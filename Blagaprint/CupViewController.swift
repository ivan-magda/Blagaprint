//
//  CupViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 08.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class CupViewController: UIViewController {

    @IBOutlet weak var wholeImageView: UIImageView!
    
    @IBOutlet weak var firstPartImageView: UIImageView!
    
    @IBOutlet weak var secondPartImageView: UIImageView!
    
    /// Image picker controller to let us take/pick photo.
    private var imagePickerController: BLImagePickerController?
    private var firstHalfImage:  UIImage?
    private var secondHalfImage: UIImage?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePickerController = BLImagePickerController(rootViewController: self) { image in
            self.wholeImageView.image = image
            
            // Picked image cropping
            
            let imageSize = image.size
            print("Size: \(imageSize)")
            
            let halfOfWidth: CGFloat = imageSize.width / 2.0
            
            let firstHalfImageRect = CGRectMake(0, 0, halfOfWidth, imageSize.height)
            self.firstHalfImage = image.croppedImage(firstHalfImageRect)
            self.firstPartImageView.image = self.firstHalfImage
            
            let secondHalfImageRect = CGRectMake(halfOfWidth, 0, halfOfWidth, imageSize.height)
            self.secondHalfImage = image.croppedImage(secondHalfImageRect)
            self.secondPartImageView.image = self.secondHalfImage
        }
    }

    @IBAction func imageButtonDidPressed(sender: UIBarButtonItem) {
        if let imagePickerController = self.imagePickerController {
            imagePickerController.photoFromLibrary()
        }
    }
}
