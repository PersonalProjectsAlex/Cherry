//
//  ProcedureTypeTableViewCell.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 7/4/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

class ProcedureTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var lblProceduraType: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    var statusCell : Bool?
    
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
}
