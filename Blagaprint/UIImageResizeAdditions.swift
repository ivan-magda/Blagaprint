//
//  UIImageResizeAdditions.swift
//  Blagaprint
//
//  Created by Иван Магда on 03.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

extension UIImage {
    class func resizedImage(image: UIImage, newSize: CGSize) -> UIImage {
        return image.resizedImage(newSize)
    }
    
    func resizedImage(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        let newImageRect = CGRectMake(0.0, 0.0, newSize.width, newSize.height)
        self.drawInRect(newImageRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /**
     * Scales an image to fit within a bounds with a size governed by
     * the passed size. Also keeps the aspect ratio.
     *
     * Switch MIN to MAX for aspect fill instead of fit.
     *
     * @param newSize the size of the bounds the image must fit within.
     * @return a new scaled image.
     */
    func scaledImageToSize(newSize: CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth = newSize.width / self.size.width
        let aspectHeight = newSize.height / self.size.height
        let aspectRation = max(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRation
        scaledImageRect.size.height = self.size.height * aspectRation
        scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.drawInRect(scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    /// Returns a copy of this image that is cropped to the given bounds.
    /// The bounds will be adjusted using CGRectIntegral.
    /// This method ignores the image's imageOrientation setting.
    func croppedImage(bounds: CGRect) -> UIImage {
        let imageRef = CGImageCreateWithImageInRect(self.CGImage, bounds)
        let croppedImage = UIImage(CGImage: imageRef!)
        
        return croppedImage
    }
    
    /// Returns a rescaled copy of the image, taking into account its orientation
    /// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
    func resizedImage(newSize: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        var drawTransposed: Bool
        
        switch (self.imageOrientation) {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }
        
        return self.resizedImage(newSize, transform: self.transformForOrientation(newSize), drawtransposed: drawTransposed, interpolationQuality: quality)
    }
    
    /// Resizes the image according to the given content mode, taking into account the image's orientation
    func resizedImageWithContentMode(contentMode: UIViewContentMode, bounds: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        let horizontalRatio: CGFloat = bounds.width / self.size.width
        let verticalRatio: CGFloat = bounds.height / self.size.height
        var ratio: CGFloat = 0.0
        
        switch (contentMode) {
        case .ScaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
        case .ScaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
        default:
            break
        }
        
        let newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio)
        
        return self.resizedImage(newSize, interpolationQuality: quality)
    }
    
    // MARK: - Private helper methods
    
    /// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
    /// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
    /// If the new size is not integral, it will be rounded up
    private func resizedImage(newSize: CGSize, transform: CGAffineTransform, drawtransposed transpose: Bool, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        let newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height))
        let transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width)
        let imageRef = self.CGImage
        
        // Build a context that's the same dimensions as the new size
        let bitmap = CGBitmapContextCreate(nil,
            Int(newRect.size.width),
            Int(newRect.size.height),
            CGImageGetBitsPerComponent(imageRef),
            0,
            CGImageGetColorSpace(imageRef),
            CGImageGetBitmapInfo(imageRef).rawValue)
        
        // Rotate and/or flip the image if required by its orientation
        CGContextConcatCTM(bitmap, transform)
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(bitmap, quality)
        
        // Draw into the context; this scales the image
        CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef)
        
        // Get the resized image from the context and a UIImage
        let newImageRef = CGBitmapContextCreateImage(bitmap)
        let newImage = UIImage(CGImage: newImageRef!)
        
        return newImage
    }
    
    
    /// Returns an affine transform that takes into account the image orientation when drawing a scaled image
    private func transformForOrientation(newSize: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransformIdentity
        
        switch (self.imageOrientation) {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, newSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        default:
            break
        }
        
        switch (self.imageOrientation) {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        default:
            break
        }
        
        return transform
    }
    
}