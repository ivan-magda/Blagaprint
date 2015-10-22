//
//  AppAppearance.swift
//  Blagaprint
//
//  Created by Ivan Magda on 29.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class AppAppearance: NSObject {
    // MARK: Colors
    
    struct AppColors {
        static let vulcanColor: UIColor = UIColor(red: 21.0 / 255.0, green: 21.0 / 255.0, blue: 34.0 / 255, alpha: 1)
        static let malibuColor: UIColor = UIColor(red: 89.0 / 255.0, green: 189.0 / 255.0, blue: 247.0 / 255.0, alpha: 1)
        static let ebonyClayColor: UIColor = UIColor(red: 40.0 / 255.0, green: 37.0 / 255.0, blue: 60.0 / 255.0, alpha: 1)
        static let brightGray: UIColor = UIColor(red: 65.0 / 255.0, green: 62.0 / 255.0, blue: 80.0 / 255.0, alpha: 1)
        static let haiti: UIColor = UIColor(red: 44.0 / 255.0, green: 42.0 / 255.0, blue: 55.0 / 255.0, alpha: 1)
        static let tuna: UIColor = UIColor(red: 54.0 / 255.0, green: 54.0 / 255.0, blue: 66.0 / 255.0, alpha: 1)
    }
    
    // MARK: - Public
    
    static func applyAppAppearance() {
        customizeNavigationAndStatusBars()
    }
    
    /// Return Anderson Supercar font with passed size.
    static func andersonSupercarFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "AndersonSupercar", size: size)!
    }
    
    // MARK: - Private
    
    private static func customizeNavigationAndStatusBars() {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        UINavigationBar.appearance().barTintColor = self.AppColors.vulcanColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
}

// MARK: - UINavigationBar extension

extension UINavigationBar {
    
    static func hideBottomLineFromNavigationController(navigationController: UINavigationController) {
        navigationController.navigationBar.translucent = false
        navigationController.navigationBar.setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        navigationController.navigationBar.shadowImage = UIImage()
    }
    
}