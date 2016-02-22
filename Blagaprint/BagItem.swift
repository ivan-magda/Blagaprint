//
//  BagItem.swift
//  Blagaprint
//
//  Created by Иван Магда on 02.01.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation
import CoreImage
import Parse

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
        case itemSize
        case numberOfItems
        case amount
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
    @NSManaged var itemSize: String
    @NSManaged var numberOfItems: Int
    @NSManaged var amount: Double
    
    override var description: String {
        return "UserID: \(userId), categoryID: \(category), categoryItemID: \(categoryItem), numberOfItems: \(numberOfItems), price: \(price), device: \(device), text: \(text), itemSize: \(itemSize)"
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
    
    /// Class name of the Bag object.
    class func parseClassName() -> String {
        return "BagItem"
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
