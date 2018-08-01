//
//  CamViewController.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 7/26/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//
import UIKit
import SDWebImage
class CamViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    var cellIndex:Int?
    var selectedCell: UITableViewCell?
    var remoteImage: String?
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var imgLatestImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !NewInspectionModel.sharedInstance.imageToSave[cellIndex!].isEmpty {
            let strBase64 = NewInspectionModel.sharedInstance.imageToSave[cellIndex!]
            let index = strBase64.index(strBase64.startIndex, offsetBy: 21)
            let data: NSData = NSData(base64Encoded: strBase64.substring(from: index) , options: .ignoreUnknownCharacters)!
            let dataImage = UIImage(data: data as Data)
            imgLatestImage.image = dataImage
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(tapHandler(img:)))
            imgLatestImage.isUserInteractionEnabled = true
            imgLatestImage.addGestureRecognizer(tapGestureRecognizer)
        }else{
            if self.remoteImage != nil {
                imgLatestImage.backgroundColor = UIColor.white
                imgLatestImage.sd_setImage(with: URL(string: self.remoteImage!)!, completed: nil)
                let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(tapHandler(img:)))
                imgLatestImage.isUserInteractionEnabled = true
                imgLatestImage.addGestureRecognizer(tapGestureRecognizer)
            } else {
                imgLatestImage.isHidden = true
                lblInfo.isHidden = true
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        UIApplication.shared.isStatusBarHidden=true // for status bar hide
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "CamView-iOS")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    @objc func tapHandler(img: AnyObject) {
        let newImageView = UIImageView(image: imgLatestImage.image)
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    @IBAction func openCameraButton(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func openPhotoLibraryButton(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        let imagefixed = fixOrientation(image)
        let imageData = UIImageJPEGRepresentation(imagefixed, 0.5)
        
        let strBase64:String = imageData!.base64EncodedString(options: .lineLength64Characters)
        NewInspectionModel.sharedInstance.imageToSave[cellIndex!] = "data:image/png;base64,\(strBase64))"
        NewInspectionModel.sharedInstance.camCheckImage[cellIndex!] = true
        
        let cell = self.selectedCell as! NewInspectionCell
        cell.addServiceToSave(self.cellIndex!)
        
        self.dismiss(animated: true, completion: nil);
        self.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    func fixOrientation(_ img:UIImage) -> UIImage {
        
        if (img.imageOrientation == UIImageOrientation.up) {
            return img;
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.presentingViewController!.dismiss(animated: true, completion: nil)
    }
}
