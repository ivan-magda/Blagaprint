//
//  ExpandedCollectionViewFlowLayout.swift
//  Blagaprint
//
//  Created by Ivan Magda on 07.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class ExpandedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    // MARK: - Properties
    
    let kCollectionViewHeightValue: CGFloat = 200.0

    // MARK: - Overriding
    
    override func collectionViewContentSize() -> CGSize {
        let itemCount = self.collectionView!.numberOfItemsInSection(0)
        
        let width = CGRectGetWidth(self.collectionView!.bounds)
        let height = CGRectGetHeight(self.collectionView!.bounds)
        
        return CGSizeMake(width * CGFloat(itemCount), height);
    }
    
    override internal var itemSize: CGSize {
        get { return CGSizeMake(CGRectGetWidth(self.collectionView!.bounds), kCollectionViewHeightValue) }
        set {}
    }
}
