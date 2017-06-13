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

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
        print(DataManager.Instance.responseDic)
    }
    
    func setBackgroundImage () {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "bkg.jpg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }

    @IBAction func buyButtonTapped(_ sender: Any) {
        
        if let url = URL(string: "http://apple.com") {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    @IBAction func respinButtonTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showMain", sender: self)
    }
}
