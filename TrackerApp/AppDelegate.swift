//
//  AppDelegate.swift
//  TrackerApp
//
//  Created by Md Munir Hossain on 8/21/17.
//  Copyright © 2017 Md Munir Hossain. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FBSDKCoreKit
import GoogleSignIn
import GoogleMaps
import UserNotifications
import SwiftKeychainWrapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //register the delegate
        UNUserNotificationCenter.current().delegate = self

        //configure Firebase
        FIRApp.configure()
        //initialize Map with key
        GMSServices.provideAPIKey(MAP_API_KEY)
        
        //checking user is already logged in
        if let uid = KeychainWrapper.standard.string(forKey: Constants.KEY_UID){
            // segue to main view controller
            print("AppDelegate: Already logged in")
            //get User Data from Firebase & autologin
            if let company_name = KeychainWrapper.standard.string(forKey: Constants.KEY_COMPANY){
                DADataService.instance.getUserFromFirebaseDB(uid: uid,companyName: company_name){(user) in
                    let mUserObj = user as? UserObject
                    self.go_to_main_page(userObj: mUserObj!)

                }
            }else{
                go_to_onboarding_page()
            }
        }else{
            go_to_onboarding_page()
        }
        //Configure facebook
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }
    
    private func go_to_main_page(userObj: UserObject){
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
        initialViewController?.mUserObj = userObj
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
    }
    
    private func go_to_onboarding_page(){
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "OnboardingVC")
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        GIDSignIn.sharedInstance().handle(url,
                                          sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                          annotation: [:])
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        FBSDKAppEvents.activateApp()

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

