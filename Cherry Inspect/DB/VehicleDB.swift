//
//  IncompleteVehicleDB.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 20/12/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import GRDB

class VehicleDB: Record {
    
    var id: Int64?
    
    var vehicles_id:Int64?
    var vehicles_vin:String
    var vehicles_license:String
    var vehicles_licensePlateState:String
    var vehicles_model:String
    var vehicles_make:String
    var vehicles_year:Int
    var vehicles_description:String
    var vehicles_mileage:String
    var vehicles_status:Int
    
    init(vehicles_id:Int64? = nil, vehicles_vin:String, vehicles_license:String, vehicles_licensePlateState:String,
         vehicles_model:String, vehicles_make:String, vehicles_year:Int, vehicles_description:String, vehicles_mileage:String, vehicles_status:Int) {

        self.vehicles_id = vehicles_id
        self.vehicles_vin = vehicles_vin
        self.vehicles_license = vehicles_license
        self.vehicles_licensePlateState = vehicles_licensePlateState
        self.vehicles_model = vehicles_model
        self.vehicles_make = vehicles_make
        self.vehicles_year = vehicles_year
        self.vehicles_description = vehicles_description
        self.vehicles_mileage = vehicles_mileage
        self.vehicles_status = vehicles_status
        super.init()
    }
    
    // MARK: Record overrides
    override class var databaseTableName: String {
        return "incompleteVehicles"
    }
    
    required init(row: Row) {
        id = row["id"]
        vehicles_id = row["vehicles_id"]
        vehicles_vin = row["vehicles_vin"]
        vehicles_license = row["vehicles_license"]
        vehicles_licensePlateState = row["vehicles_licensePlateState"]
        vehicles_model = row["vehicles_model"]
        vehicles_make = row["vehicles_make"]
        vehicles_year = row["vehicles_year"]
        vehicles_description = row["vehicles_description"]
        vehicles_mileage = row["vehicles_mileage"]
        vehicles_status = row["vehicles_status"]
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["vehicles_id"] = vehicles_id
        container["vehicles_vin"] = vehicles_vin
        container["vehicles_license"] = vehicles_license
        container["vehicles_licensePlateState"] = vehicles_licensePlateState
        container["vehicles_model"] = vehicles_model
        container["vehicles_make"] = vehicles_make
        container["vehicles_year"] = vehicles_year
        container["vehicles_description"] = vehicles_description
        container["vehicles_mileage"] = vehicles_mileage
        container["vehicles_status"] = vehicles_status
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
