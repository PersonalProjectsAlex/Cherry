//
//  ServiceDB.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 12/01/17.
//  Copyright © 2017 Slate Development. All rights reserved.
//

import GRDB

class ServiceDB: Record {
    var id: Int64?
    
    var remote_id:Int
    var remote_inspection_id:Int64
    var internal_inspection_id:Int
    var service_id:Int
    var qty:Int
    var service_status:Bool
    var item_type:String?
    var comment:String?
    var image_url:String?
    var is_light:Bool?
    var light_selected:Bool?
    
    init(remote_id:Int, remote_inspection_id:Int64, internal_inspection_id:Int, service_id:Int, qty:Int, service_status:Bool, item_type:String? = "", comment:String? = "", image_url:String? = "", is_light:Bool? = false, light_selected:Bool? = false) {
        self.remote_id = remote_id
        self.remote_inspection_id = remote_inspection_id
        self.internal_inspection_id = internal_inspection_id
        self.service_id = service_id
        self.qty = qty
        self.service_status = service_status
        self.item_type = item_type
        self.comment = comment
        self.image_url = image_url
        self.is_light = is_light
        self.light_selected = light_selected
        super.init()
    }
    
    // MARK: Record overrides
    override class var databaseTableName: String {
        return "services"
    }
    
    required init(row: Row) {
        id = row["id"]
        remote_id = row["remote_id"]
        remote_inspection_id = row["remote_inspection_id"]
        internal_inspection_id = row["internal_inspection_id"]
        service_id = row["service_id"]
        qty = row["qty"]
        service_status = row["service_status"]
        item_type = row["item_type"]
        comment = row["comment"]
        image_url = row["image_url"]
        is_light = row["is_light"]
        light_selected = row["light_selected"]
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["remote_id"] = remote_id
        container["remote_inspection_id"] = remote_inspection_id
        container["internal_inspection_id"] = internal_inspection_id
        container["service_id"] = service_id
        container["qty"] = qty
        container["service_status"] = service_status
        container["item_type"] = item_type
        container["comment"] = comment
        container["image_url"] = image_url
        container["is_light"] = is_light
        container["light_selected"] = light_selected
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
