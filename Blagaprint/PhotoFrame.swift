//
//  PhotoFrame.swift
//  Blagaprint
//
//  Created by Иван Магда on 24.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import UIKit

enum PhotoFrameType: String {
    case SH_3
    case SH_19
    case SH_38
}

class PhotoFrame: NSObject {
    // MARK: - Properties
    
    var type: PhotoFrameType
    var pickedImageSize: CGSize
    var image: UIImage?
    
    // MARK: - Init
    
    init(type: PhotoFrameType, imageSize: CGSize, image: UIImage?) {
        self.type = type
        self.pickedImageSize = imageSize
        self.image = image
        
        super.init()
    }
    
    // MARK: - Seed
    
    class func seedInitialFrames() -> [PhotoFrame] {
        var frames = [PhotoFrame]()
        
        frames.append(PhotoFrame(type: .SH_3, imageSize: CGSizeMake(402.0, 286.0), image: nil))
        frames.append(PhotoFrame(type: .SH_19, imageSize: CGSizeMake(400.0, 400.0), image: nil))
        frames.append(PhotoFrame(type: .SH_38, imageSize: CGSizeMake(282.0, 200.0), image: nil))
        
        return frames
    }
}
