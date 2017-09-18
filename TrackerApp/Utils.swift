//
//  Utils.swift
//  TrackerApp
//
//  Created by Lipu Hossain on 9/19/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import Foundation
import UIKit

func createMarkerWithImage(url: String)-> UIImage{
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
    imageViewForUserProfile.image = convertURLToUIImage(imageUrl: url)
    
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
    return imageConverted
}

func convertURLToUIImage(imageUrl: String)->UIImage{
    let url = URL(string: imageUrl)
    let data = try? Data(contentsOf: url!)
    
    if let imageData = data {
        let image = UIImage(data: imageData)
        return image!
    }
    return UIImage()
}
