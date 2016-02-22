//
//  FCategoryItem.swift
//  Blagaprint
//
//  Created by Иван Магда on 19.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation
import Firebase

class FCategoryItem {
    
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
    
    enum Keys: String {
        case name
        case type
        case sizes
        case parentCategory
    }
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var key: String
    
    var reference: Firebase
    
    /// Name of the categoryItem.
    var name: String!
    
    /// Pointer to the parent category.
    var parentCategory: String!
    
    /// Type of the categoryItem.
    var type: CategoryItemType!
    
    /// Array of item sizes.
    var sizes: [String]?

    //--------------------------------------
    // MARK: - Initialize -
    //--------------------------------------
    
    /// Initialize the new Category
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self.key = key
        
        // Within the CategoryItem, or Key, the following properties are children
        
        if let name = dictionary[Keys.name.rawValue] as? String {
            self.name = name
        }
        
        if let parentCategory = dictionary[Keys.parentCategory.rawValue] as? String {
            self.parentCategory = parentCategory
        }
        
        if let typeString = dictionary[Keys.type.rawValue] as? String {
            self.type = FCategoryItem.typeFromString(typeString)
        }
        
        if let sizes = dictionary[Keys.sizes.rawValue] as? [String] {
            self.sizes = sizes
        }
        
        // The above properties are assigned to their key.
        
        reference = DataService.sharedInstance.categoryItemReference.childByAppendingPath(self.key)
    }
    
    //--------------------------------------
    // MARK: - Helper Methods
    //--------------------------------------
    
    private class func typeFromString(type: String) -> CategoryItemType {
        let type = CategoryItemType(rawValue: type)
        
        return (type == nil ? .undefined : type!)
    }
}

//--------------------------------------
// MARK: - CustomStringConvertible -
//--------------------------------------

extension FCategoryItem: CustomStringConvertible {
    var description: String {
        return "Name: \(name), type: \(type.rawValue)"
    }
}