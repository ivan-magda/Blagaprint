//
//  UIImage+Base64String.swift
//  Blagaprint
//
//  Created by Иван Магда on 18.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// Returns a Base-64 encoded String from the UIImage.
    func base64EncodedString() -> String {
        // Make an NSData JPEG representation of the image.
        let imageData = UIImageJPEGRepresentation(self, 0.9)
        
        // Encode data to base 64 string.
        let base64String = imageData?.base64EncodedStringWithOptions([])
        
        return base64String!
    }
}
