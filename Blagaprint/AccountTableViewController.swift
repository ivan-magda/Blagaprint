//
//  AccountTableViewController.swift
//  Blagaprint
//
//  Created by Niko on 10.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class AccountTableViewController: UITableViewController {
    // MARK: - Types
    
    private enum TextFieldTag: Int {
        case name = 100
        case patronymic
        case surname
        case phoneNumber
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var patronymicTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var logOutActivityIndicator: UIActivityIndicatorView!
    
    private var nameIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    private var patronymicIndexPath = NSIndexPath(forRow: 1, inSection: 0)
    private var surnameIndexPath = NSIndexPath(forRow: 2, inSection: 0)
    private var phoneNumberIndexPath = NSIndexPath(forRow: 3, inSection: 0)
    private var emailIndexPath = NSIndexPath(forRow: 4, inSection: 0)
    private var changePasswordIndexPath = NSIndexPath(forRow: 5, inSection: 0)
    private var orderHistoryIndexPath = NSIndexPath(forRow: 0, inSection: 1)
    private var logOutIndexPath = NSIndexPath(forRow: 0, inSection: 2)
    
    private var saveBarButtonItem: UIBarButtonItem?
    private var saveActivityIndicatorBarButtonItem: UIBarButtonItem?

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInfoSetup()
        
        self.saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: Selector("saveButtonDidPressed"))
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        self.view.endEditing(true)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if logOutActivityIndicator.isAnimating() {
            return nil
        }
        
        if indexPath != emailIndexPath {
            return indexPath
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath == logOutIndexPath {
            logOut()
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    // MARK: - Private Helper Methods
    
    private func userInfoSetup() {
        let user = User.currentUser()
        self.nameTextField.text = user?.name
        self.patronymicTextField.text = user?.patronymic
        self.surnameTextField.text = user?.surname
        self.phoneNumberTextField.text = user?.phoneNumber
        self.emailLabel.text = user?.email
    }
    
    private func presentAlertWithMessage(message: String) {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func logOut() {
        self.logOutActivityIndicator.startAnimating()
        
        User.logOutInBackgroundWithBlock { error in
            self.logOutActivityIndicator.stopAnimating()
            
            if let error = error {
                self.presentAlertWithMessage(error.userInfo["error"] as! String)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    // MARK: - IBActions
    
    func saveButtonDidPressed() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.hidesWhenStopped = true
        
        self.saveActivityIndicatorBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = saveActivityIndicatorBarButtonItem
        
        activityIndicator.startAnimating()
        
        User.currentUser()?.saveInBackgroundWithBlock() { (succeeded, error) in
            activityIndicator.stopAnimating()
            
            if let error = error {
                self.presentAlertWithMessage(error.userInfo["error"] as! String)
            }
        }
    }
    
    @IBAction func logOutButtonDidPressed(sender: UIButton) {
        guard self.logOutActivityIndicator.isAnimating() == false else {
            return
        }
        
        self.tableView.selectRowAtIndexPath(logOutIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        self.tableView(self.tableView, didSelectRowAtIndexPath: logOutIndexPath)
    }

}

// MARK: - UITextFieldDelegate -
extension AccountTableViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return !logOutActivityIndicator.isAnimating()
    }
}
