//
//  GeneralInspectionModel.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 7/9/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

class GeneralInspectionModel: NSObject {
    static let sharedInstance = GeneralInspectionModel()
    
    var statusGeneralCell:Bool = false
    var servicesId = [Int:[Int]]()
    var serviceName = [Int:[String]]()
    var serviceImage = [Int:[String]]()
    var servicesQty = [Int:[Int]]()
    var serviceButtons = [Int:[[Bool]]]()
    var default_comment = [Int:[String]]()
    var imageToSave = [Int:[String]]()
    var camCheckImage = [Int:[Bool]]()
    
    var generalServices:[[String:AnyObject]] = []
    var inspectionsServicesAttributes:[[String:AnyObject]] = []
    
    func resetGeneralInspectionModel() {
        statusGeneralCell = false
        servicesId = [Int:[Int]]()
        serviceName = [Int:[String]]()
        serviceImage = [Int:[String]]()
        servicesQty = [Int:[Int]]()
        serviceButtons = [Int:[[Bool]]]()
        default_comment = [Int:[String]]()
        
        camCheckImage = [Int:[Bool]]()
        imageToSave = [Int:[String]]()
        generalServices = [[String:AnyObject]]()
        inspectionsServicesAttributes = [[String:AnyObject]]()
    }
}
