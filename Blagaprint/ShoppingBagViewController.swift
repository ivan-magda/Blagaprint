//
//  ShoppingBagViewController.swift
//  Blagaprint
//
//  Created by Niko on 10.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class ShoppingBagViewController: UIViewController {
    // MARK: - Properties
    
    var parseCentral: ParseCentral?

    private let logInImage = UIImage(named: "Enter.png")!
    private var logInBarButtonItem: UIBarButtonItem?
    
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
        if BlagaprintUser.currentUser() == nil {
            self.logInBarButtonItem = UIBarButtonItem(image: logInImage, style: .Plain, target: self, action: Selector("logInBarButtonDidPressed:"))
            self.navigationItem.rightBarButtonItem = logInBarButtonItem
        } else {
            self.logInBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: - Target

    func logInBarButtonDidPressed(sender: UIBarButtonItem) {
        self.presentViewController(LoginViewController(), animated: true, completion: nil)
    }
}
