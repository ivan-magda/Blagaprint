//
//  CollectionTableViewCell.swift
//  Blagaprint
//
//  Created by Иван Магда on 20.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {
    // MARK: - Properties
    
    @IBOutlet weak var collectionView: FrameItemColectionView!
    @IBOutlet weak var pageControl: UIPageControl!
}
