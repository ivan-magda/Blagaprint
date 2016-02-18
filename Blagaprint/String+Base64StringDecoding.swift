//
//  String+Base64StringDecoding.swift
//  Blagaprint
//
//  Created by Иван Магда on 18.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import UIKit

extension String {
    
    /// Returns an image decoded from Base-64 String.
    func decodedImageFromBase64String() -> UIImage? {
        let decodedData = NSData(base64EncodedString: self, options: [])
        
        if let decodedData = decodedData {
            let decodedImage = UIImage(data: decodedData)
            if let decodedImage = decodedImage {
                return decodedImage
            }
        }
        
        return nil
    }
    
}
