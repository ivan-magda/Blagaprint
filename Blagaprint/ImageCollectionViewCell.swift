//
//  ImageCollectionViewCell.swift
//  Blagaprint
//
//  Created by Niko on 21.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var imageView: UIImageView?
    
    /// Cell reuse identifier.
    static let cellReuseIdentifier = "ImageCollectionViewCell"
}
