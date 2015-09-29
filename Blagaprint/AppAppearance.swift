//
//  AppAppearance.swift
//  Blagaprint
//
//  Created by Ivan Magda on 29.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class AppAppearance: NSObject {
    
    static let vulcanColor: UIColor = UIColor(red: 21.0 / 255.0, green: 21.0 / 255.0, blue: 34.0 / 255, alpha: 1)
    static let malibuColor: UIColor = UIColor(red: 89.0 / 255.0, green: 189.0 / 255.0, blue: 247.0 / 255.0, alpha: 1)
    static let ebonyClayColor: UIColor = UIColor(red: 40.0 / 255.0, green: 37.0 / 255.0, blue: 60.0 / 255.0, alpha: 1)
    
    static func applyAppAppearance() {
        customizeNavigationAndStatusBars()
    }
    
    private static func customizeNavigationAndStatusBars() {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        UINavigationBar.appearance().barTintColor = vulcanColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
}
