//
//  CaseConstructorViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 11.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit
import ImageIO

class CaseConstructorTableViewController: UITableViewController {
    // MARK: - Types
    
    enum CellTypes: Int {
        case Device
        case Background
        case Text
    }
    
    enum ColorSelectionType: String {
        case CaseBackground
        case TextColor
    }
    
    // MARK: - Properties
    
    /// Case view.
    @IBOutlet weak var caseView: IPhoneCase!
    
    /// Device label.
    @IBOutlet weak var deviceLabel: UILabel!
    
    /// Segue identifier to SelectDeviceTableViewController.
    static let kSelectDeviceSegueIdentifier = "SelectDevice"
    
    /// Segue identifier to SelectbackgroundCollectionViewController.
    static let kSelectBackgroundSegueIdentifier = "ColorPicking"
    
    /// Segue identifier to TextEditingViewController.
    static let kTextEditingSegueIdentifier = "TextEditing"
    
    /// Default supported device.
    var device: Device!
    
    /// Image picker controller to let us take/pick photo.
    let imagePickerController: UIImagePickerController = UIImagePickerController()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = Device(deviceName: "iPhone 5/5S", deviceManufacturer: "Apple")

        // The required delegate to get a photo back to the app.
        imagePickerController.delegate = self
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
            
            // Change case/text color, when new color picked.
            weak var weakSelf = self
            
            var caseBackgroundType = false
            var textColorType = false
            let type = sender as! String
            if type == ColorSelectionType.CaseBackground.rawValue {
                selectBackgroundVC.selectedColor = caseView.fillColor
                caseBackgroundType = true
            } else if type == ColorSelectionType.TextColor.rawValue {
                selectBackgroundVC.selectedColor = caseView.textColor
                textColorType = true
            }
            
            selectBackgroundVC.didSelectColorCompletionHandler = { (color) in
                if caseBackgroundType {
                    if weakSelf!.caseView.fillColor != color {
                        UIView.animateWithDuration(0.25, animations: { () -> Void in
                            weakSelf!.caseView.fillColor = color
                        })
                    }
                } else if textColorType {
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        weakSelf!.caseView.textColor = color
                    })
                }
            }
        } else if segue.identifier == CaseConstructorTableViewController.kTextEditingSegueIdentifier {
            let navigationController = segue.destinationViewController as! UINavigationController
            let textEditingVC = navigationController.topViewController as! TextEditingViewController
            textEditingVC.text = caseView.text
            
            // Change text on case.
            weak var weakSelf = self
            textEditingVC.didDoneOnTextCompletionHandler = { (text) in
                weakSelf?.caseView.text = text
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
            let type = ColorSelectionType.CaseBackground.rawValue
            weakSelf?.performSegueWithIdentifier(CaseConstructorTableViewController.kSelectBackgroundSegueIdentifier, sender: type)
        }
        backgroundSelectionAlertController.addAction(backgroundAction)
        
        // Images library action
        let imagesLibraryAction = UIAlertAction(title: "Библиотека", style: .Default, handler: { (action) -> Void in
        })
        backgroundSelectionAlertController.addAction(imagesLibraryAction)
        
        // Photo from gallery(take photo) action
        let photoFromLibrary = UIAlertAction(title: "Выбрать фото", style: .Default) { (action) -> Void in
            weakSelf!.photoFromLibrary()
        }
        backgroundSelectionAlertController.addAction(photoFromLibrary)
        
        let shoot = UIAlertAction(title: "Сфотать", style: .Default) { (action) -> Void in
            weakSelf!.shootPhoto()
        }
        backgroundSelectionAlertController.addAction(shoot)
        
        self.presentViewController(backgroundSelectionAlertController, animated: true, completion: nil)
    }
    
    private func presentManageTextAlertController() {
        let manageTextAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        weak var weakSelf = self
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (action) -> Void in
        }
        manageTextAlertController.addAction(cancelAction)
        
        // Enter text action
        let enterTextAction = UIAlertAction(title: "Ввести", style: .Default) { (action) -> Void in
            self.performSegueWithIdentifier(CaseConstructorTableViewController.kTextEditingSegueIdentifier, sender: nil)
        }
        manageTextAlertController.addAction(enterTextAction)
        
        // Select text color action
        let selectTextColorAction = UIAlertAction(title: "Цвет", style: .Default) { (action) -> Void in
            let type = ColorSelectionType.TextColor.rawValue
            weakSelf!.performSegueWithIdentifier(CaseConstructorTableViewController.kSelectBackgroundSegueIdentifier, sender: type)
        }
        manageTextAlertController.addAction(selectTextColorAction)
        
        self.presentViewController(manageTextAlertController, animated: true, completion: nil)
    }
}

// MARK: - Image picking extension -

extension CaseConstructorTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: Private helper methods
    
    private func noCamera() {
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    /// Get a photo from the library.
    private func photoFromLibrary() {
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.modalPresentationStyle = .FullScreen
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    /// Take a picture, check if we have a camera first.
    private func shootPhoto() {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePickerController.allowsEditing = false
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            imagePickerController.cameraCaptureMode = .Photo
            imagePickerController.modalPresentationStyle = .FullScreen
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let newSize = CGSizeMake(CGRectGetWidth(caseView.bounds), CGRectGetHeight(caseView.bounds))
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
        let newImageRect = CGRectMake(0.0, 0.0, newSize.width, newSize.height);
        chosenImage.drawInRect(newImageRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        caseView.image = newImage
        caseView.showBackgroundImage = true

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}