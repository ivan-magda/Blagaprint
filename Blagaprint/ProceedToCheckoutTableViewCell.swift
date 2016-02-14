//
//  ProceedToCheckoutTableViewCell.swift
//  Blagaprint
//
//  Created by Иван Магда on 21.01.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import UIKit

class ProceedToCheckoutTableViewCell: UITableViewCell {
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var orderDetailsLabel: UILabel!
    @IBOutlet weak var proceedToCheckoutButton: UIButton!
    
    /// Cell reuse identifier.
    static let cellReuseIdentifier = "ProceedToCheckoutCell"
    
    /// Cell height value.
    static let defaultHeightValue: CGFloat = 132.0
    
    //--------------------------------------
    // MARK: - Overriding
    //--------------------------------------
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.proceedToCheckoutButton.layer.cornerRadius = proceedToCheckoutButton.frame.height * 0.1
        self.proceedToCheckoutButton.clipsToBounds = true
    }
}
