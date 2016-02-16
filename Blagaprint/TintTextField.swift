//
//  TintTextField.swift
//  Blagaprint
//
//  Created by Иван Магда on 15.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import UIKit

class TintTextField: UITextField {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var tintedClearImage: UIImage?
    
    /// Color of clear button.
    var clearButtonColor: UIColor = .whiteColor()
    
    //--------------------------------------
    // MARK: - View Life Cycle
    //--------------------------------------
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tintClearImage()
    }
    
    //--------------------------------------
    // MARK: - Helper
    //--------------------------------------
    
    private func tintClearImage() {
        subviews.flatMap{ $0 as? UIButton }.forEach { button in
            if let image = button.imageForState(.Highlighted) {
                
                if tintedClearImage == nil {
                    tintedClearImage = tintImage(image, color: clearButtonColor)
                }
                
                button.setImage(tintedClearImage, forState: .Normal)
                button.setImage(tintedClearImage, forState: .Highlighted)
            }
        }
    }
    
    func tintImage(image: UIImage, color: UIColor) -> UIImage {
        let size = image.size
        
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.drawAtPoint(.zero, blendMode: .Normal, alpha: 1.0)
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextSetBlendMode(context, .SourceIn)
        CGContextSetAlpha(context, 1.0)
        
        let rect = CGRectMake(
            CGPoint.zero.x,
            CGPoint.zero.y,
            image.size.width,
            image.size.height
        )
        
        CGContextFillRect(UIGraphicsGetCurrentContext(), rect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage
    }
}