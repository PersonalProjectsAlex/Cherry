//
//  ConnectivityManager.swift
//  CherryDrive
//
//  Created by Jefferson S. Batista on 5/1/16.
//  Copyright © 2016 Ring Seven. All rights reserved.
//

import Foundation
import ReachabilitySwift

class ConnectivityManager: NSObject {
    
    static let sharedInstance = ConnectivityManager()
    
    let reachability = Reachability()!
    
    var hasInternet:Bool = false {
        didSet {
            printReachabilityStatus()
        }
    }
    
    override init() {
        super.init()
        // Setup reachability
        self.reachability.whenReachable = { reachability in
            
//            if reachability.isReachableViaWiFi {
//                print("Reachable via WiFi")
//            } else {
//                print("Reachable via Cellular")
//            }
            
            self.hasInternet = true
            //            NotificationManager.completionWithMessage("Connection Available")
        }
        
        self.reachability.whenUnreachable = { reachability in
            self.hasInternet = false
            //            NotificationManager.alertWithMessage("Connection Lost")
        }
        
        try! reachability.startNotifier()
        
        // Initial reachability check
        if self.reachability.isReachable {
            self.hasInternet = true
            printReachabilityStatus()
        } else {
            self.hasInternet = false
            printReachabilityStatus()
        }
    }
    
    fileprivate func printReachabilityStatus() {
//        if(self.hasInternet){
//            print("internet reachable")
//        }else{
//            print("internet not reachable")
//            //            NotificationManager.alertWithMessage("Cannot perform desired request, make sure you have a valid connection.")
//        }
    }
}
