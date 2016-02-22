//
//  CategoryCollectionViewCell.swift
//  Blagaprint
//
//  Created by Ivan Magda on 28.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    //--------------------------------------
    // MARK: Properties
    //--------------------------------------
    
    @IBOutlet weak var categoryImageView: UIImageView?
    @IBOutlet weak var imageDownloadingActivityIndicator: UIActivityIndicatorView!
 
    /// Cell reuse identifier.
    static let cellReuseIdentifier = "CategoryCell"
    
}
