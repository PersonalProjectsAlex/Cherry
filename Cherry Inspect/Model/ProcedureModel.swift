//
//  ProcedureModel.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 7/15/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

class ProcedureModel: NSObject {
    static let sharedInstance = ProcedureModel()

    var allProcedures:[[String:AnyObject]] = []
    
    func resetProcedureModel() {
        allProcedures = []
    }
}
