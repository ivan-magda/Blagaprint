//
//  Category.swift
//  Blagaprint
//
//  Created by Ivan Magda on 02.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import UIKit

class Category: NSObject, NSCoding {
    // MARK: - Types
    
    private enum CoderKeys: String {
        case nameKey
        case imageKey
        case categoryItemsKey
    }
    
    // MARK: - Properties
    
    var name: String
    var image: UIImage
    var categoryItems = Set<CategoryItem>()
    
    // MARK: - Initializers
    
    init(name: String, image: UIImage, categoryItems:Set<CategoryItem> = Set<CategoryItem>()) {
        self.name = name
        self.image = image
        self.categoryItems = categoryItems
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey(CoderKeys.nameKey.rawValue) as! String
        image = aDecoder.decodeObjectForKey(CoderKeys.imageKey.rawValue) as! UIImage
        categoryItems = aDecoder.decodeObjectForKey(CoderKeys.categoryItemsKey.rawValue) as! Set<CategoryItem>
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: CoderKeys.nameKey.rawValue)
        aCoder.encodeObject(image, forKey: CoderKeys.imageKey.rawValue)
        aCoder.encodeObject(categoryItems, forKey: CoderKeys.categoryItemsKey.rawValue)
    }
    
    // MARK: - Public
    
    static func seedInitialData() -> [Category] {
        let categories: [Category] = [
            Category(name: "Чехлы",                image: UIImage(named:"cases.jpg")!),
            Category(name: "Кружки",               image: UIImage(named: "cups.jpg")!),
            Category(name: "Тарелки",              image: UIImage(named: "plates.jpg")!),
            Category(name: "Фоторамки",            image: UIImage(named: "frames.jpg")!),
            Category(name: "Кристаллы",            image: UIImage(named: "crystals.jpg")!),
            Category(name: "Именные брелки",       image: UIImage(named: "key_rings_by_3D_printer.jpg")!),
            Category(name: "Брелки с фото",        image: UIImage(named: "key_ring_with_photo.jpg")!),
            Category(name: "Одежда",               image: UIImage(named: "clothes.jpg")!),
            Category(name: "Копировальные услуги", image: UIImage(named: "copy_services.jpg")!),
            Category(name: "3D печать",            image: UIImage(named: "3D_printing.jpg")!),
            Category(name: "Деревянные чехлы",     image: UIImage(named: "wood_cases.jpg")!)]
        
        return categories
    }
}
