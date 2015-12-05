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
    
    private func confParse() {
        self.parseCentral = ParseCentral.sharedInstance
        if let parseCentral = self.parseCentral {
            self.parse = parseCentral.parse
        }
        
        let navigationController = window!.rootViewController as! UINavigationController
        let mainTableViewController = navigationController.topViewController as! MainQueryTableViewController
        mainTableViewController.parseCentral = self.parseCentral
    }
    
    
    // MARK: - Application Life Cycle
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        confParse()
        
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

