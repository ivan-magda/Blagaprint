//
//  AppConfiguration.swift
//  Blagaprint
//
//  Created by Иван Магда on 11.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation

let IsFirstTimeAppLaunchIdentifier: String = "IsFirstLaunch"
private let RegisterDefaultsIdentifier = "RegisterDefaults"

class AppConfiguration: NSObject {
    // MARK: - Methods
    
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
        }
    }
}