//
//  File.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/11/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
import UIKit
protocol Floatable {}

extension Floatable where Self: UIView{
    func float()  {
        let scaleAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        //scaleAnimation.duration = 0.5
        scaleAnimation.repeatCount = 0
        scaleAnimation.autoreverses = true
        scaleAnimation.fromValue = 1.0;
        scaleAnimation.toValue = 1.2;
        self.layer.add(scaleAnimation, forKey: "scale")
        
    }
}
