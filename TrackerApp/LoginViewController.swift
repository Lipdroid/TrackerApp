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

class LoginViewController: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate {
    var dict : [String : AnyObject]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //configure Google Signin
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("123")
        if let err = error{
            print("Something went wrong with google login",err)
            return
        }
        
        print("Successfully Signed in")
        guard let idToken = user.authentication.idToken else {
            return
        }
        guard let accessToken = user.authentication.accessToken else {
            return
        }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        FIRAuth.auth()?.signIn(with: credential, completion: { (User, error) in
            if(error != nil){
                print("error")
                return
            }
            
            guard let uid = user?.userID else{return}
            print("Successfully logged in",uid)
        })
        
    }


    @IBAction func after_click_facebook_login(_ sender: Any) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
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
                                print("Something went wrong",error ?? "")
                            }
                            
                            print("Logged In")
                        })
                        
                        //self.getFBUserData()
                       // fbLoginManager.logOut()
                        
                    }
                }
            }
        }

    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    //print(result!)
                    print(self.dict)
                }
            })
        }
    }

    @IBAction func after_click_google(_ sender: Any) {
       // GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }

}

