//
//  FrameItemColectionView.swift
//  Blagaprint
//
//  Created by Иван Магда on 20.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class FrameItemColectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}