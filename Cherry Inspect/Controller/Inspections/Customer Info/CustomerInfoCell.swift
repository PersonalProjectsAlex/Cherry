//
//  CustomerInfoCell.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 8/22/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

protocol CustomerInfoProtocol {
    func search(_ Code: String, license:String, licensePlateState:String)
}

class CustomerInfoCell: UITableViewCell {

    @IBOutlet weak var btnState: UIButton!
    @IBOutlet weak var btnCountry: UIButton!
    @IBOutlet weak var btnVin: UIButton!
    @IBOutlet weak var tbxDefault: UITextField!
    
    var delegate: CustomerInfoProtocol?
    
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
    
    @IBAction func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            CustomersModel.sharedInstance.full_name = textField.text!
        case 2:
            //CustomersModel.sharedInstance.state = textField.text!
            break;
        case 3:
            let trimmedString = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            CustomersModel.sharedInstance.license = trimmedString
            if !CustomersModel.sharedInstance.license.isEmpty && !VehiclesModel.sharedInstance.vehicles_licensePlateState.isEmpty {
                self.delegate?.search("", license: CustomersModel.sharedInstance.license, licensePlateState: VehiclesModel.sharedInstance.vehicles_licensePlateState)
            }
        case 4:
            VehiclesModel.sharedInstance.vehicles_licensePlateState = textField.text!
            if !CustomersModel.sharedInstance.license.isEmpty && !VehiclesModel.sharedInstance.vehicles_licensePlateState.isEmpty {
                self.delegate?.search("", license: CustomersModel.sharedInstance.license, licensePlateState: VehiclesModel.sharedInstance.vehicles_licensePlateState)
            }
        case 5:
            CustomersModel.sharedInstance.license_expiration_date = textField.text!
        case 6:
            VehiclesModel.sharedInstance.vehicles_vin = textField.text!
        case 7:
            VehiclesModel.sharedInstance.vehicles_make = textField.text!
        case 8:
            VehiclesModel.sharedInstance.vehicles_model = textField.text!
        case 9:
            if !(textField.text?.isEmpty)! {
                VehiclesModel.sharedInstance.vehicles_year = Int(textField.text!)!
            }
        case 10:
            VehiclesModel.sharedInstance.vehicles_description = textField.text!
        case 11:
            CustomersModel.sharedInstance.mileage = textField.text!
        default:
            print("")
        }
    }
}
