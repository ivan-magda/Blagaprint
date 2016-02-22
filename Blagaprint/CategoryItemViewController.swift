//
//  CupViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 08.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit
import SVProgressHUD

class CategoryItemViewController: UIViewController {
    
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    private enum SegueIdentifier: String {
        case SelectDevice
        case ColorPicking
        case TextEditing
        case PhotoLibrary
        case PickType
        case EmbedItemSizeCollectionViewController
    }
    
    /// Use this enum for tracking selected mode of manage text alert
    /// controller.
    private enum ManageTextSelectedMode: Int {
        case Letters
        case Numbers
        case Region
    }
    
    /// Picked image sizes for filling in the item object.
    private struct PickedImageSize {
        static let Cup = CGSize(width: 197.0, height: 225.0)
        static let Plate = CGSize(width: 210.0, height: 210.0)
    }
    
    
    //--------------------------------------
    // MARK: - Properties -
    //--------------------------------------
    
    
    //--------------------------------------
    // MARK: Views
    //--------------------------------------
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var itemSizeContainerView: UIView!
    
    weak var itemSizeCollectionViewController: ItemSizeCollectionViewController?
    
    @IBOutlet weak var moreActionsView: UIView!
    @IBOutlet weak var moreActionsLabel: UILabel!
    
    @IBOutlet weak var pickTypeView: UIView!
    @IBOutlet weak var pickTypeViewDetailLabel: UILabel!
    @IBOutlet weak var pickTypeViewDetailDisclosureImageView: UIImageView!
    
    @IBOutlet weak var pickColorView: UIView!
    @IBOutlet weak var pickedColorView: UIView!
    
    @IBOutlet weak var pickCountView: UIView!
    @IBOutlet weak var pickCountViewDetailLabel: UILabel!
    
    @IBOutlet weak var placeholderViewOfPickerView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var addToBagButton: UIButton!
    
    //--------------------------------------
    // MARK: LayoutConstraints
    //--------------------------------------
    
    @IBOutlet weak var placeholderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemSizeContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControlBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var moreActionsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickTypeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickCountViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickColorViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var placeholderViewOfPickerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var placeholderViewOfPickerViewBottomSpace: NSLayoutConstraint!
    
    //--------------------------------------
    // MARK: Dimension Values
    //--------------------------------------
    
    /// Height value of view that contains UICollectionView.
    private let placeholderViewDefaultHeightValue: CGFloat = 320.0
    
    /// Minimal height value of collection view.
    private let collectionViewMinHeightValue: CGFloat = 160.0
    
    /// Maximum height value of collection view.
    private let collectionViewMaximumHeightValue: CGFloat = 320.0
    
    /// Height value for views that use for trigger an action.
    private let actionViewHeightValue: CGFloat = 44.0
    
    /// Minimal bottom space value.
    private let minimalSpaceValue: CGFloat = 72.0
    
    /// Default height of the UIPickerView.
    private let pickerViewDefaultHeightValue: CGFloat = 216.0
    
    //--------------------------------------
    // MARK: Data Service
    //--------------------------------------
    
    var dataService: DataService!
    
    /// Category of the presenting item.
    var category: FCategory!
    
    /// Loaded category items of the parent category.
    private var categoryItems: [FCategoryItem]?
    
    //--------------------------------------
    // MARK: Model
    //--------------------------------------
    
    /// Image picker controller to let us take/pick photo.
    private var imagePickerController: BLImagePickerController?
    
    /// Picked image by the user.
    private var pickedImage: UIImage?
    
    // Data source for collection view.
    private var images = [UIImage]()
    
    /// Picked color by the user.
    private var pickedColor = UIColor.whiteColor()
    
    /// True if user successfully added item to bag.
    private var didAddItemToBag = false
    
    /// Holds the index of picked item type.
    private var pickedTypeIndex = 0
    
    /// Where to place the image on t-shirt.
    private var imageLocation = TShirt.TShirtImageLocations.Front
    
    /// Determine whether picker view visible or hidden
    private var pickerViewVisible = false
    
    /// Number of the specific item that user want to buy.
    private var numberOfItems = 1
    
    //--------------------------------------
    // MARK: Manage Text of Item
    //--------------------------------------
    
