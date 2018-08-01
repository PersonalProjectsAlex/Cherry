//
//  NewInspectionController.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 8/5/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GRDB
import SwiftyBeaver

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

extension String {
    var isNumeric: Bool {
        guard self.characters.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self.characters).isSubset(of: nums)
    }
}

class NewInspectionController: UIViewController, newInspectionProtocol {
    
    //Set data
    var setState = String()
    var setPlate = String()
    
    
    let prefs = UserDefaults.standard
    
    @IBOutlet var pickerQty: UIPickerView! = UIPickerView()
    
    @IBOutlet weak var lbl_InfoService: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var pellicleView: UIView!
    @IBOutlet weak var collectionComments: UICollectionView!
    @IBOutlet weak var btnCommentDone: UIButton!
    @IBOutlet weak var tbComments: UITextField!
    
    @IBOutlet weak var tbCommentsView: UIView!
    
    @IBOutlet weak var lightView: UIView!
    @IBOutlet weak var collectionLightFront: UICollectionView!
    @IBOutlet weak var collectionLightRear: UICollectionView!
    @IBOutlet weak var lblLightR: UILabel!
    @IBOutlet weak var lblLightL: UILabel!
    var lightServicesToSaveFront = [Int]()
    var lightServicesToSaveBack = [Int]()
    
    var myComment:String?
    
    var procedure_id:Int?
    var inspection_id: Int?
    var internal_inspection_id:Int = -1
    var VehiclesID:Int64?
    
    var service = [NewInspectionModel.service()]
    
    var isNewInspection:Bool = true
    var incompleteInspection = [[String:AnyObject]]()
    var incompleteIndex:Int?
    var isDraftInspection:Bool = false
    
    var servicesName = [String]()
    var servicesImage = [String]()
    var serviceButtons = [[Bool]]()
    var default_comment = [String]()
    var servicesId = [Int]()
    var servicesQty = [Int]()
    var imageToSave = [String]()
    var camCheckImage = [Bool]()
    var servicesType = [String]()
    
    var selectedCell: UITableViewCell?
    var cellIndex:Int?
    
