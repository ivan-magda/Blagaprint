//
//  ViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 27.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class CategoriesCollectionViewController: UICollectionViewController {
    private let kCategoryCollectionViewCellReuseIdentifier = "CollectionViewCell"
    private let kNothingFoundCollectionViewCellReuseIdentifier = "NothingFoundCell"
    private let kCollectionViewObserveValueKeyPath = "contentOffset"
    private let kCollectionViewCellHeightValue: CGFloat = 200.0
    private let kCollectionViewTopSectionInset: CGFloat = 0.0
    
    private var categories: [Category] = Category.seedInitialData()
    private var filteredCategories: [Category] = [Category]()
    
    private var searchBarActive: Bool = false
    private var searchBarBoundsY: CGFloat = 0.0
    private let searchBarHeight: CGFloat = 44.0
    
    lazy private var searchBar: UISearchBar = {
        self.searchBarBoundsY = CGRectGetHeight(self.navigationController!.navigationBar.frame) + CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
        
        var temporarySearchBar = UISearchBar(frame: CGRectMake(0.0, self.searchBarBoundsY + self.kCollectionViewTopSectionInset, CGRectGetWidth(UIScreen.mainScreen().bounds), self.searchBarHeight))
        temporarySearchBar.delegate = self
        temporarySearchBar.placeholder = "Поиск"
        
        // add KVO observer.. so we will be informed when user scroll colllectionView
        self.addObservers()
        
        return temporarySearchBar
    }()
    
// MARK: - ViewController lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.searchBar.isDescendantOfView(self.view) {
            self.view.addSubview(self.searchBar)
        }
    }
    
    deinit {
        removeObservers()
    }
    
// MARK: - Navigation -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

// MARK: - UICollectionView -
// MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchBarActive {
            if filteredCategories.count > 0 {
                return filteredCategories.count
            } else {
                return 1
            }
        }
        return categories.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if nothingFound() {
            return collectionView.dequeueReusableCellWithReuseIdentifier(kNothingFoundCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! NothingFoundCollectionViewCell
        } else {
            return collectionView.dequeueReusableCellWithReuseIdentifier(kCategoryCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! CategoryCollectionViewCell
        }
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if nothingFound() {
            let collectionViewCell: NothingFoundCollectionViewCell = cell as! NothingFoundCollectionViewCell
            collectionViewCell.textLabel.text = "Ничего не найдено"
        } else {
            let collectionViewCell: CategoryCollectionViewCell = cell as! CategoryCollectionViewCell
            
            let category = (searchBarActive ? filteredCategories[indexPath.row] : categories[indexPath.row])
            collectionViewCell.categoryImageView?.image = category.image
            collectionViewCell.categoryNameLabel.text = category.name
        }
    }

// MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Select category at index: \(indexPath.row).")
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !nothingFound()
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension CategoriesCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(CGRectGetHeight(searchBar.frame) + kCollectionViewTopSectionInset * 2, 0.0, 0.0, 0.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), kCollectionViewCellHeightValue)
    }
}

//MARK: - Search -

extension CategoriesCollectionViewController: UISearchBarDelegate {
    
    private func cancelSearching() {
        searchBarActive = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
    
    private func filterContentForSearchText(searchText: String) {
        filteredCategories = categories.filter({ (category: Category) -> Bool in
            return (category.name?.lowercaseString.containsString(searchText.lowercaseString))!
        })
    }
    
    private func reloadContentData() {
        collectionView?.reloadSections(NSIndexSet(index: 0))
    }
    
    private func nothingFound() -> Bool {
        return searchBarActive && filteredCategories.count == 0
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // user did type something, check our datasource for text that looks the same
        if searchText.characters.count > 0 {
            // search and reload data source
            searchBarActive = true
            filterContentForSearchText(searchText)
        } else {
            // if text lenght == 0
            // we will consider the searchbar is not active
            searchBarActive = false
        }
        reloadContentData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if searchBar.text?.characters.count == 0 {
            cancelSearching()
            return
        } else {
            cancelSearching()
            reloadContentData()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBarActive = true
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        // we used here to set self.searchBarActive = YES
        // but we'll not do that any more... it made problems
        // it's better to set self.searchBarActive = YES when user typed something
        self.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        // this method is being called when search btn in the keyboard tapped
        // we set searchBarActive = NO
        // but no need to reloadCollectionView
        searchBarActive = false
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
// MARK: - KVO Observing -
    
    private func addObservers() {
        self.collectionView?.addObserver(self, forKeyPath: kCollectionViewObserveValueKeyPath, options: [NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Old], context: nil)
    }
    
    private func removeObservers() {
        self.collectionView?.removeObserver(self, forKeyPath: kCollectionViewObserveValueKeyPath, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let observer = object as? UICollectionView {
            if keyPath! == kCollectionViewObserveValueKeyPath &&
                observer == self.collectionView {
                    self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
                        self.searchBarBoundsY + ((-1 * object!.contentOffset.y) - self.searchBarBoundsY) + kCollectionViewTopSectionInset,
                        self.searchBar.frame.size.width,
                        self.searchBar.frame.size.height);
            }
        }
    }
}

