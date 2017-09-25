//
//  HeaderShadowView.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 9/25/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit

class HeaderShadowView: UIView {

    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
    }

}
