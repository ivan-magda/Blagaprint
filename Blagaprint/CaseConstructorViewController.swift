//
//  CaseConstructorViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 11.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class CaseConstructorTableViewController: UITableViewController {
    // MARK: - Types
    
    enum CellTypes: Int {
        case Device
        case Background
        case Text
    }
    
    // MARK: - Properties
    
    /// Case view.
    @IBOutlet weak var caseView: IPhoneCase!
    
    /// Device label.
    @IBOutlet weak var deviceLabel: UILabel!
    
    /// Segue identifier to SelectDeviceTableViewController.
    static let kSelectDeviceSegueIdentifier = "SelectDevice"
    
    /// Segue identifier to SelectbackgroundCollectionViewController.
    static let kSelectBackgroundSegueIdentifier = "BackgroundAction"
    
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
        } else if segue.identifier == CaseConstructorTableViewController.kSelectBackgroundSegueIdentifier {
            let navigationController = segue.destinationViewController as! UINavigationController
            let selectBackgroundVC = navigationController.topViewController as! SelectBackgroundCollectionViewController
            selectBackgroundVC.selectedColor = caseView.fillColor
            
            // Change color of case, when new color is picked.
            weak var weakSelf = self
            selectBackgroundVC.didSelectColorCompletionHandler = { (color) in
                if weakSelf!.caseView.fillColor != color {
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        weakSelf!.caseView.fillColor = color
                    })
                }
            }
        }
    }
    
    // MARK: - UITableView
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row == CellTypes.Background.rawValue ||
           indexPath.row == CellTypes.Text.rawValue {
            return nil
        }
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func selectBackgroundDidPressed(sender: UIButton) {
        presentSelectBackgroundAlertController()
    }
    
    @IBAction func selectTextDidPressed(sender: UIButton) {
        presentManageTextAlertController()
    }
    
    @IBAction func cancelButtonDidPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonDidPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UIAlertActions
    
    private func presentSelectBackgroundAlertController() {
        let backgroundSelectionAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        weak var weakSelf = self
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (action) -> Void in
        }
        backgroundSelectionAlertController.addAction(cancelAction)
        
        // Background library action
        let backgroundAction = UIAlertAction(title: "Палитра", style: .Default) { (action) -> Void in
            weakSelf?.performSegueWithIdentifier(CaseConstructorTableViewController.kSelectBackgroundSegueIdentifier, sender: nil)
        }
        backgroundSelectionAlertController.addAction(backgroundAction)
        
        // Images library action
        let imagesLibraryAction = UIAlertAction(title: "Библиотека", style: .Default, handler: { (action) -> Void in
        })
        backgroundSelectionAlertController.addAction(imagesLibraryAction)
        
        // Photo from gallery(take photo) action
        let photoAction = UIAlertAction(title: "Фото", style: .Default) { (action) -> Void in
        }
        backgroundSelectionAlertController.addAction(photoAction)
        
        self.presentViewController(backgroundSelectionAlertController, animated: true, completion: nil)
    }
    
    private func presentManageTextAlertController() {
        let manageTextAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        //weak var weakSelf = self
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (action) -> Void in
        }
        manageTextAlertController.addAction(cancelAction)
        
        // Enter text action
        let enterTextAction = UIAlertAction(title: "Ввести", style: .Default) { (action) -> Void in
        }
        manageTextAlertController.addAction(enterTextAction)
        
        // Select text color action
        let selectTextColorAction = UIAlertAction(title: "Цвет", style: .Default) { (action) -> Void in
        }
        manageTextAlertController.addAction(selectTextColorAction)
        
        // Pattern picking image action
        let pickImageAction = UIAlertAction(title: "Узор текста", style: .Default) { (action) -> Void in
        }
        manageTextAlertController.addAction(pickImageAction)
        
        self.presentViewController(manageTextAlertController, animated: true, completion: nil)
    }
}
