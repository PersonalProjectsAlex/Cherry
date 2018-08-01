//
//  VehiclesModel.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 7/6/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

class VehiclesModel: NSObject {
    static let sharedInstance = VehiclesModel()
    
    var vinSearched:Bool = false
    var user_id:Int?
    var vehicles_id:Int64?
    var name:String?
    var vehicles_vin = ""
    var vehicles_licensePlateState = ""
    var vehicles_make = ""
    var vehicles_model = ""
    var vehicles_year = 0
    var vehicles_description = ""
    var vehicles_status:Int?
    var mileage = ""
    
    let vehiclePlaceholdArray = [
        "License Plate Number",
        "Issuing State",
        "Expiration Date (MM/YYYY)",
        "VIN",
        "Vehicle Make",
        "Vehicle Model",
        "Year",
        "Engine Size",
        "Mileage"
    ]
    
    func resetVehiclesModel() {
        vinSearched = false
        user_id = nil
        vehicles_id = nil
        name = nil
        vehicles_vin = ""
        vehicles_licensePlateState = ""
        vehicles_make = ""
        vehicles_model = ""
        vehicles_year = 0
        vehicles_description = ""
        vehicles_status = nil
        mileage = ""
    }
}
