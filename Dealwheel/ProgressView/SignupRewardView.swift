//
//  SignupRewardView.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/16/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import UIKit

class SignupRewardView: UIView {
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SignupRewardView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0.0
        }) { (success) in
        }
    }
}
