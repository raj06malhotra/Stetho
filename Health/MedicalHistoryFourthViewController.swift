//
//  MedicalHistoryFourthViewController.swift
//  Health
//
//  Created by HW-Anil on 7/30/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class MedicalHistoryFourthViewController: UIViewController,serverTaskComplete {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bloodGlucoseView: UIView!
    @IBOutlet weak var bloodPressureView: UIView!
    @IBOutlet weak var btnFastingBloodSugar: UIButton!
    @IBOutlet weak var bloodPressureSegmentedControl: UISegmentedControl!
    @IBOutlet weak var btnBloodPressureCheckBox: UIButton!
    @IBOutlet weak var btnBloodGlucoseCheckBox: UIButton!
    @IBOutlet weak var btnSave_Done: UIButton!
    @IBOutlet weak var lblCurrentHealthStatus: UILabel!
    @IBOutlet weak var lblCurrentHealthStausSubTital: UILabel!
    
    @IBOutlet weak var lblBloodPressure: UILabel!
    @IBOutlet weak var lblBloodGlucose: UILabel!
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    var fastingBloodSugarIsSelected = Bool()
    var activityIndicator : ProgressViewController?
    var memberId : String = ""
    var memberName: String = ""
    var bloodPressure : String = "0"
    var bloodGlucose : String = "0"
    var arrTreatedSelectdValue  = NSMutableArray()
   var arrMemberProfileInfoDetails = NSMutableArray()
    var isFromCorporate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.createLayoutDesign()
        
        //add ActivityIndicator on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        self.view.addSubview(activityIndicator!)
        if isFromCorporate != "yes" {
            self.getMemberProfileInfo()
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Back"
        self.title = "PROFILE SETUP"
        self.navigationController?.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
    }
    override func viewWillLayoutSubviews() {
        if self.view.frame.height == 480 {
            bloodGlucoseView.frame = CGRect(x: bloodGlucoseView.frame.origin.x, y: 150, width: bloodGlucoseView.frame.width, height: bloodGlucoseView.frame.height)
            bottomView.frame = CGRect(x: bottomView.frame.origin.x, y: 238 , width: bottomView.frame.width, height: bottomView.frame.height)
            btnSave_Done.frame = CGRect(x: btnSave_Done.frame.origin.x, y: bottomView.frame.origin.y + 120 + 20, width: btnSave_Done.frame.width, height: btnSave_Done.frame.height)
            scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 30)
        }
    }
    func createLayoutDesign()  {
        
        bloodPressureSegmentedControl.tintColor = UIColor (red: (252.0/255.0), green: (199.0/255.0), blue: (99.0/255.0), alpha: 1)
        //set text color of Segment control
        let titleTextAttributes = [NSForegroundColorAttributeName: UIColor (red: (81.0/255.0), green: (81.0/255.0), blue: (81.0/255.0), alpha: 1)]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: UIControlState())
       
        btnSave_Done.layer.masksToBounds = true
        btnSave_Done.layer.borderWidth = 2
        btnSave_Done.layer.borderColor = KRED_COLOR.cgColor
        fastingBloodSugarIsSelected = false
        btnFastingBloodSugar.layer.masksToBounds = true
        btnFastingBloodSugar.layer.borderWidth = 1
        btnFastingBloodSugar.layer.borderColor =  UIColor (red: (252.0/255.0), green: (199.0/255.0), blue: (99.0/255.0), alpha: 1).cgColor
        
        if isFromCorporate != "yes" {
        //Add skip button on Navigation bar
        let btnSkip = BaseUIController().AButtonFrame(CGRect(x: 0  ,y: 7 , width: 50 , height: 30), withButtonTital: "Skip")as! UIButton
        btnSkip.backgroundColor = UIColor.white
        btnSkip.setTitleColor(KRED_COLOR, for: UIControlState())
        btnSkip.addTarget(self, action: #selector(MedicalHistorySecondViewController.btnSkipOnClick(_:)), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem(customView: btnSkip)
        self.navigationItem.rightBarButtonItem = rightBarButton
        }
        
        //change dynamic text on UIlable
        if memberName != "" {
            lblCurrentHealthStatus.text = String(format: "%@ Current health status" , memberName)
            lblCurrentHealthStausSubTital.text = String(format: "Below reading help in calculating %@ wellness score accirately and risk of chronic diseases" , memberName)
            lblCurrentHealthStausSubTital.adjustsFontSizeToFitWidth = true
            lblBloodPressure.attributedText = self.changeTextWithMultipleColor(String(format: "What is %@ " , memberName) , redString: "Blood Pressure?")
            lblBloodGlucose.attributedText = self.changeTextWithMultipleColor(String(format: "What is %@ " , memberName) , redString: "Blood Glucose?")
            
        }else{
            lblBloodPressure.attributedText = self.changeTextWithMultipleColor(String(format: "What is Your ") , redString: "Blood Pressure?")
            lblBloodGlucose.attributedText = self.changeTextWithMultipleColor(String(format: "What is Your ") , redString: "Blood Glucose?")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func selectAnyTreated(_ sender: UIButton) {
//        for i in 0..<4 {
//            if sender.tag == 100 + i {
//                let selectdCheckBoxImage = self.view.viewWithTag(1000 + i)as! UIImageView
//                selectdCheckBoxImage.image = UIImage(named: "selected_red_checkbox.png")
//            }else{
//                let nonSelectdCheckBoxImage = self.view.viewWithTag(1000 + i)as! UIImageView
//                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox.png")
//            }
//        }
        
        if sender.tag == 103 {
            if sender.isSelected == true {
                sender.isSelected = false
                let nonSelectdCheckBoxImage = self.view.viewWithTag(900 + sender.tag)as! UIImageView
                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox.png")
            }else{
                for i in 0..<3 {
                    let nonSelectdCheckBoxImage = self.view.viewWithTag(1000 + i)as! UIImageView
                    nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox.png")
                }
                arrTreatedSelectdValue.removeAllObjects()
                sender.isSelected = true
                let selectdCheckBoxImage = self.view.viewWithTag(900 + sender.tag)as! UIImageView
                selectdCheckBoxImage.image = UIImage(named: "selected_red_checkbox.png")
            }
            
            
        }else{
            if arrTreatedSelectdValue .contains(sender.tag) {
                arrTreatedSelectdValue.remove(sender.tag)
                let nonSelectdCheckBoxImage = self.view.viewWithTag(900 + sender.tag)as! UIImageView
                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox.png")
            }else{
                arrTreatedSelectdValue.add(sender.tag)
                let selectdCheckBoxImage = self.view.viewWithTag(900 + sender.tag)as! UIImageView
                selectdCheckBoxImage.image = UIImage(named: "selected_red_checkbox.png")
            }
            if arrTreatedSelectdValue.count != 0 {
                let button = self.view.viewWithTag(103)as! UIButton
                button.isSelected = false
                
                let nonSelectdCheckBoxImage = self.view.viewWithTag(1003)as! UIImageView
                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox.png")
                
            }
        }
        

        
    }
    
    @IBAction func bloodGlucoseCheckBoxSelected(_ sender: UIButton) {
        
        let isCheckBoxSelected = self.view.viewWithTag(sender.tag + 1 )as! UIImageView
        if sender.isSelected {
            isCheckBoxSelected.image = UIImage(named: "nonselected_yellow_checkbox.png")
            sender.isSelected = false
        }else{
            isCheckBoxSelected.image = UIImage(named: "selected_red_checkbox.png")
            sender.isSelected = true
            bloodGlucose = "0"

        }
            fastingBloodSugarIsSelected = false
            btnFastingBloodSugar.backgroundColor = UIColor.clear
            btnFastingBloodSugar.setTitleColor(UIColor (red: (81.0/255.0), green: (81.0/255.0), blue: (81.0/255.0), alpha: 1), for: UIControlState())
        
  
    }
    
    @IBAction func bloodPressureCheckBoxSelected(_ sender: UIButton) {
      
        
        let isCheckBoxSelected = self.view.viewWithTag(sender.tag + 1)as! UIImageView
        if sender.isSelected {
             isCheckBoxSelected.image = UIImage(named: "nonselected_yellow_checkbox.png")
            
            sender.isSelected = false
        }else{
             isCheckBoxSelected.image = UIImage(named: "selected_red_checkbox.png")
            sender.isSelected = true
            bloodPressureSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
            bloodPressure = "0"
        }
       
    }
//    @IBAction func btnFastingBloodSugarOnClick(sender: UIButton) {
//       // sender.setTitleColor(UIColor (red: (81.0/255.0), green: (81.0/255.0), blue: (81.0/255.0), alpha: 1), forState: .Normal)
//        
//        if btnFastingBloodSugar.selected  {
//            btnFastingBloodSugar.backgroundColor = UIColor .redColor()
//            btnFastingBloodSugar.selected = false
//             btnFastingBloodSugar.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//            
//        }else{
//             btnFastingBloodSugar.backgroundColor = UIColor .clearColor()
//             btnFastingBloodSugar.selected = true
////             btnFastingBloodSugar.tintColor = UIColor.clearColor()
//             btnFastingBloodSugar.setTitleColor(UIColor (red: (81.0/255.0), green: (81.0/255.0), blue: (81.0/255.0), alpha: 1), forState: .Normal)
//        }
    
 //   }
    
    @IBAction func btnFastingBloodSugarOnClick(_ sender: UIButton) {
         let isCheckBoxSelected = self.view.viewWithTag(302)as! UIImageView
        
        if fastingBloodSugarIsSelected == false {
            fastingBloodSugarIsSelected = true
            btnFastingBloodSugar.backgroundColor = KRED_COLOR
            btnFastingBloodSugar.setTitleColor(UIColor.white, for: UIControlState())
            isCheckBoxSelected.image = UIImage(named: "nonselected_yellow_checkbox.png")
            btnBloodGlucoseCheckBox.isSelected = false
            bloodGlucose = "1"
        }else{
            fastingBloodSugarIsSelected = false
            btnFastingBloodSugar.backgroundColor = UIColor.clear
            btnFastingBloodSugar.setTitleColor(UIColor (red: (81.0/255.0), green: (81.0/255.0), blue: (81.0/255.0), alpha: 1), for: UIControlState())
            isCheckBoxSelected.image = UIImage(named: "selected_red_checkbox.png")
            btnBloodGlucoseCheckBox.isSelected = true


        }
   
    }
    //MARK: UploadDataOnServer
    
    func getMemberProfileInfo()  {
        
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let allParameters = ["memberId":self.memberId, "profilePage": "4"]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetMemberProfileResult" ,methodname: "GetMemberProfile", className: self)
        }else{
            
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    
    func uploadMedicalHisotyPageFourthData()  {
        
       if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let memberId = (self.memberId)
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
        
            var hypertensionStatus = String()
            var cancerStatus = String()
            var cardioStatus = String()
        
            if arrTreatedSelectdValue.contains(100) {
            hypertensionStatus = ("1")
            }else{
            hypertensionStatus = ("0")
            }
            if arrTreatedSelectdValue.contains(101) {
            cancerStatus = ("1")
            }else{
            cancerStatus = ("0")
            }
            if arrTreatedSelectdValue.contains(102) {
            cardioStatus = ("1")
            }else{
            cardioStatus = ("0")
            }

            let bloodPressureStatus = (bloodPressure)
            let bloodGlucoseStatus = (bloodGlucose)
        
            
            let allParameters = ["memberId":memberId, "customerId":customerId ,"bloodPressureStatus":bloodPressureStatus,"bloodGlucoseStatus":bloodGlucoseStatus,"hypertensionStatus":hypertensionStatus,"cancerStatus": cancerStatus ,"cardioStatus":cardioStatus]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "SaveProfilePage4Result" ,methodname: "SaveProfilePage4", className: self)
        }else{
        
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    
    
   func saveAllMedicalHistory()  {
        
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
           
            let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
           let alcohal = (appdelegate.corporateAllDetailsDict.value(forKey: "alcohal")as! String)
           let smoke = (appdelegate.corporateAllDetailsDict.value(forKey: "smoke")as! String)
           let dob = (appdelegate.corporateAllDetailsDict.value(forKey: "dob")as! String)
           let gender = (appdelegate.corporateAllDetailsDict.value(forKey: "gender")as! String)
           //let cid =  (appdelegate.corporateAllDetailsDict.valueForKey("cid")as! String)
           let bloodPressureStatus = (appdelegate.corporateAllDetailsDict.value(forKey: "bloodPressure")as! String)
           let bloodGlucose = (appdelegate.corporateAllDetailsDict.value(forKey: "bloodGlucose")as! String)
           
            let hypertension : NSMutableString = NSMutableString()
            hypertension.append(appdelegate.corporateAllDetailsDict.value(forKey: "hypertensionStatus")as! String)
            hypertension.append(",")
            hypertension.append(appdelegate.corporateAllDetailsDict.value(forKey: "fatherHypertensionStatus")as! String)
            hypertension.append(",")
            hypertension.append(appdelegate.corporateAllDetailsDict.value(forKey: "motherHypertensionStatus")as! String)
            let hypertension_status = (hypertension as String)
            
            let cancer = NSMutableString()
            cancer.append(appdelegate.corporateAllDetailsDict.value(forKey: "cancerStatus")as! String)
            cancer.append(",")
            cancer.append(appdelegate.corporateAllDetailsDict.value(forKey: "fatherCancerStatus")as! String)
            cancer.append(",")
            cancer.append(appdelegate.corporateAllDetailsDict.value(forKey: "motherCancerStatus")as! String)
            let cancer_status = (cancer as String)
            
            let cardio = NSMutableString()
            cardio.append(appdelegate.corporateAllDetailsDict.value(forKey: "cardioStatus")as! String)
            cardio.append(",")
            cardio.append(appdelegate.corporateAllDetailsDict.value(forKey: "fatherCardioStatus")as! String)
            cardio.append(",")
            cardio.append(appdelegate.corporateAllDetailsDict.value(forKey: "motherCardioStatus")as! String)
            let cardio_status = (cardio as String)
            
            
            let diabetes = NSMutableString()
            diabetes.append("0")
            diabetes.append(",")
            diabetes.append(appdelegate.corporateAllDetailsDict.value(forKey: "fatherDiabetesStatus")as! String)
            diabetes.append(",")
            diabetes.append(appdelegate.corporateAllDetailsDict.value(forKey: "motherDiabetesStatus")as! String)
            let diabetes_status = (diabetes as String)
            
            let height = NSMutableString()
            height.append(appdelegate.corporateAllDetailsDict.value(forKey: "heightinfeet")as! String)
            if !(height.isEqual("")) {
                height.append(".")
                height.append(appdelegate.corporateAllDetailsDict.value(forKey: "heightininch")as! String)
            }
           
            
            print(height)
            let heightInFeetandInch = (height as String)
            let bloodgroup = (appdelegate.corporateAllDetailsDict.value(forKey: "bloodgroup")as! String)
            let exercise = (appdelegate.corporateAllDetailsDict.value(forKey: "exercise")as! String)
            let weight = (appdelegate.corporateAllDetailsDict.value(forKey: "weight")as! String)
            let waist = (appdelegate.corporateAllDetailsDict.value(forKey: "waist")as! String)
            
         //   print(appdelegate.corporateAllDetailsDict)
            let firstName = (appdelegate.corporateAllDetailsDict.value(forKey: "firstName")as! String)
            let middleName = ("")
            let lastName = (appdelegate.corporateAllDetailsDict.value(forKey: "lastName")as! String)
            
            
            let mobileNumber = (appdelegate.corporateAllDetailsDict.value(forKey: "mobileno")as! String)
            let personal_email = (appdelegate.corporateAllDetailsDict.value(forKey: "pemail")as! String)
            let official_email = (appdelegate.corporateAllDetailsDict.value(forKey: "oemail")as! String)
            
            var pincode = ""
            var geoAddress = ""
            var geoLong = ""
            var geoLat = ""
            var address1 = ""
            var address2 = ""
            
            var landmark = ""
            var city = ""
            var locality = ""
            var pickupDate = ""
            var pickupTime = ""
            
         //   let allParameters3 = ["firstName":appdelegate.corporateAllDetailsDict.valueForKey("firstName")as! String ,"middleName": "","lastName": appdelegate.corporateAllDetailsDict.valueForKey("lastName")as! String,"mobileNumber" : appdelegate.corporateAllDetailsDict.valueForKey("mobileno")as! String , "oEmail": appdelegate.corporateAllDetailsDict.valueForKey("oemail")as! String ,"pEmail": appdelegate.corporateAllDetailsDict.valueForKey("pemail")as! String ,"isHome": "0" , "pincode" : pincode , "geoAddress" : geoAddress , "geoLong" : geoLong ,"geoLat" : geoLat ,"address1" : address1 ,"address2" : address2, "landmark" : landmark , "city" : city , "locality": locality, "pickupDate" : pickupDate ,"pickupTime" : pickupTime ,"height":height as String,"weight": appdelegate.corporateAllDetailsDict.valueForKey("weight")as! String,"waist" : appdelegate.corporateAllDetailsDict.valueForKey("waist")as! String , "bloodGroup": appdelegate.corporateAllDetailsDict.valueForKey("bloodgroup")as! String ,"Hypertension": hypertension as String ,"Cancer": cancer as String , "Cardio" : cardio as String , "diabetes" : diabetes as String , "bp" : appdelegate.corporateAllDetailsDict.valueForKey("bloodPressure")as! String ,"smokeFrequency" : appdelegate.corporateAllDetailsDict.valueForKey("smoke")as! String ,"alcoholFrequency" : appdelegate.corporateAllDetailsDict.valueForKey("alcohal")as! String ,"exerciseFrequency" : appdelegate.corporateAllDetailsDict.valueForKey("exercise")as! String, "gender" : appdelegate.corporateAllDetailsDict.valueForKey("gender")as! String , "dob" : appdelegate.corporateAllDetailsDict.valueForKey("dob")as! String , "userId":NSUserDefaults.standardUserDefaults().valueForKey("loginCustomerId")as! String]
            
          //  print(allParameters3)
            if appdelegate.corporateAllDetailsDict.value(forKey: "selectedaddress")as! String == "0" {
                
                 pincode = ("")
                 geoAddress = ("")
                 geoLong = ("")
                 geoLat = ("")
                 address1 = ("")
                 address2 = ("")
                 landmark = ("")
                 city = ("")
                 locality = ("")
                 pickupDate = ("")
                 pickupTime = ("")

                
            }
            let isHome = (appdelegate.corporateAllDetailsDict.value(forKey: "selectedaddress")as! String)
            let companyId = UserDefaults.standard.value(forKey: "company_id") as! String
//            guard let departmentId = appdelegate.corporateAllDetailsDict.valueForKey("departmentID") else {
//                return ""
//            }
            let departmentId = appdelegate.corporateAllDetailsDict.value(forKey: "departmentID")as! String
            
            print(companyId)
            print(departmentId)

            
            let allParameters = [ "firstName" : firstName,
                                  "middleName" : middleName ,
                                  "lastName":lastName ,
                                  "mobileNumber": mobileNumber,
                                  "pEmail": personal_email ,
                                  "oEmail": official_email,
                                  "isHome":isHome,
                                  "pincode": pincode ,
                                  "geoAddress": geoAddress,
                                  "geoLong": geoLong ,
                                  "geoLat" : geoLat,
                                  "address1": address1,
                                  "address2" : address2 ,
                                  "landmark" : landmark,
                                  "city":city,
                                  "locality" : locality,
                                  "pickupDate" :pickupDate ,
                                  "pickupTime" : pickupTime,
                                  "height":heightInFeetandInch,
                                  "weight": weight,
                                  "waist" : waist,
                                  "bloodGroup": bloodgroup,
                                  "Hypertension": hypertension_status ,
                                  "Cancer":cancer_status ,
                                  "Cardio" : cardio_status ,
                                  "diabetes" : diabetes_status ,
                                  "bloodPressure" : bloodPressureStatus,
                                  "bloodGlucose" : bloodGlucose,
                                  "smokeFrequency" : smoke ,
                                  "alcoholFrequency" : alcohal ,
                                  "exerciseFrequency" : exercise,
                                  "gender" : gender ,
                                  "dob" : dob ,
                                  "userId":customerId,
                                  "departmentId" : departmentId ,
                                  "COMP_ID" : companyId]
            
            ServerConnectivity().callWebservice(allParameters, resulttagname: "SaveCorporateCustomer_V1Result" ,methodname: "SaveCorporateCustomer_V1", className: self)
        }else{
            
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
        
     //   print(allResponse)
    //    print(methodName)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                self.activityIndicator?.stop()
                
                if (allResponse .isEqual("error") || allResponse.isEqual("Something went wrong. Please try again.") || allResponse.isEqual("0") ) {
                    
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }else{
                // getMemberProfileInfo result 
                if(methodName == "SaveProfilePage4"){
                    if (allResponse as! String == "1"){
                        self.popToBackViewController()
                    }else{
                        
                    }
                }else if (methodName == "SaveCorporateCustomer_V1"){
                    
                    UserDefaults.standard.set(false, forKey: "iscorporate")
                    self.appdelegate.loadMainview()
                }
                else{
                if  allResponse is String {
                   
                }else{
                    self.arrMemberProfileInfoDetails = allResponse as! NSMutableArray
                    self.populateMemberProfileInfo()
                }
                }
                }
                
            });
        });
        
    }
    
    
    @IBAction func btnSave_DoneOnClick(_ sender: UIButton) {
        
      //  self.uploadMedicalHisotyPageFourthData()
        
        if isFromCorporate != "yes" {
            self.uploadMedicalHisotyPageFourthData()
        }else{
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        var hypertensionStatus = String()
        var cancerStatus = String()
        var cardioStatus = String()
        
        if arrTreatedSelectdValue.contains(100) {
          //  hypertensionStatus = ("1")
             appdelegate.corporateAllDetailsDict.setValue("1", forKey: "hypertensionStatus")
        }else{
          //  hypertensionStatus = ("0")
            appdelegate.corporateAllDetailsDict.setValue("0", forKey: "hypertensionStatus")
        }
        if arrTreatedSelectdValue.contains(101) {
          //  cancerStatus = ("1")
            appdelegate.corporateAllDetailsDict.setValue("1", forKey: "cancerStatus")
        }else{
         //   cancerStatus = ("0")
            appdelegate.corporateAllDetailsDict.setValue("0", forKey: "cancerStatus")
        }
        if arrTreatedSelectdValue.contains(102) {
           // cardioStatus = ("1")
            appdelegate.corporateAllDetailsDict.setValue("1", forKey: "cardioStatus")
        }else{
          //  cardioStatus = ("0")
             appdelegate.corporateAllDetailsDict.setValue("0", forKey: "cardioStatus")
        }
            
             appdelegate.corporateAllDetailsDict.setValue(bloodPressure, forKey: "bloodPressure")
             appdelegate.corporateAllDetailsDict.setValue(bloodGlucose, forKey: "bloodGlucose")
            
        print(appdelegate.corporateAllDetailsDict)
            
            print(appdelegate.corporateAllDetailsDict.value(forKey: "selectedaddress")as! String == "1")
           
            
            if (appdelegate.corporateAllDetailsDict.value(forKey: "selectedaddress")as! String == "1") {
                let corporateAddress = CorporateAddrssViewController()
                self.navigationController?.pushViewController(corporateAddress, animated: true)
                
                
            }else{
                self.saveAllMedicalHistory()
            }
            
            
            
            
            
        }
        
        

        
    }
    func btnSkipOnClick(_ button : UIButton)  {
        self.popToBackViewController()
        
       
    }
    @IBAction func bloodPressureSegmentedControlSelected(_ sender: UISegmentedControl) {
       
        if sender.selectedSegmentIndex == 0 {
            bloodPressure = "1"
            
        }else if(sender.selectedSegmentIndex == 1){
            bloodPressure = "2"
        }
        let isCheckBoxSelected = self.view.viewWithTag(btnBloodPressureCheckBox.tag + 1)as! UIImageView
        isCheckBoxSelected.image = UIImage(named: "nonselected_yellow_checkbox.png")
        btnBloodPressureCheckBox.isSelected = false
        
    }
    
    func popToBackViewController()  {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: MyFamilyViewController.self) {
                self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                break
            }
        }
        
    }
    func populateMemberProfileInfo()  {
        
         let bp = (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "bp")as! String
         let bg = (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "bg")as! String
        if bp == "0" {
            bloodPressure = "0"
           bloodPressureSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
        }else if(bp == "1"){
           bloodPressure = "1"
           bloodPressureSegmentedControl.selectedSegmentIndex = 0
           let isCheckBoxSelected = self.view.viewWithTag(btnBloodPressureCheckBox.tag + 1)as! UIImageView
           isCheckBoxSelected.image = UIImage(named: "nonselected_yellow_checkbox.png")
           btnBloodPressureCheckBox.isSelected = false
            
        }else if(bp == "2"){
           bloodPressure = "2"
           bloodPressureSegmentedControl.selectedSegmentIndex = 1
           let isCheckBoxSelected = self.view.viewWithTag(btnBloodPressureCheckBox.tag + 1)as! UIImageView
           isCheckBoxSelected.image = UIImage(named: "nonselected_yellow_checkbox.png")
           btnBloodPressureCheckBox.isSelected = false
        }
        if bg == "1" {
            let isCheckBoxSelected = self.view.viewWithTag(302)as! UIImageView
            fastingBloodSugarIsSelected = true
            btnFastingBloodSugar.backgroundColor = KRED_COLOR
            btnFastingBloodSugar.setTitleColor(UIColor.white, for: UIControlState())
            isCheckBoxSelected.image = UIImage(named: "nonselected_yellow_checkbox.png")
            btnBloodGlucoseCheckBox.isSelected = false
            bloodGlucose = "1"
        }else{
            let isCheckBoxSelected = self.view.viewWithTag(302)as! UIImageView
            isCheckBoxSelected.image = UIImage(named: "selected_red_checkbox.png")
            bloodGlucose = "0"
            
        }
        self.checkAndUncheckBox(1000, selecteValue: (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "hypertension")as! String )
        self.checkAndUncheckBox(1001, selecteValue: (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "cancer")as! String )
        self.checkAndUncheckBox(1002, selecteValue: (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "cardio")as! String )
        
    }
    
    
    func checkAndUncheckBox(_ tag : Int , selecteValue : String)  {
        
        
            if selecteValue == "1" {
                arrTreatedSelectdValue.add(tag - 900)
                let selectdCheckBoxImage = self.view.viewWithTag(tag)as! UIImageView
                selectdCheckBoxImage.image = UIImage(named: "selected_red_checkbox.png")
                
            }else{
                arrTreatedSelectdValue.remove(tag - 900)
                let nonSelectdCheckBoxImage = self.view.viewWithTag(tag)as! UIImageView
                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox.png")
            }
        
        if arrTreatedSelectdValue.count != 0 {
            let button = self.view.viewWithTag(103)as! UIButton
            button.isSelected = false
            
            let nonSelectdCheckBoxImage = self.view.viewWithTag(1003)as! UIImageView
            nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox.png")
            
        }
    }

    

}
