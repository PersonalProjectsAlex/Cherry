//
//  CustomerInfoController.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 7/6/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON
import SwiftyBeaver

class CustomerInfoController: UIViewController, StateDelegate, UIPickerViewDataSource, UIPickerViewDelegate, vinScanControllerProtocol, CustomerInfoProtocol{
    
    var isPresented = false
    let heightForHeader:CGFloat = 40.0
    var isError = false
    
    @IBOutlet weak var tableView: UITableView!
    
    var vehicles_status:Int?
    
    //Set data
    var setState = String()
    var setPlate = String()
    
    
    var pickerCountry = UIPickerView()
    let countryList = ["Canada", "Mexico", "United States"]
    var sCountry:String = ""
    var sState:String = ""
    var sLicenseExpirationDate = ""
    
    let indexName:IndexPath = IndexPath(row: 0, section: 0)
    let indexCountry:IndexPath = IndexPath(row: 1, section: 0)
    let indexState:IndexPath = IndexPath(row: 2, section: 0)
    let indexLicense:IndexPath = IndexPath(row: 0, section: 1)
    let indexLicencePlateState:IndexPath = IndexPath(row: 1, section: 1)
    let indexLicenseExpirationDate:IndexPath = IndexPath(row: 2, section: 1)
    let indexVin:IndexPath = IndexPath(row: 3, section: 1)
    let indexVehiclesMake:IndexPath = IndexPath(row: 4, section: 1)
    let indexVehiclesModel:IndexPath = IndexPath(row: 5, section: 1)
    let indexVehiclesYear:IndexPath = IndexPath(row: 6, section: 1)
    let indexVehiclesDescription:IndexPath = IndexPath(row: 7, section: 1)
    let indexMileage:IndexPath = IndexPath(row: 8, section: 1)
    
    var cellName:CustomerInfoCell?
    var cellCountry:CustomerInfoCell?
    var cellState:CustomerInfoCell?
    
    var cellLicense:CustomerInfoCell?
    var cellLicencePlateState:CustomerInfoCell?
    var cellLicenseExpirationDate:CustomerInfoCell?
    var cellVin:CustomerInfoCell?
    var cellVehiclesMake:CustomerInfoCell?
    var cellVehiclesModel:CustomerInfoCell?
    var cellVehiclesYear:CustomerInfoCell?
    var cellVehiclesDescription:CustomerInfoCell?
    var cellMileage:CustomerInfoCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print(setPlate)
        print(setState)
        
        self.pickerCountry.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //        view.addGestureRecognizer(tap)
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        cellName = self.tableView.cellForRow(at: self.indexName) as? CustomerInfoCell
        cellCountry = self.tableView.cellForRow(at: self.indexCountry) as? CustomerInfoCell
        cellState = self.tableView.cellForRow(at: self.indexState) as? CustomerInfoCell
        
        cellLicense = self.tableView.cellForRow(at: self.indexLicense) as? CustomerInfoCell
        cellLicencePlateState = self.tableView.cellForRow(at: self.indexLicencePlateState) as? CustomerInfoCell
        cellLicenseExpirationDate = self.tableView.cellForRow(at: self.indexLicenseExpirationDate) as? CustomerInfoCell
        cellVin = self.tableView.cellForRow(at: indexVin) as? CustomerInfoCell
        cellVehiclesMake = self.tableView.cellForRow(at: self.indexVehiclesMake) as? CustomerInfoCell
        cellVehiclesModel = self.tableView.cellForRow(at: self.indexVehiclesModel) as? CustomerInfoCell
        cellVehiclesYear = self.tableView.cellForRow(at: self.indexVehiclesYear) as? CustomerInfoCell
        cellVehiclesDescription = self.tableView.cellForRow(at: self.indexVehiclesDescription) as? CustomerInfoCell
        cellMileage = self.tableView.cellForRow(at: self.indexMileage) as? CustomerInfoCell
        
        
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isError{
            self.cellLicenseExpirationDate!.tbxDefault.isUserInteractionEnabled = false
            self.cellVin!.tbxDefault.isUserInteractionEnabled = false
            self.cellVehiclesMake!.tbxDefault.isUserInteractionEnabled = false
            self.cellVehiclesYear!.tbxDefault.isUserInteractionEnabled = false
            self.cellMileage!.tbxDefault.isUserInteractionEnabled = false
            self.cellVehiclesModel!.tbxDefault.isUserInteractionEnabled = false
        }
        
