//
//  CaseConstructorViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 11.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class CaseConstructorTableViewController: UITableViewController {
    // MARK: - Properties
    
    /// Device label.
    @IBOutlet weak var deviceLabel: UILabel!
    
    /// Segue identifier to SelectDeviceTableViewController.
    static let kSelectDeviceSegueIdentifier = "SelectDevice"
    
    /// Default supported device.
    var device: Device!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = Device(deviceName: "iPhone 5/5S", deviceManufacturer: "Apple")
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == CaseConstructorTableViewController.kSelectDeviceSegueIdentifier {
            let selectDeviceViewController = segue.destinationViewController as! SelectDeviceTableViewController
            selectDeviceViewController.originalDevice = device
            
            // Call back when SelectDeviceTableVC did select device.
            weak var weakSelf = self
            selectDeviceViewController.didSelectDeviceClosure = { (selectedDevice: Device) in
                weakSelf?.device = selectedDevice
                weakSelf?.deviceLabel.text = weakSelf?.device.deviceName
            }
        }
    }

    
    // MARK: - IBActions
    
    @IBAction func cancelButtonDidPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonDidPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
