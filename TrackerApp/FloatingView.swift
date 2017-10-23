//
//  FloatingView.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/8/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit

class FloatingView: UIView {

    override func layoutSubviews() {
        //MARK: HOVER ANIMATION
               let hover = CABasicAnimation(keyPath: "position")
                hover.isAdditive = true
                hover.fromValue = NSValue(cgPoint: CGPoint.zero)
                hover.toValue = NSValue(cgPoint: CGPoint(x: 20.0, y: 0.0))
                hover.autoreverses = true
                hover.duration = 0.5
                hover.repeatCount = Float.infinity
                self.layer.add(hover, forKey: "myHoverAnimation")
        
      
    }

}
