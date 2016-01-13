//
//  Category.swift
//  Blagaprint
//
//  Created by Ivan Magda on 02.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation

/// Class name of the Category object.
let CategoryClassName = "Category"

class Category: PFObject, PFSubclassing {
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
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
    
    enum Keys: String {
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
    /// Use CategoryTypes(rawValue:) for creating type from string.
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
    
    /// The class name of the object.
    class func parseClassName() -> String {
        return CategoryClassName
    }
    
    //--------------------------------------
    // MARK: - Helper Methods
    //--------------------------------------
    
    /// Return a string that describes the contents.
    override var description: String {
        return "Name: \(name)\nType: \(type)."
    }
    
    func getType() -> CategoryTypes {
        let type = CategoryTypes(rawValue: self.type)
        return (type == nil ? .undefined : type!)
    }
    
    /// Returns items of the category.
    func getItemsInBackgroundWithBlock(completionHandler: ((objects: [CategoryItem]?, error: NSError?) -> ())? ) {
        let categoryItemsQuery = PFQuery(className: CategoryItemClassName)
        categoryItemsQuery.cachePolicy = .CacheThenNetwork
        categoryItemsQuery.whereKey(CategoryItem.Keys.parentCategory.rawValue, equalTo: self)
        categoryItemsQuery.includeKey(CategoryItem.Keys.parentCategory.rawValue)
        
        
        categoryItemsQuery.findObjectsInBackgroundWithBlock() { (items, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if let error = error {
                    if let completionHandler = completionHandler {
                        completionHandler(objects: nil, error: error)
                    }
                } else if let items = items as? [CategoryItem] {
                    if let completionHandler = completionHandler {
                        completionHandler(objects: items, error: error)
                    }
                } else if let completionHandler = completionHandler {
                    completionHandler(objects: nil, error: nil)
                }
            }
        }
    }
}
