////
////  IncompleteInspections.swift
////  Cherry Inspect
////
////  Created by Jefferson S. Batista on 19/12/16.
////  Copyright © 2016 Slate Development. All rights reserved.
////
//
import GRDB

class CustomerDB: Record {
    
    var id: Int64?
    
    var customer_id:Int64?
    var full_name:String
    var country:String
    var state:String
    var customer_status:Int
    
    init(customer_id:Int64? = nil, full_name:String, country:String, state:String, customer_status:Int) {
        self.customer_id = customer_id
        self.full_name = full_name
        self.country = country
        self.state = state
        self.customer_status = customer_status
        super.init()
    }
    
    // MARK: Record overrides
    override class var databaseTableName: String {
        return "incompleteCustomers"
    }
    
    required init(row: Row) {
        id = row["id"]
        customer_id = row["customer_id"]
        full_name = row["full_name"]
        country = row["country"]
        state = row["state"]
        customer_status = row["customer_status"]
        super.init(row: row)
    }

    override func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["customer_id"] = customer_id
        container["full_name"] = full_name
        container["country"] = country
        container["state"] = state
        container["customer_status"] = customer_status
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
