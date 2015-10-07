//
//  ViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 27.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class MainCollectionViewController: UICollectionViewController {
    // MARK: - Properties
    
    /// Reuse identifiers for collection view.
    private let kCategoryCollectionViewCellReuseIdentifier = "CollectionViewCell"
    private let kNothingFoundCollectionViewCellReuseIdentifier = "NothingFoundCell"
    
    /// Detail category segue identifier.
    private let kDetailCategorySegueIdentifier = "DetailCategory"
    
    /// Observe value key path for collection view content offset.
    private let kCollectionViewObserveValueKeyPath = "contentOffset"
    
    /// Collection view size and inset values.
    private let kCollectionViewCellHeightValue: CGFloat = 200.0
    private let kCollectionViewTopSectionInset: CGFloat = 0.0
    
    /// Data model for the collection view.
    private var categories: [Category] = Category.seedInitialData()
    private var filteredCategories: [Category] = [Category]()
    
    /// Search bar is active state value.
    private var searchBarActive: Bool = false
    
    /// Search bar coordinate and size values.
    private var searchBarBoundsY: CGFloat = 0.0
    private let searchBarHeight: CGFloat = 44.0
    
    /// Search bar to help us with filtering.
    lazy private var searchBar: UISearchBar = {
        self.searchBarBoundsY = CGRectGetHeight(self.navigationController!.navigationBar.frame) + CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
        
        var temporarySearchBar = UISearchBar(frame: CGRectMake(0.0, self.searchBarBoundsY + self.kCollectionViewTopSectionInset, CGRectGetWidth(UIScreen.mainScreen().bounds), self.searchBarHeight))
        temporarySearchBar.searchBarStyle = UISearchBarStyle.Minimal
        temporarySearchBar.delegate = self
        temporarySearchBar.placeholder = "Поиск"
        
        // add KVO observer.. so we will be informed when user scroll colllectionView
        self.addObservers()
        
        return temporarySearchBar
    }()
    
    // MARK: - View Life Cycle
    
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
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kDetailCategorySegueIdentifier {
            if let selectedCategory = sender as? Category {
                let detailViewController = segue.destinationViewController as! DetailTableViewController
                detailViewController.categoryItems = Array(selectedCategory.categoryItems)
                detailViewController.parentCategoryName = selectedCategory.name
            }
        }
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
        return getConfiguratedCellAtIndexPath(indexPath)
    }
    
    func getConfiguratedCellAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        if nothingFound() {
            let collectionViewCell = self.collectionView!.dequeueReusableCellWithReuseIdentifier(kNothingFoundCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! NothingFoundCollectionViewCell
            collectionViewCell.textLabel.text = "Ничего не найдено"
            
            return collectionViewCell
        } else {
            let collectionViewCell = self.collectionView!.dequeueReusableCellWithReuseIdentifier(kCategoryCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! CategoryCollectionViewCell
            
            let category = (searchBarActive ? filteredCategories[indexPath.row] : categories[indexPath.row])
            collectionViewCell.categoryImageView?.image = category.image
            collectionViewCell.categoryNameLabel.text = category.name
            
            return collectionViewCell
        }
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedCategory = categories[indexPath.row]
        switch selectedCategory.categoryType {
        case .cases, .cups, .keyRingsWithPhoto, .clothes, .copyServices, .printingBy3Dprint:
            print("Perform detail segue")
            self.performSegueWithIdentifier(kDetailCategorySegueIdentifier, sender: selectedCategory)
        default:
            break
        }
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !nothingFound()
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension MainCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(CGRectGetHeight(searchBar.frame) + kCollectionViewTopSectionInset * 2, 0.0, 0.0, 0.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), kCollectionViewCellHeightValue)
    }
}

// MARK: - Search -

extension MainCollectionViewController: UISearchBarDelegate {
    
    private func cancelSearching() {
        searchBarActive = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
    
    private func filterContentForSearchText(searchText: String) {
        filteredCategories = categories.filter({ (category: Category) -> Bool in
            return category.name.lowercaseString.containsString(searchText.lowercaseString)
        })
    }
    
    private func reloadContentData() {
        collectionView?.reloadSections(NSIndexSet(index: 0))
    }
    
    private func nothingFound() -> Bool {
        return searchBarActive && filteredCategories.count == 0
    }

    // MARK: UISearchBarDelegate
    
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

