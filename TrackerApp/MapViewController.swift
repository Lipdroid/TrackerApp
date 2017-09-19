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
import AVFoundation

class MapViewController: UIViewController {
    var mUserObj: UserObject! = nil
    @IBOutlet weak var google_map: GMSMapView!
    @IBOutlet weak var user_image: CircleImageView!
    @IBOutlet weak var user_name_label: UILabel!
    let locationManager = CLLocationManager()
    
    var employees = [UserObject]()
    var marker_dict = Dictionary<String,GMSMarker>()
    var player : AVAudioPlayer?

    deinit {
        // Release all recoureces
        // perform the deinitialization
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

    }
    
    func intMarkerSound(){
        let url = Bundle.main.url(forResource: "marker_add", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func playMarkerAddSound(){
        if(player?.isPlaying)!{
            player?.stop()
        }
        player?.play()
    }

    @IBAction func currentLocation_btn_pressed(_ sender: Any) {
        guard let lat = mUserObj.user_login_lat,let lng = mUserObj.user_login_lng else {
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: (Double)(lat)!, longitude: (Double)(lng)!, zoom: MAP_ZOOM_LEVEL)
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
        intMarkerSound()
    }
    
    func getAllUserData(){
        Progress.sharedInstance.showLoading()
        print("start getting all user data")
        DADataService.instance.REF_COMPANY.child(mUserObj.companyName!).child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get all user
            print("finish getting all user data")
            Progress.sharedInstance.dismissLoading()
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                print("emplyoee count:\(snapshots.count)")
                //remove if their is any previous information about emplyoee/user
                self.employees.removeAll()
                for snap in snapshots {
                    if let user_snap = snap.value as? Dictionary<String, String>{
                        if let employee = self.parseUserSnap(uid: snap.key, userSnapDict: user_snap){
                            self.employees.append(employee)
                        }
                    }
                }
                
                //put markers for all the users/employee
                for employee in self.employees{
                    if(employee.userNodeId != self.mUserObj.userNodeId){
                        self.addUserMarker(userObj: employee)
                    }
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func parseUserSnap(uid: String,userSnapDict: Dictionary<String,String>)->UserObject?{
        var userObj = UserObject(authId: uid)
        
        guard let name = userSnapDict["userName"] else{
            return userObj
        }
        guard let imageUrl = userSnapDict["imageUrl"] else{
            return userObj
        }
        guard let email = userSnapDict["userEmail"] else{
            return userObj
        }
        guard let route = userSnapDict["userRouteStatus"] else{
            return userObj
        }
        guard let lat = userSnapDict["user_login_lat"] else{
            return userObj
        }
        guard let lng = userSnapDict["user_login_lng"] else{
            return userObj
        }
        
        userObj = UserObject(uid: uid, companyName: self.mUserObj.companyName!, email: email, userName: name, routeStatus: route, imageUrl: imageUrl, user_login_lat: lat, user_login_lng: lng)
        
        return userObj
    }
    
    func startObservingUserDataChange(){
        Progress.sharedInstance.showLoading()
        print("start observing")
        DADataService.instance.REF_COMPANY.child(mUserObj.companyName!).child("users").observe(.childChanged, with: { (snapshot) in
            // Get data changed user
            print("receive user data changed")
            if let user_snap = snapshot.value as? Dictionary<String, String>{
                if let employee = self.parseUserSnap(uid: snapshot.key, userSnapDict: user_snap){
                    if(employee.userNodeId != self.mUserObj.userNodeId){
                        self.employees.append(employee)
                    }
                    self.addUserMarker(userObj: employee)

                    }
            }
            
        }) { (error) in
            print(error.localizedDescription)
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
                locationManager.startUpdatingLocation()
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
            user_image.imageFromServerURL(urlString: imageUrl, defaultImage: "Default image link")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logout_btn_pressed(_ sender: Any) {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                Progress.sharedInstance.showLoading()
                //logout firebase user
                try FIRAuth.auth()?.signOut()
                //clear login locaition
                DADataService.instance.updateUserLoginLocation(uid: mUserObj.userNodeId!, companyName: mUserObj.companyName!, lat: LOGOUT_LAT, lng: LOGOUT_LNG){
                (response) in
                    //clear keychain
                    KeychainWrapper.standard.removeObject(forKey: Constants.KEY_UID)
                    KeychainWrapper.standard.removeObject(forKey: Constants.KEY_COMPANY)
                    Progress.sharedInstance.dismissLoading()
                    self.dismiss(animated: true, completion: nil)

                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }

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
            if let user_lat = mUserObj.user_login_lat,let user_lng = mUserObj.user_login_lng
            {
                //journey already started or just opened the app
                print("new location: lat:\(location.coordinate.latitude), lng:\(location.coordinate.longitude) user:\(user_lat),\(user_lng)")

            }else{
                mUserObj.user_login_lat = "\(location.coordinate.latitude)"
                mUserObj.user_login_lng = "\(location.coordinate.longitude)"
                DADataService.instance.updateUserLoginLocation(uid: mUserObj.userNodeId!, companyName: mUserObj.companyName!, lat: location.coordinate.latitude, lng: location.coordinate.longitude){
                    (response) in
                    self.getAllUserData()
                    self.startObservingUserDataChange()
                    self.google_map.camera = GMSCameraPosition(target: location.coordinate, zoom: MAP_ZOOM_LEVEL, bearing: 0, viewingAngle: 0)
                    self.addUserMarker(userObj: self.mUserObj)
                    self.locationManager.stopUpdatingLocation()
                }
                
            }
            

            
        }
        
    }
    
    func addUserMarker(userObj: UserObject){
        let location: CLLocation = CLLocation(latitude: (Double)(userObj.user_login_lat!)!, longitude: (Double)(userObj.user_login_lng!)!)
        
        guard var marker = marker_dict[userObj.userNodeId!] else {
            //add a new marker and save it to the dictionary
            let user_marker = GMSMarker()
            user_marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude ,longitude: location.coordinate.longitude)
            user_marker.title = userObj.userName
            user_marker.snippet = userObj.userEmail
            user_marker.appearAnimation = .pop
            createMarkerWithImage(url: userObj.imageUrl!)
            {(image) in
                if let marker_image = image as? UIImage{
                    user_marker.icon = marker_image
                    user_marker.map = self.google_map
                    self.playMarkerAddSound()
                    self.marker_dict[userObj.userNodeId!] = user_marker

                }
            }
            return
        }
        
        //remove the marker
        marker.map = nil
        marker_dict.removeValue(forKey: userObj.userNodeId!)
        //then add new marker
        marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude ,longitude: location.coordinate.longitude)
        marker.title = userObj.userName
        marker.snippet = userObj.userEmail
        marker.appearAnimation = .pop
        createMarkerWithImage(url: userObj.imageUrl!)
        {(image) in
            if let marker_image = image as? UIImage{
                marker.icon = marker_image
                marker.map = self.google_map
                self.playMarkerAddSound()
                self.marker_dict[userObj.userNodeId!] = marker
                
            }
        }
        
    }
    
    
       
}
