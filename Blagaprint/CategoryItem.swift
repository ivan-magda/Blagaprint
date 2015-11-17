//
//  CategoryItem.swift
//  Blagaprint
//
//  Created by Ivan Magda on 06.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit
import CloudKit

/// The type of CategoryItem record, app supported record type.
let CategoryItemRecordType = "CategoryItem"

class CategoryItem: NSObject, NSCoding, SortByNameProtocol {
    // MARK: - Types
    
    private enum CoderKeys: String {
        case nameKey
        case recordNameKey
        case recordChangeTagKey
        case imageKey
        case imageUrlKey
        case parentCategoryKey
    }
    
    // MARK: - Properties
    
    var name: String
    var recordName: String
    var recordChangeTag: String
    var image: UIImage?
    var imageUrl: NSURL?
    weak var parentCategory: Category?
    
    override var description: String {
        return "Name: \(name)\nImageUrl: \(imageUrl)"
    }

    // MARK: - Initializers
    
    init(record: CKRecord) {
        self.name = record[CloudKitFieldNames.Name.rawValue] as! String
        self.recordName = record.recordID.recordName
        self.recordChangeTag = record.recordChangeTag ?? ""
        
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
    
    init(categoryItemData: CategoryItemData) {
        self.name = categoryItemData.name!
        self.recordName = categoryItemData.recordName!
        self.recordChangeTag = categoryItemData.recordChangeTag!
        
        if let url = categoryItemData.imageUrl as? NSURL {
            self.imageUrl = url
        }
        
        if let imageData = categoryItemData.image {
            self.image = UIImage(data: imageData)
        }
        
        super.init()
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey(CoderKeys.nameKey.rawValue) as! String
        recordName = aDecoder.decodeObjectForKey(CoderKeys.recordNameKey.rawValue) as! String
        recordChangeTag = aDecoder.decodeObjectForKey(CoderKeys.recordChangeTagKey.rawValue) as! String
        image = aDecoder.decodeObjectForKey(CoderKeys.imageKey.rawValue) as? UIImage
        imageUrl = aDecoder.decodeObjectForKey(CoderKeys.imageUrlKey.rawValue) as? NSURL
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: CoderKeys.nameKey.rawValue)
        aCoder.encodeObject(recordName, forKey: CoderKeys.recordNameKey.rawValue)
        aCoder.encodeObject(recordChangeTag, forKey: CoderKeys.recordChangeTagKey.rawValue)
        aCoder.encodeObject(image, forKey: CoderKeys.imageKey.rawValue)
        aCoder.encodeObject(imageUrl, forKey: CoderKeys.imageUrlKey.rawValue)
    }
}
