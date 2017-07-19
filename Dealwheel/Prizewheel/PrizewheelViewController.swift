//
//  PrizewheelViewController.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/20/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import UIKit
import Parse
import SpinWheelControl

class PrizewheelViewController: UIViewController, SpinWheelControlDelegate, SpinWheelControlDataSource {
    
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var spinWheelControl: SpinWheelControl!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userPointsLabel: UILabel!
    
    var spinning: Bool?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        spinning = false
        setBackgroundImage()
        setWheelAndArrowFrames()
        initSpinWheel()
        setUserData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        detectIfUserCanSpinPrizewheel()
        AudioManager.Instance.pauseMainScreenMusic()
        AudioManager.Instance.playPrizeWheelMusic()
    }
    
    func detectIfUserCanSpinPrizewheel () {
        if(PFUser.current() == nil) {
        } else {
            let numberOfPoints = PFUser.current()?.object(forKey: "points") as? Int
            if numberOfPoints! < DataManager.minPointsToSpinPrizewheel {
                spinWheelControl.isUserInteractionEnabled = false
                let alert = UIAlertController(title: "Not enough Points", message: "You do not have enough points to spin the Prizewheel! At least 10 points needed to spin.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                    self.performSegue(withIdentifier: "showDealwheel", sender: self)
                })
                self.present(alert, animated: true)
            }
        }
    }
    
    func setUserData () {
        if(PFUser.current() == nil) {
            // No user?? Simulator Testing
        } else {
            let firstNameString = PFUser.current()?.object(forKey: "fullName") as? String
            let firstName = firstNameString?.components(separatedBy: " ").first
            usernameLabel.text = firstName
            let numberOfPoints = PFUser.current()?.object(forKey: "points") as? Int
            userPointsLabel.text = String(format: "%d", numberOfPoints!)
        }
    }
    
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
    
    func initSpinWheel () {
        spinWheelControl.delegate = self
        spinWheelControl.dataSource = self
        spinWheelControl.reloadData()
        spinWheelControl.manualSpinValue = randomBetweenNumbers(firstNum: -3.2, secondNum: -8.1)
        spinWheelControl.addTarget(self, action: #selector(spinWheelDidChangeValue), for: UIControlEvents.valueChanged)
    }
    
    // Add some randomness to the spin wheel
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func setBackgroundImage () {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bkg.jpg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    @objc func spinWheelDidChangeValue(_ sender: AnyObject) {
        spinning = false
        AudioManager.Instance.playSoundForWedgeAtIndex(self.spinWheelControl.selectedIndex)
        DataManager.Instance.deductPointsForPrizeWheelSpin()
        DataManager.Instance.currentWedgeColor = self.spinWheelControl.selectedIndex
        showPrizeVC()
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
    
    func showPrizeVC () {
        self.performSegue(withIdentifier: "showPrizeVC", sender: self)
    }
    
    func wedgeForSliceAtIndex(index: UInt) -> SpinWheelWedge {
        let wedge = SpinWheelWedge()
        return wedge
    }
    func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt {
        return 12
    }

    @IBAction func goBackButtonTapped(_ sender: Any) {
        if spinning! {
            return
        }
        self.performSegue(withIdentifier: "showDealwheel", sender: self)
    }
}
