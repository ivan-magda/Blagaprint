//
//  SelectDeviceTableViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 12.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class SelectDeviceTableViewController: UITableViewController {
    // MARK: - Properties
    
    /// Did select device call back closure.
    var didSelectDeviceClosure: ((Device) -> ())?
    
    /// Original device passed from CaseConstructorTableVC.
    var originalDevice: Device!
    
    /// Device cell identifier.
    static private let kDeviceCellReuseIdentifier = "DeviceCell"
    
    /// Supported devices.
    private var devices = [String: [Device]]()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(originalDevice != nil, "Original device must be passed when segue to this controller")
        setUp()
    }

    // MARK: - Private
    
    private func setUp() {
        self.title = "Устройство"
        self.configurateDevicesByCompany()
    }
    
    private func configurateDevicesByCompany() {
        for company in Device.companies() {
            for device in Device.allDevices() {
                if device.manufacturer == company {
                    if devices[company] == nil {
                        devices[company] = []
                    }
                    devices[company]!.append(device)
                }
            }
        }
    }
    
    private func companyFromSection(section: Int) -> String {
        return Device.companies()[section]
    }

    private func configurateCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let key = companyFromSection(indexPath.section)
        let device = devices[key]![indexPath.row]
        cell.textLabel?.text = device.name
        
        if originalDevice.name == device.name {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
    }
    
    // MARK: - UITableView
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Device.numberOfCompanies()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = companyFromSection(section)
        return devices[key]!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SelectDeviceTableViewController.kDeviceCellReuseIdentifier)!
        configurateCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return companyFromSection(section)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        weak var weakSelf = self
        if let callBack = didSelectDeviceClosure {
            let key = companyFromSection(indexPath.section)
            let selectedDevice = weakSelf!.devices[key]![indexPath.row]
            callBack(selectedDevice)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}
