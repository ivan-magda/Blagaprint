//
//  IPhoneCase.swift
//  Blagaprint
//
//  Created by Ivan Magda on 11.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

@IBDesignable
class IPhoneCase: UIView {
    // MARK: - Drawing
    
    override func drawRect(rect: CGRect) {
        PhoneCases.drawIPhoneCase(self.bounds, fillColor: UIColor.whiteColor())
    }
}
