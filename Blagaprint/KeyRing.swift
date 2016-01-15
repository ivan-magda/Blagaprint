//
//  KeyRing.swift
//  Blagaprint
//
//  Created by Иван Магда on 15.01.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation
import UIKit

class KeyRing: NSObject {
    
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    /// Type of the key ring.
    enum KeyRingType: String {
        case Circle
        case Heart
        case HeartWithWings
    }
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    /// Type of the key ring.
    var type: KeyRingType
    
    /// Size for picked image.
    var pickedImageSize: CGSize
    
    /// Key ring image.
    var image: UIImage
    
    //--------------------------------------
    // MARK: - Init
    //--------------------------------------
    
    init(type: KeyRingType, imageSize: CGSize, image: UIImage) {
        self.type = type
        self.pickedImageSize = imageSize
        self.image = image
        
        super.init()
    }
    
    //--------------------------------------
    // MARK: - Images
    //--------------------------------------
    
    /// Returns default generated image of the key ring.
    func imageOfKeyRing() -> UIImage {
        switch self.type {
        case .Circle:
            return CircleKeyRing.imageOfKeyRing()
        case .Heart:
            return HeartKeyRing.imageOfKeyRing()
        case .HeartWithWings:
            return HeartWithWingsKeyRing.imageOfKeyRing()
        }
    }
    
    /// Returns generated image of the key ring with picked image by the user.
    func imageOfKeyRingWithPickedImage(image: UIImage) -> UIImage {
        let resizedImage = UIImage.resizedImage(image, newSize: self.pickedImageSize)
        
        switch self.type {
        case .Circle:
            return CircleKeyRing.imageOfKeyRing(image: resizedImage, imageVisible: true)
        case .Heart:
            return HeartKeyRing.imageOfKeyRing(image: resizedImage, imageVisible: true)
        case .HeartWithWings:
            return HeartWithWingsKeyRing.imageOfKeyRing(image: resizedImage, imageVisible: true)
        }
    }
    
    //--------------------------------------
    // MARK: - Seed
    //--------------------------------------
    
    class func seedInitialKeyRings() -> [KeyRing] {
        var keyRings = [KeyRing]()
        
        keyRings.append(KeyRing(type: .Circle, imageSize: CGSizeMake(240.0, 240.0), image: CircleKeyRing.imageOfKeyRing()))
        keyRings.append(KeyRing(type: .Heart, imageSize: CGSizeMake(250.0, 250.0), image: HeartKeyRing.imageOfKeyRing()))
        keyRings.append(KeyRing(type: .HeartWithWings, imageSize: CGSizeMake(314.0, 214.0), image: HeartWithWingsKeyRing.imageOfKeyRing()))
        
        return keyRings
    }
}
