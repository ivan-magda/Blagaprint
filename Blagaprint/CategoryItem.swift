//
//  CategoryItem.swift
//  Blagaprint
//
//  Created by Ivan Magda on 06.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class CategoryItem: PFObject, PFSubclassing {
    
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    enum CategoryItemType: String {
        // Copy services.
        case businessCardPrinting
        case bannerPrinting
        case photoPrinting
        
        // Key rings.
        case stateNumberKeyRing
        case plasticKeyRing
        case glassKeyRing
        
        // Cups.
        case pairedCup
        case ceramicCup
        case chameleonCup
        
        // Clothes.
        case male
        case female
        case child
        
        // Default.
        case undefined
    }
    
    enum FieldKey: String {
        case name
        case type
        case image
        case sizes
        case parentCategory
    }
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    /// Name of the categoryItem.
    @NSManaged var name: String
    
    /// Image file of the categoryItem.
    @NSManaged var image: PFFile
    
    /// Pointer to the parent category.
    @NSManaged var parentCategory: PFObject
    
    /// Type of the categoryItem.
    /// Use CategoryItemType(rawValue:) for creating type from string.
    @NSManaged var type: String
    
    /// Array of item sizes.
    @NSManaged var sizes: [String]
    
    override var description: String {
        return "Name: \(name)\nCategory: \(parentCategory)"
    }
    
    //--------------------------------------
    // MARK: - PFSubclassing
    //--------------------------------------
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    /// Class name of the CategoryItem object.
    class func parseClassName() -> String {
        return "CategoryItem"
    }
    
    //--------------------------------------
    // MARK: - CategoryItemType
    //--------------------------------------
    
    func getType() -> CategoryItemType {
        let type = CategoryItemType(rawValue: self.type)
        return (type == nil ? .undefined : type!)
    }
}
