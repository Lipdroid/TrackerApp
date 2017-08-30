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

typealias Completion = ()->()

struct Constants {
    static let STORYBOARD_MAIN = "Main"
    
    //storyboard identifiers
    static let LOGINVIEW_IDENTIFIER_STORYBOARD = "LoginViewController"
    static let MAPVIEW_IDENTIFIER_STORYBOARD = "MapViewController"
    
    //storyboard segue
    static let LOGINVIEW_TO_MAPVIEW_SEGUE_IDENTIFIER = "toMapSegue"
    static let LOGOUT_SEGUE_IDENTIFIER = "toLoginPage"

    
    

}
