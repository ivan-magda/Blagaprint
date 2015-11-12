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
        case recordKey
        case imageKey
        case imageUrlKey
        case parentCategoryKey
    }
    
    // MARK: - Properties
    
    var name: String
    var record: CKRecord = CKRecord(recordType: CategoryItemRecordType)
    var image: UIImage?
    var imageUrl: NSURL?
    weak var parentCategory: Category?
    
    override var description: String {
        return "Name: \(name)\nImageUrl: \(imageUrl)"
    }

    // MARK: - Initializers
    
    init(name: String) {
        self.name = name
        
        super.init()
    }
    
    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
        
        super.init()
    }
    
    init(name: String, parentCategory: Category) {
        self.name = name
        
        super.init()
    }
    
    init(name: String, image: UIImage, parentCategory: Category) {
        self.name = name
        self.image = image
        
        super.init()
    }
    
    init(record: CKRecord) {
        self.name = record[CloudKitFieldNames.Name.rawValue] as! String
        self.record = record
        
        super.init()
        
        let image = record[CloudKitFieldNames.Image.rawValue] as? CKAsset
        if let ckAsset = image {
            let url = ckAsset.fileURL
            self.imageUrl = url
            let queue = NSOperationQueue()
            queue.addOperationWithBlock({
                let imageData = NSData(contentsOfURL: url)
                self.image = UIImage(data: imageData!)!
            })
        }
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey(CoderKeys.nameKey.rawValue) as! String
        record = aDecoder.decodeObjectForKey(CoderKeys.recordKey.rawValue) as! CKRecord
        image = aDecoder.decodeObjectForKey(CoderKeys.imageKey.rawValue) as? UIImage
        imageUrl = aDecoder.decodeObjectForKey(CoderKeys.imageUrlKey.rawValue) as? NSURL
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: CoderKeys.nameKey.rawValue)
        aCoder.encodeObject(record, forKey: CoderKeys.recordKey.rawValue)
        aCoder.encodeObject(image, forKey: CoderKeys.imageKey.rawValue)
        aCoder.encodeObject(imageUrl, forKey: CoderKeys.imageUrlKey.rawValue)
    }
}
