//
//  VinScanController.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 7/4/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit
import AVFoundation

protocol vinScanControllerProtocol {
    func viewOrientation()
}

class VinScanController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let session         : AVCaptureSession = AVCaptureSession()
    var previewLayer    : AVCaptureVideoPreviewLayer!
    var qrCodeFrameView:UIView?

    @IBOutlet weak var lblHelp: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var redLine: UIView!
    @IBOutlet weak var footer: UIView!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnQRCode: UIButton!
    
    var delegate: vinScanControllerProtocol?
    
    var activeQRCode:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add it to our controller's view as a subview.
        // For the sake of discussion this is the camera
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        
        // Create a nilable NSError to hand off to the next method.
        // Make sure to use the "var" keyword and not "let"
   //     let error : NSError? = nil
        var input: AVCaptureDeviceInput
        do {
            input = try  AVCaptureDeviceInput(device: device!) as AVCaptureDeviceInput
            session.addInput(input)
        } catch let myJSONError {
            print(myJSONError)
        }
        
        // If our input is not nil then add it to the session, otherwise we're kind of done!
//        if input !=  AVCaptureDeviceInput {
//            session.addInput(input)
//        }
//        else {
//            print(error!)
//        }
        
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        session.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        
        // Start the scanner. You'll have to end it yourself later.
        session.startRunning()
        
        self.view.addSubview(self.topView)
        self.view.addSubview(self.bottomView)
        self.view.addSubview(self.redLine)
        self.view.addSubview(self.footer)
        self.view.addSubview(self.lblHelp)
        
        self.view.addSubview(self.btnCancel)
  //      self.view.bringSubview(toFront: self.topView)
        self.view.bringSubview(toFront: self.bottomView)
        self.view.bringSubview(toFront: self.redLine)
        self.view.bringSubview(toFront: self.footer)
        self.view.bringSubview(toFront: self.lblHelp)
        self.view.bringSubview(toFront: self.btnCancel)
        
        qrCodeFrameView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "VinScanView-iOS")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    
    fileprivate func updatePreviewLayer(_ layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        previewLayer.frame = self.view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.previewLayer?.connection  {
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            
            if (previewLayerConnection.isVideoOrientationSupported) {
                
                switch (orientation) {
                case .portrait: updatePreviewLayer(previewLayerConnection, orientation: .portrait)
                    break
                case .landscapeRight: updatePreviewLayer(previewLayerConnection, orientation: .landscapeLeft)
                    break
                case .landscapeLeft: updatePreviewLayer(previewLayerConnection, orientation: .landscapeRight)
                    break
                case .portraitUpsideDown: updatePreviewLayer(previewLayerConnection, orientation: .portraitUpsideDown)
                    break
                default: updatePreviewLayer(previewLayerConnection, orientation: .portrait)
                    break
                }
            }
        }
    }

    // This is called when we find a known barcode type with the camera.
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let code = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            self.session.stopRunning()
            
            if (code.characters.count) > 17 {
                let s2 = code.replacingCharacters(in: (code.startIndex)..<(code.index(after: (code.startIndex))), with: "")
                self.alert(s2)
            }else{
                self.alert(code)
            }
        }
    }
    
    func alert(_ Code: String){
        let alert = UIAlertController(title: "Successfully Scanned", message: "VIN code: \(Code)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default){
            UIAlertAction in
            print("Code: \(Code)")
            self.delegate?.viewOrientation()
            
            VehiclesModel.sharedInstance.vehicles_vin = Code
            VehiclesModel.sharedInstance.vinSearched = false
            self.presentingViewController!.dismiss(animated: true, completion: nil)
            }
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.delegate?.viewOrientation()
        self.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func qrCodeChange(_ sender: AnyObject) {
//        let halfTopView = (self.topView.bounds.height / 2)
//        let halfBottomView = (self.bottomView.bounds.height / 2)
//        let animationTime = 1.0
//        
//        if activeQRCode {
//            activeQRCode = false
//            self.btnQRCode.setImage(UIImage(named: "QRCode_Icon"), for: UIControlState())
//            
//            UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseOut, animations: {
//                self.topView.transform = self.topView.transform.translatedBy(x: 0.0, y: halfTopView)
//                self.bottomView.transform = self.bottomView.transform.translatedBy(x: 0.0, y: -halfBottomView)
//            }, completion: { (finished) -> Void in
//                self.lblHelp.isHidden = false
//                self.redLine.isHidden = false
//            })
//        }else{
//            activeQRCode = true
//            self.redLine.isHidden = true
//            self.lblHelp.isHidden = true
//            self.btnQRCode.setImage(UIImage(named: "BarCode-Icon"), for: UIControlState())
//            
//            UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseOut, animations: {
//                self.topView.transform = self.topView.transform.translatedBy(x: 0.0, y: -halfTopView)
//                self.bottomView.transform = self.bottomView.transform.translatedBy(x: 0.0, y: halfBottomView)
//            })
//        }
    }
    
    @IBAction func insertVinCode(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Cherry Drive", message: "Please, insert the VIN code", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default){
            UIAlertAction in
            let textField = alert.textFields![0] as UITextField
            self.delegate?.viewOrientation()
            
            VehiclesModel.sharedInstance.vehicles_vin = textField.text!
            VehiclesModel.sharedInstance.vinSearched = false
            self.presentingViewController!.dismiss(animated: true, completion: nil);
            }
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Vin code"
        })
        self.present(alert, animated: true, completion: nil)
    }
}
