//
//  Utils.swift
//  TrackerApp
//
//  Created by Lipu Hossain on 9/19/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

var imageCache: NSCache<NSString, UIImage> =  NSCache()

 var onTrip = false

func createMarkerWithImage(url: String, completed: @escaping Completion){
    //check cache before creating"
    if let cached_marker_image = imageCache.object(forKey: url as NSString){
            print("marker from cache")
            completed (cached_marker_image)
        return
    }
    //download image in async task
    URLSession.shared.dataTask(with: NSURL(string: url)! as URL, completionHandler: { (data, response, error) -> Void in
        
        if error != nil {
            print(error ?? "downloading image failed \(error.debugDescription)")
            return
        }
        DispatchQueue.main.async(execute: { () -> Void in
            let image = UIImage(data: data!)
            ///Creating UIView for Custom Marker
            let DynamicView=UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            DynamicView.backgroundColor=UIColor.clear
            
            //Creating Marker Pin imageview for Custom Marker
            var imageViewForPinMarker : UIImageView
            imageViewForPinMarker  = UIImageView(frame:CGRect(x: 0, y: 0, width: 60, height: 60));
            imageViewForPinMarker.image = UIImage(named:"marker_window")
            
            //Creating User Profile imageview
            var imageViewForUserProfile : UIImageView
            imageViewForUserProfile  = UIImageView(frame:CGRect(x: 0, y: 0, width: 40, height: 40));
            imageViewForUserProfile.layer.cornerRadius = imageViewForUserProfile.frame.height/2
            imageViewForUserProfile.clipsToBounds = true
            imageViewForUserProfile.contentMode = .scaleAspectFill
            imageViewForUserProfile.image = image
            
            //set the profile pic in the center
            imageViewForUserProfile.center = CGPoint(x: imageViewForPinMarker.frame.size.width  / 2,
                 y: imageViewForPinMarker.frame.size.height / 3 + 2);
            
            //Adding userprofile imageview inside Marker Pin Imageview
            imageViewForPinMarker.addSubview(imageViewForUserProfile)
            
            //Adding Marker Pin Imageview isdie view for Custom Marker
            DynamicView.addSubview(imageViewForPinMarker)
            
            //Converting dynamic uiview to get the image/marker icon.
            UIGraphicsBeginImageContextWithOptions(DynamicView.frame.size, false, UIScreen.main.scale)
            DynamicView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let imageConverted: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            imageCache.setObject(imageConverted, forKey: url as NSString)
            print("marker downloaded")
            completed (imageConverted)
        })
        
    }).resume()
}

extension UIImageView {
    public func imageFromServerURL(urlString: String, defaultImage : String?) {
        if let di = defaultImage {
            self.image = UIImage(named: di)
        }
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }
    
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}

func getCurrentDate()->String{
    var currentDate:String!
    let date = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    
    let year =  components.year
    let month = components.month
    let day = components.day
    
    currentDate = "\(day ?? 00)-\(month ?? 00)-\(year ?? 0000)"
    return currentDate
}

func getCurrentTime()->String{
    var currentTime:String!
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    
    let timeString = formatter.string(from: Date())
    print(timeString)
    
    currentTime = timeString
    return currentTime
}

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
}

func scheduleNotification(inSeconds: TimeInterval,body: String,title: String,subtitle: String,completion: @escaping (_ Success: Bool)->()){
    //Create Image Content for notification
    
    //Create the notification content or body
    let notif_content = UNMutableNotificationContent()
    notif_content.title = title
    notif_content.body = body
    notif_content.subtitle = subtitle
    
    //add a sound
    notif_content.sound = UNNotificationSound.default()
    
    
    //Create notification Trigger
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
    
    //create a request for notification
    let request = UNNotificationRequest(identifier: "myNotification", content: notif_content, trigger: trigger)
    
    //add it to notificationCenter To show
    UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
        if error != nil {
            completion(false)
        }else{
            completion(true)
        }
    })
}
func randomTripID(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}