    /// Set this attributes when you want to segue to TextEditingViewController.
    private var textAttributes: [TextEditingViewControllerTextFieldAttributes : Int]?
    
    /// Holds the selected text edting mode: work with numbers or letters.
    private var selectedTextEditingMode: ManageTextSelectedMode?
    
    //--------------------------------------
    // MARK: State Key Ring
    //--------------------------------------
    
    private var letters: String?
    private var numbers: String?
    private var region: String?
    
    //--------------------------------------
    // MARK: - View Life Cycle -
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupScrollView()
    }
    
    //--------------------------------------
    // MARK: - Navigation
    //--------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pick the color.
        if segue.identifier == SegueIdentifier.ColorPicking.rawValue {
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let colorPickingVC = navigationController.topViewController as! SelectBackgroundCollectionViewController!
            colorPickingVC.selectedColor = pickedColor
            
            weak var weakSelf = self
            colorPickingVC.didSelectColorCompletionHandler = { color in
                weakSelf?.pickedColor = color
                weakSelf?.pickedColorView.backgroundColor = color
                weakSelf?.pickedColorViewUpdateBorderLayer()
                
                weakSelf?.reloadData()
            }
            
            // Pick type.
        } else if segue.identifier == SegueIdentifier.PickType.rawValue {
            let pickTypeTableViewController = segue.destinationViewController as! PickTypeTableViewController
            
            pickTypeTableViewController.dataSource = self
            pickTypeTableViewController.delegate = self
            
            pickTypeTableViewController.originalTypeName = categoryItems![pickedTypeIndex].name
            
            // Text editing.
        } else if segue.identifier == SegueIdentifier.TextEditing.rawValue {
            let navigationController = segue.destinationViewController as! UINavigationController
            let textEditingViewController = navigationController.topViewController as! TextEditingViewController
            
            // Check for sended attributes and apply if necessary.
            if let attributes = self.textAttributes {
                for (key, value) in attributes {
                    switch key {
                    case .KeyboardType:
                        textEditingViewController.keyboardType = UIKeyboardType(rawValue: value)
                    case .TextLengthLimit:
                        textEditingViewController.textLengthLimit = value
                    }
                }
            }
            
            weak var weakSelf = self
            
            // Completion handler block.
            textEditingViewController.didDoneOnTextCompletionHandler = { text in
                // Detect what user has changed.
                if let selectedMode = weakSelf?.selectedTextEditingMode {
                    switch selectedMode {
                    case .Letters:
                        weakSelf?.letters = text
                    case .Numbers:
                        weakSelf?.numbers = text
                    case .Region:
                        weakSelf?.region = text
                    }
                }
                
                weakSelf?.reloadData()
            }
            
            // Embed ItemSizeCollectionViewController.
        } else if segue.identifier == SegueIdentifier.EmbedItemSizeCollectionViewController.rawValue {
            let controller = segue.destinationViewController as! ItemSizeCollectionViewController
            
            self.itemSizeCollectionViewController = controller
        }
    }
    
    //--------------------------------------
    // MARK: - Private Helper Methods -
    //--------------------------------------
    
    private func animateViewSelection(view: UIView, callback: (() -> Void)?) {
        UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            view.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2)
            }) { finished in
                if finished {
                    UIView.animateWithDuration(0.25) {
                        view.backgroundColor = UIColor.whiteColor()
                        
                        if let callback = callback {
                            callback()
                        }
                    }
                }
        }
    }
    
    private func goToShoppingCart() {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = TabItemIndex.ShoppingBagViewController.rawValue
        }
    }
    
    private func getCategoryItemType() -> FCategoryItem.CategoryItemType? {
        if let categoryItems = self.categoryItems where categoryItems.count > 0 {
            return categoryItems[pickedTypeIndex].type!
        }
        
        return nil
    }
    
    private func getItemSizes() -> [String]? {
        var sizes: [String]?
        
        guard let items = self.categoryItems where items.count > 0 else {
            return nil
        }
        
        guard self.pickedTypeIndex < items.count else {
            return nil
        }
        
        sizes = items[pickedTypeIndex].sizes
        
        guard let _ = sizes else {
            return nil
        }
        
        return sizes!.count > 0 ? sizes! : nil
    }
    
    //--------------------------------------
    // MARK: Setup
    //--------------------------------------
    
    private func setup() {
        self.title = self.category.titleName
        
        (self.collectionView as UIScrollView).delegate = self
        
        // Working with data.
        loadCategoryItems()
        reloadData()
        
        // Setup.
        setupImagePickerController()
        setupPickedColorView()
        setupAddToBagButton()
        
        addGestureRecognizers()
        
        self.pickTypeViewDetailLabel.text = nil
        
        // Hide picker view.
        self.placeholderViewOfPickerView.alpha = 0.0
        self.placeholderViewOfPickerViewHeightConstraint.constant = 0.0
        
        updateItemCountLabel()
    }
    
    private func addGestureRecognizers() {
        let pickImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("moreActionsDidPressed"))
        self.moreActionsView.addGestureRecognizer(pickImageTapGestureRecognizer)
        
        let pickColorTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("pickColorDidPressed"))
        self.pickColorView.addGestureRecognizer(pickColorTapGestureRecognizer)
        
        let pickTypeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("pickTypeDidPressed"))
        self.pickTypeView.addGestureRecognizer(pickTypeTapGestureRecognizer)
        
        let pickCountTypeGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("pickCountDidPressed"))
        self.pickCountView.addGestureRecognizer(pickCountTypeGestureRecognizer)
    }
    
    private func setupImagePickerController() {
        weak var weakSelf = self
        
        self.imagePickerController = BLImagePickerController(rootViewController: self) { pickedImage in
            weakSelf?.pickedImage = pickedImage
            weakSelf?.reloadData()
        }
    }
    
    private func setupMoreActionsLabelText() {
        if let type = getCategoryItemType() where type == FCategoryItem.CategoryItemType.stateNumberKeyRing {
            self.moreActionsLabel.text = NSLocalizedString("Text", comment: "")
        } else {
            self.moreActionsLabel.text = NSLocalizedString("Image", comment: "")
        }
    }
    
    private func setupAddToBagButton() {
        self.addToBagButton.layer.insertSublayer(AppAppearance.horizontalGreenGradientLayerForRect(self.addToBagButton.bounds), atIndex: 0)
        
        self.addToBagButton.layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.9).CGColor
        self.addToBagButton.layer.shadowOpacity = 1.0
        self.addToBagButton.layer.shadowOffset = CGSizeZero
        self.addToBagButton.layer.shadowRadius = 3.0
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
    
    private func setupPickedColorView() {
        self.pickedColorView.backgroundColor = self.pickedColor
        self.pickedColorView.layer.cornerRadius = CGRectGetWidth(self.pickedColorView.bounds) / 2.0
        
        pickedColorViewUpdateBorderLayer()
    }
    
    private func pickedColorViewUpdateBorderLayer() {
        self.pickedColorView.layer.borderWidth = 0.0
        var borderColor: UIColor?
        
        if pickedColor == UIColor.whiteColor() {
            borderColor = UIColor.lightGrayColor()
        }
        
        if let borderColor = borderColor {
            self.pickedColorView.layer.borderWidth = 1.0
            self.pickedColorView.layer.borderColor = borderColor.CGColor
        }
    }
    
    private func setupScrollView() {
        guard let _ = self.navigationController else {
            return
        }
        
        let categoryType = category.type!
        
        // Setting up the dimentions.
        
        // Collection view.
        let imageHeight = (self.images.count > 0 ? images[0].size.height : collectionViewMinHeightValue)
        if imageHeight >= collectionViewMinHeightValue && imageHeight <= collectionViewMaximumHeightValue {
            self.collectionViewHeightConstraint.constant = imageHeight
        } else if imageHeight > collectionViewMaximumHeightValue {
            self.collectionViewHeightConstraint.constant = collectionViewMaximumHeightValue
        } else if imageHeight < collectionViewMinHeightValue {
            self.collectionViewHeightConstraint.constant = collectionViewMinHeightValue
        }
        
        // Set height of container view.
        if let _ = self.getItemSizes() {
            self.itemSizeContainerViewHeightConstraint.constant = actionViewHeightValue
        } else {
            self.itemSizeContainerViewHeightConstraint.constant = 0.0
        }
        
        // Sets the placeholder view height constraint with determinated value.
        switch categoryType {
        case .cup:
            self.placeholderViewHeightConstraint.constant = placeholderViewDefaultHeightValue
        default:
            self.placeholderViewHeightConstraint.constant = collectionViewHeightConstraint.constant + itemSizeContainerViewHeightConstraint.constant + pageControl.bounds.height
        }
        
        setupPickTypeViewWithIfNeedLayout(false)
        setupMoreActionsLabelText()
        
        switch categoryType {
        case .clothes:
            self.pickColorViewHeightConstraint.constant = actionViewHeightValue
            self.pickColorView.alpha = 1.0
        default:
            self.moreActionsViewHeightConstraint.constant = actionViewHeightValue
            
            self.pickColorViewHeightConstraint.constant = 0.0
            self.pickColorView.alpha = 0.0
        }
        
        setupBottomSpaceToScrollView()
        
        UIView.animateWithDuration(0.25) {
            self.scrollView.layoutIfNeeded()
        }
    }
    
    private func setupBottomSpaceToScrollView() {
        let frameHeight = self.view.bounds.height
        let navBarHeight = self.navigationController!.navigationBar.bounds.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let placeholderViewHeight = self.placeholderViewHeightConstraint.constant
        let pickTypeViewHeight = self.pickTypeViewHeightConstraint.constant
        var pickImageViewHeight = self.moreActionsViewHeightConstraint.constant
        
        // If we hide color picking view, then we need additional space.
        if self.pickColorViewHeightConstraint.constant == 0 {
            pickImageViewHeight = 0.0
        }
        
        var space = frameHeight - (statusBarHeight + navBarHeight + placeholderViewHeight + pickImageViewHeight + pickTypeViewHeight)
        
        // Check for minimal space.
        if space < minimalSpaceValue {
            space = minimalSpaceValue
        }
        
        self.placeholderViewOfPickerViewBottomSpace.constant = space
    }
    
    private func setupPickTypeViewWithIfNeedLayout(needed: Bool) {
        func hidePickTypeView() {
            self.pickTypeViewHeightConstraint.constant = 0.0
            self.pickTypeView.alpha = 0.0
            self.pickTypeViewDetailLabel.text = nil
        }
        
        if let categoryItems = self.categoryItems {
            func setDefaultStateOfPickTypeView() {
                self.pickTypeViewHeightConstraint.constant = actionViewHeightValue
                self.pickTypeView.alpha = 1.0
                self.pickTypeViewDetailLabel.text = categoryItems[pickedTypeIndex].name
            }
            
            // Hide pick type view.
            if categoryItems.count == 0 {
                hidePickTypeView()
            } else {
                setDefaultStateOfPickTypeView()
                self.pickTypeViewDetailDisclosureImageView.image = UIImage(named: "MoreThan.png")
            }
        } else {
            hidePickTypeView()
        }
        
        if needed {
            UIView.animateWithDuration(0.25) {
                self.scrollView.layoutIfNeeded()
            }
        }
    }
    
    //--------------------------------------
    // MARK: Data
    //--------------------------------------
    
    private func reloadData() {
        reloadImages(pickedImage: pickedImage)
        
        collectionView.reloadData()
        
        if let sizes = self.getItemSizes() {
            self.itemSizeCollectionViewController?.sizes = sizes
            self.itemSizeCollectionViewController?.collectionView?.reloadData()
        }
        
        self.pageControl.numberOfPages = images.count
    }
    
    private func reloadImages(pickedImage pickedImage: UIImage?) {
        self.images.removeAll(keepCapacity: true)
        
        // Get category.
        let categoryType = category.type!
        
        // Get catgeory item.
        var categoryItem: FCategoryItem? = nil
        if let categoryItems = self.categoryItems where categoryItems.count > 0 {
            categoryItem = categoryItems[pickedTypeIndex]
        }
        
        // Set image for state number key ring and immediatly return from here.
        if let type = getCategoryItemType() where type == FCategoryItem.CategoryItemType.stateNumberKeyRing {
            let keyRing = KeyRing(selfType: .StateNumber, categoryItemType: .stateNumberKeyRing)
            self.images = [keyRing.stateNumberImage(characters: self.letters, numbers: self.numbers, region: self.region)]
            
            return
        }
        
        if let pickedImage = pickedImage {
            switch categoryType {
                
            case .cup:
                self.images = Cup.getCupImagesWithPickedImage(pickedImage)
                
            case .plate:
                let scaledImage = pickedImage.scaledImageToSize(PickedImageSize.Plate)
                self.images = [Plate.imageOfPlateCanvas(image: scaledImage, isPlateImageVisible: true)]
                
            case .photoFrame:
                let frames = PhotoFrame.seedInitialFrames()
                self.images = frames.map() { $0.frameImageWithPickedImage(pickedImage) }
                
            case .keyRing:
                var keyRings: [KeyRing]!
                
                if let categoryItem = categoryItem {
                    keyRings = KeyRing.keyRingsFromCategoryItem(categoryItem)
                } else {
                    keyRings = KeyRing.seedInitialKeyRings()
                }
                
                self.images = keyRings.map() { $0.imageOfKeyRingWithPickedImage(pickedImage) }
                
            case .clothes:
                self.images = TShirt(image: pickedImage, isImageVisible: true, imageLocation: self.imageLocation, color: pickedColor).tShirtImages()
                
            case .copyServices:
                var copyServices: [CopyServices]!
                
                if let categoryItem = categoryItem {
                    copyServices = CopyServices.copyServiceFromCategoryItem(categoryItem)
                } else {
                    copyServices = CopyServices.seedInitialServices()
                }
                
                self.images = copyServices.map() { $0.imageWithPickedImage(pickedImage) }
                
            default:
                break
            }
        } else {
            switch categoryType {
                
            case .cup:
                images = Cup.getDefaultCupImages()
                
            case .plate:
                images = [Plate.imageOfPlateCanvas()]
                
            case .photoFrame:
                let frames = PhotoFrame.seedInitialFrames()
                self.images = frames.map() { $0.image }
                
            case .keyRing:
                var keyRings: [KeyRing]!
                
                if let categoryItem = categoryItem {
                    keyRings = KeyRing.keyRingsFromCategoryItem(categoryItem)
                } else {
                    keyRings = KeyRing.seedInitialKeyRings()
                }
                
                self.images = keyRings.map() { $0.image }
                
            case .clothes:
                self.images = TShirt(isImageVisible: false, imageLocation: self.imageLocation, color: pickedColor).tShirtImages()
                
            case .copyServices:
                var copyServices: [CopyServices]!
                
                if let categoryItem = categoryItem {
                    copyServices = CopyServices.copyServiceFromCategoryItem(categoryItem)
                } else {
                    copyServices = CopyServices.seedInitialServices()
                }
                
                self.images = copyServices.map() { $0.image }
                
            default:
                break
            }
        }
    }
    
    //--------------------------------------
    // MARK: Quering
    //--------------------------------------
    
    private func loadCategoryItems() {
        category.getItemsInBackgroundWithBlock { [weak self] objects in
            if let items = objects {
                self?.categoryItems = items
                
                if let itemSizeController = self?.itemSizeCollectionViewController {
                    if let sizes = self!.getItemSizes() {
                        itemSizeController.sizes = sizes
                        itemSizeController.collectionView?.reloadData()
                    }
                }
                
                self?.setupPickTypeViewWithIfNeedLayout(true)
                self?.reloadData()
            }
        }
    }
    
    private func createBagItem() -> [String : AnyObject] {
        
        var item = [String : AnyObject]()
        
        guard let userId = User.currentUserId else {
            assert(false, "User must be logged in.")
        }
        
        // Set the user id.
        item[FBagItem.Keys.userId.rawValue] = userId
        
        // Set parent category id.
        item[FBagItem.Keys.category.rawValue] = category.key
        
        // Set the current date.
        item[FBagItem.Keys.createdAt.rawValue] = NSDate().getStringValue()
        
        // Set selected category item if it exist.
        if let categoryItems = self.categoryItems where categoryItems.count > 0 {
            item[FBagItem.Keys.categoryItem.rawValue] = categoryItems[pickedTypeIndex].key
        }
        
        // Set user picked image from media/camera.
        if let image = self.pickedImage {
            if let base64ImageString = image.base64EncodedString() {
                item[FBagItem.Keys.image.rawValue] = base64ImageString
            }
        }
        
        let pickedItemIndex = self.pageControl.currentPage
        
        // Set thumbnail image of item.
        let size = images[pickedItemIndex].size
        let thumbnailData = UIImagePNGRepresentation(images[pickedItemIndex].resizedImage(size, interpolationQuality: .Low))
        if let thumbnailData = thumbnailData {
            item[FBagItem.Keys.thumbnail.rawValue] = thumbnailData.base64EncodedStringWithOptions([])
        }
        
        // Set picked color.
        if self.pickColorViewHeightConstraint.constant != 0.0 {
            item[FBagItem.Keys.fillColor.rawValue] = FBagItem.colorToString(self.pickedColor)
        }
        
        // Set item size.
        if let selectedItemSizeIndex = self.itemSizeCollectionViewController?.selectedSizeIndexPath?.row {
            if let sizes = getItemSizes() {
                item[FBagItem.Keys.itemSize.rawValue] = sizes[selectedItemSizeIndex]
            }
        }
        
        item[FBagItem.Keys.numberOfItems.rawValue] = self.numberOfItems
        
        // FIXME: fix with the price.
        let price = 500.0
        item[FBagItem.Keys.price.rawValue] = price
        
        item[FBagItem.Keys.amount.rawValue] = price * Double(self.numberOfItems)
        
        print("BagItem dictionary created.")
        
        return item
    }
    
    //--------------------------------------
    // MARK: - Actions
    //--------------------------------------
    
    func moreActionsDidPressed() {
        animateViewSelection(moreActionsView) { [weak self] in
            if let type = self?.getCategoryItemType() where type == FCategoryItem.CategoryItemType.stateNumberKeyRing {
                self?.presentManageTextAlertController()
            } else {
                self?.presentImagePickingAlertController()
            }
        }
    }
    
    func pickColorDidPressed() {
        animateViewSelection(pickColorView) { [weak self] in
            self?.performSegueWithIdentifier(SegueIdentifier.ColorPicking.rawValue, sender: self)
        }
    }
    
    func pickTypeDidPressed() {
        self.didAddItemToBag = false
        
        animateViewSelection(pickTypeView) { [weak self] in
            self?.performSegueWithIdentifier(SegueIdentifier.PickType.rawValue, sender: self)
            self?.updateAddToBagButtonTitle()
        }
    }
    
    func pickCountDidPressed() {
        animateViewSelection(pickCountView) {
            if self.pickerViewVisible {
                self.hidePickerView()
            } else {
                self.showPickerView()
            }
        }
    }
    
    @IBAction func addToBagDidPressed(sender: AnyObject) {
        
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
    
    @IBAction func pageControlDidChangeValue(sender: UIPageControl) {
        let pageWidth = self.collectionView.bounds.width
        let scrollTo = CGPoint(x: pageWidth * CGFloat(sender.currentPage), y: 0)
        
        self.collectionView.setContentOffset(scrollTo, animated: true)
    }
    
    //--------------------------------------
    // MARK: - UIAlertActions
    //--------------------------------------
    
    private func presentAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func presentImagePickingAlertController() {
        let imagePickingAlertController = UIAlertController(title: NSLocalizedString("Choose an action", comment: "Alert action title"), message: nil, preferredStyle: .ActionSheet)
        
        /// Cancel action
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert action title"), style: .Cancel) { action in
        }
        imagePickingAlertController.addAction(cancelAction)
        
        /// Photo from gallery(take photo) action
        let photoFromLibrary = UIAlertAction(title: NSLocalizedString("Gallery", comment: "Alert action title"), style: .Default) { action in
            if let imagePickerController = self.imagePickerController {
                imagePickerController.photoFromLibrary()
            }
        }
        imagePickingAlertController.addAction(photoFromLibrary)
        
        /// Shoot photo action
        let shoot = UIAlertAction(title: NSLocalizedString("Take photo", comment: "Alert action title"), style: .Default) { action in
            if let imagePickerController = self.imagePickerController {
                imagePickerController.shootPhoto()
            }
        }
        imagePickingAlertController.addAction(shoot)
        
        // Add additional image location action.
        if self.category.type == FCategory.CategoryType.clothes {
            
            // Present next action sheet with supported locations.
            
            let imageLocation = UIAlertAction(title: NSLocalizedString("Image location", comment: "Alert action title"), style: .Default) { action in
                
                /// Nested function for data updating.
                func setImageLocationAndReloadData(location: TShirt.TShirtImageLocations) {
                    self.imageLocation = location
                    self.reloadData()
                }
                
                let imageLocationController = UIAlertController(title: NSLocalizedString("Where to place the image", comment: "Alert action title"), message: nil, preferredStyle: .ActionSheet)
                
                // Front image location action.
                imageLocationController.addAction(UIAlertAction(title: NSLocalizedString("Front", comment: "Alert action title"), style: .Default, handler: { action in
                    setImageLocationAndReloadData(TShirt.TShirtImageLocations.Front)
                }))
                
                // Behind image location action.
                imageLocationController.addAction(UIAlertAction(title: NSLocalizedString("Behind", comment: "Alert action title"), style: .Default, handler: { action in
                    setImageLocationAndReloadData(TShirt.TShirtImageLocations.Behind)
                }))
                
                // Cancel action.
                imageLocationController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert action title"), style: .Cancel, handler: nil))
                
                self.presentViewController(imageLocationController, animated: true, completion: nil)
            }
            
            imagePickingAlertController.addAction(imageLocation)
        }
        
        /// Clear action
        let clearAction = UIAlertAction(title: NSLocalizedString("Clear", comment: "Alert action title"), style: .Destructive) { action in
            self.pickedImage = nil
            self.reloadData()
        }
        imagePickingAlertController.addAction(clearAction)
        
        self.presentViewController(imagePickingAlertController, animated: true, completion: nil)
    }
    
    private func presentManageTextAlertController() {
        let manageTextAlertController = UIAlertController(title: NSLocalizedString("Choose an action", comment: "Alert action title"), message: nil, preferredStyle: .ActionSheet)
        
        // Cancel action.
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert action title"), style: .Cancel) { action in
        }
        manageTextAlertController.addAction(cancelAction)
        
        // Letters action.
        let lettersAction = UIAlertAction(title: NSLocalizedString("Letters", comment: "Alert action title"), style: .Default) { action in
            self.textAttributes = [TextEditingViewControllerTextFieldAttributes.KeyboardType : UIKeyboardType.Default.rawValue, TextEditingViewControllerTextFieldAttributes.TextLengthLimit : 3]
            self.selectedTextEditingMode = ManageTextSelectedMode.Letters
            
            self.performSegueWithIdentifier(SegueIdentifier.TextEditing.rawValue, sender: self)
        }
        manageTextAlertController.addAction(lettersAction)
        
        // Numbers action.
        let numbersAction = UIAlertAction(title: NSLocalizedString("Numbers", comment: "Alert action title"), style: .Default) { action in
            self.textAttributes = [TextEditingViewControllerTextFieldAttributes.KeyboardType : UIKeyboardType.NumberPad.rawValue, TextEditingViewControllerTextFieldAttributes.TextLengthLimit : 3]
            self.selectedTextEditingMode = ManageTextSelectedMode.Numbers
            
            self.performSegueWithIdentifier(SegueIdentifier.TextEditing.rawValue, sender: self)
        }
        manageTextAlertController.addAction(numbersAction)
        
        // Region action.
        let regionAction = UIAlertAction(title: NSLocalizedString("Region", comment: "Alert action title"), style: .Default) { action in
            self.textAttributes = [TextEditingViewControllerTextFieldAttributes.KeyboardType : UIKeyboardType.NumberPad.rawValue, TextEditingViewControllerTextFieldAttributes.TextLengthLimit : 3]
            self.selectedTextEditingMode = ManageTextSelectedMode.Region
            
            self.performSegueWithIdentifier(SegueIdentifier.TextEditing.rawValue, sender: self)
        }
        manageTextAlertController.addAction(regionAction)
        
        self.presentViewController(manageTextAlertController, animated: true, completion: nil)
    }
    
}

