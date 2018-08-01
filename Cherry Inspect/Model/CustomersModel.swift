//
//  Customers.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 7/7/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

class CustomersModel: NSObject {
    static let sharedInstance = CustomersModel()
    
    var id:Int64?
    var full_name = ""
    var state = ""
    var country = ""
    var license = ""
    var license_expiration_date = ""
    var mileage = ""
    
    //let personalPlaceholdArray = ["Full Name (Optional)", "Country (Optional)", "State (Optional)"]
    let personalPlaceholdArray = ["Full Name (Optional)"]
    
    func resetCustomersModel() {
        id = nil
        full_name = ""
        state = ""
        country = ""
        license = ""
        license_expiration_date = ""
        mileage = ""
    }
}
