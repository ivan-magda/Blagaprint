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

internal final class DataService {
    
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
    
    var categoryItemReference: Firebase {
        return Firebase(url: baseURL).childByAppendingPath("categoryItems")
    }
    
    var bagItemReference: Firebase {
        return Firebase(url: baseURL).childByAppendingPath("bagItems")
    }
    
    var bagReference: Firebase {
        return Firebase(url: baseURL).childByAppendingPath("bags")
    }
    
    var isUserLoggedIn: Bool {
        return (NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.userId) != nil) && (DataService.sharedInstance.currentUserReference.authData != nil)
    }
    
    //--------------------------------------
    // MARK: Class Variables
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
    
    //--------------------------------------
    // MARK: - Class Functions -
    //--------------------------------------
    
    //--------------------------------------
    // MARK: Network Indicator
    //--------------------------------------
    
    class func showNetworkIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    class func hideNetworkIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    //--------------------------------------
    // MARK: User
    //--------------------------------------
    
    class func logout() {
        // unauth() is the logout method for the current user.
        
        DataService.sharedInstance.currentUserReference.unauth()
        
        // Remove the user's uid, email and provider from storage.
        NSUserDefaults.standardUserDefaults().updateUserInfoWithDictionary(nil)
    }
    
    //--------------------------------------
    // MARK: - Instance Functions -
    //--------------------------------------
    
    //--------------------------------------
    // MARK: User
    //--------------------------------------
    
    func createNewAccount(key: String, user: Dictionary<String, String>) {
        // A User is born.
        
        userReference.childByAppendingPath(key).setValue(user)
        
        // Store the uid, email, provider for future access - handy!
        NSUserDefaults.standardUserDefaults().updateUserInfoWithDictionary(user)
    }
    
    func resetPasswordForEmail(email: String, withCompletionHandler block: DataServiceResultBlock) {
        DataService.showNetworkIndicator()
        
        baseReference.resetPasswordForUser(email, withCompletionBlock: { error in
            DataService.hideNetworkIndicator()
            
            if let _ = error {
                // There was an error processing the request
                print("Reset password failed. Error: \(error.localizedDescription)")
                
                block(succeeded: false, error: error)
            } else {
                // Password reset sent successfully
                
                block(succeeded: true, error: nil)
            }
        })
    }
    
    func changePasswordForUser(email email: String, fromOldPassword oldPassword: String, toNewPassword newPassword: String, withCompletionBlock block: DataServiceResultBlock) {
        DataService.showNetworkIndicator()
        
        baseReference.changePasswordForUser(email, fromOld: oldPassword, toNew: newPassword) { error in
            DataService.hideNetworkIndicator()
            
            if let _ = error {
                // There was an error processing the request
                print("Change password failed. Error: \(error.localizedDescription)")
                
                block(succeeded: false, error: error)
            } else {
                block(succeeded: true, error: nil)
            }
        }
    }
    
    //--------------------------------------
    // MARK: Bag
    //--------------------------------------
    
    func updateBagBadgeValue() {
        
        func setCountValue(count: Int) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let tabBarController = appDelegate.window!.rootViewController as! UITabBarController
            
            if let tabBarItem = tabBarController.tabBar.items?[TabItemIndex.ShoppingBagViewController.rawValue] {
                if count == 0 {
                    tabBarItem.badgeValue = nil
                } else {
                    tabBarItem.badgeValue = "\(count)"
                }
            }
        }
        
        guard isUserLoggedIn == true else {
            setCountValue(0)
            return
        }
        
        guard let userId = User.currentUserId else {
            setCountValue(0)
            return
        }
        
        bagReference.queryOrderedByChild(FBag.Key.userId.rawValue).queryEqualToValue(userId).observeEventType(.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                assert(snapshots.count == 1, "Bag must be unique for each user.")
                
                let bagSnap = snapshots[0]
                if let bagDict = bagSnap.value as? [String: AnyObject] {
                    if let items = bagDict[FBag.Key.items.rawValue] as? [String] {
                        setCountValue(items.count)
                    } else {
                        setCountValue(0)
                    }
                }
            }
        })
    }
    
    
    func deleteItem(item: FBagItem, succeeded: DataServiceSuccessResultBlock?, failure: DataServiceFailureResultBlock?) {
        let bagRef = bagReference
        let userId = User.currentUserId!
        
        // Query for the user bag.
        bagRef.queryOrderedByChild(FBag.Key.userId.rawValue).queryEqualToValue(userId).observeSingleEventOfType(.Value, withBlock: { snap in
            if let snapshots = snap.children.allObjects as? [FDataSnapshot] {
                assert(snapshots.count == 1, "Bag must be unique for each user.")
                
                let bagSnap = snapshots[0]
                
                if let bagDict = bagSnap.value as? [String : AnyObject] {
                    let bag = FBag(key: bagSnap.key, dictionary: bagDict)
                    
                    // Remove item from bag.
                    
                    for (index, element) in bag.items!.enumerate() {
                        if element == item.key {
                            bag.items!.removeAtIndex(index)
                            break
                        }
                    }
                    
                    // Update bag.
                    
                    bag.reference.updateChildValues(bag.value, withCompletionBlock: { (error, ref) in
                        if let _ = error {
                            failure?(error: error)
                        } else {
                            
                            // Remove item from firebase.
                            
                            item.reference.setValue(nil, withCompletionBlock: { (error, ref) in
                                if let _ = error {
                                    failure?(error: error)
                                } else {
                                    succeeded?()
                                }
                            })
                        }
                    })
                }
            }
        })
    }
    
    
    /// Saves item to the Bag of the current user.
    func saveItem(item: [String : AnyObject], success: DataServiceSuccessResultBlock?, failure: DataServiceFailureResultBlock?) {
        
        let bagRef = bagReference
        
        let userId = User.currentUserId!
        
        // Looking for the Bag of the current user.
        
        bagRef.queryOrderedByChild(FBag.Key.userId.rawValue).queryEqualToValue(userId).observeSingleEventOfType(.Value, withBlock: { [weak self] snapshot in
            
            // If there is no value in snapshot, it's meaning that bag
            // for the current user doesn't exist yet.
            // Create it and then save the item.
            
            if snapshot.value is NSNull {
                self?.createBagForUserWithId(userId) { (error, ref, bag) in
                    if let error = error {
                        failure?(error: error)
                    } else {
                        self?.addItemToBag(bag!, item: item) { (succeeded, error) in
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
                    
                    self?.addItemToBag(bag, item: item) { (succeeded, error) in
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
        
        let bag = [FBag.Key.userId.rawValue: id]
        
        // saves to Firebase.
        
        newBagRef.setValue(bag) { (error, ref) in
            if let _ = error {
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
            if let _ = error {
                block(succeeded: false, error: error)
            } else {
                // Add unique object.
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
