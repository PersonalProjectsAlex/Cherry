//
//  HomeCell.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 8/4/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

class HomeCell: UITableViewCell {

    @IBOutlet weak var btnTitle: UILabel!
    
    @IBOutlet weak var customSeperator: UIView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var btnImage: UIImageView!
    
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
