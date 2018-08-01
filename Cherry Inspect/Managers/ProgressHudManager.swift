//
//  ProgressHudManager.swift
//  CherryDrive
//
//  Created by Jefferson S. Batista on 4/21/16.
//  Copyright © 2016 Ring Seven. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProgressHudManager: NSObject {
    static var sharedInstance = ProgressHudManager()
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    var onHudWasHidden: (() -> Void)?
    var continousRequests: Int = 0
    
    override init() {
        super.init()
        container.frame = (UIApplication.shared.keyWindow?.frame)!
        container.center = (UIApplication.shared.keyWindow?.center)!
        container.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 120, height: 100)
        loadingView.center = (UIApplication.shared.keyWindow?.center)!
        loadingView.backgroundColor = Constants.CherryDrivePrimaryColor
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: 40);
        
        let label = UILabel(frame: CGRect(x: 0, y: 70, width: 120, height: 21))
        label.textAlignment = NSTextAlignment.center
        label.text = "Loading..."
        label.textColor = UIColor.white
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(label)
        
        container.addSubview(loadingView)
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func hide() {
        container.removeFromSuperview()
        activityIndicator.stopAnimating()
    }
    
//    func disableForNextRequest() {
//        if let manager = CherryApiManager.API.manager as? CherryDriveRequestOperationManager {
//            manager.disableHudForNextRequest = true
//        }
//    }
}
