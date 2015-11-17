//
//  AppDelegate.swift
//  Blagaprint
//
//  Created by Ivan Magda on 27.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

let SubscriptionNotification = "SubscriptionNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    
    var window: UIWindow?
    
    var cloudKitCentral: CloudKitCentral!
    var persistence: Persistence!
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: - Persistence Stack
    
    private func setUpPersistence() {
        self.persistence = Persistence(storeUrl: self.storeUrl(), modelUrl: self.modelUrl())
        self.managedObjectContext = self.persistence.managedObjectContext
        
        spreadManagedObjectContext()
    }
    
    private func spreadManagedObjectContext() {
        let navigationController = window!.rootViewController as! UINavigationController
        let mainTableViewController = navigationController.topViewController as! MainTableViewController
        
        mainTableViewController.managedObjectContext = self.managedObjectContext
    }
    
    private func documentsDirectory() -> NSURL {
        return try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    }
    
    private func storeUrl() -> NSURL {
        return documentsDirectory().URLByAppendingPathComponent("DataStore.sqlite")
    }
    
    private func modelUrl() -> NSURL {
        return NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd")!
    }
    
    // MARK: - Application Life Cycle
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setUpPersistence()
        cloudKitCentral = CloudKitCentral.sharedInstance
        
        AppAppearance.applyAppAppearance()
        AppConfiguration.setUp()
        
        registerForPushNotifications(application)
        
        return true
    }
    
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let castedUserInfo = userInfo as! [String: NSObject]
        let notification = CKNotification(fromRemoteNotificationDictionary: castedUserInfo)
        if notification.notificationType == .Query {
            NSNotificationCenter.defaultCenter().postNotificationName(SubscriptionNotification, object: nil, userInfo: ["subscriptionID": notification.subscriptionID!])
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        persistence.saveContext()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        persistence.saveContext()
    }
}

