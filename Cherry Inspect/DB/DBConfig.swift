//
//  DBConfig.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 23/02/17.
//  Copyright © 2017 Slate Development. All rights reserved.
//

import GRDB

class DBConfig: Record {
    var id: Int64?
    
    var version:String
    var updated:Date
    
    init(version:String, updated:Date) {
        self.version = version
        self.updated = updated
        super.init()
    }
    
    // MARK: Record overrides
    override class var databaseTableName: String {
        return "dbConfig"
    }
    
    required init(row: Row) {
        id = row["id"]
        version = row["version"]
        updated = row["updated"]
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["version"] = version
        container["updated"] = updated
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
