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
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        // Set title.
        if let title = parentCategoryName {
            self.title = title
        } else {
            self.title = "Detail"
        }
    }
    
    // MARK: - Set Up
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kEmbedCollectionViewSegueIdentifier {
            let destinationVC = segue.destinationViewController as! DetailCategoryCollectionViewController
            destinationVC.categoryItems = self.categoryItems
        }
    }
    
    // MARK: - UITableView
    // MARK: Data Source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kDetailTableViewCellReuseIdentifier) as! DescriptionCell
        
        cell.descriptionLabel.text = "When you create a Core Data app, you design an initial data model for your app. However, after you ship your app inevitably you’ll want to make changes to your data model. What do you do then – you don’t want to break the app for existing users! "
        
        return cell
    }
}
