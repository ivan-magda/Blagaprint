//
//  BagItemTableViewCell.swift
//  Blagaprint
//
//  Created by Иван Магда on 04.01.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import UIKit

class BagItemTableViewCell: PFTableViewCell {
    // MARK: - Properties
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    static let cellReuseIdentifier = "BagItemCell"

}
