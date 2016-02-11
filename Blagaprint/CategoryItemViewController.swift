//
//  CupViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 08.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

let CategoryItemViewControllerDidAddItemToBagNotification = "CategoryItemViewControllerDidAddItemToBagNotification"

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
    @IBOutlet weak var pickColorView: UIView!
    @IBOutlet weak var pickTypeView: UIView!
    @IBOutlet weak var pickTypeViewDetailLabel: UILabel!
    @IBOutlet weak var pickTypeViewDetailDisclosureImageView: UIImageView!
    @IBOutlet weak var pickedColorView: UIView!
    @IBOutlet weak var addToBagButton: UIButton!
    
    //--------------------------------------
    // MARK: LayoutConstraints
    //--------------------------------------
    
    @IBOutlet weak var placeholderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemSizeContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControlBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreActionsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickColorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickTypeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickColorViewBottomSpace: NSLayoutConstraint!
    
    //--------------------------------------
    // MARK: Dimension Values
    //--------------------------------------
    
    /// Height value of view that contains UICollectionView.
    private let placeholderViewDefaultHeightValue: CGFloat = 320.0
    
    /// Height value for views that use for trigger an action.
    private let actionViewHeightValue: CGFloat = 44.0
    
    /// Minimal bottom space value.
    private let minimalSpaceValue: CGFloat = 72.0
    
    /// Minimal height value of collection view.
    private let collectionViewMinHeightValue: CGFloat = 160.0
    
    /// Maximum height value of collection view.
    private let collectionViewMaximumHeightValue: CGFloat = 320.0
    
    //--------------------------------------
    // MARK: Parse
    //--------------------------------------
    
    var parseCentral: ParseCentral?
    
    /// Category of the presenting item.
    var category: Category!
    
    /// Loaded category items of the parent category.
    private var categoryItems: [CategoryItem]?
    
    //--------------------------------------
    // MARK: Other
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
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
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
    
    private func getCategoryItemType() -> CategoryItem.CategoryItemType? {
        if let categoryItems = self.categoryItems where categoryItems.count > 0 {
            return categoryItems[pickedTypeIndex].getType()
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
        
        return sizes!.count > 0 ? sizes! : nil
    }
    
    //--------------------------------------
    // MARK: Setup
    //--------------------------------------
    
    private func addGestureRecognizers() {
        let pickImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("moreActionsDidPressed"))
        self.moreActionsView.addGestureRecognizer(pickImageTapGestureRecognizer)
        
        let pickColorTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("pickColorDidPressed"))
        self.pickColorView.addGestureRecognizer(pickColorTapGestureRecognizer)

        let pickTypeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("pickTypeDidPressed"))
        self.pickTypeView.addGestureRecognizer(pickTypeTapGestureRecognizer)
    }
    
    private func setupImagePickerController() {
        weak var weakSelf = self
        
        self.imagePickerController = BLImagePickerController(rootViewController: self) { pickedImage in
            weakSelf?.pickedImage = pickedImage
            weakSelf?.reloadData()
        }
    }
    
    private func setupMoreActionsLabelText() {
        if let type = getCategoryItemType() where type == CategoryItem.CategoryItemType.stateNumberKeyRing {
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
        
        let categoryType = self.category.getType()
        
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
        
        setPickColorViewBottomSpace()
        
        UIView.animateWithDuration(0.25) {
            self.scrollView.layoutIfNeeded()
        }
    }
    
    private func setPickColorViewBottomSpace() {
        let frameHeight = self.view.bounds.height
        let navBarHeight = self.navigationController!.navigationBar.bounds.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let placeholderViewHeight = self.placeholderViewHeightConstraint.constant
        let itemSizesViewHeight = self.itemSizeContainerViewHeightConstraint.constant
        let pickTypeViewHeight = self.pickTypeViewHeightConstraint.constant
        var pickImageViewHeight = self.moreActionsViewHeightConstraint.constant
        
        // If we hide color picking view, then we need additional space.
        if self.pickColorViewHeightConstraint.constant == 0 {
            pickImageViewHeight = 0.0
        }
        
        var space = frameHeight - (statusBarHeight + navBarHeight + placeholderViewHeight + itemSizesViewHeight + pickImageViewHeight + pickTypeViewHeight)
        
        // Check for minimal space.
        if space < minimalSpaceValue {
            space = minimalSpaceValue
        }
        
        self.pickColorViewBottomSpace.constant = space
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
            } else if categoryItems.count == 1 {
                setDefaultStateOfPickTypeView()
                self.pickTypeViewDetailDisclosureImageView.image = UIImage()
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
        let category = self.category.getType()
        
        // Get catgeory item.
        var categoryItem: CategoryItem? = nil
        if let categoryItems = self.categoryItems where categoryItems.count > 0 {
            categoryItem = categoryItems[pickedTypeIndex]
        }
        
        // Set image for state number key ring and immediatly return from here.
        if let type = getCategoryItemType() where type == CategoryItem.CategoryItemType.stateNumberKeyRing {
            let keyRing = KeyRing(selfType: .StateNumber, categoryItemType: .stateNumberKeyRing)
            self.images = [keyRing.stateNumberImage(characters: self.letters, numbers: self.numbers, region: self.region)]
            
            return
        }
        
        if let pickedImage = pickedImage {
            switch category {
                
            case .cup:
                // Picked image cropping
                let imageSize = pickedImage.size
                let fortyPercentOfWidth = imageSize.width * 0.4
                
                // Left side cup view.
                let leftSideRect = CGRectMake(0.0, 0.0, fortyPercentOfWidth, imageSize.height)
                let leftCroppedImage = pickedImage.croppedImage(leftSideRect)
                let leftSideImage = leftCroppedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: PickedImageSize.Cup, interpolationQuality: .High)
                images.append(Cup.imageOfCupLeft(pickedImage: leftSideImage, imageVisible: true))
                
                // Front side cup view.
                let frontSideRect = CGRectMake(CGRectGetWidth(leftSideRect) - (CGRectGetWidth(leftSideRect) * 0.1), 0, fortyPercentOfWidth, imageSize.height)
                let frontCroppedImage = pickedImage.croppedImage(frontSideRect)
                let frontSideImage = frontCroppedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: PickedImageSize.Cup, interpolationQuality: .High)
                images.append(Cup.imageOfCupFront(pickedImage: frontSideImage, imageVisible: true))
                
                // Right side cup view.
                let rightSideRect = CGRectMake(imageSize.width * 0.6, 0, fortyPercentOfWidth, imageSize.height)
                let rightCroppedImage = pickedImage.croppedImage(rightSideRect)
                let rightSideImage = rightCroppedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: PickedImageSize.Cup, interpolationQuality: .High)
                images.append(Cup.imageOfCupRight(pickedImage: rightSideImage, imageVisible: true))
                
            case .plate:
                let resizedImage = pickedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: PickedImageSize.Plate, interpolationQuality: .High)
                self.images = [Plate.imageOfPlateCanvas(image: resizedImage, isPlateImageVisible: true)]
                
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
                
            default:
                break
            }
        } else {
            switch category {
                
            case .cup:
                images = [Cup.imageOfCupLeft(), Cup.imageOfCupFront(), Cup.imageOfCupRight()]
                
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
                
            default:
                break
            }
        }
    }
    
    //--------------------------------------
    // MARK: Parse
    //--------------------------------------
    
    private func loadCategoryItems() {
        weak var weakSelf = self
        self.category.getItemsInBackgroundWithBlock() { (items, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let items = items {
                weakSelf?.categoryItems = items
                
                if let itemSizeController = weakSelf?.itemSizeCollectionViewController {
                    if let sizes = weakSelf!.getItemSizes() {
                        itemSizeController.sizes = sizes
                        itemSizeController.collectionView?.reloadData()
                    }
                }
                
                weakSelf?.setupPickTypeViewWithIfNeedLayout(true)
                weakSelf?.reloadData()
            }
        }
    }
    
    private func createBagItem() -> BagItem {
        // Create BagItem and save it to Parse.
        let item = BagItem()
        
        // Set user ID.
        if let user = BlagaprintUser.currentUser() {
            item.userId = user.objectId!
        }
        
        // Set parent category ID.
        item.category = self.category.objectId!
        
        // Set selected category item if it exist.
        if let categoryItems = self.categoryItems where categoryItems.count > 0 {
            item.categoryItem = categoryItems[pickedTypeIndex].objectId!
        }
        
        // Set user picked image from media/camera.
        if let image = self.pickedImage {
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            if let imageData = imageData {
                if let imageFile = PFFile(data: imageData) {
                    item.image = imageFile
                }
            }
        }
        
        let pickedItemIndex = self.pageControl.currentPage
        
        // Set thumbnail image of item.
        let size = images[pickedItemIndex].size
        let thumbnailData = UIImagePNGRepresentation(images[pickedItemIndex].resizedImage(size, interpolationQuality: .Low))
        if let thumbnailData = thumbnailData {
            if let thumbnailFile = PFFile(data: thumbnailData) {
                item.thumbnail = thumbnailFile
            }
        }
        
        // Set picked color.
        if self.pickColorViewHeightConstraint.constant != 0.0 {
            item.fillColor = BagItem.colorToString(self.pickedColor)
        }
        
        // Set item size.
        if let selectedItemSizeIndex = self.itemSizeCollectionViewController?.selectedSizeIndexPath?.row {
            if let sizes = getItemSizes() {
                item.itemSize = sizes[selectedItemSizeIndex]
            }
        }
        
        // TODO: fix with price selection.
        item.price = 500.0
        
        print("Created BagItem: \(item)")
        
        return item
    }
    
    //--------------------------------------
    // MARK: - Actions
    //--------------------------------------
    
    func moreActionsDidPressed() {
        weak var weakSelf = self
        
        animateViewSelection(moreActionsView) {
            if let type = weakSelf?.getCategoryItemType() where type == CategoryItem.CategoryItemType.stateNumberKeyRing {
                weakSelf!.presentManageTextAlertController()
            } else {
                weakSelf?.presentImagePickingAlertController()
            }
        }
    }
    
    func pickColorDidPressed() {
        animateViewSelection(pickColorView) {
            self.performSegueWithIdentifier(SegueIdentifier.ColorPicking.rawValue, sender: self)
        }
    }
    
    func pickTypeDidPressed() {
        self.didAddItemToBag = false
        
        animateViewSelection(pickTypeView) {
            self.performSegueWithIdentifier(SegueIdentifier.PickType.rawValue, sender: self)
            
            self.updateAddToBagButtonTitle()
        }
    }
    
    @IBAction func addToBagDidPressed(sender: AnyObject) {
        // Go to shopping cart.
        if didAddItemToBag {
            goToShoppingCart()
            
            // Add item to bag.
        } else if let parseCentral = self.parseCentral {
            let item = createBagItem()
            
            parseCentral.saveItem(item, success: {
                self.didAddItemToBag = true
                
                // Post notification.
                NSNotificationCenter.defaultCenter().postNotificationName(CategoryItemViewControllerDidAddItemToBagNotification, object: item)
                
                // Present success alert controller.
                let alert = UIAlertController(title: NSLocalizedString("Successfully", comment: ""), message: NSLocalizedString("Item successfully added to bag. Would you like go to shopping cart?", comment: "Saved successfully item alert message"), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Go", comment: ""), style: .Default, handler: { (action) in
                    self.goToShoppingCart()
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                
                self.updateAddToBagButtonTitle()
                
                // Update badge value.
                ParseCentral.updateBagTabBarItemBadgeValue()
                }, failure: { (error) in
                    self.didAddItemToBag = false
                    
                    self.presentAlertWithTitle(NSLocalizedString("Error", comment: ""), message: error?.localizedDescription ?? NSLocalizedString("An error occured. Please try again later.", comment: "Failure alert message"))
                    
                    self.updateAddToBagButtonTitle()
            })
        } else {
            self.didAddItemToBag = false
            
            presentAlertWithTitle(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("An error occured. Please try again later.", comment: "Failure alert message"))
            
            self.updateAddToBagButtonTitle()
        }
    }
    
    @IBAction func pageControlDidChangeValue(sender: UIPageControl) {
        let pageWidth = CGRectGetWidth(self.collectionView.bounds)
        let scrollTo = CGPointMake(pageWidth * CGFloat(sender.currentPage), 0)
        
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
        if self.category.type == Category.CategoryType.clothes.rawValue {
            
            // Present next action sheet with supported locations.
            
            let imageLocation = UIAlertAction(title: NSLocalizedString("Image location", comment: "Alert action title"), style: .Default) { action in
                
                /// Nested function for data updating.
                func setImageLocationAndReloadData(location: TShirt.TShirtImageLocations) {
                    self.imageLocation = location
                    self.reloadData()
                }
                
                let imageLocationController = UIAlertController(title: NSLocalizedString("Where to place the image", comment: ""), message: nil, preferredStyle: .ActionSheet)
                
                // Front image location action.
                imageLocationController.addAction(UIAlertAction(title: NSLocalizedString("Front", comment: ""), style: .Default, handler: { action in
                    setImageLocationAndReloadData(TShirt.TShirtImageLocations.Front)
                }))
                
                // Behind image location action.
                imageLocationController.addAction(UIAlertAction(title: NSLocalizedString("Behind", comment: ""), style: .Default, handler: { action in
                    setImageLocationAndReloadData(TShirt.TShirtImageLocations.Behind)
                }))
                
                // Cancel action.
                imageLocationController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
                
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

