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

class User {
    
    //--------------------------------------
    // MARK: - Types
    //--------------------------------------
    
    enum Keys: String {
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
        
        dictionary[Keys.Id.rawValue] = id
        dictionary[Keys.Email.rawValue] = email
        dictionary[Keys.Provider.rawValue] = provider
        
        if let name = name {
            dictionary[Keys.Name.rawValue] = name
        }
        
        if let patronymic = patronymic {
            dictionary[Keys.Patronymic.rawValue] = patronymic
        }
        
        if let surname = surname {
            dictionary[Keys.Surname.rawValue] = surname
        }
        
        if let phoneNumber = phoneNumber {
            dictionary[Keys.PhoneNumber.rawValue] = phoneNumber
        }
        
        return dictionary
    }
    
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
    // MARK: - Initialize -
    //--------------------------------------
    
    /// Initialize the new User
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self.key = key
        
        self.id = dictionary[Keys.Id.rawValue] as! String
        self.email = dictionary[Keys.Email.rawValue] as! String
        self.provider = dictionary[Keys.Provider.rawValue] as! String
        
        if let name = dictionary[Keys.Name.rawValue] as? String {
            self.name = name
        }
        
        if let patronymic = dictionary[Keys.Patronymic.rawValue] as? String {
            self.patronymic = patronymic
        }
        
        if let surname = dictionary[Keys.Surname.rawValue] as? String {
            self.surname = surname
        }
        
        if let phoneNumber = dictionary[Keys.PhoneNumber.rawValue] as? String {
            self.phoneNumber = phoneNumber
        }
        
        // The above properties are assigned to their key.
        
        self.reference = DataService.sharedInstance.userReference.childByAppendingPath(key)
    }
    
    //--------------------------------------
    // MARK: - Behavior -
    //--------------------------------------
    
    func updateValuesWithCompletionBlock(block: (Bool, NSError?) -> Void) {
        self.reference.updateChildValues(self.value) { (error, ref) in
            if error != nil {
                print("Data could not be saved with error: \(error.localizedDescription).")
                
                block(false, error)
            } else {
                print("Data saved successfully!")
                
                block(true, nil)
            }
        }
    }
    
    class func fetchFacebookUserInfoWithCompletionHandler(block:(result: [String : String]?, error: NSError?) -> ()) {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "\(FacebookParameters.id), \(FacebookParameters.name), \(FacebookParameters.firstName), \(FacebookParameters.lastName), \(FacebookParameters.email)"]).startWithCompletionHandler({ (connection, result, error) in
            if error != nil {
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
        
        usersRef.queryOrderedByChild(Keys.Id.rawValue).queryEqualToValue(userId).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                block(false)
            } else {
                print("Found user with value: \(snapshot.value)")
                
                assert(snapshot.childrenCount == 1, "Founded user account must be unique.")
                
                block(true)
            }
        })
    }
}