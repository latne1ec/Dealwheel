//
//  SpinwheelViewController.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/1/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import UIKit
import Parse

class SpinwheelViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var spinwheelImage: UIImageView!
    @IBOutlet weak var spinButton: UIButton!
    
    let categories = ["Food", "Fun", "Vacations", "Adventures", "Gifts", "Things to do"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundImage ()
        checkIfUserLoggedIn()
        
        spinButton.addTarget(self, action: #selector(spinTheWheel), for: .touchUpInside)
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = false
    }
    
    func setBackgroundImage () {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bkg.jpg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    func checkIfUserLoggedIn() {
        if(PFUser.current() != nil) {
            self.performSegue(withIdentifier: "showLogin", sender: self)
        } else {
            self.performSegue(withIdentifier: "showLogin", sender: self)
        }
    }
    
    @objc func spinTheWheel () {
        
        let rotations: CGFloat = 6
        let duration: CGFloat = 7
        let anim = CAKeyframeAnimation(keyPath: "transform.rotation")
        let touchUpStartAngle: CGFloat = CGFloat(arc4random_uniform(10))
        // Random Number here
        let touchUpEndAngle: CGFloat = (.pi)
        let angularVelocity: CGFloat = CGFloat((((2 * .pi) * rotations) + .pi) / duration)
        anim.values = [(touchUpStartAngle), (touchUpStartAngle + angularVelocity * duration)]
        anim.duration = CFTimeInterval(duration)
        anim.autoreverses = false
        anim.repeatCount = 1
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        spinwheelImage.layer.add(anim, forKey: nil)
        spinwheelImage.transform = CGAffineTransform(rotationAngle: touchUpStartAngle + (touchUpEndAngle));

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
}
