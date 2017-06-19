//
//  DealViewController.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/13/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import UIKit
import SafariServices
class DealViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var wedgeImageView: UIImageView!
    @IBOutlet weak var dealImageView: UIImageView!
    @IBOutlet weak var dealTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
        setDealImage()
        setDealTitle()
        setWedgeColor()
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
    func setDealImage () {
        
        if DataManager.Instance.dealImageUrlString != nil {
            let dealImageUrl = URL(string: DataManager.Instance.dealImageUrlString!)
            let data = try? Data(contentsOf: dealImageUrl!)
            if data != nil {
                dealImageView.image = UIImage(data: data!)
            }
            dealImageView.layer.cornerRadius = 5
        }
    }
    
    func setWedgeColor () {
         if DataManager.Instance.currentWedgeColor != nil {
            let imageNameString = String(format: "wedge%@", DataManager.Instance.currentWedgeColor!)
            wedgeImageView.image = UIImage(named: imageNameString)
        }
    }

    @IBAction func buyButtonTapped(_ sender: Any) {
        if let url = URL(string: DataManager.Instance.dealUrlString!) {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func respinButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "showMain", sender: self)
    }
}
