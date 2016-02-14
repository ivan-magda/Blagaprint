//
//  ItemSizeCollectionViewCell.swift
//  Blagaprint
//
//  Created by Иван Магда on 11.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import UIKit

class ItemSizeCollectionViewCell: UICollectionViewCell {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var sizeLabel: UILabel?
    
    /// Cell reuse identifier.
    static let cellReuseIdentifier = "SizeCell"

    //--------------------------------------
    // MARK: - Life Cycle
    //--------------------------------------
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.bounds.height / 2.0
        self.clipsToBounds = true
    }
}
