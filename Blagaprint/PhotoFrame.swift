//
//  PhotoFrame.swift
//  Blagaprint
//
//  Created by Иван Магда on 24.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import UIKit

/// Photo frame types enum.
enum PhotoFrameType: String {
    case SH_2
    case SH_3
    case SH_11
    case SH_15
    case SH_19
    case SH_38
}

class PhotoFrame: NSObject {
    // MARK: - Properties
    
    /// Type of the frame.
    var type: PhotoFrameType
    
    /// Size for picked image.
    var pickedImageSize: CGSize
    
    /// Frame image.
    var image: UIImage
    
    /// Frame description.
    var descriptionText: String
    
    // MARK: - Init
    
    init(type: PhotoFrameType, imageSize: CGSize, image: UIImage, description: String) {
        self.type = type
        self.pickedImageSize = imageSize
        self.image = image
        self.descriptionText = description
        
        super.init()
    }
    
    // MARK: - Frame Image
    
    /// Return only frame image, without picked image.
    func frameImage() -> UIImage {
        switch self.type {
        case .SH_2:
            return SH2_PhotoFrame.imageOfSH2()
        case .SH_3:
            return SH3_PhotoFrame.imageOfSH3()
        case .SH_11:
            return SH11_PhotoFrame.imageOfSH11()
        case .SH_15:
            return SH15_PhotoFrame.imageOfSH15()
        case .SH_19:
            return SH19_PhotoFrame.imageOfSH19()
        case .SH_38:
            return SH38_PhotoFrame.imageOfSH38()
        }
    }

    /// Return frame image with picked image.
    func frameImageWithPickedImage(image: UIImage) -> UIImage {
        let resizedImage = UIImage.resizedImage(image, newSize: self.pickedImageSize)
        switch self.type {
        case .SH_2:
            return SH2_PhotoFrame.imageOfSH2(pickedImage: resizedImage)
        case .SH_3:
            return SH3_PhotoFrame.imageOfSH3(pickedImage: resizedImage)
        case .SH_11:
            return SH11_PhotoFrame.imageOfSH11(pickedImage: resizedImage)
        case .SH_15:
            return SH15_PhotoFrame.imageOfSH15(pickedImage: resizedImage)
        case .SH_19:
            return SH19_PhotoFrame.imageOfSH19(pickedImage: resizedImage)
        case .SH_38:
            return SH38_PhotoFrame.imageOfSH38(pickedImage: resizedImage)
        }
    }
    
    // MARK: - Seed
    
    class func seedInitialFrames() -> [PhotoFrame] {
        var frames = [PhotoFrame]()
        
        frames.append(PhotoFrame(type:  .SH_2, imageSize: CGSizeMake(468.0, 450.0), image: SH2_PhotoFrame.imageOfSH2(), description: ""))
        frames.append(PhotoFrame(type:  .SH_3, imageSize: CGSizeMake(402.0, 286.0), image: SH3_PhotoFrame.imageOfSH3(), description: ""))
        frames.append(PhotoFrame(type: .SH_11, imageSize: CGSizeMake(492.0, 503.0), image: SH11_PhotoFrame.imageOfSH11(), description: ""))
        frames.append(PhotoFrame(type: .SH_15, imageSize: CGSizeMake(751.0, 338.0), image: SH15_PhotoFrame.imageOfSH15(), description: ""))
        frames.append(PhotoFrame(type: .SH_19, imageSize: CGSizeMake(400.0, 400.0), image: SH19_PhotoFrame.imageOfSH19(), description: ""))
        frames.append(PhotoFrame(type: .SH_38, imageSize: CGSizeMake(282.0, 200.0), image: SH38_PhotoFrame.imageOfSH38(), description: ""))
        
        return frames
    }
}

// MARK: - UIImage Extension -

extension UIImage {
    class func resizedImage(image: UIImage, newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        let newImageRect = CGRectMake(0.0, 0.0, newSize.width, newSize.height)
        image.drawInRect(newImageRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
