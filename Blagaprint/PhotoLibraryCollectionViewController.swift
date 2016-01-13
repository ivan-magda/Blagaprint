//
//  PhotoLibraryCollectionViewController.swift
//  Blagaprint
//
//  Created by Niko on 16.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

//----------------------------------------------------------------
// MARK: - PhotoLibraryCollectionViewControllerDelegate Protocol -
//----------------------------------------------------------------

protocol PhotoLibraryCollectionViewControllerDelegate {
    func photoLibraryCollectionViewController(controller: PhotoLibraryCollectionViewController, didDoneOnImage image: UIImage)
}

//-----------------------------------------------
// MARK: - PhotoLibraryCollectionViewController -
//-----------------------------------------------

class PhotoLibraryCollectionViewController: UICollectionViewController {
    //--------------------------------------
    // MARK: Properties
    //--------------------------------------
 
    /// PhotoLibraryItemCollectionViewCell reuse identifier.
    private let reuseIdentifier = "PhotoLibraryCell"
    
    /// PhotoLibraryCollectionViewController delegate object.
    var delegate: PhotoLibraryCollectionViewControllerDelegate?
    
    /// Photo library images.
    private var images: [UIImage]!
    
    /// Image that user select.
    private var selectedImage: UIImage?
    
    //--------------------------------------
    // MARK: - View Life Cycle
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        images = [UIImage(named: "3dWallpaper.jpg")!, UIImage(named: "FunnyAnimals.jpg")!, UIImage(named: "wallpaper.jpg")!]
    }

    //--------------------------------------
    // MARK: - UICollectionView -
    //--------------------------------------
    
    //--------------------------------------
    // MARK: UICollectionViewDataSource
    //--------------------------------------

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoLibraryItemCollectionViewCell
        cell.imageView.image = images[indexPath.row]
        cell.imageView.layer.cornerRadius = CGRectGetWidth(cell.imageView.bounds) / CGFloat(2.0)
        cell.imageView.clipsToBounds = true
        cell.imageView.layer.borderWidth = 5.0
        
        if selectedImage == images[indexPath.row] {
            cell.imageView.layer.borderColor = AppAppearance.AppColors.tuna.CGColor
        } else {
            cell.imageView.layer.borderColor = UIColor.clearColor().CGColor
        }
    
        return cell
    }

    //--------------------------------------
    // MARK: UICollectionViewDelegate
    //--------------------------------------
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.reloadData()
        selectedImage = images[indexPath.row]
    }

    //--------------------------------------
    // MARK: - IBActions
    //--------------------------------------
    
    @IBAction func cancelButtonDidPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonDidPressed(sender: UIBarButtonItem) {
        delegate?.photoLibraryCollectionViewController(self, didDoneOnImage: selectedImage!)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
