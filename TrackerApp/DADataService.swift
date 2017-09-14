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
    
    func getUserFromFirebaseDB(uid: String, companyName: String, completed: @escaping Completion){
        var mUserObj = UserObject(authId: uid)
        REF_COMPANY.child(companyName).child("users").child(uid).observe(.value, with: { (snapshot) in
            // Get user value
            if let snap = snapshot.value as? Dictionary<String, String>{
                guard let name = snap["userName"] else{
                    return
                }
                guard let email = snap["userEmail"] else{
                    return
                }
                guard let imageUrl = snap["imageUrl"] else{
                    return
                }
                guard let userRoute = snap["userRouteStatus"] else{
                    return
                }
                
                mUserObj = UserObject(uid: uid, userName: name, userEmail: email, userCompany: companyName, imageUrl: imageUrl, userRoute: userRoute)
                
                completed(mUserObj)
                
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    

}
