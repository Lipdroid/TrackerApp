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
    private var _userEmail: String!
    private var _userNodeId: String!
    private var _userRouteStatus: String!
    private var _imageUrl: String!
    
    
    
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
    var userEmail: String?{
        get{
            if _userEmail == nil {
                _userEmail = "No Email Available"
            }
            return _userEmail
        }
        set{
            _userName = newValue
        }
    }
    var userNodeId: String?{
        get{
            if _userNodeId == nil {
                _userNodeId = "No node  Available"
            }
            return _userNodeId
        }
    }
    var userRouteStatus: String?{
        get{
            if _userRouteStatus == nil {
                _userRouteStatus = "No route Status Available"
            }
            return _userRouteStatus
        }
        set{
            _userRouteStatus = newValue
        }
    }
    var imageUrl: String?{
        get{
            return _imageUrl
        }
        set{
            _imageUrl = newValue
        }
    }
    
    init(authId: String) {
        self._userNodeId = authId
    }

    
}
