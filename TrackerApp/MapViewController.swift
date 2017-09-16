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
    let locationManager = CLLocationManager()
    
    deinit {
        // Release all recoureces
        // perform the deinitialization
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

    }

    @IBAction func currentLocation_btn_pressed(_ sender: Any) {
        guard let lat = mUserObj.user_start_lat,let lng = mUserObj.user_start_lng else {
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: (Double)(lat)!, longitude: (Double)(lng)!, zoom: 15.0)
        google_map.animate(to: camera)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        NotificationCenter.default.addObserver(self, selector:#selector(checkForLocationPermission), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        if(mUserObj != nil){
            setUserData()
        }
    }
    
    func checkForLocationPermission(){
        if (CLLocationManager.locationServicesEnabled())
        {
            switch(CLLocationManager.authorizationStatus())
            {
            case .notDetermined, .restricted, .denied:
                print("User disabled Location permisson")
                showAlertForSettings()
                break
            case .authorizedAlways, .authorizedWhenInUse:
                print("User enabled Location permission")
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()add
                break
            }
            
        }else{
            showAlertForSettings()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForLocationPermission()
        
    }
    
    private func setUserData(){
        if let name = mUserObj.userName{
            user_name_label.text = name
        }
        //show image from image url
        
        
        if let imageUrl = mUserObj.imageUrl{
            user_image.image = convertURLToUIImage(imageUrl: imageUrl)
        }
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
        dismiss(animated: true, completion: nil)

    }
    private func showAlertForSettings(){
        // create the alert
        let alert = UIAlertController(title: "Alert", message: "Please enable your location service from settings to run this app", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: goToSystemSettings))
        //alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func goToSystemSettings(action: UIAlertAction) {
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
    
    }

}

// MARK: - CLLocationManagerDelegate
//An extension for showing user location
extension MapViewController: CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    //locationManager(_:didUpdateLocations:) executes when the location manager receives new location data.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if let user_lat = mUserObj.user_start_lat,let user_lng = mUserObj.user_start_lng
            {
                //journey already started or just opened the app
                print("new location: lat:\(location.coordinate.latitude), lng:\(location.coordinate.longitude) user:\(user_lat),\(user_lng)")

            }else{
                mUserObj.user_start_lat = "\(location.coordinate.latitude)"
                mUserObj.user_start_lng = "\(location.coordinate.longitude)"
                google_map.camera = GMSCameraPosition(target: location.coordinate, zoom: 18, bearing: 0, viewingAngle: 0)
                self.addMarker(location: location)
                locationManager.stopUpdatingLocation()
            }
            

            
        }
        
    }
    
    private func addMarker(location: CLLocation){
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
//        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15.0)
        // Creates a marker in the center of the map.
        let user_marker = GMSMarker()
        user_marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude ,longitude: location.coordinate.longitude)
        user_marker.title = mUserObj.userName
        user_marker.snippet = mUserObj.userEmail
        user_marker.appearAnimation = .pop
        user_marker.icon = createMarkerWithImage()
        user_marker.map = self.google_map
    
       // google_map.animate(to: camera)
        
    }
    
    func createMarkerWithImage()-> UIImage{
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
        imageViewForUserProfile.image = convertURLToUIImage(imageUrl: mUserObj.imageUrl!)
        
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
   
}
