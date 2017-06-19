//
//  PrizeViewController.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/19/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import UIKit

class PrizeViewController: UIViewController {
    
    @IBOutlet weak var wedgeImageView: UIImageView!
    @IBOutlet weak var dealTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
    }
    
    func setBackgroundImage () {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bkg.jpg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    func setDealTitle () {
        dealTitleLabel.text = DataManager.Instance.dealTitle
    }
    
    func setWedgeColor () {
        if DataManager.Instance.currentWedgeColor != nil {
            let imageNameString = String(format: "wedge%d", DataManager.Instance.currentWedgeColor!)
            print(imageNameString)
            wedgeImageView.image = UIImage(named: imageNameString)
        }
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "showMain", sender: self)
    }
    
}
