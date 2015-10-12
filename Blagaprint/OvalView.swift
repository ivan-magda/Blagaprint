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
    // MARK: - Properties
    
    var fillColor: UIColor = UIColor.redColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Drawing
    
    override func drawRect(rect: CGRect) {
        BackgroundOvalView.drawOvalView(self.bounds, fillColor: fillColor)
    }
}
