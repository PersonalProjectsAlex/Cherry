//
//  NewInspectionCell.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 8/5/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit
import SwiftyBeaver

protocol newInspectionProtocol {
    func openCamView(_ cell:UITableViewCell, cellIndex:Int, remoteImage:String?)
    func showPickerQty(_ cell:UITableViewCell, cellQty:Int)
    func openComment(_ i: Int, reference:NewInspectionCell)
    func openLightInspection(_ cell: UITableViewCell)
    func updateLightServicesToSave(_ index:Int, arrayToSave: [Int])
    func resetLights(_ index:Int, arrayToSave: String)
}

class NewInspectionCell: UITableViewCell {
    
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var imgLoadActivity: UIActivityIndicatorView!
    
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnAtt: UIButton!
    @IBOutlet weak var btnRec: UIButton!
    @IBOutlet weak var btnNA: UIButton!
    @IBOutlet weak var btnCam: UIButton!
    @IBOutlet weak var btnQty: UIButton!
    @IBOutlet weak var btnTxt: UIButton!
    
    @IBOutlet weak var ServiceButton: UIButton!
    
    var delegate: newInspectionProtocol?
    var cellQTY:Int = 0
    var cellIndex:Int = -1
    var internal_inspection_id:Int = -1
    var hasSelection = false
    var selectedOption = ""
    var hasImage = false
    var remoteImage : String?
    var q = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutMargins = UIEdgeInsets.zero
        self.separatorInset = UIEdgeInsets.zero
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func actionButtons(_ sender: AnyObject) {
        hasSelection = true
        switch sender.tag {
        case 0:
            self.btnOk.setBackgroundImage(UIImage(named: "Btn_EmptyGreen"), for: UIControlState())
            self.btnAtt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnRec.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnNA.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            
            self.btnQty.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            if cellQTY > 0 {
                cellQTY = 0
                NewInspectionModel.sharedInstance.servicesQty[cellIndex] = 0
            }
            
            NewInspectionModel.sharedInstance.servicesType[self.cellIndex] = "ok"
            
            if (self.serviceName.text!.caseInsensitiveCompare("Front Lights") == ComparisonResult.orderedSame){
                try! dbQueue.inDatabase { db in
                    for i in 0...LightsInspectionModel.sharedInstance.itemsFrontIds.count - 1 {
                        try db.execute(
                            "UPDATE services SET light_selected = 0 WHERE internal_inspection_id = ? and service_id = ?", arguments: [self.internal_inspection_id, LightsInspectionModel.sharedInstance.itemsFrontIds[i]]
                        )
                        self.delegate?.resetLights(i, arrayToSave: "Front Lights")
                    }
                }
            }else if (self.serviceName.text!.caseInsensitiveCompare("Back Lights") == ComparisonResult.orderedSame){
                try! dbQueue.inDatabase { db in
                    for i in 0...LightsInspectionModel.sharedInstance.itemsRearIds.count - 1 {
                        try db.execute(
                            "UPDATE services SET light_selected = 0 WHERE internal_inspection_id = ? and service_id = ?", arguments: [self.internal_inspection_id, LightsInspectionModel.sharedInstance.itemsRearIds[i]])
                        self.delegate?.resetLights(i, arrayToSave: "Back Lights")
                    }
                }
            }
            
            addServiceToSave(self.cellIndex)
        case 1:
            self.btnAtt.setBackgroundImage(UIImage(named: "Btn_EmptyYellow"), for: UIControlState())
            self.btnOk.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnRec.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnNA.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            
            self.btnQty.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            if cellQTY > 0 {
                cellQTY = 0
                NewInspectionModel.sharedInstance.servicesQty[cellIndex] = 0
            }
            
            NewInspectionModel.sharedInstance.servicesType[self.cellIndex] = "att"
            addServiceToSave(self.cellIndex)
            
            if (self.serviceName.text!.caseInsensitiveCompare("Front Lights") == ComparisonResult.orderedSame)
                || (self.serviceName.text!.caseInsensitiveCompare("Back Lights") == ComparisonResult.orderedSame){
                self.delegate?.openLightInspection(self)
            }
            
        case 2:
            self.btnRec.setBackgroundImage(UIImage(named: "Btn_Empty"), for: UIControlState())
            self.btnOk.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnAtt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnNA.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            
            self.btnQty.setBackgroundImage(UIImage(named: "Btn_DarkBlue"), for: UIControlState())
            if cellQTY < 1 {
                cellQTY = 1
                NewInspectionModel.sharedInstance.servicesQty[cellIndex] = 1
            }
            
            NewInspectionModel.sharedInstance.servicesType[self.cellIndex] = "rec"
            addServiceToSave(self.cellIndex)
            
            if (self.serviceName.text!.caseInsensitiveCompare("Front Lights") == ComparisonResult.orderedSame)
                || (self.serviceName.text!.caseInsensitiveCompare("Back Lights") == ComparisonResult.orderedSame){
                self.delegate?.openLightInspection(self)
            }
        case 3:
            self.btnNA.setBackgroundImage(UIImage(named: "Btn_DarkBlue"), for: UIControlState())
            self.btnOk.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnAtt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnRec.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            
            self.btnQty.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            if cellQTY > 0 {
                cellQTY = 0
                NewInspectionModel.sharedInstance.servicesQty[cellIndex] = 0
            }
            
            NewInspectionModel.sharedInstance.servicesType[self.cellIndex] = "na"
            addServiceToSave(self.cellIndex)
            
            if (self.serviceName.text!.caseInsensitiveCompare("Front Lights") == ComparisonResult.orderedSame)
                || (self.serviceName.text!.caseInsensitiveCompare("Back Lights") == ComparisonResult.orderedSame){
                self.delegate?.openLightInspection(self)
            }
        case 4:
            self.delegate?.openComment(self.cellIndex, reference: self)
            self.btnTxt.setBackgroundImage(UIImage(named: "Btn_DarkBlue"), for: UIControlState())
        case 5:
            self.delegate?.showPickerQty(self, cellQty: cellQTY)
            self.btnQty.setBackgroundImage(UIImage(named: "Btn_DarkBlue"), for: UIControlState())
        case 6:
            if (NewInspectionModel.sharedInstance.servicesType[self.cellIndex] as? String != "") {
                self.delegate?.openCamView(self, cellIndex: self.cellIndex, remoteImage: self.remoteImage)
                self.hasImage = true
                self.btnCam.setBackgroundImage(UIImage(named: "Btn_Cam"), for: UIControlState())
            } else {
                self.hasImage = true
                return
            }
            
        default:
            print(sender.tag)
        }
    }
    
