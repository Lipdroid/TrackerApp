//
//  File.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 8/29/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
import GoogleMaps

public let MAP_API_KEY: String = "AIzaSyC3xIKFe9SiegwfaqP9WFAjLN53HaaBDm0"
public let destination_latitude: CLLocationDegrees = 23.887
public let destination_longitude: CLLocationDegrees = 90.622
public let MAP_ZOOM_LEVEL:Float = 15.0

typealias Completion = (AnyObject)->()

struct Constants {
    static let STORYBOARD_MAIN = "Main"
    
    //storyboard identifiers
    static let LOGINVIEW_IDENTIFIER_STORYBOARD = "LoginViewController"
    static let MAPVIEW_IDENTIFIER_STORYBOARD = "MapViewController"
    
    //storyboard segue
    static let LOGINVIEW_TO_MAPVIEW_SEGUE_IDENTIFIER = "toMapSegue"
    static let LOGOUT_SEGUE_IDENTIFIER = "toLoginPage"

    //user status on trip
    static let USER_ROUTE_STATUS_NOT_STARTED = "notStarted"
    static let USER_ROUTE_STATUS_ON_TRAFFIC = "onTraffic"
    static let USER_ROUTE_STATUS_WAITING = "waiting"
    static let USER_ROUTE_STATUS_TRIP_STARTED = "tripStarted"
    
    static let DEFAULT_COMPANY_NAME = "defaultCompany"
    static let KEY_UID = "uid"
    static let KEY_COMPANY = "companyName"




}
