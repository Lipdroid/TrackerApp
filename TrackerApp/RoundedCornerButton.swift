//
//  RoundedCornerButton.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/8/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit
@IBDesignable
class RoundedCornerButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
    }
    
    func setTitle(title: String){
        self.setTitle(title,for: .normal)
    }
    
    func getTitle()-> String{
        return self.title(for: .normal)!
    }

}
