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
        
        PFFacebookUtils.logInInBackground(withReadPermissions: ["email"]) { (user, error) in
            if let user = user {
                if user.isNew {
                    print("User signed up!")
                    self.getDataFromFacebookUserAccount(user: user)
                    
                } else {
                    print("User logged in through Facebook!")
                    self.getDataFromFacebookUserAccount(user: user)
                    //self.fetchProfile()
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    func getDataFromFacebookUserAccount (user: PFUser) {
        let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if result != nil {
                guard let data = result as? [String:Any] else { return }
                
                let fullname: String = data["name"] as! String
                print(fullname)
                
                if data["email"] == nil {
                    print("no email found")
                } else {
                    let email: String = data["email"] as! String
                    user.setObject(email, forKey: "email")
                }
                
                user.setObject(fullname, forKey: "fullName")
                user.saveInBackground(block: { (success, error) in
                    if success {
                        print("saved")
                    }
                })
            }
        })
    }
}

