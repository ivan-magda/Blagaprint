//
//  ViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 27.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let kCollectionViewCellReuseIdentifier = "CollectionViewCell"
    
    @IBOutlet weak var barButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let categories: [String]! = ["Именные чехлы", "Именные футболки", "Печать на кружках", "Фотопечать", "Копи-услуги"]
    
// MARK: - ViewController lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar = self.navigationController!.navigationBar
        navBar.barTintColor = UIColor(red: 65.0 / 255.0, green: 62.0 / 255.0, blue: 79.0 / 255.0, alpha: 1)
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.collectionView.backgroundColor = UIColor(red: 44.0 / 255.0, green: 42.0 / 255.0, blue: 54.0 / 255, alpha: 1)
    }

// MARK: - Navigation -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MenuSegue" {
            let destinationVC = segue.destinationViewController as! GuillotineMenuViewController
            destinationVC.hostNavigationBarHeight = CGRectGetHeight(self.navigationController!.navigationBar.frame)
            destinationVC.hostTitleText = self.navigationItem.title
            destinationVC.view!.backgroundColor = self.navigationController!.navigationBar.barTintColor
            destinationVC.setMenuButtonWithImage(self.barButton.imageView!.image!)
        }
    }
}

// MARK: - UICollectionViewDataSource -

extension ViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: CategoryCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(kCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! CategoryCollectionViewCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let collectionViewCell: CategoryCollectionViewCell = cell as! CategoryCollectionViewCell
        
        collectionViewCell.layer.cornerRadius = 5
        collectionViewCell.categoryImageView?.image = UIImage(named: "\(indexPath.row).jpg")
        collectionViewCell.categoryNameLabel.text = categories[indexPath.row]
    }
}

// MARK: - UICollectionViewDelegate -

extension ViewController: UICollectionViewDelegate {
    
}
