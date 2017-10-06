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

class MapViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    let TAG = "MapViewController"
    @IBOutlet weak var searchBar: UISearchBar!
    
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
    var filter_employee = [UserObject]()
    var marker_dict = Dictionary<String,GMSMarker>()

    @IBOutlet weak var status_seg: UISegmentedControl!
    
    var status = Constants.STATUS_STOP
    var markerAnimationfinish = true

    @IBOutlet weak var status_lbl: UILabel!
    var chats = [ChatObject]()

    @IBOutlet weak var badge: UILabel!
    var isSearching = false
    
    var allUserTripsDict = [String: [TripObject]]()
    var tripObjects = [TripObject]()
    var tripObj:TripObject!
    
    var allUserDict = [String: UserObject]()
    
    deinit {
        // Release all recoureces
        // perform the deinitialization
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "refreshChatList"), object: nil)

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
            onTrip = true;
            break
        case Constants.STATUS_WAITING:
            onTrip = true;
            status = Constants.STATUS_WAITING
            //reset_segment()
            break
        case Constants.STATUS_STOP:
            DADataService.instance.update_userRouteStatus(uid: mUserObj.userNodeId!, companyName: mUserObj.companyName!, status: Constants.STATUS_ON_FINISH, callback: nil)
            locationManager.stopUpdatingLocation()
            status_segment_enable(enable: false)
            self.status_seg.selectedSegmentIndex = 3;
            status = Constants.STATUS_STOP
            status_lbl.text = "Finish"
            DADataService.instance.add_location_with_status(uid: self.mUserObj.userNodeId!, companyName: self.mUserObj.companyName!, status: Constants.STATUS_ON_FINISH, latitude: (Double)(mUserObj.user_current_lat!)!, longitude: (Double)(mUserObj.user_current_lng!)!, callback: nil)
            onTrip = false;
            break
        default:
            break
        }
    }
    
    func startObservingChatDataChange(){
        print("\(self.TAG): start observing messagese")
        DADataService.instance.REF_COMPANY.child(mUserObj.companyName!).child("chatGroup").queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
            print("\(self.TAG): receive chat data changed")
            if let chat_snap = snapshot.value as? Dictionary<String, String>{
                
                if let chat = self.parseChatSnap(chatId: snapshot.key,chatSnapDict: chat_snap){
                    if let index = self.chats.index(where: { $0.chatId == chat.chatId }) {
                        self.chats.remove(at: index)
                        //do nothing
                    }
                    //add that item
                    self.chats.append(chat)
                    
                    if self.mUserObj.userNodeId != chat.senderId{
                            //if the user is not in chat page then show the notification
                            if(!Constants.onChatPage){
                                //as observer runs first for the first time it gives the last message so
                                //do not show it
                                if let user_seen = Int(self.mUserObj.chat_notify_count!){
                                    //if chat list size is lesser that means its for the first time observer called
                                    if self.chats.count > user_seen{
                                        //show a notification
                                        scheduleNotification(inSeconds: 1, body: chat.message, title: chat.senderName, subtitle: chat.time, completion: {(success) in
                                                if success{
                                                    print("\(self.TAG): succesfull scheduling")
                                                }else{
                                                    print("\(self.TAG): Error sending notification schedule")
                                                }
                                        })
                                    }
                                }
                            }else{
                                //as the user is in chat page so user is up to date
                                //update its status
                                self.userNotificationStatusUptoDate()
                            }
                        }else{
                            //as the user itself make the chat so no need to notify him
                             self.userNotificationStatusUptoDate()
                        }
                        self.count_show_badge()
                        //update chat list in chat room vc
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshChatList"), object: nil,userInfo:["snap": chat])

                }

            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func userNotificationStatusUptoDate(){
        let user_seen = Int(self.mUserObj.chat_notify_count!)!
        let total_chat = self.chats.count
        var update_current_user_count = 0
        if user_seen > total_chat{
            update_current_user_count = user_seen
        }else{
            update_current_user_count = self.chats.count
        }
        self.mUserObj.chat_notify_count = "\(update_current_user_count)"
        //update current user DB firebase
        DADataService.instance.update_notification_count_for_user(uid: self.mUserObj.userNodeId!, companyName: self.mUserObj.companyName!, count: "\(update_current_user_count)"){(response) in
        }
    }
    
    func getAllChatData(){
        DADataService.instance.REF_COMPANY.child(Constants.DEFAULT_COMPANY_NAME).child("chatGroup").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get all user
            print("\(self.TAG): finish getting chat data")
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                print("\(self.TAG): chat count:\(snapshots.count)")
                //remove if their is any previous information about emplyoee/user
                self.chats.removeAll()
                for snap in snapshots {
                    if let chat_snap = snap.value as? Dictionary<String, String>{
                        if let chat = self.parseChatSnap(chatId:snap.key,chatSnapDict: chat_snap){
                            self.chats.append(chat)
                        }
                    }
                }
                self.count_show_badge()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func count_show_badge(){
        //count notification
        if let seen_notification = Int(self.mUserObj.chat_notify_count!){
            if seen_notification == self.chats.count{
                //show no badge
                badge.text = "0"
                badge.isHidden = true
            }else{
                //count badge
                let badge_count = self.chats.count - seen_notification
                print("\(self.TAG): \(badge_count)")
                if(badge_count > 0){
                    badge.text = "\(badge_count)"
                    badge.isHidden = false
                }
            }
        }
    }
    
    func parseChatSnap(chatId: String,chatSnapDict: Dictionary<String,String>)->ChatObject?{
        var chatObj = ChatObject()
        
        guard let senderName = chatSnapDict["senderName"] else{
            return chatObj
        }
        guard let senderId = chatSnapDict["senderId"] else{
            return chatObj
        }
        guard let date = chatSnapDict["date"] else{
            return chatObj
        }
        guard let iamgeUrl = chatSnapDict["imageUrl"] else{
            return chatObj
        }
        guard let message = chatSnapDict["message"] else{
            return chatObj
        }
        guard let time = chatSnapDict["time"] else{
            return chatObj
        }
        
        
        
        chatObj = ChatObject(chatId: chatId,senderId: senderId, senderName: senderName, message: message, time: time, date: date, image_url: iamgeUrl)
        
        return chatObj
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
        guard let lat = mUserObj.user_current_lat,let lng = mUserObj.user_current_lng else {
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
                print("\(self.TAG): User granted Permission")
            }else{
                print(error?.localizedDescription ?? "Error!!!")
            }
            
        })
        startObservingChatDataChange()
        startObservingTrips()
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done

    }
    
    func startObservingTrips(){
        print("\(self.TAG): start observing trips")
        print("\(self.TAG): current Date: \(getCurrentDate())")
        DADataService.instance.REF_COMPANY.child(mUserObj.companyName!).child("userTrips").child(getCurrentDate()).observe(.value, with: { (snapshot) in
            if let userNodes = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for userNode in userNodes{
                    //this snap is user node id for each user
                    //check if this is the current user if yes no need to show update
                    //location of map cause its already updating my locationManager
                  if  userNode.key != self.mUserObj.userNodeId{
                    if let trips = userNode.value as? Dictionary<String,AnyObject>{
                        self.tripObjects.removeAll()
                        for trip in trips{
                            //this trip is only random trip ids
                            self.tripObj = TripObject()
                            if let tripDict = trip.value as? Dictionary<String,AnyObject>{
                                //this is 3 different status of that trip
                                //we will get a trip object from the method with location objects in it
                                self.tripObjects.append(self.parseTripObjWithLocation(tripDict: tripDict))
                            }
                           
                        }

                    }
                    self.allUserTripsDict.updateValue(self.tripObjects, forKey: userNode.key)
                }
            }
        }
            self.processUserMovement(allUserTripsDict: self.allUserTripsDict)

            }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func processUserMovement(allUserTripsDict: Dictionary<String, [TripObject]>){
        //get all the keys
        //here key is userNode id
        let keys = Array(allUserTripsDict.keys)
        //iterating all the keys
        for key in keys{
            //get the user object of that key
            if let userObj = allUserDict[key]{
                //get all the trip object of a user
                let tripObjects = allUserTripsDict[key]
                //get the last trip
                let tripObj = tripObjects?.last
                //check the user is on move or slow
                if userObj.userRouteStatus == Constants.STATUS_ON_TRIP{
                    //last location object
                    let last_location = tripObj?.onTripLocation.last
                    //update the lat lng
                    userObj.user_current_lat = last_location?.latitude
                    userObj.user_current_lng = last_location?.longitude
                    //check if the marker is already in the map
                    if let marker = marker_dict[userObj.userNodeId!]{
                        if(self.markerAnimationfinish){
                            //update the marker location
                            anitmateMarkertoLocation(marker: marker, coordinates: CLLocationCoordinate2D(latitude: Double(last_location!.latitude)!, longitude: Double(last_location!.longitude)!), degrees: 0, duration: 3)
                        }
                    }else{
                        //add marker in that location
                        addUserMarker(userObj: userObj)
                    }
                }else if userObj.userRouteStatus == Constants.STATUS_ON_WAITING{
                    //last location object
                    let last_location = tripObj?.onTripLocation.last
                    //update the lat lng
                    userObj.user_current_lat = last_location?.latitude
                    userObj.user_current_lng = last_location?.longitude
                }else if userObj.userRouteStatus == Constants.STATUS_ON_FINISH{
                    //last location object
                    let last_location = tripObj?.onTripLocation.last
                    //update the lat lng
                    userObj.user_current_lat = last_location?.latitude
                    userObj.user_current_lng = last_location?.longitude
                    if let _ = marker_dict[userObj.userNodeId!]{
                        //nothing to do
                    }else{
                        //add marker in that location
                        addUserMarker(userObj: userObj)
                    }
                }
            }
        }
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell{
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func parseTripObjWithLocation(tripDict: Dictionary<String, AnyObject>) -> TripObject {
        let tripObject = TripObject()
        if let onTrip = tripDict["onTrip"]{
            if let onTripDict = onTrip as? Dictionary<String,AnyObject>{
                for triplocation in onTripDict{
                    
                    if let finalDict = triplocation.value as? Dictionary<String,String>{
                        //getting the main values
                        print("\(self.TAG): onTrip: \(finalDict)")
                        guard let latitude = finalDict["latitude"] else{
                            return tripObject
                        }
                        guard let longitude = finalDict["longitude"] else{
                            return tripObject
                        }
                        guard let time = finalDict["time"] else{
                            return tripObject
                        }
                        let locationObj = locationObject(latitude: latitude, longitude: longitude, time: time)
                        tripObject.onTripLocation.append(locationObj)
                    }
                    
                }
            }
        }
        if let onFinish = tripDict["onFinish"]{
            if let onFinishDict = onFinish as? Dictionary<String,AnyObject>{
                for tripLocation in onFinishDict{
                    if let finalDict = tripLocation.value as? Dictionary<String,String>{
                        //getting the main values
                        print("\(self.TAG): onFinish: \(finalDict)")
                        guard let latitude = finalDict["latitude"] else{
                            return tripObject
                        }
                        guard let longitude = finalDict["longitude"] else{
                            return tripObject
                        }
                        guard let time = finalDict["time"] else{
                            return tripObject
                        }
                        let locationObj = locationObject(latitude: latitude, longitude: longitude, time: time)
                        tripObject.onFinishLocation.append(locationObj)
                    }
                    
                }
            }
        }
        if let onWaiting = tripDict["onWaiting"]{
            if let onWaitingDict = onWaiting as? Dictionary<String,AnyObject>{
                for tripLocation in onWaitingDict{
                    if let finalDict = tripLocation.value as? Dictionary<String,String>{
                        //getting the main values
                        print("\(self.TAG): onWaiting: \(finalDict)")
                        guard let latitude = finalDict["latitude"] else{
                            return tripObject
                        }
                        guard let longitude = finalDict["longitude"] else{
                            return tripObject
                        }
                        guard let time = finalDict["time"] else{
                            return tripObject
                        }
                        let locationObj = locationObject(latitude: latitude, longitude: longitude, time: time)
                        tripObject.onWaitingLocation.append(locationObj)
                    }
                    
                }
            }
        }
        
        return tripObject
    }
    
    
    func configureCell(cell: UserCell,indexPath: IndexPath){
        if isSearching{
            if let item = filter_employee[indexPath.row] as? UserObject{
                cell.configureCell(userObj: item)
            }
        }else{
            if let item = employees[indexPath.row] as? UserObject{
                cell.configureCell(userObj: item)
            }
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == ""{
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        }else{
            isSearching = true
            filter_employee = employees.filter{$0.userName!.starts(with: searchBar.text!) }
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        isSearching = false;
        self.searchBar.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return filter_employee.count
        }else{
            return employees.count
        }
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
                dest.chats = self.chats
            }
        }
    }
    
    
    @IBAction func profile_icon_changed(_ sender: Any) {
        toggleLeftMenu()
        self.performSegue(withIdentifier: Constants.USER_PROFILE_SEGUE_IDENTIFIER, sender: nil)
    }
    func getAllUserData(){
        Progress.sharedInstance.showLoading()
        print("\(self.TAG): start getting all user data")
        DADataService.instance.REF_COMPANY.child(mUserObj.companyName!).child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get all user
            print("\(self.TAG): finish getting all user data")
            Progress.sharedInstance.dismissLoading()
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                print("\(self.TAG): emplyoee count:\(snapshots.count)")
                //remove if their is any previous information about emplyoee/user
                self.employees.removeAll()
                for snap in snapshots {
                    if let user_snap = snap.value as? Dictionary<String, String>{
                        if let employee = self.parseUserSnap(uid: snap.key, userSnapDict: user_snap){
                            //no need to show login users in the right user menu
                            if employee.userNodeId != self.mUserObj.userNodeId{
                                self.employees.append(employee)
                            }
                        }
                    }
                }
                self.tableView.reloadData()
                //clear the dictionary data
                self.allUserDict.removeAll()
                //put markers for all the users/employee
                for employee in self.employees{
                    //populate the user dictionary
                    self.allUserDict.updateValue(employee, forKey: employee.userNodeId!)
                    if(employee.userNodeId != self.mUserObj.userNodeId){
                        switch employee.status!{
                        case .OFFLINE:
                            print("\(self.TAG): \(employee.userName!) is logged out user")
                            break
                        case .ONLINE:
                            print("\(self.TAG): \(employee.userName!) is logged in user")
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
        guard let lat = userSnapDict["user_current_lat"] else{
            return userObj
        }
        guard let lng = userSnapDict["user_current_lng"] else{
            return userObj
        }
        guard let status = userSnapDict["status"] else{
            return userObj
        }
        guard let chat_notify_count = userSnapDict["chat_notify_count"] else{
            return userObj
        }

        
        userObj = UserObject(uid: uid, companyName: self.mUserObj.companyName!, email: email, userName: name, routeStatus: route, imageUrl: imageUrl, user_current_lat: lat, user_current_lng: lng,status: status,chat_notify_count: chat_notify_count)
        
        return userObj
    }
    
    func startObservingUserDataChange(){
        print("\(self.TAG): start observing")
        DADataService.instance.REF_COMPANY.child(mUserObj.companyName!).child("users").observe(.childChanged, with: { (snapshot) in
            // Get data changed user
            print("\(self.TAG): receive user data changed")
            if let user_snap = snapshot.value as? Dictionary<String, String>{
                if let employee = self.parseUserSnap(uid: snapshot.key, userSnapDict: user_snap){
                    
                   //if already exist then remove that item
                    if let index = self.employees.index(where: { $0.userNodeId == employee.userNodeId }) {
                        self.employees.remove(at: index)
                        //continue do: arrPickerData.append(...)
                    }
                    //remove from dictionary
                    self.allUserDict.removeValue(forKey: employee.userNodeId!)
                    //add that item again
                    self.employees.append(employee)
                    self.allUserDict.updateValue(employee, forKey: employee.userNodeId!)
                    self.tableView.reloadData()
                    
                    //if offline no marker add
                    switch employee.status!{
                        case .OFFLINE:
                            print("\(self.TAG): \(employee.userName!) offline marker not added")
                            //remove if prevoiusly added
                            guard let marker = self.marker_dict[employee.userNodeId!] else {
                                return
                            }
                            marker.map = nil
                            self.marker_dict.removeValue(forKey: employee.userNodeId!)
                            
                        break
                        case .ONLINE:
                            print("\(self.TAG): \(employee.userName!) online marker not added")
                            //if user has already a marker then remove it and add new marker with new position
                            if let marker = self.marker_dict[employee.userNodeId!] {
                                if(self.markerAnimationfinish){
                                    //no need to add again just animate it to the new location
                                    //animate the marker there
                                    self.anitmateMarkertoLocation(marker: marker, coordinates: CLLocationCoordinate2D(latitude: Double(employee.user_current_lat!)!, longitude: Double(employee.user_current_lng!)!), degrees: 0, duration: 3)
                                }
                                return
                            }
                            //add marker
                            //if this line execute that means this is a new marker
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
                print("\(self.TAG): User disabled Location permisson")
                showAlertForSettings()
                break
            case .authorizedAlways, .authorizedWhenInUse:
                print("\(self.TAG): User enabled Location permission")
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
        getAllChatData()
        checkForLocationPermission()
        Constants.onChatPage = false

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
                    //remove the observers
                    DADataService.instance.REF_COMPANY.child(self.mUserObj.companyName!).child("chatGroup").removeAllObservers()
                    DADataService.instance.REF_COMPANY.child(self.mUserObj.companyName!).child("users").removeAllObservers()
                    //clear all userDefaults
                    if let appDomain = Bundle.main.bundleIdentifier {
                        UserDefaults.standard.removePersistentDomain(forName: appDomain)
                    }
                    //reset the trip status
                    onTrip = false
                    
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
        badge.text = "0"
        mUserObj.chat_notify_count = "\(chats.count)"
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
            if let user_lat = mUserObj.user_current_lat,let user_lng = mUserObj.user_current_lng
            {
                //journey already started or just opened the app
                let user_current_location = CLLocation(latitude: user_lat.toDouble()!, longitude: user_lng.toDouble()!)
                let user_new_location = CLLocation(latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)
                let distanceInMeters = user_current_location.distance(from: user_new_location) // result is in meters
                print("\(self.TAG): moved \(distanceInMeters) meters")
                if(distanceInMeters >= 5)
                {
                    // 1 mile = 1609 meters
                    // 1 kilometer = 1000 meters
                    if(self.status != Constants.STATUS_STOP){
                        if let marker = marker_dict[mUserObj.userNodeId!]{
                            if(self.markerAnimationfinish){
                                    self.markerAnimationfinish = false
                                    status_lbl.text = "Moving"
                                    DADataService.instance.update_userRouteStatus(uid: mUserObj.userNodeId!, companyName: mUserObj.companyName!, status: Constants.STATUS_ON_TRIP, callback: nil)
                                    DADataService.instance.add_location_with_status(uid: self.mUserObj.userNodeId!, companyName: self.mUserObj.companyName!, status: Constants.STATUS_ON_TRIP, latitude: user_new_location.coordinate.latitude, longitude: user_new_location.coordinate.longitude, callback: nil)
                                    anitmateMarkertoLocation(marker: marker, coordinates: CLLocationCoordinate2D(latitude: user_new_location.coordinate.latitude, longitude: user_new_location.coordinate.longitude), degrees: 0, duration: 3)
                            }else{
                                status_lbl.text = "Moving"
                            }
                        }
                    }else{
                        status_lbl.text = "N?A"
                        
                    }
                    
                }
                else
                {
                    // in 20
                    if(self.status != Constants.STATUS_STOP){
                        status_lbl.text = "Slow"
                        DADataService.instance.update_userRouteStatus(uid: mUserObj.userNodeId!, companyName: mUserObj.companyName!, status: Constants.STATUS_ON_WAITING, callback: nil)
                        DADataService.instance.add_location_with_status(uid: self.mUserObj.userNodeId!, companyName: self.mUserObj.companyName!, status: Constants.STATUS_ON_WAITING, latitude: user_new_location.coordinate.latitude, longitude: user_new_location.coordinate.longitude, callback: nil)
                        //update users current location in firebase
                        DADataService.instance.updateUserLoginLocation(uid: mUserObj.userNodeId!, companyName: mUserObj.companyName!, lat: location.coordinate.latitude, lng: location.coordinate.longitude, status: .ONLINE){(response) in}
                    }else{
                        status_lbl.text = "N/A"
                    }

                }

                if(self.status == Constants.STATUS_STOP){
                    locationManager.stopUpdatingLocation()
                }
            }else{
                mUserObj.user_current_lat = "\(location.coordinate.latitude)"
                mUserObj.user_current_lng = "\(location.coordinate.longitude)"
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
        let location: CLLocation = CLLocation(latitude: (Double)(userObj.user_current_lat!)!, longitude: (Double)(userObj.user_current_lng!)!)
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
        self.markerAnimationfinish = true
        // Keep Rotation Short
        //if want to update the rotation also comment out these two lines
//        CATransaction.begin()
//        CATransaction.setAnimationDuration(0.5)
//        marker.rotation = degrees
//        CATransaction.commit()
        
        // Movement
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            print("\(self.TAG): Animation completed")
            self.markerAnimationfinish = true
            //insert the lat lng as users current location
            self.mUserObj.user_current_lat = "\(coordinates.latitude)"
            self.mUserObj.user_current_lng = "\(coordinates.longitude)"
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

