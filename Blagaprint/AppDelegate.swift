//
//  AppDelegate.swift
//  Blagaprint
//
//  Created by Ivan Magda on 27.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit
import Parse

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
    // MARK: - Properties
    
    var window: UIWindow?
    
    var parse: Parse?
    var parseCentral: ParseCentral?
    
    var dataService: DataService!
    private var dataListener: DataListener!
    
    //--------------------------------------
    // MARK: - Private
    //--------------------------------------
    
    private func confParseWithOptions(launchOptions: [NSObject: AnyObject]?) {
        self.parseCentral = ParseCentral.sharedInstance
        if let parseCentral = self.parseCentral {
            self.parse = parseCentral.parse
        }
        
        assert(self.parseCentral != nil, "ParseCentral must exist")
        
        // TODO: Rewrite it
        self.dataService = DataService.sharedInstance
        
        // Spread ParseCentral
        let tabBarController = window!.rootViewController as! UITabBarController
        
        // To CategoryTableViewController
        let categoryNavigationController = tabBarController.viewControllers![0] as! UINavigationController
        let categoryTableViewController = categoryNavigationController.topViewController as! CategoryTableViewController
        categoryTableViewController.dataService = self.dataService
        
        // To ShoppingBagViewController
        let shoppingBagNavigationController = tabBarController.viewControllers![1] as! UINavigationController
        let shoppingBagViewController = shoppingBagNavigationController.topViewController as! ShoppingBagViewController
        shoppingBagViewController.parseCentral = self.parseCentral
    }
    
    //--------------------------------------
    // MARK: - Application Life Cycle
    //--------------------------------------
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        confParseWithOptions(launchOptions)
        
        AppAppearance.applyAppAppearance()
        AppConfiguration.setUp()
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        // Enable persistence storage.
        Firebase.defaultConfig().persistenceEnabled = true
        
        // Start listen for data changes.
        dataListener = DataListener.sharedInstance
        dataListener.startListen()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationWillResignActive(application: UIApplication) {
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        self.parseCentral?.removeObservers()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        self.parseCentral?.addObservers()
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
        // Store the deviceToken in the current installation and save it to Parse.
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
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
}

