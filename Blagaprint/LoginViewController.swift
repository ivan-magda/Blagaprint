//
//  LoginViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 05.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class LoginViewController: PFLogInViewController, PFLogInViewControllerDelegate {
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.fields = [.UsernameAndPassword, .LogInButton, .SignUpButton, .PasswordForgotten, .DismissButton]
        self.signUpController = SignUpViewController()
        
        // Customizing the logoView
        let logo = UILabel()
        logo.font = AppAppearance.ralewayThinFontWithSize(50)
        logo.text = "Blagaprint"
        logo.textColor = UIColor.whiteColor()
        self.logInView?.logo = logo
        
        self.logInView?.passwordField?.backgroundColor = UIColor.clearColor()
        self.logInView?.passwordField?.textColor = UIColor.whiteColor()
        self.logInView?.usernameField?.backgroundColor = UIColor.clearColor()
        self.logInView?.usernameField?.textColor = UIColor.whiteColor()
        
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
        logInButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        logInButton.setBackgroundImage(nil, forState: UIControlState.Highlighted)
        logInButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        
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
    
    // MARL: - Log In
    
    func presentLoggedInAlert() {
        let alertController = UIAlertController(title: "You're logged in", message: "Welcome to Blagaprint", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: PFLogInViewControllerDelegate
    
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
