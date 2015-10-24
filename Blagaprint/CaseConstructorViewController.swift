//
//  CaseConstructorViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 11.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit
import ImageIO

/// Segue identifier to SelectDeviceTableViewController.
private let kSelectDeviceSegueIdentifier = "SelectDevice"

/// Segue identifier to SelectbackgroundCollectionViewController.
private let kSelectBackgroundSegueIdentifier = "ColorPicking"

/// Segue identifier to TextEditingViewController.
private let kTextEditingSegueIdentifier = "TextEditing"

/// Segue identifier to PhotoLibraryCollectionViewController
private let kPhotoLibrarySegueIdentifier = "PhotoLibrary"

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
    @IBOutlet weak var caseView: CaseView!
    
    /// Device label.
    @IBOutlet weak var deviceLabel: UILabel!
    
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
        if segue.identifier == kSelectDeviceSegueIdentifier {
            let selectDeviceViewController = segue.destinationViewController as! SelectDeviceTableViewController
            selectDeviceViewController.originalDevice = device
            
            // Call back when SelectDeviceTableVC did select device.
            weak var weakSelf = self
            selectDeviceViewController.didSelectDeviceClosure = { (selectedDevice: Device) in
                weakSelf?.device = selectedDevice
                
                // Update table header view frame.
                var tableHeaderViewHeight: CGFloat = 400.0
                if selectedDevice.deviceName == "iPhone 5/5S" {
                    tableHeaderViewHeight = 400.0
                } else if selectedDevice.deviceName == "iPhone 4/4S" {
                    tableHeaderViewHeight = 380.0
                }
                
                let tableView = weakSelf?.tableView
                let newFrame = CGRectMake(tableView!.bounds.origin.x, tableView!.bounds.origin.y, CGRectGetWidth(tableView!.bounds), tableHeaderViewHeight)
                
                weakSelf?.view.layoutIfNeeded()
                
                tableView?.tableHeaderView?.alpha = 0.0
                UIView.animateWithDuration(0.45, delay: 0.1, options: .CurveEaseInOut, animations: { () in
                    tableView?.tableHeaderView?.frame = newFrame
                    tableView?.tableHeaderView = tableView?.tableHeaderView
                    tableView?.tableHeaderView?.alpha = 1.0
                    }, completion: nil)
                
                // Present selected device.
                weakSelf?.caseView.device = selectedDevice
                weakSelf?.deviceLabel.text = weakSelf?.device.deviceName
            }
        } else if segue.identifier == kSelectBackgroundSegueIdentifier {
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
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        weakSelf!.caseView.fillColor = color
                        weakSelf!.caseView.showBackgroundImage = false
                    })
                } else if textColorType {
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        weakSelf!.caseView.textColor = color
                    })
                }
            }
        } else if segue.identifier == kTextEditingSegueIdentifier {
            let navigationController = segue.destinationViewController as! UINavigationController
            let textEditingVC = navigationController.topViewController as! TextEditingViewController
            textEditingVC.text = caseView.text
            
            // Change text on case.
            weak var weakSelf = self
            textEditingVC.didDoneOnTextCompletionHandler = { (text) in
                weakSelf?.caseView.text = text
            }
        } else if segue.identifier == kPhotoLibrarySegueIdentifier {
            let navigationController = segue.destinationViewController as! UINavigationController
            let photoLibraryVC = navigationController.topViewController as! PhotoLibraryCollectionViewController
            
            photoLibraryVC.delegate = self
        }
    }
    
    // MARK: - UITableView
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == CellTypes.Background.rawValue {
            presentSelectBackgroundAlertController()
        } else if indexPath.row == CellTypes.Text.rawValue {
            presentManageTextAlertController()
        }
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
        
        // Photo from gallery(take photo) action
        let photoFromLibrary = UIAlertAction(title: "Медиатека", style: .Default) { (action) -> Void in
            weakSelf!.photoFromLibrary()
        }
        backgroundSelectionAlertController.addAction(photoFromLibrary)
        
        let shoot = UIAlertAction(title: "Снять фото", style: .Default) { (action) -> Void in
            weakSelf!.shootPhoto()
        }
        backgroundSelectionAlertController.addAction(shoot)
        
        // Background library action
        let backgroundAction = UIAlertAction(title: "Палитра", style: .Default) { (action) -> Void in
            let type = ColorSelectionType.CaseBackground.rawValue
            weakSelf?.performSegueWithIdentifier(kSelectBackgroundSegueIdentifier, sender: type)
        }
        backgroundSelectionAlertController.addAction(backgroundAction)
        
        // Images library action
        let imagesLibraryAction = UIAlertAction(title: "Библиотека изображений", style: .Default, handler: { (action) -> Void in
            weakSelf?.performSegueWithIdentifier(kPhotoLibrarySegueIdentifier, sender: nil)
        })
        backgroundSelectionAlertController.addAction(imagesLibraryAction)
        
        self.presentViewController(backgroundSelectionAlertController, animated: true, completion: nil)
    }
    
    private func presentManageTextAlertController() {
        let manageTextAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        weak var weakSelf = self
        
        // Remove text action
        let removeTextAction = UIAlertAction(title: "Очистить", style: .Destructive) { (action) -> Void in
            UIView.animateWithDuration(0.45, animations: { () -> Void in
                weakSelf!.caseView.text = ""
            })
        }
        manageTextAlertController.addAction(removeTextAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (action) -> Void in
        }
        manageTextAlertController.addAction(cancelAction)
        
        // Select text color action
        let selectTextColorAction = UIAlertAction(title: "Цвет", style: .Default) { (action) -> Void in
            let type = ColorSelectionType.TextColor.rawValue
            weakSelf!.performSegueWithIdentifier(kSelectBackgroundSegueIdentifier, sender: type)
        }
        manageTextAlertController.addAction(selectTextColorAction)
        
        // Enter text action
        let enterTextAction = UIAlertAction(title: "Ввести текст", style: .Default) { (action) -> Void in
            self.performSegueWithIdentifier(kTextEditingSegueIdentifier, sender: nil)
        }
        manageTextAlertController.addAction(enterTextAction)
        
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
    
    private func imageForCase(image: UIImage) -> UIImage {
        let newSize = CGSizeMake(CGRectGetWidth(caseView.bounds), CGRectGetHeight(caseView.bounds))
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        let newImageRect = CGRectMake(0.0, 0.0, newSize.width, newSize.height)
        image.drawInRect(newImageRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.caseView.image = imageForCase(chosenImage)
        self.caseView.showBackgroundImage = true

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CaseConstructorTableViewController: PhotoLibraryCollectionViewControllerDelegate {
    func photoLibraryCollectionViewController(controller: PhotoLibraryCollectionViewController, didDoneOnImage image: UIImage) {
        self.caseView.image = imageForCase(image)
        self.caseView.showBackgroundImage = true
    }
}