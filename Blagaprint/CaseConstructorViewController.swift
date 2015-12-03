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
    var imagePickerController: BLImagePickerController?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = Device.iPhone5()
        
        self.imagePickerController = BLImagePickerController(rootViewController: self) {
            pickedImage in
            self.setImageToCaseView(pickedImage)
        }
    }
    
    // MARK: - Private
    
    private func setImageToCaseView(image: UIImage) {
        self.caseView.image = UIImage.resizedImage(image, newSize: caseViewSize)
        self.caseView.showBackgroundImage = true
    }
    
    // MARK: Animations
    
    private func animateCaseView(delay: NSTimeInterval) {
        let tableView = self.tableView
        
        tableView.tableHeaderView?.alpha = 0.0
        UIView.animateWithDuration(0.45, delay: delay, options: .CurveEaseInOut, animations: {
            tableView.tableHeaderView?.alpha = 1.0
            }, completion: nil)
    }
    
    private func animateCaseViewWithNewFrame(newFrame: CGRect) {
        let tableView = self.tableView
        
        tableView.tableHeaderView?.alpha = 0.0
        UIView.animateWithDuration(0.45, delay: 0.1, options: .CurveEaseInOut, animations: { () in
            tableView.tableHeaderView?.frame = newFrame
            tableView.tableHeaderView = tableView.tableHeaderView
            tableView.tableHeaderView?.alpha = 1.0
            }, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.SelectDevice.rawValue {
            let selectDeviceViewController = segue.destinationViewController as! SelectDeviceTableViewController
            selectDeviceViewController.originalDevice = device
            
            // Call back when SelectDeviceTableVC did select device.
            selectDeviceViewController.didSelectDeviceClosure = { (selectedDevice: Device) in
                self.device = selectedDevice
                
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
                
                let tableView = self.tableView
                let newFrame = CGRectMake(tableView.bounds.origin.x, tableView.bounds.origin.y, CGRectGetWidth(tableView.bounds), tableHeaderViewHeight)
                
                self.view.layoutIfNeeded()
                
                self.caseViewWidthConstraint.constant = caseViewWidth
                self.animateCaseViewWithNewFrame(newFrame)
                
                // Present selected device.
                self.caseView.device = selectedDevice
                self.deviceLabel.text = self.device.name
            }
        } else if segue.identifier == SegueIdentifier.ColorPicking.rawValue {
            let navigationController = segue.destinationViewController as! UINavigationController
            let selectBackgroundVC = navigationController.topViewController as! SelectBackgroundCollectionViewController
            
            // Change case/text color when new color picked.
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
                        self.caseView.fillColor = color
                        self.caseView.showBackgroundImage = false
                    })
                } else if textColorType {
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.caseView.textColor = color
                    })
                }
            }
        } else if segue.identifier == SegueIdentifier.TextEditing.rawValue {
            let navigationController = segue.destinationViewController as! UINavigationController
            let textEditingVC = navigationController.topViewController as! TextEditingViewController
            textEditingVC.text = caseView.text
            
            // Change text on case.
            textEditingVC.didDoneOnTextCompletionHandler = { text in
                self.animateCaseView(0.1)
                self.caseView.text = text
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
        
        /// Cancel action
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { action in
        }
        backgroundSelectionAlertController.addAction(cancelAction)
        
        /// Clear action
        let clearAction = UIAlertAction(title: "Очистить", style: .Destructive) { action in
            self.animateCaseView(0.0)
            self.caseView.image = UIImage()
            self.caseView.showBackgroundImage = false
            self.caseView.fillColor = UIColor.whiteColor()
        }
        backgroundSelectionAlertController.addAction(clearAction)
        
        /// Photo from gallery(take photo) action
        let photoFromLibrary = UIAlertAction(title: "Медиатека", style: .Default) { action in
            if let imagePickerController = self.imagePickerController {
                imagePickerController.photoFromLibrary()
            }
        }
        backgroundSelectionAlertController.addAction(photoFromLibrary)
        
        /// Shoot photo action
        let shoot = UIAlertAction(title: "Снять фото", style: .Default) { action in
            if let imagePickerController = self.imagePickerController {
                imagePickerController.shootPhoto()
            }
        }
        backgroundSelectionAlertController.addAction(shoot)
        
        /// Background library action
        let backgroundAction = UIAlertAction(title: "Палитра", style: .Default) { action in
            let type = ColorSelectionType.CaseBackground.rawValue
            self.performSegueWithIdentifier(SegueIdentifier.ColorPicking.rawValue, sender: type)
        }
        backgroundSelectionAlertController.addAction(backgroundAction)
        
        /// Images library action
        let imagesLibraryAction = UIAlertAction(title: "Библиотека изображений", style: .Default, handler: { action in
            self.performSegueWithIdentifier(SegueIdentifier.PhotoLibrary.rawValue, sender: nil)
        })
        backgroundSelectionAlertController.addAction(imagesLibraryAction)
        
        self.presentViewController(backgroundSelectionAlertController, animated: true, completion: nil)
    }
    
    private func presentManageTextAlertController() {
        let manageTextAlertController = UIAlertController(title: "Редактирование текста", message: nil, preferredStyle: .ActionSheet)
        
        /// Remove text action
        let removeTextAction = UIAlertAction(title: "Очистить", style: .Destructive) { action in
            UIView.animateWithDuration(0.45, animations: {
                self.caseView.text = ""
            })
        }
        manageTextAlertController.addAction(removeTextAction)
        
        /// Cancel action
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { action in
        }
        manageTextAlertController.addAction(cancelAction)
        
        /// Select text color action
        let selectTextColorAction = UIAlertAction(title: "Цвет", style: .Default) { action in
            let type = ColorSelectionType.TextColor.rawValue
            self.performSegueWithIdentifier(SegueIdentifier.ColorPicking.rawValue, sender: type)
        }
        manageTextAlertController.addAction(selectTextColorAction)
        
        /// Enter text action
        let enterTextAction = UIAlertAction(title: "Ввести текст", style: .Default) { action in
            self.performSegueWithIdentifier(SegueIdentifier.TextEditing.rawValue, sender: nil)
        }
        manageTextAlertController.addAction(enterTextAction)
        
        self.presentViewController(manageTextAlertController, animated: true, completion: nil)
    }
}

extension CaseConstructorTableViewController: PhotoLibraryCollectionViewControllerDelegate {
    func photoLibraryCollectionViewController(controller: PhotoLibraryCollectionViewController, didDoneOnImage image: UIImage) {
        setImageToCaseView(image)
    }
}