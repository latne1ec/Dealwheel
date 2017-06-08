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

class SpinwheelViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, SpinWheelControlDataSource, SpinWheelControlDelegate {
    
    // Outlets
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var spinWheelControl: SpinWheelControl!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var spinButton: UIButton!
    @IBOutlet weak var centerView: UIView!
    
    // Vars
    var player: AVAudioPlayer?
    
    var locationManager = CLLocationManager()
    let categories = ["Food", "Fun", "Vacations", "Adventures", "Gifts", "Things to do"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //prepareSound()
        setBackgroundImage ()
        checkIfPreviousUser()
        initSpinWheel()
        
        spinButton.addTarget(self, action: #selector(spinTheWheel), for: .touchUpInside)
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = false
        
        if UIScreen.main.bounds.size.height > 568 {
            // iPhone 6
//            spinWheelControl.frame = CGRect(x: spinWheelControl.frame.origin.x, y: spinWheelControl.frame.origin.y, width: spinWheelControl.frame.width*1.5, height: spinWheelControl.frame.height*1.5)
            var civ: CGPoint = spinWheelControl.center
            civ.x = self.view.center.x
            civ.y = self.view.center.y+25
            spinWheelControl.center = civ
        } else if UIScreen.main.bounds.size.height > 667 {
            // iPhone Plus
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initLocationManager()
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
            usernameLabel.text = PFUser.current()?.object(forKey: "fullName") as? String
        }
    }
    
    @objc func playSound () {
        player?.play()
    }
    
    @objc func spinTheWheel () {
        
        if CLLocationManager.authorizationStatus() == .denied {
            showLocationDeniedError()
            return
        }
        spinWheelControl.manualSpinValue = -5
        spinWheelControl.manuallySpinTheWheel()
        
       // Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.playSound), userInfo: nil, repeats: true)
        
    }
    
    // Picker View Stuff
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
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        if (pickerLabel == nil) {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "AvenirNext-Bold", size: 21)
            pickerLabel?.textColor = UIColor.white
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        pickerLabel?.text = categories[row]
        return pickerLabel!;
    }
    
    
    // Location Callbacks
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
            print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        print(coord.latitude)
        print(coord.longitude)
        locationManager.stopUpdatingLocation()
    }
    
    // Spin Wheel Control
    func wedgeForSliceAtIndex(index: UInt) -> SpinWheelWedge {
        let wedge = SpinWheelWedge()
        return wedge
    }
    func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt {
        return 12
    }
    @objc func spinWheelDidChangeValue(sender: AnyObject) {
        //print("Value changed to " + String(self.spinWheelControl.selectedIndex))
        
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
        
    }
    func spinWheelDidEndDecelerating(spinWheel: SpinWheelControl) {
        print("The spin wheel did end decelerating.")
    }
    func spinWheelDidRotateByRadians(radians: Radians) {
        //print("The wheel did rotate this many radians - " + String(describing: radians))
    }
    
    func prepareSound() {
        let url = Bundle.main.url(forResource: "tick2", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else {
                print("why")
                return
            }
            player.prepareToPlay()
            
        } catch let error as NSError {
            print(error.description)
        }
    }
}


