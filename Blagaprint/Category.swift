//
//  Category.swift
//  Blagaprint
//
//  Created by Ivan Magda on 02.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import UIKit
import CloudKit


/// CloudKit field names for Category and CategoryItem.
enum CloudKitFieldNames: String {
    case Name
    case Image
    case ParentCategory
    case CategoryType
}

/// The type of Category record, app supported record type.
let CategoryRecordType = "Category"

class Category: NSObject, NSCoding, SortByNameProtocol {
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
        case imageUrlKey
        case recordKey
        case recordNameKey
        case categoryItemsKey
        case categoryTypeKey
        case isCachedKey
    }
    
    // MARK: - Properties
    
    var name: String
    var image: UIImage?
    var imageUrl: NSURL?
    let record: CKRecord
    var recordName: String
    var categoryItems: [CategoryItem] = []
    var categoryType: CategoryTypes = .undefined
    var isCached: Bool
    
    override var description: String {
        return "Name: \(name)\nRecordName: \(recordName)\nCategoryItemsCount: \(categoryItems.count)\nCategoryType: \(categoryType.rawValue)\nCached: \(isCached)."
    }
    
    // MARK: - Initializers
    
    init(name: String, image: UIImage, categoryItems: [CategoryItem] = [], categoryType: CategoryTypes = .undefined) {
        self.name = name
        self.image = image
        self.categoryItems = categoryItems
        self.categoryType = categoryType
        
        self.record = CKRecord(recordType: CategoryRecordType)
        self.recordName = ""
        self.isCached = false
    }
    
    init(record: CKRecord) {
        self.name = record[CloudKitFieldNames.Name.rawValue] as! String
        self.record = record
        self.recordName = record.recordID.recordName
        self.isCached = false
        
        let categoryString = record[CloudKitFieldNames.CategoryType.rawValue] as! String
        if let type = Category.categoryTypeFromString(categoryString) {
            self.categoryType = type
        } else {
            self.categoryType = .undefined
        }
        
        super.init()
        
        let image = record[CloudKitFieldNames.Image.rawValue] as? CKAsset
        if let ckAsset = image {
            let url = ckAsset.fileURL
            self.imageUrl = url
            let queue = NSOperationQueue()
            queue.addOperationWithBlock({
                let imageData = NSData(contentsOfURL: url)
                self.image = UIImage(data: imageData!)!
                
                let data = NSKeyedArchiver.archivedDataWithRootObject(self.image!)
                print("Size \(data.length)")
            })
        }
    }
    
    // MARK: - Private
    
    private class func categoryTypeFromString(string: String) -> CategoryTypes? {
        return CategoryTypes(rawValue: string)
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey(CoderKeys.nameKey.rawValue) as! String
        image = aDecoder.decodeObjectForKey(CoderKeys.imageKey.rawValue) as? UIImage
        imageUrl = aDecoder.decodeObjectForKey(CoderKeys.imageUrlKey.rawValue) as? NSURL
        record = aDecoder.decodeObjectForKey(CoderKeys.recordKey.rawValue) as! CKRecord
        recordName = aDecoder.decodeObjectForKey(CoderKeys.recordNameKey.rawValue) as! String
        categoryItems = aDecoder.decodeObjectForKey(CoderKeys.categoryItemsKey.rawValue) as! [CategoryItem]
        categoryType = CategoryTypes(rawValue: aDecoder.decodeObjectForKey(CoderKeys.categoryTypeKey.rawValue) as! String)!
        isCached = aDecoder.decodeBoolForKey(CoderKeys.isCachedKey.rawValue)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: CoderKeys.nameKey.rawValue)
        aCoder.encodeObject(image, forKey: CoderKeys.imageKey.rawValue)
        aCoder.encodeObject(imageUrl, forKey: CoderKeys.imageUrlKey.rawValue)
        aCoder.encodeObject(record, forKey: CoderKeys.recordKey.rawValue)
        aCoder.encodeObject(recordName, forKey: CoderKeys.recordNameKey.rawValue)
        aCoder.encodeObject(categoryItems, forKey: CoderKeys.categoryItemsKey.rawValue)
        aCoder.encodeObject(categoryType.rawValue, forKey: CoderKeys.categoryTypeKey.rawValue)
        aCoder.encodeBool(isCached, forKey: CoderKeys.isCachedKey.rawValue)
    }
    
    // MARK: - Public
    
    static func seedInitialData() -> [Category] {
        var categories = [Category]()
        
        let phoneCase = Category(name: "Чехлы", image: UIImage(named:"cases.jpg")!, categoryType: .cases)
        phoneCase.categoryItems = [CategoryItem(name: "Именные", image: UIImage(named: "case_with_name.jpg")!, parentCategory: phoneCase), CategoryItem(name: "С фотографией", image: UIImage(named: "case_with_photo.jpg")!, parentCategory: phoneCase), CategoryItem(name: "С индивидуальным дизайном", image: UIImage(named: "case_individual.jpg")!, parentCategory: phoneCase)]
        categories.append(phoneCase)
        
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
