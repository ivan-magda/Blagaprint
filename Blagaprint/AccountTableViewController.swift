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
    
    var logInAccountView: UserLogInEmptyView?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var patronymicTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var logOutActivityIndicator: UIActivityIndicatorView!
    
    // Index paths of the table view cells.
    private var nameIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    private var patronymicIndexPath = NSIndexPath(forRow: 1, inSection: 0)
    private var surnameIndexPath = NSIndexPath(forRow: 2, inSection: 0)
    private var phoneNumberIndexPath = NSIndexPath(forRow: 3, inSection: 0)
    private var emailIndexPath = NSIndexPath(forRow: 4, inSection: 0)
    private var changePasswordIndexPath = NSIndexPath(forRow: 5, inSection: 0)
    private var orderHistoryIndexPath = NSIndexPath(forRow: 0, inSection: 1)
    private var logOutIndexPath = NSIndexPath(forRow: 0, inSection: 2)
    
    // Holds input info from text fields.
    private var name: String?
    private var patronymic: String?
    private var surname: String?
    private var phoneNumber: String?
    
    // Phone number associated variables.
    private let internationalCountryCode = "+7"
    private let phoneNumberDigitsCount = 10
    private let phoneNumberStringLength = 17
    
    // Right bar button items.
    private var saveBarButtonItem: UIBarButtonItem?
    private var saveActivityIndicatorBarButtonItem: UIBarButtonItem?
    private var logInBarButtonItem: UIBarButtonItem?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        viewSetup()
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
        
        switch indexPath {
        case nameIndexPath:
            nameTextField.becomeFirstResponder()
        case patronymicIndexPath:
            patronymicTextField.becomeFirstResponder()
        case surnameIndexPath:
            surnameTextField.becomeFirstResponder()
        case phoneNumberIndexPath:
            phoneNumberTextField.becomeFirstResponder()
        case logOutIndexPath:
            logOut()
        default:
            break
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    // MARK: - Private Helper Methods
    
    private func viewSetup() {
        self.logInAccountView?.removeFromSuperview()
        
        if BlagaprintUser.currentUser() == nil {
            self.logInBarButtonItem = UIBarButtonItem(image: UIImage(named: "Enter.png")!, style: .Plain, target: self, action: Selector("presentLoginViewController"))
            self.navigationItem.rightBarButtonItem = self.logInBarButtonItem
            
            presentLogInAccountView()
        } else {
            userInfoSetup()
            
            self.saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: Selector("saveButtonDidPressed"))
            self.navigationItem.rightBarButtonItem = saveBarButtonItem
            
            updateSaveButtonEnabledState()
            updateBackgroundColorOfLogOutCell()
        }
    }
    
    private func userInfoSetup() {
        let user = BlagaprintUser.currentUser()!
        
        self.name = user.name
        self.patronymic = user.patronymic
        self.surname = user.surname
        self.phoneNumber = user.phoneNumber
        
        self.nameTextField.text = name
        self.patronymicTextField.text = patronymic
        self.surnameTextField.text = surname
        self.phoneNumberTextField.text = phoneNumber
        
        self.emailLabel.text = user.email
    }
    
    private func presentLogInAccountView() {
        self.logInAccountView = NSBundle.mainBundle().loadNibNamed("UserLogInEmptyView", owner: self, options: nil).first as? UserLogInEmptyView
        
        // Handle callback when Log In button pressed.
        weak var weakSelf = self
        self.logInAccountView!.logInButtonDidPressedCallBack = {
            weakSelf?.presentLoginViewController()
        }
        
        // Customize view frame
        let navBarHeight = CGRectGetHeight(self.navigationController!.navigationBar.bounds)
        let statusBarHeight = CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
        let yCoordinate = navBarHeight + statusBarHeight
        let height = CGRectGetHeight(self.view.bounds) - yCoordinate
        let frame = CGRectMake(0, yCoordinate, CGRectGetWidth(self.view.bounds), height)
        self.logInAccountView?.frame = frame
        
        // Change background color of log out cell.
        updateBackgroundColorOfLogOutCell()
        
        self.navigationController?.view.addSubview(self.logInAccountView!)
    }
    
    func presentLoginViewController() {
        presentViewController(LoginViewController(), animated: true, completion: nil)
    }
    
    private func updateBackgroundColorOfLogOutCell() {
        let logOutCell = self.tableView.cellForRowAtIndexPath(logOutIndexPath)
        
        if BlagaprintUser.currentUser() == nil {
            logOutCell?.backgroundColor = UIColor.whiteColor()
        } else {
            logOutCell?.backgroundColor = AppAppearance.AppColors.cornflowerBlue
        }
    }
    
    private func updateSaveButtonEnabledState() {
        let user = BlagaprintUser.currentUser()
        
        if user?.name != name ||
           user?.patronymic != patronymic ||
           user?.surname != surname ||
           user?.phoneNumber != phoneNumber {
            self.saveBarButtonItem?.enabled = true
        } else {
            self.saveBarButtonItem?.enabled = false
        }
    }
    
    private func presentAlert(title title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func logOut() {
        self.logOutActivityIndicator.startAnimating()
        
        BlagaprintUser.logOutInBackgroundWithBlock { error in
            self.logOutActivityIndicator.stopAnimating()
            
            if let error = error {
                self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: (error.userInfo["error"] as! String))
            } else {
                self.viewSetup()
            }
        }
    }
    
    // MARK: - Actions
    
    func saveButtonDidPressed() {
        self.view.endEditing(true)
        
        // Count for empty text fields.
        let emptyFields = [nameTextField, patronymicTextField, surnameTextField, phoneNumberTextField].filter { (textField) in textField.text?.characters.count == 0 }.reduce(0) { (total, textField) in
            total + 1
        }
        
        // Validate inputs info.
        if emptyFields > 1 {
            presentAlert(title: "", message: NSLocalizedString("Please, enter all data", comment: "Message for alert controller in accountVC"))
            
            return
        } else if emptyFields == 1 {
            var message: String?
            
            if nameTextField.text == "" {
                message = NSLocalizedString("Please, enter your name", comment: "Message for alert")
            } else if patronymicTextField.text == "" {
                message = NSLocalizedString("Please, enter your patronymic", comment: "Message for alert")
            } else if surnameTextField.text == "" {
                message = NSLocalizedString("Please, enter your surname", comment: "Message for alert")
            } else if phoneNumberTextField.text == "" {
                message = NSLocalizedString("Please, enter your phone number", comment: "Message for alert")
            }
            
            guard message != nil else {
                return
            }
            
            presentAlert(title: "", message: message!)
            
            return
        }
        
        let length = phoneNumberTextField.text?.characters.count
        if length < phoneNumberStringLength {
            presentAlert(title: "", message: NSLocalizedString("Incorrect phone number", comment: "Message for alert"))
            
            return
        }
        
        // Present activity indicator.
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.hidesWhenStopped = true
        
        self.saveActivityIndicatorBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = saveActivityIndicatorBarButtonItem
        
        activityIndicator.startAnimating()
        
        // Update info and save it.
        let user = BlagaprintUser.currentUser()!
        user.name = name
        user.patronymic = patronymic
        user.surname = surname
        user.phoneNumber = phoneNumber
        
        BlagaprintUser.currentUser()?.saveInBackgroundWithBlock() { (succeeded, error) in
            activityIndicator.stopAnimating()
            
            if let error = error {
                self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: error.userInfo["error"] as! String)
            } else if succeeded {
                self.presentAlert(title: "", message: NSLocalizedString("Updated", comment: "Message for alert"))
            } else {
                print("User info is not updated")
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
    
    private func getLength(number: String) -> Int {
        return getDigitString(number).characters.count
    }
    
    private func getDigitString(number: String) -> String {
        var digitString = (number as NSString).stringByReplacingCharactersInRange(NSMakeRange(0, 3), withString: "")
        digitString = digitString.stringByReplacingOccurrencesOfString("(", withString: "")
        digitString = digitString.stringByReplacingOccurrencesOfString(")", withString: "")
        digitString = digitString.stringByReplacingOccurrencesOfString(" ", withString: "")
        digitString = digitString.stringByReplacingOccurrencesOfString("-", withString: "")
        digitString = digitString.stringByReplacingOccurrencesOfString("+", withString: "")
        
        return digitString
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if logOutActivityIndicator.isAnimating() {
            return false
        }
        
        // Set the placeholder text for the phone number text field.
        if textField.tag == TextFieldTag.phoneNumber.rawValue, let text = textField.text {
            if text.characters.count == 0 {
                textField.text = "\(internationalCountryCode) ("
            }
        }
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Find out what the text field will be after adding the current edit
        let text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        switch textField.tag {
        case TextFieldTag.name.rawValue:
            self.name = text
        case TextFieldTag.patronymic.rawValue:
            self.patronymic = text
        case TextFieldTag.surname.rawValue:
            self.surname = text
        case TextFieldTag.phoneNumber.rawValue:
            
          // +7 (xxx) 216-5382
            
            let length = getLength(textField.text!)
            
            let delete = range.length > 0
            
            if length == phoneNumberDigitsCount {
                if !delete {
                    updateSaveButtonEnabledState()
                    
                    return false
                }
            }
            
            if length == 0 && delete {
                updateSaveButtonEnabledState()
                
                return false
            }
            
            let num: NSString = getDigitString(textField.text!)
            
            if length == 3 {
                textField.text = "\(internationalCountryCode) (\(num)) "
                
                if delete {
                    textField.text = "\(internationalCountryCode) (\(num)"
                }
            } else if length == 6 {
                let mobileOperatorDigits = num.substringToIndex(3)
                let number = num.substringFromIndex(3)
                textField.text = "\(internationalCountryCode) (\(mobileOperatorDigits)) \(number)-"
                
                if delete {
                    textField.text = "\(internationalCountryCode) (\(mobileOperatorDigits)) \(number)"
                }
            }
            
            self.phoneNumber = textField.text
            updateSaveButtonEnabledState()
            
            return true
        default:
            break
        }
        
        updateSaveButtonEnabledState()
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
