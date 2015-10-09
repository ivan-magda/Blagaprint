//
//  ExpandedCollectionViewFlowLayout.swift
//  Blagaprint
//
//  Created by Ivan Magda on 07.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class ExpandedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    // MARK: - Overriding
    
    override func collectionViewContentSize() -> CGSize {
        let itemCount = self.collectionView!.numberOfItemsInSection(0)
        
        let width = CGRectGetWidth(self.collectionView!.bounds)
        let height = CGRectGetHeight(self.collectionView!.bounds)
        
        return CGSizeMake(width * CGFloat(itemCount), height);
    }
}
