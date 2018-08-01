// Core.swift
// Cherry Inspect
//
// Created by Administrador on 22/03/18.
//Copyright © 2018 Slate Development. All rights reserved.
//
import Foundation
import UIKit

class Core {
    static let shared = Core()
    private init() {}
    
    
    //MARK: - UI
    
    //Show Alert Message (function)
     func alert(message: String, title: String, at viewController: UIViewController){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    //Convert String into HexColor (function)-> UIColor
    func hexToUIColor (hex:String) -> UIColor {
        
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    // MARK. -Components
    
    // Register cell at a table view
    func registerCell(at tableView: UITableView, named: String, withIdentifier: String? = nil) {
        let coffeeCellNib = UINib(nibName: named, bundle: nil)
        tableView.register(coffeeCellNib, forCellReuseIdentifier: withIdentifier ?? named)
    }
    
    
    
}
