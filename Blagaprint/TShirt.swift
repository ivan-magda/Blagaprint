//
//  TShirt.swift
//  Blagaprint
//
//  Created by Иван Магда on 07.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation

class TShirt {
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    struct TShirtImageLocations: OptionSetType {
        let rawValue: Int
        
        static let None   = TShirtImageLocations(rawValue: -1)
        static let Front  = TShirtImageLocations(rawValue: 1 << 0)
        static let Behind = TShirtImageLocations(rawValue: 1 << 1)
    }
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    /// Size of picked image.
    private let pickedImageSize = CGSize(width: 120.0, height: 170.0)
    
    /// T-Shirt image.
    var image: UIImage
    
    /// T-Shirt image location.
    var imageLocation: TShirtImageLocations = .Front
    
    /// Show or hide the image.
    var isImageVisible = false
    
    /// T-Shirt color.
    var color = UIColor.whiteColor()
    
    /// T-Shirt size.
    var size = "M"
    
    //--------------------------------------
    // MARK: - Init
    //--------------------------------------
    
    init(image: UIImage = UIImage(), isImageVisible visible: Bool = false, imageLocation: TShirtImageLocations = .Front, color: UIColor = UIColor.whiteColor(), size: String = "M") {
        self.image = image
        self.isImageVisible = visible
        self.imageLocation = imageLocation
        self.color = color
        self.size = size
    }
    
    //--------------------------------------
    // MARK: - T-Shirt Image
    //--------------------------------------
    
    func tShirtImages() -> [UIImage] {
        let resizedImage = (isImageVisible == true ? image.resizedImageWithContentMode(.ScaleAspectFill, bounds: pickedImageSize, interpolationQuality: .High) : UIImage())
        
        let showImageInFront = imageLocation.contains(.Front)  && !imageLocation.contains(.None)
        let showImageBehind  = imageLocation.contains(.Behind) && !imageLocation.contains(.None)
        
        let frontImage = TShirtCanvas.imageOfFront(tshirtColor: color, image: (showImageInFront == true ? resizedImage : UIImage()), imageVisible: isImageVisible)
        let behindImage = TShirtCanvas.imageOfBack(tshirtColor: color, image: (showImageBehind == true ? resizedImage : UIImage()), imageVisible: isImageVisible)
        
        return [frontImage, behindImage]
    }

}