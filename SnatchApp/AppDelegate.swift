//
//  AppDelegate.swift
//  SnatchApp
//
//  Created by Tomer Cohen on 03/01/2017.
//  Copyright © 2017 Tomer Cohen. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                // instantiate your desired ViewController
                let rootController = storyboard.instantiateViewController(withIdentifier: "Login")
                
                // Because self.window is an optional you should check it's value first and assign your rootViewController
                if let window = self.window {
                    window.rootViewController = rootController
                }
            }
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        return handled
    }


}

