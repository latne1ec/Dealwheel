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

class SpinwheelViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, SpinWheelControlDataSource, SpinWheelControlDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var spinWheelControl: SpinWheelControl!
    @IBOutlet weak var spinwheelImage: UIImageView!
    @IBOutlet weak var spinButton: UIButton!
    
    var locationManager = CLLocationManager()
    let categories = ["Food", "Fun", "Vacations", "Adventures", "Gifts", "Things to do"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundImage ()
        checkIfPreviousUser()
        initSpinWheel()
        
        spinButton.addTarget(self, action: #selector(spinTheWheel), for: .touchUpInside)
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = false
        
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
            self.performSegue(withIdentifier: "showLogin", sender: self)
        } else {
            // We have a User
            self.performSegue(withIdentifier: "showLogin", sender: self)
        }
    }
    
    @objc func spinTheWheel () {
        
        if CLLocationManager.authorizationStatus() == .denied {
            showLocationDeniedError()
            return
        }
        
        spinWheelControl.manualSpinValue = -5
        spinWheelControl.manuallySpinTheWheel()
        
    }
    
    @objc func EndSpin () {
        let radians: CGFloat = CGFloat(atan2f(Float(spinwheelImage.transform.b), Float(spinwheelImage.transform.a)))
        print(radians)
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
            pickerLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20)
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
        print("Value changed to " + String(self.spinWheelControl.selectedIndex))
    }
    func spinWheelDidEndDecelerating(spinWheel: SpinWheelControl) {
        print("The spin wheel did end decelerating.")
    }
    func spinWheelDidRotateByRadians(radians: Radians) {
        print("The wheel did rotate this many radians - " + String(describing: radians))
    }
}
