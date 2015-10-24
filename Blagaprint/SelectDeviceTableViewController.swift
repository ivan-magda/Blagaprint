//
//  SelectDeviceTableViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 12.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

internal struct Device {
    let name: String
    let manufacturer: String
    
    func descriptionFromDevice() -> String {
        return "\(manufacturer) \(name)"
    }
}

class SelectDeviceTableViewController: UITableViewController {
    // MARK: - Properties
    
    /// Did select device call back closure.
    var didSelectDeviceClosure: ((Device) -> ())?
    
    /// Original device passed from CaseConstructorTableVC.
    var originalDevice: Device!
    
    /// Device cell identifier.
    static private let kDeviceCellReuseIdentifier = "DeviceCell"
    
    /// Supported devices.
    private var devices: [Device] = []
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(originalDevice != nil, "Original device must be passed when segue to this controller")
        
        self.title = "Устройство"
        
        configurateDevices()
    }
    
    // MARK: - Private
    
    private func configurateDevices() {
        let appleInc = "Apple"
        let samsung = "Samsung"
        devices = [Device(name: "iPhone 4/4S", manufacturer: appleInc), Device(name: "iPhone 5/5S", manufacturer: appleInc), Device(name: "iPhone 6/6S", manufacturer: appleInc), Device(name: "iPhone 6/6S Plus", manufacturer: appleInc), Device(name: "Galaxy S5", manufacturer: samsung)]
    }
    
    private func configurateCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let device = devices[indexPath.row];
        cell.textLabel?.text = device.descriptionFromDevice()
        
        if originalDevice.name == device.name {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
    }
    
    // MARK: - UITableView
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SelectDeviceTableViewController.kDeviceCellReuseIdentifier)!
        configurateCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: -UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        weak var weakSelf = self
        if let callBack = didSelectDeviceClosure {
            let selectedDevice = weakSelf!.devices[indexPath.row]
            callBack(selectedDevice)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}
