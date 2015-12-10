//
//  User.swift
//  Blagaprint
//
//  Created by Иван Магда on 09.12.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import UIKit

class BlagaprintUser: PFUser {
    // MARK: - Properties
    
    @NSManaged var name: String?
    @NSManaged var patronymic: String?
    @NSManaged var surname: String?
    @NSManaged var phoneNumber: String?
    
    // MARK: - Inheritens
    
    override class func initialize() {
        struct Static {
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
}
