//
//  InspectionsController.swift
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

class IncompleteInspectionsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    var incompleteInspections = [JSON]()
    
    var loading = false
    var isLoading = true
    private let refreshControl = UIRefreshControl()
    var shouldReload = true
    var number = 1
    
    //- MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        SwiftyBeaver.debug(getHeader())
        
        
        let rightButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(IncompleteInspectionsController.showEditing))
        
        self.navigationItem.rightBarButtonItem = rightButton
        
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        self.shouldReload = true
        isLoading = true
        self.getDraftInspections()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getDraftInspections()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.shouldReload = true
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
        return self.incompleteInspections.count
    }
    
    
    func getProcedures(procedureID:Int, associatedCell: IncompleteInspectionCell){
        if associatedCell.data != nil && self.shouldReload == false {
            return
        }
        let decoder = JSONDecoder()

        weak var weakSelf = self
        let getProceduresURL = "\(CherryApi.rootURL)api/v1/inspections/\(procedureID)"
        Alamofire.request(getProceduresURL, method: .get, headers: getHeader()).responseDecodableObject(keyPath: nil, decoder: decoder) { (response: DataResponse<BaseProcedure>) in
            
            print(response)
            
            if let procedureResponse = response.result.value{
                print(procedureResponse)
                associatedCell.data = procedureResponse
                weakSelf?.getProcedure = procedureResponse
                weakSelf?.tableView.reloadData()

            }
            
            
        }
        
    }
    
    
    func getDraftInspections(){
        self.incompleteInspections.removeAll()
        tableView.reloadData()
        isLoading = true
        let proceduresUrl = "\(CherryApi.createInspectionUrl)"
        guard let store_id = LoginModel.sharedInstance.selectedStoreId else{
            SwiftyBeaver.error("We could not find store_id")
            isLoading = false
            return
        }
        let params: Parameters = ["store_id": store_id.description,"draft": 1]
        
        
        weak var weakSelf = self
        Alamofire.request(proceduresUrl, method: .get, parameters: params, headers: getHeader()).checkConnectivity().showHUD().responseJSON { response in
            ProgressHudManager.sharedInstance.hide()
            self.shouldReload = false
            
            switch response.result{
            case .success(let value):
                self.incompleteInspections.removeAll()
                weakSelf?.tableView.reloadData()
                print(response)
                
                self.incompleteInspections = JSON(value).arrayValue
                weakSelf?.refreshControl.endRefreshing()
                weakSelf?.tableView.reloadData()
                
                
                if self.incompleteInspection.count == 0{
                    self.isLoading = false
                    SwiftyBeaver.warning("value is 0")
                    weakSelf?.tableView.updateEmptyDataSetIfNeeded()
                }
                
                
            case .failure(let error):
                self.isLoading = false
                
                let msg = "Please check your API in \(proceduresUrl)?store_id=\(LoginModel.sharedInstance.selectedStoreId!.description)&draft=0"
               
                Core.shared.alert(message: "Something wrong, please contact with support", title: "Cherry Drive", at: self)
                
                print(error)
                print(msg)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIncompleteInspection", for: indexPath) as! IncompleteInspectionCell
        var incompleteInspection = self.incompleteInspections[indexPath.row]
        getProcedures(procedureID: incompleteInspection["id"].intValue, associatedCell: cell)
        cell.inspectionId = incompleteInspection["id"].intValue
        cell.cellCustomerName.text = incompleteInspection["vehicle"].dictionaryValue["name"]?.stringValue
        cell.cellYear.text = incompleteInspection["vehicle"].dictionaryValue["year"]?.stringValue
        cell.cellVehicle.text = incompleteInspection["vehicle"].dictionaryValue["model"]?.stringValue
        cell.cellPlate.text = incompleteInspection["vehicle"].dictionaryValue["license"]?.stringValue
        cell.cellMileage.text = incompleteInspection["vehicle"].dictionaryValue["mileage"]?.stringValue
        cell.cellState.text = incompleteInspection["vehicle"].dictionaryValue["license_plate_state"]?.stringValue
        cell.cellMaker.text = incompleteInspection["vehicle"].dictionaryValue["make"]?.stringValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ProgressHudManager.sharedInstance.show()
        let cell = tableView.cellForRow(at: indexPath) as! IncompleteInspectionCell
        if cell.data == nil {
            var incompleteInspection = self.incompleteInspections[indexPath.row]
            getProcedures(procedureID: incompleteInspection["id"].intValue, associatedCell: cell)
            return
        }
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            let storyboard = UIStoryboard(name: "NewInspection_iPad", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "newInspectionIPadView") as! NewInspectionController
            vc.draftStatus = true
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
            vc.draftStatus = true
            navigationController?.pushViewController(vc, animated: true)
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            var incompleteInspection = self.incompleteInspections[indexPath.row]
            
            let id = incompleteInspection["id"].intValue.description
            ProgressHudManager().activityIndicator.startAnimating()
            Alamofire.request("\(CherryApi.rootURL)api/v1/inspections/\(id)", method: .delete, headers: getHeader()).responseString(completionHandler: { (reponse) in
                
                print(reponse)
                if reponse.result.isSuccess{
                    ProgressHudManager().activityIndicator.stopAnimating()
                    self.getDraftInspections()
                }
                
            })
            
            
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    
    
    //- MARK: SetUps
    func getHeader() -> HTTPHeaders{
        //Header
        var header: HTTPHeaders
        var saveToken = String()
        
        if let token = LoginModel.sharedInstance.prefs.value(forKey: "auth_token") as? String {
             saveToken = token
        }
        header = [
            "Authorization": saveToken,
            "Content-Type": "application/json"
        ]
        
        return header
    }
    
    func setupTableView(){
        tableView.emptyDataSetDataSource = self
        tableView.emptyDataSetDelegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
}

