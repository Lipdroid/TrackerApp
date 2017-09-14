//
//  DADataService.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 8/30/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = FIRDatabase.database().reference()

class DADataService {
    static let instance = DADataService()
    
    private let _REF_BASE = DB_BASE
    private let _REF_COMPANY = DB_BASE.child("company")

    var REF_BASE: FIRDatabaseReference{
        return _REF_BASE
    }
    var REF_COMPANY: FIRDatabaseReference{
        return _REF_COMPANY
    }
    
    func createFirebaseDBUser(uid: String, userObject: UserObject){
        let user = ["userName": userObject.userName,
                    "userEmail": userObject.userEmail,
                    "imageUrl": userObject.imageUrl,
                    "userRouteStatus": userObject.userRouteStatus]
        
        REF_COMPANY.child(userObject.companyName!).child("users").child(uid).updateChildValues(user as Any as! [AnyHashable : Any])
        
        
    }

}
