//
//  MessageManager.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 07/04/17.
//  Copyright © 2017 Slate Development. All rights reserved.
//

import UIKit

class MessageManager: NSObject {
    static let shared = MessageManager()
    
    func showSimpleAlert(sender:UIViewController, title:String, msg:String){
        let alert = UIAlertController(title: NSLocalizedString(title, comment: ""), message:
            NSLocalizedString(msg, comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        
        sender.present(alert, animated: true, completion: nil)
    }
    
    func showBackAlert(sender:UIViewController, title:String, msg:String) {
        let alert = UIAlertController(title: NSLocalizedString(title, comment: ""), message:
            NSLocalizedString(msg, comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default){
            UIAlertAction in
            _ = sender.navigationController?.popViewController(animated: true)
            }
        )
        sender.present(alert, animated: true, completion: nil)
    }
}
