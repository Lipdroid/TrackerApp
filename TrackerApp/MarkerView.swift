//
//  MarkerView.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 8/29/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit

class MarkerView: UIView {

    override init(frame: CGRect) {
        //for using customview in code
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        //for using customview in IB
        super.init(coder: aDecoder)
        commonInit()

    }
    private func commonInit(){
        //we are going to do stuff here
        let view = Bundle.main.loadNibNamed("MarkerView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
    }
    
}
