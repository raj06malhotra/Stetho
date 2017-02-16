//
//  ManualBarCodeEnterViewController.swift
//  Stetho
//
//  Created by HW-Anil on 2/2/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class ManualBarCodeEnterViewController: UIViewController, serverTaskComplete {

    @IBOutlet var txtBarCode:UITextField!
    @IBOutlet var btnSubmit:UIButton!
    @IBOutlet var btnCancel:UIButton!

    
    var activityIndicator : ProgressViewController?
    var barCode : String?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = KCORP_CHECKIN
        addToolBar(txtBarCode)
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        self.view.addSubview(activityIndicator!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        btnSubmit.layer.cornerRadius = 8.0
        btnSubmit.layer.borderWidth = 1.0
        btnSubmit.layer.borderColor = UIColor.red.cgColor
        
        btnCancel.layer.cornerRadius = 8.0
        btnCancel.layer.borderWidth = 1.0
        btnCancel.layer.borderColor = UIColor.red.cgColor
        
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;
    }
    
    
    //MARK: IBActions
    
    func barButtonBackClick(_ button : UIButton)  {
            AppDelegate.getAppDelegate().loadMainview()
    }
    
    @IBAction func cancelButtonClicked(_ sender: AnyObject){
        txtBarCode.resignFirstResponder()
        AppDelegate.getAppDelegate().loadMainview()
    }
    
    @IBAction func submitButtonClicked(_ sender: AnyObject){
        if txtBarCode.text?.characters.count < 6{
            self.present(BaseUIController().showAlertView("Please Enter right Barcode"), animated: true, completion: nil)
        }else{
            txtBarCode.resignFirstResponder()
            getCorporateDetailsbyBarcode(txtBarCode.text!)
            //service hit
        }
    }
    
    //MARK: TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == txtBarCode {
            if string.isEmpty == true{
                return true
            }
            var startString = ""
            if (textField.text != nil)
            {
                startString += textField.text!
            }
            startString += string
            let limitNumber = startString.characters.count
            return limitNumber <= 6
        }
        return true
    }
    
    //MARK: SERVICE METHODS
    
    func getCorporateDetailsbyBarcode(_ barCode:String){
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            self.barCode = barCode
            let allParameters = ["barcode" : barCode]
            print(allParameters)
            ServerConnectivity().callWebservice(allParameters , resulttagname: "get_corporatedetailfrombarcodeResult" ,methodname: "get_corporatedetailfrombarcode", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
        // print(allResponse)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if allResponse is String &&  (allResponse as! String == "error" || allResponse as! String == "0"){
                    self.present(BaseUIController().showAlertView("Something went wrong."), animated: true, completion: nil)
                }else if (allResponse is String &&  allResponse as! String == "2"){
                    self.present(BaseUIController().showAlertView("Barcode already used for this mobile number."), animated: true, completion: nil)
                }
                else{
                    
                    //self.pushOnCheckOutView(allResponse as! NSArray)
                    let isValid = self.parseCorporateCheckinDetails(allResponse as! NSArray)
                    if isValid == true{
                        let viewController =  CorporateViewController()
                        viewController.isComingfromCheckinBarCode = true
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                }
            });
        });
    }
    
    func parseCorporateCheckinDetails(_ responseArray : NSArray) -> Bool{
        // let companyInfo = CompanyDetailsInfo()
        let arrDepartment = NSMutableArray()
        for (index, _) in responseArray.enumerated() {
            if index == 0 {
                if (responseArray[index] as AnyObject).object(forKey: "company_id") as! String == "0"{
                    //Wrong Bar code entered
                    self.present(BaseUIController().showAlertView("Please Enter right Barcode"), animated: true, completion: nil)
                    return false
                }
                UserDefaults.standard.setValue((responseArray[index] as AnyObject).object(forKey: "pkg_name") as! String, forKey: "PACK_NAME")
                UserDefaults.standard.setValue((responseArray[index] as AnyObject).object(forKey: "company_id"), forKey: "company_id")
                
                GlobalInfo.sharedInfo.setValueInDefault((responseArray[index] as! NSDictionary).object(forKey: "company_name") as AnyObject, forKey: KCOPERATE_NAME)
                GlobalInfo.sharedInfo.setValueInDefault((responseArray[index] as! NSDictionary).object(forKey: "company_image") as AnyObject, forKey: KCOPERATE_URL)
                GlobalInfo.sharedInfo.setValueInDefault(barCode! as AnyObject, forKey: KCHECKIN_CODE)
            }
            let dictDepartment = NSMutableDictionary()
            dictDepartment.setValue((responseArray[index] as AnyObject).value(forKey: "department_name")as! String, forKey: "departmentName")
            dictDepartment.setValue((responseArray[index] as AnyObject).value(forKey: "cwd_id")as! String, forKey: "department_id")
            arrDepartment.add(dictDepartment)
        }
        UserDefaults.standard.setValue(arrDepartment, forKey: "department")
        return true
    }
    
}
