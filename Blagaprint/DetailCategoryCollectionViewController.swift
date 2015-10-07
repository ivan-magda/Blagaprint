//
//  DetailCategoryCollectionViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 07.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class DetailCategoryCollectionViewController: UICollectionViewController {
    // MARK: - Properties
    
    // Collection view cell reuse identifier.
    private let kDetailCategoryCollectionViewCellIdentifier = "CategoryItemCell"
    
    // Data model for the collection view.
    var categoryItems: [CategoryItem] = []
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - UICollectionView -
    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryItems.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kDetailCategoryCollectionViewCellIdentifier, forIndexPath: indexPath) as! CategoryCollectionViewCell
        configuratedCellAtIndexPath(indexPath, cell: cell)
        
        return cell
    }
    
    func configuratedCellAtIndexPath(indexPath: NSIndexPath, cell: CategoryCollectionViewCell) {
        let categoryItem = categoryItems[indexPath.row]
//        if let image = categoryItem.image {
//            cell.categoryImageView?.image = image
//        }
        cell.categoryNameLabel.text = categoryItem.name
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Selected category at index: \(indexPath.row).")
    }
}
