//
//  CherryApiManager.swift
//  CherryDrive
//
//  Created by JJefferson S. Batista on 5/1/16.
//  Copyright © 2016 Ring Seven. All rights reserved.
//

import UIKit
//import AFNetworking

//typealias SuccessResponse = (_ operation: AFHTTPRequestOperation?, _ responseObject: AnyObject?) -> Void
//typealias FailureResponse = (_ operation: AFHTTPRequestOperation?, _ error: NSError?) -> Void

protocol CherryApiProtocol {
    // MARK: - AUTH
//    func login(_ email:String, password:String, success:SuccessResponse?, failure: FailureResponse?)
//    func logout(_ success:SuccessResponse?, failure: FailureResponse?)
//    func forgotPass(_ email:String, success:SuccessResponse?, failure: FailureResponse?)
//    func changePass(_ password:String, password_confirmation:String, success:SuccessResponse?, failure: FailureResponse?)
//
//    // MARK: - CUSTOMERS
//    func getAllCustomers(_ store_id:String, success:SuccessResponse?, failure: FailureResponse?)
//    func createCustomer(_ full_name:String, state:String, country:String, license:String, license_plate_state:String, license_expiration_date:String, store_id:Int, vehicles_vin:String, vehicles_make:String, vehicles_model:String, vehicles_year:Int, vehicles_description:String, success:SuccessResponse?, failure: FailureResponse?)
//    func searchCustomers(_ vin:String, license:String, success:SuccessResponse?, failure: FailureResponse?)
//    func updateCustomers(_ customer_Id:Int, full_name:String, state:String, country:String, license:String, license_plate_state:String, license_expiration_date:String, store_id:Int, vehicles_id:Int, vehicles_vin:String, vehicles_make:String, vehicles_model:String, vehicles_year:Int, vehicles_description:String, success:SuccessResponse?, failure: FailureResponse?)
//
//    // MARK: - INSPECTIONS
//    func getInspections(_ store_id:String, success:SuccessResponse?, failure: FailureResponse?)
//    func createInspection(_ store_id:Int, vehicle_id:Int, mileage:String, procedure_id:Int, inspections_services_attributes: AnyObject, success:SuccessResponse?, failure: FailureResponse?)
//    func searchInspection(_ inspection_id:Int, success:SuccessResponse?, failure: FailureResponse?)
//    func updateInspection(_ inspection_id:Int, vehicle_id:Int, min_total:Int, max_total:Int, mileage:String, success:SuccessResponse?, failure: FailureResponse?)
//
//    // MARK: - MEMBERS
//    func getAllTeamMembers(_ store_id:String, success:SuccessResponse?, failure: FailureResponse?)
//    func addMemberTeam(_ store_id:Int, user_id:Int, success:SuccessResponse?, failure: FailureResponse?)
//
//    // MARK: - PAYMENT PROFILES
//    func addPaymentProfile(_ first_name:String, last_name:String, company:String, address:String, city:String, state:String, country:String, zip:String, phone_number:String, card_number:String, expiration_date:String, card_code:String, success:SuccessResponse?, failure: FailureResponse?)
//    func updatePaymentProfile(_ first_name:String, last_name:String, company:String, address:String, city:String, state:String, country:String, zip:String, phone_number:String, card_number:String, expiration_date:String, card_code:String, success:SuccessResponse?, failure: FailureResponse?)
//
//    // MARK: - USERS
//    func signUp(_ email:String, password:String, first_name:String, last_name:String, success:SuccessResponse?, failure: FailureResponse?)
//
//    // MARK: - VEHICLES
//    func searchVehicles(_ vin:String, license:String, license_plate_state:String, success:SuccessResponse?, failure: FailureResponse?)
//
//    // MARK: - PROCEDURES
//    func getAllProcedures(_ store_id:String, success:SuccessResponse?, failure: FailureResponse?)
//    func showProcedure(_ store_id:String, procedure_id:String, success:SuccessResponse?, failure: FailureResponse?)
}

class CherryApiManager: NSObject {
    static let API = CherryApi()
}
