//
//  NSUserDefaults+UpdateUserInfo.swift
//  Blagaprint
//
//  Created by Иван Магда on 22.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation

extension NSUserDefaults {
    
    func updateUserInfoWithDictionary(info: [String : String]?) {
        setValue(info?[User.Key.Id.rawValue], forKey: UserDefaultsKeys.userId)
        setValue(info?[User.Key.Email.rawValue], forKey: UserDefaultsKeys.email)
        setValue(info?[User.Key.Provider.rawValue], forKey: UserDefaultsKeys.provider)
        
        postUserBasedNotifications()
    }
    
    private func postUserBasedNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        if let _ = stringForKey(UserDefaultsKeys.userId) {
            notificationCenter.postNotificationName(NotificationName.DataListenerUserDidLogInNotification, object: nil)
        } else {
            notificationCenter.postNotificationName(NotificationName.DataListenerUserDidLogOutNotification, object: nil)
        }
    }
    
}