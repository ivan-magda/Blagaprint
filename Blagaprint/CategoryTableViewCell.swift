//
//  CategoryCollectionViewCell.swift
//  Blagaprint
//
//  Created by Ivan Magda on 28.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit
import ParseUI

class CategoryTableViewCell: PFTableViewCell {
    //--------------------------------------
    // MARK: Properties
    //--------------------------------------
    
    @IBOutlet weak var categoryImageView: PFImageView?
    @IBOutlet weak var imageDownloadingActivityIndicator: UIActivityIndicatorView!
    
}
