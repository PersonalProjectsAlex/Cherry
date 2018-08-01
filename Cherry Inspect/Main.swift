//
//  ViewController.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 6/20/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit
import GRDB
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol LoginViewProtocol{
    func loginSucceded(_ responseObject: String!)
    func loginFailured()
}

class Main: UIViewController, UITextFieldDelegate, LoginViewProtocol{
    
    var loginInteractor: LoginInteractorProtocol?
    let dbVersion = "1.4.2.2" //DB Version: 1.4.2.2 > Wed 17 May 1:12PM 2017

    @IBOutlet weak var btnKeepLogged: UIButton!
    @IBOutlet weak var tbxEmail: UITextField!
    @IBOutlet weak var tbxPassword: UITextField!
    
    var keyboardVisible:Bool? = false
    var keepLoggedCheck:Bool? = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! dbQueue.inDatabase { db in
            let checkDBConfig = try db.tableExists("dbConfig")
            
            if checkDBConfig {
                if let rowsCustomer = try Row.fetchOne(db, "SELECT * FROM dbConfig WHERE id = 1") {
                    let version: String = rowsCustomer["version"]
                    if version != dbVersion {
                        
                        print("DB Dropped at: \(Date())")
                        try createDB()
                    }
                }
            }else{
                print("DB Created at: \(Date())")
                try createDB()
            }
        }
        
        loginInteractor = LoginInteractor(loginView: self)
        
        keepLoggedCheck = LoginModel.sharedInstance.prefs.bool(forKey: "keepLogged")
        
