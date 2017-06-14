//
//  LoginViewController.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/6/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import ProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    var progressView: ProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage ()
        setLoginButtonDefaults()        
    }
    
    func setLoginButtonDefaults () {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginButton.imageView?.contentMode = .scaleAspectFit
    }
    
    func setBackgroundImage () {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bkg.jpg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    // MARK: - User tapped login button
    
    @objc func loginButtonTapped () {
        //ProgressHUD.show("", interaction: false)
        progressView = ProgressView()
        progressView.frame = self.view.frame
        self.view.addSubview(progressView)
        
        PFFacebookUtils.logInInBackground(withReadPermissions: ["email"]) { (user, error) in
            if let user = user {
                if user.isNew {
                    // User signed up!
                    self.getDataFromFacebookUserAccount(user: user)
                    
                } else {
                    // User logged in!
                    self.getDataFromFacebookUserAccount(user: user)
                }
            } else {
                // User canceled fb login
            }
        }
    }
    
    // MARK: - Get user data from facebook account
    func getDataFromFacebookUserAccount (user: PFUser) {
        let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if result != nil {
                guard let data = result as? [String:Any] else { return }
                let fullname: String = data["name"] as! String
                
                if data["email"] == nil {
                    // No email found
                } else {
                    let email: String = data["email"] as! String
                    user.setObject(email, forKey: "email")
                }
                // Save user info to Backend
                user.setObject(fullname, forKey: "fullName")
                user.setObject(0, forKey: "points")
                user.saveInBackground(block: { (success, error) in
                    if success {
                        // Saved Successfully
                        self.performSegue(withIdentifier: "showMainScreen", sender: self)
                    } else {
                        // An error occured trying to save user fb info
                        self.progressView.dismiss()
                        let alert = UIAlertController(title: "Error", message: "An unknown error occured", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in })
                        self.present(alert, animated: true)
                    }
                })
            }
        })
    }
}
