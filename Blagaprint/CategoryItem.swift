//
//  CategoryItem.swift
//  Blagaprint
//
//  Created by Ivan Magda on 06.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

/// The Parse CategoryItem object class name.
let CategoryItemParseClassName = "CategoryItem"

class CategoryItem: PFObject, PFSubclassing {
    // MARK: - Types
    
    enum CoderKeys: String {
        case name
        case image
        case parentCategory
    }
    
    // MARK: - Properties
    
    @NSManaged var name: String
    @NSManaged var image: PFFile
    @NSManaged var parentCategory: PFObject
    
    override var description: String {
        return "Name: \(name)\nImageUrl: \(parentCategory)"
    }
    
    // MARK: - PFSubclassing
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    /// The class name of the object.
    class func parseClassName() -> String {
        return CategoryItemParseClassName
    }
}
