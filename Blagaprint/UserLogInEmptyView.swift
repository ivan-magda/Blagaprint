//
//  UserLogInEmptyView.swift
//  Blagaprint
//
//  Created by Иван Магда on 11.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import UIKit

class UserLogInEmptyView: UIView {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    
    var logInButtonDidPressedCallBack: (() -> ())?
    
    //--------------------------------------
    // MARK: - Methods
    //--------------------------------------
    
    @IBAction private func logInButtonDidPressed(sender: UIButton) {
        if let callback = logInButtonDidPressedCallBack {
            callback()
        }
    }
}
