//
//  PulseView.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/8/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit

class PulseView: UIView {

    override func layoutSubviews() {
        
        //MARK: Pulse ANIMATION
                let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
                pulseAnimation.duration = 1
                pulseAnimation.fromValue = 0.3
                pulseAnimation.toValue = 1
                pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                pulseAnimation.autoreverses = true
                pulseAnimation.repeatCount = .greatestFiniteMagnitude
                self.layer.add(pulseAnimation, forKey: "animateOpacity")
        
        
    }

}
