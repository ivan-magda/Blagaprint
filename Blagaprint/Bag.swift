//
//  Bag.swift
//  Blagaprint
//
//  Created by Иван Магда on 02.01.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation

/// Class name of the Bag object.
let BagClassName = "Bag"

class Bag: PFObject, PFSubclassing {
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    enum Keys: String {
        case userId
        case items
    }
    
    //--------------------------------------
    // MARK: - PFSubclassing
    //--------------------------------------
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    @NSManaged var userId: String
    @NSManaged var items: [String]
    
    /// The class name of the object.
    class func parseClassName() -> String {
        return BagClassName
    }

}
