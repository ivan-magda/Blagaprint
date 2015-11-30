//
//  ExpandedCollectionViewFlowLayout.swift
//  Blagaprint
//
//  Created by Иван Магда on 20.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class ExpandedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func collectionViewContentSize() -> CGSize {
        let pages = self.collectionView!.numberOfSections()
        
        let width = CGRectGetWidth(self.collectionView!.bounds)
        let height = CGRectGetHeight(self.collectionView!.bounds)
        
        return CGSizeMake(width * CGFloat(pages), height)
    }
}
