//
//  PrizeViewController.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/19/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import UIKit
import Parse

class PrizeViewController: UIViewController {
    
    @IBOutlet weak var wedgeImageView: UIImageView!
    @IBOutlet weak var dealTitleLabel: UILabel!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var detailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
        setWedgeColor()
        setDealTitle()
        NotificationCenter.default.addObserver(self, selector: #selector(PrizeViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PrizeViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func setBackgroundImage () {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bkg.jpg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    func setDealTitle () {
        if UIScreen.main.bounds.size.height > 667 {
            dealTitleLabel.font = UIFont(name: "BudmoJiggler-Regular", size: 26)
            detailsLabel.font = UIFont(name: "BudmoJiggler-Regular", size: 24)
        }
        dealTitleLabel.text = DataManager.Instance.getRandomPrize()
    }
    
    func setWedgeColor () {
        if DataManager.Instance.currentWedgeColor != nil {
            let imageNameString = String(format: "wedge%d", DataManager.Instance.currentWedgeColor!)
            wedgeImageView.image = UIImage(named: imageNameString)
        }
    }
    
    func saveWinnerToDatabase () {
        if(PFUser.current() == nil) {
            // No user?? Simulator Testing
        } else if self.emailTextfield.text == "" {
            let alert = UIAlertController(title: "Error", message: "Please enter a valid email address", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in })
            self.present(alert, animated: true)
        } else {
            let winner = PFObject(className:"Winners")
            winner["user"] = PFUser.current()
            winner["email"] = self.emailTextfield.text
            winner["winnerFullName"] = PFUser.current()?.object(forKey: "fullName")
            if PFUser.current()?.object(forKey: "email") != nil {
                winner["winnerEmail"] = PFUser.current()?.object(forKey: "email")
            }
            winner["prize"] = dealTitleLabel.text
            winner.saveInBackground(block: { (success, error) in
                if (success) {
                    // The winner has been saved, Segue back to Prizewheel
                    self.performSegue(withIdentifier: "backToPrizewheel", sender: self)
                } else {
                    // There was a problem
                    let alert = UIAlertController(title: "Error", message: "An unknown error occured", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in })
                    self.present(alert, animated: true)
                }
            })
        }
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        saveWinnerToDatabase()
    }
    
}
