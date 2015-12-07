//
//  SignUpViewController.swift
//  Blagaprint
//
//  Created by Иван Магда on 05.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class SignUpViewController: PFSignUpViewController, PFSignUpViewControllerDelegate {
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.minPasswordLength = 8
        
        // Customizing the signUpView
        let signUpView = self.signUpView!
        signUpView.emailAsUsername = true
        
        let logo = UILabel()
        logo.font = AppAppearance.ralewayThinFontWithSize(50)
        logo.text = "Blagaprint"
        logo.textColor = UIColor.whiteColor()
        signUpView.logo = logo
        
        // Password
        signUpView.passwordField?.backgroundColor = UIColor.clearColor()
        signUpView.passwordField?.textColor = UIColor.whiteColor()
        signUpView.passwordField?.placeholder = NSLocalizedString("Password", comment: "SignUpViewController password placeholder text")
        
        // Username as email
        signUpView.usernameField?.backgroundColor = UIColor.clearColor()
        signUpView.usernameField?.textColor = UIColor.whiteColor()
        
        // Add a background image
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let imageView = UIImageView(frame: appDelegate.window!.bounds)
        imageView.image = AppAppearance.blurredBackgroundImage()
        self.view.insertSubview(imageView, atIndex: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Customizing the signUpButton
        let signUpButton = self.signUpView!.signUpButton!
        signUpButton.setTitle(NSLocalizedString("Sign Up", comment: "SignUpViewController signUpButton title for state normal"), forState: .Normal)
        signUpButton.setTitle(NSLocalizedString("Sign Up", comment: "SignUpViewController signUpButton title for state highlighted"), forState: .Highlighted)
        
        // Customizing the dismissButton
        let dismissButton = self.signUpView!.dismissButton!
        let image = UIImage(named: "Delete.png")!
        dismissButton.setImage(image, forState: UIControlState.Normal)
        dismissButton.setImage(image, forState: UIControlState.Highlighted)
    }

    
    // MARK: - PFSignUpViewControllerDelegate
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        print("Did fail to sign in: \(error)")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        print("Did cancel to sign up")
    }
}
