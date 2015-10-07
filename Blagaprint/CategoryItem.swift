//
//  CategoryItem.swift
//  Blagaprint
//
//  Created by Ivan Magda on 06.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class CategoryItem: NSObject, NSCoding {
    // MARK: - Types
    
    private enum CoderKeys: String {
        case nameKey
        case imageKey
        case parentCategoryKey
    }
    
    // MARK: - Properties
    
    var name: String
    var image: UIImage?
    weak var parentCategory: Category?

    // MARK: - Initializers
    
    init(name: String) {
        self.name = name
    }
    
    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
    }
    
    init(name: String, image: UIImage, parentCategory: Category) {
        self.name = name
        self.image = image
        self.parentCategory = parentCategory
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey(CoderKeys.nameKey.rawValue) as! String
        image = aDecoder.decodeObjectForKey(CoderKeys.imageKey.rawValue) as? UIImage
        parentCategory = aDecoder.decodeObjectForKey(CoderKeys.parentCategoryKey.rawValue) as? Category
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: CoderKeys.nameKey.rawValue)
        aCoder.encodeObject(image, forKey: CoderKeys.imageKey.rawValue)
        aCoder.encodeObject(parentCategory, forKey: CoderKeys.parentCategoryKey.rawValue)
    }
}
