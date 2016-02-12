//
//  CopyServices.swift
//  Blagaprint
//
//  Created by Иван Магда on 12.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation
import UIKit

class CopyServices: NSObject {
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    /// Type of the service.
    enum CopyServicesType: String {
        case BusinessCard
        case Banner
        case Photo
    }
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    /// Type of the photo frame.
    var type: CopyServicesType
    
    /// Type of the key ring category item.
    var categoryItemType: CategoryItem.CategoryItemType
    
    /// Size for picked image.
    var pickedImageSize: CGSize
    
    /// Frame image.
    var image: UIImage
    
    //--------------------------------------
    // MARK: - Init
    //--------------------------------------
    
    init(type: CopyServicesType, categoryItemType: CategoryItem.CategoryItemType, imageSize: CGSize = .zero, image: UIImage = UIImage()) {
        self.type = type
        self.categoryItemType = categoryItemType
        self.pickedImageSize = imageSize
        self.image = image
        
        super.init()
    }
    
    //--------------------------------------
    // MARK: - Image Generating
    //--------------------------------------
    
    /// Return only frame image, without picked image.
    func generatedImage() -> UIImage {
        switch self.type {
        case .BusinessCard:
            return BusinessCard.imageOfBusinessCardCanvas()
        default:
            return UIImage()
        }
    }
    
    /// Return frame image with picked image.
    func imageWithPickedImage(image: UIImage) -> UIImage {
        let scaledImage = image.scaledImageToSize(pickedImageSize)
        
        switch self.type {
        case .BusinessCard:
            return BusinessCard.imageOfBusinessCardCanvas(image: scaledImage, imageVisible: true)
        default:
            return UIImage()
        }
    }
    
    //--------------------------------------
    // MARK: - Getting CopyServices
    //--------------------------------------
    
    class func seedInitialServices() -> [CopyServices] {
        var images = [CopyServices]()
        
        images.append(CopyServices(type: .BusinessCard, categoryItemType: CategoryItem.CategoryItemType.businessCardPrinting, imageSize: CGSize(width: 300.0, height: 160.0), image: BusinessCard.imageOfBusinessCardCanvas()))
        
        return images
    }
    
    /// Returns key rings with the same category item type.
    class func copyServiceFromCategoryItem(item: CategoryItem) -> [CopyServices] {
        return seedInitialServices().filter() { $0.categoryItemType.rawValue == item.type }
    }
}
