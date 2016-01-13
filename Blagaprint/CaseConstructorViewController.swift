//
//  CaseConstructorViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 11.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class CaseConstructorTableViewController: UITableViewController {
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
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
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    /// Case view.
    @IBOutlet weak var caseView: CaseView!
    
    /// Case view width constraint.
    @IBOutlet weak var caseViewWidthConstraint: NSLayoutConstraint!
    
    /// Device label.
    @IBOutlet weak var deviceLabel: UILabel!
    
    var parseCentral: ParseCentral?
    
    /// Category of the presenting item.
    var category: Category!
    
    /// Loaded category items of the parent category.
    private var categoryItems: [CategoryItem]?
    
    /// Default supported device.
    private var device: Device!
    
    /// Picked image by the user.
    private var pickedImage: UIImage?
    
    /// Case view size value.
    var caseViewSize: CGSize {
        return CGSizeMake(CGRectGetWidth(self.caseView.bounds), CGRectGetHeight(self.caseView.bounds))
    }
    
    /// Image picker controller to let us take/pick photo.
    var imagePickerController: BLImagePickerController?
    
    private var addToBagButton: UIButton?
    
    private let addToBagButtonHeight: CGFloat = 56.0
    
    //--------------------------------------
    // MARK: - View Life Cycle
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.category.titleName
        
        device = Device.iPhone5()
        
        self.imagePickerController = BLImagePickerController(rootViewController: self) {
            pickedImage in
            self.pickedImage = pickedImage
            self.setImageToCaseView(pickedImage)
        }
        
        // Adds content inset to bottom.
        let scrollView = self.view as! UIScrollView
        scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, addToBagButtonHeight - 0.5, 0.0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setupAddToBagButton()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.addToBagButton?.removeFromSuperview()
    }
    
    //--------------------------------------
    // MARK: - Private
    //--------------------------------------
    
    private func loadCategoryItems() {
        weak var weakSelf = self
        self.category.getItemsInBackgroundWithBlock() { (items, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let items = items {
                weakSelf?.categoryItems = items
            }
        }
    }
    
    private func setImageToCaseView(image: UIImage) {
        self.caseView.image = UIImage.resizedImage(image, newSize: caseViewSize)
        self.caseView.showBackgroundImage = true
    }
    
    //--------------------------------------
    // MARK: Animations
    //--------------------------------------
    
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
    
    //--------------------------------------
    // MARK: - Add to Bag
    //--------------------------------------
    
    private func setupAddToBagButton() {
        if self.addToBagButton == nil {
            let width = CGRectGetWidth(self.view.bounds)
            let y = CGRectGetHeight(self.navigationController!.view.bounds) - addToBagButtonHeight
            let addToBagButton = UIButton(frame: CGRectMake(0, y, width, addToBagButtonHeight))
            addToBagButton.setTitle(NSLocalizedString("Add to Bag", comment: ""), forState: .Normal)
            addToBagButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            addToBagButton.titleLabel?.font = UIFont.systemFontOfSize(19.0)
            addToBagButton.backgroundColor = UIColor(red: 76.0 / 255.0, green: 217.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0)
            addToBagButton.addTarget(self, action: Selector("addToBag"), forControlEvents: UIControlEvents.TouchUpInside)
            self.addToBagButton = addToBagButton
        }
        
        self.navigationController?.view.addSubview(self.addToBagButton!)
    }
    
    private func createBagItem() -> BagItem {
        // Create BagItem and save it to Parse.
        let item = BagItem()
        
        if let user = BlagaprintUser.currentUser() {
            item.userId = user.objectId!
        }
        
        item.category = self.category.objectId!
        
        if let categoryItems = self.categoryItems where categoryItems.count > 0 {
            item.categoryItem = categoryItems[0].objectId!
        }
        
        // Set user picked image from media/camera.
        if self.caseView.showBackgroundImage == true {
            if let image = self.pickedImage {
                let imageData = UIImageJPEGRepresentation(image, 0.9)
                if let imageData = imageData {
                    if let imageFile = PFFile(data: imageData) {
                        item.image = imageFile
                    }
                }
            }
        }
        
        // Set thumbnail image of item.
        let image = self.caseView.getCaseImage()
        let size = CGSizeMake(image.size.width / 2.0, image.size.height / 2.0)
        let resizedImage = image.resizedImage(size, interpolationQuality: .Low)
        let thumbnailData = UIImagePNGRepresentation(resizedImage)
        if let thumbnailData = thumbnailData {
            if let thumbnailFile = PFFile(data: thumbnailData) {
                item.thumbnail = thumbnailFile
            }
        }
        
        // Set colors.
        item.fillColor = BagItem.colorToString(self.caseView.fillColor)
        item.textColor = BagItem.colorToString(self.caseView.textColor)
        
        // Set device.
        item.device = self.device.descriptionFromDevice()
        
        // Set text.
        item.text = self.caseView.text
        
        return item
    }
    
    
    func addToBag() {
        if let parseCentral = self.parseCentral {
            parseCentral.saveItem(createBagItem())
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: "An error occured. Please try again later.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //--------------------------------------
    // MARK: - Navigation
    //--------------------------------------
    
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
                        self.pickedImage = nil
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
    
    //--------------------------------------
    // MARK: - UITableView -
    //--------------------------------------
    
    //--------------------------------------
    // MARK: UITableViewDelegate
    //--------------------------------------
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == CellTypes.Background.rawValue {
            presentSelectBackgroundAlertController()
        } else if indexPath.row == CellTypes.Text.rawValue {
            presentManageTextAlertController()
        }
    }
    
    //--------------------------------------
    // MARK: - IBActions
    //--------------------------------------
    
    @IBAction func selectBackgroundDidPressed(sender: UIButton) {
        presentSelectBackgroundAlertController()
    }
    
    @IBAction func selectTextDidPressed(sender: UIButton) {
        presentManageTextAlertController()
    }
    
    //--------------------------------------
    // MARK: - UIAlertActions
    //--------------------------------------
    
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
            self.pickedImage = nil
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

//-------------------------------------------------------
// MARK: - PhotoLibraryCollectionViewControllerDelegate -
//-------------------------------------------------------

extension CaseConstructorTableViewController: PhotoLibraryCollectionViewControllerDelegate {
    func photoLibraryCollectionViewController(controller: PhotoLibraryCollectionViewController, didDoneOnImage image: UIImage) {
        setImageToCaseView(image)
        self.pickedImage = image
    }
}