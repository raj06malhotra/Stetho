//
//  MedicalHistoryFirstViewController.swift
//  Health
//
//  Created by HW-Anil on 7/29/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class MedicalHistoryFirstViewController: UIViewController ,serverTaskComplete {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnANegative: UIButton!
    @IBOutlet weak var btnBNegative: UIButton!
    @IBOutlet weak var btnABNegative: UIButton!
    @IBOutlet weak var btnONegative: UIButton!
    @IBOutlet weak var btnAPositive: UIButton!
    @IBOutlet weak var btnBPositive: UIButton!
    @IBOutlet weak var btnABPositive: UIButton!
    @IBOutlet weak var btnOPositive: UIButton!
    @IBOutlet weak var txtHeightInFeet: UITextField!
    @IBOutlet weak var txtHeightInInch: UITextField!
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var txtWaistSize: UITextField!
    @IBOutlet weak var btnSave_Next: UIButton!
    @IBOutlet weak var lblBasicDetails: UILabel!
    @IBOutlet weak var lblCalculateHeight: UILabel!
    @IBOutlet weak var lblCalulateBMI: UILabel!
    @IBOutlet weak var lblChooseBlooodGroup: UILabel!
    @IBOutlet weak var btnSkipAll: UIButton!
    var btnSkip = UIButton()
    
    
    let boderColor: UIColor =  UIColor (red: (252.0/255.0), green: (199.0/255.0), blue: (99.0/255.0), alpha: 1)
    var activityIndicator : ProgressViewController?
    var selectedBloodGroup = ""
    var memberId: String = ""
    var memberName: String = ""
    var arrMemberProfileInfoDetails = NSArray()
    var arrBloodGroup : Array = ["A+" ,"B+","AB+","O+","A-","B-","AB-","O-"]
    var isFromCorporate = ""
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.createAlayoutDesign()
        //add ActivityIndicator on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        if isFromCorporate == "yes" {
            
            btnSkipAll.isHidden = true
            
        }else{
            self.getMemberProfileInfo()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Back"
        self.title = "PROFILE SETUP"
        self.navigationController?.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillLayoutSubviews() {
        if self.view.frame.height == 480 {
            scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 100)
        }
    }
    func createAlayoutDesign()  {
        btnAPositive.layer.borderWidth = 1
        btnAPositive.layer.borderColor = boderColor.cgColor
        btnBPositive.layer.borderWidth = 1
        btnBPositive.layer.borderColor = boderColor.cgColor
        btnABPositive.layer.borderWidth = 1
        btnABPositive.layer.borderColor = boderColor.cgColor
        btnOPositive.layer.borderWidth = 1
        btnOPositive.layer.borderColor = boderColor.cgColor
        
        btnANegative.layer.borderWidth = 1
        btnANegative.layer.borderColor = boderColor.cgColor
        btnBNegative.layer.borderWidth = 1
        btnBNegative.layer.borderColor = boderColor.cgColor
        btnABNegative.layer.borderWidth = 1
        btnABNegative.layer.borderColor = boderColor.cgColor
        btnONegative.layer.borderWidth = 1
        btnONegative.layer.borderColor = boderColor.cgColor
        
        txtHeightInFeet.layer.borderWidth = 1
        txtHeightInFeet.layer.borderColor = boderColor.cgColor
        txtHeightInInch.layer.borderWidth = 1
        txtHeightInInch.layer.borderColor = boderColor.cgColor
        txtWeight.layer.borderWidth = 1
        txtWeight.layer.borderColor = boderColor.cgColor
        txtWaistSize.layer.borderWidth = 1
        txtWaistSize.layer.borderColor = boderColor.cgColor
        
        btnSave_Next.layer.borderWidth = 2
        btnSave_Next.layer.borderColor = KRED_COLOR.cgColor
        btnSkipAll.layer.borderWidth = 2
        btnSkipAll.layer.borderColor = KRED_COLOR.cgColor
        //add numeric keyboad & tool bar on textfield
        txtHeightInFeet.keyboardType = .numberPad
        addToolBar(txtHeightInFeet)
        txtHeightInInch.keyboardType = .numberPad
        addToolBar(txtHeightInInch)
        txtWeight.keyboardType = .numberPad
        addToolBar(txtWeight)
        txtWaistSize.keyboardType = .numberPad
        addToolBar(txtWaistSize)
        if isFromCorporate != "yes" {
            //Add skip button on Navigation bar
            btnSkip = BaseUIController().AButtonFrame(CGRect(x: 0  ,y: 7 , width: 50 , height: 30), withButtonTital: "Skip")as! UIButton
            btnSkip.backgroundColor = UIColor.white
            btnSkip.setTitleColor(KRED_COLOR, for: UIControlState())
            btnSkip.addTarget(self, action: #selector(MedicalHistoryThirdViewController.btnSkipOnClick(_:)), for: .touchUpInside)
            let rightBarButton = UIBarButtonItem(customView: btnSkip)
            self.navigationItem.rightBarButtonItem = rightBarButton
        }
        //change dynamic text on UIlable
        if memberName != "" {
            lblBasicDetails.text = String(format: "Provide %@ basic detais" , memberName)
            lblCalculateHeight.text = String(format: "To calculate %@ BMI",memberName)
            lblCalulateBMI.text = String(format: "To calculate %@ BMI",memberName)
            let blackText = String(format: "Choose  %@ " , memberName)
            lblChooseBlooodGroup.attributedText = self.changeTextWithMultipleColor(blackText, redString: "Blood Group")
        }else{
            lblChooseBlooodGroup.attributedText = self.changeTextWithMultipleColor("Choose Your ", redString: "Blood Group")
        }
        
        
    }
    //MARK: TextFieldDelgete
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        return textField.resignFirstResponder()
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        if textField == txtHeightInFeet {
            var startString = ""
            if (textField.text != nil)
            {
                startString += textField.text!
            }
            startString += string
            let limitNumber = Int(startString)
            return limitNumber <= 8
        }else if(textField == txtHeightInInch){
            var startString = ""
            if (textField.text != nil)
            {
                startString += textField.text!
            }
            startString += string
            let limitNumber = Int(startString)
            return limitNumber <= 11
        }else if(textField == txtWeight)
        {
            var startString = ""
            if (textField.text != nil)
            {
                startString += textField.text!
            }
            startString += string
            let limitNumber = Int(startString)
            return limitNumber <= 400
        }else{
            var startString = ""
            if (textField.text != nil)
            {
                startString += textField.text!
            }
            startString += string
            let limitNumber = Int(startString)
            return limitNumber <= 50
        }
        
    }
    
    
    func getMemberProfileInfo()  {
        
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let allParameters = ["memberId":self.memberId, "profilePage": "1"]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetMemberProfileResult" ,methodname: "GetMemberProfile", className: self)
        }else{
            
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
        
    }
    
    //MARK: UploadDataOnServer
    func uploadMedicalHisotyPageOneData()  {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let allParameters = ["memberId":self.memberId, "customerId":customerId ,"heightft":txtHeightInFeet.text!,"heightin":txtHeightInInch.text!,"weight":txtWeight.text!,"waist": txtWaistSize.text! ,"bloodGroup":selectedBloodGroup]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "SaveProfilePage1Result" ,methodname: "SaveProfilePage1", className: self)
        }else{
            
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                self.activityIndicator?.stop()
                // getMemberProfileInfo result
                if(methodName == "SaveProfilePage1"){
                    let resultString = allResponse as! String
                    if (resultString == "1"){
                        self.sendToNextViewController()
                    }else{
                        
                    }
                }else{
                    if  allResponse is String {
                        
                    }else{
                        self.arrMemberProfileInfoDetails = allResponse as! NSArray
                        self.populateMemberProfileInfo()
                    }
                }
            });
        });
        
    }
    
    //MARK: chageWihtMultipleTextAttributeColor
    func changeTextWithMultipleColor(_ blackString : String , redString : String) -> NSMutableAttributedString {
        
        let attrs1      = [NSFontAttributeName: UIFont().regularMediumFont, NSForegroundColorAttributeName:UIColor.black]
        let attrs2      = [NSFontAttributeName: UIFont().regularMediumFont, NSForegroundColorAttributeName: KRED_COLOR]
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: blackString , attributes:  attrs1))
        attributedText.append(NSAttributedString(string: redString, attributes: attrs2))
        return attributedText
    }
    
    //MARK: ButtonAction
    @IBAction func btnSave_NextOnClick(_ sender: AnyObject) {
        
        
        
        
        
        if (isFromCorporate == "yes") {
            
            if (txtHeightInFeet.text?.isEmpty == true || txtHeightInInch.text?.isEmpty == true) {
                
                self.present(BaseUIController().showAlertView("Please Enter Height!"), animated: true, completion: nil)
                
            }else if(txtWeight.text?.isEmpty == true){
                
                self.present(BaseUIController().showAlertView("Please Enter Weight!"), animated: true, completion: nil)
                
            }else{
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                appdelegate.corporateAllDetailsDict.setValue(txtHeightInFeet.text!, forKey: "heightinfeet")
                appdelegate.corporateAllDetailsDict.setValue(txtHeightInInch.text!, forKey: "heightininch")
                appdelegate.corporateAllDetailsDict.setValue(txtWeight.text!, forKey: "weight")
                appdelegate.corporateAllDetailsDict.setValue(selectedBloodGroup, forKey: "bloodgroup")
                appdelegate.corporateAllDetailsDict.setValue(txtWaistSize.text!, forKey: "waist")
                
                print(appdelegate.corporateAllDetailsDict)
                self.sendToNextViewController()
            }
            
        }else{
            self.uploadMedicalHisotyPageOneData()
        }
        
        
        
        
    }
    @IBAction func btnSkipAllOnClick(_ sender: UIButton) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: MyFamilyViewController.self) {
                self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                break
            }
        }
    }
    
    @IBAction func btnBloodGroupSelected(_ sender: AnyObject) {
        
        let selectedButton = self.view.viewWithTag(sender.tag) as? UIButton
        selectedButton?.backgroundColor = KRED_COLOR
        for i in 0..<9 {
            if sender.tag == 301 + i {
                
                selectedButton?.backgroundColor = KRED_COLOR
                selectedBloodGroup = (selectedButton?.titleLabel?.text)!
            }else{
                let nonSelectedButton = self.view.viewWithTag(301+i) as? UIButton
                nonSelectedButton?.backgroundColor = UIColor.clear
            }
            
        }
    }
    
    func btnSkipOnClick(_ button : UIButton)  {
        self.sendToNextViewController()
    }
    func sendToNextViewController()  {
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        let medicalHistorySecondVC = storyboard1.instantiateViewController(withIdentifier: "MedicalHistorySecondViewController")as! MedicalHistorySecondViewController
        medicalHistorySecondVC.memberId = memberId
        medicalHistorySecondVC.isFromCorporate = isFromCorporate
        medicalHistorySecondVC.memberName = memberName
        self.navigationController?.pushViewController(medicalHistorySecondVC, animated: true)
        
    }
    func populateMemberProfileInfo() {
        let height = (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "height")as! String
        var heightSepratedbyTwoPart = height.components(separatedBy: "_")
        txtHeightInFeet.text = heightSepratedbyTwoPart[0]
        txtHeightInInch.text = heightSepratedbyTwoPart [1]
        txtWeight.text = (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "weight")as? String
        txtWaistSize.text = (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "waist")as? String
        print(((arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "blood_group")as! String))
        
        if ((arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "blood_group")as! String) != "" {
            let buttonTag  = arrBloodGroup.index(of: (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "blood_group")as! String)
            let selectedButton = self.view.viewWithTag(buttonTag! + 301) as? UIButton
            selectedButton?.backgroundColor = KRED_COLOR
            
        }
        
    }
    
}

