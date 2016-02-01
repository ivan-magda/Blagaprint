//
//  PickTypeTableViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 01.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import UIKit

//--------------------------------------------------------
// MARK: - PickTypeTableViewControllerDataSourceProtocol
//--------------------------------------------------------

@objc protocol PickTypeTableViewControllerDataSourceProtocol {
    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int
    
    func itemForIndexPath(indexPath: NSIndexPath) -> String
    optional func itemForSection(section: Int) -> String
}

//------------------------------------------------------
// MARK: - PickTypeTableViewControllerDelegateProtocol
//------------------------------------------------------

@objc protocol PickTypeTableViewControllerDelegateProtocol: NSObjectProtocol {
    optional func pickTypeTableViewController(controller: PickTypeTableViewController, didSelectItem item: String, atIndexPath indexPath: NSIndexPath)
}

//--------------------------------------
// MARK:
//--------------------------------------

class PickTypeTableViewController: UITableViewController {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    private let cellReuseIdentifier = "PickTypeCell"
    
    /// Original type name passed from whom invoked.
    var originalTypeName: String!
    
    var dataSource: PickTypeTableViewControllerDataSourceProtocol?
    var delegate: PickTypeTableViewControllerDelegateProtocol?
    
    //--------------------------------------
    // MARK: - View Life Cycle
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(originalTypeName != nil, "Original type name should be passed when segue to this controller")
    }
    
    //--------------------------------------
    // MARK: - UITableViewDataSource
    //--------------------------------------
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (dataSource != nil ? dataSource!.numberOfSections() : 0)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataSource != nil ? dataSource!.numberOfRowsInSection(section) : 0)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)!
        
        let itemName = dataSource!.itemForIndexPath(indexPath)
        cell.textLabel?.text = itemName
        
        if originalTypeName == itemName {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource!.itemForSection?(section) ?? nil
    }
    
    //--------------------------------------
    // MARK: - UITableViewDelegate
    //--------------------------------------
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let delegate = self.delegate {
            let item = dataSource!.itemForIndexPath(indexPath)
            delegate.pickTypeTableViewController?(self, didSelectItem: item, atIndexPath: indexPath)
            
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}
