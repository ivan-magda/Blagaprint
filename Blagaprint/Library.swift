//
//  Library.swift
//  Blagaprint
//
//  Created by Иван Магда on 04.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreData

protocol SortByNameProtocol {
    var name: String { get set }
}

/// Notification name, when data donwloading from CloudKit completed.
let LibraryDidDoneWithCloudKitDataDownloadingNotification = "LibraryDidDoneWithCloudKitDataDownloading"

/// Notification name, when data loading from cache completed.
let LibraryDidDoneWithDataLoadingFromCacheNotification = "LibraryDidDoneWithDataLoadingFromCache"

class Library {
    // MARK: - Types
    
    typealias Callback = () -> ()
    
    // MARK: Properties
    
    class var sharedInstance: Library {
        struct Static {
            static var instance: Library?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Library()
        }
        
        return Static.instance!
    }
    
    var categories: [Category] = []
    var categoriesItems: [CategoryItem] = []
    
    // MARK: - Data Managing -
    
    func loadData(callback: Callback) {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(Library.storeUrl().path!) {
            loadFromDataBase(callback)
        } else {
            loadFromCloudKit(callback)
        }
    }
    
    // MARK: CloudKit
    
    func loadFromCloudKit(callback: Callback) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        weak var weakSelf = self
        let cloudKitCentral = CloudKitCentral.sharedInstance
        CategoryItem.countFromCloudKitWithCompletionHandler() {
            count in
            let query = CKQuery(recordType: CategoryRecordType, predicate: NSPredicate(value: true))
            query.sortDescriptors = [NSSortDescriptor(key: CloudKitFieldNames.Name.rawValue, ascending: false)]
            let queryOperation = CKQueryOperation(query: query)
            weakSelf!.categories.removeAll(keepCapacity: true)
            weakSelf!.categoriesItems.removeAll(keepCapacity: true)
            
            // Fetched block for each category.
            queryOperation.recordFetchedBlock = {
                record in
                let category = Category(record: record as CKRecord)
                debugPrint(category)
                
                let reference = CKReference(record: record as CKRecord, action: .DeleteSelf)
                let predicate = NSPredicate(format: "ParentCategory == %@", reference)
                let query = CKQuery(recordType: CategoryItemRecordType, predicate: predicate)
                let categoryItemOperation = CKQueryOperation(query: query)
                
                // Fetched block for each category item
                categoryItemOperation.recordFetchedBlock = {
                    record in
                    let categoryItem = CategoryItem(record: record as CKRecord)
                    categoryItem.parentCategory = category
                    category.categoryItems.append(categoryItem)
                    weakSelf!.categoriesItems.append(categoryItem)
                    debugPrint(categoryItem)
                }
                
                // Completion block for each category items in specific category.
                categoryItemOperation.queryCompletionBlock = {
                    cursor, error in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            weakSelf!.categoriesItems = weakSelf!.sortedArrayByName(weakSelf!.categoriesItems, ascending: true)
                            
                            // We are done with fetching if all categories items fetched.
                            if weakSelf!.categoriesItems.count == count {
                                if Library.dataBaseExist() {
                                    weakSelf!.deleteData()
                                }
                                weakSelf!.saveToDatabase()
                                
                                // Post notification.
                                NSNotificationCenter.defaultCenter().postNotificationName(LibraryDidDoneWithCloudKitDataDownloadingNotification, object: nil)
                                
                                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                
                                print("Done with load from CloudKit")
                                
                                callback()
                            }
                        }
                    }
                }
                Library.sharedInstance.categories.append(category)
                cloudKitCentral.publicDatabase.addOperation(categoryItemOperation)
            }
            cloudKitCentral.publicDatabase.addOperation(queryOperation)
        }
    }
    
    // MARK: Cache
    
    class func dataBaseExist() -> Bool {
        let fileManager = NSFileManager.defaultManager()
        
        // Count for categories
        let request = NSFetchRequest(entityName: CategoryDataEntityName)
        var error: NSError?
        let count = Persistence.sharedInstance.managedObjectContext.countForFetchRequest(request, error: &error)
        if error != nil {
            print("Error: \(error!.localizedDescription)")
        }
        
        return (fileManager.fileExistsAtPath(Persistence.sharedInstance.storeUrl.path!) && count > 0)
    }
    
    func loadFromDataBase(callback: Callback) {
        let request = NSFetchRequest(entityName: CategoryDataEntityName)
        request.returnsObjectsAsFaults = false
        
        let sort = NSSortDescriptor(key: "name", ascending: false)
        request.sortDescriptors = [sort]
        
        var fetchedCategories: [CategoryData]?
        do {
            fetchedCategories = try Persistence.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [CategoryData]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        if fetchedCategories != nil {
            for categoryData in fetchedCategories! {
                let category = Category(categoryData: categoryData)
                if let items = categoryData.items?.allObjects as? [CategoryItemData] {
                    for categoryItem in items {
                        let item = CategoryItem(categoryItemData: categoryItem)
                        item.parentCategory = category
                        category.categoryItems.append(item)
                        
                        self.categoriesItems.append(item)
                    }
                }
                self.categories.append(category)
            }
        }
        Persistence.sharedInstance.managedObjectContext.refreshAllObjects()
        
        self.categories = sortedArrayByName(categories, ascending: false)
        self.categoriesItems = sortedArrayByName(categoriesItems, ascending: true)
        
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            NSNotificationCenter.defaultCenter().postNotificationName(LibraryDidDoneWithDataLoadingFromCacheNotification, object: nil)
            print("Done with load from database")
            callback()
        }
    }
    
    func saveToDatabase() {
        let persistence = Persistence.sharedInstance
        
        for category in categories {
            let categoryData = NSEntityDescription.insertNewObjectForEntityForName(CategoryDataEntityName, inManagedObjectContext: persistence.managedObjectContext) as! CategoryData
            categoryData.name = category.name
            categoryData.recordName = category.recordName
            categoryData.recordChangeTag = category.recordChangeTag
            categoryData.recordName = category.recordName
            categoryData.type = category.categoryType.rawValue
            categoryData.imageUrl = category.imageUrl
            if let image = category.image {
                categoryData.image = UIImageJPEGRepresentation(image, 1.0)
            }
            
            let itemsSet = NSMutableSet(capacity: category.categoryItems.count)
            for categoryItem in category.categoryItems {
                let categoryItemData = NSEntityDescription.insertNewObjectForEntityForName(CategoryItemDataEntityName, inManagedObjectContext: persistence.managedObjectContext) as! CategoryItemData
                categoryItemData.name = categoryItem.name
                categoryItemData.recordName = categoryItem.recordName
                categoryItemData.recordChangeTag = categoryItem.recordChangeTag
                if let image = categoryItem.image {
                    categoryItemData.image = UIImageJPEGRepresentation(image, 1.0)
                }
                categoryItemData.imageUrl = categoryItem.imageUrl
                categoryItemData.parentCategory = categoryData
                
                itemsSet.addObject(categoryItemData)
            }
            categoryData.items = itemsSet
        }
        persistence.saveContext()
        
        Persistence.sharedInstance.managedObjectContext.refreshAllObjects()
        print("Done with save to database")
    }
    
    func deleteData() {
        Persistence.sharedInstance.deleteData()
    }
    
    class func storeUrl() -> NSURL {
        return Persistence.sharedInstance.storeUrl
    }
    
    // MARK: - Sorting Array -
    
    func sortedArrayByName<T: SortByNameProtocol>(arrayToSort: [T], ascending: Bool) -> [T] {
        if ascending {
            return arrayToSort.sort() {
                $0.name < $1.name
            }
        } else {
            return arrayToSort.sort() {
                $0.name > $1.name
            }
        }
    }
}
