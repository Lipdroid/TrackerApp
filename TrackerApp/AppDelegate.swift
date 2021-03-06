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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //configure Firebase
        FIRApp.configure()
        //initialize Map with key
        GMSServices.provideAPIKey(MAP_API_KEY)
        
        // Access the storyboard and fetch an instance of the view controller
        let storyboard = UIStoryboard(name: Constants.STORYBOARD_MAIN, bundle: nil);
        var viewController: UIViewController?
        
        if (FIRAuth.auth()?.currentUser) != nil {
            // segue to main view controller
            print("Already logged in")
            viewController = storyboard.instantiateViewController(withIdentifier: Constants.MAPVIEW_IDENTIFIER_STORYBOARD) as? MapViewController

        } else {
            // sign in
            viewController = storyboard.instantiateViewController(withIdentifier: Constants.LOGINVIEW_IDENTIFIER_STORYBOARD) as! LoginViewController
        }
        
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        //Configure facebook
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
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

