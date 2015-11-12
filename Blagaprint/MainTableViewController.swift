//
//  ViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 27.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

/// CategoryTableViewCell identifier.
private let kCategoryTableViewCellIdentifier = "CategoryCell"

/// CategoryItemTableViewCell identifier.
private let kCategoryItemTableViewCellIdentifier = "CategoryItemCell"

/// NothingFoundTableViewCell identifier.
private let kNothingFoundTableViewCellIdentifier = "NothingFoundCell"

/// CategoryTableViewCell height value.
private let kCategoryTableViewCellHeightValue: CGFloat = 200.0

/// Height for tableView header view.
private let kHeightForHeader: CGFloat = 44.0

class MainTableViewController: UITableViewController {
    // MARK: - Properties -
    
    /// Data source for the table view.
    private var categories: [Category] = []
    private var filteredCategories: [Category] = [Category]()
    
    /// Handle previous selection of CategoryTableViewCell.
    private var selectedSectionIndex = -1

    /// Separator view tag value.
    private let separatorViewTag = 17
    
    /// Search controller to help us with filtering.
    var searchController: UISearchController!
    
    /// Search bar state.
    private var searchBarActive: Bool = false
    
    private let library: Library = Library.sharedInstance
    
    /// LoadingView that presenting when app first time launched.
    private var loadingView: LoadingView?
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AppConfiguration.isFirstTimeAppLaunch() {
            self.configurateTableView()
            self.presentLoadingActivityIndicator()
            library.loadFromCloudKit() {
                self.loadingView!.stopAnimating()
                self.loadingView!.removeFromSuperview()
                
                self.configurateRefreshControl()
                self.searchSetUp()
                self.reloadDataAfterCallback()
                
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: IsFirstTimeAppLaunchIdentifier)
            }
        } else {
            // Load data from library.
            if Library.cacheExist() {
                library.loadFromCache() {
                    self.reloadDataAfterCallback()
                }
                configurateRefreshControl()
            } else {
                self.configurateRefreshControl()
                self.refreshControl!.beginRefreshing()
                library.loadFromCloudKit() {
                    self.reloadDataAfterCallback()
                }
            }
            configurateTableView()
            searchSetUp()
        }
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Navigation -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

    // MARK: - UITableView -
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSections()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItemsInSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return getConfiguratedCellAtIndexPath(indexPath)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if nothingFound() {
            return nil
        }
        
        let headerView = UIView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(tableView.bounds), kHeightForHeader))
        headerView.backgroundColor = AppAppearance.AppColors.tuna
        
        let labelHeight: CGFloat = 18.0
        let labelLeadingSpace = CategoryItemTableViewCell.leadingSpace
        let labelTrailingSpace = labelLeadingSpace + 8.0
        let label = UILabel(frame: CGRectMake(labelLeadingSpace, CGRectGetHeight(headerView.bounds) / 2 - labelHeight / 2.0, CGRectGetWidth(tableView.bounds) - labelTrailingSpace, labelHeight))
        let category = (searchBarActive ? filteredCategories[section] : categories[section])
        label.text = category.name
        label.textColor = UIColor.whiteColor()
        
        headerView.addSubview(label)
        
        return headerView
    }
    

    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        configurateSeparatorViewOnCell(cell, atIndexPath: indexPath)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchController.searchBar.resignFirstResponder()
        
        if indexPath.row == 0 {
            let category = getCategoryFromIndexPath(indexPath)
            if category.categoryType == Category.CategoryTypes.cases {
                self.performSegueWithIdentifier("PhoneCaseConstructor", sender: nil)
                return
            }
        }
        
        if selectedSectionIndex == indexPath.section {
            selectedSectionIndex = -1
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
        } else {
            if selectedSectionIndex != indexPath.section &&
               selectedSectionIndex != -1 {
               selectedSectionIndex = indexPath.section
                tableView.reloadData()
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            } else {
                selectedSectionIndex = indexPath.section
                tableView.reloadSections(NSIndexSet(index: selectedSectionIndex), withRowAnimation: .Automatic)
            }
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if !nothingFound() {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return nothingFound() ? 0.0 : kHeightForHeader
    }
    
    // MARK: - Private Helpers Methods -
    
    func reloadLibrary() {
        weak var weakSelf = self
        if Library.cacheExist() {
            library.loadFromCloudKit() {
                weakSelf!.reloadDataAfterCallback()
            }
        } else {
            library.loadFromCache() {
                weakSelf!.reloadDataAfterCallback()
            }
        }
    }
    
    private func reloadDataAfterCallback() {
        self.categories = Library.sharedInstance.categories
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    private func configurateRefreshControl() {
        let refreshLibraryControl = UIRefreshControl()
        refreshLibraryControl.addTarget(self, action: Selector("reloadLibrary"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshLibraryControl
    }
    
    private func presentLoadingActivityIndicator() {
        let navigationController = self.navigationController!
        let navControllerFrame = navigationController.view.bounds
        
        self.loadingView = LoadingView(frame: navControllerFrame)
        navigationController.view.addSubview(loadingView!)
        self.loadingView!.startAnimating()
    }
    
    // MARK: NSNotificationCenter
    
    private func addObservers() {
        weak var weakSelf = self
        NSNotificationCenter.defaultCenter().addObserverForName(LibraryDidDoneWithCloudKitDataDownloadingNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            notification in
            print("Handle cloudkit notification: \(notification)")
            weakSelf!.reloadLibrary()
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName(LibraryDidDoneWithDataLoadingFromCacheNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            notification in
            print("Handle cache notification: \(notification)")
            weakSelf!.reloadLibrary()
        })
    }
    
    private func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: UITableView
    
    private func configurateTableView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = kCategoryTableViewCellHeightValue
    }
    
    private func numberOfSections() -> Int {
        if searchBarActive {
            if filteredCategories.count > 0 {
                return filteredCategories.count
            } else {
                return 1
            }
        }
        return categories.count
    }
    
    private func numberOfItemsInSection(section: Int) -> Int {
        if selectedSectionIndex != -1 &&
           selectedSectionIndex == section {
                let countItems = categories[section].categoryItems.count
                
                return (countItems == 0 ? 1 : countItems + 1)
        } else {
            return 1
        }
    }
    
    private func getConfiguratedCellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        if nothingFound() {
            let nothingFoundCell = self.tableView!.dequeueReusableCellWithIdentifier(kNothingFoundTableViewCellIdentifier) as! NothingFoundTableViewCell
            nothingFoundCell.label.text = "Ничего не найдено"
            
            return nothingFoundCell
        } else if indexPath.row == 0 {
            let categoryCell = self.tableView.dequeueReusableCellWithIdentifier(kCategoryTableViewCellIdentifier) as! CategoryTableViewCell
            
            let category = getCategoryFromIndexPath(indexPath)
            categoryCell.categoryImageView?.image = category.image
            categoryCell.categoryNameLabel.text = category.name.uppercaseString
            
            return categoryCell
        } else {
            let categoryItemCell = self.tableView.dequeueReusableCellWithIdentifier(kCategoryItemTableViewCellIdentifier) as! CategoryItemTableViewCell
            let item = categories[indexPath.section].categoryItems[indexPath.row - 1]
            categoryItemCell.categoryItemLabel.text = item.name
            
            return categoryItemCell
        }
    }
    
    private func getCategoryFromIndexPath(indexPath: NSIndexPath) -> Category {
        return searchBarActive ? filteredCategories[indexPath.section] : categories[indexPath.section]
    }
    
    private func configurateSeparatorViewOnCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 0 && !nothingFound() {
            let separatorFrame = CGRectMake(CategoryItemTableViewCell.leadingSpace, CGRectGetHeight(cell.bounds) - 0.5, CGRectGetWidth(tableView.bounds) - CategoryItemTableViewCell.leadingSpace, 0.5)
            
            var separatorFound = false
            for view in cell.subviews {
                if view.tag == separatorViewTag {
                    view.frame = separatorFrame
                    separatorFound = true
                    break
                }
            }
            
            if !separatorFound {
                let separator = UIView(frame: separatorFrame)
                separator.backgroundColor = tableView.separatorColor
                separator.tag = separatorViewTag
                
                cell.addSubview(separator)
            }
        }
    }
    
    private func searchSetUp() {
        searchController = UISearchController(searchResultsController: nil)
    
        let searchBar = searchController.searchBar
        searchBar.tintColor = UIColor.blackColor()
        searchBar.placeholder = "Поиск"
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self    // so we can monitor text changes + others
        
        /*
        Search is now just presenting a view controller. As such, normal view controller
        presentation semantics apply. Namely that presentation will walk up the view controller
        hierarchy until it finds the root view controller or one that defines a presentation context.
        */
        definesPresentationContext = true
    }
}

// MARK: - Search -

extension MainTableViewController: UISearchBarDelegate {
    private func filterContentForSearchText(searchText: String) {
        filteredCategories = categories.filter({ (category: Category) -> Bool in
            return category.name.lowercaseString.containsString(searchText.lowercaseString)
        })
    }
    
    private func cancelSearching() {
        searchBarActive = false
        searchController.searchBar.resignFirstResponder()
        searchController.searchBar.text = ""
    }
    
    private func reloadContentData() {
        tableView.reloadData()
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
        } else {
            cancelSearching()
            reloadContentData()
        }
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBarActive = true
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        // this method is being called when search btn in the keyboard tapped
        // we set searchBarActive = NO
        // but no need to reloadCollectionView
        searchBarActive = false
    }
}

