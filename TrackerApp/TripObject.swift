//
//  TripObject.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/2/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
class TripObject {
    private var _user_start_lat: String!
    private var _user_start_lng: String!
    private var _user_current_lat: String!
    private var _user_current_lng: String!
    var onTrip_lat_array:[String] = [String]()
    var onTrip_lng_array:[String] = [String]()
    
    var onTripLocation = [locationObject]()
    var onWaitingLocation = [locationObject]()
    var onFinishLocation = [locationObject]()

    //getters
    var user_start_lat: String?{
        return _user_start_lat
    }
    var user_start_lng: String?{
        return _user_start_lng
    }
    var user_current_lat: String?{
        return _user_current_lat
    }
    var user_current_lng: String?{
        return _user_current_lng
    }
}
