//
//  AppDelegate.swift
//  Blagaprint
//
//  Created by Ivan Magda on 27.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    
    var window: UIWindow?
    
    var parse: Parse?
    var parseCentral: ParseCentral?
    
    // MARK: - Private
    
    private func confParseWithOptions(launchOptions: [NSObject: AnyObject]?) {
        self.parseCentral = ParseCentral.sharedInstance
        if let parseCentral = self.parseCentral {
            self.parse = parseCentral.parse
        }
        
        assert(self.parseCentral != nil, "ParseCentral must exist")
        
        // Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        // Spread ParseCentral
        let tabBarController = window!.rootViewController as! UITabBarController
        
        // To CategoryTableViewController
        let categoryNavigationController = tabBarController.viewControllers![0] as! UINavigationController
        let categoryTableViewController = categoryNavigationController.topViewController as! CategoryTableViewController
        categoryTableViewController.parseCentral = self.parseCentral
        
        // To ShoppingBagViewController
        let shoppingBagNavigationController = tabBarController.viewControllers![1] as! UINavigationController
        let shoppingBagViewController = shoppingBagNavigationController.topViewController as! ShoppingBagViewController
        shoppingBagViewController.parseCentral = self.parseCentral
    }
    
    
    // MARK: - Application Life Cycle
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        confParseWithOptions(launchOptions)
        
        AppAppearance.applyAppAppearance()
        AppConfiguration.setUp()
        
        return true
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
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
    }
    
    func applicationWillTerminate(application: UIApplication) {
    }
}

