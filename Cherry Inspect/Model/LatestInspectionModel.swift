//
//  LatestInspectionModel.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 10/01/17.
//  Copyright © 2017 Slate Development. All rights reserved.
//

import UIKit

class LatestInspectionModel: NSObject {
    static let sharedInstance = LatestInspectionModel()
    let prefs = UserDefaults.standard
    
    struct customer {
        var customer_id:Int?
        var full_name:String?
        //var country:String?
        //var state:String?
    }
    
    struct vehicle {
        var vehicles_id:Int?
        var vehicles_vin:String?
        var vehicles_license:String?
        var vehicles_licensePlateState:String?
        var vehicles_model:String?
        var vehicles_make:String?
        var vehicles_year:Int?
        var vehicles_description:String?
        var vehicles_mileage:String?
    }
    
    var latestInspection = [[[String:AnyObject]]]()
    var latestTitle = [String]()
    var latestProcedure_id = [Int]()
    var latestStore_id = [Int]()
    var latestCustomers = [customer]()
    var latestVehicles = [vehicle]()
    
    func loadData() {
        if let lLatestInspection = (LatestInspectionModel.sharedInstance.prefs.object(forKey: "latestInspection") as? [[[String:AnyObject]]]) {
            self.latestInspection = lLatestInspection
        }
        if let lLatestTitle = (LatestInspectionModel.sharedInstance.prefs.object(forKey: "latestTitle") as? [String]) {
            self.latestTitle = lLatestTitle
        }
        if let lLatestProcedure_id = (LatestInspectionModel.sharedInstance.prefs.object(forKey: "latestProcedure_id") as? [Int]) {
            self.latestProcedure_id = lLatestProcedure_id
        }
        if let lLatestStore_id = (LatestInspectionModel.sharedInstance.prefs.object(forKey: "latestStore_id") as? [Int]) {
            self.latestStore_id = lLatestStore_id
        }
    }
    
    func saveLatestInspection() {
        prefs.set(latestInspection, forKey: "latestInspection")
        prefs.set(latestTitle, forKey: "latestTitle")
        prefs.set(latestProcedure_id, forKey: "latestProcedure_id")
        prefs.set(latestStore_id, forKey: "latestStore_id")
        
    }
    

}
