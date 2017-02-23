//
//  SubmitQueryViewController.swift
//  Health
//
//  Created by HW-Anil on 8/18/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit
import MobileCoreServices

class SubmitQueryViewController: UIViewController , UITextViewDelegate ,UIImagePickerControllerDelegate , UINavigationControllerDelegate ,serverTaskComplete{
   var imagePicker = UIImagePickerController()
   var button = UIButton()
   var imageView = UIImageView()
   var txtView = UITextView()
   var base64String = ""
   var activityIndicator : ProgressViewController?
// MARK: ViewLifeCycleMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        self.createALayout()
        self.addLeftBarButton()
        self.navigationController?.navigationBar.tintColor = KRED_COLOR
        self.title = "SUBMIT QUERY"
        // add progress on View
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
    }
    override func viewWillAppear(_ animated: Bool) {
         self.navigationController!.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // call google analytics for screen tracking
         appDelegate.trackViewOnGoogleAnalytics("Submit Query")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: LayoutDesign
    func createALayout()  {
        var yPos : CGFloat = 74
        
        txtView = UITextView.init(frame: CGRect(x: 10, y: yPos, width: self.view.frame.width - 20, height: 100))
        txtView.layer.cornerRadius = 4
        txtView.text = nil
        txtView.text = "ADD REMARK"
        txtView.delegate = self
        txtView.returnKeyType = UIReturnKeyType.done
        txtView.textColor = UIColor.lightGray
        txtView.font = UIFont().mediumFont
        txtView.layer.borderWidth = 1
        txtView.layer.borderColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1).cgColor
        self.view.addSubview(txtView)
        
        
        yPos += 100 + 20
        
        button = BaseUIController().AButtonFrame(CGRect(x: 10, y: yPos, width: self.view.frame.width - 20, height: self.view.frame.height - (yPos + 100)), withButtonTital: "")as! UIButton
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4
        button.addDashedBorder()

        button.addTarget(self, action: #selector(SubmitQueryViewController.btnTakePhotoOnClick(_:)), for: .touchUpInside)
        self.view.addSubview(button)
        
        imageView = BaseUIController().AImageViewFrame(CGRect(x: button.frame.width/2 - 40  , y: button.frame.width/2 - 40, width: 80, height: 80), withImageName: "add_reminder_upload_image.png")as! UIImageView
        button.addSubview(imageView)
        
        let btnSubmitQuery = BaseUIController().AButtonFrame(CGRect(x: 10, y: self.view.frame.height - 50, width: self.view.frame.width - 20, height: 40), withButtonTital: "SUBMIT QUERY")as! UIButton
        btnSubmitQuery.backgroundColor = KRED_COLOR
        btnSubmitQuery.setTitleColor(UIColor.white, for: UIControlState())
        btnSubmitQuery.titleLabel?.font = UIFont().regularMediumFont
        btnSubmitQuery.layer.cornerRadius = 3
        btnSubmitQuery.addTarget(self, action: #selector(SubmitQueryViewController.btnSubmitQuery(_:)), for: .touchUpInside)
        self.view.addSubview(btnSubmitQuery)
    }
    // MARK: buttonOnClick
    func btnTakePhotoOnClick(_ button : UIButton)  {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func btnSubmitQuery(_ button : UIButton)  {
        let trimmedString = txtView.text.trimmingCharacters(in: CharacterSet.whitespaces)
        if trimmedString == "" {
            self.present(BaseUIController().showAlertView("Please submit query Remark/Query photo or both"), animated: true, completion: nil)
        }else if(txtView.text.caseInsensitiveCompare("ADD REMARK") == ComparisonResult.orderedSame){
            self.present(BaseUIController().showAlertView("Please submit query Remark/Query photo or both"), animated: true, completion: nil)
        }else{
            self.submitQueryOnServer()
        }
    }
    //MARK: textViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "ADD REMARK"
            textView.textColor = UIColor.lightGray
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    //MARK: - ImagePickerDelegate

    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
       
       let addRecoredVC = AddRecordsViewController()
       let reSizeImage = addRecoredVC.resizeImage(image, targetSize: CGSize(width: 400, height: 400))
        let imageData = UIImagePNGRepresentation(reSizeImage)
        base64String = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        imageView.isHidden = true
        button.setImage(image, for: UIControlState())
    }
    
    // MARK: - AddMenuButton
    func addLeftBarButton()  {
        let menuBarButton = UIBarButtonItem(image: UIImage(named: "menu_icon"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(self.didTapMenuBarButton(_:)))
        self.navigationItem.leftBarButtonItem = menuBarButton
    }
    
    func didTapMenuBarButton(_ sender: AnyObject) {
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    //MARK: callWebservice
    func submitQueryOnServer()  {
        if Reachability.isConnectedToNetwork() == true {
             self.activityIndicator?.start()
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let allParameters = ["customerId":customerId, "remark":txtView.text! ,"queryImage": base64String]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "SubmitQueryResult" ,methodname: "SubmitQuery", className: self)
        }else{
             self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        
        }
        
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
           // print(allResponse)
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if allResponse is String &&  allResponse as! String == "error" {
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                } else if allResponse is String &&  allResponse as! String == "1" {
                    
                    self.present(BaseUIController().showAlertView("Your query submitted successfully!"), animated: true, completion: nil)
                    
                }else if (allResponse is String && allResponse as! String != ""){
                    
                    self.present(BaseUIController().showAlertView(allResponse as! String), animated: true, completion: nil)
                    
                }
            });
        });
    }
}

extension UIView {
    func addDashedBorder() {
        let color = UIColor(red: (228/255), green: (228/255), blue: (228/255), alpha: 1).cgColor
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
        
    }
}
