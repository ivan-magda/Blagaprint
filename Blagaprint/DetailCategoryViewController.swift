//
//  DetailCategoryCollectionViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 07.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class DetailCategoryViewController: UIViewController {
    // MARK: - Properties
    
    // Collection view cell reuse identifier.
    let kDetailCategoryCollectionViewCellIdentifier = "CategoryItemCell"
    
    // Data model for the collection view.
    var categoryItems: [CategoryItem] = []
    
    // IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // Did scroll to category item call back closure.
    var detailCategoryDidScrollToPageIndex: ((Int) -> ())?
    
    // Previous page index for indicating is it new page appear.
    private var previousSelectedPage: Int = -1
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        previousSelectedPage = pageControl.currentPage
    }
    
    // MARK: - Private
    
    private func didSelectPage(currentPage: Int) {
        if previousSelectedPage != -1 &&
            previousSelectedPage != currentPage {
                if let callBack = detailCategoryDidScrollToPageIndex {
                    callBack(currentPage)
                }
        }
        previousSelectedPage = currentPage
    }

    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth = CGRectGetWidth(collectionView.bounds)
        let currentPage = collectionView.contentOffset.x / pageWidth
        
        if 0.0 != fmodf(Float(currentPage), 1.0) {
            pageControl.currentPage += 1
        } else {
            pageControl.currentPage = Int(currentPage)
        }
        
        didSelectPage(pageControl.currentPage)
    }
    
    // MARK: - IBActions
    
    @IBAction func pageControlDidChangeValue(sender: UIPageControl) {
        let pageWidth = CGRectGetWidth(collectionView.bounds)
        let scrollTo = CGPointMake(pageWidth * CGFloat(pageControl.currentPage), 0)
        collectionView.setContentOffset(scrollTo, animated: true)
        
        didSelectPage(pageControl.currentPage)
    }
}

// MARK: - UICollectionView -

extension DetailCategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kDetailCategoryCollectionViewCellIdentifier, forIndexPath: indexPath) as! CategoryCollectionViewCell
        configuratedCellAtIndexPath(indexPath, cell: cell)
        
        setUpPageControl()
        
        return cell
    }
    
    private func setUpPageControl() {
        let itemCount = collectionView.numberOfItemsInSection(0)
        self.pageControl.numberOfPages = itemCount
        self.pageControl.hidden = (itemCount == 1)
    }
    
    func configuratedCellAtIndexPath(indexPath: NSIndexPath, cell: CategoryCollectionViewCell) {
        //        let categoryItem = categoryItems[indexPath.row]
        //        if let image = categoryItem.image {
        //            cell.categoryImageView?.image = image
        //        }
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Selected category at index: \(indexPath.row).")
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), CGRectGetHeight(collectionView.bounds))
    }
    
}
