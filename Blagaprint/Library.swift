//
//  Library.swift
//  Blagaprint
//
//  Created by Иван Магда on 04.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import CloudKit

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
        if fileManager.fileExistsAtPath(Library.sharedInstance.cacheUrl().path!) {
            loadFromCache(callback)
        } else {
            loadFromCloudKit(callback)
        }
    }
    
    // MARK: CloudKit
    
    func loadFromCloudKit(callback: Callback) {
        weak var library = Library.sharedInstance
        let cloudKitCentral = CloudKitCentral.sharedInstance
        CategoryItem.countFromCloudKitWithCompletionHandler() {
            count in
            let query = CKQuery(recordType: CategoryRecordType, predicate: NSPredicate(value: true))
            let queryOperation = CKQueryOperation(query: query)
            library!.categories.removeAll(keepCapacity: true)
            library!.categoriesItems.removeAll(keepCapacity: true)
            
            // Fetched block for each category.
            queryOperation.recordFetchedBlock = {
                record in
                let category = Category(record: record as CKRecord)
                print("\(category)" + "\n")
                
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
                    library!.categoriesItems.append(categoryItem)
                    print("\(categoryItem)" + "\n")
                }
                
                // Completion block for each category items in specific category.
                categoryItemOperation.queryCompletionBlock = {
                    cursor, error in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        NSOperationQueue.mainQueue().addOperationWithBlock() {
                            library!.categoriesItems.sortInPlace() {
                                $0.name < $1.name
                            }
                            
                            // We are done with fetching if all categories items fetched.
                            if library!.categoriesItems.count == count {
                                NSOperationQueue().addOperationWithBlock() {
                                    library!.saveToCache()
                                }
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
    
    func loadFromCache(callback: Callback) {
        let library = Library.sharedInstance
        if let data = NSData(contentsOfURL: library.cacheUrl()) {
            if data.length > 0 {
                let decoder = NSKeyedUnarchiver(forReadingWithData: data)
                let object: AnyObject! = decoder.decodeObject()
                if object != nil {
                    library.categories = object as! [Category]
                    for category in library.categories {
                        library.categoriesItems += category.categoryItems
                        for categoryItem in category.categoryItems {
                            categoryItem.parentCategory = category
                        }
                    }
                    library.categoriesItems.sortInPlace() {
                        $0.name < $1.name
                    }
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                        print("Done with load from cache")
                        callback()
                    }
                }
            }
        }
    }
    
    func saveToCache() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeRootObject(Library.sharedInstance.categories)
        archiver.finishEncoding()
        data.writeToURL(cacheUrl(), atomically: true)
        
        print("Save to cache")
    }
    
    func deleteCache() {
        let url = cacheUrl()
        let fileManager = NSFileManager.defaultManager()
        
        do {
            try fileManager.removeItemAtURL(url)
            
            print("Cache deleted")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func cacheUrl() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let cacheUrl = try! fileManager.URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let saveUrl = cacheUrl.URLByAppendingPathComponent("blagaprint.cache")
        
        return saveUrl
    }
}
