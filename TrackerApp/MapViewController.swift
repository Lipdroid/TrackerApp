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
import UserNotifications

class MapViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var mUserObj: UserObject! = nil
    @IBOutlet weak var google_map: GMSMapView!
    @IBOutlet weak var user_image: CircleImageView!
    @IBOutlet weak var user_name_label: UILabel!
    let locationManager = CLLocationManager()
    var player : AVAudioPlayer?

    @IBOutlet weak var currentLocationButtonView: UIView!
    @IBOutlet weak var right_nav_menu: UIView!//This is the right navigation view
    @IBOutlet weak var right_nav_view: UIView!//This is the top right userlist show view
    @IBOutlet weak var tranparent_overlay: UIVisualEffectView!
    @IBOutlet weak var right_nav_trailing_constraint: NSLayoutConstraint!
    var right_nav_view_isShown = false

    @IBOutlet weak var left_nav_btn_view: UIView!
    @IBOutlet weak var left_nav_menu: UIView!
    var left_nav_view_isShown = false
    @IBOutlet weak var left_nav_leading_constraint: NSLayoutConstraint!

    var employees = [UserObject]()
    var marker_dict = Dictionary<String,GMSMarker>()

    @IBOutlet weak var status_seg: UISegmentedControl!
    
    var status = Constants.STATUS_STOP
    var markerAnimationfinish = true

    @IBOutlet weak var status_lbl: UILabel!
    deinit {
        // Release all recoureces
        // perform the deinitialization
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

    }
    
    @IBAction func status_chage_pressed(_ sender: Any) {
        switch status_seg.selectedSegmentIndex {
        case Constants.STATUS_START:
            status_segment_enable(enable: true)
            locationManager.startUpdatingLocation()
            status = Constants.STATUS_START
            break
        case Constants.STATUS_TRAFFIC:
            status = Constants.STATUS_TRAFFIC
            scheduleNotification(inSeconds: 1, body: "THis is a test message for all", title: "Md Munir Hossain", subtitle: "Oceanize", completion: {(success) in
                if success{
                    print("succesfull scheduling")
                }else{
                    print("Error sending notification schedule")
                }
                
            })
        
            break
        case Constants.STATUS_WAITING:
            status = Constants.STATUS_WAITING
            reset_segment()
            break
        case Constants.STATUS_STOP:
            locationManager.stopUpdatingLocation()
            status_segment_enable(enable: false)
            self.status_seg.selectedSegmentIndex = 3;
            status = Constants.STATUS_STOP
            break
        default:
            break
        }
    }
    
    public func status_segment_enable(enable: Bool){
        if enable{
            self.status_seg.setEnabled(true, forSegmentAt: 1);
            self.status_seg.setEnabled(true, forSegmentAt: 2);
            self.status_seg.setEnabled(true, forSegmentAt: 3);
        }else{
            self.status_seg.setEnabled(false, forSegmentAt: 1);
            self.status_seg.setEnabled(false, forSegmentAt: 2);
            self.status_seg.setEnabled(false, forSegmentAt: 3);
        }
    }
    
    public func reset_segment(){
            self.status_seg.selectedSegmentIndex = UISegmentedControlNoSegment;

            self.status_seg.setEnabled(true, forSegmentAt: 0);
            self.status_seg.setEnabled(true, forSegmentAt: 1);
            self.status_seg.setEnabled(true, forSegmentAt: 2);
            self.status_seg.setEnabled(true, forSegmentAt: 3);
        
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        NotificationCenter.default.addObserver(self, selector:#selector(checkForLocationPermission), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        if(mUserObj != nil){
            setUserData()
        }
        intMarkerSound()
        
        //Request to user for permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound], completionHandler:{(granted,error) in
            if (granted){
                print("User granted Permission")
            }else{
                print(error?.localizedDescription ?? "Error!!!")
            }
            
        })

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell{
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    
    func configureCell(cell: UserCell,indexPath: IndexPath){
        if let item = employees[indexPath.row] as? UserObject{
            cell.configureCell(userObj: item)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("You selected cell number: \(indexPath.row)!")
        toggleRightMenu()
        self.performSegue(withIdentifier: Constants.PROFILE_SEGUE_IDENTIFIER, sender: nil)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.PROFILE_SEGUE_IDENTIFIER{
            if let dest: ProfileVC = segue.destination as? ProfileVC{
                let index = self.tableView.indexPathForSelectedRow
                let indexNumber = index?.row //0,1,2,3
                dest.mUserObj = self.employees[indexNumber!]
            }
        }else if segue.identifier == Constants.USER_PROFILE_SEGUE_IDENTIFIER{
            if let dest: ProfileVC = segue.destination as? ProfileVC{
                dest.mUserObj = self.mUserObj
            }
        }else if segue.identifier == Constants.CHATROOM_SEGUE_IDENTIFIER{
            if let dest: ChatRoomVC = segue.destination as? ChatRoomVC{
                dest.mUserObj = self.mUserObj
            }
        }
    }
    
    
    @IBAction func profile_icon_changed(_ sender: Any) {
        toggleLeftMenu()
        self.performSegue(withIdentifier: Constants.USER_PROFILE_SEGUE_IDENTIFIER, sender: nil)
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
                
                self.tableView.reloadData()
                
                //put markers for all the users/employee
                for employee in self.employees{
                    if(employee.userNodeId != self.mUserObj.userNodeId){
                        switch employee.status!{
                        case .OFFLINE:
                            print("\(employee.userName!) is logged out user")
                            break
                        case .ONLINE:
                            print("\(employee.userName!) is logged in user")
                            self.addUserMarker(userObj: employee)
                            break
                        }
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
        guard let status = userSnapDict["status"] else{
            return userObj
        }

        
        userObj = UserObject(uid: uid, companyName: self.mUserObj.companyName!, email: email, userName: name, routeStatus: route, imageUrl: imageUrl, user_login_lat: lat, user_login_lng: lng,status: status)
        
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
                    
                   //if already exist then remove that item
                    if let index = self.employees.index(where: { $0.userNodeId == employee.userNodeId }) {
                        self.employees.remove(at: index)
                        //continue do: arrPickerData.append(...)
                    }
                    //add that item again
                    self.employees.append(employee)
                    self.tableView.reloadData()
                    
                    //if offline no marker add
                    switch employee.status!{
                        case .OFFLINE:
                            print("\(employee.userName!) offline marker not added")
                            //remove if prevoiusly added
                            guard let marker = self.marker_dict[employee.userNodeId!] else {
                                return
                            }
                            marker.map = nil
                            self.marker_dict.removeValue(forKey: employee.userNodeId!)
                            
                        break
                        case .ONLINE:
                            print("\(employee.userName!) online marker not added")
                            self.addUserMarker(userObj: employee)
                            break
                        }

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
                DADataService.instance.updateUserLoginLocation(uid: mUserObj.userNodeId!, companyName: mUserObj.companyName!, lat: LOGOUT_LAT, lng: LOGOUT_LNG, status: .OFFLINE){
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
    
    @IBAction func nav_left_icon_pressed(_ sender: Any) {
        toggleLeftMenu()
    }
    
    @IBAction func transparent_view_touched(_ sender: Any) {
        //depending on whicn view is open it will toggle
        if(left_nav_view_isShown){
            toggleLeftMenu()
        }
        if(right_nav_view_isShown){
            toggleRightMenu()
        }
    }
    private func toggleLeftMenu(){
        if !left_nav_view_isShown{
            left_nav_leading_constraint.constant = 0
            left_nav_menu.layer.shadowOpacity = 1
            left_nav_menu.layer.shadowRadius = 6.0
            tranparent_overlay.isHidden = false
            left_nav_btn_view.isHidden = true
            
        }else{
            left_nav_leading_constraint.constant = -280
            
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
            
        }){(true) in
            if !self.left_nav_view_isShown{
                self.left_nav_menu.layer.shadowOpacity = 0
                self.tranparent_overlay.isHidden = true
                self.left_nav_btn_view.isHidden = false
            }else{
                self.left_nav_btn_view.isHidden = true
                
            }
            
        }
        
        left_nav_view_isShown = !left_nav_view_isShown
    }
    
    
    @IBAction func nav_right_icon_pressed(_ sender: Any) {
        toggleRightMenu()
    }
    
    private func toggleRightMenu(){
        if !right_nav_view_isShown{
            right_nav_trailing_constraint.constant = 0
            right_nav_menu.layer.shadowOpacity = 1
            right_nav_menu.layer.shadowRadius = 6.0
            tranparent_overlay.isHidden = false
            right_nav_view.isHidden = true
            currentLocationButtonView.isHidden = true
            
        }else{
            right_nav_trailing_constraint.constant = -280
            
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
            
        }){(true) in
            if !self.right_nav_view_isShown{
                self.right_nav_menu.layer.shadowOpacity = 0
                self.tranparent_overlay.isHidden = true
                self.currentLocationButtonView.isHidden = false
                self.right_nav_view.isHidden = false
            }else{
                self.currentLocationButtonView.isHidden = true
                self.right_nav_view.isHidden = true
                
            }
            
        }
        
        right_nav_view_isShown = !right_nav_view_isShown
    }
    
    @IBAction func home_btn_pressed(_ sender: Any) {
        toggleLeftMenu()
    }
    @IBAction func chat_btn_pressed(_ sender: Any) {
        toggleLeftMenu()
        self.performSegue(withIdentifier: Constants.CHATROOM_SEGUE_IDENTIFIER, sender: nil)

    }
    @IBAction func history_btn_pressed(_ sender: Any) {
        toggleLeftMenu()
        self.performSegue(withIdentifier: Constants.HISTORY_SEGUE_IDENTIFIER, sender: nil)
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
                let user_current_location = CLLocation(latitude: user_lat.toDouble()!, longitude: user_lng.toDouble()!)
                let user_new_location = CLLocation(latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)
                let distanceInMeters = user_current_location.distance(from: user_new_location) // result is in meters
                print("moved \(distanceInMeters) meters")
                if(distanceInMeters >= 20)
                {
                    // 1 mile = 1609 meters
                    // 1 kilometer = 1000 meters
                    if(self.status != Constants.STATUS_STOP){
                        if let marker = marker_dict[mUserObj.userNodeId!]{
                            if(self.markerAnimationfinish){
                                    self.markerAnimationfinish = false
                                    status_lbl.text = "Moving"
                                    anitmateMarkertoLocation(marker: marker, coordinates: CLLocationCoordinate2D(latitude: user_new_location.coordinate.latitude, longitude: user_new_location.coordinate.longitude), degrees: 0, duration: 3)
                            }else{
                                status_lbl.text = "Moving"
                            }
                        }
                    }else{
                        status_lbl.text = "UNAVAILABLE"
                        
                    }
                    
                }
                else
                {
                    // in of 1000
                    status_lbl.text = "Stopped"
                }

                if(self.status == Constants.STATUS_STOP){
                    locationManager.stopUpdatingLocation()
                }
            }else{
                mUserObj.user_login_lat = "\(location.coordinate.latitude)"
                mUserObj.user_login_lng = "\(location.coordinate.longitude)"
                DADataService.instance.updateUserLoginLocation(uid: mUserObj.userNodeId!, companyName: mUserObj.companyName!, lat: location.coordinate.latitude, lng: location.coordinate.longitude, status: .ONLINE){
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
    }
    
    
    func anitmateMarkertoLocation(marker: GMSMarker,coordinates: CLLocationCoordinate2D, degrees: CLLocationDegrees, duration: Double) {
        // Keep Rotation Short
        //if want to update the rotation also comment out these two lines
//        CATransaction.begin()
//        CATransaction.setAnimationDuration(0.5)
//        marker.rotation = degrees
//        CATransaction.commit()
        
        // Movement
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            print("Animation completed")
            self.markerAnimationfinish = true
            self.mUserObj.user_login_lat = "\(coordinates.latitude)"
            self.mUserObj.user_login_lng = "\(coordinates.longitude)"
        })
        CATransaction.setAnimationDuration(duration)
        marker.position = coordinates
        //if want to update the camerea also comment out these two lines
        // Center Map View
        //let camera = GMSCameraUpdate.setTarget(coordinates)
        //google_map.animate(with: camera)
        
        CATransaction.commit()
    }
    
}

