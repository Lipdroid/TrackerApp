  //
//  ViewController.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 8/21/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit
import Firebase
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn
import SwiftKeychainWrapper

class LoginViewController: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate {
    var dict : [String : AnyObject]!
    var mUserObj: UserObject? = nil
    private let TAG = "LoginViewController"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
        //configure Google Signin
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
//        KeychainWrapper.standard.removeObject(forKey: Constants.KEY_UID)
//        KeychainWrapper.standard.removeObject(forKey: Constants.KEY_COMPANY)
        
        if let uid = KeychainWrapper.standard.string(forKey: Constants.KEY_UID){
            // segue to main view controller
            print("\(self.TAG): Already logged in")
            //get User Data from Firebase & autologin
            if let company_name = KeychainWrapper.standard.string(forKey: Constants.KEY_COMPANY){
                Progress.sharedInstance.showLoading()
                DADataService.instance.getUserFromFirebaseDB(uid: uid,companyName: company_name){(user) in
                    Progress.sharedInstance.dismissLoading()
                    self.mUserObj = user as? UserObject
                    self.go_to_main_page()

                }
            }
            

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error{
            print("\(self.TAG): Something went wrong with google login",err)
            Progress.sharedInstance.dismissLoading()
            return
        }
        
        print("\(self.TAG): Successfully Signed in by google")
        guard let idToken = user.authentication.idToken else {
            return
        }
        guard let accessToken = user.authentication.accessToken else {
            return
        }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        FIRAuth.auth()?.signIn(with: credential, completion: { (User, error) in
            Progress.sharedInstance.dismissLoading()
            if(error != nil){
                print("\(self.TAG): error")
                return
            }
            if let authId = FIRAuth.auth()?.currentUser?.uid{
                self.mUserObj = UserObject(authId: authId, user: user)
                KeychainWrapper.standard.set(authId, forKey: Constants.KEY_UID)
                KeychainWrapper.standard.set((self.mUserObj?.companyName)!
                    , forKey: Constants.KEY_COMPANY)
                self.addUpdateUserToFirebaseDB();
            }

        })
        
    }


    @IBAction func after_click_facebook_login(_ sender: Any) {
        Progress.sharedInstance.showLoading()
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                //check if someone pressed cancel or done
                guard (fbloginresult.grantedPermissions) != nil else{
                    Progress.sharedInstance.dismissLoading()
                    return
                }
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email")){
                        //login successfully
                        //send the access token to firebase for authenticate
                        let accessToken = FBSDKAccessToken.current()
                        guard let accessTokenString = accessToken?.tokenString else
                        {
                            return
                        }
                        let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
                        FIRAuth.auth()?.signIn(with: credential, completion: { (User, error) in
                            if(error != nil){
                                print("\(self.TAG): Something went wrong",error ?? "")
                                Progress.sharedInstance.dismissLoading()
                                return
                            }
                            self.getFBUserData()
                            print("\(self.TAG): facebook authentication complete through firebase")
                        })
                        
                    }else{
                        Progress.sharedInstance.dismissLoading()
                    }
                }
            }else{
                print(error.debugDescription)
                Progress.sharedInstance.dismissLoading()
            }
        }

    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                Progress.sharedInstance.dismissLoading()
                if (error == nil){
                    print(result!)
                    if let dict = result as? Dictionary<String,AnyObject>{
                        if let authId = FIRAuth.auth()?.currentUser?.uid{
                            self.mUserObj = UserObject(authId: authId,dict: dict)
                            KeychainWrapper.standard.set(authId, forKey: Constants.KEY_UID)
                            KeychainWrapper.standard.set((self.mUserObj?.companyName)!
                                , forKey: Constants.KEY_COMPANY)
                            self.addUpdateUserToFirebaseDB();
                        }else{
                            print("\(self.TAG): no uid found from firebase current user for fb")
                        }

                    }
                    
                }
            })
        }
    }

    @IBAction func after_click_google(_ sender: Any) {
       // GIDSignIn.sharedInstance().
        Progress.sharedInstance.showLoading()
        GIDSignIn.sharedInstance().signIn()
    }
    
    func go_to_main_page(){
        //
        performSegue(withIdentifier: Constants.LOGINVIEW_TO_MAPVIEW_SEGUE_IDENTIFIER, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.LOGINVIEW_TO_MAPVIEW_SEGUE_IDENTIFIER{
            if let dest: MapViewController = segue.destination as? MapViewController{
                dest.mUserObj = self.mUserObj
            }
        }
    }
    
    private func addUpdateUserToFirebaseDB(){
        //it will add new users and update old users
        DADataService.instance.get_chat_notify_count_by_user(uid: self.mUserObj!.userNodeId!, companyName: self.mUserObj!.companyName!){
        (response) in
            if let count = response as? String{
                print("notify_count:\(count)")
                self.mUserObj?.chat_notify_count = count
                DADataService.instance.createFirebaseDBUser(uid: (FIRAuth.auth()?.currentUser?.uid)!, userObject: self.mUserObj!)
                self.go_to_main_page()
            }
        }
    }

}

