//
//  HomeController.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 7/1/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftyBeaver

class HomeController: UIViewController {
    let prefs = UserDefaults.standard
    @IBOutlet var pickerStore: UIPickerView! = UIPickerView()
    
    var storeName = [String]()
    var storeId = [Int]()
    
    var selectedStore:Int = 0
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeController.checkUrlScheme), name: NSNotification.Name(rawValue: "checkUrlScheme"), object: nil)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(prefs.bool(forKey: "urlScheme"))
        
        pickerStore.isHidden = true
        self.storeName = (prefs.object(forKey: "storeName") as? Array)!
        self.storeId = (prefs.object(forKey: "storeId") as? Array)!
        
        if self.storeId.count > 0 {
            LoginModel.sharedInstance.selectedStoreId = self.storeId[self.selectedStore]
            loadProcedures()
        }
        
        IncompleteInspectionModel.sharedInstance.loadData()
        
        self.navigationController?.navigationBar.barTintColor = Constants.CherryDrivePrimaryColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationController?.isNavigationBarHidden = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "MenuView-iOS")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    @objc func checkUrlScheme() {
        if prefs.bool(forKey: "urlScheme"){
            if ProcedureModel.sharedInstance.allProcedures.count > 0{
                if let cellBtnTitle = ProcedureModel.sharedInstance.allProcedures[0]["name"] as? String{
                    let procedureID = ProcedureModel.sharedInstance.allProcedures[0]["id"] as! Int
                    performNewCustomer(cellBtnTitle, procedure_id: procedureID)
                }
            }
        }else{
            VehiclesModel.sharedInstance.resetVehiclesModel()
            CustomersModel.sharedInstance.resetCustomersModel()
        }
    }
    
    @objc func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return ProcedureModel.sharedInstance.allProcedures.count
        }
        if section == 1{
            return 0
        }else{
            return 4
        }
    }
    
    @objc func tableView(_ tableView: UITableView!, heightForRowAtIndexPath indexPath: IndexPath!) -> CGFloat {
        var cellHeight:CGFloat = 0.0
        if indexPath.section == 0{
            cellHeight = 44.0
        }else if indexPath.section == 1{
            cellHeight = 42.0
        }else{
            cellHeight = 60.0
        }
        return cellHeight
    }
    
    @objc func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellInspectionType", for: indexPath) as! HomeCell
            switch indexPath.row {
            case 0:
                if let cellBtnTitle = ProcedureModel.sharedInstance.allProcedures[0]["name"] as? String{
                    cell.btnTitle.text = cellBtnTitle
                }
            case 1:
                if let cellBtnTitle = ProcedureModel.sharedInstance.allProcedures[1]["name"] as? String{
                    cell.btnTitle.text = cellBtnTitle
                }
            case 2:
                if let cellBtnTitle = ProcedureModel.sharedInstance.allProcedures[2]["name"] as? String{
                    cell.btnTitle.text = cellBtnTitle
                }
            default:
                print("range out")
            }
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSpecialInspectionType", for: indexPath) as! HomeCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellHomeButton", for: indexPath) as! HomeCell
            switch indexPath.row {
            case 0:
                cell.btnImage.image = UIImage(named: "Branch_Icon")
                if self.storeName.count > 0 {
                    cell.cellTitle.text = storeName[self.selectedStore]
                    cell.customSeperator.isHidden = true
                }
            case 1:
                cell.btnImage.image = UIImage(named: "OldInspection_Icon")
                cell.cellTitle.text = "Latest Inspections"
                cell.customSeperator.isHidden = false
            case 2:
                cell.btnImage.image = UIImage(named: "Inspections_Icon")
                cell.cellTitle.text = "Draft Inspections"
                cell.customSeperator.isHidden = false
            case 3:
                cell.btnImage.image = UIImage(named: "LogOut_Icon")
                cell.cellTitle.text = "Log Out"
                cell.customSeperator.isHidden = false
            default:
                print("range out")
            }
            return cell
        }
    }
    
    @objc func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! HomeCell
        if indexPath.section == 0{
            let cellTitle = cell.btnTitle.text
            let procedureID = ProcedureModel.sharedInstance.allProcedures[indexPath.row]["id"] as! Int
            performNewCustomer(cellTitle!, procedure_id: procedureID)
        }else if indexPath.section == 1{
            let cellTitle = cell.btnTitle.text
            let procedureID = ProcedureModel.sharedInstance.allProcedures[0]["id"] as! Int
            performNewCustomer(cellTitle!, procedure_id: procedureID)
        }else{
            switch indexPath.row {
            case 0:
                selectStore()
            case 1:
                latestInspection()
            case 2:
                incompleteInspection()
            case 3:
                performLogout()
            default:
                print("range out")
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // returns the number of 'columns' to display.
    @objc func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    @objc func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        return storeName.count
    }
    
    @objc func pickerView(_ pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
        return storeName[row]
    }
    
    @objc func pickerView(_ pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int)
    {
        var storeName = self.storeName[row]
        let indexPath:IndexPath = IndexPath(row: 0, section: 2);  //slecting 0th row with 0th section
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHomeButton", for: indexPath) as! HomeCell
        cell.btnImage.image = UIImage(named: "Branch_Icon")
        LoginModel.sharedInstance.selectedStoreId = self.storeId[row]
        self.selectedStore = row
        cell.cellTitle.text = storeName
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        loadProcedures()
        pickerStore.isHidden = true
    }
    
    @IBAction func selectStore() {
        if self.storeName.count > 0 {
            pickerStore.isHidden = false
        }
    }
    
    func performNewCustomer(_ myTitle: String, procedure_id:Int) {
        NewInspectionModel.sharedInstance.resetNewInspectionModel()
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            let storyboard = UIStoryboard(name: "NewInspection_iPad", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "newInspectionIPadView") as! NewInspectionController
            vc.title = myTitle
            vc.procedure_id = procedure_id
            navigationController?.pushViewController(vc, animated: true)
        }else {
            let storyboard = UIStoryboard(name: "NewInspection", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "newInspectionView") as! NewInspectionController
            vc.title = myTitle
            vc.procedure_id = procedure_id
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func latestInspection() {
        if self.storeId.count > 0 {
            let storyboard = UIStoryboard(name: "LatestInspection", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "latestInspectionsView")
            vc.title = "Latest Inspections"
            navigationController?.pushViewController(vc, animated: true)
        }else{
            let alertController = UIAlertController(title: "Cherry Drive", message:
                "Sorry, to perform this operation you need to be associated to a store. Please inform this problem to your administrator.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func incompleteInspection() {
        if self.storeId.count > 0 {
            let storyboard = UIStoryboard(name: "IncompleteInspections", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "incompleteInspectionsView")
            vc.title = "Inspections to Complete"
            navigationController?.pushViewController(vc, animated: true)
        }else{
            let alertController = UIAlertController(title: "Cherry Drive", message:
                "Sorry, to perform this operation you need to be associated to a store. Please inform this problem to your administrator.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func performLogout() {
        guard let token = LoginModel.sharedInstance.prefs.value(forKey: "auth_token") as? String else{
            SwiftyBeaver.error("Please check token status")
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(CherryApi.authUrl, method: .delete, parameters: nil, headers: headers).checkConnectivity().showHUD().responseJSON { response in
            ProgressHudManager.sharedInstance.hide()
            if response.result.isSuccess{
                print("LogOut isSuccess!")
            }else{
                print("LogOut Error!")
            }
        }
        
        LoginModel.sharedInstance.removeToken()
        LoginModel.sharedInstance.removeStores()
        LoginModel.sharedInstance.prefs.set(false, forKey: "keepLogged")
        
        Core.shared.alert(message: "You have been logged out", title: "Cherry Drive", at: self)
        
    }
    
    func loadProcedures(){
        guard let token = LoginModel.sharedInstance.prefs.value(forKey: "auth_token") as? String else{
            SwiftyBeaver.error("Please check token status")
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        SwiftyBeaver.debug("Token:\(token)")
        
        let parameters = ["store_id": LoginModel.sharedInstance.selectedStoreId] as [String:AnyObject]
        
        Alamofire.request(CherryApi.proceduresUrl, method: .get, parameters: parameters, headers: headers).checkConnectivity().showHUD().responseJSON { response in
            ProgressHudManager.sharedInstance.hide()
            if response.result.isSuccess{
                let json = JSON(response.result.value!)
                NewInspectionModel.sharedInstance.resetNewInspectionModel()
                ProcedureModel.sharedInstance.resetProcedureModel()
                if json.count > 0 {
                    for i in 0...json.count - 1{
                        ProcedureModel.sharedInstance.allProcedures.append([
                            "id": json[i]["id"].intValue as AnyObject,
                            "name": json[i]["name"].stringValue as AnyObject,
                            "description": json[i]["description"].stringValue as AnyObject,
                            "csv_ids": json[i]["csv_ids"].stringValue as AnyObject,
                            "parent": json[i]["parent"].object as AnyObject
                        ])
                    }
                }
                self.tableView.reloadData()
                self.checkUrlScheme()
            }else{
                print("You don't have permission to access this menu.")
            }
        }
    }
}
