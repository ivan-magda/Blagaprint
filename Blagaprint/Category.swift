//
//  Category.swift
//  Blagaprint
//
//  Created by Ivan Magda on 02.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation

/// The Parse Category object class name.
let CategoryParseClassName = "Category"

class Category: PFObject, PFSubclassing {
    // MARK: - Types
    
    enum CategoryTypes: String {
        case cases
        case cups
        case plates
        case frames
        case crystals
        case keyRingsBy3DPrinter
        case keyRingsWithPhoto
        case clothes
        case copyServices
        case printingBy3Dprint
        case woodCases
        case undefined
    }
    
    enum CoderKeys: String {
        case name
        case image
        case type
    }
    
    // MARK: - Properties
    
    @NSManaged var name: String
    @NSManaged var image: PFFile
    @NSManaged var type: String
    
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
        return CategoryParseClassName
    }
    
    // MARK: - Helper Methods
    
    /// Return a string that describes the contents.
    override var description: String {
        return "Name: \(name)\nType: \(type)."
    }
    
    func getType() -> CategoryTypes {
        let type = CategoryTypes(rawValue: self.type)
        return (type == nil ? .undefined : type!)
    }
}
