//
//  LoginViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 05.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class LoginViewController: PFLogInViewController, PFLogInViewControllerDelegate {
    //--------------------------------------
    // MARK: - View Life Cycle
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.fields = [.UsernameAndPassword, .LogInButton, .SignUpButton, .PasswordForgotten, .DismissButton]
        self.signUpController = SignUpViewController()
        
        // Customizing the logoView
        let logo = UILabel()
        logo.font = AppAppearance.ralewayThinFontWithSize(40)
        logo.text = "Blagaprint"
        logo.textColor = UIColor.whiteColor()
        
        let logInView = self.logInView!
        logInView.logo = logo
        
        // Passwor field
        let passwordField = logInView.passwordField!
        passwordField.placeholder = NSLocalizedString("Password", comment: "LogInViewController password placeholder text")
        passwordField.backgroundColor = UIColor.clearColor()
        passwordField.textColor = UIColor.whiteColor()
        
        // Username Field
        let usernameField = logInView.usernameField!
        usernameField.placeholder = NSLocalizedString("Email", comment: "LogInViewController username placeholder text")
        usernameField.backgroundColor = UIColor.clearColor()
        usernameField.textColor = UIColor.whiteColor()
        
        // Forgotten button
        let forgottenButton = logInView.passwordForgottenButton!
        forgottenButton.setTitle(NSLocalizedString("Forgot Password?", comment: "LogInViewController forgotPasswordButton title for state normal"), forState: .Normal)
        forgottenButton.setTitle(NSLocalizedString("Forgot Password?", comment: "LogInViewController forgotPasswordButton title for state highlighted"), forState: .Highlighted)
        
        // Add a background image
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let imageView = UIImageView(frame: appDelegate.window!.bounds)
        imageView.image = AppAppearance.blurredBackgroundImage()
        self.view.insertSubview(imageView, atIndex: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Customizing the logInButton
        let logInButton = self.logInView!.logInButton!
        logInButton.setTitle(NSLocalizedString("Log In", comment: "LogInViewController logInButton title for state normal"), forState: .Normal)
        logInButton.setTitle(NSLocalizedString("Log In", comment: "LogInViewController logInButton title for state highlighted"), forState: .Highlighted)
        logInButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        logInButton.setBackgroundImage(nil, forState: UIControlState.Highlighted)
        logInButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        
        // Customizing the signUpButton
        let signUpButton = self.logInView!.signUpButton!
        signUpButton.setTitle(NSLocalizedString("Sign Up", comment: "LogInViewController signUpButton title for state normal"), forState: .Normal)
        signUpButton.setTitle(NSLocalizedString("Sign Up", comment: "LogInViewController signUpButton title for state highlighted"), forState: .Highlighted)
        
        // Customizing the dismissButton
        let dismissButton = self.logInView!.dismissButton!
        let image = UIImage(named: "Delete.png")!
        dismissButton.setImage(image, forState: UIControlState.Normal)
        dismissButton.setImage(image, forState: UIControlState.Highlighted)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.currentUser() != nil {
            self.presentLoggedInAlert()
        }
    }
    
    //--------------------------------------
    // MARK: - Log In
    //--------------------------------------
    
    func presentLoggedInAlert() {
        let alertController = UIAlertController(title: "You're logged in", message: "Welcome to Blagaprint", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "Ok", style: .Default) { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //--------------------------------------
    // MARK: PFLogInViewControllerDelegate
    //--------------------------------------
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        if (!username.isEmpty && !password.isEmpty) {
            return true
        } else {
            return false
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.presentLoggedInAlert()
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        if let error = error {
            let message = error.userInfo["error"] as! String
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        print("Did fail to log in: \(error)")
    }
}
