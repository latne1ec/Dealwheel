//
//  SpinwheelViewController.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/1/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import SpinWheelControl
import AVFoundation
import SwiftyJSON
import UIDropDown

class SpinwheelViewController: UIViewController, CLLocationManagerDelegate, SpinWheelControlDataSource, SpinWheelControlDelegate {
    
    // Outlets
    @IBOutlet weak var dropDown: UIDropDown!
    @IBOutlet weak var redeemButton: UIButton!
    @IBOutlet weak var spinWheelControl: SpinWheelControl!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var spinButton: UIButton!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var arrow: UIImageView!
   
    
    // Vars
    var currentCategory: String = ""
    var player: AVAudioPlayer?
    var userLat: CLLocationDegrees?
    var userLon: CLLocationDegrees?
    var locationManager = CLLocationManager()
    var lastDegree: CGFloat?
    var spinning: Bool?
    var dealMode: Bool?
    var categories = ["Automotive", "Auto And Home Improvement", "Baby Kids and Toys", "Beauty and Spas", "Collectibles", "Cruise Travel", "Electronics", "Entertainment and Media", "Flights and Transportation", "Food and Drink", "For the Home", "Groceries Household and Pets", "Health and Beauty", "Health and Fitness", "Home Improvement", "Hotels and Accommodations", "Jewelry and Watches", "Mens Clothing Shoes and Accessories", "Personal Services", "Sports and Outdoors", "Retail", "Things to do", "Tour Travel", "Womens Clothing Shoes and Accessories"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinning = false
        checkIfPreviousUser()
        setWheelAndArrowFrames()
        setBackgroundImage ()
        initSpinWheel()
        initDropDown()
        initRewardView()
        currentCategory = categories[0]
        redeemButton.imageView?.contentMode = .scaleAspectFit
        redeemButton.addTarget(self, action: #selector(redeemButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            initLocationManager()
            AudioManager.Instance.playMainScreenMusic()
            AudioManager.Instance.initTickNoisePlayer()
            DataManager.Instance.detectIfUserMadePurchase()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Adjust Dropdown Title to center of Device
        dropDown.title.frame = CGRect(x: 0, y: 0, width: dropDown.frame.width, height: dropDown.frame.height)
        dropDown.alpha = 1.0
    }
    
    func checkIfPreviousUser() {
        if(PFUser.current() == nil) {
            // No User, show Login screen
            self.performSegue(withIdentifier: "showLogin", sender: self)
        } else {
            // We have a User
            let firstNameString = PFUser.current()?.object(forKey: "fullName") as? String
            let firstName = firstNameString?.components(separatedBy: " ").first
            usernameLabel.text = firstName
            let numberOfPoints = PFUser.current()?.object(forKey: "points") as? Int
            pointsLabel.text = String(format: "%d", numberOfPoints!)
            pointsLabel.adjustsFontSizeToFitWidth = true
        }
    }
    
    @objc func redeemButtonTapped () {
        if spinning! {
            return
        }
        self.performSegue(withIdentifier: "showPrizewheel", sender: self)
    }
    
    // MARK: - Init Methods
    
    func setWheelAndArrowFrames () {
        
        // Set Spinwheel and Arrow frame manually per device size
        if UIScreen.main.bounds.size.height > 568 {
            // iPhone 6, 6s, and 7
            var arrowCenter: CGPoint = spinWheelControl.center
            arrowCenter.x = self.view.center.x
            arrowCenter.y = self.view.center.y-98
            arrow.center = arrowCenter
            spinWheelControl.frame.size.width = 290
            spinWheelControl.frame.size.height = 290
            var spinWheelCenter: CGPoint = spinWheelControl.center
            spinWheelCenter.x = self.view.center.x
            spinWheelCenter.y = self.view.center.y+45
            spinWheelControl.center = spinWheelCenter
            spinWheelControl.clear()
            spinWheelControl.drawWheel()
        }
        if UIScreen.main.bounds.size.height > 667 {
            // iPhone 6 Plus, 7 Plus
            var arrowCenter: CGPoint = spinWheelControl.center
            arrowCenter.x = self.view.center.x
            arrowCenter.y = self.view.center.y-95
            arrow.center = arrowCenter
            spinWheelControl.frame.size.width = 320
            spinWheelControl.frame.size.height = 320
            var spinWheelCenter: CGPoint = spinWheelControl.center
            spinWheelCenter.x = self.view.center.x
            spinWheelCenter.y = self.view.center.y+65
            spinWheelControl.center = spinWheelCenter
            spinWheelControl.clear()
            spinWheelControl.drawWheel()
        }
    }
    
    func initDropDown () {
        let image = UIImage(named: "bkg.jpg")
        dropDown.title.layoutIfNeeded()
        dropDown.setNeedsLayout()
        dropDown.layoutIfNeeded()
        dropDown.cornerRadius = 8
        dropDown.animationType = .classic
        dropDown.rowBackgroundColor = UIColor.white
        dropDown.backgroundColor = UIColor(patternImage: image!) //UIColor.clear
        dropDown.textColor = UIColor.white
        dropDown.optionsTextColor = UIColor.darkText
        dropDown.optionsTextAlignment = .center
        dropDown.font = "BudmoJiggler-Regular"
        dropDown.fontSize = 22
        dropDown.tableHeight = 250
        dropDown.hideOptionsWhenSelect = true
        dropDown.placeholder = "Select category"
        dropDown.options = categories
        dropDown.alpha = 0.0
        dropDown.didSelect { (option, index) in
            self.retrieveDeal()
        }
    }
    
    func initSpinWheel () {
        spinWheelControl.delegate = self
        spinWheelControl.dataSource = self
        spinWheelControl.reloadData()
        spinWheelControl.addTarget(self, action: #selector(spinWheelDidChangeValue), for: UIControlEvents.valueChanged)
    }
    
    func initRewardView () {
        if PFUser.current() != nil {
            let value = UserDefaults.standard.bool(forKey: "hasShown50PointSignupReward")
            if value == false {
                UserDefaults.standard.set( true, forKey: "hasShown50PointSignupReward")
                let signupRewardView = SignupRewardView.instanceFromNib()
                signupRewardView.frame = self.view.frame
                signupRewardView.alpha = 0.0
                self.view.addSubview(signupRewardView)
                UIView.animate(withDuration: 0.25, animations: {
                    signupRewardView.alpha = 1.0
                }) { (success) in
                }
            }
        }
    }
    
    func initLocationManager () {
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        if CLLocationManager.authorizationStatus() == .denied {
            showLocationDeniedError()
        }
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    func showLocationDeniedError () {
        let alert = UIAlertController(title: "Enable Location", message: "Dealwheel needs access to your location when using the app to find deals in your area. To turn on location services, open your device settings, find Dealwheel, tap Location, tap \"While using the app.\"", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in })
        self.present(alert, animated: true)
    }
    
    func setBackgroundImage () {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bkg.jpg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    @IBAction func instructionsButtonTapped(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Instructions") as! TutorialViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Location Callbacks
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
            print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        userLat = coord.latitude
        userLon = coord.longitude
        locationManager.stopUpdatingLocation()
        retrieveDeal()
    }
    
    // MARK: - Spin Wheel Control
    
    func wedgeForSliceAtIndex(index: UInt) -> SpinWheelWedge {
        let wedge = SpinWheelWedge()
        return wedge
    }
    func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt {
        return 12
    }
    @objc func spinWheelDidChangeValue(_ sender: AnyObject) {
        lastDegree = 100
        AudioManager.Instance.playSoundForWedgeAtIndex(self.spinWheelControl.selectedIndex)
        DataManager.Instance.currentWedgeColor = self.spinWheelControl.selectedIndex
        showDealVC()

    }
    
    func spinWheelDidEndDecelerating(spinWheel: SpinWheelControl) {
        AudioManager.Instance.stopSpinSound()
        spinWheelControl.isUserInteractionEnabled = true
        spinning = false
    }
    
    func spinWheelDidRotateByRadians(radians: CGFloat) {
        spinning = true
    }
    
    func userEndedTouchInteraction(spinWheel: SpinWheelControl) {
        AudioManager.Instance.playSpinSound()

    }
    
    func showDealVC () {
        if DataManager.Instance.dealTitle != nil {
            self.performSegue(withIdentifier: "showDeal", sender: self)
        } else {
            let alert = UIAlertController(title: "No deals", message: "There are currently no deals available in this area. Please try again later!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in })
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Data Helper Methods
    
    func retrieveDeal () {
        
        if PFUser.current() == nil {
            let urlString2 = String(format:"https://partner-api.groupon.com/deals.json?tsToken=US_AFF_0_207463_212556_0&lat=%f&lng=%f&filters=category:%@&offset=0&limit=1&sid=%@", 37.776072, -122.417696, getCurrentCategory(), "12345")
            let dasUrl = URL(string: urlString2)
            DataManager.Instance.getDeal(dasUrl!)
            return
        }
        
        let urlString = String(format:"https://partner-api.groupon.com/deals.json?tsToken=US_AFF_0_207463_212556_0&lat=%f&lng=%f&filters=category:%@&offset=0&limit=1&sid=%@", userLat!, userLon!, getCurrentCategory(), (PFUser.current()?.objectId)!)
        let url = URL(string: urlString)
        
        DataManager.Instance.getDeal(url!)
    }
    
    func getCurrentCategory () -> String {
        if dropDown.selectedIndex == nil {
            let randomIndex = Int(arc4random_uniform(UInt32(categories.count)))
            return getCategoryParsed(categories[randomIndex])
        } else {
            return getCategoryParsed(categories[dropDown.selectedIndex!])
        }
    }
    
    func getCategoryParsed (_ category: String) -> String {
        let lowercasedCategory = category.lowercased()
        let newString = lowercasedCategory.replacingOccurrences(of: " ", with: "-")
        return newString
    }
}
