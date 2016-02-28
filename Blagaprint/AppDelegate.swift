//
//  AppDelegate.swift
//  Blagaprint
//
//  Created by Ivan Magda on 27.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

/// The index of the view controller associated with the tab item.
enum TabItemIndex: Int {
    case CatalogViewController
    case ShoppingBagViewController
    case AccountViewController
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var window: UIWindow?
    
    var dataService: DataService!
    private var dataListener: DataListener!
    
    //--------------------------------------
    // MARK: - Application Life Cycle
    //--------------------------------------
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        configurateFirebase()
        
        AppAppearance.applyAppAppearance()
        AppConfiguration.setUp()
        
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationWillResignActive(application: UIApplication) {
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        dataService.reachability.removeObservers()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        dataService.reachability.addObservers()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    //--------------------------------------
    // MARK: - Push Notifications
    //--------------------------------------
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    }
    
    //--------------------------------------
    // MARK: - Shortcut Items
    //--------------------------------------
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        print("User selects a Home screen quick action with type: \(shortcutItem.type)")
        
        /// Nested function, that select view controller from TabItemIndex.
        func selectTabBarIndex(index: TabItemIndex) {
            if let tabBarController = window?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = index.rawValue
            }
        }
        
        if let shortcutItemType = AppConfiguration.ShortcutItemType(rawValue: shortcutItem.type) {
            switch shortcutItemType {
            case .goToCatalog:
                selectTabBarIndex(TabItemIndex.CatalogViewController)
            case .goToShoppingBag:
                selectTabBarIndex(TabItemIndex.ShoppingBagViewController)
            case .goToAccount:
                selectTabBarIndex(TabItemIndex.AccountViewController)
            }
        }
    }
    
    
    //--------------------------------------
    // MARK: - Private
    //--------------------------------------
    
    private func configurateFirebase() {
        dataService = DataService.sharedInstance
        dataService.reachability.monitorReachability()
        
        let tabBarController = window!.rootViewController as! UITabBarController
        
        // To CatalogViewController
        let categoryNavigationController = tabBarController.viewControllers![TabItemIndex.CatalogViewController.rawValue] as! UINavigationController
        let categoryTableViewController = categoryNavigationController.topViewController as! CategoryTableViewController
        categoryTableViewController.dataService = dataService
        
        // To ShoppingBagViewController
        let shoppingBagNavigationController = tabBarController.viewControllers![TabItemIndex.ShoppingBagViewController.rawValue] as! UINavigationController
        let shoppingBagViewController = shoppingBagNavigationController.topViewController as! ShoppingBagViewController
        shoppingBagViewController.dataService = dataService
        
        // Enable persistence storage.
        Firebase.defaultConfig().persistenceEnabled = true
        
        // Start listen for data changes.
        dataListener = DataListener.sharedInstance
        dataListener.startListen()
    }
    
}

