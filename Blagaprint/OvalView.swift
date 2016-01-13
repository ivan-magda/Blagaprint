//
//  OvalView.swift
//  Blagaprint
//
//  Created by Ivan Magda on 12.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

@IBDesignable
class OvalView: UIView {
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    /// Fill color.
    var fillColor: UIColor = UIColor.redColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// Show or hide checkmark.
    var checkmarkVisible: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// Checkmark stroke color.
    var checkmarkStrokeColor: UIColor {
        get {
            if fillColor == UIColor.blackColor() ||
               fillColor == UIColor.grayColor() {
                return UIColor.whiteColor()
            } else {
                let fillColorRedComponent: CGFloat = 1,
                fillColorGreenComponent: CGFloat = 1,
                fillColorBlueComponent: CGFloat = 1
                
                let strokeColor = UIColor(red: (fillColorRedComponent * 0.5), green: (fillColorGreenComponent * 0.5), blue: (fillColorBlueComponent * 0.5), alpha: (CGColorGetAlpha(fillColor.CGColor) * 0.5 + 0.5))
                
                return strokeColor
            }
        }
    }
    
    //--------------------------------------
    // MARK: - Drawing
    //--------------------------------------
    
    override func drawRect(rect: CGRect) {
        BackgroundOvalView.drawOvalView(self.bounds, fillColor: fillColor, visible: checkmarkVisible)
    }
}
