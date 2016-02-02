//
//  Category.swift
//  Blagaprint
//
//  Created by Ivan Magda on 02.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation

class Category: PFObject, PFSubclassing {
    
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    enum CategoryType: String {
        case phoneCase
        case cup
        case plate
        case photoFrame
        case photoCrystal
        case keyRing
        case clothes
        case copyServices
        case undefined
    }
    
    enum FieldKey: String {
        case name
        case titleName
        case image
        case type
    }
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    /// Name of the category.
    @NSManaged var name: String

    /// Uses for title name of any view controller.
    @NSManaged var titleName: String
    
    /// Image of the category.
    @NSManaged var image: PFFile
    
    /// Type of the category. 
    /// Use CategoryType(rawValue:) for creating type from string.
    @NSManaged var type: String
    
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
    
    /// Class name of the Category object.
    class func parseClassName() -> String {
        return "Category"
    }

    //--------------------------------------
    // MARK: - CategoryType
    //--------------------------------------
    
    func getType() -> CategoryType {
        let type = CategoryType(rawValue: self.type)
        
        return (type == nil ? .undefined : type!)
    }
    
    //--------------------------------------
    // MARK: - Helper Methods
    //--------------------------------------
    
    /// Return a string that describes the contents.
    override var description: String {
        return "Name: \(name)\nType: \(type)."
    }
    
    /// Returns items of the category.
    func getItemsInBackgroundWithBlock(block: ((objects: [CategoryItem]?, error: NSError?) -> ())? ) {
        let categoryItemsQuery = PFQuery(className: CategoryItem.parseClassName())
        
        categoryItemsQuery.cachePolicy = .CacheThenNetwork
        categoryItemsQuery.whereKey(CategoryItem.FieldKey.parentCategory.rawValue, equalTo: self)
        categoryItemsQuery.includeKey(CategoryItem.FieldKey.parentCategory.rawValue)
        categoryItemsQuery.orderByAscending(CategoryItem.FieldKey.name.rawValue)
        
        categoryItemsQuery.findObjectsInBackgroundWithBlock() { (items, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if let error = error {
                    if let completionHandler = block {
                        completionHandler(objects: nil, error: error)
                    }
                } else if let items = items as? [CategoryItem] {
                    if let completionHandler = block {
                        completionHandler(objects: items, error: error)
                    }
                } else if let completionHandler = block {
                    completionHandler(objects: nil, error: nil)
                }
            }
        }
    }
}
