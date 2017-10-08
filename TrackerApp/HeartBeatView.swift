//
//  HeartBeatView.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/8/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit

class HeartBeatView: UIView {

    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
        let scaleAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 0.5
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.autoreverses = true
        scaleAnimation.fromValue = 1.2;
        scaleAnimation.toValue = 0.8;
        self.layer.add(scaleAnimation, forKey: "scale")
    }
    
}
