//
//  ShoppingBagViewController.swift
//  Blagaprint
//
//  Created by Niko on 10.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit
import Firebase

class ShoppingBagViewController: UITableViewController {
    
    //--------------------------------------
    // MARK: - Properties -
    //--------------------------------------
    
    var dataService: DataService!
    
    private let logInImage = UIImage(named: "Enter.png")!
    private var logInBarButtonItem: UIBarButtonItem?
    
    private var items = [FBagItem]()
    private var categories = [String : String]()
    private var categoryItems = [String : String]()
    
    //--------------------------------------
    // MARK: - Init
    //--------------------------------------
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Adding notification observer.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadObjects"), name: NotificationName.CategoryItemViewControllerDidAddItemToBagNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //--------------------------------------
    // MARK: - View Life Cycle -
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .SingleLine
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadObjects()
        dataService.updateBagBadgeValue()
        
        configureAccountActionBarButton()
    }
    
    //--------------------------------------
    // MARK: - Private Helper Methods
    //--------------------------------------
    
    private func configureAccountActionBarButton() {
        if dataService.isUserLoggedIn {
            logInBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
        } else {
            logInBarButtonItem = UIBarButtonItem(image: logInImage, style: .Plain, target: self, action: Selector("logInBarButtonDidPressed:"))
            navigationItem.rightBarButtonItem = logInBarButtonItem
        }
    }
    
    private func configuratedCellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(ProceedToCheckoutTableViewCell.cellReuseIdentifier) as! ProceedToCheckoutTableViewCell
            
            cell.proceedToCheckoutButton.addTarget(self, action: Selector("proceedToCheckout:"), forControlEvents: .TouchUpInside)
            
            // Count for amount and format it.
            var amount = 0.0
            for item in items {
                amount += item.amount
            }
            
            let formatAmount = String.formatAmount(NSNumber(double: amount))
            
            cell.orderDetailsLabel.text = NSLocalizedString("Order in the amount of \(formatAmount)", comment: "Order detail info with amount")
            cell.proceedToCheckoutButton.setTitle(NSLocalizedString("Proceed to Checkout", comment: "Proceed to Checkout button title"), forState: .Normal)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(BagItemTableViewCell.cellReuseIdentifier) as! BagItemTableViewCell
            
            let item = items[indexPath.row]
            
            cell.thumbnailImage.image = item.thumbnail
            
            var description = ""
            
            // Category title name.
            if let categoryName = categories[item.key] {
                description += categoryName
            }
            
            // Category item name.
            if let itemName = categoryItems[item.key] {
                description += " \(itemName.lowercaseString)"
            }
            
            // Item size.
            if let itemSize = items[indexPath.row].itemSize where itemSize != "" {
                description += ": \(itemSize)"
            }
            
            cell.descriptionLabel.text = description
            cell.priceLabel.text = String.formatAmount(NSNumber(double: item.amount))
            
            return cell
        }
    }
    
    //--------------------------------------
    // MARK: - Target
    //--------------------------------------
    
    func logInBarButtonDidPressed(sender: UIBarButtonItem) {
        LoginViewController.presentInController(self)
    }
    
    func proceedToCheckout(sender: UIButton) {
        print("Proceed to Checkout did pressed")
    }
    
    //--------------------------------------
    // MARK: Querying
    //--------------------------------------
    
    func loadObjects() {
        
        func clearData() {
            items.removeAll(keepCapacity: true)
            categories.removeAll(keepCapacity: true)
            categoryItems.removeAll(keepCapacity: true)
        }
        
        guard dataService.isUserLoggedIn == true else {
            clearData()
            tableView.reloadData()
            
            return
        }
        
        guard let userId = User.currentUserId else {
            clearData()
            tableView.reloadData()
            
            return
        }
        
        let bagRef = dataService.bagReference
        
        // Query for the user bag.
        
        // TODO: ordered by creation date
        bagRef.queryOrderedByChild(FBag.Key.userId.rawValue).queryEqualToValue(userId).observeEventType(.Value, withBlock: { [weak self] snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                assert(snapshots.count == 1, "Bag must be unique for each user.")
                
                // Create user bag object.
                
                clearData()
                
                let bagSnap = snapshots[0]
                
                if let bagDict = bagSnap.value as? [String: AnyObject] {
                    let bag = FBag(key: bagSnap.key, dictionary: bagDict)
                    
                    // Query for the BagItems of the current bag.
                    
                    if let items = bag.items {
                        if let itemRef = self?.dataService.bagItemReference {
                            for itemPath in items {
                                
                                // Append each item object to the item data source array.
                                
                                itemRef.childByAppendingPath(itemPath).observeEventType(.Value, withBlock: { itemSnap in
                                    if let itemDict = itemSnap.value as? [String: AnyObject] {
                                        let item = FBagItem(key: itemPath, dictionary: itemDict)
                                        
                                        self?.items.append(item)
                                        self?.tableView.reloadData()
                                        
                                        // Query for the category name of the specific item.
                                        
                                        let categoryRef = self?.dataService.categoryReference
                                        categoryRef?.childByAppendingPath(item.category).observeEventType(.Value, withBlock: { categorySnap in
                                            if let categoryDict = categorySnap.value as? [String: AnyObject] {
                                                let name = categoryDict[FCategory.Keys.titleName.rawValue] as? String
                                                if let name = name {
                                                    self?.categories[itemPath] = name
                                                    self?.tableView.reloadData()
                                                }
                                            }
                                        })
                                        
                                        // Query for categoryItem name of the specific item.
                                        
                                        if let cItem = item.categoryItem {
                                            let cItemRef = self?.dataService.categoryItemReference
                                            cItemRef?.childByAppendingPath(cItem).observeEventType(.Value, withBlock: { snap in
                                                if let cItemDict = snap.value as? [String: AnyObject] {
                                                    let name = cItemDict[FCategoryItem.Keys.name.rawValue] as? String
                                                    if let name = name {
                                                        self?.categoryItems[itemPath] = name
                                                        self?.tableView.reloadData()
                                                    }
                                                }
                                            })
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
            })
        
        dataService.updateBagBadgeValue()
    }
    
    //--------------------------------------
    // MARK: - UITableViewDataSource
    //--------------------------------------
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count == 0 {
            return 0
        }
        
        if section == 0 {
            return 1
        }
        
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return configuratedCellForRowAtIndexPath(indexPath)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // FIXME: implement item deletion
        if editingStyle == .Delete {
            // Remove the deleted object from data source.
            //            if let parseCentral = self.parseCentral {
            //                let itemToDelete = items![indexPath.row]
            //
            //                parseCentral.deleteItem(itemToDelete: itemToDelete, succeeded: {
            //                    let idString = itemToDelete.objectId!
            //
            //                    self.objects!.removeAtIndex(indexPath.row)
            //                    self.thumbnails.removeValueForKey(idString)
            //                    self.categories.removeValueForKey(idString)
            //
            //                    dispatch_async(dispatch_get_main_queue()) {
            //                        // Reload a table view.
            //                        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0, length: 2)), withRowAnimation: .Automatic)
            //
            //                        let alert = UIAlertController(title: NSLocalizedString("Successfully", comment: ""), message: "Item has successfully deleted", preferredStyle: .Alert)
            //                        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            //                        self.presentViewController(alert, animated: true, completion: nil)
            //
            //                        ParseCentral.updateBagTabBarItemBadgeValue()
            //                    }
            //
            //                    }, failure: { error in
            //                        dispatch_async(dispatch_get_main_queue()) {
            //                            let alert = UIAlertController(title: NSLocalizedString("Failure", comment: ""), message: error?.localizedDescription ?? NSLocalizedString("An error occured. Please try again later.", comment: "Failure alert message"), preferredStyle: .Alert)
            //                            alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            //                            self.presentViewController(alert, animated: true, completion: nil)
            //
            //                            ParseCentral.updateBagTabBarItemBadgeValue()
            //                        }
            //                })
            //            }
            //
            //            ParseCentral.updateBagTabBarItemBadgeValue()
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if items.count == 0 {
            return nil
        }
        
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
