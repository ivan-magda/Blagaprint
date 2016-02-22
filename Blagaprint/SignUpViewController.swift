//
//  SignUpViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 05.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit
import Shimmer
import Firebase

class SignUpViewController: UIViewController {

    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    private enum TextFieldTag: Int {
        case Email = 254
        case Password = 255
    }
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var shimmeringView: FBShimmeringView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var didSetKeyboardOffset = false
    
    //--------------------------------------
    // MARK: - View Life Cycle
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        startShimmering()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
                self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: self.scrollView.contentOffset.y + keyboardSize.height / 3.0)
                
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
        
        // Add gesture recognizer to signUp view.
        let signUpGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("signup:"))
        self.signUpView.addGestureRecognizer(signUpGestureRecognizer)
    }
    
    private func startShimmering() {
        // Add app name label.
        let label = UILabel(frame: shimmeringView.bounds)
        label.textAlignment = .Center
        label.font = UIFont(name: "AvenirNext-UltraLight", size: 48.0)
        label.text = "Blagaprint"
        label.textColor = .whiteColor()
        
        shimmeringView.backgroundColor = .clearColor()
        shimmeringView.contentView = label
        
        // Start shimmering.
        shimmeringView.shimmering = true
    }
    
    //--------------------------------------
    // MARK: - Private
    //--------------------------------------
    
    private func presentSignupErrorAlert(title: String, message: String) {
        // Called upon signup error to let the user know signup didn't work.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //--------------------------------------
    // MARK: - Actions
    //--------------------------------------
    
    @IBAction func signup(sender: AnyObject) {
        resetScrollViewContentOffset()
        
        self.view.endEditing(true)
        
        func presentMissingParametersAlert() {
            let title = NSLocalizedString("Signup error", comment: "Signup missing parameters error title")
            let message = NSLocalizedString("Don't forget to enter your email and password.", comment: "Sign up missing parameters error message")
            
            presentSignupErrorAlert(title, message: message)
        }
        
        guard let email = emailTextField.text where email.characters.count > 0 else {
            presentMissingParametersAlert()
            return
        }
        
        guard let password = passwordTextField.text where password.characters.count > 0 else {
            presentMissingParametersAlert()
            return
        }
        
        weak var weakSelf = self
        
        // Start animating.
        self.activityIndicator.startAnimating()
        
        // Set Email and Password for the New User.
        DataService.sharedInstance.baseReference.createUser(email, password: password) { (error, userData) in
            if error != nil {
                weakSelf?.activityIndicator.stopAnimating()
                
                // There was a problem.
                print("Create user error: \(error.localizedDescription)")
                
                // An error occurred while attempting login.
                if let errorCode = FAuthenticationError(rawValue: error.code) {
                    switch errorCode {
                    case .EmailTaken:
                        weakSelf?.presentSignupErrorAlert(NSLocalizedString("Email taken", comment: ""), message: NSLocalizedString("Email adress is already taken. Please enter another email adress and try again to signup.", comment: ""))
                    default:
                        weakSelf?.presentSignupErrorAlert(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("An error occurred while attempting signup.", comment: ""))
                    }
                }
            } else {
                // Create and Login the New User with authUser.
                DataService.sharedInstance.baseReference.authUser(email, password: password) { (error, authData) in
                    if error != nil {
                        weakSelf?.activityIndicator.stopAnimating()
                        
                        print("Error: \(error.localizedDescription)")
                    } else {
                        let id = userData["uid"] as! String
                        
                        let user = [
                            User.Key.Id.rawValue : id,
                            User.Key.Provider.rawValue : authData.provider!,
                            User.Key.Email.rawValue : email
                        ]
                        
                        // Seal the deal in DataService.swift.
                        DataService.sharedInstance.createNewAccount(id, user: user)
                        
                        weakSelf?.activityIndicator.stopAnimating()
                        
                        // Enter the app.
                        weakSelf?.dismiss(weakSelf!)
                    }
                }
            }
        }
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

//--------------------------------------
// MARK: - UITextFieldDelegate -
//--------------------------------------

extension SignUpViewController: UITextFieldDelegate {
    
    //--------------------------------------
    // MARK: Helper
    //--------------------------------------
    
    private func resetScrollViewContentOffset() {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: 0.0)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField.tag {
        case TextFieldTag.Email.rawValue:
            self.passwordTextField.becomeFirstResponder()
        case TextFieldTag.Password.rawValue:
            self.signup(textField)
        default:
            break
        }
        
        return true
    }
}
