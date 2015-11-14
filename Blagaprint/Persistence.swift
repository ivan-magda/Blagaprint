//
//  Persistence.swift
//  Blagaprint
//
//  Created by Иван Магда on 13.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Persistence: NSObject {
    // MARK: Properties
    
    var storeUrl: NSURL
    private var modelUrl: NSURL
    
    class var sharedInstance: Persistence {
        struct Static {
            static var instance: Persistence?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            Static.instance = appDelegate.persistence
        }
        
        return Static.instance!
    }
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return context
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption : true]
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.storeUrl, options: options)
        } catch {
            print("Error adding persistence store. \(error)")
        }
        
        return coordinator
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
       return NSManagedObjectModel(contentsOfURL: self.modelUrl)!
    }()
    
    // MARK: - Initialize
    
    init(storeUrl: NSURL, modelUrl: NSURL) {
        self.storeUrl = storeUrl
        self.modelUrl = modelUrl
        
        super.init()
    }
    
    // MARK: - Core Data Saving Support
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }
    }
    
    // MARK: - Core Data Deleting Support
    
    func deleteData() {
        let context = Persistence.sharedInstance.managedObjectContext
        let fetchedCategories = CategoryData.getAllCategories(context)
        if fetchedCategories != nil {
            for category in fetchedCategories! {
                context.deleteObject(category)
            }
            saveContext()
        }
    }
}
