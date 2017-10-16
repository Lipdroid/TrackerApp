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
public let MAP_ZOOM_LEVEL:Float = 17.0
public let LOGOUT_LAT:Double = 0.0
public let LOGOUT_LNG:Double = 0.0

typealias Completion = (AnyObject)->()

struct Constants {
    static let STORYBOARD_MAIN = "Main"
    
    //storyboard identifiers
    static let LOGINVIEW_IDENTIFIER_STORYBOARD = "LoginViewController"
    static let MAPVIEW_IDENTIFIER_STORYBOARD = "MapViewController"
    
    //storyboard segue
    static let LOGINVIEW_TO_MAPVIEW_SEGUE_IDENTIFIER = "toMapSegue"
    static let LOGOUT_SEGUE_IDENTIFIER = "toLoginPage"
    static let CHATROOM_SEGUE_IDENTIFIER = "toChatPage"
    static let HISTORY_SEGUE_IDENTIFIER = "toHistoryPage"
    static let PROFILE_SEGUE_IDENTIFIER = "toProfilePage"
    static let USER_PROFILE_SEGUE_IDENTIFIER = "toUserProfilePage"
    static let ONBOARDING_LOGIN_SEGUE_IDENTIFIER = "onboardingToLoginPage"

    //user status on trip
    static let USER_ROUTE_STATUS_NOT_STARTED = "notStarted"
    static let USER_ROUTE_STATUS_ON_TRAFFIC = "onTraffic"
    static let USER_ROUTE_STATUS_WAITING = "waiting"
    static let USER_ROUTE_STATUS_TRIP_STARTED = "tripStarted"
    
    static let DEFAULT_COMPANY_NAME = "defaultCompany"
    static let DEFAULT_CHAT_COUNT = "0"
    static let KEY_UID = "uid"
    static let KEY_COMPANY = "companyName"

    static let STATUS_START = 0
    static let STATUS_TRAFFIC = 1
    static let STATUS_WAITING = 2
    static let STATUS_STOP = 3
    
    static let STATUS_ON_TRIP = "onTrip"
    static let STATUS_ON_FINISH = "onFinish"
    static let STATUS_ON_WAITING = "onWaiting"

    static var onChatPage = false;
    static let TRIP_ID = "trip_id"
    
    static let START_TRACKING = "START  TRACKING"
    static let STOP_TRACKING = "STOP  TRACKING"


}
