//
//  Draft.swift
//  Cherry Inspect
//
//  Created by Administrador on 24/03/18.
//  Copyright © 2018 Slate Development. All rights reserved.
//

import Foundation

struct Vehicle: Codable {
    let id : Int?
    let vin : String?
    let make : String?
    let model : String?
    let year : Int?
    let engine_size : String?
    let user_id : Int?
    let name : String?
    let state : String?
    let country : String?
    let description : String?
    let status : String?
    let min_brake_thickness : String?
    let num_doors : String?
    let drivetrain : String?
    let customer_signature_url : String?
    let technician_signature_url : String?
    let license : String?
    let license_plate_state : String?
    let license_expiration_date : String?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case vin = "vin"
        case make = "make"
        case model = "model"
        case year = "year"
        case engine_size = "engine_size"
        case user_id = "user_id"
        case name = "name"
        case state = "state"
        case country = "country"
        case description = "description"
        case status = "status"
        case min_brake_thickness = "min_brake_thickness"
        case num_doors = "num_doors"
        case drivetrain = "drivetrain"
        case customer_signature_url = "customer_signature_url"
        case technician_signature_url = "technician_signature_url"
        case license = "license"
        case license_plate_state = "license_plate_state"
        case license_expiration_date = "license_expiration_date"
    }
}
