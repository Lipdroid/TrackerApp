//
//  UserObject.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 8/28/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
import GoogleSignIn

enum Status: String{
    case ONLINE = "online"
    case OFFLINE = "offline"
}

class UserObject{
    private var _companyName: String!
    private var _userName: String!
    private var _userEmail: String!
    private var _userNodeId: String!
    private var _userRouteStatus: String!
    private var _imageUrl: String!
    private var _user_status = Status.OFFLINE
    private var _chat_notify_count:String!
    
    private var _user_current_lat: String!
    private var _user_current_lng: String!
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
    var chat_notify_count: String?{
        get{
            return _chat_notify_count
        }
        set{
            _chat_notify_count = newValue
        }
    }
    var user_current_lat: String?{
        get{
            return _user_current_lat
        }
        set{
            _user_current_lat = newValue
        }
    }
    var user_current_lng: String?{
        get{
            return _user_current_lng
        }
        set{
            _user_current_lng = newValue
        }
    }
    var status: Status?{
        get{
            switch _user_status {
                case Status.ONLINE:
                    return Status.ONLINE
                case Status.OFFLINE:
                    return Status.OFFLINE
                }
           }
    }
    
    //initialize
    init(authId: String) {
        self._userNodeId = authId
    }
    
    //for firebase User with lat lng
    init(uid: String,companyName: String,email: String,userName: String,routeStatus: String,imageUrl: String,user_current_lat
        :String,user_current_lng:String,status: String,chat_notify_count: String) {
        self._userNodeId = uid
        self._userName = userName
        self._companyName = companyName
        self._userEmail = email
        self._imageUrl = imageUrl
        self._userRouteStatus = routeStatus
        self._user_current_lat = user_current_lat
        self._user_current_lng = user_current_lng
        self._chat_notify_count = chat_notify_count
        switch status {
        case Status.ONLINE.rawValue:
            self._user_status = .ONLINE
        case Status.OFFLINE.rawValue:
            self._user_status = .OFFLINE
        default:
            break
        }
    }
    
    //this is for facebook user
    init(authId: String, dict: Dictionary<String, AnyObject>) {
        _userRouteStatus = Constants.USER_ROUTE_STATUS_NOT_STARTED;
        _companyName = Constants.DEFAULT_COMPANY_NAME;
        self._userNodeId = authId
        self._chat_notify_count = Constants.DEFAULT_CHAT_COUNT
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
    
    //this is for google user
    init(authId: String, user: GIDGoogleUser!) {
        _userRouteStatus = Constants.USER_ROUTE_STATUS_NOT_STARTED;
        _companyName = Constants.DEFAULT_COMPANY_NAME;
        self._userNodeId = authId
        self._chat_notify_count = Constants.DEFAULT_CHAT_COUNT
        if let name = user.profile.name{
            _userName = name
        }
        if let email = user.profile.email{
            _userEmail = email
        }
        let imageUrl = user.profile.imageURL(withDimension: 400).absoluteString
        _imageUrl = imageUrl

    }

    //for firebase User without lat lng
    init(uid: String,userName: String,userEmail: String,userCompany: String,imageUrl: String,userRoute:String,status: String,chat_notify_count: String) {
        self._userNodeId = uid
        self._userName = userName
        self._companyName = userCompany
        self._imageUrl = imageUrl
        self._userEmail = userEmail
        self._userRouteStatus = userRoute
        self._chat_notify_count = chat_notify_count
        switch status {
        case Status.ONLINE.rawValue:
            self._user_status = .ONLINE
        case Status.OFFLINE.rawValue:
            self._user_status = .OFFLINE
        default:
            break
        }

    }
    
}
