//
//  MaterialView.swift
//  DreamLister
//
//  Created by Lipu Hossain on 3/30/17.
//  Copyright © 2017 lipple. All rights reserved.
//

import UIKit


private var _isMaterialViewOn = false
extension UIView {

    @IBInspectable var materialView: Bool{
    
        
        get{
          return _isMaterialViewOn
        }
        set{
           _isMaterialViewOn = newValue
            
            if _isMaterialViewOn{
                self.layer.masksToBounds = false
                self.layer.cornerRadius = 3.0
                self.layer.shadowRadius = 3.0
                self.layer.shadowOpacity = 0.8
                self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
                self.layer.shadowColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1.0).cgColor
            }else{
                self.layer.cornerRadius = 0.0
                self.layer.shadowRadius = 0.0
                self.layer.shadowOpacity = 0.0
                self.layer.shadowColor = nil
            
            }
        
        }
    
    }

}
