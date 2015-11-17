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
        case recordChangeTag
        case categoryItemsKey
        case categoryTypeKey
    }
    
    // MARK: - Properties
    
    var name: String
    var image: UIImage?
    var imageUrl: NSURL?
    var recordName: String
    var recordChangeTag: String
    var categoryItems: [CategoryItem] = []
    var categoryType: CategoryTypes = .undefined
    
    override var description: String {
        return "Name: \(name)\nRecordName: \(recordName)\nCategoryItemsCount: \(categoryItems.count)\nCategoryType: \(categoryType.rawValue)."
    }
    
    // MARK: - Initializers
    
    init(record: CKRecord) {
        self.name = record[CloudKitFieldNames.Name.rawValue] as! String
        self.recordName = record.recordID.recordName
        self.recordChangeTag = record.recordChangeTag ?? ""
        
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
            queue.addOperationWithBlock() {
                let imageData = NSData(contentsOfURL: url)
                self.image = UIImage(data: imageData!)!
            }
        }
    }
    
    init(categoryData: CategoryData) {
        self.name = categoryData.name!
        self.recordName = categoryData.recordName!
        self.recordChangeTag = categoryData.recordChangeTag!
        
        if let url = categoryData.imageUrl as? NSURL {
            self.imageUrl = url
        }
        
        if let imageData = categoryData.image {
            self.image = UIImage(data: imageData)
        }
        
        let typeString = categoryData.type!
        if let type = Category.categoryTypeFromString(typeString) {
            self.categoryType = type
        } else {
            self.categoryType = .undefined
        }
        
        super.init()
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
        recordName = aDecoder.decodeObjectForKey(CoderKeys.recordNameKey.rawValue) as! String
        recordChangeTag = aDecoder.decodeObjectForKey(CoderKeys.recordChangeTag.rawValue) as! String
        categoryItems = aDecoder.decodeObjectForKey(CoderKeys.categoryItemsKey.rawValue) as! [CategoryItem]
        categoryType = CategoryTypes(rawValue: aDecoder.decodeObjectForKey(CoderKeys.categoryTypeKey.rawValue) as! String)!
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: CoderKeys.nameKey.rawValue)
        aCoder.encodeObject(image, forKey: CoderKeys.imageKey.rawValue)
        aCoder.encodeObject(imageUrl, forKey: CoderKeys.imageUrlKey.rawValue)
        aCoder.encodeObject(recordName, forKey: CoderKeys.recordNameKey.rawValue)
        aCoder.encodeObject(recordChangeTag, forKey: CoderKeys.recordChangeTag.rawValue)
        aCoder.encodeObject(categoryItems, forKey: CoderKeys.categoryItemsKey.rawValue)
        aCoder.encodeObject(categoryType.rawValue, forKey: CoderKeys.categoryTypeKey.rawValue)
    }
}
