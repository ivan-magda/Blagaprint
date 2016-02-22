//
//  NSDate+String.swift
//  Blagaprint
//
//  Created by Иван Магда on 22.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation

extension NSDate {
    
    func getStringValue() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EE, dd MMMM, yyyy. HH:mm"
        
        return dateFormatter.stringFromDate(self)
    }
    
}
