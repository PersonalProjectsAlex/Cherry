//
//  SessionManager.swift
//  CherryDrive
//
//  Created by Jefferson S. Batista on 5/1/16.
//  Copyright © 2016 Ring Seven. All rights reserved.
//

import UIKit
//import SimpleKeychain

class SessionManager: NSObject {
    static let sharedInstance = SessionManager()
    
//    fileprivate let AuthToken = "auth_token"
//    fileprivate let emailKey = "email"
//    fileprivate let userIdKey = "userId"
//    
//    var selectedStoreId:Int?
//    
//    var storeId:[Int] = []
//    var storeStatus:[Bool] = []
//    var storeName:[String] = []
//    
////    let keychain = A0SimpleKeychain()
//    
//    var authToken: String? {
//        get {
//            return keychain.string(forKey: AuthToken) ?? ""
//        }
//        set {
//            keychain.setString(newValue!, forKey: AuthToken)
//        }
//    }
//    
//    var email: String {
//        get {
//            return keychain.string(forKey: emailKey) ?? ""
//        }
//        set {
//            keychain.setString(newValue, forKey: emailKey)
//        }
//    }
//    
//    var userId: String {
//        get {
//            return keychain.string(forKey: userIdKey) ?? ""
//        }
//        set {
//            keychain.setString(newValue, forKey: userIdKey)
//        }
//    }
//    
//    func saveStores(_ store_name:String, store_id:Int, store_status:Bool) {
//        self.storeId.append(store_id)
//        self.storeName.append(store_name)
//        self.storeStatus.append(store_status)
//    }
//    func removeStores() {
//        self.storeId.removeAll()
//        self.storeName.removeAll()
//        self.storeStatus.removeAll()
//    }
//    func removeToken() {
//        if keychain.hasValue(forKey: AuthToken) {
//            keychain.deleteEntry(forKey: AuthToken)
//        }
//    }
//    
//    func removeAllKeychainINFO(){
//        keychain.deleteEntry(forKey: AuthToken)
//        keychain.deleteEntry(forKey: emailKey)
//        keychain.deleteEntry(forKey: userIdKey)
//    }
}