    func addServiceToSave(_ index:Int){
        //-MARK: Getting inspectedservices and show what is doing
        if NewInspectionModel.sharedInstance.id[self.cellIndex] != 0{
            NewInspectionModel.sharedInstance.toSave[self.cellIndex] = [
                "id": NewInspectionModel.sharedInstance.id[index]  as AnyObject,
                "service_id": NewInspectionModel.sharedInstance.servicesId[index] as AnyObject,
                "qty": NewInspectionModel.sharedInstance.servicesQty[index] as AnyObject,
                "status": NewInspectionModel.sharedInstance.servicesStatus[index] as AnyObject,
                "item_type": NewInspectionModel.sharedInstance.servicesType[index] as AnyObject,
                "comment": NewInspectionModel.sharedInstance.comment[index] as AnyObject,
                "image": NewInspectionModel.sharedInstance.imageToSave[index] as AnyObject,
                "is_light": false as AnyObject,
                "light_selected": false as AnyObject
                ]
        } else {
            NewInspectionModel.sharedInstance.toSave[self.cellIndex] = [
                "service_id": NewInspectionModel.sharedInstance.servicesId[index] as AnyObject,
                "qty": NewInspectionModel.sharedInstance.servicesQty[index] as AnyObject,
                "status": NewInspectionModel.sharedInstance.servicesStatus[index] as AnyObject,
                "item_type": NewInspectionModel.sharedInstance.servicesType[index] as AnyObject,
                "comment": NewInspectionModel.sharedInstance.comment[index] as AnyObject,
                "image": NewInspectionModel.sharedInstance.imageToSave[index] as AnyObject,
                "is_light": false as AnyObject,
                "light_selected": false as AnyObject
                ]
        }
    }
    
