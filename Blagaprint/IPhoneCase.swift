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
    
    /// Case text.
    var text: String = "BLAGAPRINT" {
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
    
    // MARK: - Drawing
    
    override func drawRect(rect: CGRect) {
        PhoneCases.drawIPhoneCase(self.bounds, fillColor: fillColor, colorOfText: textColor, caseText: text)
    }
}