    var frontItemsStatus = [false,false,false,false,false,false,false,false,false,false,false,false]
    var rearItemsStatus = [false,false,false,false,false,false,false,false,false,false,false,false]
    
    
    var getDraft: Draft?
    var procedures: BaseProcedure?
    var flagString = String()
    var savedData: BaseProcedure?
    var alreadyLoaded = false
    var draftStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.inspection_id)
        
        if isNewInspection || isDraftInspection{
            let btnSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveDraft))
            self.navigationItem.rightBarButtonItem = btnSave
        }else{
            let btnSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.performSaveInspection))
            self.navigationItem.rightBarButtonItem = btnSave
        }
        
        let image = UIImage(named: "back_arrow")?.withRenderingMode(.alwaysOriginal)
        let btnBack = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.backToInitial))
        
        
        self.navigationItem.leftBarButtonItem = btnBack
        
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        addShadowToBar(self.navigationController!.navigationBar)
        addShadowToBar(self.headerView)
        
        tbCommentsView.layer.borderColor = Constants.CherryDriveBorderColor.cgColor
        
        NewInspectionModel.sharedInstance.resetNewInspectionModel()
        
        
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true )
        
    }
    
    
    
    @objc func backToInitial() {
        if isNewInspection && CustomersModel.sharedInstance.license != ""{
            let alertController = UIAlertController(title: "Save inspection", message: "Would you like to save before exiting?", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
                
                
                if self.isDraftInspection == false {
                    self.saveInspectionInDraft()
                }else{
                    print("sds")
                }
                
                
                
                self.popBack()
            }))
            
            alertController.addAction(UIAlertAction(title: "NO", style: .default, handler: { (action: UIAlertAction!) in
                self.navigationController?.popViewController(animated: true)
            }))
            
            present(alertController, animated: true, completion: nil)
        }else{
            self.popBack()
        }
    }
    
    //    override func viewDidDisappear(_ animated: Bool) {
    //        self.servicesType.removeAll()
    //    }
    //
    
    func setType(){
        guard let token = LoginModel.sharedInstance.prefs.value(forKey: "auth_token") as? String else{
            print("we have an issue with token to be fixed")
            return
        }
        
        guard let procedure_id = procedure_id else{
            print("we have an issue with procedure_id to be fixed")
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        guard let selectedStoreID = LoginModel.sharedInstance.selectedStoreId else{
            print("selectedStoreId is empty yet")
            return
        }
        
        let proceduresUrl = "\(CherryApi.proceduresUrl)/\(procedure_id)?store_id=\(selectedStoreID)"
        print(proceduresUrl)
        weak var weakSelf = self
        Alamofire.request(proceduresUrl, method: .get, parameters: nil, headers: headers).checkConnectivity().showHUD().responseJSON { response in
            ProgressHudManager.sharedInstance.hide()
            if response.result.isSuccess{
                let json = JSON(response.result.value!)
                weakSelf?.service.removeAll()
                print("Prccedures result ID: \(json)")
                
                if self.isNewInspection == false {
                    NewInspectionModel.sharedInstance.toSave = self.incompleteInspection
                    
                    if (json["procedure_services"]).count > 0 {
                        for i in 0...(json["procedure_services"]).count - 1 {
                            
                            weakSelf?.service.append(NewInspectionModel.service(
                                id: json["procedure_services"][i]["service"]["id"].intValue,
                                name: json["procedure_services"][i]["service"]["name"].stringValue,
                                description: json["procedure_services"][i]["service"]["description"].stringValue,
                                default_comment: json["procedure_services"][i]["service"]["default_comment"].stringValue,
                                default_comment_2: json["procedure_services"][i]["service"]["default_comment_2"].stringValue,
                                status: json["procedure_services"][i]["service"]["status"].boolValue,
                                icon: CherryApi.rootURL + json["procedure_services"][i]["service"]["icon"].stringValue)
                            )
                            NewInspectionModel.sharedInstance.servicesId.append(json["procedure_services"][i]["service"]["id"].intValue)
                            
                            var data = weakSelf?.incompleteInspection
                            data = data?.filter { $0["service_id"] as! Int == json["procedure_services"][i]["service"]["id"].intValue}
                            
                            if data?.count > 0 {
                                NewInspectionModel.sharedInstance.servicesStatus.append(1)
                                
                                if data?[0]["id"] as? Int > 0 {
                                    NewInspectionModel.sharedInstance.id.append((data?[0]["id"] as? Int)!)
                                    SwiftyBeaver.verbose(data?[0]["id"])
                                }else{
                                    NewInspectionModel.sharedInstance.id.append(0)
                                }
                                
                                if data?[0]["qty"] as? Int > 0 {
                                    NewInspectionModel.sharedInstance.servicesQty.append((data?[0]["qty"] as? Int)!)
                                }else{
                                    NewInspectionModel.sharedInstance.servicesQty.append(0)
                                }
                                
                                if data?[0]["item_type"] as? String != "" {
                                    NewInspectionModel.sharedInstance.servicesType.append((data?[0]["item_type"] as? String)!)
                                }else{
                                    NewInspectionModel.sharedInstance.servicesType.append("")
                                }
                                
                                if data?[0]["comment"] as? String != "" {
                                    NewInspectionModel.sharedInstance.comment.append((data?[0]["comment"] as? String)!)
                                }else{
                                    NewInspectionModel.sharedInstance.comment.append("")
                                }
                                
                                if data?[0]["image"] as? String != "" {
                                    NewInspectionModel.sharedInstance.camCheckImage.append(true)
                                    NewInspectionModel.sharedInstance.imageToSave.append((data?[0]["image"] as? String)!)
                                }else{
                                    NewInspectionModel.sharedInstance.camCheckImage.append(false)
                                    NewInspectionModel.sharedInstance.imageToSave.append("")
                                }
                            }else{
                                weakSelf?.servicesAttributesDefault()
                            }
                            
                            if i == (json["procedure_services"]).count - 1{
                                weakSelf?.tableView.reloadData()
                                weakSelf?.collectionComments.reloadData()
                            }
                        }
                        self.alreadyLoaded = true
                        NewInspectionModel.sharedInstance.resetToSave(withCapacity: self.service.count)
                    }else{
                        self.lbl_InfoService.isHidden = false
                    }
                }else{
                    if (json["procedure_services"]).count > 0 {
                        for i in 0...(json["procedure_services"]).count - 1 {
                            self.service.append(NewInspectionModel.service(
                                id: json["procedure_services"][i]["service"]["id"].intValue,
                                name: json["procedure_services"][i]["service"]["name"].stringValue,
                                description: json["procedure_services"][i]["service"]["description"].stringValue,
                                default_comment: json["procedure_services"][i]["service"]["default_comment"].stringValue,
                                default_comment_2: json["procedure_services"][i]["service"]["default_comment_2"].stringValue,
                                status: json["procedure_services"][i]["service"]["status"].boolValue,
                                icon: CherryApi.rootURL + json["procedure_services"][i]["service"]["icon"].stringValue)
                            )
                            NewInspectionModel.sharedInstance.servicesId.append(json["procedure_services"][i]["service"]["id"].intValue)
                            NewInspectionModel.sharedInstance.servicesQty.append(0)
                            NewInspectionModel.sharedInstance.servicesStatus.append(1)
                            NewInspectionModel.sharedInstance.servicesType.append("")
                            NewInspectionModel.sharedInstance.comment.append("")
                            NewInspectionModel.sharedInstance.camCheckImage.append(false)
                            NewInspectionModel.sharedInstance.imageToSave.append("")
                            
                            if i == (json["procedure_services"]).count - 1{
                                self.tableView.reloadData()
                                self.collectionComments.reloadData()
                            }
                        }
                        self.alreadyLoaded = true
                        NewInspectionModel.sharedInstance.resetToSave(withCapacity: self.service.count)
                    }
                }
            }else{
                print("Erro on load procedureServices.")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("alreadyLoaded? \(self.alreadyLoaded)")
        if (!self.alreadyLoaded) {
            setType()
            getProcedures()
        }
        
        if isDraftInspection && setState.isEmpty == false {
            let array = NewInspectionModel.sharedInstance.toSave
            print("Se mamut")
            print(array)
        }
        print("Isnpection ID: \(procedure_id)")
        UIApplication.shared.isStatusBarHidden=false // for status bar hide
        
        if prefs.bool(forKey: "urlScheme"){
            prefs.set(false, forKey: "urlScheme")
            openCurtomerInfo()
        }
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "NewInspectionView-iOS")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    // MARK: - TABLEVIEW
    @objc func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return self.service.count
    }
    
    // There is just one row in every section
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    @objc func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else{
            return 15
        }
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        //headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    @objc func tableView(_ tableView: UITableView!, heightForRowAtIndexPath indexPath: IndexPath!) -> CGFloat {
        let cellHeight:CGFloat = 100.0
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellService", for: indexPath) as! NewInspectionCell
        cell.delegate = self
        let service = self.service[indexPath.section]
        cell.cellIndex = indexPath.section
        cell.configureCell(service: service, aditionalData: self.savedData)
        return cell
    }
    
    
    
    // MARK: - PICKERQTY
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        return 11
    }
    
    func pickerView(_ pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
        return String(row)
    }
    
    func pickerView(_ pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int)
    {
        let cell = self.selectedCell as! NewInspectionCell
        if row > 0 {
            cell.btnQty.setBackgroundImage(UIImage(named: "Btn_DarkBlue"), for: UIControlState())
        }else{
            cell.btnQty.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        }
        NewInspectionModel.sharedInstance.servicesQty[cell.cellIndex] = row
        cell.cellQTY = NewInspectionModel.sharedInstance.servicesQty[cell.cellIndex]
        guard let serviceName = cell.serviceName.text else{
            // Core.shared.alert(message: "Something bad with service name, please check it", title: "Something Wrong", at: self)
            print("Something bad with service name, please check it")
            return
        }
        
        if (serviceName.caseInsensitiveCompare("Front Lights") == ComparisonResult.orderedSame){
            self.updateLightServicesToSave(cell.cellIndex, arrayToSave: self.lightServicesToSaveFront)
        }else if (serviceName.caseInsensitiveCompare("Back Lights") == ComparisonResult.orderedSame){
            self.updateLightServicesToSave(cell.cellIndex, arrayToSave: self.lightServicesToSaveBack)
        }else{
            cell.addServiceToSave(cell.cellIndex)
        }
        pickerQty.isHidden = true
    }
    
    func showPickerQty(_ cell: UITableViewCell, cellQty: Int) {
        self.selectedCell = cell
        let cell = self.selectedCell as! NewInspectionCell
        
        if NewInspectionModel.sharedInstance.servicesType[cell.cellIndex] == "" {
            self.showToast(message: "Please select NA, REC, OK or ATT on your items")
            return
        }
        
        pickerQty.selectRow(cellQty, inComponent: 0, animated: true)
        pickerQty.isHidden = false
    }
    
    // MARK: - COLLECTIONVIEW
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let collectionViewHeight = collectionView.bounds.size.height
        let collectionViewWidth = collectionView.bounds.size.width
        
        
        if collectionView == collectionLightFront || collectionView == collectionLightRear {
            let cellHeight = (collectionViewHeight / 3) - 1
            return CGSize(width: (collectionViewWidth / 4) - 1, height: CGFloat(cellHeight))
            
        }else {
            return CGSize(width: (collectionViewWidth / 2) - 10, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionLightFront{
            return LightsInspectionModel.sharedInstance.collectionItemsFront.count
        }else if collectionView == collectionLightRear {
            return LightsInspectionModel.sharedInstance.collectionItemsRear.count
        }else{
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collectionLightFront{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellLightsInspection", for: indexPath) as! LightsInspectionCells
            cell.lblService.text = LightsInspectionModel.sharedInstance.collectionItemsFront[indexPath.item]
            
            if self.internal_inspection_id != -1 {
                try! dbQueue.inDatabase { db in
                    if let rowsCustomer = try Row.fetchOne(db, "SELECT * FROM services WHERE internal_inspection_id = ? and service_id = ?", arguments: [self.internal_inspection_id, LightsInspectionModel.sharedInstance.itemsFrontIds[(indexPath as NSIndexPath).item]]) {
                        let lightSelected: Bool = rowsCustomer["light_selected"]
                        
                        if lightSelected{
                            cell.backgroundColor = Constants.CherryDriveSecondaryColor
                            cell.lblService.textColor = UIColor.white
                            cell.imgRainOff.isHidden = false
                            cell.cellSelected = true
                        }else{
                            cell.backgroundColor = Constants.CollectionViewCell
                            cell.lblService.textColor = UIColor.black
                            cell.imgRainOff.isHidden = true
                            cell.cellSelected = false
                        }
                    }
                }
            }else{
                let statusCell = LightsInspectionModel.sharedInstance.itemsFront[(indexPath as NSIndexPath).item]
                
                if statusCell{
                    cell.backgroundColor = Constants.CherryDriveSecondaryColor
                    cell.lblService.textColor = UIColor.white
                    cell.imgRainOff.isHidden = false
                    cell.cellSelected = true
                }else{
                    cell.backgroundColor = Constants.CollectionViewCell
                    cell.lblService.textColor = UIColor.black
                    cell.imgRainOff.isHidden = true
                    cell.cellSelected = false
                }
            }
            return cell
        }else if collectionView == collectionLightRear {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellLightsInspection", for: indexPath) as! LightsInspectionCells
            cell.lblService.text = LightsInspectionModel.sharedInstance.collectionItemsRear[indexPath.item]
            
            if self.internal_inspection_id != -1 {
                try! dbQueue.inDatabase { db in
                    if let rowsCustomer = try Row.fetchOne(db, "SELECT * FROM services WHERE internal_inspection_id = ? and service_id = ?", arguments: [self.internal_inspection_id, LightsInspectionModel.sharedInstance.itemsRearIds[(indexPath as NSIndexPath).item]]) {
                        let lightSelected: Bool = rowsCustomer["light_selected"]
                        
                        if lightSelected{
                            cell.backgroundColor = Constants.CherryDriveSecondaryColor
                            cell.lblService.textColor = UIColor.white
                            cell.imgRainOff.isHidden = false
                            cell.cellSelected = true
                        }else{
                            cell.backgroundColor = Constants.CollectionViewCell
                            cell.lblService.textColor = UIColor.black
                            cell.imgRainOff.isHidden = true
                            cell.cellSelected = false
                        }
                    }
                }
            }else{
                let statusCell = LightsInspectionModel.sharedInstance.itemsRear[(indexPath as NSIndexPath).item]
                
                if statusCell{
                    cell.backgroundColor = Constants.CherryDriveSecondaryColor
                    cell.lblService.textColor = UIColor.white
                    cell.imgRainOff.isHidden = false
                    cell.cellSelected = true
                }else{
                    cell.backgroundColor = Constants.CollectionViewCell
                    cell.lblService.textColor = UIColor.black
                    cell.imgRainOff.isHidden = true
                    cell.cellSelected = false
                }
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellComment", for: indexPath) as! CommentCollectionCell
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = Constants.CherryDriveBorderColor.cgColor
            switch indexPath.row {
            case 0:
                cell.lblComment.text = self.service[self.cellIndex!].default_comment
                break
            case 1:
                cell.lblComment.text = self.service[self.cellIndex!].default_comment_2
                break
            case 2:
                cell.lblComment.text = "Damage Prior to Service"
                break
            case 3:
                cell.lblComment.text = "Additional Parts Required for Repair/ Replacement"
                break
            case 4:
                cell.lblComment.text = "Missing Prior to Service"
                break
            case 5:
                cell.lblComment.text = "Safety Concern"
            case 6:
                cell.lblComment.text = "Advanced Inspection Recommended"
                break
            case 7:
                cell.lblComment.text = "Declined By Customer"
            case 8:
                cell.lblComment.text = "See Pictures for Details"
            case 9:
                cell.lblComment.text = "Customer's Own Part/Fluid"
            default:
                cell.lblComment.text = ""
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        if collectionView == collectionLightFront || collectionView == collectionLightRear{
            let cell = collectionView.cellForItem(at: indexPath) as! LightsInspectionCells
            
            if cell.cellSelected {
                cell.backgroundColor = Constants.CollectionViewCell
                cell.lblService.textColor = UIColor.black
                cell.imgRainOff.isHidden = true
                cell.cellSelected = false
                if collectionView == collectionLightFront{
                    try! dbQueue.inDatabase { db in
                        try db.execute(
                            "UPDATE services SET light_selected = 0 WHERE internal_inspection_id = ? and service_id = ?", arguments: [self.internal_inspection_id, LightsInspectionModel.sharedInstance.itemsFrontIds[(indexPath as NSIndexPath).item]])
                    }
                    
                    self.frontItemsStatus[(indexPath as NSIndexPath).item] = false
                    self.lightServicesToSaveFront = self.lightServicesToSaveFront.filter{$0 != LightsInspectionModel.sharedInstance.itemsFrontIds[(indexPath as NSIndexPath).item]}
                }else{
                    try! dbQueue.inDatabase { db in
                        try db.execute(
                            "UPDATE services SET light_selected = 0 WHERE internal_inspection_id = ? and service_id = ?", arguments: [self.internal_inspection_id, LightsInspectionModel.sharedInstance.itemsRearIds[(indexPath as NSIndexPath).item]])
                    }
                    
                    self.rearItemsStatus[(indexPath as NSIndexPath).item] = false
                    self.lightServicesToSaveBack = self.lightServicesToSaveBack.filter{$0 != LightsInspectionModel.sharedInstance.itemsRearIds[(indexPath as NSIndexPath).item]}
                }
            }else{
                cell.backgroundColor = Constants.CherryDriveSecondaryColor
                cell.lblService.textColor = UIColor.white
                cell.imgRainOff.isHidden = false
                cell.cellSelected = true
                if collectionView == collectionLightFront{
                    try! dbQueue.inDatabase { db in
                        try db.execute(
                            "UPDATE services SET light_selected = 1 WHERE internal_inspection_id = ? and service_id = ?", arguments: [self.internal_inspection_id, LightsInspectionModel.sharedInstance.itemsFrontIds[(indexPath as NSIndexPath).item]])
                    }
                    
                    self.frontItemsStatus[(indexPath as NSIndexPath).item] = true
                    self.lightServicesToSaveFront.append(LightsInspectionModel.sharedInstance.itemsFrontIds[(indexPath as NSIndexPath).item])
                }else{
                    try! dbQueue.inDatabase { db in
                        try db.execute(
                            "UPDATE services SET light_selected = 1 WHERE internal_inspection_id = ? and service_id = ?", arguments: [self.internal_inspection_id, LightsInspectionModel.sharedInstance.itemsRearIds[(indexPath as NSIndexPath).item]])
                    }
                    
                    self.rearItemsStatus[(indexPath as NSIndexPath).item] = true
                    self.lightServicesToSaveBack.append(LightsInspectionModel.sharedInstance.itemsRearIds[(indexPath as NSIndexPath).item])
                }
            }
        }else{
            let cell = collectionView.cellForItem(at: indexPath) as! CommentCollectionCell
            
            cell.backgroundColor = Constants.CherryDriveSecondaryColor
            cell.lblComment.textColor = UIColor.white
            self.btnCommentDone.isEnabled = true
            self.btnCommentDone.backgroundColor = Constants.CherryDriveSecondaryColor
            self.myComment = cell.lblComment.text
            self.tbComments.resignFirstResponder()
            self.tbComments.text = ""
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: IndexPath) {
        if collectionView == collectionComments{
            let cell = collectionView.cellForItem(at: indexPath) as! CommentCollectionCell
            
            cell.backgroundColor = UIColor.white
            cell.lblComment.textColor = Constants.CherryDriveTextColor
        }
    }
    // MARK: - LIGHT INSPECTION ACTIONS
    func openLightInspection(_ cell: UITableViewCell){
        self.selectedCell = cell
        let cell = self.selectedCell as! NewInspectionCell
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden=true
        self.pellicleView.frame = self.view.frame
        self.pellicleView.center = CGPoint(x: self.view.frame.size.width  / 2, y: self.view.frame.size.height / 2)
        self.view.addSubview(self.pellicleView)
        self.lightView.frame.size.height = 245
        self.lightView.frame.size.width = self.view.frame.size.width - 20
        self.lightView.center = CGPoint(x: self.view.frame.size.width  / 2, y: self.view.frame.size.height / 2)
        
        if (cell.serviceName.text!.caseInsensitiveCompare("Front Lights") == ComparisonResult.orderedSame){
            self.collectionLightFront.isHidden = false
            self.collectionLightRear.isHidden = true
            self.lblLightL.text = "Driver Front"
            self.lblLightR.text = "Pass Front"
            //    self.collectionLightFront.reloadData()
        }else if (cell.serviceName.text!.caseInsensitiveCompare("Back Lights") == ComparisonResult.orderedSame){
            self.collectionLightFront.isHidden = true
            self.collectionLightRear.isHidden = false
            self.lblLightL.text = "Driver Rear"
            self.lblLightR.text = "Pass Rear"
            //    self.collectionLightRear.reloadData()
        }
        self.view.addSubview(lightView)
    }
    
    @IBAction func saveLightInspection(){
        let cell = self.selectedCell as! NewInspectionCell
        
        if (cell.serviceName.text!.caseInsensitiveCompare("Front Lights") == ComparisonResult.orderedSame){
            self.updateLightServicesToSave(cell.cellIndex, arrayToSave: self.lightServicesToSaveFront)
            
        }else if (cell.serviceName.text!.caseInsensitiveCompare("Back Lights") == ComparisonResult.orderedSame){
            self.updateLightServicesToSave(cell.cellIndex, arrayToSave: self.lightServicesToSaveBack)
        }
        
        self.navigationController?.isNavigationBarHidden = false
        UIApplication.shared.isStatusBarHidden=false
        self.pellicleView.removeFromSuperview()
        self.lightView.removeFromSuperview()
    }
    
    func updateLightServicesToSave(_ index:Int, arrayToSave: [Int]){
        if arrayToSave.count > 0 {
            for i in 0...arrayToSave.count - 1 {
                var data = NewInspectionModel.sharedInstance.toSave
                data = data.filter { $0!["service_id"] as! Int  != arrayToSave[i]}
                NewInspectionModel.sharedInstance.toSave = data
                print("AWSS3-> \(NewInspectionModel.sharedInstance.imageToSave[index])")
                NewInspectionModel.sharedInstance.toSave.append([
                    "service_id": arrayToSave[i] as AnyObject,
                    "qty": NewInspectionModel.sharedInstance.servicesQty[index] as AnyObject,
                    "status": 1 as AnyObject,
                    "item_type": NewInspectionModel.sharedInstance.servicesType[index] as AnyObject,
                    "comment": NewInspectionModel.sharedInstance.comment[index] as AnyObject,
                    "image": NewInspectionModel.sharedInstance.imageToSave[index] as AnyObject,
                    "is_light": true as AnyObject,
                    "light_selected": true as AnyObject
                    ])
                
                
            }
        }
    }
    
    func resetLights(_ index:Int, arrayToSave: String){
        if (arrayToSave.caseInsensitiveCompare("Front Lights") == ComparisonResult.orderedSame){
            self.frontItemsStatus[index] = false
            self.lightServicesToSaveFront = self.lightServicesToSaveFront.filter{$0 != LightsInspectionModel.sharedInstance.itemsFrontIds[index]}
            
            self.updateLightServicesToSave(index, arrayToSave: self.lightServicesToSaveFront)
        }else if (arrayToSave.caseInsensitiveCompare("Back Lights") == ComparisonResult.orderedSame){
            self.rearItemsStatus[index] = false
            self.lightServicesToSaveBack = self.lightServicesToSaveBack.filter{$0 != LightsInspectionModel.sharedInstance.itemsRearIds[index]}
            
            self.updateLightServicesToSave(index, arrayToSave: self.lightServicesToSaveBack)
        }
    }
    
    // MARK: - COMMENT ACTIONS
    @IBAction func textFieldEditing(_ sender: UITextField) {
        let selectedIndexPaths = self.collectionComments!.indexPathsForSelectedItems
        let selectedIndexPath = selectedIndexPaths?.first
        if (selectedIndexPath != nil) {
            let indexPath : IndexPath = selectedIndexPaths![0] as IndexPath
            let cell = collectionComments.cellForItem(at: indexPath) as! CommentCollectionCell
            cell.backgroundColor = UIColor.white
            cell.lblComment.textColor = Constants.CherryDriveTextColor
            self.collectionComments.deselectItem(at: indexPath, animated: true)
        }
        if sender.text!.isEmpty {
            self.btnCommentDone.isEnabled = false
            self.btnCommentDone.backgroundColor = UIColor.gray
        }
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        if textField.text!.isEmpty {
            self.btnCommentDone.isEnabled = false
            self.btnCommentDone.backgroundColor = UIColor.gray
        }else{
            self.myComment = textField.text
            self.btnCommentDone.isEnabled = true
            self.btnCommentDone.backgroundColor = Constants.CherryDriveSecondaryColor
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func openComment(_ i: Int, reference: NewInspectionCell){
        self.selectedCell = reference
        
        if NewInspectionModel.sharedInstance.servicesType[i] == "" {
            self.showToast(message: "Please select NA, REC, OK or ATT on your items")
            return
        }
        
        self.cellIndex = i
        if NewInspectionModel.sharedInstance.comment[i].isEmpty {
            self.myComment = ""
            self.tbComments.text = ""
            self.btnCommentDone.isEnabled = false
            self.btnCommentDone.backgroundColor = UIColor.gray
        }else{
            self.tbComments.text = NewInspectionModel.sharedInstance.comment[i]
        }
        
        let selectedIndexPaths = self.collectionComments!.indexPathsForSelectedItems
        let selectedIndexPath = selectedIndexPaths?.first
        if (selectedIndexPath != nil) {
            let indexPath : IndexPath = selectedIndexPaths![0] as IndexPath
            let cell = collectionComments.cellForItem(at: indexPath) as! CommentCollectionCell
            cell.backgroundColor = UIColor.white
            cell.lblComment.textColor = Constants.CherryDriveTextColor
            self.collectionComments.deselectItem(at: indexPath, animated: true)
        }
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden=true
        
        self.pellicleView.frame = self.view.frame
        self.pellicleView.center = CGPoint(x: self.view.frame.size.width  / 2, y: self.view.frame.size.height / 2)
        self.view.addSubview(self.pellicleView)
        self.commentView.frame.size.height = self.view.frame.size.height - 20
        self.commentView.frame.size.width = self.view.frame.size.width - 20
        self.commentView.center = CGPoint(x: self.view.frame.size.width  / 2, y: self.view.frame.size.height / 2)
        
        self.collectionComments.reloadData()
        self.view.addSubview(commentView)
    }
    
    @IBAction func performSaveComment() {
        let cell = self.selectedCell as! NewInspectionCell
        self.navigationController?.isNavigationBarHidden = false
        UIApplication.shared.isStatusBarHidden=false
        NewInspectionModel.sharedInstance.comment[self.cellIndex!] = self.myComment!
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.pellicleView.removeFromSuperview()
        self.commentView.removeFromSuperview()
        if (cell.serviceName.text!.caseInsensitiveCompare("Front Lights") == ComparisonResult.orderedSame){
            self.updateLightServicesToSave(cell.cellIndex, arrayToSave: self.lightServicesToSaveFront)
            
        }else if (cell.serviceName.text!.caseInsensitiveCompare("Back Lights") == ComparisonResult.orderedSame){
            self.updateLightServicesToSave(cell.cellIndex, arrayToSave: self.lightServicesToSaveBack)
        }
        cell.addCommentToSave(index: self.cellIndex!)
        self.tableView.reloadData()
    }
    
    @IBAction func closeComment(){
        
        if NewInspectionModel.sharedInstance.comment.indices.contains(self.cellIndex!) {
            self.navigationController?.isNavigationBarHidden = false
            UIApplication.shared.isStatusBarHidden=false
            self.pellicleView.removeFromSuperview()
            self.commentView.removeFromSuperview()
        }
        
        let alertController = UIAlertController(title: "Cherry Drive", message: "If a comment was defined, it will be lost, are you sure you want to continue with this action?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.navigationController?.isNavigationBarHidden = false
            UIApplication.shared.isStatusBarHidden=false
            NewInspectionModel.sharedInstance.comment[self.cellIndex!] = ""
            self.pellicleView.removeFromSuperview()
            self.commentView.removeFromSuperview()
            self.tableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func getProcedures(){
        
        let decoder = JSONDecoder()
        guard let token = LoginModel.sharedInstance.prefs.value(forKey: "auth_token") as? String else{
            print("we have an issue with token to be fixed")
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-Type": "application/json"
        ]
        
        guard let inspection_id = self.inspection_id else{
            print("Procedure_id is empty yet")
            return
        }
        weak var weakSelf = self
        Alamofire.request("\(CherryApi.rootURL)api/v1/inspections/\(inspection_id)", method: .get, headers: headers).responseDecodableObject(keyPath: nil, decoder: decoder) { (response: DataResponse<BaseProcedure>) in
            self.alreadyLoaded = true
            //            print("Response1: \(response.result.value)")
            if let procedureResponse = response.result.value{
                print(procedureResponse)
                
                weakSelf?.procedures = procedureResponse
                
                //Set data
                
                if let setPlate = procedureResponse.vehicle?.license, let setState =  procedureResponse.vehicle?.license_plate_state{
                    
                    weakSelf?.setState = setState
                    weakSelf?.setPlate = setPlate
                }
                
                //self.selectedProcedureID = procedureResponse.procedure?.id
                print("Response1: \(weakSelf?.setState)")
                
                print("Response2: \(procedureResponse.vehicle?.license_plate_state)")
                print("Response3: \(procedureResponse.vehicle?.license)")
            }
            
            
        }
        
    }
    
    lazy var DelegateCustomerInfoController: CustomerInfoController = {
        let storyboard = UIStoryboard(name: "CustomerInfo", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "customerInfoView") as! CustomerInfoController
        return vc
    }()
    
    // MARK: - CUSTOMER INFO
    @IBAction func openCurtomerInfo() {
        
        DelegateCustomerInfoController.setState = self.setState
        DelegateCustomerInfoController.setPlate = self.setPlate
        
        present(DelegateCustomerInfoController, animated: true, completion: nil)
    }
    
    // MARK: - SAVE INSPECTION
    @objc func saveDraft() {
        let alertController = UIAlertController(title: "Save inspection", message: "Would you like to save this inspection to continue another time?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
            weak var weakSelf = self
            guard let isDraftInspection = weakSelf?.isDraftInspection else{
                print("Error with isDraftInspection")
                return
            }
            
            if isDraftInspection == false && VehiclesModel.sharedInstance.vehicles_id != nil{
                self.saveInspectionInDraft()
            }else if isDraftInspection{
                
                self.updateInspectionDraft(isDraft: true)
            }else{
                Core.shared.alert(message: "You have to set data before saving an inpection", title: "Error", at: self)
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default,handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func performSaveInspection() {
        print("performSaveInspection has been tapped")
        if NewInspectionModel.sharedInstance.toSave.count == 0 {
            return
        }
        
        
        var inspectionUrl:String?
        var inspectionMethod:String?
        print(NewInspectionModel.sharedInstance.toSave)
        
        if isDraftInspection == true && VehiclesModel.sharedInstance.vehicles_id != nil{
            print("performSaveInspection has been tapped")
            let alertController = UIAlertController(title: "Complete inspection", message: "Would you like to send this inspection", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
                let array = NewInspectionModel.sharedInstance.toSave
                
                print(array)
                self.updateInspectionDraft(isDraft: false)
                
            }))
            
            alertController.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default,handler: nil))
            guard let store_id = LoginModel.sharedInstance.selectedStoreId else{
                print("we have an issue with procedure_id to be fixed")
                return
            }
            let params = ["store_id": store_id,
                          "vehicle_id": VehiclesModel.sharedInstance.vehicles_id ,
                          "procedure_id":procedure_id,
                          "min_total": 0,
                          "max_total":0,
                          "mileage": CustomersModel.sharedInstance.mileage,
                          "draft": 1,
                          "inspections_services_attributes": NewInspectionModel.sharedInstance.toSave] as  [String : Any]
            
            print(params)
            present(alertController, animated: true, completion: nil)
        }
        
        if VehiclesModel.sharedInstance.vehicles_id != nil {
            self.incompleteInspection = NewInspectionModel.sharedInstance.toSave.flatMap { $0 }
            
            
            
            if self.inspection_id > 0 {
                inspectionMethod = "PUT"
                guard let inspection_id = self.inspection_id else{
                    print("Procedure_id is empty yet")
                    return
                }
                let inspection = "\(inspection_id)"
                inspectionUrl = CherryApi.createInspectionUrl + "/" + inspection
                
                
                try! dbQueue.inDatabase { db in
                    var rowCount = 0
                    for row in try Row.fetchAll(db, "SELECT * FROM services WHERE remote_inspection_id = ?", arguments: [self.inspection_id]) {
                        rowCount += 1
                        let remote_id: Int = row["remote_id"]
                        let service_id: Int = row["service_id"]
                        let is_light: Bool = row["is_light"] ?? false
                        let light_selected: Bool = row["light_selected"] ?? false
                        
                        var data = NewInspectionModel.sharedInstance.toSave
                        data = data.filter { $0!["service_id"] as! Int == service_id}
                        
                        try db.execute(
                            "UPDATE services SET qty = ?, item_type = ?, comment = ?, image_url = ? WHERE remote_id = ?",
                            arguments: [
                                data[0]!["qty"] as! Int,
                                data[0]!["item_type"] as! String,
                                data[0]!["comment"] as! String,
                                data[0]!["image"] as! String,
                                remote_id
                            ]
                        )
                        
                        if data.count > 0 {
                            var parameters = [String:Any]()
                            var updateInspectionsService:String
                            
                            if is_light == true && light_selected == false {
                                
                                guard let inspectionsurl = inspectionUrl, inspectionUrl?.count > 0 else{
                                    print("Error: InsptectionURL is empty")
                                    return
                                }
                                
                                updateInspectionsService = inspectionsurl
                                
                                parameters = ([
                                    "inspections_services_attributes": [
                                        [
                                            "id": remote_id,
                                            "service_id": data[0]!["service_id"]!,
                                            "_destroy": 1
                                        ]
                                    ]
                                    ] as? [String : Any])!
                            }else{
                                guard let inspectionsurl = inspectionUrl, inspectionUrl?.count > 0 else{
                                    print("Error: InsptectionURL is empty")
                                    return
                                }
                                
                                updateInspectionsService = inspectionsurl + ("/inspections_services/" + String(remote_id))
                                parameters = [
                                    "service_id": data[0]!["service_id"] as! Int,
                                    "qty": data[0]!["qty"] as! Int,
                                    "status": 1,
                                    "item_type": data[0]!["item_type"] as! String,
                                    "comment": data[0]!["comment"] as! String,
                                    "image": data[0]!["image"] as! String
                                    ] as [String : Any]
                            }
                            
                            let request = CherryApi.sharedInstance.makeRequest(url: updateInspectionsService, parameters: parameters as [String : AnyObject], httpMethod: inspectionMethod!)
                            
                            Alamofire.request(request).checkConnectivity().showHUD().responseJSON { response in
                                switch response.result {
                                case .success:
                                    let json = JSON(response.result.value!)
                                    
                                    
                                    rowCount -= 1
                                    var data2 = NewInspectionModel.sharedInstance.toSave
                                    data2 = data2.filter { $0!["service_id"] as! Int != service_id}
                                    NewInspectionModel.sharedInstance.toSave = data2
                                    if rowCount == 0 {
                                        ProgressHudManager.sharedInstance.hide()
                                        self.createConnection(inspectionMethod: inspectionMethod!, inspectionUrl: inspectionUrl!)
                                    }
                                    
                                    
                                case .failure(let error):
                                    print("CreateGeneralInspection Error: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
            }else{
                inspectionMethod = "POST"
                
                
                inspectionUrl = CherryApi.createInspectionUrl
                
                // --MARK: TODO
                if let inspection = inspectionUrl{
                    createConnection(inspectionMethod: inspectionMethod!, inspectionUrl: inspection)
                }
            }
            
            
        }else{
            MessageManager.shared.showSimpleAlert(sender: self, title: "TITLE", msg: NSLocalizedString("FILL_LICENSE_PLATE", comment: ""))
            
        }
    }
    
    func finishConnection(request: URLRequest, msg: String){
        Alamofire.request(request).checkConnectivity().showHUD().responseJSON { response in
            ProgressHudManager.sharedInstance.hide()
            switch response.result {
            case .success:
                let json = JSON(response.result.value!)
                if self.inspection_id == -1 {
                    // self.saveInspectionCache(0, inspectionId: Int64(json["id"].intValue), json: json)
                }else{
                    
                    print("MYID: \(Int64(json["id"].intValue))")
                    
                }
                print(json)
                self.isNewInspection = false
                MessageManager.shared.showBackAlert(sender: self, title:"TITLE_SUCCESSFULLY", msg: "VISIT_URL")
                
            case .failure(let error):
                
                let errorMessage:String = error.localizedDescription
                var errorCode = ""
                if let err = response.response?.statusCode {
                    errorCode = "\(err)"
                }
                
                MessageManager.shared.showSimpleAlert(sender: self, title:"Something wrong submitting", msg: errorMessage)
            }
        }
    }
    
    func createConnection(inspectionMethod: String, inspectionUrl: String){
        var parameters = [String:Any]()
        let msg = "Success"
        
        if NewInspectionModel.sharedInstance.toSave.count > 0 {
            print(NewInspectionModel.sharedInstance.toSave)
            print("params: \(NewInspectionModel.sharedInstance.toSave)")
            if let vehicles_id = VehiclesModel.sharedInstance.vehicles_id, let selectedStoreId = LoginModel.sharedInstance.selectedStoreId
                
            {
                guard let procedure_id = procedure_id else{
                    print("we have an issue with procedure_id to be fixed")
                    return
                }
                
                parameters = [
                    "store_id": selectedStoreId,
                    "vehicle_id": vehicles_id,
                    "mileage": CustomersModel.sharedInstance.mileage,
                    "procedure_id": procedure_id,
                    "inspections_services_attributes": NewInspectionModel.sharedInstance.toSave,
                    "image": "https://owner.ford.com/content/dam/assets/ford/personalization/1656/1656-target-vehicle.png"
                    ] as [String : Any]
                
                let headers: HTTPHeaders = [
                    "Authorization": (LoginModel.sharedInstance.prefs.value(forKey: "auth_token") as? String)!,
                    "Content-Type": "application/json"
                ]
                
                
            }
            
            //B329ZP UT
            
            if NewInspectionModel.sharedInstance.toSave[0]!["item_type"] as! String == "" {
                MessageManager.shared.showSimpleAlert(sender: self, title: "Something Wrong", msg: "INCOMPLETE_INSPECTION")
            }else{
                
                if let vehicles_id = VehiclesModel.sharedInstance.vehicles_id, let selectedStoreId = LoginModel.sharedInstance.selectedStoreId
                    
                    
                {
                    
                    
                    if(VehiclesModel.sharedInstance.vehicles_id != nil){
                        guard let procedure_id = procedure_id else{
                            print("we have an issue with procedure_id to be fixed")
                            return
                        }
                        
                        // --MARK: CheckIMAGEParams
                        parameters = [
                            "store_id": selectedStoreId,
                            "vehicle_id": vehicles_id,
                            "mileage": CustomersModel.sharedInstance.mileage,
                            "procedure_id": procedure_id,
                            "draft": 0,
                            "inspections_services_attributes": NewInspectionModel.sharedInstance.toSave.flatMap { $0 }
                            ] as [String : Any]
                        print("Parameters to send")
                        print(parameters)
                        
                        let request = CherryApi.sharedInstance.makeRequest(url: inspectionUrl, parameters: parameters as [String : AnyObject], httpMethod: inspectionMethod)
                        print("insert1: \(parameters)")
                        
                        let alertController = UIAlertController(title: "Save inspection", message: "Do you want to apply this inspection", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alertController.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
                            self.finishConnection(request: request, msg: msg)
                            self.popBack()
                        }))
                        
                        alertController.addAction(UIAlertAction(title: "NO", style: .default, handler: { (action: UIAlertAction!) in
                            
                        }))
                        
                        present(alertController, animated: true, completion: nil)
                        
                        
                    }else{
                        MessageManager.shared.showSimpleAlert(sender: self, title: "TITLE", msg: "FILL_LICENSE_PLATE")
                    }
                }
                
            }
        }else if NewInspectionModel.sharedInstance.toSave.count == 0 && inspectionMethod == "PUT"{
            if let vehicles_id = VehiclesModel.sharedInstance.vehicles_id, let selectedStoreId = LoginModel.sharedInstance.selectedStoreId
                
                
                
            {
                guard let procedure_id = procedure_id else{
                    print("we have an issue with procedure_id to be fixed")
                    return
                }
                let parameters = [
                    "store_id": selectedStoreId,
                    "vehicle_id": vehicles_id,
                    "mileage": CustomersModel.sharedInstance.mileage,
                    "procedure_id": procedure_id
                    ] as [String : Any]
                
                print("My params:\(parameters)")
                let request = CherryApi.sharedInstance.makeRequest(url: inspectionUrl, parameters: parameters as [String : AnyObject], httpMethod: inspectionMethod)
                
                try! dbQueue.inDatabase { db in
                    //try Row.fetchOne(db, "SELECT * FROM incompleteVehicles WHERE id = ?", arguments: [latestId[indexPath.row]])
                    try db.execute("UPDATE incompleteVehicles SET vehicles_mileage = ? WHERE vehicles_id = ?", arguments: [CustomersModel.sharedInstance.mileage, self.VehiclesID])
                }
                
                self.finishConnection(request: request, msg: msg)
            }
            
        }else{
            //MessageManager.shared.showSimpleAlert(sender: self, title: "TITLE", msg: "FILL_LICENSE_PLATE")
            if let selectedStoreId = LoginModel.sharedInstance.selectedStoreId
            {
                guard let procedure_id = procedure_id else{
                    print("we have an issue with procedure_id to be fixed")
                    return
                }
                let parameters = [
                    "store_id": selectedStoreId,
                    "vehicle_id": 0,
                    "mileage": "0",
                    "procedure_id": procedure_id
                    ] as [String : Any]
                
                let request = CherryApi.sharedInstance.makeRequest(url: inspectionUrl, parameters: parameters as [String : AnyObject], httpMethod: inspectionMethod)
                try! dbQueue.inDatabase { db in
                    //try Row.fetchOne(db, "SELECT * FROM incompleteVehicles WHERE id = ?", arguments: [latestId[indexPath.row]])
                    try db.execute("UPDATE incompleteVehicles SET vehicles_mileage = ? WHERE vehicles_id = ?", arguments: [CustomersModel.sharedInstance.mileage, self.VehiclesID])
                }
                
                self.finishConnection(request: request, msg: msg)
            }
        }
    }
    
    func loadImageFromUrl(url: String, view: UIImageView, activity: UIActivityIndicatorView!){
        // Create Url from string
        let url = URL(string: url)!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (responseData, responseUrl, error) -> Void in
            // if responseData is not null...
            if let data = responseData{
                DispatchQueue.main.async(execute: { () -> Void in
                    view.image = UIImage(data: data)
                    view.isHidden = false
                    activity.stopAnimating()
                })
            }
        })
        task.resume()
    }
    
    func servicesAttributesDefault(){
        servicesQty.append(0)
        NewInspectionModel.sharedInstance.imageToSave.append("")
        NewInspectionModel.sharedInstance.servicesType.append("")
        NewInspectionModel.sharedInstance.servicesQty.append(0)
        NewInspectionModel.sharedInstance.camCheckImage.append(false)
        NewInspectionModel.sharedInstance.comment.append("")
        NewInspectionModel.sharedInstance.servicesStatus.append(1)
    }
    
    func openCamView(_ cell:UITableViewCell, cellIndex:Int, remoteImage:String?){
        if NewInspectionModel.sharedInstance.servicesType[cellIndex] == "" {
            self.showToast(message: "Please select NA, REC, OK or ATT on your items")
            return
        }
        
        let storyboard = UIStoryboard(name: "CamView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "camView") as! CamViewController
        vc.cellIndex = cellIndex
        vc.selectedCell = cell
        vc.remoteImage = remoteImage
        present(vc, animated: true, completion: nil)
    }
    
    func addShadowToBar(_ view: UIView) {
        let shadowView = UIView(frame: view.frame)
        shadowView.backgroundColor = UIColor.white
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOpacity = 0.4 // your opacity
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2) // your offset
        shadowView.layer.shadowRadius =  4 //your radius
        self.view.addSubview(shadowView)
    }
    
    
    func updateInspectionDraft(isDraft: Bool){
        
        print("Its being called")
        
        
        let inspectionMethod =  "PUT"
        
        guard let inspection_id = inspection_id else{
            print("we have an issue with inspection_id to be fixed")
            return
        }
        
        guard let procedure_id = procedure_id else{
            print("we have an issue with procedure_id to be fixed")
            return
        }
        
        guard let store_id = LoginModel.sharedInstance.selectedStoreId else{
            print("we have an issue with procedure_id to be fixed")
            return
        }
        
        let proceduresUrl = "\(CherryApi.createInspectionUrl)/\(inspection_id)/services"
        print(proceduresUrl)
        let params = ["store_id": store_id,
                      "vehicle_id": VehiclesModel.sharedInstance.vehicles_id ,
                      "procedure_id":procedure_id,
                      "min_total": 0,
                      "max_total":0,
                      "mileage": CustomersModel.sharedInstance.mileage,
                      "draft": (isDraft) ? 1 : 0,
                      "inspections_services_attributes": NewInspectionModel.sharedInstance.toSave, "id": inspection_id] as  [String : Any]
        
        print(params)
        let request = CherryApi.sharedInstance.makeRequest(url: proceduresUrl, parameters: params as [String : AnyObject], httpMethod: inspectionMethod)
        Alamofire.request(request).checkConnectivity().showHUD().responseString { response in
            print(response)
            DispatchQueue.main.async {
                self.popBack()
            }
            
        }
        
        
        
    }
    
    
    func saveInspectionInDraft(){
        
        let inspectionMethod = "POST"
        
        let proceduresUrl = "\(CherryApi.createInspectionUrl)"
        let params = ["store_id": LoginModel.sharedInstance.selectedStoreId,
                      "vehicle_id": VehiclesModel.sharedInstance.vehicles_id,
                      "procedure_id":procedure_id!,
                      "min_total": 0,
                      "max_total":0,
                      "mileage": CustomersModel.sharedInstance.mileage,
                      "draft": 1,
                      "inspections_services_attributes": NewInspectionModel.sharedInstance.toSave] as  [String : Any]
        print(params)
        let request = CherryApi.sharedInstance.makeRequest(url: proceduresUrl, parameters: params as [String : AnyObject], httpMethod: inspectionMethod)
        Alamofire.request(request).checkConnectivity().showHUD().responseString { response in
            print(response)
            DispatchQueue.main.async {
                self.popBack()
            }
            
        }
    }
    
    
    func popBack() {
        self.navigationController?.popViewController(animated: true)
        NewInspectionModel.sharedInstance.toSave.removeAll()
        self.alreadyLoaded = false
        self.savedData = nil
        self.service.removeAll()
        tableView.reloadData()
    }
    
    
}
