//
//  ShoppingBagViewController.swift
//  Blagaprint
//
//  Created by Niko on 10.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class ShoppingBagViewController: UITableViewController {
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var parseCentral: ParseCentral?
    
    private let logInImage = UIImage(named: "Enter.png")!
    private var logInBarButtonItem: UIBarButtonItem?
    
    private var objects: [BagItem]?
    private var thumbnails = [String : UIImage]()
    private var categories = [String : String]()
    
    //--------------------------------------
    // MARK: - View Life Cycle
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .SingleLine
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureAccountActionBarButton()
        
        loadObjects()
        
        ParseCentral.updateBagTabBarItemBadgeValue()
    }
    
    //--------------------------------------
    // MARK: - Private Helper Methods
    //--------------------------------------
    
    private func configureAccountActionBarButton() {
        if BlagaprintUser.currentUser() == nil {
            self.logInBarButtonItem = UIBarButtonItem(image: logInImage, style: .Plain, target: self, action: Selector("logInBarButtonDidPressed:"))
            self.navigationItem.rightBarButtonItem = logInBarButtonItem
        } else {
            self.logInBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    //--------------------------------------
    // MARK: - Target
    //--------------------------------------
    
    func logInBarButtonDidPressed(sender: UIBarButtonItem) {
        self.presentViewController(LoginViewController(), animated: true, completion: nil)
    }
    
    //--------------------------------------
    // MARK: Querying
    //--------------------------------------
    
    private func loadObjects() {
        guard let user = BlagaprintUser.currentUser() else {
            self.objects = nil
            
            return
        }
        
        let query = PFQuery(className: BagItemClassName)
        query.orderByDescending(BagItem.Keys.createdAt.rawValue)
        query.whereKey(BagItem.Keys.userId.rawValue, equalTo: user.objectId!)
        query.cachePolicy = .CacheThenNetwork
        
        query.findObjectsInBackgroundWithBlock() { (items, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let items = items as? [BagItem] {
                self.objects = items
                
                self.thumbnails.removeAll(keepCapacity: true)
                self.categories.removeAll(keepCapacity: true)
                
                // Load thumbnail image.
                for item in items {
                    item.thumbnail.getDataInBackgroundWithBlock() { (data, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let data = data where data.length > 0 {
                            if let image = UIImage(data: data) {
                                self.thumbnails[item.objectId!] = image
                            }
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.reloadData()
                            }
                        }
                    }
                    
                    // Get category name.
                    let categoryId = item.category
                    let categoryQuery = PFQuery(className: CategoryClassName)
                    categoryQuery.cachePolicy = .CacheThenNetwork
                    categoryQuery.getObjectInBackgroundWithId(categoryId) { (category, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let category = category as? Category {
                            self.categories[item.objectId!] = category.name
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //--------------------------------------
    // MARK: - UITableViewDataSource
    //--------------------------------------
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(BagItemTableViewCell.cellReuseIdentifier) as! BagItemTableViewCell
        
        let item = objects![indexPath.row]
        
        if indexPath.row < self.thumbnails.count {
            cell.thumbnailImage.image = thumbnails[item.objectId!]
        }
        
        if indexPath.row < self.categories.count {
            cell.descriptionLabel.text = categories[item.objectId!]
        }
        
        cell.priceLabel.text = String.formatAmount(NSNumber(double: item.price))
        
        return cell
    }
    
    //--------------------------------------
    // MARK: - UITableViewDelegate
    //--------------------------------------
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
