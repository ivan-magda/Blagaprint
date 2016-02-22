//
//  ChangePasswordTableViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 12.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordTableViewController: UITableViewController {
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    private enum TextFieldTag: Int {
        case currentPassword = 200
        case newPassword
        case repeatNewPassword
    }
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var currentPasswordTextFiled: UITextField!
    @IBOutlet weak var newPasswordTextFiled: UITextField!
    @IBOutlet weak var repeatNewPasswordTextField: UITextField!
    @IBOutlet weak var saveActivityIndicator: UIActivityIndicatorView!
    
    private let currentPasswordIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    private let newPasswordIndexPath = NSIndexPath(forRow: 1, inSection: 0)
    private let repeatNewPasswordIndexpath = NSIndexPath(forRow: 2, inSection: 0)
    private let saveCellIndexPath = NSIndexPath(forRow: 0, inSection: 1)
    
    private var currentPassword = ""
    private var newPassword = ""
    private var repeatedNewPassword = ""
    
    private let minPasswordLength = 8
    
    //--------------------------------------
    // MARK: - View Life Cycle
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSaveCellBackgroundColor()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        self.view.endEditing(true)
    }
    
    //--------------------------------------
    // MARK: - UITableViewDelegate
    //--------------------------------------
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if saveActivityIndicator.isAnimating() {
            return nil
        }
        
        if indexPath == saveCellIndexPath {
            if isSaveEnabled() {
                return indexPath
            }
            
            return nil
        }
        
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath {
        case currentPasswordIndexPath:
            currentPasswordTextFiled.becomeFirstResponder()
        case newPasswordIndexPath:
            newPasswordTextFiled.becomeFirstResponder()
        case repeatNewPasswordIndexpath:
            repeatNewPasswordTextField.becomeFirstResponder()
        case saveCellIndexPath:
            self.view.endEditing(true)
            save()
        default:
            break
        }
    }
    
    //--------------------------------------
    // MARK: - Private Helpers Methods
    //--------------------------------------
    
    private func isSaveEnabled() -> Bool {
        return (currentPassword != "" && newPassword != "" && repeatedNewPassword != "")
    }
    
    private func updateSaveCellBackgroundColor() {
        let cell = self.tableView.cellForRowAtIndexPath(saveCellIndexPath)
        
        if isSaveEnabled() {
            cell?.backgroundColor = AppAppearance.AppColors.celestialBlue
        } else {
            cell?.backgroundColor = UIColor.lightGrayColor()
        }
    }
    
    private func presentAlert(title title: String, message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func save() {
        
        // Change password only for users that signup with password provider.
        
        if let provider = User.currentUserProvider where provider == "facebook" {
            presentAlert(title: "", message: NSLocalizedString("You can't change your password, because you have joined us with Facebook account.", comment: "Change password provider message"))
            return
        }
        
        // Validate input
        if newPassword != repeatedNewPassword {
            presentAlert(title: "", message: NSLocalizedString("Field confirmation is not the same as the new password field", comment: "Change password message"))
            return
        }
        
        if currentPassword.characters.count < minPasswordLength {
            presentAlert(title: "", message: NSLocalizedString("Current password must be at least \(minPasswordLength) characters", comment: "Change password message"))
            return
        }
        
        if newPassword.characters.count < minPasswordLength {
            presentAlert(title: "", message: NSLocalizedString("New password must be at least \(minPasswordLength) characters", comment: "Change password message"))
            return
        }
        
        // Change old password to new password.
        
        saveActivityIndicator.startAnimating()
        
        guard let email = User.currentUserEmail else {
            return
        }
        
        DataService.sharedInstance.changePasswordForUser(email: email, fromOldPassword: currentPassword, toNewPassword: newPassword) { (succeeded, error) in
            self.saveActivityIndicator.stopAnimating()
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                
                self.presentAlert(title: NSLocalizedString("Change password failed.", comment: "Change password title"), message: error.localizedDescription)
            } else {
                // Password successfully changed.
                
                let alert = UIAlertController(title: "", message: NSLocalizedString("Password successfully changed", comment: "Change password message"), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { action in
                    self.navigationController?.popViewControllerAnimated(true)
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
}

//--------------------------------------
// MARK: - UITextFieldDelegate
//--------------------------------------

extension ChangePasswordTableViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return !self.saveActivityIndicator.isAnimating()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        switch textField.tag {
        case TextFieldTag.currentPassword.rawValue:
            currentPassword = text
        case TextFieldTag.newPassword.rawValue:
            newPassword = text
        case TextFieldTag.repeatNewPassword.rawValue:
            repeatedNewPassword = text
        default:
            break
        }
        
        updateSaveCellBackgroundColor()
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
