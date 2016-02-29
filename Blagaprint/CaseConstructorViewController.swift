//
//  CaseConstructorViewController.swift
//  Blagaprint
//
//  Created by Ivan Magda on 11.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit
import SVProgressHUD

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
    
    var dataService: DataService!
    
    /// Category of the presenting item.
    var category: FCategory!
    
    /// Loaded category items of the parent category.
    private var categoryItems: [FCategoryItem]?
    
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
    
    private let addToBagButtonHeight: CGFloat = 49.0
    
    /// True if user successfully added item to bag.
    private var didAddItemToBag = false
    
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
        category.getItemsInBackgroundWithBlock { [weak self] objects in
            if let items = objects {
                self?.categoryItems = items
            }
        }
    }
    
    private func setImageToCaseView(image: UIImage) {
        self.caseView.image = image.scaledImageToSize(caseViewSize)
        self.caseView.showBackgroundImage = true
    }
    
    private func presentAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func setBagActionButtonTitle(title: String) {
        self.addToBagButton?.setTitle(title, forState: .Normal)
    }
    
    private func goToShoppingCart() {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = TabItemIndex.ShoppingBagViewController.rawValue
        }
    }
    
    private func updateAddToBagButtonTitle() {
        func setBagActionButtonTitle(title: String) {
            self.addToBagButton?.setTitle(title, forState: .Normal)
        }
        
        if didAddItemToBag {
            setBagActionButtonTitle(NSLocalizedString("Go to Shopping Cart", comment: ""))
        } else {
            setBagActionButtonTitle(NSLocalizedString("Add to Bag", comment: ""))
        }
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
            addToBagButton.backgroundColor = UIColor.clearColor()
            addToBagButton.addTarget(self, action: Selector("addToBag"), forControlEvents: UIControlEvents.TouchUpInside)
            
            // Add a gradient layer.
            addToBagButton.layer.insertSublayer(AppAppearance.horizontalGreenGradientLayerForRect(addToBagButton.bounds), atIndex: 0)
            
            // Setup shadow layer.
            addToBagButton.layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.9).CGColor
            addToBagButton.layer.shadowOpacity = 1.0
            addToBagButton.layer.shadowOffset = CGSizeZero
            addToBagButton.layer.shadowRadius = 3.0
            
            self.addToBagButton = addToBagButton
        }
        
        self.navigationController?.view.addSubview(self.addToBagButton!)
    }
    
    private func createBagItem() -> [String: AnyObject] {
        var item = [String : AnyObject]()
        
        guard let userId = User.currentUserId else {
            assert(false, "User must be logged in.")
        }
        
        // Set the user id.
        item[FBagItem.Key.UserId.rawValue] = userId
        
        // Set parent category id.
        item[FBagItem.Key.Category.rawValue] = category.key
        
        // Set the current date.
        item[FBagItem.Key.CreatedAt.rawValue] = NSDate().getStringValue()
        
        // Set selected category item if it exist.
        if let categoryItems = categoryItems where categoryItems.count > 0 {
            item[FBagItem.Key.CategoryItem.rawValue] = categoryItems[0].key
        }
        
        // Set user picked image from media/camera.
        if self.caseView.showBackgroundImage == true {
            if let image = pickedImage {
                if let base64ImageString = image.base64EncodedString() {
                    item[FBagItem.Key.Image.rawValue] = base64ImageString
                }
            }
        }
        
        // Set thumbnail image of item.
        let image = caseView.getCaseImage()
        let size = image.size
        let thumbnailData = UIImagePNGRepresentation(image.resizedImage(size, interpolationQuality: .Low))
        if let thumbnailData = thumbnailData {
            item[FBagItem.Key.Thumbnail.rawValue] = thumbnailData.base64EncodedStringWithOptions([])
        }
        
        
        // Set colors.
        item[FBagItem.Key.FillColor.rawValue] = FBagItem.colorToString(caseView.fillColor)
        item[FBagItem.Key.TextColor.rawValue] = FBagItem.colorToString(caseView.textColor)
        
        item[FBagItem.Key.NumberOfItems.rawValue] = 1
        
        // FIXME: fix with the price.
        let price = 750.0
        item[FBagItem.Key.Price.rawValue] = price
        item[FBagItem.Key.Amount.rawValue] = price
        
        // Set device.
        item[FBagItem.Key.Device.rawValue] = device.descriptionFromDevice()
        
        // Set text.
        item[FBagItem.Key.Text.rawValue] = caseView.text
        
        print("BagItem dictionary created.")
        
        return item
    }
    
    func addToBag() {
        // For adding item to bag, user must be logged in.
        // Present an alert that inform user about this.
        
        guard dataService.isUserLoggedIn == true else {
            let alert = UIAlertController(title: NSLocalizedString("You are not registred", comment: "Alert title when user not registered"), message: NSLocalizedString("If you want add item to bag, please login in your account", comment: "Alert message when user not logged in and want add item to bag"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Log In", comment: ""), style: .Default, handler: { (action) in
                LoginViewController.presentInController(self)
            }))
            
            presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        // If the item has already been added to bag, go to shopping cart.
        if didAddItemToBag {
            goToShoppingCart()
        } else {
            // DataService must be reachable for adding item to bag.
            guard dataService.reachability.isReachable() == true else {
                presentAlertWithTitle(NSLocalizedString("Offline", comment: "DataService is not reachable alert title"), message: NSLocalizedString("Server is not reachable. Please, check your internet connection and try again.", comment: "DataService is not reachable alert message"))
                return
            }
            
            // Adding item to the user bag.
            SVProgressHUD.showWithStatus(NSLocalizedString("Adding...", comment: ""))
            DataService.showNetworkIndicator()
            
            // Create the new item.
            let item = createBagItem()
            
            dataService.saveItem(item, success: { [weak self] in
                self?.didAddItemToBag = true
                
                SVProgressHUD.showSuccessWithStatus(NSLocalizedString("Added", comment: ""))
                DataService.hideNetworkIndicator()
                
                // Post notification.
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.CategoryItemViewControllerDidAddItemToBagNotification, object: item)
                
                self?.updateAddToBagButtonTitle()
                
                self?.dataService.updateBagBadgeValue()
                }, failure: { [weak self] (error) in
                    
                    if let error = error {
                        print("Failed to save item. Error: \(error.localizedDescription)")
                    }
                    
                    self?.didAddItemToBag = false
                    
                    SVProgressHUD.showErrorWithStatus(NSLocalizedString("Failed", comment: ""))
                    DataService.hideNetworkIndicator()
                    
                    self?.updateAddToBagButtonTitle()
                })
        }
    }
    
    //--------------------------------------
    // MARK: - Navigation
    //--------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        didAddItemToBag = false
        updateAddToBagButtonTitle()
        
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
        let backgroundSelectionAlertController = UIAlertController(title: NSLocalizedString("Choose background", comment: "Action sheet title"), message: nil, preferredStyle: .ActionSheet)
        
        /// Cancel action.
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert action title"), style: .Cancel) { action in
        }
        backgroundSelectionAlertController.addAction(cancelAction)
        
        /// Photo from gallery(take photo) action.
        let photoFromLibrary = UIAlertAction(title: NSLocalizedString("Gallery", comment: "Alert action title"), style: .Default) { action in
            if let imagePickerController = self.imagePickerController {
                imagePickerController.photoFromLibrary()
            }
        }
        backgroundSelectionAlertController.addAction(photoFromLibrary)
        
        /// Shoot photo action.
        let shoot = UIAlertAction(title: NSLocalizedString("Take photo", comment: "Alert action title"), style: .Default) { action in
            if let imagePickerController = self.imagePickerController {
                imagePickerController.shootPhoto()
            }
        }
        backgroundSelectionAlertController.addAction(shoot)
        
        /// Background library action.
        let backgroundAction = UIAlertAction(title: NSLocalizedString("Palette", comment: "Alert action title"), style: .Default) { action in
            let type = ColorSelectionType.CaseBackground.rawValue
            self.performSegueWithIdentifier(SegueIdentifier.ColorPicking.rawValue, sender: type)
        }
        backgroundSelectionAlertController.addAction(backgroundAction)
        
        /// Images library action.
        let imagesLibraryAction = UIAlertAction(title: NSLocalizedString("Image library", comment: "Alert action title"), style: .Default, handler: { action in
            self.performSegueWithIdentifier(SegueIdentifier.PhotoLibrary.rawValue, sender: nil)
        })
        backgroundSelectionAlertController.addAction(imagesLibraryAction)
        
        /// Clear action.
        let clearAction = UIAlertAction(title: NSLocalizedString("Clear", comment: "Alert action title"), style: .Destructive) { action in
            self.animateCaseView(0.0)
            self.caseView.image = UIImage()
            self.caseView.showBackgroundImage = false
            self.pickedImage = nil
        }
        backgroundSelectionAlertController.addAction(clearAction)
        
        self.presentViewController(backgroundSelectionAlertController, animated: true, completion: nil)
    }
    
    private func presentManageTextAlertController() {
        let manageTextAlertController = UIAlertController(title: NSLocalizedString("Text editing", comment: "Action sheet title"), message: nil, preferredStyle: .ActionSheet)
        
        /// Cancel action.
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert action title"), style: .Cancel) { action in
        }
        manageTextAlertController.addAction(cancelAction)
        
        /// Select text color action.
        let selectTextColorAction = UIAlertAction(title: NSLocalizedString("Color", comment: "Alert action title"), style: .Default) { action in
            let type = ColorSelectionType.TextColor.rawValue
            self.performSegueWithIdentifier(SegueIdentifier.ColorPicking.rawValue, sender: type)
        }
        manageTextAlertController.addAction(selectTextColorAction)
        
        /// Enter text action.
        let enterTextAction = UIAlertAction(title: NSLocalizedString("Enter a text", comment: "Alert action title"), style: .Default) { action in
            self.performSegueWithIdentifier(SegueIdentifier.TextEditing.rawValue, sender: nil)
        }
        manageTextAlertController.addAction(enterTextAction)
        
        /// Remove text action.
        let removeTextAction = UIAlertAction(title: NSLocalizedString("Clear", comment: "Alert action title"), style: .Destructive) { action in
            UIView.animateWithDuration(0.45, animations: {
                self.caseView.text = ""
            })
        }
        manageTextAlertController.addAction(removeTextAction)
        
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