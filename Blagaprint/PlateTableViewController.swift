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
    weak var plateView: PlateView?
    
    /// Size of the plate view image.
    var plateViewImageSize: CGSize {
        return CGSizeMake(210.0, 210.0)
    }
    
    /// Image picker controller to let us take/pick photo.
    var imagePickerController: BLImagePickerController?
    
    // MARK: - View Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        self.imagePickerController = BLImagePickerController(rootViewController: self) {
            pickedImage in
            if let plateView = self.plateView {
                plateView.image = pickedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: self.plateViewImageSize, interpolationQuality: .High)
                plateView.showImage = true
            }
        }
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
            if let plateView = self.plateView {
                plateView.alpha = 0.0
                UIView.animateWithDuration(0.45, animations: {
                    plateView.image = nil
                    plateView.showImage = false
                    plateView.alpha = 1.0
                    }, completion: nil)
            }
        }
        imagePickingSelectionAlertController.addAction(clearAction)
        
        /// Photo from gallery(take photo) action
        let photoFromLibrary = UIAlertAction(title: "Медиатека", style: .Default) { (action) in
            if let imagePickerController = self.imagePickerController {
                imagePickerController.photoFromLibrary()
            }
        }
        imagePickingSelectionAlertController.addAction(photoFromLibrary)
        
        /// Shoot photo
        let shoot = UIAlertAction(title: "Снять фото", style: .Default) { (action) in
            if let imagePickerController = self.imagePickerController {
                imagePickerController.shootPhoto()
            }
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
