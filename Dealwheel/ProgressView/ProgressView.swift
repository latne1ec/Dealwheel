//
//  ProgressView.swift
//  Dealwheel
//
//  Created by Evan Latner on 6/12/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    var activityIndicator: UIActivityIndicatorView!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        self.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.backgroundColor = UIColor.black
        self.alpha = 0.75
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.isHidden = false
        activityIndicator.center = self.center
        activityIndicator.startAnimating()
        self.addSubview(activityIndicator)
        self.bringSubview(toFront: activityIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.center = self.center
    }
    
    open func dismiss () {
        self.alpha = 0.0
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

}
