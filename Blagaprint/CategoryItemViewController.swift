//
//  CupViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 08.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class CategoryItemViewController: UIViewController {
    // MARK: - Types
    
    private enum SegueIdentifier: String {
        case SelectDevice
        case ColorPicking
        case TextEditing
        case PhotoLibrary
    }
    
    /// Picked image sizes for filling in the item object.
    private struct PickedImageSize {
        static let Cup = CGSizeMake(197.0, 225.0)
        static let Plate = CGSizeMake(210.0, 210.0)
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pickImageView: UIView!
    @IBOutlet weak var pickColorView: UIView!
    @IBOutlet weak var pickedColorView: UIView!
    @IBOutlet weak var addtoBagButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var placeholderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickColorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickColorViewBottomSpace: NSLayoutConstraint!
    
    /// Height value view that contains UICollectionView.
    private let placeholderViewDefaultHeightValue: CGFloat = 320.0
    
    /// Height value for view that uses for picking a photo or color and so on.
    private let actionViewHeightValue: CGFloat = 44.0
    
    /// Minimal bottom space value.
    private let minimalSpaceValue: CGFloat = 16
    
    var parseCentral: ParseCentral?
    
    /// Category of the presenting item.
    var category: Category!
    
    /// Loaded category items of the parent category.
    private var categoryItems: [CategoryItem]?
    
    /// Image picker controller to let us take/pick photo.
    private var imagePickerController: BLImagePickerController?
    
    /// Picked image by the user.
    private var pickedImage: UIImage?
    
    // Data source for collection view.
    private var images = [UIImage]()
    
    /// Inner color of cup.
    private var cupInnerColor = UIColor.whiteColor()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (self.collectionView as UIScrollView).delegate = self
        
        loadCategoryItems()
        
        reloadData()
        
        setupImagePickerController()
        setupPickedColorView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addGestureRecognizers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupScrollView()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.ColorPicking.rawValue {
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let colorPickingVC = navigationController.topViewController as! SelectBackgroundCollectionViewController!
            colorPickingVC.selectedColor = cupInnerColor
            
            colorPickingVC.didSelectColorCompletionHandler = { color in
                self.cupInnerColor = color
                self.pickedColorView.backgroundColor = color
                self.pickedColorViewUpdateBorderLayer()
            }
        }
    }
    
    // MARK: - UIAlertActions
    
    private func presentImagePickingAlertController() {
        let imagePickingAlertController = UIAlertController(title: "Выберите действие", message: nil, preferredStyle: .ActionSheet)
        
        /// Cancel action
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { action in
        }
        imagePickingAlertController.addAction(cancelAction)
        
        /// Clear action
        let clearAction = UIAlertAction(title: "Очистить", style: .Destructive) { action in
            self.pickedImage = nil
            self.reloadData()
        }
        imagePickingAlertController.addAction(clearAction)
        
        /// Photo from gallery(take photo) action
        let photoFromLibrary = UIAlertAction(title: "Медиатека", style: .Default) { action in
            if let imagePickerController = self.imagePickerController {
                imagePickerController.photoFromLibrary()
            }
        }
        imagePickingAlertController.addAction(photoFromLibrary)
        
        /// Shoot photo action
        let shoot = UIAlertAction(title: "Снять фото", style: .Default) { action in
            if let imagePickerController = self.imagePickerController {
                imagePickerController.shootPhoto()
            }
        }
        imagePickingAlertController.addAction(shoot)
        
        self.presentViewController(imagePickingAlertController, animated: true, completion: nil)
    }
    
    // MARK: - Private Helper Methods

    private func addGestureRecognizers() {
        let pickImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("pickImageDidPressed"))
        self.pickImageView.addGestureRecognizer(pickImageTapGestureRecognizer)
        
        let pickColorTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("pickColorDidPressed"))
        self.pickColorView.addGestureRecognizer(pickColorTapGestureRecognizer)
    }
    
    private func setupImagePickerController() {
        weak var weakSelf = self
        
        self.imagePickerController = BLImagePickerController(rootViewController: self) { pickedImage in
            guard weakSelf != nil else {
                return
            }
            
            weakSelf!.pickedImage = pickedImage
            weakSelf!.reloadData()
        }
    }
    
    private func setupPickedColorView() {
        self.pickedColorView.layer.cornerRadius = CGRectGetWidth(self.pickedColorView.bounds) / 2.0
        pickedColorViewUpdateBorderLayer()
    }
    
    private func pickedColorViewUpdateBorderLayer() {
        self.pickedColorView.layer.borderWidth = 0.0
        var borderColor: UIColor?
        
        if cupInnerColor == UIColor.whiteColor() {
            borderColor = UIColor.lightGrayColor()
        }
        
        if let borderColor = borderColor {
            self.pickedColorView.layer.borderWidth = 1.0
            self.pickedColorView.layer.borderColor = borderColor.CGColor
        }
    }
    
    private func setupScrollView() {
        if self.navigationController == nil {
            return
        }
        
        switch self.category.getType() {
        case .cups:
            self.placeholderViewHeightConstraint.constant = placeholderViewDefaultHeightValue
            self.pickImageViewHeightConstraint.constant = actionViewHeightValue
            self.pickColorViewHeightConstraint.constant = actionViewHeightValue
        case .plates, .frames:
            self.placeholderViewHeightConstraint.constant = placeholderViewDefaultHeightValue
            self.pickImageViewHeightConstraint.constant = actionViewHeightValue
            
            self.pickColorViewHeightConstraint.constant = 0.0
            self.pickColorView.alpha = 0.0
        default:
            break
        }
        
        setPickColorViewBottomSpace()
        
        self.scrollView.layoutIfNeeded()
    }
    
    private func setPickColorViewBottomSpace() {
        let frameHeight = CGRectGetHeight(self.view.bounds)
        let navBarHeight = CGRectGetHeight(self.navigationController!.navigationBar.bounds)
        let statusBarHeight = CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
        let cupViewHeight = self.placeholderViewHeightConstraint.constant
        var pickImageViewHeight = self.pickImageViewHeightConstraint.constant
        
        // If we hide color picking view, then we do not need to include pick image view height.
        if self.pickColorViewHeightConstraint.constant == 0 {
            pickImageViewHeight = 0.0
        }
        
        var space = frameHeight - (statusBarHeight + navBarHeight + cupViewHeight + pickImageViewHeight)
        
        // Check for minimal space.
        if space < minimalSpaceValue {
            space = minimalSpaceValue
        }
        
        self.pickColorViewBottomSpace.constant = space
    }
    
    private func reloadData() {
        reloadImages(pickedImage: pickedImage)
        self.collectionView.reloadData()
    }
    
    private func reloadImages(pickedImage pickedImage: UIImage?) {
        self.images.removeAll(keepCapacity: true)
        
        let category = self.category.getType()
        
        if let pickedImage = pickedImage {
            switch category {
                
            case .cups:
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
                
            case .plates:
                let resizedImage = pickedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: PickedImageSize.Plate, interpolationQuality: .High)
                self.images = [Plate.imageOfPlateCanvas(image: resizedImage, isPlateImageVisible: true)]
                
            case .frames:
                let frames = PhotoFrame.seedInitialFrames()
                for frame in frames {
                    images.append(frame.frameImageWithPickedImage(pickedImage))
                }
                
            default:
                break
            }
        } else {
            switch category {
                
            case .cups:
                images = [Cup.imageOfCupLeft(), Cup.imageOfCupFront(), Cup.imageOfCupRight()]
                
            case .plates:
                images = [Plate.imageOfPlateCanvas()]
                
            case .frames:
                let frames = PhotoFrame.seedInitialFrames()
                for frame in frames {
                    images.append(frame.image)
                }
                
            default:
                break
            }
        }
    }
    
    private func animateViewSelection(view: UIView) {
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            view.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2)
            }) { finished in
                if finished {
                    UIView.animateWithDuration(0.25) {
                        view.backgroundColor = UIColor.whiteColor()
                    }
                }
        }
    }
    
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
        if let image = self.pickedImage {
            let imageData = UIImageJPEGRepresentation(image, 0.9)
            if let imageData = imageData {
                if let imageFile = PFFile(data: imageData) {
                    item.image = imageFile
                }
            }
        }
        
        // Set thumbnail image of item.
        let thumbnailData = UIImagePNGRepresentation(images[0].resizedImage(images[0].size, interpolationQuality: .Low))
        if let thumbnailData = thumbnailData {
            if let thumbnailFile = PFFile(data: thumbnailData) {
                item.thumbnail = thumbnailFile
            }
        }
        
        // Set picked color.
        if self.pickColorViewHeightConstraint.constant != 0.0 {
            let colorInString = BagItem.colorToString(self.cupInnerColor)
            item.fillColor = colorInString
        }
        
        return item
    }
    
    // MARK: - Actions
    
    func pickImageDidPressed() {
        animateViewSelection(self.pickImageView)
        self.presentImagePickingAlertController()
    }
    
    func pickColorDidPressed() {
        animateViewSelection(self.pickColorView)
        self.performSegueWithIdentifier(SegueIdentifier.ColorPicking.rawValue, sender: nil)
    }
    
    @IBAction func addToBagDidPressed(sender: AnyObject) {
        if let parseCentral = self.parseCentral {
            parseCentral.saveItem(createBagItem())
        } else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: "An error occured. Please try again later.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func pageControlDidChangeValue(sender: UIPageControl) {
        let pageWidth = CGRectGetWidth(self.collectionView.bounds)
        let scrollTo = CGPointMake(pageWidth * CGFloat(sender.currentPage), 0)
        
        self.collectionView.setContentOffset(scrollTo, animated: true)
    }
    
}
// MARK: - UIScrollViewDelegate -

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

// MARK: - UICollectionView Extensions -

extension CategoryItemViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ImageCollectionViewCell
        
        let cup = images[indexPath.section]
        cell.imageView?.image = cup
        
        self.pageControl.numberOfPages = self.images.count
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Select item at section: \(indexPath.section)")
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width  = CGRectGetWidth(collectionView.bounds)
        let height: CGFloat = CGRectGetHeight(self.placeholderView.frame)
        
        return CGSizeMake(width, height)
    }
}

