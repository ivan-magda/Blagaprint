//
//  CloudKitCentral.swift
//  Blagaprint
//
//  Created by Иван Магда on 02.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import CloudKit

private let CloudKitContainerIdentifier = "iCloud.com.IvanMagda.Blagaprint.CloudKit.Test"

class CloudKitCentral {
    // MARK: - Properties

    let container: CKContainer
    let publicDatabase: CKDatabase
    let privateDatabase: CKDatabase
    
    class var sharedInstance: CloudKitCentral {
        struct Static {
            static var instance: CloudKitCentral?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = CloudKitCentral()
        }
        
        return Static.instance!
    }
    
    // MARK: - Initializers
    
    init() {
        self.container = CKContainer(identifier: CloudKitContainerIdentifier)
        self.publicDatabase = container.publicCloudDatabase
        self.privateDatabase = container.privateCloudDatabase
    }
}
