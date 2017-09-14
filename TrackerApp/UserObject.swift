//
//  UserObject.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 8/28/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
class UserObject{
    private var _companyName: String!
    private var _userName: String!
    private var _userEmail: String!
    private var _userNodeId: String!
    private var _userRouteStatus: String!
    private var _imageUrl: String!
    
    
    //getters
    var companyName: String?{
        return _companyName
    }
    var userName: String?{
        return _userName
    }
    var userEmail: String?{
        return _userEmail
    }
    var userNodeId: String?{
            return _userNodeId
    }
    var userRouteStatus: String?{
            return _userRouteStatus
    }
    var imageUrl: String?{
            return _imageUrl
    }
    
    //initialize
    init(authId: String) {
        self._userNodeId = authId
    }
    
    init(authId: String, dict: Dictionary<String, AnyObject>) {
        _userRouteStatus = Constants.USER_ROUTE_STATUS_NOT_STARTED;
        _companyName = Constants.DEFAULT_COMPANY_NAME;
        self._userNodeId = authId
        if let name = dict["name"] as? String{
            _userName = name
        }
        if let email = dict["email"] as? String{
            _userEmail = email
        }
        if let picture = dict["picture"] as? Dictionary<String,AnyObject>{
            if let data = picture["data"] as? Dictionary<String,AnyObject>{
                if let imageUrl = data["url"] as? String{
                    _imageUrl = imageUrl
                }
            }
        }
    }

    
}
