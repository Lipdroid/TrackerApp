//
//  Shakeable.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/11/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
import UIKit
protocol Shakeable {}

extension Shakeable where Self: UIView{
    func shake()  {
        let animation = CABasicAnimation.init(keyPath: "position")
        animation.fromValue = NSValue(cgPoint: CGPoint.init(x: self.center.x - 5, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint.init(x: self.center.x + 5, y: self.center.y))
        
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.duration = 0.05
        
        self.layer.add(animation, forKey: "position")
        
    }
}
