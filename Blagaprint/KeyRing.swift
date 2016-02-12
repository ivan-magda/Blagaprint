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
        // Plastic.
        case Circle
        case Square
        case Rectangle
        case Heart
        case HeartWithWings
        
        // Glass.
        case GlassRectangle
        case GlassOval
        
        // State number.
        case StateNumber
    }
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    /// Type of the key ring it self.
    var type: KeyRingType
    
    /// Type of the key ring category item.
    var categoryItemType: CategoryItem.CategoryItemType
    
    /// Size for picked image.
    var pickedImageSize: CGSize
    
    /// Key ring image.
    var image: UIImage
    
    // MARK: State Number
    
    var numbers = "000"
    var firstLetter = "М"
    var lastLetters = "ММ"
    var region = "28"
    
    //--------------------------------------
    // MARK: - Init
    //--------------------------------------
    
    init(selfType type: KeyRingType, categoryItemType: CategoryItem.CategoryItemType, imageSize: CGSize = CGSizeZero, image: UIImage = UIImage()) {
        self.type = type
        self.categoryItemType = categoryItemType
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
        case .Square:
            return SquareKeyRing.imageOfKeyRing()
        case .Rectangle:
            return RectangleKeyRing.imageOfKeyRing()
        case .GlassRectangle:
            return GlassRectangleKeyRing.imageOfKeyRing()
        case .GlassOval:
            return GlassOvalKeyRing.imageOfKeyRing()
        case .Heart:
            return HeartKeyRing.imageOfKeyRing()
        case .HeartWithWings:
            return HeartWithWingsKeyRing.imageOfKeyRing()
        case .StateNumber:
            return StateNumberKeyRing.imageOfKeyRing()
        }
    }
    
    /// Returns generated image of the key ring with picked image by the user.
    func imageOfKeyRingWithPickedImage(image: UIImage) -> UIImage {
        let scaledImage = image.scaledImageToSize(pickedImageSize)
        
        switch self.type {
        case .Circle:
            return CircleKeyRing.imageOfKeyRing(image: scaledImage, imageVisible: true)
        case .Square:
            return SquareKeyRing.imageOfKeyRing(image: scaledImage, imageVisible: true)
        case .Rectangle:
            return RectangleKeyRing.imageOfKeyRing(image: scaledImage, imageVisible: true)
        case .GlassRectangle:
            return GlassRectangleKeyRing.imageOfKeyRing(image: scaledImage, imageVisible: true)
        case .GlassOval:
            return GlassOvalKeyRing.imageOfKeyRing(image: scaledImage, imageVisible: true)
        case .Heart:
            return HeartKeyRing.imageOfKeyRing(image: scaledImage, imageVisible: true)
        case .HeartWithWings:
            return HeartWithWingsKeyRing.imageOfKeyRing(image: scaledImage, imageVisible: true)
        case .StateNumber:
            break
        }
        
        return UIImage()
    }
    
    /// Returns an image of state number key ring.
    func stateNumberImage(characters characters: String?, numbers: String?, region: String?) -> UIImage {
        var charactersArray = [String]()
        
        if characters == nil {
            charactersArray.append(firstLetter)
            
            for char in Array(lastLetters.characters) {
                charactersArray.append(String(char))
            }
        } else {
            for char in Array(characters!.characters) {
                charactersArray.append(String(char))
            }
        }
        
        let firstCharacter = charactersArray[0]
        let lastCharacters = "\(charactersArray[1])\(charactersArray[2])"
        
        let numbers = numbers == nil ? self.numbers : numbers!
        let region = region == nil ? self.region : region!
        
        return StateNumberKeyRing.imageOfKeyRing(numbers: numbers, firstLetter: firstCharacter, lastLetters: lastCharacters, region: region)
    }
    
    //--------------------------------------
    // MARK: - Getting Key Rings
    //--------------------------------------
    
    /// Returns all available key rings.
    class func seedInitialKeyRings() -> [KeyRing] {
        var keyRings = [KeyRing]()
        
        // Plastic.
        keyRings.append(KeyRing(selfType: .Circle, categoryItemType: .plasticKeyRing, imageSize: CGSizeMake(240.0, 240.0), image: CircleKeyRing.imageOfKeyRing()))
        keyRings.append(KeyRing(selfType: .Square, categoryItemType: .plasticKeyRing, imageSize: CGSizeMake(240.0, 240.0), image: SquareKeyRing.imageOfKeyRing()))
        keyRings.append(KeyRing(selfType: .Rectangle, categoryItemType: .plasticKeyRing, imageSize: CGSizeMake(170.0, 225.0), image: RectangleKeyRing.imageOfKeyRing()))
        keyRings.append(KeyRing(selfType: .Heart, categoryItemType: .plasticKeyRing, imageSize: CGSizeMake(250.0, 250.0), image: HeartKeyRing.imageOfKeyRing()))
        keyRings.append(KeyRing(selfType: .HeartWithWings, categoryItemType: .plasticKeyRing, imageSize: CGSizeMake(314.0, 214.0), image: HeartWithWingsKeyRing.imageOfKeyRing()))
        
        // Glass.
        keyRings.append(KeyRing(selfType: .GlassRectangle, categoryItemType: .glassKeyRing, imageSize: CGSizeMake(124.0, 176.0), image: GlassRectangleKeyRing.imageOfKeyRing()))
        keyRings.append(KeyRing(selfType: .GlassOval, categoryItemType: .glassKeyRing, imageSize: CGSizeMake(120.0, 186.0), image: GlassOvalKeyRing.imageOfKeyRing()))
        
        // State number.
        let stateKeyRing = KeyRing(selfType: .StateNumber, categoryItemType: .stateNumberKeyRing)
        stateKeyRing.image = stateKeyRing.stateNumberImage(characters: nil, numbers: nil, region: nil)
        
        keyRings.append(stateKeyRing)
        
        return keyRings
    }
    
    /// Returns key rings with the same category item type.
    class func keyRingsFromCategoryItem(item: CategoryItem) -> [KeyRing] {
        return seedInitialKeyRings().filter() { $0.categoryItemType.rawValue == item.type }
    }
}
