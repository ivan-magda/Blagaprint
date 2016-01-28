//
//  AppConfiguration.swift
//  Blagaprint
//
//  Created by Иван Магда on 11.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation

class AppConfiguration: NSObject {
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    enum ShortcutItemType: String {
        case goToCatalog = "com.IvanMagda.Blagaprint.goToCatalog"
        case goToShoppingBag = "com.IvanMagda.Blagaprint.goToShoppingBag"
        case goToAccount = "com.IvanMagda.Blagaprint.goToAccount"
    }
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    static internal let IsFirstTimeAppLaunchIdentifier = "IsFirstLaunch"
    static private let RegisterDefaultsIdentifier = "RegisterDefaults"
    
    //--------------------------------------
    // MARK: - Methods
    //--------------------------------------
    
    class func setUp() {
        AppConfiguration.registerUserDefaults()
    }
    
    class func isFirstTimeAppLaunch() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(IsFirstTimeAppLaunchIdentifier)
    }
    
    private class func registerUserDefaults() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if !userDefaults.boolForKey(RegisterDefaultsIdentifier) {
            userDefaults.setBool(true, forKey: IsFirstTimeAppLaunchIdentifier)
            userDefaults.setBool(true, forKey: RegisterDefaultsIdentifier)
            userDefaults.synchronize()
        }
    }
}