//
//  SignUpController.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 6/30/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignUpController: UIViewController {
    
    @IBOutlet weak var tbxFirstName: UITextField!
    @IBOutlet weak var tbxLastName: UITextField!
    @IBOutlet weak var tbxEmail: UITextField!
    @IBOutlet weak var tbxPassword: UITextField!
    @IBOutlet weak var tbxConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = Constants.CherryDrivePrimaryColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white

        navigationController?.isNavigationBarHidden = false
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "SignUpView-iOS")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(true, moveValue: 100)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(false, moveValue: 100)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tbxFirstName {
            tbxLastName.becomeFirstResponder()
        } else if textField == tbxLastName {
            tbxEmail.becomeFirstResponder()
        } else if textField == tbxEmail {
            tbxPassword.becomeFirstResponder()
        } else if textField == tbxPassword {
            tbxConfirmPassword.becomeFirstResponder()
        } else if textField == tbxConfirmPassword {
            tbxConfirmPassword.resignFirstResponder()
            self.performSignUp()
        }
        return false
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    @IBAction func performSignUp() {
        if tbxFirstName.text! == "" || tbxLastName.text! == "" || tbxEmail.text! == "" || tbxPassword.text! == ""{
            let alertController = UIAlertController(title: "Cherry Drive", message:
                "Please, fill in all required fields.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }else if tbxPassword.text! != tbxConfirmPassword.text!{
            let alertController = UIAlertController(title: "Cherry Drive", message:
                "Password does not match the password verification field.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }else{
            let parameters = [
                "email": tbxEmail.text!,
                "password": tbxPassword.text!,
                "first_name": tbxFirstName.text!,
                "last_name": tbxLastName.text!
            ]
            
            Alamofire.request(CherryApi.signUpUrl, method: .post, parameters: parameters).checkConnectivity().showHUD().responseJSON { response in
                ProgressHudManager.sharedInstance.hide()
                switch response.result {
                case .success:
                    let json = JSON(response.result.value!)
                    print("Success UpdateCustomer: \(json)")
                    
                    if !json["message"].stringValue.isEmpty {
                        let alertController = UIAlertController(title: "Cherry Drive", message:
                            json["message"].stringValue, preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }else{
                        let alertController = UIAlertController(title: "Cherry Drive", message:
                            "Success.", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default){
                            UIAlertAction in
                            _ = self.navigationController?.popToRootViewController(animated: true)
                            }
                        )
                        
                        self.present(alertController, animated: true, completion: nil)
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                case .failure(let error):
                    let alertController = UIAlertController(title: "Cherry Drive", message:
                        "UpdateCustomers Error: \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))

                    self.present(alertController, animated: true, completion: nil)

                    print("UpdateCustomers Error: \(error.localizedDescription)")
                }
            }
        }
    }
    @IBAction func alreadyUser() {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
