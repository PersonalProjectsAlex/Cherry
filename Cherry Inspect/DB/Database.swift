////
////  Database.swift
////  Cherry Inspect
////
////  Created by Jefferson S. Batista on 19/12/16.
////  Copyright © 2016 Slate Development. All rights reserved.
////
//

import GRDB
import UIKit

// The shared database queue
var dbQueue: DatabaseQueue!

func setupDatabase(_ application: UIApplication) throws {
    
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
    let databasePath = documentsPath.appendingPathComponent("db.sqlite")
    dbQueue = try DatabaseQueue(path: databasePath)
    
    dbQueue.setupMemoryManagement(in: application)
}
