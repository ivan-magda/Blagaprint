//
//  DetailTableViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 07.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
    // MARK: - Properties
    
    // Table view cell reuse identifier.
    private let kDetailTableViewCellReuseIdentifier = "InfoCell"
    
    // Table view embed segue identifier for DetailCategoryCollectionVC.
    private let kEmbedCollectionViewSegueIdentifier = "EmbedCollectionView"
    
    // Data source for the table view.
    var categoryItems: [CategoryItem] = []
    
    // Title for the navigation bar.
    var parentCategoryName: String?
    
    // When DetailCategoryVC scroll to new page, we use this variable
    // for proper selection of CategoryItem obj
    private var selectedCategoryIndex: Int = 0
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    // MARK: - Set Up
    
    private func setUp() {
        setUpTitle()
        setUpContainerViewFrame()
        configureTableView()
    }
    
    private func setUpTitle() {
        if let title = parentCategoryName {
            self.title = title
        } else {
            self.title = "Detail"
        }
    }
    
    private func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
    }
    
    private func setUpContainerViewFrame() {
        let containerViewFrame = CGRectMake(tableView.tableHeaderView!.bounds.origin.x, tableView.tableHeaderView!.bounds.origin.y, CGRectGetWidth(tableView.bounds), CGRectGetHeight(tableView!.bounds) / 2.0)
        self.tableView.tableHeaderView!.frame = containerViewFrame
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kEmbedCollectionViewSegueIdentifier {
            let destinationVC = segue.destinationViewController as! DetailCategoryViewController
            destinationVC.categoryItems = self.categoryItems
            
            weak var weakSelf = self
            destinationVC.detailCategoryDidScrollToPageIndex = { (index) in
                weakSelf?.selectedCategoryIndex = index
                weakSelf?.tableView?.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
    
    // MARK: - UITableView -
    // MARK: Data Source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kDetailTableViewCellReuseIdentifier) as! DescriptionCell
        
        cell.descriptionLabel.text = "\(categoryItems[selectedCategoryIndex].name)."
        
        return cell
    }
    
    // MARK: Delegate
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
}
