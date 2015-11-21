//
//  FrameConstructorTableViewController.swift
//  Blagaprint
//
//  Created by Niko on 18.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class FrameConstructorTableViewController: UITableViewController {
    // MARK: - Types
    
    private enum CellIdentifier: String {
        case ImagePickingCell
        case DescriptionCell
        case CollectionViewCell
        case FrameItemCell
    }
    
    // MARK: - Properties
    
    weak var collectionView: FrameItemColectionView!
    weak var pageControl: UIPageControl!
    
    weak var currentPhotoFrame: PhotoFrameView!
    
    /// Image picker controller to let us take/pick photo.
    let imagePickerController: UIImagePickerController = UIImagePickerController()
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        handleScrollInScrollView(scrollView)
    }
    
    private func handleScrollInScrollView(scrollView: UIScrollView) {
        if !scrollView.isKindOfClass(FrameItemColectionView) {
            return
        } else {
            let pageWidth: CGFloat = CGRectGetWidth(self.collectionView.bounds)
            let currentPage = self.collectionView.contentOffset.x / pageWidth
            
            let needToReloadData = pageControl.currentPage != Int(currentPage)
            
            if (0.0 != fmodf(Float(currentPage), 1.0)) {
                self.pageControl.currentPage = Int(currentPage) + 1
            } else {
                self.pageControl.currentPage = Int(currentPage)
            }
            
            if needToReloadData {
                reloadDescriptionCell()
            }
        }
    }
    
    private func reloadDescriptionCell() {
        let descriptionIndexPath = NSIndexPath(forRow: 1, inSection: 1)
        self.tableView.reloadRowsAtIndexPaths([descriptionIndexPath], withRowAnimation: .Automatic)
    }

    // MARK: - UITableView
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.CollectionViewCell.rawValue) as! CollectionTableViewCell
            self.collectionView = cell.collectionView
            self.pageControl = cell.pageControl
            self.pageControl.numberOfPages = self.collectionView.numberOfSections()
            
            return cell
        } else {
            if indexPath.row == 0 {
                return tableView.dequeueReusableCellWithIdentifier(CellIdentifier.ImagePickingCell.rawValue) as! ImagePickingTableViewCell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.DescriptionCell.rawValue) as! DescriptionTableViewCell
                cell.descriptionLabel.text = "Text may refer to:\nText & Talk (formerly Text), an academic journal \nText (literary theory), any object that can be read\nTextbook, a book of instruction any branch of study"
                
                return cell
            }
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row == 0 {
            return indexPath
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 0 {
            presentImagePickingAlertController()
        }
    }
    
    // MARK: - UIAlertActions
    
    private func presentImagePickingAlertController() {
        let imagePickingSelectionAlertController = UIAlertController(title: "Выберите изображение", message: nil, preferredStyle: .ActionSheet)
        
        weak var weakSelf = self
        
        /// Cancel action
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (action) -> Void in
        }
        imagePickingSelectionAlertController.addAction(cancelAction)
        
        /// Photo from gallery(take photo) action
        let photoFromLibrary = UIAlertAction(title: "Медиатека", style: .Default) { (action) -> Void in
            weakSelf!.photoFromLibrary()
        }
        imagePickingSelectionAlertController.addAction(photoFromLibrary)
        
        /// Shoot photo
        let shoot = UIAlertAction(title: "Снять фото", style: .Default) { (action) -> Void in
            weakSelf!.shootPhoto()
        }
        imagePickingSelectionAlertController.addAction(shoot)
        
        self.presentViewController(imagePickingSelectionAlertController, animated: true, completion: nil)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func imagePickingButtonPressed(sender: UIButton) {
        presentImagePickingAlertController()
    }
    
    @IBAction func pageControlDidChangeValue(sender: UIPageControl) {
        let pageWidth = CGRectGetWidth(self.collectionView.bounds)
        let scrollTo = CGPointMake(pageWidth * CGFloat(sender.currentPage), 0)
        self.collectionView.setContentOffset(scrollTo, animated: true)
        
        reloadDescriptionCell()
    }
}

// MARK: - Image Picking Extension

extension FrameConstructorTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Private helper methods
    
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
        imagePickerController.delegate = self
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
    
    private func imageForPhotoFrame(image: UIImage) -> UIImage {
        let newSize = CGSizeMake(189, 132)
        
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
        
        self.currentPhotoFrame.image = imageForPhotoFrame(chosenImage)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - CollectionView Extensions

extension FrameConstructorTableViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 6
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.FrameItemCell.rawValue, forIndexPath: indexPath) as! FrameItemCollectionViewCell
        
        self.currentPhotoFrame = cell.photoFrame
        
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        let color: UIColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        cell.backgroundColor = color
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Select item at section: \(indexPath.section)")
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let insets = FrameItemCollectionViewCell.leftSectionInset + FrameItemCollectionViewCell.rightSectionInset
        let width  = CGRectGetWidth(collectionView.bounds) - insets
        let height: CGFloat = FrameItemCollectionViewCell.height
        
        return CGSizeMake(width, height)
    }
}
