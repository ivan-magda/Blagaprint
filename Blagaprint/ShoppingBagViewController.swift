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
    
    private func configuratedCellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(ProceedToCheckoutTableViewCell.cellReuseIdentifier) as! ProceedToCheckoutTableViewCell
            
            cell.proceedToCheckoutButton.addTarget(self, action: Selector("proceedToCheckout:"), forControlEvents: .TouchUpInside)
            
            // Count for amount and format it.
            var amount = 0.0
            for object in self.objects! {
                amount += object.price
            }
            
            let formatAmount = String.formatAmount(NSNumber(double: amount))
            
            cell.orderDetailsLabel.text = NSLocalizedString("Order in the amount of \(formatAmount)", comment: "Order detail info with amount")
            cell.proceedToCheckoutButton.setTitle(NSLocalizedString("Proceed to Checkout", comment: "Proceed to Checkout button title"), forState: .Normal)
            
            return cell
        } else {
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
    }
    
    //--------------------------------------
    // MARK: - Target
    //--------------------------------------
    
    func logInBarButtonDidPressed(sender: UIBarButtonItem) {
        self.presentViewController(LoginViewController(), animated: true, completion: nil)
    }
    
    func proceedToCheckout(sender: UIButton) {
        print("Proceed to Checkout did pressed")
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
        query.orderByDescending(BagItem.FieldKey.createdAt.rawValue)
        query.whereKey(BagItem.FieldKey.userId.rawValue, equalTo: user.objectId!)
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
                    let categoryQuery = PFQuery(className: Category.parseClassName())
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
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = self.objects else {
            return 0
        }
        
        if section == 0 {
            return 1
        } else {
            return self.objects!.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return configuratedCellForRowAtIndexPath(indexPath)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Remove the deleted object from data source.
            if let parseCentral = self.parseCentral {
                let itemToDelete = objects![indexPath.row]
                
                parseCentral.deleteItem(itemToDelete: itemToDelete, succeeded: {
                    let idString = itemToDelete.objectId!
                    
                    self.objects!.removeAtIndex(indexPath.row)
                    self.thumbnails.removeValueForKey(idString)
                    self.categories.removeValueForKey(idString)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
                        
                        let alert = UIAlertController(title: NSLocalizedString("Succeeded", comment: ""), message: "Item has successfully deleted", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                    }, failure: { error in
                        dispatch_async(dispatch_get_main_queue()) {
                            let alert = UIAlertController(title: NSLocalizedString("Failure", comment: ""), message: error.localizedDescription, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                })
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("order info", comment: "Order info title for header in section, ShoppingBagVC")
        } else {
            return NSLocalizedString("selected items", comment: "Selected items title for header in section, ShoppingBagVC")
        }
    }
    
    //--------------------------------------
    // MARK: - UITableViewDelegate
    //--------------------------------------
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return ProceedToCheckoutTableViewCell.defaultHeightValue
        } else {
            return BagItemTableViewCell.defaultHeightValue
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return (indexPath.section == 0 ? nil : indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
