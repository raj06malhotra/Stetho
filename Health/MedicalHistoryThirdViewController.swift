//
//  MedicalHistoryThirdViewController.swift
//  Health
//
//  Created by HW-Anil on 7/30/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class MedicalHistoryThirdViewController: UIViewController ,serverTaskComplete {
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var btnSave_Next: UIButton!
    
    @IBOutlet weak var lblFamilyInformation: UILabel!
    
    @IBOutlet weak var lblFamilyInformationSubtital: UILabel!
    
    @IBOutlet weak var lblFatherCondition: UILabel!
    
    @IBOutlet weak var lblMotherCondition: UILabel!
    
    var activityIndicator : ProgressViewController?
    var memberId : String = ""
    var memberName: String = ""
    var arrFatherSelectdConditionValue  = NSMutableArray()
    var arrmotherSelectdConditionValue  = NSMutableArray()
    var arrMemberProfileInfoDetails = NSArray()
    var isFromCorporate = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       // scrollView.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height + 500)
        self.createLayoutDesign()
        //add ActivityIndicator on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        if isFromCorporate != "yes" {
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
    func createLayoutDesign()  {
        
        btnSave_Next.layer.borderWidth = 2
        btnSave_Next.layer.borderColor = KRED_COLOR.cgColor
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
            lblFamilyInformation.text = String(format: "%@ family information" , memberName)
            lblFamilyInformationSubtital.text = String(format: "Did you know %@ family genetics alos determines %@ health ",memberName,memberName)
            lblFatherCondition.attributedText = self.changeTextWithMultipleColor(String(format: "What is %@ " , memberName) , redString: "father's condition?")
            lblMotherCondition.attributedText = self.changeTextWithMultipleColor(String(format: "What is %@ " , memberName) , redString: "mother's condition?")
            
        }else{
            lblFatherCondition.attributedText = self.changeTextWithMultipleColor(String(format: "What is Your ") , redString: "father's condition?")
            lblMotherCondition.attributedText = self.changeTextWithMultipleColor(String(format: "What is Your ") , redString: "mother's condition?")
        }


        
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
    
    @IBAction func fatherSelectedCondition(_ sender: UIButton) {
//       print(sender.tag)
//        for i in 0..<5 {
//            if sender.tag == 100 + i {
//                let selectdCheckBoxImage = self.view.viewWithTag(1000 + i)as! UIImageView
//                selectdCheckBoxImage.image = UIImage(named: "selected_red_checkbox.png")
//            }else{
////               let nonSelectdCheckBoxImage = self.view.viewWithTag(1000 + i)as! UIImageView
////                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox")
//            }
//        }
        
        if sender.tag == 104 {
            if sender.isSelected == true {
                sender.isSelected = false
                let nonSelectdCheckBoxImage = self.view.viewWithTag(900 + sender.tag)as! UIImageView
                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox")
            }else{
                for i in 0..<4 {
                    let nonSelectdCheckBoxImage = self.view.viewWithTag(1000 + i)as! UIImageView
                    nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox")
                }
                arrFatherSelectdConditionValue.removeAllObjects()
                sender.isSelected = true
                let selectdCheckBoxImage = self.view.viewWithTag(900 + sender.tag)as! UIImageView
                selectdCheckBoxImage.image = UIImage(named: "selected_red_checkbox.png")
            }
            
            
        }else{
            if arrFatherSelectdConditionValue .contains(sender.tag) {
                arrFatherSelectdConditionValue.remove(sender.tag)
                let nonSelectdCheckBoxImage = self.view.viewWithTag(900 + sender.tag)as! UIImageView
                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox")
            }else{
                arrFatherSelectdConditionValue.add(sender.tag)
                let selectdCheckBoxImage = self.view.viewWithTag(900 + sender.tag)as! UIImageView
                selectdCheckBoxImage.image = UIImage(named: "selected_red_checkbox.png")
            }
            if arrFatherSelectdConditionValue.count != 0 {
                let button = self.view.viewWithTag(104)as! UIButton
                button.isSelected = false
                
                let nonSelectdCheckBoxImage = self.view.viewWithTag(1004)as! UIImageView
                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox")
                
            }
        }

        
        
    }
    
    @IBAction func motherSelectedCondition(_ sender: UIButton) {
//        print(sender.tag)
//        for i in 0..<5 {
//            if sender.tag == 200 + i {
//                let selectdCheckBoxImage = self.view.viewWithTag(2000 + i)as! UIImageView
//                selectdCheckBoxImage.image = UIImage(named: "selected_red_checkbox.png")
//            }else{
//                let nonSelectdCheckBoxImage = self.view.viewWithTag(2000 + i)as! UIImageView
//                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox")
//            }
//        }
        
        if sender.tag == 204 {
            if sender.isSelected == true {
                sender.isSelected = false
                let nonSelectdCheckBoxImage = self.view.viewWithTag(1800 + sender.tag)as! UIImageView
                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox")
            }else{
                for i in 0..<4 {
                    let nonSelectdCheckBoxImage = self.view.viewWithTag(2000 + i)as! UIImageView
                    nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox")
                }
                arrmotherSelectdConditionValue.removeAllObjects()
                sender.isSelected = true
                let selectdCheckBoxImage = self.view.viewWithTag(1800 + sender.tag)as! UIImageView
                selectdCheckBoxImage.image = UIImage(named: "selected_red_checkbox.png")
            }
            
            
        }else{
            if arrmotherSelectdConditionValue .contains(sender.tag) {
                arrmotherSelectdConditionValue.remove(sender.tag)
                let nonSelectdCheckBoxImage = self.view.viewWithTag(1800 + sender.tag)as! UIImageView
                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox")
            }else{
                arrmotherSelectdConditionValue.add(sender.tag)
                let selectdCheckBoxImage = self.view.viewWithTag(1800 + sender.tag)as! UIImageView
                selectdCheckBoxImage.image = UIImage(named: "selected_red_checkbox.png")
            }
            if arrmotherSelectdConditionValue.count != 0 {
                let button = self.view.viewWithTag(204)as! UIButton
                button.isSelected = false
                
                let nonSelectdCheckBoxImage = self.view.viewWithTag(2004)as! UIImageView
                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox")
                
            }
        }

        
    }
    
    //MARK: UploadDataOnServer
    func getMemberProfileInfo()  {
        
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let allParameters = ["memberId":self.memberId, "profilePage": "3"]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetMemberProfileResult" ,methodname: "GetMemberProfile", className: self)
        }else{
            
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    
    func uploadMedicalHisotyPageThirdData()  {
        
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let memberId = (self.memberId)
            let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            var fatherHypertensionStatus = String()
            var fatherCancerStatus = String()
            var fatherCardioStatus = String()
            var fatherDiabetesStatus = String()
            if arrFatherSelectdConditionValue.contains(100) {
                fatherHypertensionStatus = ("1")
            }else{
                fatherHypertensionStatus = ("0")
            }
            if arrFatherSelectdConditionValue.contains(101) {
                fatherCancerStatus = ("1")
            }else{
                fatherCancerStatus = ("0")
            }
            if arrFatherSelectdConditionValue.contains(102) {
                fatherCardioStatus = ("1")
            }else{
                fatherCardioStatus = ("0")
            }
            if arrFatherSelectdConditionValue.contains(103) {
                fatherDiabetesStatus = ("1")
            }else{
                fatherDiabetesStatus = ("0")
            }
            
            var motherHypertensionStatus = String()
            var motherCancerStatus = String()
            var motherCardioStatus = String()
            var motherDiabetesStatus = String()
            if arrmotherSelectdConditionValue.contains(200) {
                motherHypertensionStatus = ("1")
            }else{
                motherHypertensionStatus = ("0")
            }
            if arrmotherSelectdConditionValue.contains(201) {
                motherCancerStatus = ("1")
            }else{
                motherCancerStatus = ("0")
            }
            if arrmotherSelectdConditionValue.contains(202) {
                motherCardioStatus = ("1")
            }else{
                motherCardioStatus = ("0")
            }
            if arrmotherSelectdConditionValue.contains(203) {
                motherDiabetesStatus = ("1")
            }else{
                motherDiabetesStatus = ("0")
            }

            
            
            
            let allParameters = ["memberId":memberId, "customerId":customerId ,"fatherHypertensionStatus":fatherHypertensionStatus,"fatherCancerStatus":fatherCancerStatus,"fatherCardioStatus":fatherCardioStatus,"fatherDiabetesStatus": fatherDiabetesStatus ,"motherHypertensionStatus":motherHypertensionStatus,"motherCancerStatus":motherCancerStatus,"motherCardioStatus":motherCardioStatus,"motherDiabetesStatus": motherDiabetesStatus]
            
            ServerConnectivity().callWebservice(allParameters, resulttagname: "SaveProfilePage3Result" ,methodname: "SaveProfilePage3", className: self)
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
                if(methodName == "SaveProfilePage3"){
                    if (allResponse as! String == "1"){
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
    
    
    @IBAction func btnSave_NextOnClick(_ sender: UIButton) {
        
    
        if isFromCorporate == "yes" {
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            
            var fatherHypertensionStatus = String()
            var fatherCancerStatus = String()
            var fatherCardioStatus = String()
            var fatherDiabetesStatus = String()
            if arrFatherSelectdConditionValue.contains(100) {
                // fatherHypertensionStatus = ("1")
                appdelegate.corporateAllDetailsDict.setValue("1", forKey: "fatherHypertensionStatus")
            }else{
                //fatherHypertensionStatus = ("0")
                appdelegate.corporateAllDetailsDict.setValue("0", forKey: "fatherHypertensionStatus")
            }
            if arrFatherSelectdConditionValue.contains(101) {
                //   fatherCancerStatus = ("1")
                appdelegate.corporateAllDetailsDict.setValue("1", forKey: "fatherCancerStatus")
            }else{
                //  fatherCancerStatus = ("0")
                appdelegate.corporateAllDetailsDict.setValue("0", forKey: "fatherCancerStatus")
            }
            if arrFatherSelectdConditionValue.contains(102) {
                //  fatherCardioStatus = ("1")
                appdelegate.corporateAllDetailsDict.setValue("1", forKey: "fatherCardioStatus")
            }else{
                //  fatherCardioStatus = ("0")
                appdelegate.corporateAllDetailsDict.setValue("0", forKey: "fatherCardioStatus")
            }
            if arrFatherSelectdConditionValue.contains(103) {
                // fatherDiabetesStatus = ("1")
                appdelegate.corporateAllDetailsDict.setValue("1", forKey: "fatherDiabetesStatus")
            }else{
                // fatherDiabetesStatus = ("0")
                appdelegate.corporateAllDetailsDict.setValue("0", forKey: "fatherDiabetesStatus")
                
            }
            
            var motherHypertensionStatus = String()
            var motherCancerStatus = String()
            var motherCardioStatus = String()
            var motherDiabetesStatus = String()
            if arrmotherSelectdConditionValue.contains(200) {
                //   motherHypertensionStatus = ("1")
                appdelegate.corporateAllDetailsDict.setValue("1", forKey: "motherHypertensionStatus")
            }else{
                //  motherHypertensionStatus = ("0")
                appdelegate.corporateAllDetailsDict.setValue("0", forKey: "motherHypertensionStatus")
            }
            if arrmotherSelectdConditionValue.contains(201) {
                // motherCancerStatus = ("1")
                appdelegate.corporateAllDetailsDict.setValue("1", forKey: "motherCancerStatus")
            }else{
                // motherCancerStatus = ("0")
                appdelegate.corporateAllDetailsDict.setValue("0", forKey: "motherCancerStatus")
            }
            if arrmotherSelectdConditionValue.contains(202) {
                //  motherCardioStatus = ("1")
                appdelegate.corporateAllDetailsDict.setValue("1", forKey: "motherCardioStatus")
            }else{
                // motherCardioStatus = ("0")
                appdelegate.corporateAllDetailsDict.setValue("0", forKey: "motherCardioStatus")
                
            }
            if arrmotherSelectdConditionValue.contains(203) {
                //  motherDiabetesStatus = ("1")
                appdelegate.corporateAllDetailsDict.setValue("1", forKey: "motherDiabetesStatus")
                
            }else{
                //  motherDiabetesStatus = ("0")
                appdelegate.corporateAllDetailsDict.setValue("0", forKey: "motherDiabetesStatus")
            }
            
            
            print(appdelegate.corporateAllDetailsDict)
            self.sendToNextViewController()
            
        }else{
            self.uploadMedicalHisotyPageThirdData()
        }
        
        
        
        

        
        
        
//        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
//        let medicalHistoryFourthVC = storyboard1.instantiateViewControllerWithIdentifier("MedicalHistoryFourthViewController")as! MedicalHistoryFourthViewController
//        self.navigationController?.pushViewController(medicalHistoryFourthVC, animated: true)
        
    }
    func btnSkipOnClick(_ button : UIButton)  {
        self.sendToNextViewController()
        
    }

    func sendToNextViewController()  {
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        let medicalHistoryFourthVC = storyboard1.instantiateViewController(withIdentifier: "MedicalHistoryFourthViewController")as! MedicalHistoryFourthViewController
        medicalHistoryFourthVC.memberId = self.memberId
        medicalHistoryFourthVC.isFromCorporate = isFromCorporate
        medicalHistoryFourthVC.memberName = memberName
        self.navigationController?.pushViewController(medicalHistoryFourthVC, animated: true)
    }
    
    func populateMemberProfileInfo() {
        if ((arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "relation")as! String == "Father") {
            self.checkAndUncheckBox(1000, selecteValue: (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "hypertension")as! String , relation: "Father")
            self.checkAndUncheckBox(1001, selecteValue: (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "cancer")as! String , relation: "Father")
            self.checkAndUncheckBox(1002, selecteValue: (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "cardio")as! String , relation: "Father")
            self.checkAndUncheckBox(1003, selecteValue: (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "diabetes")as! String , relation: "Father")
        }
        
        if ((arrMemberProfileInfoDetails.object(at: 1) as AnyObject).value(forKey: "relation")as! String == "Mother") {
            self.checkAndUncheckBox(2000, selecteValue: (arrMemberProfileInfoDetails.object(at: 1) as AnyObject).value(forKey: "hypertension")as! String , relation: "Mother")
            self.checkAndUncheckBox(2001, selecteValue: (arrMemberProfileInfoDetails.object(at: 1) as AnyObject).value(forKey: "cancer")as! String , relation: "Mother")
            self.checkAndUncheckBox(2002, selecteValue: (arrMemberProfileInfoDetails.object(at: 1) as AnyObject).value(forKey: "cardio")as! String , relation: "Mother")
            self.checkAndUncheckBox(2003, selecteValue: (arrMemberProfileInfoDetails.object(at: 1) as AnyObject).value(forKey: "diabetes")as! String , relation: "Mother")
        }
      
    }
    func checkAndUncheckBox(_ tag : Int , selecteValue : String , relation : String)  {
        
        if relation == "Father" {
            if selecteValue == "1" {
                arrFatherSelectdConditionValue.add(tag - 900)
                let selectdCheckBoxImage = self.view.viewWithTag(tag)as! UIImageView
                selectdCheckBoxImage.image = UIImage(named: "selected_red_checkbox.png")
                
            }else{
                arrFatherSelectdConditionValue.remove(tag - 900)
                let nonSelectdCheckBoxImage = self.view.viewWithTag(tag)as! UIImageView
                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox.png")
            }
        }else{
            if selecteValue == "1" {
                arrmotherSelectdConditionValue.add(tag - 1800)
                let selectdCheckBoxImage = self.view.viewWithTag(tag)as! UIImageView
                selectdCheckBoxImage.image = UIImage(named: "selected_red_checkbox.png")
                
            }else{
                arrmotherSelectdConditionValue.remove(tag - 1800)
                let nonSelectdCheckBoxImage = self.view.viewWithTag(tag)as! UIImageView
                nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox")
            }
        }
        if arrFatherSelectdConditionValue.count != 0 {
            let button = self.view.viewWithTag(104)as! UIButton
            button.isSelected = false
            
            let nonSelectdCheckBoxImage = self.view.viewWithTag(1004)as! UIImageView
            nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox")
            
        }
        
        if arrmotherSelectdConditionValue.count != 0 {
            let button = self.view.viewWithTag(204)as! UIButton
            button.isSelected = false
            
            let nonSelectdCheckBoxImage = self.view.viewWithTag(2004)as! UIImageView
            nonSelectdCheckBoxImage.image = UIImage(named: "nonselected_yellow_checkbox")
        }
    }

   

}
