//
//  StringFormatNumberExtension.swift
//  Blagaprint
//
//  Created by Иван Магда on 13.01.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation

extension String {
    
    /// Returns a formatted currency string from number.
    static func formatAmount(number: NSNumber) -> String {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.locale = NSLocale(localeIdentifier: "ru_RU")
        numberFormatter.numberStyle = .CurrencyStyle
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        if let formattedString = numberFormatter.stringFromNumber(number) {
            return formattedString
        } else {
            return "\(number)"
        }
    }
}
