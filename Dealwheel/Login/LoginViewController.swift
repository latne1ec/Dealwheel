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
import AVFoundation

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    var progressView: ProgressView!
    var videoPlayer: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage ()
        setLoginButtonDefaults()        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //initVideoPlayer()
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, with: .duckOthers)
//        } catch {
//            print("AVAudioSession cannot be set: \(error)")
//        }
    }
    
    func initVideoPlayer () {
        
        videoView.layer.cornerRadius = 6
        let videoURL = Bundle.main.url(forResource: "intronew", withExtension: "mp4")
        videoPlayer = AVPlayer(url: videoURL! as URL)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LoginViewController.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: self.videoPlayer?.currentItem)
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        //playerLayer.videoGravity = .as
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.frame = CGRect(x: 0, y: 0, width: self.videoView.bounds.width, height: self.videoView.bounds.height)
        self.videoView.layer.addSublayer(playerLayer)
        videoPlayer?.play()
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        self.videoPlayer?.seek(to: kCMTimeZero)
        self.videoPlayer?.play()
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
        
        videoPlayer?.pause()
        progressView = ProgressView()
        progressView.isHidden = false
        progressView.frame = self.view.frame
        self.view.addSubview(progressView)
        
        PFFacebookUtils.logInInBackground(withReadPermissions: ["email"]) { (user, error) in
            if let user = user {
                if user.isNew {
                    // User signed up!
                    self.getDataFromFacebookUserAccount(user: user)
                    self.videoPlayer?.pause()
                    
                } else {
                    // User logged in!
                    self.getDataFromFacebookUserAccount(user: user)
                    self.videoPlayer?.pause()
                }
            } else {
                // User canceled fb login
                self.videoPlayer?.play()
                self.progressView.isHidden = true
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
                user.setObject(3, forKey: "points")
                user.setObject(0, forKey: "numberOfPurchases")
                user.setObject(0, forKey: "grossSales")
                user.saveInBackground(block: { (success, error) in
                    if success {
                        // Saved Successfully
                        self.videoPlayer?.pause()
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
    
    @IBAction func privacyButtonTapped(_ sender: Any) {
        let url = URL(string: "http://dealwheelapp.com/privacy-policy");
        UIApplication.shared.open(url!, options: [:])
    }
    
}
