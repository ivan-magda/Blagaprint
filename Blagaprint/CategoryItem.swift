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
        case imageKey
        case imageUrlKey
        case parentCategoryKey
    }
    
    // MARK: - Properties
    
    var name: String
    var image: UIImage?
    var imageUrl: NSURL?
    
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
        image = aDecoder.decodeObjectForKey(CoderKeys.imageKey.rawValue) as? UIImage
        imageUrl = aDecoder.decodeObjectForKey(CoderKeys.imageUrlKey.rawValue) as? NSURL
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: CoderKeys.nameKey.rawValue)
        aCoder.encodeObject(image, forKey: CoderKeys.imageKey.rawValue)
        aCoder.encodeObject(imageUrl, forKey: CoderKeys.imageUrlKey.rawValue)
    }
}
