//
//  ShoppingBagViewController.swift
//  Blagaprint
//
//  Created by Niko on 10.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class ShoppingBagViewController: UIViewController {
    // MARK: Types
    
    private enum SegueIdentifiers: String {
        case MyInfo
    }
    
    // MARK: - Properties
    
    private let logInImage = UIImage(named: "Enter.png")!
    private let accoutnInfoImage = UIImage(named: "Contacts.png")!
    
    var parseCentral: ParseCentral?

    @IBOutlet weak var accountActionBarButton: UIBarButtonItem!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureAccountActionBarButton()
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    // MARK: - Private Helper Methods
    
    private func configureAccountActionBarButton() {
        if User.currentUser() != nil {
            self.accountActionBarButton.image = accoutnInfoImage
        } else {
            self.accountActionBarButton.image = logInImage
        }
    }
    
    // MARK: - IBActions

    @IBAction func accountActionBarButtonDidPressed(sender: UIBarButtonItem) {
        if User.currentUser() != nil {
            self.performSegueWithIdentifier(SegueIdentifiers.MyInfo.rawValue, sender: nil)
        } else {
            self.presentViewController(LoginViewController(), animated: true, completion: nil)
        }
    }
}
