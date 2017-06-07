//
//  User.swift
//
//
//  Created by Evan Latner on 6/1/17.
//
//

import Foundation
import Parse
import ParseFacebookUtilsV4

public class User {
    
    private static let _instance = User()
    static var Instance: User {
        return _instance
    }
    
    func login () {
        
        let permissions = [ "public_profile" ]
        PFFacebookUtils.logInInBackground(withReadPermissions: permissions) { (user, error) in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    print(user)
                } else {
                    print("User logged in through Facebook!")
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
}

