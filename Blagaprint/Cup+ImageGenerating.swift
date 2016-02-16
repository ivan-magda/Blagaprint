//
//  Cup+ImageGenerating.swift
//  Blagaprint
//
//  Created by Иван Магда on 12.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import UIKit

extension Cup {
    
    /**
     * Returns default images of cup, without passed in image.
     *
     * @return an array of cup images.
     */
    class func getDefaultCupImages() -> [UIImage] {
        return [Cup.imageOfCupLeft(), Cup.imageOfCupFront(), Cup.imageOfCupRight()]
    }
    
    /**
     * Returns cup images with passed in image.
     *
     * @param passedInImage the image of the cup in that it will be presenting.
     *
     * @return an array of cup images.
     */
    class func getCupImagesWithPickedImage(passedInImage: UIImage) -> [UIImage] {
        let pickedImageSize = CGSize(width: 200.0, height: 225.0)
        
        var images = [UIImage]()
        
        // Picked image cropping
        let imageSize = passedInImage.size
        let fortyPercentOfWidth = imageSize.width * 0.4
        
        // Left side cup view.
        let leftSideRect = CGRect(x: 0.0, y: 0.0, width: fortyPercentOfWidth, height: imageSize.height)
        let leftCroppedImage = passedInImage.croppedImage(leftSideRect)
        let leftSideImage = leftCroppedImage.scaledImageToSize(pickedImageSize)
        images.append(Cup.imageOfCupLeft(pickedImage: leftSideImage, imageVisible: true))
        
        // Front side cup view.
        let frontSideRect = CGRect(x: leftSideRect.width - (leftSideRect.width * 0.1), y: 0.0, width: fortyPercentOfWidth, height: imageSize.height)
        let frontCroppedImage = passedInImage.croppedImage(frontSideRect)
        let frontSideImage = frontCroppedImage.scaledImageToSize(pickedImageSize)
        images.append(Cup.imageOfCupFront(pickedImage: frontSideImage, imageVisible: true))
        
        // Right side cup view.
        let rightSideRect = CGRect(x: imageSize.width * 0.6, y: 0, width: fortyPercentOfWidth, height: imageSize.height)
        let rightCroppedImage = passedInImage.croppedImage(rightSideRect)
        let rightSideImage = rightCroppedImage.scaledImageToSize(pickedImageSize)
        images.append(Cup.imageOfCupRight(pickedImage: rightSideImage, imageVisible: true))
        
        return images
    }
}
