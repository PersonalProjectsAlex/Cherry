//
//  Draft.swift
//  Cherry Inspect
//
//  Created by Administrador on 24/03/18.
//  Copyright © 2018 Slate Development. All rights reserved.
//

import Foundation

struct Draft: Codable {
    let id : Int?
    let min_total : Int?
    let max_total : Int?
    let mileage : String?
    let created_at : String?
    let store : Store?
    let vehicle : Vehicle?
    
    private enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case min_total = "min_total"
        case max_total = "max_total"
        case mileage = "mileage"
        case created_at = "created_at"
        case store
        case vehicle
    }
}
