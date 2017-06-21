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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
        setWedgeColor()
        saveWinnerToDatabase()
        setDealTitle()
    }
    
    func setBackgroundImage () {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bkg.jpg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    func setDealTitle () {
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
        } else {
            let winner = PFObject(className:"Winners")
            winner["user"] = PFUser.current()
            winner["winnerFullName"] = PFUser.current()?.object(forKey: "fullName")
            if PFUser.current()?.object(forKey: "email") != nil {
                winner["winnerEmail"] = PFUser.current()?.object(forKey: "email")
            }
            winner["prize"] = "10 Amazon Gift Card"
            winner.saveInBackground(block: { (success, error) in
                if (success) {
                    // The winner has been saved.
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
        self.performSegue(withIdentifier: "backToPrizewheel", sender: self)
    }
    
}
