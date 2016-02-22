//
//  String+Date.swift
//  Blagaprint
//
//  Created by Иван Магда on 22.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation

extension String {
    
    func getDateValue() -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EE, dd MMMM, yyyy. HH:mm"
        
        return dateFormatter.dateFromString(self)
    }
    
}
