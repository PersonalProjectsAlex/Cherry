//
//  IncompleteInspectionCell.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 10/4/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit
import SwiftDate
class IncompleteInspectionCell: UITableViewCell {
    
    @IBOutlet weak var cellVehicle: UILabel!
    @IBOutlet weak var cellCustomerName: UILabel!
    @IBOutlet weak var cellPlate: UILabel!
    @IBOutlet weak var cellYear: UILabel!
    @IBOutlet weak var cellMileage: UILabel!
    @IBOutlet weak var cellState: UILabel!
    @IBOutlet weak var cellMaker: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    var inspectionId = 0
    var procedureId = 0
    var data: BaseProcedure? {
        didSet {
            configureServicesLabels()
        }
    }
    
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
    
    
    func configureServicesLabels(){
        for view in self.stackView.arrangedSubviews {
            self.stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        for service in data!.inspections_services! {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 25))
            label.text = service.service_name!
            label.font = UIFont.systemFont(ofSize: 14)
            self.stackView.addArrangedSubview(label)
            self.setNeedsLayout()
        }
        self.layoutIfNeeded()
    }
    
    
    
}

