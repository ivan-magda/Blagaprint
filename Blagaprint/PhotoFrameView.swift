//
//  PhotoFrameView.swift
//  Blagaprint
//
//  Created by Иван Магда on 21.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

@IBDesignable
class PhotoFrameView: UIView {
    // MARK: - Properties
    
    /// Photo frame picked image.
    var image: UIImage = UIImage() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Drawing
    
    override func drawRect(rect: CGRect) {
        SH38_PhotoFrame.drawSH38(frame: rect, pickedImage: image)
    }
}