//--------------------------------------
// MARK: - UIScrollViewDelegate -
//--------------------------------------

extension CategoryItemViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // Calculate current page.
        if !scrollView.isKindOfClass(UICollectionView) {
            return
        } else {
            let pageWidth: CGFloat = CGRectGetWidth(self.collectionView.bounds)
            let currentPage = self.collectionView.contentOffset.x / pageWidth
            
            //let needToReloadData = pageControl.currentPage != Int(currentPage)
            
            if (0.0 != fmodf(Float(currentPage), 1.0)) {
                self.pageControl.currentPage = Int(currentPage) + 1
            } else {
                self.pageControl.currentPage = Int(currentPage)
            }
        }
    }
}

//--------------------------------------
// MARK: - UICollectionView Extensions -
//--------------------------------------

extension CategoryItemViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //--------------------------------------
    // MARK: - UICollectionViewDataSource
    //--------------------------------------
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageCollectionViewCell.cellReuseIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
        
        let cup = images[indexPath.section]
        cell.imageView?.image = cup
        
        return cell
    }
    
    //--------------------------------------
    // MARK: - UICollectionViewDelegate
    //--------------------------------------
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Did select item at section: \(indexPath.section)")
    }
    
    //--------------------------------------------
    // MARK: - UICollectionViewDelegateFlowLayout
    //--------------------------------------------
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = CGRectGetWidth(collectionView.bounds)
        let height = CGRectGetHeight(collectionView.bounds)
        
        return CGSizeMake(width, height)
    }
}

