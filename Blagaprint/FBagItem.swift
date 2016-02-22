//
//  FBagItem.swift
//  Blagaprint
//
//  Created by Иван Магда on 19.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation
import CoreImage
import Firebase

class FBagItem {
    
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    enum Keys: String {
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
    
    var key: String
    
    var reference: Firebase
    
    var userId: String!
    var category: String!
    var categoryItem: String?
    var createdAt: String!
    
    var image: UIImage?
    var thumbnail: UIImage?

    var device: String?
    var text: String?
    var fillColor: String?
    var textColor: String?
    var itemSize: String?
    
    var numberOfItems: Int!
    var price: Double!
    var amount: Double!
    
    //--------------------------------------
    // MARK: - Initialize -
    //--------------------------------------
    
    /// Initialize the new Category
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self.key = key
        
        // Within the BagItem, or Key, the following properties are children
        
        for (key, value) in dictionary {
            let type = Keys(rawValue: key)!
            
            switch type {
            case .userId:
                self.userId = value as! String
            case .category:
                self.category = value as! String
            case .categoryItem:
                self.categoryItem = value as? String
            case .image:
                self.image = (value as! String).decodedImageFromBase64String()
            case .thumbnail:
                self.thumbnail = (value as! String).decodedImageFromBase64String()
            case .price:
                self.price = value as! Double
            case .device:
                self.device = value as? String
            case .text:
                self.text = value as? String
            case .fillColor:
                self.fillColor = value as? String
            case .textColor:
                self.textColor = value as? String
            case .itemSize:
                self.itemSize = value as? String
            case .numberOfItems:
                self.numberOfItems = value as! Int
            case .amount:
                self.amount = value as! Double
            case .createdAt:
                self.createdAt = value as! String
            }
        }
        
        // The above properties are assigned to their key.
        
        self.reference = DataService.sharedInstance.bagItemReference.childByAppendingPath(self.key)
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

//--------------------------------------
// MARK: - CustomStringConvertible -
//--------------------------------------

extension FBagItem: CustomStringConvertible {
    var description: String {
        return "UserID: \(userId), categoryID: \(category), categoryItemID: \(categoryItem), numberOfItems: \(numberOfItems), price: \(price), device: \(device), text: \(text), itemSize: \(itemSize)"
    }
}
