//
//  ViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 27.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let kCollectionViewCellReuseIdentifier = "CollectionViewCell"
    
    private let categories: [String]! = ["Именные чехлы", "Именные футболки", "Печать на кружках", "Фотопечать", "Копи-услуги"]
    
// MARK: - ViewController lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = AppAppearance.AppColors.ebonyClayColor
    }
}

// MARK: - UICollectionViewDataSource -

extension ViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(kCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! CategoryCollectionViewCell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let collectionViewCell: CategoryCollectionViewCell = cell as! CategoryCollectionViewCell
        collectionViewCell.categoryImageView?.image = UIImage(named: "\(indexPath.row).jpg")
        collectionViewCell.categoryNameLabel.text = categories[indexPath.row].uppercaseString
    }
}

// MARK: - UICollectionViewDelegate -

extension ViewController: UICollectionViewDelegate {
    
}
