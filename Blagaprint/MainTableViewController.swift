//
//  ViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 27.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    // MARK: - Properties
    
    /// Identifier for table view cell.
    private let kCategoryTableViewCellIdentifier = "CategoryCell"
    private let kCategoryItemTableViewCellIdentifier = "CategoryItemCell"
    private let kNothingFoundTableViewCellIdentifier = "NothingFoundCell"
    
    /// Detail category segue identifier.
    private let kDetailCategorySegueIdentifier = "DetailCategory"
    
    /// Collection view size and inset values.
    private let kCategoryTableViewCellHeightValue: CGFloat = 200.0
    
    /// Data model for the table view.
    private var categories: [Category] = Category.seedInitialData()
    private var filteredCategories: [Category] = [Category]()
    
    /// Search bar is active state value.
    private var searchBarActive: Bool = false
    
    /// Search bar coordinate and size values.
    private var searchBarBoundsY: CGFloat = 0.0
    private let searchBarHeight: CGFloat = 44.0
    
    private var selectedSectionIndex = -1
    
    /// Search bar to help us with filtering.
    lazy private var searchBar: UISearchBar = {
        self.searchBarBoundsY = CGRectGetHeight(self.navigationController!.navigationBar.frame) + CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
        
        var temporarySearchBar = UISearchBar(frame: CGRectMake(0.0, self.searchBarBoundsY, CGRectGetWidth(UIScreen.mainScreen().bounds), self.searchBarHeight))
        temporarySearchBar.searchBarStyle = UISearchBarStyle.Minimal
        temporarySearchBar.delegate = self
        temporarySearchBar.placeholder = "Поиск"
        
        return temporarySearchBar
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tableView.tableHeaderView = searchBar
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kDetailCategorySegueIdentifier {
            if let selectedCategory = sender as? Category {
                let detailViewController = segue.destinationViewController as! DetailCategoryCollectionViewController
                detailViewController.categoryItems = Array(selectedCategory.categoryItems)
                detailViewController.parentCategoryName = selectedCategory.name
            }
        }
    }

    // MARK: - UITableView -
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchBarActive {
            if filteredCategories.count > 0 {
                return filteredCategories.count
            } else {
                return 1
            }
        }
        return categories.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSectionIndex != -1 &&
           selectedSectionIndex == section {
            let countItems = categories[section].categoryItems.count
            
            return (countItems == 0 ? 1 : countItems + 1)
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return getConfiguratedCellAtIndexPath(indexPath)
    }
    
    func getConfiguratedCellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        if nothingFound() {
            let nothingFoundCell = self.tableView!.dequeueReusableCellWithIdentifier(kNothingFoundTableViewCellIdentifier) as! NothingFoundTableViewCell
            nothingFoundCell.label.text = "Ничего не найдено"
            
            return nothingFoundCell
        } else if indexPath.row == 0 {
            let categoryCell = self.tableView.dequeueReusableCellWithIdentifier(kCategoryTableViewCellIdentifier) as! CategoryTableViewCell
            
            let category = (searchBarActive ? filteredCategories[indexPath.section] : categories[indexPath.section])
            categoryCell.categoryImageView?.image = category.image
            categoryCell.categoryNameLabel.text = category.name
            
            return categoryCell
        } else {
            let categoryItemCell = self.tableView.dequeueReusableCellWithIdentifier(kCategoryItemTableViewCellIdentifier) as! CategoryItemTableViewCell
            let item = categories[indexPath.section].categoryItems[indexPath.row - 1]
            categoryItemCell.categoryItemCell.text = item.name
            
            return categoryItemCell
        }
    }

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let selectedCategory = categories[indexPath.row]
//        switch selectedCategory.categoryType {
//        case .cases, .cups, .keyRingsWithPhoto, .clothes, .copyServices, .printingBy3Dprint:
//            print("Perform detail segue")
//            self.performSegueWithIdentifier(kDetailCategorySegueIdentifier, sender: selectedCategory)
//        default:
//            break
//        }
        
        if selectedSectionIndex == indexPath.section {
            selectedSectionIndex = -1
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
        } else {
            if selectedSectionIndex != indexPath.section &&
               selectedSectionIndex != -1 {
                selectedSectionIndex = indexPath.section
                tableView.reloadData()
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0  {
            return kCategoryTableViewCellHeightValue
        } else {
            return 44.0
        }
    }
}

// MARK: - Search -

extension MainTableViewController: UISearchBarDelegate {
    
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
}

