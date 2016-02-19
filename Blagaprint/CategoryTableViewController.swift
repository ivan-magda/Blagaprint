//
//  ViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 27.09.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit
import Firebase

class CategoryTableViewController: UITableViewController {
    
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    private enum SegueIdentifier: String {
        case PhoneCaseConstructor
        case CategoryItem
    }
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    /// CategoryTableViewCell height value.
    private let categoryTableViewCellHeight: CGFloat = 200.0
    
    /// Height for tableView header view.
    private let headerViewHeight: CGFloat = 44.0
    
    var dataService: DataService!
    
    private var categories = [FCategory]()
    
    private var loadingLabel: UILabel?
    
    //--------------------------------------
    // MARK: - View Life Cycle
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: updateBagTabBarItemBadgeValue
        ParseCentral.updateBagTabBarItemBadgeValue()
        
        // Back button without title.
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        loadCategories()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("loadCategories"), forControlEvents: .ValueChanged)
    }
    
    //--------------------------------------
    // MARK: - Navigation
    //--------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.CategoryItem.rawValue {
            let categoryItemViewController = segue.destinationViewController as! CategoryItemViewController
            categoryItemViewController.dataService = dataService
            
            if let selectedRow = self.tableView.indexPathForSelectedRow {
                categoryItemViewController.category = categories[selectedRow.section]
            }
        } else if segue.identifier == SegueIdentifier.PhoneCaseConstructor.rawValue {
            let caseConstructorVC = segue.destinationViewController as! CaseConstructorTableViewController
            // TODO: fix with path the category
            
//            caseConstructorVC.parseCentral = self.parseCentral
//            
//            if let selectedRow = self.tableView.indexPathForSelectedRow {
//                caseConstructorVC.category = objects![selectedRow.section] as! Category
//            }
        }
    }
    
    //--------------------------------------
    // MARK: Querying
    //--------------------------------------
    
    func loadCategories() {
        DataService.showNetworkIndicator()
        
        if self.categories.count == 0 {
            showLoadingLabel()
        }
        
        // observeEventType is called whenever anything changes in the Firebase.
        // It's always listening.
        
        let categoryRef = dataService.categoryReference
        
        categoryRef.queryOrderedByChild(FCategory.Keys.name.rawValue).observeEventType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                print("Loading categories failed. Snapshot: \(snapshot)")
            } else {
                print("Categories loaded. Now parse it.")
            }
            
            self.categories.removeAll(keepCapacity: true)
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    
                    // Make our categories array for the tableView.
                    
                    if let categoryDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let category = FCategory(key: key, dictionary: categoryDictionary)
                        
                        print("Category \(category)")
                        
                        // Reverse ordered.
                        
                        self.categories.insert(category, atIndex: 0)
                    }
                }
            }
            
            self.refreshControl?.endRefreshing()
            
            DataService.hideNetworkIndicator()
            
            self.hideLoadingLabel()
            
            // Be sure that the tableView updates when there is new data.
            
            self.tableView.reloadData()
        })
    }
    
    //--------------------------------------
    // MARK: - UITableViewDataSource
    //--------------------------------------
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.categories.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let categoryCell = self.tableView.dequeueReusableCellWithIdentifier(CategoryTableViewCell.cellReuseIdentifier) as! CategoryTableViewCell
        
        let category = categories[indexPath.section]
        
        categoryCell.categoryImageView?.image = category.image
        
        //categoryCell.imageDownloadingActivityIndicator.startAnimating()
        
        return categoryCell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(tableView.bounds), headerViewHeight))
        headerView.layer.insertSublayer(AppAppearance.horizontalTunaGradientLayerForRect(headerView.bounds), atIndex: 0)
        
        let labelHeight: CGFloat = 18.0
        let labelLeadingSpace: CGFloat = 15.0
        let labelTrailingSpace: CGFloat = labelLeadingSpace + 8.0
        let label = UILabel(frame: CGRectMake(labelLeadingSpace, CGRectGetHeight(headerView.bounds) / 2 - labelHeight / 2.0, CGRectGetWidth(tableView.bounds) - labelTrailingSpace, labelHeight))
        
        let category = categories[section]
        label.text = category.name
        label.textColor = UIColor.whiteColor()
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    //--------------------------------------
    // MARK: - UITableViewDelegate
    //--------------------------------------
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let category = categories[indexPath.section]
        
        switch category.type! {
        case .phoneCase:
            self.performSegueWithIdentifier(SegueIdentifier.PhoneCaseConstructor.rawValue, sender: nil)
        default:
            self.performSegueWithIdentifier(SegueIdentifier.CategoryItem.rawValue, sender: nil)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerViewHeight
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return categoryTableViewCellHeight
    }
    
    //--------------------------------------
    // MARK: - Loading Label -
    //--------------------------------------
    
    private func showLoadingLabel() {
        guard self.loadingLabel == nil else {
            return
        }
        
        self.loadingLabel = UILabel()
        self.loadingLabel?.text = NSLocalizedString("Loading...", comment: "")
        self.loadingLabel?.sizeToFit()
        
        if let navigationController = self.navigationController {
            self.loadingLabel?.center = navigationController.view.center
            
            navigationController.view.addSubview(loadingLabel!)
        }
    }
    
    private func hideLoadingLabel() {
        self.loadingLabel?.removeFromSuperview()
        self.loadingLabel = nil
    }
}

