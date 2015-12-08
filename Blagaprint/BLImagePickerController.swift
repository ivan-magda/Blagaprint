//
//  BLImagePickerController.swift
//  Blagaprint
//
//  Created by Иван Магда on 03.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class BLImagePickerController: NSObject {
    // MARK: - Properties
    
    /// Image picker controller to let us take/pick photo.
    private var imagePickerController = UIImagePickerController()
    
    /// Controller in that image picker controller presenting.
    let rootViewController: UIViewController
    
    /// Did finish picking image completion handler.
    var didFinishPickingImage: ((UIImage) -> ())?
    
    // MARK: - Init
    
    init(rootViewController: UIViewController, didFinishPickingImage completionHandler:(UIImage) -> ()) {
        self.rootViewController = rootViewController
        self.didFinishPickingImage = completionHandler
        
        super.init()
        
        self.imagePickerController.delegate = self
    }
}

// MARK: - Private Helper Methods
extension BLImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func noCamera() {
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        
        self.rootViewController.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    /// Get a photo from the library.
    func photoFromLibrary() {
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.modalPresentationStyle = .FullScreen
        
        self.rootViewController.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    /// Take a picture, check if we have a camera first.
    func shootPhoto() {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePickerController.allowsEditing = false
            imagePickerController.sourceType = .Camera
            imagePickerController.cameraCaptureMode = .Photo
            imagePickerController.modalPresentationStyle = .FullScreen
            
            self.rootViewController.presentViewController(imagePickerController, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            if let didFinishPickingImage = self.didFinishPickingImage {
                if let pickedImage = pickedImage {
                    didFinishPickingImage(pickedImage)
                }
            }
            
            self.rootViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.rootViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
