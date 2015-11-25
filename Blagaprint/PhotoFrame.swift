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
    
    /// Picked image.
    var image: UIImage?
    
    /// Frame description.
    var descriptionText: String
    
    // MARK: - Init
    
    init(type: PhotoFrameType, imageSize: CGSize, image: UIImage?, description: String) {
        self.type = type
        self.pickedImageSize = imageSize
        self.image = image
        self.descriptionText = description
        
        super.init()
    }
    
    // MARK: - Seed
    
    class func seedInitialFrames() -> [PhotoFrame] {
        var frames = [PhotoFrame]()
        
        frames.append(PhotoFrame(type:  .SH_2, imageSize: CGSizeMake(468.0, 450.0), image: nil, description: ""))
        frames.append(PhotoFrame(type:  .SH_3, imageSize: CGSizeMake(402.0, 286.0), image: nil, description: ""))
        frames.append(PhotoFrame(type: .SH_11, imageSize: CGSizeMake(492.0, 503.0), image: nil, description: ""))
        frames.append(PhotoFrame(type: .SH_15, imageSize: CGSizeMake(751.0, 338.0), image: nil, description: ""))
        frames.append(PhotoFrame(type: .SH_19, imageSize: CGSizeMake(400.0, 400.0), image: nil, description: ""))
        frames.append(PhotoFrame(type: .SH_38, imageSize: CGSizeMake(282.0, 200.0), image: nil, description: ""))
        
        return frames
    }
}
