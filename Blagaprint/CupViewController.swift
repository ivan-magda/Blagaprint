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
    private var pickedImage: UIImage?
    private var firstHalfImage: UIImage?
    private var secondHalfImage: UIImage?
    
    private var isLeftCup: Bool = true
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePickerController = BLImagePickerController(rootViewController: self) { pickedImage in
            self.pickedImage = pickedImage
            
            // Picked image cropping
            
            let imageSize = pickedImage.size
            print("Size: \(imageSize)")
            
            let halfOfWidth: CGFloat = imageSize.width / 2.0
            
            let firstHalfImageRect = CGRectMake(0, 0, halfOfWidth, imageSize.height)
            self.firstHalfImage = pickedImage.croppedImage(firstHalfImageRect)
            
            let secondHalfImageRect = CGRectMake(halfOfWidth, 0, halfOfWidth, imageSize.height)
            self.secondHalfImage = pickedImage.croppedImage(secondHalfImageRect)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.cupImageView.image = Cup.imageOfCupLeft()
        self.isLeftCup = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("pickImageDidPressed"))
        self.pickImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - UIAlertActions
    
    private func presentImagePickingAlertController() {
        let imagePickingAlertController = UIAlertController(title: "Выбор изображения", message: nil, preferredStyle: .ActionSheet)
        
        /// Cancel action
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { action in
        }
        imagePickingAlertController.addAction(cancelAction)
        
        /// Clear action
        let clearAction = UIAlertAction(title: "Очистить", style: .Destructive) { action in
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

    // MARK: - Actions
    
    func pickImageDidPressed() {
        self.presentImagePickingAlertController()
    }

    @IBAction func replaceDidPressed(sender: UIBarButtonItem) {
        self.cupImageView.alpha = 0
        
        UIView.animateWithDuration(0.25) {
            if self.isLeftCup {
                self.cupImageView.image = Cup.imageOfCupRight()
                self.isLeftCup = false
            } else {
                self.cupImageView.image = Cup.imageOfCupLeft()
                self.isLeftCup = true
            }
            
            self.cupImageView.alpha = 1.0
        }
    }
}
