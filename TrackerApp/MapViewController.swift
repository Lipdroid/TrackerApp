//
//  MapViewController.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 8/28/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit
import Firebase
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn
import GoogleMaps
import SwiftKeychainWrapper


class MapViewController: UIViewController {
    var mUserObj: UserObject! = nil

    @IBOutlet weak var google_map: GMSMapView!
  
    @IBOutlet weak var user_image: CircleImageView!
    @IBOutlet weak var user_name_label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        initMaps()
        if(mUserObj != nil){
            setUserData()
        }
        
        
    }
    
    private func setUserData(){
        if let name = mUserObj.userName{
            user_name_label.text = name
        }
        //show image from image url
        if let imageUrl = mUserObj.imageUrl{
            let url = URL(string: imageUrl)
            let data = try? Data(contentsOf: url!)
        
            if let imageData = data {
                let image = UIImage(data: imageData)
                user_image.image = image
            }
        }else{
            print("no image found")
        }
        
    }
    
    private func initMaps(){
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: destination_latitude, longitude: destination_latitude, zoom: 15.0)

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: destination_latitude, longitude: destination_latitude)
        marker.title = "Oceanize"
        marker.snippet = "Bangladesh"
        marker.appearAnimation = .pop
        //marker.iconView = MarkerView()
       // marker.map = self.google_map

        google_map.animate(to: camera)
        
        // Delay the dismissal by 5 seconds
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            self.addMarker()
        }


    }
    private func addMarker(){
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: destination_latitude, longitude: destination_latitude, zoom: 15.0)
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: destination_latitude, longitude: destination_latitude)
        marker.title = "Oceanize"
        marker.snippet = "Bangladesh"
        marker.appearAnimation = .pop
        //marker.iconView = MarkerView()
        marker.map = self.google_map
        
        google_map.animate(to: camera)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logout_btn_pressed(_ sender: Any) {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                //clear keychain
                KeychainWrapper.standard.removeObject(forKey: Constants.KEY_UID)
                KeychainWrapper.standard.removeObject(forKey: Constants.KEY_COMPANY)
                //logout firebase user
                try FIRAuth.auth()?.signOut()
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
