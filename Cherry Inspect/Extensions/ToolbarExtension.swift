//
//  ToolbarExtension.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 7/25/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

extension UIToolbar {
    func ToolbarPiker(_ mySelect : Selector, myTitle: String) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: myTitle, style: UIBarButtonItemStyle.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
}
