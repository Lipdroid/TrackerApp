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
                    "userRouteStatus": userObject.userRouteStatus,
                    "user_current_lat":"\(LOGOUT_LAT)",
                    "user_current_lng":"\(LOGOUT_LNG)",
                    "status":"\(userObject.status?.rawValue ?? "online")",
                    "chat_notify_count":userObject.chat_notify_count]

        
        REF_COMPANY.child(userObject.companyName!).child("users").child(uid).updateChildValues(user as Any as! [AnyHashable : Any])
    }
    
    func getUserFromFirebaseDB(uid: String, companyName: String, callback: @escaping Completion){
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
                
                guard let status = snap ["status"] else{
                    return
                }
                guard let chat_notify_count = snap ["chat_notify_count"] else{
                    return
                }
                
                mUserObj = UserObject(uid: uid, userName: name, userEmail: email, userCompany: companyName, imageUrl: imageUrl, userRoute: userRoute, status: status, chat_notify_count: chat_notify_count)
                
                callback(mUserObj)
                
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    //update user login location lat lng
    func updateUserLoginLocation(uid: String,companyName: String,lat: Double,lng: Double,status: Status,callback: Completion?){
        let user_login_location = ["user_current_lat":"\(lat)",
                    "user_current_lng":"\(lng)",
                    "status": status.rawValue]
        REF_COMPANY.child(companyName).child("users").child(uid).updateChildValues(user_login_location as Any as! [AnyHashable : Any])
        if let callback = callback{
            callback("Success" as AnyObject)
        }
    }
    
    func createFirebaseDBChat(message: String, userObject: UserObject){
        let chat = ["message": message,
                    "senderName": userObject.userName,
                    "imageUrl": userObject.imageUrl,
                    "senderId": userObject.userNodeId,
                    "time":getCurrentTime(),
                    "date":getCurrentDate()]
        
        let newRef = REF_COMPANY.child(userObject.companyName!).child("chatGroup").childByAutoId()
        
        newRef.setValue(chat as Any as! [AnyHashable : Any])
    }
    
    func update_notification_count_for_user(uid: String,companyName: String,count: String,callback: Completion?){
        let chat_notify_count = ["chat_notify_count": count]
        REF_COMPANY.child(companyName).child("users").child(uid).updateChildValues(chat_notify_count as Any as! [AnyHashable : Any])
        if let callback = callback{
            callback("Success" as AnyObject)
        }
    }
    
    func get_chat_notify_count_by_user(uid: String,companyName: String,callback: Completion?){
        REF_COMPANY.child(companyName).child("users").child(uid).child("chat_notify_count").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let item = snapshot.value as? String{
                if let callback = callback{
                    callback(item as AnyObject)
                }
            }else{
                if let callback = callback{
                    callback(Constants.DEFAULT_CHAT_COUNT as String as AnyObject)
                }
            }
        })
    }
    
    func add_location_with_status(uid: String,companyName: String,status: String,latitude: Double,longitude: Double,callback: Completion?){
        let date = getCurrentDate()
        let time = getCurrentTime()
        let location = ["latitude": "\(latitude)",
                    "longitude": "\(longitude)",
                    "time": time]
        var newRef: FIRDatabaseReference!
        if onTrip{
             let trip_id = UserDefaults.standard.string(forKey: Constants.TRIP_ID)
             newRef = REF_COMPANY.child(companyName).child("userTrips").child(date).child(uid).child(trip_id!)
        }else{
            onTrip = true
            let trip_id = randomTripID(length: 20)
            let defaults = UserDefaults.standard
            defaults.set(trip_id, forKey: Constants.TRIP_ID)
            newRef = REF_COMPANY.child(companyName).child("userTrips").child(date).child(uid).child(trip_id)
            //add to history in firebase
            addHistoryByDate(uid: uid, companyName: companyName, date: date, tripId: trip_id)
        }
        var status_update_ref: FIRDatabaseReference!
        switch status {
        case Constants.STATUS_ON_TRIP:
            status_update_ref = newRef.child(Constants.STATUS_ON_TRIP).childByAutoId()
            break
        case Constants.STATUS_ON_WAITING:
            status_update_ref = newRef.child(Constants.STATUS_ON_WAITING).childByAutoId()
            break
        case Constants.STATUS_ON_FINISH:
            status_update_ref = newRef.child(Constants.STATUS_ON_FINISH).childByAutoId()
            break
        default:
            break
        }

        status_update_ref.setValue(location as Any as! [AnyHashable : Any])

    }
    
    func addHistoryByDate(uid: String,companyName: String,date: String,tripId: String){
        let history = ["trip": true]
        REF_COMPANY.child(companyName).child("history").child(uid).child(date).child(tripId).setValue(history as Any as! [AnyHashable : Any])
    }
}
