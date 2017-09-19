//
//  CircleImageView.swift
//  TrackerApp
//
//  Created by Lipu Hossain on 9/14/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit
@IBDesignable
class CircleImageView: UIImageView {
    override func awakeFromNib() {
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        
    }

    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
}
