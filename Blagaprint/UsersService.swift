//
//  UsersService.swift
//  Blagaprint
//
//  Created by Иван Магда on 17.11.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation
import CloudKit

class AccountService {
    /// Reports whether the current user’s iCloud account can be accessed.
    class func accountStatus(completion: (available: Bool) -> Void) {
        CloudKitCentral.sharedInstance.container.accountStatusWithCompletionHandler {
            status, error in
            print("account status = \(status.rawValue)")
            guard error == nil else {
                print("UserService err: \(error!.localizedDescription)")
                completion(available: false)
                return
            }
            completion(available: true)
        }
    }
    
    /// Returns the user record associated with the current user.
    class func fetchUserRecordID(completion: CKRecordID? -> Void) {
        CloudKitCentral.sharedInstance.container.fetchUserRecordIDWithCompletionHandler {
            fetchedRecordID, error in
            guard error == nil else {
                print("AccountService error: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            completion(fetchedRecordID)
        }
    }
}
