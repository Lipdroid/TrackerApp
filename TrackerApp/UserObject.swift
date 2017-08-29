//
//  UserObject.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 8/28/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
class UserObject{
    private var _userName: String!
    
    var userName: String?{
        get{
        if _userName == nil {
            _userName = "No Name Available"
        }
        return _userName
        }
        set{
          _userName = newValue
        }
    }
    

    
}
