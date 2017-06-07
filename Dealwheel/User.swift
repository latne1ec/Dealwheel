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
}

