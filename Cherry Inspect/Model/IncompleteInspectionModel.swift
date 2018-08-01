//
//  IncompleteInspectionModel.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 10/4/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

class IncompleteInspectionModel: NSObject {
    static let sharedInstance = IncompleteInspectionModel()
    let prefs = UserDefaults.standard
    
    struct customer {
        var customer_id:Int?
        var full_name:String?
        var country:String?
        var state:String?
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
    
    var incompleteInspection = [[[String:AnyObject]]]()
    var incompleteTitle = [String]()
    var incompleteProcedure_id = [Int]()
    var incompleteStore_id = [Int]()
    var incompleteCustomers = [customer]()
    var incompleteVehicles = [vehicle]()
    
    func loadData() {
        if let lIncompleteInspection = (IncompleteInspectionModel.sharedInstance.prefs.object(forKey: "incompleteInspection") as? [[[String:AnyObject]]]) {
            self.incompleteInspection = lIncompleteInspection
        }
        if let lIncompleteTitle = (IncompleteInspectionModel.sharedInstance.prefs.object(forKey: "incompleteTitle") as? [String]) {
            self.incompleteTitle = lIncompleteTitle
        }
        if let lIncompleteProcedure_id = (IncompleteInspectionModel.sharedInstance.prefs.object(forKey: "incompleteProcedure_id") as? [Int]) {
            self.incompleteProcedure_id = lIncompleteProcedure_id
        }
        if let lIncompleteStore_id = (IncompleteInspectionModel.sharedInstance.prefs.object(forKey: "incompleteStore_id") as? [Int]) {
            self.incompleteStore_id = lIncompleteStore_id
        }
    }
    
    func saveIncompleteInspection() {
        prefs.set(incompleteInspection, forKey: "incompleteInspection")
        prefs.set(incompleteTitle, forKey: "incompleteTitle")
        prefs.set(incompleteProcedure_id, forKey: "incompleteProcedure_id")
        prefs.set(incompleteStore_id, forKey: "incompleteStore_id")
    }
    
    func cleanIncompleteInspection() {
        prefs.removeObject(forKey: "incompleteInspection")
        prefs.removeObject(forKey: "incompleteInspection")
        prefs.removeObject(forKey: "incompleteTitle")
        prefs.removeObject(forKey: "incompleteProcedure_id")
        prefs.removeObject(forKey: "incompleteStore_id")
    }
    
    func removeIndex(_ index:Int) {
        self.incompleteInspection.remove(at: index)
        self.incompleteTitle.remove(at: index)
        self.incompleteProcedure_id.remove(at: index)
        self.incompleteStore_id.remove(at: index)
   //     self.incompleteCustomers.remove(at: index)
   //     self.incompleteVehicles.remove(at: index)
        
        prefs.set(self.incompleteInspection, forKey: "incompleteInspection")
//        prefs.set(self.incompleteCustomers, forKey: "incompleteCustomers")
//        prefs.set(self.incompleteVehicles, forKey: "incompleteVehicles")
        prefs.set(self.incompleteTitle, forKey: "incompleteTitle")
        prefs.set(self.incompleteProcedure_id, forKey: "incompleteProcedure_id")
        prefs.set(self.incompleteStore_id, forKey: "incompleteStore_id")
    }
}
