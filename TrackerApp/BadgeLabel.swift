//
//  BadgeLabel.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 9/28/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit

class BadgeLabel: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.red.cgColor
        self.backgroundColor = UIColor.red
        self.textColor = UIColor.white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }

}
