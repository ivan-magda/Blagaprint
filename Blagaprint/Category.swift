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
    
    private enum CoderKeys: String {
        case nameKey
        case imageKey
        case categoryItemsKey
    }
    
    // MARK: - Properties
    
    var name: String
    var image: UIImage
    var categoryItems: [CategoryItem] = []
    var categoryType: CategoryTypes = .undefined
    
    // MARK: - Initializers
    
    init(name: String, image: UIImage, categoryItems: [CategoryItem] = [], categoryType: CategoryTypes = .undefined) {
        self.name = name
        self.image = image
        self.categoryItems = categoryItems
        self.categoryType = categoryType
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey(CoderKeys.nameKey.rawValue) as! String
        image = aDecoder.decodeObjectForKey(CoderKeys.imageKey.rawValue) as! UIImage
        categoryItems = aDecoder.decodeObjectForKey(CoderKeys.categoryItemsKey.rawValue) as! [CategoryItem]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: CoderKeys.nameKey.rawValue)
        aCoder.encodeObject(image, forKey: CoderKeys.imageKey.rawValue)
        aCoder.encodeObject(categoryItems, forKey: CoderKeys.categoryItemsKey.rawValue)
    }
    
    // MARK: - Public
    
    static func seedInitialData() -> [Category] {
        var categories = [Category]()
        
        let cases = Category(name: "Чехлы", image: UIImage(named:"cases.jpg")!, categoryType: .cases)
        cases.categoryItems = [CategoryItem(name: "Именные", image: UIImage(named: "case_with_name.jpg")!, parentCategory: cases), CategoryItem(name: "С фотографией", image: UIImage(named: "case_with_photo.jpg")!, parentCategory: cases), CategoryItem(name: "С индивидуальным дизайном", image: UIImage(named: "case_individual.jpg")!, parentCategory: cases)]
        categories.append(cases)
        
        let cups = Category(name: "Кружки", image: UIImage(named: "cups.jpg")!, categoryType: .cups)
        cups.categoryItems = [CategoryItem(name: "Хамелеон", image: UIImage(named: "cup_chameleon.jpg")!, parentCategory: cups), CategoryItem(name: "Керамика", image: UIImage(named: "cup_ceramic.jpg")!, parentCategory: cups), CategoryItem(name: "Парные кружки для влюбленных", image: UIImage(named: "cup_love_is.jpg")!, parentCategory: cups)]
        categories.append(cups)
        
        let plates = Category(name: "Тарелки", image: UIImage(named: "plates.jpg")!, categoryType: .plates)
        categories.append(plates)
        
        let frames = Category(name: "Фоторамки", image: UIImage(named: "frames.jpg")!, categoryType: .frames)
        categories.append(frames)
        
        let crystals = Category(name: "Кристаллы", image: UIImage(named: "crystals.jpg")!, categoryType: .crystals)
        categories.append(crystals)
        
        let keyRingsBy3DPrinter = Category(name: "Именные брелки", image: UIImage(named: "key_rings_by_3D_printer.jpg")!, categoryType: .keyRingsBy3DPrinter)
        categories.append(keyRingsBy3DPrinter)
        
        let keyRingsWithPhoto = Category(name: "Брелки с фото", image: UIImage(named: "key_ring_with_photo.jpg")!, categoryType: .keyRingsWithPhoto)
        keyRingsWithPhoto.categoryItems = [CategoryItem(name: "Стеклянные", image: UIImage(named: "key_ring_with_photo_glass.jpg")!, parentCategory: keyRingsWithPhoto), CategoryItem(name: "Пластиковые", image: UIImage(named: "key_ring_with_photo_plastic.jpg")!, parentCategory: keyRingsWithPhoto), CategoryItem(name: "С гос номером", image: UIImage(named: "key_ring_with_number.jpg")!, parentCategory: keyRingsWithPhoto)]
        categories.append(keyRingsWithPhoto)
        
        let clothes = Category(name: "Одежда", image: UIImage(named: "clothes.jpg")!, categoryType: .clothes)
        clothes.categoryItems = [CategoryItem(name: "Мужская", image: UIImage(named: "clothes_man.jpg")!, parentCategory: clothes), CategoryItem(name: "Женская", image: UIImage(named: "clothes_wimen.jpg")!, parentCategory: clothes), CategoryItem(name: "Детская", image: UIImage(named: "clothes_kids.jpg")!, parentCategory: clothes)]
        categories.append(clothes)
        
        let copyServices = Category(name: "Копировальные услуги", image: UIImage(named: "copy_services.jpg")!, categoryType: .copyServices)
        copyServices.categoryItems = [CategoryItem(name: "Печать фотографий", image: UIImage(named: "copy_services_photo.jpg")!, parentCategory: copyServices), CategoryItem(name: "Банерная печать", image: UIImage(named: "copy_services_baner.jpg")!, parentCategory: copyServices), CategoryItem(name: "Визитки", image: UIImage(named: "copy_services_business_card.jpg")!, parentCategory: copyServices)]
        categories.append(copyServices)
        
        let printingBy3Dprint = Category(name: "3D печать", image: UIImage(named: "3D_printing.jpg")!, categoryType: .printingBy3Dprint)
        printingBy3Dprint.categoryItems = [CategoryItem(name: "Разработка индивидуального дизайна", image: UIImage(named: "3d_printing_individual.jpg")!, parentCategory: printingBy3Dprint), CategoryItem(name: "Из пластика", image: UIImage(named: "3d_printing_plastic.jpg")!, parentCategory: printingBy3Dprint), CategoryItem(name: "Из резины", image: UIImage(), parentCategory: printingBy3Dprint), CategoryItem(name: "Из твердого пластика", image: UIImage(named: "3d_printing_strong_plastic.jpg")!, parentCategory: printingBy3Dprint)]
        categories.append(printingBy3Dprint)
        
        categories.append(Category(name: "Деревянные чехлы", image: UIImage(named: "wood_cases.jpg")!, categoryType: .woodCases))
        
        return categories
    }
}
