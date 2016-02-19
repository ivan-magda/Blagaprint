//
//  DataService.swift
//  Blagaprint
//
//  Created by Иван Магда on 14.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation
import Firebase

public typealias DataServiceSuccessResultBlock = () -> ()
public typealias DataServiceFailureResultBlock = (error: NSError?) -> ()
public typealias DataServiceResultBlock = (succeeded: Bool, error: NSError?) -> ()

class DataService {
    
    //--------------------------------------
    // MARK: - Properties -
    //--------------------------------------
    
    //--------------------------------------
    // MARK: References
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
        let userId = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.userId)
        
        return userReference.childByAppendingPath(userId)
    }
    
    var categoryReference: Firebase {
        return Firebase(url: baseURL).childByAppendingPath("categories")
    }
    
    var categoryItemsReference: Firebase {
        return Firebase(url: baseURL).childByAppendingPath("categoryItems")
    }
    
    var bagItemReference: Firebase {
        return Firebase(url: baseURL).childByAppendingPath("bagItems")
    }
    
    //--------------------------------------
    // MARK: Other
    //--------------------------------------
    
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
        return (NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.userId) != nil) && (DataService.sharedInstance.currentUserReference.authData != nil)
    }
    
    //--------------------------------------
    // MARK: - User Behavior -
    //--------------------------------------
    
    func createNewAccount(key: String, user: Dictionary<String, String>) {
        // A User is born.
        
        userReference.childByAppendingPath(key).setValue(user)
        
        // Store the uid, email, provider for future access - handy!
        NSUserDefaults.standardUserDefaults().updateUserInfoWithDictionary(user)
    }
    
    class func logout() {
        // unauth() is the logout method for the current user.
        
        DataService.sharedInstance.currentUserReference.unauth()
        
        // Remove the user's uid, email and provider from storage.
        NSUserDefaults.standardUserDefaults().updateUserInfoWithDictionary(nil)
    }
    
    func resetPasswordForEmail(email: String, callback: (success: Bool, error: NSError?) -> Void ) {
        DataService.showNetworkIndicator()
        
        self.baseReference.resetPasswordForUser(email, withCompletionBlock: { error in
            DataService.hideNetworkIndicator()
            
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
    
    func changePasswordForUser(email email: String, fromOldPassword oldPassword: String, toNewPassword newPassword: String, withCompletionBlock block: NSError? -> ()) {
        DataService.showNetworkIndicator()
        
        self.baseReference.changePasswordForUser(email, fromOld: oldPassword, toNew: newPassword) { error in
            DataService.hideNetworkIndicator()
            
            if error != nil {
                block(error)
            } else {
                block(nil)
            }
        }
    }
    
    //--------------------------------------
    // MARK: - Network Indicator -
    //--------------------------------------
    
    class func showNetworkIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    class func hideNetworkIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    //--------------------------------------
    // MARK: - Adding to Bag
    //--------------------------------------
    
    func saveItem(item: [String : AnyObject], success: DataServiceSuccessResultBlock?, failure: DataServiceFailureResultBlock?) {
        
    }
}

//--------------------------------------
// MARK: - NSUserDefaults Extension -
//--------------------------------------

extension NSUserDefaults {
    func updateUserInfoWithDictionary(info: [String : String]?) {
        self.setValue(info?[User.Keys.Id.rawValue], forKey: UserDefaultsKeys.userId)
        self.setValue(info?[User.Keys.Email.rawValue], forKey: UserDefaultsKeys.email)
        self.setValue(info?[User.Keys.Provider.rawValue], forKey: UserDefaultsKeys.provider)
    }
}
