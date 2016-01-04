//
//  ShoppingBagViewController.swift
//  Blagaprint
//
//  Created by Niko on 10.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class ShoppingBagViewController: PFQueryTableViewController {
    // MARK: - Properties
    
    var parseCentral: ParseCentral?
    
    private let logInImage = UIImage(named: "Enter.png")!
    private var logInBarButtonItem: UIBarButtonItem?
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // The className to query on
        self.parseClassName = BagItemClassName
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = false
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = false
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .SingleLine
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureAccountActionBarButton()
        
        self.loadObjects()
    }
    
    
    // MARK: - Private Helper Methods
    
    private func configureAccountActionBarButton() {
        if BlagaprintUser.currentUser() == nil {
            self.logInBarButtonItem = UIBarButtonItem(image: logInImage, style: .Plain, target: self, action: Selector("logInBarButtonDidPressed:"))
            self.navigationItem.rightBarButtonItem = logInBarButtonItem
        } else {
            self.logInBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func updateBadgeValue() {
        if let tabBarItem = self.tabBarController?.tabBar.items?[1] {
            if let objects = self.objects {
                if objects.count == 0 {
                    tabBarItem.badgeValue = nil
                } else {
                    tabBarItem.badgeValue = "\(objects.count)"
                }
            } else {
                tabBarItem.badgeValue = nil
            }
        }
    }
    
    // MARK: - Target
    
    func logInBarButtonDidPressed(sender: UIBarButtonItem) {
        self.presentViewController(LoginViewController(), animated: true, completion: nil)
    }
    
    // MARK: - PFQueryTableViewController -
    
    // MARK: Responding to Events
    
    /// Called when objects will loaded from Parse.
    override func objectsWillLoad() {
        super.objectsWillLoad()
        
        print("Objects will load.")
    }
    
    /// Called when objects have loaded from Parse.
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        if let error = error {
            print("Error with objects downloading: \(error.localizedDescription)")
            
            let message = error.userInfo["error"] as! String
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            print("Objects have loaded from Parse.")
        }
    }
    
    // MARK: Querying
    
    /// Construct custom PFQuery to get the objects.
    override func queryForTable() -> PFQuery {
        guard let user = BlagaprintUser.currentUser() else {
            return PFQuery()
        }
        
        let query = PFQuery(className: self.parseClassName!)
        query.orderByDescending(BagItem.Keys.createdAt.rawValue)
        query.whereKey(BagItem.Keys.userId.rawValue, equalTo: user.objectId!)
        query.cachePolicy = .CacheThenNetwork
        
        return query
    }
    
    // MARK: Data Source Methods
    
    /// Customize each cell given a PFObject that is loaded.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(BagItemTableViewCell.cellReuseIdentifier) as! BagItemTableViewCell
        cell.label.text = ""
        
        if let objects = self.objects {
            let item = objects[indexPath.row] as! BagItem
            
            cell.thumbnailImage.image = UIImage()
            cell.thumbnailImage.file = item.thumbnail
            
            // Remote image downloading.
            weak var weakCell = cell
            cell.thumbnailImage.loadInBackground({ (image, error) in
                if let error = error {
                    print("Error: \(error.userInfo["error"])")
                } else {
                    weakCell?.thumbnailImage.image = image
                }
            })
            
            // Get category name.
            let categoryId = item.category
            let categoryQuery = PFQuery(className: CategoryClassName)
            categoryQuery.cachePolicy = .CacheThenNetwork
            categoryQuery.getObjectInBackgroundWithId(categoryId) { (category, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let category = category as? Category {
                    weakCell?.label.text = "\(category.name): \(item.createdAt!)"
                }
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateBadgeValue()
        
        return self.objects?.count ?? 0
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
