//
//  LoginInteractor.swift
//  CherryDrive
//
//  Created by Jefferson S. Batista on 11/28/16.
//  Copyright © 2016 SlateDev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol LoginInteractorProtocol {
    func performLogin(_ email:String, password:String)
}

class LoginInteractor: NSObject, LoginInteractorProtocol {
    
    var loginView: LoginViewProtocol?
    var email: String?
    var authToken: String?
    
    convenience init(loginView:LoginViewProtocol) {
        self.init()
        self.loginView = loginView
    }
    
    func performLogin(_ email: String, password: String) {
        self.email = email
        let parameters = ["email": email, "password": password]
        Alamofire.request(CherryApi.authUrl, method: .post, parameters: parameters).checkConnectivity().showHUD().responseJSON { response in
            ProgressHudManager.sharedInstance.hide()
            switch response.result {
            case .success:
                let json = JSON(response.result.value!)
                print(json)
                if json["stores"].count > 0 {
                    for i in 0...json["stores"].count - 1{
                        print(json["stores"][i]["name"])
                        LoginModel.sharedInstance.storeId.append(json["stores"][i]["id"].intValue)
                        LoginModel.sharedInstance.storeName.append(json["stores"][i]["name"].stringValue)
                        LoginModel.sharedInstance.storeStatus.append(json["stores"][i]["status"].boolValue)
                        
                        if i == json["stores"].count - 1 {
                            LoginModel.sharedInstance.prefs.set(LoginModel.sharedInstance.storeName, forKey: "storeName")
                            LoginModel.sharedInstance.prefs.set(LoginModel.sharedInstance.storeId, forKey: "storeId")
                        }
                    }
                }
                LoginModel.sharedInstance.auth_token = json["auth_token"].stringValue
                LoginModel.sharedInstance.prefs.set(json["auth_token"].stringValue, forKey: "auth_token")
                
                self.loginView?.loginSucceded("Success Login: \(json)")
                
            case .failure(let error):
                print(".Failure Login: Request failed with error: \(error)")
                self.loginView?.loginFailured()
            }
        }
    }
}
