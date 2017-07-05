//
//  InstructionsView.swift
//  Dealwheel
//
//  Created by Evan Latner on 7/4/17.
//  Copyright © 2017 dealwheel. All rights reserved.
//

import UIKit

class InstructionsView: UIView {
    
    var instructionsImageView: UIImageView?
    var instructionsImage: UIImage?

    override init (frame : CGRect) {
        super.init(frame : frame)
        
        instructionsImage = UIImage(named: "instructions")
        instructionsImageView = UIImageView(image: instructionsImage)
        instructionsImageView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        instructionsImageView?.contentMode = .scaleAspectFill
        self.addSubview(instructionsImageView!)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    open func dismiss () {
        self.alpha = 0.0
    }
}
