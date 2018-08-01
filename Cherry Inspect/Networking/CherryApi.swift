//
//  CherryApi.swift
//  CherryDrive
//
//  Created by Jefferson S. Batista on 5/1/16.
//  Copyright © 2016 Ring Seven. All rights reserved.
//

import UIKit
import Alamofire

extension Request {
    
    public func debugLog() -> Self {
        #if DEBUG
            debugPrint(self)
        #endif
        return self
    }
    
    public func showHUD() -> Self {
        ProgressHudManager.sharedInstance.show()
        return self
    }
    
    public func setTimeOut() -> Self {
        
        // NOT IMPLEMENTED YET
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 4 // seconds
        configuration.timeoutIntervalForResource = 4
        
        //TODO: setup a timeout to current session
        
        return self
    }
    
    public func checkConnectivity() -> Self {
        if !ConnectivityManager.sharedInstance.reachability.isReachable{
            self.cancel()
            print("No Internet Connection Available")
        }
        return self
    }
    
}

class CherryApi: NSObject, CherryApiProtocol {

    static let sharedInstance = CherryApi()

    //Final Domain
    static let rootURL2 = "https://cherryinspect.com"
    static let baseURL2 = "https://cherryinspect.com/api/v1"
    
    //test databot.io Domains
    static let rootURL_dev = "https://cherry-api-app.herokuapp.com/"
    static let baseURL_dev = "https://cherry-api-app.herokuapp.com/api/v1"
    
    #if STAGING
    static let rootURL = "http://52.87.240.225:5000/"
    static let baseURL = "http://52.87.240.225:5000/api/v1"
    #elseif LOCAL
    static let rootURL = "http://localhost:3000/"
    static let baseURL = "http://localhost:3000/api/v1"
    #else
    static let rootURL = "http://cherryinspect.databot.io/"
    static let baseURL = "http://cherryinspect.databot.io/api/v1"
    #endif
    //test local
    //static let rootURL = "http://192.168.0.21:3000"
    //static let baseURL = "http://192.168.0.21:3000/api/v1"
    
   // http://cherryinspect.databot.io/
    
    //    static let rootURL = "http://4767dc06.ngrok.io/"
    //
    //    static let baseURL = "http://4767dc06.ngrok.io/api/v1"
    //Tests Domain
//    static let rootURL = "http://138.197.24.239"
//    static let baseURL = "http://138.197.24.239/api/v1"
    
//    static let rootURL = "http://cherrytest.ringseven.com"
//    static let baseURL = "http://cherrytest.ringseven.com/api/v1"
    
    //Tests Domain 2
//    static   let rootURL = "https://cherry.ringseven.com"
//    static  let baseURL = "https://cherry.ringseven.com/api/v1"

    
    // MARK: - AUTH
    static let authUrl = "\(baseURL)/auth"
    
    // MARK: - USERS
    static let signUpUrl = "\(baseURL)/users"
    
    // MARK: - CUSTOMERS
    static let searchCustomersUrl = "\(baseURL)/customers/search"
    static let createCustomerUrl = "\(baseURL)/customers"
    
    // MARK: - PROCEDURES
    static let proceduresUrl = "\(baseURL)/procedures"
    
    // MARK: - INSPECTIONS
    static let createInspectionUrl = "\(baseURL)/inspections"
        
    // MARK: - VEHICLES
    static let searchVehiclesUrl = "\(baseURL)/vehicles"
    static let searchVehiclesCarfaxUrl = "\(baseURL)/vehicles/search"
    
    func makeRequest (url: String, parameters: [String:AnyObject], httpMethod: String) -> URLRequest{
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 35
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue((LoginModel.sharedInstance.prefs.value(forKey: "auth_token") as? String)!, forHTTPHeaderField: "Authorization")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        return request
    }
}
