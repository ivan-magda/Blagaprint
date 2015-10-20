//
//  IPhoneCase.swift
//  Blagaprint
//
//  Created by Ivan Magda on 11.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

@IBDesignable
class IPhoneCase: UIView {
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
        PhoneCase.drawIPhoneCase(self.bounds, fillColor: fillColor, colorOfText: textColor, image: image, caseText: text, backgroundImageVisible: showBackgroundImage)
    }
    
    // MARK: - Text Label Dimensions
    
    static func getTextRectHeightFromNumberOfCharacters(characters: Int) -> CGFloat {
        switch characters {
        case 1, 2:
            return 179.0
        case 3:
            return 127.86
        case 4:
            return 89.5
        case 5:
            return 74.58
        case 6:
            return 61.72
        case 7:
            return 51.14
        case 8:
            return 44.75
        case 9:
            return 42.62
        case 10:
            return 40.68
        case 11:
            return 35.8
        case 12:
            return 34.42
        default:
            return 30.34
        }
    }
    
    static func getTextYscaleFromNumberOfCharacters(characters: Int) -> CGFloat {
        switch characters {
        case 1, 2:
            return 1
        case 3:
            return 1.4
        case 4:
            return 2.0
        case 5:
            return 2.4
        case 6:
            return 2.9
        case 7:
            return 3.5
        case 8:
            return 4.0
        case 9:
            return 4.2
        case 10:
            return 4.4
        case 11:
            return 5.0
        case 12:
            return 5.2
        default:
            return 5.9
        }
    }
    
    static func getTextFontSizeFromNumberOfCharacters(characters: Int) -> CGFloat {
        switch characters {
        case 1, 2:
            return 200.0
        case 3:
            return 136.0
        case 4:
            return 100.0
        case 5:
            return 81.0
        case 6:
            return 69.0
        case 7:
            return 57.0
        case 8:
            return 50.0
        case 9:
            return 47.0
        case 10:
            return 44.0
        case 11:
            return 39.0
        case 12:
            return 37.0
        default:
            return 33.0
        }
    }
}
