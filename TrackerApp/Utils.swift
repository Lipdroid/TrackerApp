//
//  Utils.swift
//  TrackerApp
//
//  Created by Lipu Hossain on 9/19/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
import UIKit

var imageCache: NSCache<NSString, UIImage> =  NSCache()

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
            let DynamicView=UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            DynamicView.backgroundColor=UIColor.clear
            
            //Creating Marker Pin imageview for Custom Marker
            var imageViewForPinMarker : UIImageView
            imageViewForPinMarker  = UIImageView(frame:CGRect(x: 0, y: 0, width: 40, height: 50));
            imageViewForPinMarker.image = UIImage(named:"marker_window")
            
            //Creating User Profile imageview
            var imageViewForUserProfile : UIImageView
            imageViewForUserProfile  = UIImageView(frame:CGRect(x: 0, y: 0, width: 40, height: 35));
            imageViewForUserProfile.layer.cornerRadius = 5.0
            imageViewForUserProfile.clipsToBounds = true
            imageViewForUserProfile.contentMode = .scaleAspectFill
            imageViewForUserProfile.image = image
            
            //set the profile pic in the center
            //imageViewForUserProfile.center = CGPoint(x: imageViewForPinMarker.frame.size.width  / 2,
            //     y: imageViewForPinMarker.frame.size.height / 2);
            
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
    
    currentDate = "\(day ?? 00)/\(month ?? 00)/\(year ?? 0000)"
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


