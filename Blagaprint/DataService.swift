//
//  DataService.swift
//  Blagaprint
//
//  Created by Иван Магда on 14.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation
import Firebase

public typealias DataServiceSuccessResultBlock = () -> Void
public typealias DataServiceFailureResultBlock = (error: NSError?) -> Void
public typealias DataServiceResultBlock = (succeeded: Bool, error: NSError?) -> Void

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
    
    var bagReference: Firebase {
        return Firebase(url: baseURL).childByAppendingPath("bags")
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
    // MARK: - Bag
    //--------------------------------------
    
    /// Saves BagItem to the Bag of the current user.
    func saveItem(item: [String : AnyObject], success: DataServiceSuccessResultBlock?, failure: DataServiceFailureResultBlock?) {
        let bagRef = bagReference
        let userId = User.currentUserId!
        
        // Looking for the Bag of the current user.
        
        bagRef.queryOrderedByChild(FBag.Keys.userId.rawValue).queryEqualToValue(userId).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // If there is no value in snapshot, it's meaning that bag
            // for the current user doesn't exist yet.
            // Create it and then save the item.
            
            if snapshot.value is NSNull {
                self.createBagForUserWithId(userId) { (error, ref, bag) in
                    if let error = error {
                        failure?(error: error)
                    } else {
                        self.addItemToBag(bag!, item: item) { (succeeded, error) in
                            if succeeded {
                                success?()
                            } else {
                                failure?(error: error)
                            }
                        }
                    }
                }
            } else if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                assert(snapshots.count == 1, "Bag must be unique for each user.")
                
                let bagSnap = snapshots[0]
                
                if let bagDict = bagSnap.value as? [String : AnyObject] {
                    let bag = FBag(key: bagSnap.key, dictionary: bagDict)
                    
                    self.addItemToBag(bag, item: item) { (succeeded, error) in
                        if succeeded {
                            success?()
                        } else {
                            failure?(error: error)
                        }
                    }
                } else {
                    failure?(error: nil)
                }
            }
        })
    }
    
    private func createBagForUserWithId(id: String, andWithCompletionBlock block: (NSError?, Firebase!, FBag?) -> Void) {
        // Save the Bag
        // bagReference is the parent of the new Bag: "bags".
        // childByAutoId() saves the bag and gives it its own ID.
        
        let newBagRef = bagReference.childByAutoId()
        
        let bag = [
            FBag.Keys.userId.rawValue : id
        ]
        
        // saves to Firebase.
        
        newBagRef.setValue(bag) { (error, ref) in
            if error != nil {
                block(error, ref, nil)
            } else {
                let newBag = FBag(key: ref.key, dictionary: bag)
                
                block(nil, ref, newBag)
            }
        }
    }
    
    private func addItemToBag(bag: FBag, item: [String : AnyObject], andWithCompletionBlock block: DataServiceResultBlock) {
        let itemRef = bagItemReference.childByAutoId()
        
        itemRef.setValue(item) { (error, ref) in
            if let error = error {
                block(succeeded: false, error: error)
            } else {
                
                if bag.items != nil {
                    if !bag.items!.contains(ref.key) {
                        bag.items!.append(ref.key)
                    }
                } else {
                    bag.items = [ref.key]
                }
                
                bag.reference.updateChildValues(bag.value, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        block(succeeded: false, error: error)
                    } else {
                        block(succeeded: true, error: nil)
                    }
                })
            }
        }
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
