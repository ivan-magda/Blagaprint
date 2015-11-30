//
//  PlateTableViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 30.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class PlateTableViewController: UITableViewController {
    // MARK: - Types
    
    private enum CellIdentifier: String {
        case ImagePickingCell
        case PlateCell
    }
    
    // MARK: - Properties
    
    /// Plate view.
    weak var plateView: PlateView!
    
    /// Image picker controller to let us take/pick photo.
    let imagePickerController: UIImagePickerController = UIImagePickerController()
    
    // MARK: - View Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
    }
    
    // MARK: - UITableView
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.PlateCell.rawValue) as! PlateTableViewCell
            self.plateView = cell.plateView
            
            return cell
        } else {
            return tableView.dequeueReusableCellWithIdentifier(CellIdentifier.ImagePickingCell.rawValue) as! ImagePickingTableViewCell
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row == 0 {
            return nil
        }
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 1 {
            presentImagePickingAlertController()
        }
    }
    
    // MARK: - UIAlertActions
    
    private func presentImagePickingAlertController() {
        let imagePickingSelectionAlertController = UIAlertController(title: "Выберите действие", message: nil, preferredStyle: .ActionSheet)
        
        /// Cancel action
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (action) in
        }
        imagePickingSelectionAlertController.addAction(cancelAction)
        
        /// Clear action
        let clearAction = UIAlertAction(title: "Очистить", style: .Destructive) { (action) in
        }
        imagePickingSelectionAlertController.addAction(clearAction)
        
        /// Photo from gallery(take photo) action
        let photoFromLibrary = UIAlertAction(title: "Медиатека", style: .Default) { (action) in
            self.photoFromLibrary()
        }
        imagePickingSelectionAlertController.addAction(photoFromLibrary)
        
        /// Shoot photo
        let shoot = UIAlertAction(title: "Снять фото", style: .Default) { (action) in
            self.shootPhoto()
        }
        imagePickingSelectionAlertController.addAction(shoot)
        
        self.presentViewController(imagePickingSelectionAlertController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func imagePickingButtonPressed(sender: UIButton) {
        presentImagePickingAlertController()
    }
}

// MARK: - Image Picking Extension

extension PlateTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Private Helper Methods
    
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
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