//--------------------------------------------------------
// MARK: - PickTypeTableViewControllerDataSourceProtocol -
//--------------------------------------------------------

extension CategoryItemViewController: PickTypeTableViewControllerDataSourceProtocol {
    func numberOfSections() -> Int {
        guard let items = self.categoryItems where items.count > 0 else {
            return 0
        }
        
        return 1
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return self.categoryItems!.count
    }
    
    func itemForIndexPath(indexPath: NSIndexPath) -> String {
        return self.categoryItems![indexPath.row].name
    }
    
}

//------------------------------------------------------
// MARK: - PickTypeTableViewControllerDelegateProtocol -
//------------------------------------------------------

extension CategoryItemViewController: PickTypeTableViewControllerDelegateProtocol {
    func pickTypeTableViewController(controller: PickTypeTableViewController, didSelectItem item: String, atIndexPath indexPath: NSIndexPath) {
        print("Did select item: \(item) at section: \(indexPath.section) and row: \(indexPath.row)")
        
        self.pickedTypeIndex = indexPath.row
        
        reloadImages(pickedImage: pickedImage)
        self.pageControl.numberOfPages = images.count
        self.collectionView.reloadData()
        
        setupScrollView()
        reloadData()
    }
}

//---------------------------------
// MARK: - UIPickerView Extensions -
//---------------------------------

