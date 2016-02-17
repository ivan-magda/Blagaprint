//
//  Constants.swift
//  Blagaprint
//
//  Created by Иван Магда on 17.02.16.
//  Copyright © 2016 Blagaprint. All rights reserved.
//

import Foundation

struct UserDefaultsKeys {
    static let userId = "uid"
    static let email = "email"
    static let provider = "provider"
}

struct AuthProviders {
    static let password = "password"
    static let facebook = "facebook"
}

struct FacebookParameters {
    static let id = "id"
    static let name = "name"
    static let firstName = "first_name"
    static let lastName = "last_name"
    static let email = "email"
}
