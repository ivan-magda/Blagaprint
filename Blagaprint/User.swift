//
//  User.swift
//  Blagaprint
//
//  Created by Иван Магда on 15.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation
import Firebase
import FBSDKCoreKit

internal final class User {
    
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    enum Key: String {
        case Id = "id"
        case Email = "email"
        case Provider = "provider"
        case Name = "name"
        case Patronymic = "patronymic"
        case Surname = "surname"
        case PhoneNumber = "phoneNumber"
    }
    
    //--------------------------------------
    // MARK: - Properties -
    //--------------------------------------
    
    var key: String
    
    var reference: Firebase
    
    var id: String
    var email: String
    var provider: String
    var name: String?
    var patronymic: String?
    var surname: String?
    var phoneNumber: String?
    
    var value: Dictionary<String, AnyObject> {
        var dictionary = [String : AnyObject]()
        
        dictionary[Key.Id.rawValue] = id
        dictionary[Key.Email.rawValue] = email
        dictionary[Key.Provider.rawValue] = provider
        
        if let name = name {
            dictionary[Key.Name.rawValue] = name
        }
        
        if let patronymic = patronymic {
            dictionary[Key.Patronymic.rawValue] = patronymic
        }
        
        if let surname = surname {
            dictionary[Key.Surname.rawValue] = surname
        }
        
        if let phoneNumber = phoneNumber {
            dictionary[Key.PhoneNumber.rawValue] = phoneNumber
        }
        
        return dictionary
    }
    
    //--------------------------------------
    // MARK: Class Variables
    //--------------------------------------
    
    class var currentUserId: String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.userId)
    }
    
    class var currentUserEmail: String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.email)
    }
    
    class var currentUserProvider: String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKeys.provider)
    }
    
    //--------------------------------------
    // MARK: - Class Functions -
    //--------------------------------------
    
    class func fetchFacebookUserInfoWithCompletionHandler(block:(result: [String : String]?, error: NSError?) -> ()) {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "\(FacebookParameters.id), \(FacebookParameters.name), \(FacebookParameters.firstName), \(FacebookParameters.lastName), \(FacebookParameters.email)"]).startWithCompletionHandler({ (connection, result, error) in
            if let _ = error {
                block(result: nil, error: error)
            } else if let result = result as? [String : String] {
                block(result: result, error: nil)
            } else {
                print("Unexpected issue. Error: \(error). Result: \(result)")
                
                block(result: nil, error: error)
            }
        })
    }
    
    class func isUserAccountAlreadyPersist(userId userId: String, block: Bool -> Void) {
        let usersRef = DataService.sharedInstance.userReference
        
        usersRef.queryOrderedByChild(Key.Id.rawValue).queryEqualToValue(userId).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                block(false)
            } else {
                print("Found user with value: \(snapshot.value)")
                
                assert(snapshot.childrenCount == 1, "Founded user account must be unique.")
                
                block(true)
            }
        })
    }
    
    //--------------------------------------
    // MARK: - Init -
    //--------------------------------------
    
    /// Initialize the new User
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self.key = key
        
        id = dictionary[Key.Id.rawValue] as! String
        email = dictionary[Key.Email.rawValue] as! String
        provider = dictionary[Key.Provider.rawValue] as! String
        
        if let name = dictionary[Key.Name.rawValue] as? String {
            self.name = name
        }
        
        if let patronymic = dictionary[Key.Patronymic.rawValue] as? String {
            self.patronymic = patronymic
        }
        
        if let surname = dictionary[Key.Surname.rawValue] as? String {
            self.surname = surname
        }
        
        if let phoneNumber = dictionary[Key.PhoneNumber.rawValue] as? String {
            self.phoneNumber = phoneNumber
        }
        
        // The above properties are assigned to their key.
        
        reference = DataService.sharedInstance.userReference.childByAppendingPath(key)
    }
    
    //--------------------------------------
    // MARK: - Instance Functions -
    //--------------------------------------
    
    func updateValuesWithCompletionBlock(block: (Bool, NSError?) -> Void) {
        reference.updateChildValues(self.value) { (error, ref) in
            if let _ = error {
                print("Data could not be saved with error: \(error.localizedDescription).")
                
                block(false, error)
            } else {
                print("Data saved successfully!")
                
                block(true, nil)
            }
        }
    }
    
}