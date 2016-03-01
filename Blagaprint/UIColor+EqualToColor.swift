//
//  UIColor+EqualToColor.swift
//  Blagaprint
//
//  Created by Иван Магда on 01.03.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import UIKit

extension UIColor {
    /*
    
    - (BOOL)isEqualToColor:(UIColor *)otherColor {
    CGColorSpaceRef colorSpaceRGB = CGColorSpaceCreateDeviceRGB();
    
    UIColor *(^convertColorToRGBSpace)(UIColor*) = ^(UIColor *color) {
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome) {
    const CGFloat *oldComponents = CGColorGetComponents(color.CGColor);
    CGFloat components[4] = {oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1]};
    CGColorRef colorRef = CGColorCreate( colorSpaceRGB, components );
    
    UIColor *color = [UIColor colorWithCGColor:colorRef];
    CGColorRelease(colorRef);
    return color;
    } else
    return color;
    };
    
    UIColor *selfColor = convertColorToRGBSpace(self);
    otherColor = convertColorToRGBSpace(otherColor);
    CGColorSpaceRelease(colorSpaceRGB);
    
    return [selfColor isEqual:otherColor];
    }
    
*/
    
    func isEqualToColor(otherColor: UIColor) -> Bool {
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        
        func convertColorToRGBSpace(color: UIColor) -> UIColor {
            if CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == CGColorSpaceModel.Monochrome {
                let oldComponents = CGColorGetComponents(color.CGColor)
                let components = [oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1]]
                let colorRef = CGColorCreate(colorSpaceRGB, components)
                
                if let colorRef = colorRef {
                    let rgbSpaceColor = UIColor(CGColor: colorRef)
                    
                    return rgbSpaceColor
                }
                print("Color ref doesn't created!")
            }
            
            return color
        }
        
        let selfRGBSpaceColor = convertColorToRGBSpace(self)
        let otherRGBSpaceColor = convertColorToRGBSpace(otherColor)
        
        return selfRGBSpaceColor.isEqual(otherRGBSpaceColor)
    }
}
