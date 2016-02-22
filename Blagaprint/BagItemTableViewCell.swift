//
//  BagItemTableViewCell.swift
//  Blagaprint
//
//  Created by Иван Магда on 04.01.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import UIKit

class BagItemTableViewCell: UITableViewCell {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    /// Cell reuse identifier.
    static let cellReuseIdentifier = "BagItemCell"
    
    /// Default cell height value.
    static let defaultHeightValue: CGFloat = 84.0
    
    //--------------------------------------
    // MARK: - Overriding
    //--------------------------------------
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        // Create circular picture and rounded corner image.
//        self.thumbnailImage.layer.cornerRadius = self.thumbnailImage.frame.size.width / 2.0
//        self.thumbnailImage.clipsToBounds = true
//        self.thumbnailImage.layer.borderWidth = 0.5
//        self.thumbnailImage.layer.borderColor = UIColor.blackColor().CGColor
    }

}
