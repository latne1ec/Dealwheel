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

class SpinwheelViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, SpinWheelControlDataSource, SpinWheelControlDelegate {
    
    // Outlets
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var spinWheelControl: SpinWheelControl!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var spinButton: UIButton!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var arrow: UIImageView!
    
    // Vars
    var currentCategory: String = ""
    var player: AVAudioPlayer?
    var spinning: Bool?
    var userLat: CLLocationDegrees?
    var userLon: CLLocationDegrees?
    var locationManager = CLLocationManager()
    var categories = ["Food", "Fun", "Vacations", "Adventures", "Gifts", "Things to do"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //prepareSound()
        setWheelAndArrowFrames()
        setBackgroundImage ()
        checkIfPreviousUser()
        initSpinWheel()
        initPickerView()
        currentCategory = categories[0]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            initLocationManager()
        }
    }
    
    // MARK: - Init Methods
    
    func setWheelAndArrowFrames () {
        // Set Spinwheel and Arrow frame manually per device size
        if UIScreen.main.bounds.size.height > 568 {
            // iPhone 6, 6s, and 7
            var arrowCenter: CGPoint = spinWheelControl.center
            arrowCenter.x = self.view.center.x
            arrowCenter.y = self.view.center.y-114
            arrow.center = arrowCenter
            spinWheelControl.frame.size.width = 290
            spinWheelControl.frame.size.height = 290
            var spinWheelCenter: CGPoint = spinWheelControl.center
            spinWheelCenter.x = self.view.center.x
            spinWheelCenter.y = self.view.center.y+25
            spinWheelControl.center = spinWheelCenter
            spinWheelControl.clear()
            spinWheelControl.drawWheel()
        }
        if UIScreen.main.bounds.size.height > 667 {
            // iPhone 6 Plus, 7 Plus
            var arrowCenter: CGPoint = spinWheelControl.center
            arrowCenter.x = self.view.center.x
            arrowCenter.y = self.view.center.y-115
            arrow.center = arrowCenter
            spinWheelControl.frame.size.width = 320
            spinWheelControl.frame.size.height = 320
            var spinWheelCenter: CGPoint = spinWheelControl.center
            spinWheelCenter.x = self.view.center.x
            spinWheelCenter.y = self.view.center.y+40
            spinWheelControl.center = spinWheelCenter
            spinWheelControl.clear()
            spinWheelControl.drawWheel()
        }
    }
    
    func initPickerView () {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = false
    }
    
    func initSpinWheel () {
        spinWheelControl.delegate = self
        spinWheelControl.dataSource = self
        spinWheelControl.reloadData()
        spinWheelControl.addTarget(self, action: #selector(spinWheelDidChangeValue), for: UIControlEvents.valueChanged)
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
    
    func checkIfPreviousUser() {
        if(PFUser.current() == nil) {
            // No User, show Login screen
            //self.performSegue(withIdentifier: "showLogin", sender: self)
        } else {
            // We have a User
            let firstNameString = PFUser.current()?.object(forKey: "fullName") as? String
            let firstName = firstNameString?.components(separatedBy: " ").first
            usernameLabel.text = firstName
        }
    }
    
    /// MARK: - Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        pickerView.subviews.forEach({
            $0.isHidden = $0.frame.height < 1.0
        })
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentCategory = categories[row]
        getDeal()
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        if (pickerLabel == nil) {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "BudmoJiggler-Regular", size: 22.5)
            pickerLabel?.textColor = UIColor.white
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        pickerLabel?.text = categories[row]
        return pickerLabel!;
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
    }
    
    // MARK: - Spin Wheel Control
    
    func wedgeForSliceAtIndex(index: UInt) -> SpinWheelWedge {
        let wedge = SpinWheelWedge()
        return wedge
    }
    func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt {
        return 12
    }
    @objc func spinWheelDidChangeValue(sender: AnyObject) {
        
        switch self.spinWheelControl.selectedIndex {
        case 0:
            print("yellow")
        case 1:
            print("orange 1")
        case 2:
            print("orange 2")
        case 3:
            print("orange 3")
        case 4:
            print("red")
        case 5:
            print("pink")
        case 6:
            print("purple")
        case 7:
            print("blue 1")
        case 8:
            print("blue 2")
        case 9:
            print("blue 3")
        case 10:
            print("green 1")
        case 11:
            print("green 2")
        default:
            print("default")
        }
        
        let view = DealView.instanceFromNib() as! DealView
        view.setDefaults()
        view.setWedgeColor(index: spinWheelControl.selectedIndex)
        view.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height-100)
        self.view.addSubview(view)
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = 1.0
        }) { (success) in
        }
        
    }
    
    func spinWheelDidEndDecelerating(spinWheel: SpinWheelControl) {
        print("The spin wheel did end decelerating.")
        spinWheelControl.isUserInteractionEnabled = true
    }
    func spinWheelDidRotateByRadians(radians: Radians) {
    }
    
    func prepareSound() {
        let url = Bundle.main.url(forResource: "tick2", withExtension: "mp3")!
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else {
                return
            }
            player.prepareToPlay()
            
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    
    // MARK: - Groupon API Methods
    
    // Merchant - name √
    // Title √
    // Large Image Url
    // Link
    
    func getDeal () {
        
        let urlString = String(format:"https://partner-api.groupon.com/deals.json?tsToken=US_AFF_0_201236_212556_0&lat=%f&lng=%f&filters=category:%@&offset=0&limit=1&sid=%@", userLat!, userLon!, getCurrentCategory(), (PFUser.current()?.objectId)!)
        print(urlString)
        
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                    
                let json = JSON(data: data!)
                //print(json["deals"][0])
                //print(json["deals"][0]["options"])
                //print(json["deals"][0]["options"][0]["title"])
                //print(json["deals"][0]["largeImageUrl"])
                
                if let merchantName = json["deals"][0]["merchant"]["name"].string {
                    print(merchantName)
                }
                if let dealTitle = json["deals"][0]["options"][0]["title"].string {
                    print(dealTitle)
                }
                if let dealUrl = json["deals"][0]["dealUrl"].string {
                    print(dealUrl)
                }
                if let dealImageUrl = json["deals"][0]["largeImageUrl"].string {
                    print(dealImageUrl)
                }
            }
        }).resume()
    }
    
    func detectIfUserMadePurchase () {
        let urlString = String(format:"https://partner-api.groupon.com/reporting/v2/order.json?clientId=01faac2db87949ba744486af455c30e03662bd78&group=TopCategory&date=[2017-01-01&date=2017-12-31]&campaign.currency=USD&Sid=%@", (PFUser.current()?.objectId)!)
        print(urlString)
        
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    print(json)
                    
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
    }
    
    func getCurrentCategory () -> String {
        
        switch pickerView.selectedRow(inComponent: 0) {
        case 0:
            return "food-and-drink"
        case 1:
            return "electronics"
        case 2:
            return "health-and-fitness"
        case 3:
            return "food-and-drink"
        case 4:
            return "food-and-drink"
        case 5:
            return "food-and-drink"
        case 6:
            return "food-and-drink"
        case 7:
            return "food-and-drink"
        case 8:
            return "food-and-drink"
        case 9:
            return "food-and-drink"
        case 10:
            return "food-and-drink"
        case 11:
            return "food-and-drink"
        default:
            return ""
        }
    }
}
