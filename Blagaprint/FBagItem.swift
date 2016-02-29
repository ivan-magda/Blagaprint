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
    
    enum Key: String {
        case UserId = "userId"
        case Category = "category"
        case CategoryItem = "categoryItem"
        case Image = "image"
        case Thumbnail = "thumbnail"
        case Price = "price"
        case Device = "device"
        case Text = "text"
        case FillColor = "fillColor"
        case TextColor = "textColor"
        case CreatedAt = "createdAt"
        case ItemSize = "itemSize"
        case NumberOfItems = "numberOfItems"
        case Amount = "amount"
        case ImageLocation = "imageLocation"
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
    var imageLocation: Int?
    
    var device: String?
    var text: String?
    var fillColor: String?
    var textColor: String?
    var itemSize: String?
    
    var numberOfItems: Int!
    var price: Double!
    var amount: Double!
    
    var value: Dictionary<String, AnyObject> {
        var dictionary = [String : AnyObject]()
        
        dictionary[Key.UserId.rawValue] = userId
        dictionary[Key.Category.rawValue] = category
        dictionary[Key.CategoryItem.rawValue] = categoryItem
        dictionary[Key.CreatedAt.rawValue] = createdAt
        dictionary[Key.Image.rawValue] = image
        dictionary[Key.Thumbnail.rawValue] = thumbnail
        dictionary[Key.ImageLocation.rawValue] = imageLocation
        dictionary[Key.Device.rawValue] = device
        dictionary[Key.Text.rawValue] = text
        dictionary[Key.FillColor.rawValue] = fillColor
        dictionary[Key.TextColor.rawValue] = textColor
        dictionary[Key.ItemSize.rawValue] = itemSize
        dictionary[Key.NumberOfItems.rawValue] = numberOfItems
        dictionary[Key.Price.rawValue] = price
        dictionary[Key.Amount.rawValue] = amount
        
        return dictionary
    }
    
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
            if let type = Key(rawValue: key) {
                switch type {
                case .UserId:
                    userId = value as! String
                case .Category:
                    category = value as! String
                case .CategoryItem:
                    categoryItem = value as? String
                case .Image:
                    if let base64ImageString = value as? String {
                        image = base64ImageString.decodedImageFromBase64String()
                    }
                case .Thumbnail:
                    if let base64ThumbString = value as? String {
                        thumbnail = base64ThumbString.decodedImageFromBase64String()
                    }
                case .Price:
                    price = value as! Double
                case .Device:
                    device = value as? String
                case .Text:
                    text = value as? String
                case .FillColor:
                    fillColor = value as? String
                case .TextColor:
                    textColor = value as? String
                case .ItemSize:
                    itemSize = value as? String
                case .NumberOfItems:
                    numberOfItems = value as! Int
                case .Amount:
                    amount = value as! Double
                case .CreatedAt:
                    if let dateString = value as? String {
                        if let date = dateString.getDateValue() {
                            createdAt = date
                        }
                    }
                case .ImageLocation:
                    imageLocation = value as? Int
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
