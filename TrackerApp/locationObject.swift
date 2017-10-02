//
//  locationObject.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 10/2/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
class locationObject {
    private var _latitude:String!
    private var _longitude: String!
    private var _time: String!
    
    var latitude: String{
        return _latitude
    }
    var longitude: String{
        return _longitude
    }
    var time: String{
        return _time
    }
    
    init(latitude: String,longitude: String,time: String) {
        self._latitude = latitude
        self._longitude = longitude
        self._time = time
    }
    
}
