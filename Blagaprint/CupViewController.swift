//
//  CupViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 08.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class CupViewController: UIViewController {
    // MARK: - Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cupPlaceholderView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pickImageView: UIView!
    @IBOutlet weak var pickColorView: UIView!
    @IBOutlet weak var pickedColorView: UIView!
    @IBOutlet weak var addtoBagButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var pickColorViewBottomSpace: NSLayoutConstraint!
    private let minimalSpaceValue: CGFloat = 16
    
    var category: Category!
    private var categoryItems: [CategoryItem]?
    
    /// Segue identifier to SelectBackgroundCollectionViewController.
    private let colorPickingSegueIdentifier = "ColorPicking"
    
    /// Image picker controller to let us take/pick photo.
    private var imagePickerController: BLImagePickerController?
    
    /// Picked image by the user.
    private var pickedImage: UIImage?
    /// Picked image size for filling in the cup.
    private let pickedImageSize = CGSizeMake(197, 225)
    
    // Data source for collection view.
    private var images = [Cup.imageOfCupLeft(), Cup.imageOfCupFront(), Cup.imageOfCupRight()]
    
    /// Inner color of cup.
    private var cupInnerColor = UIColor.whiteColor()
    
    private var activityView: ActivityView?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (self.collectionView as UIScrollView).delegate = self
        
        setupImagePickerController()
        setupPickedColorView()
        
        loadCategoryItems()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let pickImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("pickImageDidPressed"))
        self.pickImageView.addGestureRecognizer(pickImageTapGestureRecognizer)
        
        let pickColorTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("pickColorDidPressed"))
        self.pickColorView.addGestureRecognizer(pickColorTapGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupScrollView()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == colorPickingSegueIdentifier {
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
        
        setPickColorViewBottomSpace()
        self.scrollView.layoutIfNeeded()
    }
    
    private func setPickColorViewBottomSpace() {
        // Calculate height.
        let frameHeight = CGRectGetHeight(self.view.bounds)
        let navBarHeight = CGRectGetHeight(self.navigationController!.navigationBar.bounds)
        let statusBarHeight = CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
        let cupViewHeight = CGRectGetHeight(self.cupPlaceholderView.bounds)
        let pickImageViewHeight = CGRectGetHeight(self.pickImageView.bounds)
        
        var space = frameHeight - (statusBarHeight + navBarHeight + cupViewHeight + pickImageViewHeight)
        
        // Check for minimal space.
        if space < minimalSpaceValue {
            space = minimalSpaceValue
        }
        print("Bottom space value: \(space)")
        
        self.pickColorViewBottomSpace.constant = space
    }
    
    private func reloadData() {
        reloadImages(pickedImage: pickedImage)
        self.collectionView.reloadData()
    }
    
    private func reloadImages(pickedImage pickedImage: UIImage?) {
        self.images.removeAll(keepCapacity: true)
        
        if let pickedImage = pickedImage {
            // Picked image cropping
            
            let imageSize = pickedImage.size
            let fortyPercentOfWidth = imageSize.width * 0.4
            
            // Left side cup view.
            let leftSideRect = CGRectMake(0.0, 0.0, fortyPercentOfWidth, imageSize.height)
            let leftCroppedImage = pickedImage.croppedImage(leftSideRect)
            let leftSideImage = leftCroppedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: pickedImageSize, interpolationQuality: .High)
            images.append(Cup.imageOfCupLeft(pickedImage: leftSideImage, imageVisible: true))
            
            // Front side cup view.
            let frontSideRect = CGRectMake(CGRectGetWidth(leftSideRect) - (CGRectGetWidth(leftSideRect) * 0.1), 0, fortyPercentOfWidth, imageSize.height)
            let frontCroppedImage = pickedImage.croppedImage(frontSideRect)
            let frontSideImage = frontCroppedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: pickedImageSize, interpolationQuality: .High)
            images.append(Cup.imageOfCupFront(pickedImage: frontSideImage, imageVisible: true))
            
            // Right side cup view.
            let rightSideRect = CGRectMake(imageSize.width * 0.6, 0, fortyPercentOfWidth, imageSize.height)
            let rightCroppedImage = pickedImage.croppedImage(rightSideRect)
            let rightSideImage = rightCroppedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: pickedImageSize, interpolationQuality: .High)
            images.append(Cup.imageOfCupRight(pickedImage: rightSideImage, imageVisible: true))
        } else {
            images = [Cup.imageOfCupLeft(), Cup.imageOfCupFront(), Cup.imageOfCupRight()]
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
    
    // MARK: - Actions
    
    func pickImageDidPressed() {
        animateViewSelection(self.pickImageView)
        self.presentImagePickingAlertController()
    }
    
    func pickColorDidPressed() {
        animateViewSelection(self.pickColorView)
        self.performSegueWithIdentifier(colorPickingSegueIdentifier, sender: nil)
    }
    
    @IBAction func addToBagDidPressed(sender: AnyObject) {
        addToBag()
    }
    
    @IBAction func pageControlDidChangeValue(sender: UIPageControl) {
        let pageWidth = CGRectGetWidth(self.collectionView.bounds)
        let scrollTo = CGPointMake(pageWidth * CGFloat(sender.currentPage), 0)
        self.collectionView.setContentOffset(scrollTo, animated: true)
    }
    
    // MARK: - Activity Indicator
    
    private func presentActivityView() {
        let tabBarController = self.tabBarController!
        
        self.activityView = ActivityView(frame: tabBarController.view.bounds, message: NSLocalizedString("Adding...", comment: ""))
        tabBarController.view.addSubview(activityView!)
        activityView!.startAnimating()
    }
    
    private func removeActivityView(completion completion: (() -> ())?) {
        if let activityView = self.activityView {
            activityView.stopAnimating()
            activityView.removeFromSuperview()
            
            self.activityView = nil
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    // MARK: - Adding to Bag
    
    /// Adds BagItem object to Bag of the current user.
    private func addBagItemToBag(bag: Bag, user: BlagaprintUser) {
        // Create BagItem and save it to Parse.
        let item = BagItem()
        item.userId = user.objectId!
        item.category = self.category.objectId!
        
        if let categoryItems = self.categoryItems where categoryItems.count > 0 {
            item.categoryItem = categoryItems.first!.objectId!
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
        let thumbnailData = UIImageJPEGRepresentation(images[0], 0.6)
        if let thumbnailData = thumbnailData {
            if let thumbnailFile = PFFile(data: thumbnailData) {
                item.thumbnail = thumbnailFile
            }
        }
        
        let colorInString = BagItem.colorToString(self.cupInnerColor)
        item.color = colorInString
        
        // Save item to Parse datastore.
        item.saveInBackgroundWithBlock() { (succeeded, error) in
            if let error = error {
                print(error.localizedDescription)
                
                self.removeActivityView(completion: nil)
            } else if succeeded {
                // Add this item to bag of the current user.
                bag.addUniqueObject(item.objectId!, forKey: Bag.Keys.items.rawValue)
                bag.saveInBackgroundWithBlock() { (succeeded, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        
                        self.removeActivityView(completion: nil)
                    } else if succeeded {
                        // Present successfull alert controller.
                        self.removeActivityView() {
                            let alert = UIAlertController(title: NSLocalizedString("Succeeded", comment: ""), message: "Item successfully added to bag", preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                self.removeActivityView(completion: nil)
            }
        }
    }
    
    private func addToBag() {
        if let user = BlagaprintUser.currentUser() {
            
            presentActivityView()
            
            // Find Bag of the user.
            let bagQuery = PFQuery(className: BagClassName)
            bagQuery.whereKey(Bag.Keys.userId.rawValue, equalTo: user.objectId!)
            bagQuery.findObjectsInBackgroundWithBlock() { (bag, error) in
                if let error = error {
                    print(error.localizedDescription)
                    
                    self.removeActivityView(completion: nil)
                } else if let bag = bag as? [Bag] {
                    assert(bag.count <= 1, "Bag must be unique for each user!")
                    
                    // Bag not exist, create it for the user.
                    if bag.count == 0 {
                        let bag = Bag()
                        bag.userId = user.objectId!
                        bag.saveInBackgroundWithBlock() { (succeeded, error) in
                            if let error = error {
                                print(error.localizedDescription)
                                
                                self.removeActivityView(completion: nil)
                            } else if succeeded {
                                self.addBagItemToBag(bag, user: user)
                            } else {
                                self.removeActivityView(completion: nil)
                            }
                        }
                        // Bag already exist and we find it.
                    } else {
                        self.addBagItemToBag(bag[bag.count - 1], user: user)
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: NSLocalizedString("You are not registred", comment: "Alert title when user not registered"), message: NSLocalizedString("If you want add item to bag, please login in your account", comment: "Alert message when user not logged in and want add item to bag"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Log In", comment: ""), style: .Default, handler: { (action) in
                self.presentViewController(LoginViewController(), animated: true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - UIScrollViewDelegate -

extension CupViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if !scrollView.isKindOfClass(UICollectionView) {
            return
        } else {
            let pageWidth: CGFloat = CGRectGetWidth(self.collectionView.bounds)
            let currentPage = self.collectionView.contentOffset.x / pageWidth
            
            if (0.0 != fmodf(Float(currentPage), 1.0)) {
                self.pageControl.currentPage = Int(currentPage) + 1
            } else {
                self.pageControl.currentPage = Int(currentPage)
            }
        }
    }
}

// MARK: - CollectionView Extensions -

extension CupViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
        let height: CGFloat = CGRectGetHeight(self.cupPlaceholderView.frame)
        
        return CGSizeMake(width, height)
    }
}

