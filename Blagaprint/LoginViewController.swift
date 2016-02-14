//
//  LoginViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 05.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    private enum TextFieldTag: Int {
        case Email = 252
        case Password = 253
    }
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var signupButton: UIButton!
    
    static private let storyboardId = "LoginViewController"
    
    private var didSetKeyboardOffset = false
    
    //--------------------------------------
    // MARK: - View Life Cycle
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.signupButton.layer.cornerRadius = signupButton.bounds.height * 0.1
        self.signupButton.clipsToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // If we have the uid stored, the user is already logger in - no need to sign in again!
        if DataService.sharedInstance.isUserLoggedIn {
            presentLoggedInAlert()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        self.view.endEditing(true)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //--------------------------------------
    // MARK: - Setup
    //--------------------------------------
    
    private func setup() {
        // Add UIKeyboardNotifications observers.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        // Setup text fields.
        self.emailTextField.delegate = self
        self.emailTextField.tag = TextFieldTag.Email.rawValue
        self.emailTextField.attributedPlaceholder = NSAttributedString(string:"Email",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        self.passwordTextField.delegate = self
        self.passwordTextField.tag = TextFieldTag.Password.rawValue
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Password", comment: ""),
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    //--------------------------------------
    // MARK: - UIKeyboardNotifications
    //--------------------------------------
    
    func keyboardWillShow(notification: NSNotification) {
        guard didSetKeyboardOffset == false else {
            return
        }
        
        if let info = notification.userInfo {
            if let keyboardSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size {
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!)
                UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!)!)
                UIView.setAnimationBeginsFromCurrentState(true)
                
                let insets = UIEdgeInsets(top: self.scrollView.contentInset.top, left: 0.0, bottom: keyboardSize.height, right: 0.0)
                self.scrollView.contentInset = insets
                self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: self.scrollView.contentOffset.y + keyboardSize.height / 2.0)
                
                UIView.commitAnimations()
                
                self.didSetKeyboardOffset = true
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let info = notification.userInfo {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(info[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!)
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: info[UIKeyboardAnimationCurveUserInfoKey]!.integerValue!)!)
            UIView.setAnimationBeginsFromCurrentState(true)
            
            let insets = UIEdgeInsets(top: self.scrollView.contentInset.top, left: 0.0, bottom: 0.0, right: 0.0)
            self.scrollView.contentInset = insets
            
            UIView.commitAnimations()
            
            self.didSetKeyboardOffset = false
        }
    }
    
    //--------------------------------------
    // MARK: - Log In
    //--------------------------------------
    
    private func presentLoggedInAlert() {
        let title = NSLocalizedString("You're logged in", comment: "Logged in alert title")
        let message = NSLocalizedString("Welcome to Blagaprint", comment: "Logged in alert message")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel) { action in
            self.dismiss(self)
            })
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func presentAlert(title title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func login(sender: AnyObject) {
        resetScrollViewContentOffset()
        
        self.view.endEditing(true)
        
        /// Nested function for informing user with missed info.
        func presentMissingParametersAlert() {
            let title = NSLocalizedString("Login error", comment: "Login missing parameters error title")
            let message = NSLocalizedString("Don't forget to enter your email and password.", comment: "Login missing parameters error message")
            
            presentAlert(title: title, message: message)
        }
        
        // Validate input info.
        
        guard let email = emailTextField.text where email.characters.count > 0 else {
            presentMissingParametersAlert()
            return
        }
        
        guard let password = passwordTextField.text where password.characters.count > 0 else {
            presentMissingParametersAlert()
            
            return
        }
        
        // Login with the Firebase's authUser method.
        
        self.activityIndicator.startAnimating()
        
        DataService.sharedInstance.baseReference.authUser(email, password: password) { (error, authData) in
            self.activityIndicator.stopAnimating()
            
            if error != nil {
                print("Error: \(error.localizedDescription)")
                
                self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Check your username and password.", comment: "Login error message"))
            } else {
                // Be sure the correct uid is stored.
                
                NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "uid")
                
                // Enter the app after user cancel the alert.
                self.presentLoggedInAlert()
            }
        }
    }
    
    //--------------------------------------
    // MARK: - Forgot Password
    //--------------------------------------
    
    @IBAction func forgotPassword(sender: AnyObject) {
        self.view.endEditing(true)
        
        // Present alert controller with a text field for entering
        // an email adress and then send a password reset email.
        
        let alert = UIAlertController(title: NSLocalizedString("Enter your email", comment: ""), message: nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Send", comment: ""), style: .Default, handler: { handler in
            
            guard let email = alert.textFields![0].text where email.characters.count > 0 else {
                self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Incorrect email", comment: ""))
                return
            }
            
            self.activityIndicator.startAnimating()
            
            // Reset password.
            
            DataService.sharedInstance.resetPasswordForEmail(email) { (success, error) in
                self.activityIndicator.stopAnimating()
                
                if success {
                    self.presentAlert(title: "", message: NSLocalizedString("Password reset email with the given email was send.", comment: ""))
                } else {
                    self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Having some trouble sending reset password email. Try again.", comment: ""))
                }
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //--------------------------------------
    // MARK: - Dismiss Controller
    //--------------------------------------
    
    @IBAction func dismiss(sender: AnyObject) {
        self.view.endEditing(true)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //--------------------------------------
    // MARK: - Presenting
    //--------------------------------------
    
    class func presentInController(controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewControllerWithIdentifier(storyboardId) as! LoginViewController
        
        controller.presentViewController(loginViewController, animated: true, completion: nil)
    }
}

//----------------------------------------
// MARK: - UITextFieldDelegate Extension -
//----------------------------------------

extension LoginViewController: UITextFieldDelegate {
    
    //--------------------------------------
    // MARK: Helper
    //--------------------------------------
    
    private func resetScrollViewContentOffset() {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: 0.0)
    }
    
    //--------------------------------------
    // MARK: Delegate
    //--------------------------------------
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField.tag {
        case TextFieldTag.Email.rawValue:
            self.passwordTextField.becomeFirstResponder()
        case TextFieldTag.Password.rawValue:
            self.login(textField)
        default:
            break
        }
        
        return true
    }
}
