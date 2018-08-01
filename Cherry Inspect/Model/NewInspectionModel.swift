//
//  NewInspectionModel.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 8/5/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

class NewInspectionModel: NSObject {
    static let sharedInstance = NewInspectionModel()
    var id = [Int?]()
    var servicesId = [Int]()
    var servicesStatus = [Int]()
    var servicesQty = [Int]()
    var servicesType = [String]()
    var imageToSave = [String]()
    var camCheckImage = [Bool]()
    var comment = [String]()
    
    struct service {
        var id: Int?
        var name: String?
        var description: String?
        var default_comment: String?
        var default_comment_2: String?
        var status: Bool?
        var icon: String?
    }
    
    struct procedureServices {
        let id: Int?
        let procedure_id: Int?
        let service: [service]?
    }
    
    struct procedures {
        var id: Int?
        var name: String?
        var description: String?
        var csv_ids: String?
        var procedure_services: [procedureServices]?
    }
    var services = [procedures]()
    
    var toSave = [[String:AnyObject]?]()
    
    func resetNewInspectionModel() {
        id = [Int]()
        servicesId = [Int]()
        servicesStatus = [Int]()
        servicesQty = [Int]()
        servicesType = [String]()
        imageToSave = [String]()
        services = [procedures]()
        camCheckImage = [Bool]()
        comment = [String]()
        toSave = [[String:AnyObject]]()
    }
    
    func resetToSave(withCapacity: Int) {
        self.toSave.removeAll()
        self.toSave = Array<[String:AnyObject]?>(repeating: nil, count: withCapacity)
    }

}