    func addCommentToSave(index: Int){
        NewInspectionModel.sharedInstance.toSave[index]!["comment"] = NewInspectionModel.sharedInstance.comment[index] as AnyObject
    }
    
    
    func configureCell(service: NewInspectionModel.service, aditionalData: BaseProcedure?) {
        if !NewInspectionModel.sharedInstance.toSave.indices.contains(self.cellIndex) {
            return
        }
        self.btnOk.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        self.btnAtt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        self.btnRec.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        self.btnNA.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        self.serviceName.text = service.name?.uppercased()
        self.selectionStyle = UITableViewCellSelectionStyle.none
        if let url = service.icon{
            self.serviceImage.sd_setImage(with: URL(string: url)) { (_, _, _, _) in
                self.serviceImage.isHidden = false
                self.imgLoadActivity.stopAnimating()
            }
        }
        
        if NewInspectionModel.sharedInstance.toSave[self.cellIndex] != nil {
            self.hasSelection = true
        } else {
            self.hasSelection = false
        }
        NewInspectionModel.sharedInstance.id.append(0)
        if self.hasSelection {
            self.selectedOption = NewInspectionModel.sharedInstance.toSave[cellIndex]!["item_type"] as! String
            if (NewInspectionModel.sharedInstance.camCheckImage[cellIndex]) {
                self.hasImage = true
                self.btnCam.setBackgroundImage(UIImage(named: "Btn_Cam"), for: UIControlState())
            }
            
            if (NewInspectionModel.sharedInstance.servicesQty[cellIndex] > 0) {
                self.cellQTY = NewInspectionModel.sharedInstance.servicesQty[cellIndex]
                self.btnQty.setBackgroundImage(UIImage(named: "Btn_DarkBlue"), for: UIControlState())
            } else {
                self.btnQty.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            }
            if NewInspectionModel.sharedInstance.comment.indices.contains(self.cellIndex) {
                if NewInspectionModel.sharedInstance.comment[self.cellIndex] != "" {
                    self.btnTxt.setBackgroundImage(UIImage(named: "Btn_DarkBlue"), for: UIControlState())
                } else {
                    self.btnTxt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
                }
            } else {
                self.btnTxt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            }
            
        } else {
            
            //-MARK: Getting inspectedservices and show what is doing
            if let inspectedServices = aditionalData?.inspections_services {
                if let dataIndex = inspectedServices.index(where: {$0.service_id == service.id}) {
                    NewInspectionModel.sharedInstance.servicesId[self.cellIndex] = inspectedServices[dataIndex].service_id!
                    NewInspectionModel.sharedInstance.servicesStatus[self.cellIndex] = inspectedServices[dataIndex].status!
                    
                    
                    NewInspectionModel.sharedInstance.id.insert(inspectedServices[dataIndex].id!, at: self.cellIndex)
                    
                    self.selectedOption = inspectedServices[dataIndex].item_type!.description
                    NewInspectionModel.sharedInstance.servicesType[self.cellIndex] = inspectedServices[dataIndex].item_type!.description
                    
                    if (inspectedServices[dataIndex]).image_url != nil {
                        NewInspectionModel.sharedInstance.camCheckImage[self.cellIndex] = true
                        self.hasImage = true
                        self.remoteImage = inspectedServices[dataIndex].image_url
                        self.getDataFromUrl(url: URL(string:inspectedServices[dataIndex].image_url!)!) { (data, response, error) in
                            if error == nil {
                                let strBase64:String = data!.base64EncodedString(options: .lineLength64Characters)
                                NewInspectionModel.sharedInstance.imageToSave[self.cellIndex] = "data:image/png;base64,\(strBase64))"
                            }
                        }
                        
                    }
                    if inspectedServices[dataIndex].comment != nil {
                        if inspectedServices[dataIndex].comment != ""{
                            self.btnTxt.setBackgroundImage(UIImage(named: "Btn_DarkBlue"), for: UIControlState())
                            NewInspectionModel.sharedInstance.comment[self.cellIndex] = inspectedServices[dataIndex].comment!
                        }
                    }
                    
                    if (inspectedServices[dataIndex]).qty != nil{
                        if (inspectedServices[dataIndex]).qty! > 0 {
                            NewInspectionModel.sharedInstance.servicesQty[self.cellIndex] = inspectedServices[dataIndex].qty!
                            self.cellQTY = inspectedServices[dataIndex].qty!
                            self.btnQty.setBackgroundImage(UIImage(named: "Btn_DarkBlue"), for: UIControlState())
                        }
                    }
                    
                    if (inspectedServices[dataIndex]).comment != nil{
                        if (inspectedServices[dataIndex]).comment! != ""{
                            NewInspectionModel.sharedInstance.comment[self.cellIndex] = inspectedServices[dataIndex].comment!
                            self.btnTxt.setBackgroundImage(UIImage(named: "Btn_DarkBlue"), for: UIControlState())
                        } else {
                            self.btnTxt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
                        }
                    } else {
                        self.btnTxt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
                    }
                    
                    
                    addServiceToSave(self.cellIndex)
                }
                
            }
        }
        
        
        self.confStatus(status: self.selectedOption)
    }
    
    override func prepareForReuse() {
        self.selectedOption = ""
        self.hasImage = false
        self.btnOk.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        self.btnAtt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        self.btnRec.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        self.btnNA.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        self.btnQty.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        self.btnTxt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
    }
    
    func confStatus(status: String){
        if self.hasImage {
            self.btnCam.setBackgroundImage(UIImage(named: "Btn_Cam"), for: UIControlState())
        } else {
            self.btnCam.setBackgroundImage(UIImage(named: "Btn_CamGrey"), for: UIControlState())
        }
        NewInspectionModel.sharedInstance.servicesType.insert(status, at: self.cellIndex)
        switch status {
        case "":
            self.btnOk.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnAtt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnRec.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnNA.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        case "ok":
            self.btnOk.setBackgroundImage(UIImage(named: "Btn_EmptyGreen"), for: UIControlState())
            self.btnAtt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnRec.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnNA.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        case "att":
            self.btnOk.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnAtt.setBackgroundImage(UIImage(named: "Btn_EmptyYellow"), for: UIControlState())
            self.btnRec.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnNA.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        case "rec":
            self.btnOk.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnAtt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnRec.setBackgroundImage(UIImage(named: "Btn_Empty"), for: UIControlState())
            self.btnNA.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
        case "na":
            self.btnOk.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnAtt.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnRec.setBackgroundImage(UIImage(named: "Btn_EmptyGrey"), for: UIControlState())
            self.btnNA.setBackgroundImage(UIImage(named: "Btn_DarkBlue"), for: UIControlState())
        default:
            return
        }
    }
    
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}
