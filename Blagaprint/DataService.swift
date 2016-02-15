//
//  DataService.swift
//  Blagaprint
//
//  Created by Иван Магда on 14.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation

class DataService {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var baseURL: String {
        return "https://blagaprint-ivanmagda.firebaseio.com"
    }
    
    var baseReference: Firebase {
        return Firebase(url: baseURL)
    }
    
    var userReference: Firebase {
        return Firebase(url: baseURL).childByAppendingPath("users")
    }
    
    var currentUserReference: Firebase {
        let userId = NSUserDefaults.standardUserDefaults().stringForKey("uid")
        
        return userReference.childByAppendingPath(userId)
    }
    
    class var sharedInstance: DataService {
        struct Static {
            static var instance: DataService?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = DataService()
        }
        
        return Static.instance!
    }
    
    var isUserLoggedIn: Bool {
        return (NSUserDefaults.standardUserDefaults().stringForKey("uid") != nil) && (DataService.sharedInstance.currentUserReference.authData != nil)
    }
    
    //--------------------------------------
    // MARK: - User Behavior -
    //--------------------------------------
    
    func createNewAccount(uid: String, user: Dictionary<String, String>) {
        // A User is born.
        
        userReference.childByAppendingPath(uid).setValue(user)
    }
    
    class func logout() {
        // unauth() is the logout method for the current user.
        
        DataService.sharedInstance.currentUserReference.unauth()
        
        // Remove the user's uid from storage.
        
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "uid")
    }
    
    func resetPasswordForEmail(email: String, callback: (success: Bool, error: NSError?) -> Void ) {
        self.baseReference.resetPasswordForUser(email, withCompletionBlock: { error in
            if error != nil {
                // There was an error processing the request
                print("Reset password error: \(error.localizedDescription)")
                
                callback(success: false, error: error)
            } else {
                // Password reset sent successfully
                
                callback(success: true, error: nil)
            }
        })
    }
}
