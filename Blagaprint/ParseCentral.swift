//
//  ParseCentral.swift
//  Blagaprint
//
//  Created by Иван Магда on 02.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation

/// The application id of Parse application.
private let applicationId = "S6q46qyVTC8tDSqkryAPvBo3fEkrkiFTtHSAHh3P"

/// The client key of Parse application.
private let clientKey = "1xTVWNh3TSB4ov5zoIseoDQ98JyMO86fjeBFwInr"

class ParseCentral {
    // MARK: - Properties
    
    let parse: Parse
    
    class var sharedInstance: ParseCentral {
        struct Static {
            static var instance: ParseCentral?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = ParseCentral()
        }
        
        return Static.instance!
    }
    
    // MARK: - Initializers
    
    init() {
        Category.registerSubclass()
        CategoryItem.registerSubclass()
        
        Parse.enableLocalDatastore()
        Parse.setApplicationId(applicationId, clientKey: clientKey)
        
        self.parse = Parse()
    }
}
