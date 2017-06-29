//
//  DealView.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/9/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import UIKit
import SafariServices

class DealView: UIView, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var respinButton: UIButton!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "DealView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    open func setDefaults () {
        self.layer.cornerRadius = 4
        self.alpha = 0.0
        setBackgroundImage()
    }
    func setBackgroundImage () {
        UIGraphicsBeginImageContext(self.frame.size)
        UIImage(named: "bkg.jpg")?.draw(in: self.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
    
    
    @IBAction func respinButtonTapped(_ sender: Any) {
        hideView()
    }
    open func hideView () {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0.0
        }) { (success) in
            
        }
    }
    
    open func setWedgeColor (_ index: Int) {
        switch index {
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
    
    open func setDealValues (_ dic: Dictionary <String, Any>) {
        print(dic)
    }
    
    @IBAction func purchaseButtonTapped(_ sender: Any) {
        if let url = URL(string: "http://apple.com") {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            vc.delegate = self
            let topVC = UIApplication.shared.keyWindow?.rootViewController
            topVC?.present(vc, animated: true)
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("finished")
    }
}
