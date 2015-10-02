//
//  Category.swift
//  Blagaprint
//
//  Created by Ivan Magda on 02.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import UIKit

class Category {
    var name: String?
    var image: UIImage?
    
    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
    }
    
    static func seedInitialData() -> [Category] {
        var categories: [Category] = []
        
        categories.append(Category(name: "Чехлы", image: UIImage(named:"cases.jpg")!))
        categories.append(Category(name: "Кружки", image: UIImage(named: "cups.jpg")!))
        categories.append(Category(name: "Тарелки", image: UIImage(named: "plates.jpg")!))
        categories.append(Category(name: "Фоторамки", image: UIImage(named: "frames.jpg")!))
        categories.append(Category(name: "Кристаллы", image: UIImage(named: "crystals.jpg")!))
        categories.append(Category(name: "Именные брелки", image: UIImage(named: "key_rings_by_3D_printer.jpg")!))
        categories.append(Category(name: "Брелки с фото", image: UIImage(named: "key_ring_with_photo.jpg")!))
        categories.append(Category(name: "Одежда", image: UIImage(named: "clothes.jpg")!))
        categories.append(Category(name: "Копировальные услуги", image: UIImage(named: "copy_services.jpg")!))
        categories.append(Category(name: "3D печать", image: UIImage(named: "3D_printing.jpg")!))
        categories.append(Category(name: "Деревянные чехлы", image: UIImage(named: "wood_cases.jpg")!))
        
        return categories
    }
}
