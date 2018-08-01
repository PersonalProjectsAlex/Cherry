//
//  Login.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 6/21/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

class LoginModel: NSObject {
    static let sharedInstance = LoginModel()
    
    let prefs = UserDefaults.standard
    var email:String?
    var password:String?
    var auth_token:String?
    
    var storeId:[Int] = []
    var storeStatus:[Bool] = []
    var storeName:[String] = []
    
    var selectedStoreId:Int?
    
    init(email:String = "", password:String = "", auth_token:String = "") {
        self.email = email
        self.password = password
        self.auth_token = auth_token
    }
    
    func keepLogged() {
        if prefs.bool(forKey: "keepLogged"){
            prefs.setValue(self.auth_token, forKey: "auth_token")
            prefs.setValue(self.email, forKey: "email")
            prefs.setValue(self.password, forKey: "password")
            prefs.set(self.storeName, forKey: "storeName")
            prefs.set(self.storeId, forKey: "storeId")
        }else{
            prefs.setValue(nil, forKey: "auth_token")
            prefs.setValue("", forKey: "email")
            prefs.setValue("", forKey: "password")
            prefs.set([], forKey: "storeName")
            prefs.set([], forKey: "storeId")
        }
    }
    
    func removeStores() {
        self.storeId.removeAll()
        self.storeName.removeAll()
        self.storeStatus.removeAll()
        prefs.set([], forKey: "storeName")
        prefs.set([], forKey: "storeId")
    }
    func removeToken() {
        prefs.setValue(nil, forKey: "auth_token")
    }
}
