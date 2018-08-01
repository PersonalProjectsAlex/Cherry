//
//  AppDelegate.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 6/20/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit
import HockeySDK
import SwiftyBeaver

typealias Log = SwiftyBeaver
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .lightContent
        try! setupDatabase(application)
        
        BITHockeyManager.shared().configure(withIdentifier: "44644631b7044e78a7a60c1bf2d27cef")
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        gai?.dispatchInterval = 10
        
        
        
        //Delegating console
        let console = ConsoleDestination()  // log to Xcode Console
        
        // use custom format and set console output to short time, log level & message
        console.format = "$DHH:mm:ss$d $L $M"
        // or use this for JSON output: console.format = "$J"
        
        // add the destinations to SwiftyBeaver
        Log.addDestination(console)
        
        //set emojis
        console.levelString.verbose = "❤️ VERBOSE: "
        console.levelString.debug = "🏃🏻 DEBUG: "
        console.levelString.info = "✍🏻 INFO: "
        console.levelString.warning = "⚠️ WARNING"
        console.levelString.error = "😡 ERROR"
        
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if self.window?.rootViewController?.presentedViewController is CustomerInfoController {
            
            let vinScanController = self.window!.rootViewController!.presentedViewController as! CustomerInfoController
            
            if vinScanController.isPresented {
                return UIInterfaceOrientationMask.all;
            } else {
                return UIInterfaceOrientationMask.portrait;
            }
        } else {
            return UIInterfaceOrientationMask.portrait;
        }
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // When you type customSchemeExample://red in the search bar in Safari
        //        let urlScheme = url.scheme //[URL_scheme]
        //        let host = url.host //red
        // When you type customSchemeExample://?backgroundColor=red or customSchemeExample://?backgroundColor=green
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: false)
    //    let items = (urlComponents?.queryItems)! as [NSURLQueryItem] // {name = backgroundcolor, value = red}
        let prefs = UserDefaults.standard
        prefs.set(true, forKey: "urlScheme")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkUrlScheme"), object: nil)
        if (url.scheme  == "cherryinspect") {
            for queryItem in (urlComponents?.queryItems!)! {
                print("\(queryItem.name) = \(queryItem.value!)")
                
                switch queryItem.name {
                    case "full_name":
                        CustomersModel.sharedInstance.full_name = queryItem.value!
                    case "country":
                        CustomersModel.sharedInstance.country = queryItem.value!
                    case "state":
                        CustomersModel.sharedInstance.state = queryItem.value!
                    case "license":
                        CustomersModel.sharedInstance.license = queryItem.value!
                    case "vehicles_licensePlateState":
                        VehiclesModel.sharedInstance.vehicles_licensePlateState = queryItem.value!
                    case "vehicles_vin":
                        VehiclesModel.sharedInstance.vehicles_vin = queryItem.value!
                    case "mileage":
                        CustomersModel.sharedInstance.mileage = queryItem.value!
                    default:
                        print("out range")
                }
            }
        }
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

