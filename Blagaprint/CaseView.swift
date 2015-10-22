//
//  IPhoneCase.swift
//  Blagaprint
//
//  Created by Ivan Magda on 11.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

/// Max font size value.
let MaxFontSize: CGFloat = 200.0

/// Min font size value.
let MinFontSize: CGFloat = 46.0

@IBDesignable
class CaseView: UIView {
    // MARK: - Properties
    
    /// Case fill color.
    var fillColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// Text color.
    var textColor: UIColor = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// Case background image.
    var image: UIImage = UIImage() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// Case text.
    var text: String = "BLAGAPRINT" {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// Background image visability.
    var showBackgroundImage: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Drawing
    
    override func drawRect(rect: CGRect) {
        PhoneCase.drawIPhone5Case(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, caseText: text, backgroundImageVisible: showBackgroundImage)
    }
    
    // MARK: - Text Label Dimensions
    
    static func fontSizeThatFitsRect(rect: CGRect, withText text: String) -> CGFloat {
        let label = UILabel(frame: rect)
        label.text = text
        
        // Try all font sizes from largest to smallest font size
        var fontSize = MaxFontSize
        let minFontSize = MinFontSize
        
        // Fit label width wize
        let constraintSize = CGSizeMake(label.frame.size.width, CGFloat.max)
        
        repeat {
            // Set current font size
            label.font = AppAppearance.andersonSupercarFontWithSize(fontSize)
            
            // Find label size for current font size
            let textRect = (label.text! as NSString).boundingRectWithSize(constraintSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: label.font], context: nil)
            
            let labelSize = textRect.size
            
            // Done, if created label is within target size
            if labelSize.height <= CGRectGetHeight(label.bounds) {
                break
            }
            
            // Decrease the font size and try again
            --fontSize
        } while fontSize > minFontSize
        
        return fontSize
    }
    
    static func getTextRectHeightFromNumberOfCharacters(characters: Int) -> CGFloat {
        switch characters {
        case 1, 2, 3:
            return 200.0
        case 4:
            return 167.0
        case 5:
            return 143.0
        case 6:
            return 125.0
        case 7:
            return 112.0
        case 8:
            return 100.0
        case 9:
            return 91.0
        case 10:
            return 84.0
        case 11:
            return 77.0
        case 12:
            return 72.0
        default:
            return 67.0
        }
    }
    
    static func getTextYscaleFromNumberOfCharacters(characters: Int) -> CGFloat {
        var scale: CGFloat = 1.0
        for i in 1...characters {
            if i > 3 {
                scale += 0.2
            }
        }
        print("Y scale = \(scale)")
        
        return scale
    }
    
    static func getTextFontSizeFromNumberOfCharacters(characters: Int) -> CGFloat {
        switch characters {
        case 1, 2, 3:
            return MaxFontSize
        case 4:
            return 151.0
        case 5:
            return 121.0
        case 6:
            return 100.0
        case 7:
            return 86.0
        case 8:
            return 75.0
        case 9:
            return 67.0
        case 10:
            return 60.0
        case 11:
            return 55.0
        case 12:
            return 50.0
        default:
            return MinFontSize
        }
    }
}
