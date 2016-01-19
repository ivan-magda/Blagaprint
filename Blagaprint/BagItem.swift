//
//  BagItem.swift
//  Blagaprint
//
//  Created by Иван Магда on 02.01.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation
import CoreImage

/// Class name of the Bag object.
let BagItemClassName = "BagItem"

class BagItem: PFObject, PFSubclassing {
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    enum FieldKey: String {
        case userId
        case category
        case categoryItem
        case image
        case thumbnail
        case price
        case device
        case text
        case fillColor
        case textColor
        case createdAt
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
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @NSManaged var userId: String
    @NSManaged var category: String
    @NSManaged var categoryItem: String
    @NSManaged var image: PFFile
    @NSManaged var thumbnail: PFFile
    @NSManaged var price: Double
    @NSManaged var device: String
    @NSManaged var text: String
    @NSManaged var fillColor: String
    @NSManaged var textColor: String
    
    /// The class name of the object.
    class func parseClassName() -> String {
        return BagItemClassName
    }
    
    //--------------------------------------
    // MARK: - Colors
    //--------------------------------------
    
    /// Returns a formatted string that specifies the components of the color.
    class func colorToString(color: UIColor) -> String {
        let colorString = CIColor(CGColor: color.CGColor).stringRepresentation
        
        return colorString
    }
    
    /// Creates a color object using the RGBA color component values specified by a string.
    class func colorFromString(string: String) -> UIColor {
        let coreColor = CIColor(string: string)
        let color = UIColor(CIColor: coreColor)
        
        return color
    }
    
}
