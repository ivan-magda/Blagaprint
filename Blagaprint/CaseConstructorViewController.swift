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
    
    private enum SegueIdentifier: String {
        case SelectDevice
        case ColorPicking
        case TextEditing
        case PhotoLibrary
    }
    
    private enum CellTypes: Int {
        case Device
        case Background
        case Text
    }
    
    private enum ColorSelectionType: String {
        case CaseBackground
        case TextColor
    }
    
    // MARK: - Properties
    
    /// Case view.
    @IBOutlet weak var caseView: CaseView!
    
    /// Case view width constraint.
    @IBOutlet weak var caseViewWidthConstraint: NSLayoutConstraint!
    
    /// Device label.
    @IBOutlet weak var deviceLabel: UILabel!
    
    /// Default supported device.
    var device: Device!
    
    /// Case view size value.
    var caseViewSize: CGSize {
        return CGSizeMake(CGRectGetWidth(self.caseView.bounds), CGRectGetHeight(self.caseView.bounds))
    }
    
    /// Image picker controller to let us take/pick photo.
    let imagePickerController: UIImagePickerController = UIImagePickerController()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = Device.iPhone5()
        
        // The required delegate to get a photo back to the app.
        imagePickerController.delegate = self
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.SelectDevice.rawValue {
            let selectDeviceViewController = segue.destinationViewController as! SelectDeviceTableViewController
            selectDeviceViewController.originalDevice = device
            
            // Call back when SelectDeviceTableVC did select device.
            weak var weakSelf = self
            selectDeviceViewController.didSelectDeviceClosure = { (selectedDevice: Device) in
                weakSelf?.device = selectedDevice
                
                // Update table header view frame.
                var tableHeaderViewHeight: CGFloat = 0.0
                var caseViewWidth: CGFloat = 0.0
                if selectedDevice.name == Device.iPhone4().name ||
                    selectedDevice.name == Device.galaxyS4Mini().name ||
                    selectedDevice.name == Device.galaxyS5Mini().name ||
                    selectedDevice.name == Device.galaxyA3().name ||
                    selectedDevice.name == Device.galaxyA5().name ||
                    selectedDevice.name == Device.sonyXperiaZ1Compact().name ||
                    selectedDevice.name == Device.sonyXperiaZ2Compact().name ||
                    selectedDevice.name == Device.sonyXperiaZ3Compact().name {
                        tableHeaderViewHeight = 380.0
                        caseViewWidth = 220.0
                } else if selectedDevice.name == Device.iPhone5().name ||
                    selectedDevice.name == Device.galaxyS3().name ||
                    selectedDevice.name == Device.galaxyA7().name {
                        tableHeaderViewHeight = 400.0
                        caseViewWidth = 220.0
                } else if selectedDevice.name == Device.iPhone6().name ||
                    selectedDevice.name == Device.galaxyS4().name {
                        tableHeaderViewHeight = 420.0
                        caseViewWidth = 240.0
                } else if selectedDevice.name == Device.iPhone6Plus().name {
                    tableHeaderViewHeight = 440.0
                    caseViewWidth = 260.0
                } else if selectedDevice.name == Device.galaxyS5().name ||
                    selectedDevice.name == Device.galaxyS6().name ||
                    selectedDevice.name == Device.galaxyS6Edge().name ||
                    selectedDevice.name == Device.galaxyNote2().name  ||
                    selectedDevice.name == Device.galaxyNote3().name  ||
                    selectedDevice.name == Device.galaxyNote4().name  ||
                    selectedDevice.name == Device.sonyXperiaZ1().name ||
                    selectedDevice.name == Device.sonyXperiaZ2().name ||
                    selectedDevice.name == Device.sonyXperiaZ3().name ||
                    selectedDevice.name == Device.xiaomiMi4().name    ||
                    selectedDevice.name == Device.lenovoS850().name {
                        tableHeaderViewHeight = 440.0
                        caseViewWidth = 240
                }
                
                let tableView = weakSelf?.tableView
                let newFrame = CGRectMake(tableView!.bounds.origin.x, tableView!.bounds.origin.y, CGRectGetWidth(tableView!.bounds), tableHeaderViewHeight)
                
                weakSelf?.view.layoutIfNeeded()
                
                self.caseViewWidthConstraint.constant = caseViewWidth
                
                tableView?.tableHeaderView?.alpha = 0.0
                UIView.animateWithDuration(0.45, delay: 0.1, options: .CurveEaseInOut, animations: { () in
                    tableView?.tableHeaderView?.frame = newFrame
                    tableView?.tableHeaderView = tableView?.tableHeaderView
                    tableView?.tableHeaderView?.alpha = 1.0
                    }, completion: nil)
                
                // Present selected device.
                weakSelf?.caseView.device = selectedDevice
                weakSelf?.deviceLabel.text = weakSelf?.device.name
            }
        } else if segue.identifier == SegueIdentifier.ColorPicking.rawValue {
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
        } else if segue.identifier == SegueIdentifier.TextEditing.rawValue {
            let navigationController = segue.destinationViewController as! UINavigationController
            let textEditingVC = navigationController.topViewController as! TextEditingViewController
            textEditingVC.text = caseView.text
            
            // Change text on case.
            weak var weakSelf = self
            textEditingVC.didDoneOnTextCompletionHandler = { (text) in
                weakSelf?.caseView.text = text
            }
        } else if segue.identifier == SegueIdentifier.PhotoLibrary.rawValue {
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
    
    @IBAction func doneButtonDidPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - UIAlertActions
    
    private func presentSelectBackgroundAlertController() {
        let backgroundSelectionAlertController = UIAlertController(title: "Выберите фон", message: nil, preferredStyle: .ActionSheet)
        
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
            weakSelf?.performSegueWithIdentifier(SegueIdentifier.ColorPicking.rawValue, sender: type)
        }
        backgroundSelectionAlertController.addAction(backgroundAction)
        
        // Images library action
        let imagesLibraryAction = UIAlertAction(title: "Библиотека изображений", style: .Default, handler: { (action) -> Void in
            weakSelf?.performSegueWithIdentifier(SegueIdentifier.PhotoLibrary.rawValue, sender: nil)
        })
        backgroundSelectionAlertController.addAction(imagesLibraryAction)
        
        self.presentViewController(backgroundSelectionAlertController, animated: true, completion: nil)
    }
    
    private func presentManageTextAlertController() {
        let manageTextAlertController = UIAlertController(title: "Редактирование текста", message: nil, preferredStyle: .ActionSheet)
        
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
            weakSelf!.performSegueWithIdentifier(SegueIdentifier.ColorPicking.rawValue, sender: type)
        }
        manageTextAlertController.addAction(selectTextColorAction)
        
        // Enter text action
        let enterTextAction = UIAlertAction(title: "Ввести текст", style: .Default) { (action) -> Void in
            self.performSegueWithIdentifier(SegueIdentifier.TextEditing.rawValue, sender: nil)
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
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.caseView.image = UIImage.resizedImage(chosenImage, newSize: caseViewSize)
        self.caseView.showBackgroundImage = true
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CaseConstructorTableViewController: PhotoLibraryCollectionViewControllerDelegate {
    func photoLibraryCollectionViewController(controller: PhotoLibraryCollectionViewController, didDoneOnImage image: UIImage) {
        self.caseView.image = UIImage.resizedImage(image, newSize: caseViewSize)
        self.caseView.showBackgroundImage = true
    }
}