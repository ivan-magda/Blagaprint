//
//  PlateView.swift
//  Blagaprint
//
//  Created by Иван Магда on 30.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

@IBDesignable
class PlateView: UIView {
    // MARK: - Properties
    
    /// Plate background image.
    var image: UIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// Background image visability.
    var showImage: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Drawing
    
    override func drawRect(rect: CGRect) {
        Plate.drawPlateCanvas(frame: rect, image: image ?? UIImage(), isPlateImageVisible: showImage)
    }

}
