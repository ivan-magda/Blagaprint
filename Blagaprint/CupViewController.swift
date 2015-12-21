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
    @IBOutlet weak var addtoBagButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var addToBagButtonVerticalSpaceConstraint: NSLayoutConstraint!
    private let minimalVerticalSpace: CGFloat = 16
    
    /// Image picker controller to let us take/pick photo.
    private var imagePickerController: BLImagePickerController?
    
    /// Picked image by the user.
    private var pickedImage: UIImage?
    /// Picked side view image size.
    private let pickedSideViewImageSize = CGSizeMake(185, 225)
    /// Picked front view image size.
    private let pickedFrontViewImageSize = CGSizeMake(196.5, 220)
    
    // Data source for collection view.
    private var images = [Cup.imageOfCupLeft(), Cup.imageOfCupFront(), Cup.imageOfCupRight()]
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (self.collectionView as UIScrollView).delegate = self
        
        setupImagePickerController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("pickImageDidPressed"))
        self.pickImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupScrollView()
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
    
    private func setupScrollView() {
        if self.navigationController == nil {
            return
        }
        
        setupVerticalSpaceForAddToBagButton()
        
        self.scrollView.layoutIfNeeded()
    }
    
    private func setupVerticalSpaceForAddToBagButton() {
        // Calculate height.
        let frameHeight = CGRectGetHeight(self.view.bounds)
        let navBarHeight = CGRectGetHeight(self.navigationController!.navigationBar.bounds)
        let statusBarHeight = CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
        let cupViewHeight = CGRectGetHeight(self.cupPlaceholderView.bounds)
        let pickImageViewHeight = CGRectGetHeight(self.pickImageView.bounds)
        let addToBagButtonHeight = CGRectGetHeight(self.addtoBagButton.bounds)
        
        var verticalSpace = frameHeight - (statusBarHeight + navBarHeight + cupViewHeight + pickImageViewHeight + addToBagButtonHeight)

        // Check for minimal space.
        if verticalSpace < minimalVerticalSpace {
            verticalSpace = minimalVerticalSpace
        }
        
        print("Vertical space: \(verticalSpace)")
        
        self.addToBagButtonVerticalSpaceConstraint.constant = verticalSpace
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
            let halfOfWidth: CGFloat = imageSize.width / 2.0
            
            // Left side cup view.
            let leftSideRect = CGRectMake(0, 0, halfOfWidth, imageSize.height)
            var croppedImage = pickedImage.croppedImage(leftSideRect)
            let leftSideImage = croppedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: pickedSideViewImageSize, interpolationQuality: .High)
            images.append(Cup.imageOfCupLeft(pickedImage: leftSideImage, imageVisible: true))
            
            // Front side cup view.
            let frontSideRect = CGRectMake(halfOfWidth, 0, halfOfWidth, imageSize.height)
            croppedImage = pickedImage.croppedImage(frontSideRect)
            let frontSideImage = croppedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: pickedFrontViewImageSize, interpolationQuality: .High)
            images.append(Cup.imageOfCupFront(pickedImage: frontSideImage, imageVisible: true))
            
            // Right side cup view.
            let rightSideRect = CGRectMake(halfOfWidth, 0, halfOfWidth, imageSize.height)
            croppedImage = pickedImage.croppedImage(rightSideRect)
            let rightSideImage = croppedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: pickedSideViewImageSize, interpolationQuality: .High)
            images.append(Cup.imageOfCupRight(pickedImage: rightSideImage, imageVisible: true))
        } else {
            images = [Cup.imageOfCupLeft(), Cup.imageOfCupFront(), Cup.imageOfCupRight()]
        }
    }
    
    // MARK: - Actions
    
    func pickImageDidPressed() {
        self.presentImagePickingAlertController()
    }
    
    @IBAction func addToBagDidPressed(sender: AnyObject) {
        print("Add to Bag did pressed")
    }
    
    @IBAction func pageControlDidChangeValue(sender: UIPageControl) {
        let pageWidth = CGRectGetWidth(self.collectionView.bounds)
        let scrollTo = CGPointMake(pageWidth * CGFloat(sender.currentPage), 0)
        self.collectionView.setContentOffset(scrollTo, animated: true)
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
        return 3
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

