//
//  AppAppearance.swift
//  Blagaprint
//
//  Created by Ivan Magda on 29.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class AppAppearance: NSObject {
    //--------------------------------------
    // MARK: Colors
    //--------------------------------------
    
    struct AppColors {
        static let vulcanColor = UIColor(red: 21.0 / 255.0, green: 21.0 / 255.0, blue: 34.0 / 255, alpha: 1)
        static let malibuColor = UIColor(red: 89.0 / 255.0, green: 189.0 / 255.0, blue: 247.0 / 255.0, alpha: 1)
        static let ebonyClayColor = UIColor(red: 40.0 / 255.0, green: 37.0 / 255.0, blue: 60.0 / 255.0, alpha: 1)
        static let brightGray = UIColor(red: 65.0 / 255.0, green: 62.0 / 255.0, blue: 80.0 / 255.0, alpha: 1)
        static let haiti = UIColor(red: 44.0 / 255.0, green: 42.0 / 255.0, blue: 55.0 / 255.0, alpha: 1)
        static let tuna = UIColor(red: 54.0 / 255.0, green: 54.0 / 255.0, blue: 66.0 / 255.0, alpha: 1)
        static let cornflowerBlue = UIColor(red: 108.0 / 255.0, green: 148.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
        static let celestialBlue = UIColor(red: 65.0 / 255.0, green: 144.0 / 255.0, blue: 219.0 / 255.0, alpha: 1.0)
    }
    
    //--------------------------------------
    // MARK: - Public
    //--------------------------------------
    
    class func applyAppAppearance() {
        customizeNavigationAndStatusBars()
        
        UITabBar.appearance().tintColor = AppAppearance.AppColors.tuna
    }
    
    class func blurredBackgroundImage() -> UIImage {
        return UIImage(named: "backgroundImage.png")!
    }
    
    //--------------------------------------
    // MARK: CAGradientLayer
    //--------------------------------------
    
    /// Returns a horizontal green gradient layer.
    class func horizontalGreenGradientLayerForRect(rect: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rect
        
        //// Color Declarations
        let color1 = UIColor(red: 76.0 / 255.0, green: 217.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0).CGColor as CGColorRef
        let color2 = UIColor(red: 38.0 / 255.0, green: 179.0 / 255.0, blue: 62.0 / 255.0, alpha: 1.0).CGColor as CGColorRef
        
        gradientLayer.colors = [color1, color2, color2, color1]
        gradientLayer.startPoint = CGPointMake(0.0, 0.5)
        gradientLayer.endPoint = CGPointMake(1.0, 0.5)
        gradientLayer.locations = [0.0, 0.25, 0.75, 1.0]
        
        return gradientLayer
    }
    
    /// Returns a horizontal tuna gradient layer.
    class func horizontalTunaGradientLayerForRect(rect: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rect
        
        //// Color Declarations
        let color1 = AppColors.tuna.colorWithAlphaComponent(0.99).CGColor as CGColorRef
        let color2 = UIColor(red: 45.0 / 255.0, green: 45.0 / 255.0, blue: 55.0 / 255.0, alpha: 1.0).colorWithAlphaComponent(0.99).CGColor as CGColorRef
        let color3 = UIColor(red: 36.0 / 255.0, green: 36.0 / 255.0, blue: 44.0 / 255.0, alpha: 1.0).colorWithAlphaComponent(0.99).CGColor as CGColorRef
        
        gradientLayer.colors = [color2, color1, color3, color2]
        gradientLayer.startPoint = CGPointMake(0.0, 0.5)
        gradientLayer.endPoint = CGPointMake(1.0, 0.5)
        gradientLayer.locations = [0.0, 0.25, 0.5, 0.85]
        
        return gradientLayer
    }
    
    //--------------------------------------
    // MARK: - UIFonts
    //--------------------------------------
    
    /// Return Anderson Supercar font with passed size.
    class func andersonSupercarFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "AndersonSupercar", size: size)!
    }
    
    /// Return UIFont with family of the Raleway-Thin with passed size.
    class func ralewayThinFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Raleway-Thin", size: size)!
    }
    
    //--------------------------------------
    // MARK: - Private
    //--------------------------------------
    
    private static func customizeNavigationAndStatusBars() {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        UINavigationBar.appearance().barTintColor = self.AppColors.vulcanColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
}

//--------------------------------------
// MARK: - UINavigationBar extension -
//--------------------------------------

extension UINavigationBar {
    class func hideBottomLineFromNavigationController(navigationController: UINavigationController) {
        navigationController.navigationBar.translucent = false
        navigationController.navigationBar.setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        navigationController.navigationBar.shadowImage = UIImage()
    }
}