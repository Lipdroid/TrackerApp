//
//  DADataService.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 8/30/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
import Firebase
import FacebookLogin
import FBSDKLoginKit

enum SocialLoginType: String{
    case FACEBOOK = "facebook"
    case GOOGLE = "google"
}

class DADataService {
    static let instance = DADataService()
}