        UIApplication.shared.isStatusBarHidden=true // for status bar hide
        
        if self.setState.isEmpty == false && self.setPlate.isEmpty == false {
            search("", license: setPlate, licensePlateState: self.setState)
            
        }else if (!VehiclesModel.sharedInstance.vehicles_vin.isEmpty){
            if !VehiclesModel.sharedInstance.vinSearched{
                self.search(VehiclesModel.sharedInstance.vehicles_vin, license: "", licensePlateState: "")
            }
        }
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "CustomerView-iOS")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    // MARK: STATE DELEGATE
    func stateValueBack(_ value: String, field: String) {
        if field == "state" {
            print(value)
            self.sState = value
            CustomersModel.sharedInstance.state = self.sState
            print(CustomersModel.sharedInstance.state)
            self.tableView.reloadRows(at: [indexState], with: UITableViewRowAnimation.top)
            self.cellLicense!.tbxDefault.becomeFirstResponder()
        }else {
            if value != "U.S. Government" {
                VehiclesModel.sharedInstance.vehicles_licensePlateState = String(value[value.startIndex..<value.characters.index(value.startIndex, offsetBy: 2)])
            }else {
                VehiclesModel.sharedInstance.vehicles_licensePlateState = value
            }
            
            self.tableView.reloadRows(at: [indexLicencePlateState], with: UITableViewRowAnimation.top)
            self.cellLicenseExpirationDate!.tbxDefault.becomeFirstResponder()
            
            
            if !CustomersModel.sharedInstance.license.isEmpty && !VehiclesModel.sharedInstance.vehicles_licensePlateState.isEmpty {
                search("", license: CustomersModel.sharedInstance.license, licensePlateState: VehiclesModel.sharedInstance.vehicles_licensePlateState)
            }
        }
    }
    
    @IBAction func stateSegue (_ sender: AnyObject) {
        switch sender.tag {
        case 0:
            if CustomersModel.sharedInstance.country != "" {
                let cell = self.tableView.cellForRow(at: self.indexState) as! CustomerInfoCell
                cell.tbxDefault.text = ""
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                self.performSegue(withIdentifier: "statesSegue", sender: "state")
            }else{
                let alertController = UIAlertController(title: "Cherry Drive", message:
                    "Please, fill the country field before.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default){
                    UIAlertAction in
                    let cellCountry = self.tableView.cellForRow(at: self.indexCountry) as! CustomerInfoCell
                    cellCountry.tbxDefault.becomeFirstResponder()
                    }
                )
                self.present(alertController, animated: true, completion: nil)
            }
        case 1:
            self.performSegue(withIdentifier: "statesSegue", sender: "license_state")
        default:
            print("")
        }
    }
    
    // MARK: UITextField Delegate
    @IBAction func textFieldEditing(_ sender: UITextField) {
        switch sender.tag {
        case 5: //license_expiration_date
            let datePickerView = MonthYearPickerView()
            datePickerView.onDateSelected = { (month: Int, year: Int) in
                let string = String(format: "%02d/%d", month, year)
                sender.text = string
                self.sLicenseExpirationDate = string
            }
            sender.inputView = datePickerView
            let toolBar = UIToolbar().ToolbarPiker(#selector(CustomerInfoController.licenseExpirationPicker), myTitle: "Next")
            sender.inputAccessoryView = toolBar
        case 1: //country
            let toolBar = UIToolbar().ToolbarPiker(#selector(stateSegue), myTitle: "Next")
            let cellCountry = self.tableView.cellForRow(at: self.indexCountry) as! CustomerInfoCell
            cellCountry.tbxDefault.inputAccessoryView = toolBar
        default:
            print("")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            cellLicense!.tbxDefault.becomeFirstResponder()
        case 2:
            cellLicense!.tbxDefault.becomeFirstResponder()
        case 3:
            stateSegue((cellLicencePlateState?.btnState)!)
        case 4:
            if !cellLicense!.tbxDefault.text!.isEmpty && !cellLicencePlateState!.tbxDefault.text!.isEmpty{
                search("", license: cellLicense!.tbxDefault.text!, licensePlateState: cellLicencePlateState!.tbxDefault.text!)
            }
            if self.isError{
                self.cellLicenseExpirationDate!.tbxDefault.isUserInteractionEnabled = false
            }
        case 5:
            let cell = self.tableView.cellForRow(at: self.indexVin) as! CustomerInfoCell
            cell.tbxDefault.becomeFirstResponder()
            
        case 6://VIN
            if cellVin!.tbxDefault.text!.isEmpty == true{
                let alertController = UIAlertController(title: "Cherry Drive", message:
                    "Please, insert the VIN code.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }else{
                let trimmedString = cellVin!.tbxDefault.text!.trimmingCharacters(in: CharacterSet.whitespaces)
                if cellLicense!.tbxDefault.text!.isEmpty || cellLicencePlateState!.tbxDefault.text!.isEmpty{
                    search(trimmedString, license: "", licensePlateState: "")
                }else{
                    search(trimmedString, license: cellLicense!.tbxDefault.text!, licensePlateState: cellLicencePlateState!.tbxDefault.text!)
                }
                self.cellVehiclesMake!.tbxDefault.becomeFirstResponder()
            }
            self.view.endEditing(true)
        case 7:
            self.cellVehiclesModel!.tbxDefault.becomeFirstResponder()
        case 8:
            self.cellVehiclesYear!.tbxDefault.becomeFirstResponder()
        case 9:
            self.cellVehiclesDescription!.tbxDefault.becomeFirstResponder()
        case 10:
            let cell = self.tableView.cellForRow(at: self.indexMileage) as! CustomerInfoCell
            cell.tbxDefault.becomeFirstResponder()
        case 11:
            let cell = self.tableView.cellForRow(at: self.indexMileage) as! CustomerInfoCell
            cell.tbxDefault.resignFirstResponder()
            performConfirmCustomer()
        default:
            print(textField)
        }
        return false
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification:Notification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.tableView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 40
        self.tableView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.tableView.contentInset = contentInset
    }
    
    // MARK: UIPickerViewDelegate
    @objc func licenseExpirationPicker() {
        let cellVin = self.tableView.cellForRow(at: indexVin) as! CustomerInfoCell
        cellVin.tbxDefault.becomeFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @objc func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    @objc func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width - 30, height: 60))
        
        let myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        var rowString = String()
        switch row {
        case 0:
            rowString = "Canada"
            myImageView.image = UIImage(named:"Flag-Canada")
        case 1:
            rowString = "Mexico"
            myImageView.image = UIImage(named:"Flag-Mexico")
        case 2:
            rowString = "United States"
            myImageView.image = UIImage(named:"Flag-United-States")
        default:
            rowString = "Error: too many rows"
            myImageView.image = nil
        }
        let myLabel = UILabel(frame: CGRect(x: 60, y: -5, width: pickerView.bounds.width - 90, height: 60 ))
        myLabel.font = UIFont(name: myLabel.font.fontName, size: 18)
        myLabel.text = rowString
        
        myView.addSubview(myLabel)
        myView.addSubview(myImageView)
        
        return myView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let indexPath:IndexPath = IndexPath(row: 1, section: 0)
        self.sCountry = self.countryList[row]
        CustomersModel.sharedInstance.country = self.sCountry
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.top)
    }
    
    // MARK: - TABLEVIEW
    @objc func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 2
    }
    
    // There is just one row in every section
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return CustomersModel.sharedInstance.personalPlaceholdArray.count
        }else{
            return VehiclesModel.sharedInstance.vehiclePlaceholdArray.count
        }
    }
    
    // Set the spacing between sections
    @objc func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.heightForHeader
    }
    
    // Make the background color show through
    @objc func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = Constants.CollectionViewCell
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: self.heightForHeader))
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 11)
        label.textAlignment = NSTextAlignment.center
        
        if section == 0 {
            label.text = "PERSONAL"
        }else{
            label.numberOfLines = 2
            label.text = "VEHICLE \n" + "License Plate & Issuing State OR vin is required"
        }
        headerView.addSubview(label)
        return headerView
    }
    
    @objc func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCustomerInfo", for: indexPath) as! CustomerInfoCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.btnState.isHidden = true
        cell.btnVin.isHidden = true
        cell.delegate = self
        if indexPath.section == 0 {
            cell.tbxDefault.placeholder = CustomersModel.sharedInstance.personalPlaceholdArray[indexPath.row]
            switch indexPath.row {
            case 0:
                cell.tbxDefault.text = CustomersModel.sharedInstance.full_name
                cell.tbxDefault.tag = 0
                cell.tbxDefault.inputView = nil
                cell.tbxDefault.inputAccessoryView = nil
            case 1:
                if !CustomersModel.sharedInstance.country.isEmpty {
                    cell.tbxDefault.text = CustomersModel.sharedInstance.country
                }else{
                    cell.tbxDefault.text = self.sCountry
                }
                cell.tbxDefault.tag = 1
                cell.tbxDefault.inputView = self.pickerCountry
            case 2:
                if !CustomersModel.sharedInstance.state.isEmpty {
                    cell.tbxDefault.text = CustomersModel.sharedInstance.state
                }else{
                    cell.tbxDefault.text = self.sState
                }
                cell.tbxDefault.tag = 2
                cell.btnState.isHidden = false
                cell.tbxDefault.inputView = nil
                cell.tbxDefault.inputAccessoryView = nil
            default:
                print("Not found")
            }
        }else{
            cell.tbxDefault.placeholder = VehiclesModel.sharedInstance.vehiclePlaceholdArray[indexPath.row]
            if VehiclesModel.sharedInstance.vehiclePlaceholdArray[indexPath.row] == "VIN" {
                cell.btnVin.isHidden = false
            }
            switch indexPath.row {
            case 0:
                cell.tbxDefault.autocapitalizationType = UITextAutocapitalizationType.allCharacters
                cell.tbxDefault.text = CustomersModel.sharedInstance.license
                cell.tbxDefault.tag = 3
                cell.tbxDefault.inputView = nil
                cell.tbxDefault.inputAccessoryView = nil
            case 1:
                cell.tbxDefault.text = VehiclesModel.sharedInstance.vehicles_licensePlateState
                cell.tbxDefault.tag = 4
                cell.btnState.tag = 1
                cell.btnState.isHidden = false
                cell.tbxDefault.inputView = nil
                cell.tbxDefault.inputAccessoryView = nil
            case 2:
                cell.tbxDefault.text = self.sLicenseExpirationDate
                cell.tbxDefault.tag = 5
            case 3:
                cell.tbxDefault.autocapitalizationType = UITextAutocapitalizationType.allCharacters
                cell.tbxDefault.text = VehiclesModel.sharedInstance.vehicles_vin
                cell.tbxDefault.tag = 6
                cell.tbxDefault.inputView = nil
                cell.tbxDefault.inputAccessoryView = nil
            case 4:
                cell.tbxDefault.text = VehiclesModel.sharedInstance.vehicles_make
                cell.tbxDefault.tag = 7
                cell.tbxDefault.inputView = nil
                cell.tbxDefault.inputAccessoryView = nil
            case 5:
                cell.tbxDefault.text = VehiclesModel.sharedInstance.vehicles_model
                cell.tbxDefault.tag = 8
                cell.tbxDefault.inputView = nil
                cell.tbxDefault.inputAccessoryView = nil
            case 6:
                if VehiclesModel.sharedInstance.vehicles_year != 0{
                    cell.tbxDefault.text = String(VehiclesModel.sharedInstance.vehicles_year)
                }
                cell.tbxDefault.keyboardType = UIKeyboardType.numberPad
                cell.tbxDefault.tag = 9
            case 7:
                cell.tbxDefault.text = VehiclesModel.sharedInstance.vehicles_description
                cell.tbxDefault.tag = 10
                cell.tbxDefault.inputView = nil
                cell.tbxDefault.inputAccessoryView = nil
                
            //-MARK: Mileage
            case 8:
                cell.tbxDefault.text =  VehiclesModel.sharedInstance.mileage
                cell.tbxDefault.keyboardType = UIKeyboardType.numberPad
                cell.tbxDefault.tag = 11
                cell.tbxDefault.inputView = nil
                cell.tbxDefault.inputAccessoryView = nil
            default:
                print("Not found")
            }
        }
        return cell
    }
    
    // MARK: NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        let stateController = (segue.destination as! StatesController)
        stateController.delegate = self
        stateController.data = []
        stateController.states = [[String]]()
        if sender as! String == "license_state" {
            stateController.data = StatesModel.sharedInstance.usStates
            stateController.data += StatesModel.sharedInstance.canadianStates
            stateController.data += StatesModel.sharedInstance.mexicoStates
            
            stateController.field = "license_state"
            stateController.states.append(StatesModel.sharedInstance.usStates)
            stateController.states.append(StatesModel.sharedInstance.canadianStates)
            stateController.states.append(StatesModel.sharedInstance.mexicoStates)
        }else{
            stateController.field = "state"
            switch self.pickerCountry.selectedRow(inComponent: 0) {
            case 0:
                stateController.data = StatesModel.sharedInstance.canadianStates
            case 1:
                stateController.data = StatesModel.sharedInstance.mexicoStates
            case 2:
                stateController.data = StatesModel.sharedInstance.usStates
            default:
                print(self.pickerCountry.selectedRow(inComponent: 0))
            }
        }
    }
    
    func viewOrientation() {
        self.isPresented = false
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        
        self.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openVinScan(){
        let storyboard = UIStoryboard(name: "VinScan", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "vinScanView") as! VinScanController
        vc.delegate = self
        self.isPresented = true
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func performConfirmCustomer() {
        if CustomersModel.sharedInstance.id != nil && VehiclesModel.sharedInstance.vehicles_id != nil {
            print("performUpdateCustomer")
            performUpdateCustomer()
        }else{
            print("performSaveCustomer")
            performSaveCustomer()
        }
        self.presentingViewController!.dismiss(animated: true, completion: nil)
        
    }
    
    func search(_ Code: String, license:String, licensePlateState:String){
        VehiclesModel.sharedInstance.resetVehiclesModel()
        //    CustomersModel.sharedInstance.resetCustomersModel()
        VehiclesModel.sharedInstance.vinSearched = true
        
        let headers: HTTPHeaders = [
            "Authorization": (LoginModel.sharedInstance.prefs.value(forKey: "auth_token") as? String)!,
            "Content-Type": "application/json"
        ]
        
        let parameters:Parameters = ["vin": Code, "license": license, "license_plate_state": licensePlateState]
        
        let request = CherryApi.sharedInstance.makeRequest(url: CherryApi.searchVehiclesCarfaxUrl, parameters: parameters as [String : AnyObject], httpMethod: "POST")
        
        Alamofire.request(request).checkConnectivity().showHUD().responseJSON { response in
            ProgressHudManager.sharedInstance.hide()
            switch response.result {
            case .success:
                let json = JSON(response.result.value!)
                
                //-MARK: getting carfax response
                if let jsonValue = response.result.value {
                    let json = JSON(jsonValue)
                    print("json")
                    let carfaxresponse  = json["carfax_response"]
                    
                    let quickvinplus = carfaxresponse["quickvinplus"]
                    let vin_info = quickvinplus["vin_info"].dictionaryObject
                    if let vin_info = vin_info {
                        if let response = vin_info["message"] as? String{
                            if response == Constants.vinNotFound{
                                Core.shared.alert(message: response, title: "Please check", at: self)
                                //No VIN was found for your request
                                self.isError = false
                            }else{
                                Core.shared.alert(message: response, title: "Something Wrong", at: self)
                                self.isError = true
                                
                            }
                        }
                        
                    }
                    
                    //-MARK: Getting custom response
                    let message = json["error"]
                    if let error = message["message"].string{
                        
                        if error == Constants.vinNotFound{
                            Core.shared.alert(message: error, title: "Please check", at: self)
                            //No VIN was found for your request
                            self.isError = false
                        }else{
                            Core.shared.alert(message: error, title: "Something Wrong", at: self)
                            self.isError = true
                            
                        }
                    }
                    
                    
                }
                
                
                if json.count > 0 {
                    VehiclesModel.sharedInstance.vehicles_make = json["makeName"].stringValue
                    VehiclesModel.sharedInstance.vehicles_model = json["modelName"].stringValue
                    VehiclesModel.sharedInstance.vehicles_year = json["year"].intValue
                    VehiclesModel.sharedInstance.vehicles_description = json["engineDescription"].stringValue
                    VehiclesModel.sharedInstance.vehicles_vin = json["vin"].stringValue
                   // VehiclesModel.sharedInstance.mileage = json["mileage"].stringValue
                    
                }
                
                print(VehiclesModel.sharedInstance.mileage)
                if self.isError == false{
                    self.searchCustomer(Code, license:license, licensePlateState:licensePlateState)
                }else{
                    print("Works")
                    
                }
            case .failure(let error):
                print("searchFunc Error: \(error.localizedDescription)")
                
                
                debugPrint(error as Any)
                self.cellLicense?.tbxDefault.text = ""
                self.cellLicencePlateState?.tbxDefault.text = ""
                self.tableView.reloadRows(at: [self.indexLicencePlateState], with: UITableViewRowAnimation.top)
                self.cellLicense?.tbxDefault.becomeFirstResponder()
                
                let alert = UIAlertController(title: "Error", message: "An error occurred in the vehicle search, please contact the tech support and inform the error code.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func searchCustomer(_ vin: String, license:String, licensePlateState:String) {
        let parameters:[String:AnyObject]
        
        if vin.isEmpty {
            parameters = ["license": license as AnyObject]
        }else{
            parameters = ["vin": vin as AnyObject, "license": license as AnyObject]
        }
        print(parameters)
        let request = CherryApi.sharedInstance.makeRequest(url: CherryApi.searchCustomersUrl, parameters: parameters , httpMethod: "POST")
        print(parameters)
        Alamofire.request(request).checkConnectivity().showHUD().responseJSON { response in
            ProgressHudManager.sharedInstance.hide()
            switch response.result {
            case .success:
                let json = JSON(response.result.value!)
                
                if json.count > 0{
                    CustomersModel.sharedInstance.id = Int64(json[json.count - 1]["id"].intValue)
                    print("CustomersID: \(CustomersModel.sharedInstance.id!)")
                    
                    if json[json.count - 1]["vehicles"].count > 0 {
                        
                        let pos = json[json.count - 1]["vehicles"].count - 1
                        SwiftyBeaver.debug(json[json.count - 1]["vehicles"][pos]["mileage"].intValue)
                        //VehiclesModel.sharedInstance.mileage = json[json.count - 1]["vehicles"][pos]["mileage"].stringValue
                        if json[json.count - 1]["vehicles"][pos]["model"].stringValue == VehiclesModel.sharedInstance.vehicles_model &&
                            json[json.count - 1]["vehicles"][pos]["year"].intValue == VehiclesModel.sharedInstance.vehicles_year
                            
                        {
                            VehiclesModel.sharedInstance.vehicles_id = Int64(json[json.count - 1]["vehicles"][pos]["id"].intValue)
                            print("VehiclesID: \(VehiclesModel.sharedInstance.vehicles_id!)")
                            if VehiclesModel.sharedInstance.vehicles_vin.isEmpty {
                                VehiclesModel.sharedInstance.vehicles_vin = json[json.count - 1]["vehicles"][pos]["vin"].stringValue
                            }
                        }
                    }
                    
                    if self.cellName!.tbxDefault.text!.isEmpty {
                        CustomersModel.sharedInstance.full_name = json[json.count - 1]["full_name"].stringValue
                    }
                    
                    
                    
                    if self.sCountry.isEmpty {
                        CustomersModel.sharedInstance.country = json[json.count - 1]["country"].stringValue
                        self.sCountry = CustomersModel.sharedInstance.country
                    }else{
                        CustomersModel.sharedInstance.country = self.sCountry
                    }
                    
                    if self.sState.isEmpty {
                        CustomersModel.sharedInstance.state = json[json.count - 1]["state"].stringValue
                        
                        self.sState = CustomersModel.sharedInstance.state
                    }else{
                        CustomersModel.sharedInstance.state = self.sState
                    }
                    
                    if self.sLicenseExpirationDate.isEmpty {
                        CustomersModel.sharedInstance.license_expiration_date = json[json.count - 1]["license_expiration_date"].stringValue
                        
                        self.sLicenseExpirationDate = CustomersModel.sharedInstance.license_expiration_date
                    }else{
                        CustomersModel.sharedInstance.license_expiration_date = self.sLicenseExpirationDate
                    }
                    
                    if license.isEmpty {
                        CustomersModel.sharedInstance.license = json[json.count - 1]["license"].stringValue
                    }else{
                        CustomersModel.sharedInstance.license = license
                    }
                    
                    if licensePlateState.isEmpty {
                        VehiclesModel.sharedInstance.vehicles_licensePlateState = json[json.count - 1]["license_plate_state"].stringValue
                    }else{
                        VehiclesModel.sharedInstance.vehicles_licensePlateState = licensePlateState
                    }
                    
                    
                    
                }else{
                    if self.isError{
                        self.cellVehiclesYear?.tbxDefault.isUserInteractionEnabled = false
                        print("gsghjdgsagdjgj")
                        
                    }
                    
                    
                    CustomersModel.sharedInstance.license = license
                    VehiclesModel.sharedInstance.vehicles_licensePlateState = licensePlateState
                }
                if self.isError == false{
                    
                    self.tableView.reloadData()
                    
                }
            case .failure(let error):
                print("SearchCustomers Error: \(error)")
                
                CustomersModel.sharedInstance.license = license
                VehiclesModel.sharedInstance.vehicles_licensePlateState = licensePlateState
                self.tableView.reloadData()
            }
        }
    }
    
    
    
    func performSaveCustomer() {
        if let mileage = self.cellMileage?.tbxDefault.text {
            CustomersModel.sharedInstance.mileage = mileage
        }
        
        if resignAllTextFields() {
            let vehicles_attributes = [
                "vin": VehiclesModel.sharedInstance.vehicles_vin,
                "make": VehiclesModel.sharedInstance.vehicles_make,
                "model": VehiclesModel.sharedInstance.vehicles_model,
                "year":  VehiclesModel.sharedInstance.vehicles_year,
                "description": VehiclesModel.sharedInstance.vehicles_description,
                "mileage": CustomersModel.sharedInstance.mileage
                ] as [String : Any]
            print(vehicles_attributes)
            
            let parameters = [
                "full_name": CustomersModel.sharedInstance.full_name,
                "state": CustomersModel.sharedInstance.state,
                "country": CustomersModel.sharedInstance.country,
                "license": CustomersModel.sharedInstance.license,
                "license_plate_state": VehiclesModel.sharedInstance.vehicles_licensePlateState,
                "license_expiration_date": CustomersModel.sharedInstance.license_expiration_date,
                "store_id": LoginModel.sharedInstance.selectedStoreId!,
                "vehicles_attributes": [vehicles_attributes]
                ] as [String : Any]
            print(parameters)
            let request = CherryApi.sharedInstance.makeRequest(url: CherryApi.createCustomerUrl, parameters: parameters as [String : AnyObject], httpMethod: "POST")
            
            Alamofire.request(request).checkConnectivity().showHUD().responseJSON { response in
                ProgressHudManager.sharedInstance.hide()
                switch response.result {
                case .success:
                    let json = JSON(response.result.value!)
                    print("Success CreateCustomer: \(response)")
                    VehiclesModel.sharedInstance.vehicles_id = Int64(json["vehicles"][0]["id"].intValue)
                case .failure(let error):
                    print("CreateCustomer Error: \(error)")
                }
            }
        }
    }
    
    func performUpdateCustomer() {
        if let mileage = self.cellMileage?.tbxDefault.text {
            CustomersModel.sharedInstance.mileage = mileage
        }
        if resignAllTextFields() {
            let vehicles_attributes = [
                "id": VehiclesModel.sharedInstance.vehicles_id!,
                "vin": VehiclesModel.sharedInstance.vehicles_vin,
                "make": VehiclesModel.sharedInstance.vehicles_make,
                "model": VehiclesModel.sharedInstance.vehicles_model,
                "year": VehiclesModel.sharedInstance.vehicles_year,
                "description": VehiclesModel.sharedInstance.vehicles_description,
                "mileage": CustomersModel.sharedInstance.mileage
                ] as [String : Any]
            
            let parameters = [
                "full_name": CustomersModel.sharedInstance.full_name,
                "state": CustomersModel.sharedInstance.state,
                "country": CustomersModel.sharedInstance.country,
                "license": CustomersModel.sharedInstance.license,
                "license_plate_state": VehiclesModel.sharedInstance.vehicles_licensePlateState,
                "license_expiration_date": CustomersModel.sharedInstance.license_expiration_date,
                "store_id": LoginModel.sharedInstance.selectedStoreId!,
                "vehicles_attributes": [vehicles_attributes]
                
                ] as [String : Any]
            print(parameters)
            let updateCustomersUrl = "\(CherryApi.createCustomerUrl)/\(CustomersModel.sharedInstance.id!)"
            let request = CherryApi.sharedInstance.makeRequest(url: updateCustomersUrl, parameters: parameters as [String : AnyObject], httpMethod: "PUT")
            
            Alamofire.request(request).checkConnectivity().showHUD().responseJSON { response in
                ProgressHudManager.sharedInstance.hide()
                switch response.result {
                case .success:
                    let json = JSON(response.result.value!)
                    print("Success UpdateCustomer: \(json["vehicles"][0]["id"])")
                    VehiclesModel.sharedInstance.vehicles_id = Int64(json["vehicles"][0]["id"].intValue)
                case .failure(let error):
                    print("UpdateCustomer Error: \(error)")
                }
            }
        }
    }
    
    func resignAllTextFields() -> Bool {
        if self.isError == false{
            self.cellName!.tbxDefault.resignFirstResponder()
            //self.cellCountry!.tbxDefault.resignFirstResponder()
            //self.cellState!.tbxDefault.resignFirstResponder()
            self.cellLicense!.tbxDefault.resignFirstResponder()
            self.cellLicencePlateState!.tbxDefault.resignFirstResponder()
            self.cellLicenseExpirationDate!.tbxDefault.resignFirstResponder()
            self.cellVin!.tbxDefault.resignFirstResponder()
            self.cellVehiclesMake!.tbxDefault.resignFirstResponder()
            self.cellVehiclesModel!.tbxDefault.resignFirstResponder()
            self.cellVehiclesYear!.tbxDefault.resignFirstResponder()
            //    self.cellVehiclesDescription!.tbxDefault.resignFirstResponder()
            self.cellMileage!.tbxDefault.resignFirstResponder()
        }
        return true
    }
    
    func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}

