//
//  RoundedCornerView.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/8/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit

class RoundedCornerView: UITableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1.0).cgColor
    }
    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
 
    }
}
