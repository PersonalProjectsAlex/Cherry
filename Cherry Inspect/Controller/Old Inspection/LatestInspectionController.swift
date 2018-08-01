//
//  LatestInspectionController.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 7/1/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit
import GRDB
import Alamofire
import SwiftyJSON
import TBEmptyDataSet
import CodableAlamofire
import SwiftyBeaver

class LatestInspectionController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var incompleteInspection = [[String:AnyObject]]()
    var incompleteTitle = [String]()
    var incompleteProcedure_id = [Int64]()
    var inspection_id:Int64 = -1
    var incompleteCustomersCount = 0
    var incompleteVehiclesCount = 0
    var incompleteInspectionId = [Int64]()
    var incompleteInspectionArray = [""]
    var emptyValue = Bool()
    var getDraft = [Draft]()
    var getVehicle = [Vehicle]()
    var selectedDraft: Draft?
    
    
    /*  LATEST ARRAYS  */
    var latestInspectionID = [Int]()
    var latestInspectionCustomer = [""]
    var latestInspectionPlate = [""]
    var latestInspectionYear = [""]
    var latestInspectionMileage = [""]
    var latestInspectionState = [""]
    var latestInspectionMaker = [""]
    var latestInspectionVehicle = [""]
    
    
    var getProcedure:BaseProcedure?
    var latestInspections = [JSON]()
    private let refreshControl = UIRefreshControl()
    var shouldReload = true
    var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.emptyDataSetDataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        let rightButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(IncompleteInspectionsController.showEditing))
        
        self.navigationItem.rightBarButtonItem = rightButton
        
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        self.shouldReload = true
        isLoading = true
        self.getLatestInspections()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getLatestInspections()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationController?.navigationBar.barTintColor = Constants.CherryDrivePrimaryColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationController?.isNavigationBarHidden = false
        self.tableView.reloadData()
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "IncompleteInspectionsView-iOS")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    // MARK: - TABLEVIEW
    @objc func showEditing()
    {
        
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing == true{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(IncompleteInspectionsController.showEditing))
        }else{
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(IncompleteInspectionsController.showEditing))
            
        }
    }
    
    @objc func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.latestInspections.count
    }
    
    
    func getProcedures(procedureID:Int, associatedCell: LatestInspectionCell){
        if associatedCell.data != nil && self.shouldReload == false {
            return
        }
        let decoder = JSONDecoder()
        guard let token = LoginModel.sharedInstance.prefs.value(forKey: "auth_token") as? String else{
            print("we have an issue with token to be fixed")
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        weak var weakSelf = self
        Alamofire.request("\(CherryApi.rootURL)api/v1/inspections/\(procedureID)", method: .get, headers: headers).responseDecodableObject(keyPath: nil, decoder: decoder) { (response: DataResponse<BaseProcedure>) in
            
            //            print("Response1: \(response.result.value)")
            if let procedureResponse = response.result.value{
                print(procedureResponse)
                
                associatedCell.data = procedureResponse
                weakSelf?.getProcedure = procedureResponse
                weakSelf?.tableView.reloadData()
                
                //self.selectedProcedureID = procedureResponse.procedure?.id
                print("Response1: \(procedureResponse.procedure?.id)")
                
                print("Response2: \(procedureResponse.id)")
                print("Response3: \(procedureResponse.vehicle?.id)")
            }
            
            
        }
        
    }
    
    
    func getLatestInspections(){
        self.latestInspections.removeAll()
        tableView.reloadData()
        isLoading = true
        guard let token = LoginModel.sharedInstance.prefs.value(forKey: "auth_token") as? String else{
            print("we have an issue with token to be fixed")
            isLoading = false
            return
        }
        
        guard let store_id = LoginModel.sharedInstance.selectedStoreId else{
            SwiftyBeaver.error("We could not find store_id")
            isLoading = false
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        let proceduresUrl = "\(CherryApi.createInspectionUrl)"
        let params: Parameters = ["store_id": store_id, "draft": 0]
        
        weak var weakSelf = self
        Alamofire.request(proceduresUrl, method: .get, parameters: params, headers: headers).checkConnectivity().showHUD().responseJSON { response in
            ProgressHudManager.sharedInstance.hide()
            self.shouldReload = false
            switch response.result{
            case .success(let value):
                self.latestInspections = JSON(value).arrayValue
                
                weakSelf?.refreshControl.endRefreshing()
                weakSelf?.tableView.reloadData()
                
                if self.latestInspections.count == 0{
                    self.isLoading = false
                    SwiftyBeaver.warning("value is 0")
                    weakSelf?.tableView.updateEmptyDataSetIfNeeded()
                }
                
            case .failure:
                self.isLoading = false
                let msg = "Please check your API in \(proceduresUrl)?store_id=\(LoginModel.sharedInstance.selectedStoreId!.description)&draft=1"
                // -MARK: TODO
                
                Core.shared.alert(message: "Something wrong, please contact with support", title: "Cherry Drive", at: self)
                
                print(msg)
            }
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellLatestInspection", for: indexPath) as! LatestInspectionCell
        var incompleteInspection = self.latestInspections[indexPath.row]
        print("----0---00---0")
        print(incompleteInspection)
        cell.inspectionId = incompleteInspection["id"].intValue
        getProcedures(procedureID: incompleteInspection["id"].intValue, associatedCell: cell)
        cell.cellCustomerName.text = incompleteInspection["vehicle"].dictionaryValue["name"]?.stringValue
        cell.cellYear.text = incompleteInspection["vehicle"].dictionaryValue["year"]?.stringValue
        cell.cellVehicle.text = incompleteInspection["vehicle"].dictionaryValue["model"]?.stringValue
        cell.cellPlate.text = incompleteInspection["vehicle"].dictionaryValue["license"]?.stringValue
        cell.cellMileage.text = incompleteInspection["vehicle"].dictionaryValue["mileage"]?.stringValue
        cell.cellState.text = incompleteInspection["vehicle"].dictionaryValue["license_plate_state"]?.stringValue
        cell.cellMaker.text = incompleteInspection["vehicle"].dictionaryValue["make"]?.stringValue
        cell.configureTiming(time: incompleteInspection["created_at"].stringValue)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ProgressHudManager.sharedInstance.show()
        let cell = tableView.cellForRow(at: indexPath) as! LatestInspectionCell
        if cell.data == nil {
            var incompleteInspection = self.latestInspections[indexPath.row]
            getProcedures(procedureID: incompleteInspection["id"].intValue, associatedCell: cell)
            return
        }
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            print("PRCO:  \(self.getProcedure?.procedure?.id)")
            
            guard let procedureid = self.getProcedure?.procedure?.id else{
                print("procedureid is empty yet")
                return
            }
            let storyboard = UIStoryboard(name: "NewInspection_iPad", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "newInspectionIPadView") as! NewInspectionController
            vc.procedure_id = cell.data!.procedure!.id!
            vc.isNewInspection = false
            vc.incompleteInspection = self.incompleteInspection
            vc.inspection_id = cell.inspectionId
            vc.getDraft = self.selectedDraft
            vc.incompleteIndex = indexPath.row
            vc.isDraftInspection = true
            vc.savedData = cell.data
            navigationController?.pushViewController(vc, animated: true)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }else {
            
            
            print("PRCO:  \(self.getProcedure?.procedure?.id)")
            
            guard let procedureid = self.getProcedure?.procedure?.id else{
                print("procedureid is empty yet")
                return
            }
            let storyboard = UIStoryboard(name: "NewInspection", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "newInspectionView") as! NewInspectionController
            
            vc.procedure_id = cell.data!.procedure!.id!
            vc.isNewInspection = false
            vc.incompleteInspection = self.incompleteInspection
            vc.inspection_id = cell.inspectionId
            vc.getDraft = self.selectedDraft
            vc.incompleteIndex = indexPath.row
            vc.isDraftInspection = true
            vc.savedData = cell.data
            navigationController?.pushViewController(vc, animated: true)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // DELETE FROM documents WHERE rowid = 1
            guard let token = LoginModel.sharedInstance.prefs.value(forKey: "auth_token") as? String else{
                print("we have an issue with token to be fixed")
                return
            }
            
            let headers: HTTPHeaders = [
                "Authorization": token,
                "Content-Type": "application/json"
            ]
            
            var incompleteInspection = self.latestInspections[indexPath.row]
            
            let id = incompleteInspection["id"].intValue.description
            
            print(id)
            ProgressHudManager().activityIndicator.startAnimating()
            Alamofire.request("\(CherryApi.rootURL)api/v1/inspections/\(id)", method: .delete, headers: headers).responseString(completionHandler: { (reponse) in
                
                print(reponse)
                
                ProgressHudManager().activityIndicator.stopAnimating()
                tableView.reloadData()
                
            })
            
            
            tableView.reloadData()
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
}