extension CategoryItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    //---------------------------------
    // MARK: Helper Methods
    //---------------------------------
    
    private func showPickerView() {
        self.pickCountViewDetailLabel.textColor = self.view.tintColor
        
        // Select row from previous picked item.
        self.pickerView.selectRow(self.numberOfItems - 1, inComponent: 0, animated: false)
        self.pickerViewVisible = true
        
        self.scrollView.layoutIfNeeded()
        
        // Show picker view.
        UIView.animateWithDuration(0.25, animations: {
            self.placeholderViewOfPickerView.alpha = 1.0
            self.placeholderViewOfPickerViewHeightConstraint.constant = self.pickerViewDefaultHeightValue
            }, completion: { finished in
        })
        
        self.scrollView.layoutIfNeeded()
        
        // Scroll to the bottom.
        let bottomOffset = CGPoint(x: 0.0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height)
        self.scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    private func hidePickerView() {
        self.pickCountViewDetailLabel.textColor = .blackColor()
        
        self.pickerViewVisible = false
        
        self.scrollView.layoutIfNeeded()
        
        // Hide picker view.
        UIView.animateWithDuration(0.25, animations: {
            self.placeholderViewOfPickerView.alpha = 0.0
            self.placeholderViewOfPickerViewHeightConstraint.constant = 0.0
            }) { finished in
        }
        
        self.scrollView.layoutIfNeeded()
    }
    
    private func updateItemCountLabel() {
        self.pickCountViewDetailLabel.text =  "\(self.numberOfItems)"
    }
    
    //---------------------------------
    // MARK: UIPickerViewDataSource
    //---------------------------------
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1000
    }
    
    //---------------------------------
    // MARK: UIPickerViewDelagate
    //---------------------------------
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.numberOfItems = row + 1
        
        updateItemCountLabel()
    }
}

