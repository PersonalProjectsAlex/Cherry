//
//  InspectionDB.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 04/01/17.
//  Copyright © 2017 Slate Development. All rights reserved.
//

import GRDB

class InspectionDB: Record {
    var id: Int64?
    
    var customer_id:Int64?
    var vehicles_id:Int64?
    var inspection_id:Int64?
    var inspection_date:Date
    var inspection_status:Int
    var inspection_procedure_id:Int64?
    var title:String?
    
    init(customer_id:Int64? = nil, vehicles_id:Int64? = nil, inspection_id:Int64? = nil, inspection_date:Date, inspection_status:Int, inspection_procedure_id:Int64? = nil, title:String? = "") {
        self.customer_id = customer_id
        self.vehicles_id = vehicles_id
        self.inspection_id = inspection_id
        self.inspection_date = inspection_date
        self.inspection_status = inspection_status
        self.inspection_procedure_id = inspection_procedure_id
        self.title = title
        super.init()
    }
    
    // MARK: Record overrides
    override class var databaseTableName: String {
        return "inspections"
    }
    
    required init(row: Row) {
        id = row["id"]
        customer_id = row["customer_id"]
        vehicles_id = row["vehicles_id"]
        inspection_id = row["inspection_id"]
        inspection_date = row["inspection_date"]
        inspection_status = row["inspection_status"]
        inspection_procedure_id = row["inspection_procedure_id"]
        title = row["title"]
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["customer_id"] = customer_id
        container["vehicles_id"] = vehicles_id
        container["inspection_id"] = inspection_id
        container["inspection_date"] = inspection_date
        container["inspection_status"] = inspection_status
        container["inspection_procedure_id"] = inspection_procedure_id
        container["title"] = title
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
