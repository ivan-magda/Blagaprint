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
    @IBOutlet weak var cupImageView: UIImageView!
    @IBOutlet weak var pickImageView: UIView!
    
    /// Image picker controller to let us take/pick photo.
    private var imagePickerController: BLImagePickerController?
    
    /// Picked image by the user.
    private var pickedImage: UIImage?
    /// Rectangle of the image on the cup.
    private let pickedImageSize = CGSizeMake(185, 225)
    
    private var firstHalfImage: UIImage?
    private var secondHalfImage: UIImage?
    
    private var isLeftCup: Bool = true
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImagePickerController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadCupView(changeSide: false)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("pickImageDidPressed"))
        self.pickImageView.addGestureRecognizer(tapGestureRecognizer)
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
            self.firstHalfImage = nil
            self.secondHalfImage = nil
            
            self.reloadCupView(changeSide: false)
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
            weakSelf?.pickedImage = pickedImage
            
            // Picked image cropping
            
            let imageSize = pickedImage.size
            let halfOfWidth: CGFloat = imageSize.width / 2.0
            
            let firstHalfImageRect = CGRectMake(0, 0, halfOfWidth, imageSize.height)
            
            var croppedImage = pickedImage.croppedImage(firstHalfImageRect)
            weakSelf?.firstHalfImage = croppedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: weakSelf!.pickedImageSize, interpolationQuality: .High)
            
            let secondHalfImageRect = CGRectMake(halfOfWidth, 0, halfOfWidth, imageSize.height)
            
            croppedImage = pickedImage.croppedImage(secondHalfImageRect)
            weakSelf?.secondHalfImage = croppedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: weakSelf!.pickedImageSize, interpolationQuality: .High)
        }
    }
    
    private func reloadCupView(changeSide changeSide: Bool) {
        self.cupImageView.alpha = 0
        
        UIView.animateWithDuration(0.25) {
            if changeSide {
                if self.isLeftCup {
                    if let image = self.secondHalfImage {
                        self.cupImageView.image = Cup.imageOfCupRight(pickedImage: image, imageVisible: true)
                    } else {
                        self.cupImageView.image = Cup.imageOfCupRight()
                    }
                    self.isLeftCup = false
                } else {
                    if let image = self.firstHalfImage {
                        self.cupImageView.image = Cup.imageOfCupLeft(pickedImage: image, imageVisible: true)
                    } else {
                        self.cupImageView.image = Cup.imageOfCupLeft()
                    }
                    self.isLeftCup = true
                }
            } else {
                if self.isLeftCup {
                    if let image = self.firstHalfImage {
                        self.cupImageView.image = Cup.imageOfCupLeft(pickedImage: image, imageVisible: true)
                    } else {
                        self.cupImageView.image = Cup.imageOfCupLeft()
                    }
                } else {
                    if let image = self.secondHalfImage {
                        self.cupImageView.image = Cup.imageOfCupRight(pickedImage: image, imageVisible: true)
                    } else {
                        self.cupImageView.image = Cup.imageOfCupRight()
                    }
                }
            }
            
            self.cupImageView.alpha = 1.0
        }
    }
    
    // MARK: - Actions
    
    func pickImageDidPressed() {
        self.presentImagePickingAlertController()
    }
    
    
    @IBAction func replaceDidPressed() {
        reloadCupView(changeSide: true)
    }
}