        if (keepLoggedCheck != nil) && (keepLoggedCheck == true) {
            tbxEmail.text = LoginModel.sharedInstance.prefs.value(forKey: "email") as? String
            tbxPassword.text = LoginModel.sharedInstance.prefs.value(forKey: "password") as? String
            
            if self.tbxEmail.text?.characters.count > 0 && self.tbxPassword.text?.characters.count > 0{
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "homeView")
                navigationController?.pushViewController(vc, animated: true)
            }else{
                LoginModel.sharedInstance.prefs.set(false, forKey: "keepLogged")
                keepLoggedCheck = false
                tbxEmail.text = ""
                tbxPassword.text = ""
            }
        }
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        
        if !LoginModel.sharedInstance.prefs.bool(forKey: "keepLogged"){
            LoginModel.sharedInstance.keepLogged()
            self.keepLoggedCheck = false
            self.btnKeepLogged.setBackgroundImage(UIImage(named: "Uncheked2_Icon"), for: UIControlState())
        }else{
            self.keepLoggedCheck = true
            self.btnKeepLogged.setBackgroundImage(UIImage(named: "Checked2_Icon"), for: UIControlState())
        }
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "LoginView-iOS")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if keyboardVisible == false{
            keyboardVisible = true
            animateViewMoving(true, moveValue: 100)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tbxEmail {
            tbxPassword.becomeFirstResponder()
        } else if textField == tbxPassword {
            tbxPassword.resignFirstResponder()
            animateViewMoving(false, moveValue: 100)
            keyboardVisible = false
        }
        return false
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    // MARK: - ForgotPassword Action
    @IBAction func forgotPassword(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Hi!", message:
            "This feature will be available soon! ;)", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - KEEP LOGGED Action
    @IBAction func keepLogged(_ sender: AnyObject) {
        if self.keepLoggedCheck == true {
            self.keepLoggedCheck = false
            LoginModel.sharedInstance.prefs.set(false, forKey: "keepLogged")
            LoginModel.sharedInstance.keepLogged()
            self.btnKeepLogged.setBackgroundImage(UIImage(named: "Uncheked2_Icon"), for: UIControlState())
        }else{
            self.keepLoggedCheck = true
            LoginModel.sharedInstance.prefs.set(true, forKey: "keepLogged")
            LoginModel.sharedInstance.keepLogged()
            self.btnKeepLogged.setBackgroundImage(UIImage(named: "Checked2_Icon"), for: UIControlState())
        }
    }
    
    // MARK: - LOGIN Action
    @IBAction func btnLogin(_ sender: AnyObject) {
        self.view.endEditing(true)
        if keyboardVisible == true{
            keyboardVisible = false
            animateViewMoving(false, moveValue: 100)
        }
        
        if self.tbxEmail.text?.characters.count > 0 && self.tbxPassword.text?.characters.count > 0{
            loginInteractor!.performLogin(self.tbxEmail.text!, password: self.tbxPassword.text!)
        }else{
            let alertController = UIAlertController(title: "Cherry Drive", message:
                "Please type in a valid email and password", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func loginSucceded(_ responseObject: String!) {
        LoginModel.sharedInstance.email = self.tbxEmail.text
        LoginModel.sharedInstance.password = self.tbxPassword.text
        
        LoginModel.sharedInstance.prefs.setValue(self.tbxEmail.text, forKey: "email")
        LoginModel.sharedInstance.prefs.setValue(self.tbxPassword.text, forKey: "password")
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "homeView")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func loginFailured() {
        let alertController = UIAlertController(title: "Cherry Drive", message:
            "Invalid Username or Password.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func createDB() throws {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let documentDirectoryFileUrl = documentsDirectory.appendingPathComponent("db.sqlite")
        
        // Delete file in document directory
        if FileManager.default.fileExists(atPath: documentDirectoryFileUrl.path) {
            do {
                try FileManager.default.removeItem(at: documentDirectoryFileUrl)
                print("Deleted file")
            } catch {
                print("Could not delete file: \(error)")
            }
        }
        
        let app = UIApplication.shared
        var dbQueue: DatabaseQueue!
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
        let databasePath = documentsPath.appendingPathComponent("db.sqlite")
        dbQueue = try DatabaseQueue(path: databasePath)
        
        dbQueue.setupMemoryManagement(in: app)
        
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("createDBConfig_V1.2") { db in
            // Create a table
            try db.create(table: "dbConfig") { t in
                // An integer primary key auto-generates unique IDs
                t.column("id", .integer).primaryKey()
                t.column("version", .text)
                t.column("updated", .datetime)
            }
            
            let version = DBConfig(
                version: self.dbVersion,
                updated: Date()
            )
            try version.save(db)
        }
        
        migrator.registerMigration("createIncompleteInspections") { db in
            // Create a table
            try db.create(table: "incompleteCustomers") { t in
                // An integer primary key auto-generates unique IDs
                t.column("id", .integer).primaryKey()
                t.column("customer_id", .integer)
                t.column("full_name", .text)
                t.column("country", .text)
                t.column("state", .text)
                t.column("customer_status", .integer)
            }
        }
        
        migrator.registerMigration("createIncompleteVehicles") { db in
            // Create a table
            try db.create(table: "incompleteVehicles") { t in
                // An integer primary key auto-generates unique IDs
                t.column("id", .integer).primaryKey()
                t.column("vehicles_id", .integer)
                t.column("vehicles_vin", .text)
                t.column("vehicles_license", .text)
                t.column("vehicles_licensePlateState", .text)
                t.column("vehicles_model", .text)
                t.column("vehicles_make", .text)
                t.column("vehicles_year", .text)
                t.column("vehicles_description", .text)
                t.column("vehicles_mileage", .text)
                t.column("vehicles_status", .integer)
            }
        }
        
        migrator.registerMigration("inspectionsV1.0.2") { db in
            try db.create(table: "inspections") { t in
                // An integer primary key auto-generates unique IDs
                t.column("id", .integer).primaryKey()
                t.column("customer_id", .integer)
                t.column("inspection_id", .integer)
                t.column("vehicles_id", .integer)
                t.column("inspection_date", .datetime)
                t.column("inspection_status", .integer)
                t.column("inspection_procedure_id", .integer)
                t.column("title", .text)
            }
        }
        
        migrator.registerMigration("servicesInspectionsV1.0.1") { db in
            // Create a table
            try db.create(table: "services") { t in
                // An integer primary key auto-generates unique IDs
                t.column("id", .integer).primaryKey()
                t.column("remote_id", .integer)
                t.column("remote_inspection_id", .integer)
                t.column("internal_inspection_id", .integer)
                t.column("service_id", .integer)
                t.column("qty", .integer)
                t.column("service_status", .boolean)
                t.column("item_type", .text)
                t.column("comment", .text)
                t.column("image_url", .text)
                t.column("is_light", .boolean)
                t.column("light_selected", .boolean)
            }
        }
        
        try migrator.migrate(dbQueue)
        try! setupDatabase(UIApplication.shared)
    }
}

