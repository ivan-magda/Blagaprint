//
//  FBagItem.swift
//  Blagaprint
//
//  Created by Иван Магда on 19.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation
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
    // MARK: - Properties -
    //--------------------------------------
    
    var key: String
    
    var reference: Firebase
    
    var userId: String!
    var category: String!
    var categoryItem: String?
    var createdAt = NSDate()
    
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
    // MARK: - Class Functions -
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
    
    //--------------------------------------
    // MARK: - Init -
    //--------------------------------------
    
    /// Initialize the new Category
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self.key = key
        
        // Within the BagItem, or Key, the following properties are children
        
        for (key, value) in dictionary {
            let type = Keys(rawValue: key)!
            
            switch type {
            case .userId:
                userId = value as! String
            case .category:
                category = value as! String
            case .categoryItem:
                categoryItem = value as? String
            case .image:
                if let base64ImageString = value as? String {
                    image = base64ImageString.decodedImageFromBase64String()
                }
            case .thumbnail:
                if let base64ThumbString = value as? String {
                    thumbnail = base64ThumbString.decodedImageFromBase64String()
                }
            case .price:
                price = value as! Double
            case .device:
                device = value as? String
            case .text:
                text = value as? String
            case .fillColor:
                fillColor = value as? String
            case .textColor:
                textColor = value as? String
            case .itemSize:
                itemSize = value as? String
            case .numberOfItems:
                numberOfItems = value as! Int
            case .amount:
                amount = value as! Double
            case .createdAt:
                if let dateString = value as? String {
                    if let date = dateString.getDateValue() {
                        createdAt = date
                    }
                }
            }
        }
        
        // The above properties are assigned to their key.
        
        reference = DataService.sharedInstance.bagItemReference.childByAppendingPath(self.key)
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
