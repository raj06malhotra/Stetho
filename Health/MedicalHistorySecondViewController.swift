//
//  MedicalHistorySecondViewController.swift
//  Health
//
//  Created by HW-Anil on 7/29/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class MedicalHistorySecondViewController: UIViewController ,serverTaskComplete{
    @IBOutlet weak var alcohalSegmentedCntrol: UISegmentedControl!
    @IBOutlet weak var smokeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var exerciseSegmentedControl: UISegmentedControl!
    @IBOutlet weak var btnSave_Next: UIButton!
    @IBOutlet weak var lblBitYourLifeStyle: UILabel!
    @IBOutlet weak var lblLifeStyleSubTital: UILabel!
    
    @IBOutlet weak var lblTakeAlcohal: UILabel!
    @IBOutlet weak var lblSmoke: UILabel!
    @IBOutlet weak var lblExercise: UILabel!
    
     let bodertintColor: UIColor =  UIColor (red: (252.0/255.0), green: (199.0/255.0), blue: (99.0/255.0), alpha: 1)
    
    var activityIndicator : ProgressViewController?
    var memberId :String = ""
    var memberName: String = ""
    var selectedAlcoholFrequency = "0"
    var selectedSmokeFrequency = "0"
    var selectedexerciseFrequency = "0"
    var arrMemberProfileInfoDetails = NSArray()
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func createLayoutDesign()  {
        btnSave_Next.layer.borderWidth = 2
        btnSave_Next.layer.borderColor = UIColor.red.cgColor
        
        alcohalSegmentedCntrol.tintColor = bodertintColor
        smokeSegmentedControl.tintColor = bodertintColor
        exerciseSegmentedControl.tintColor = bodertintColor
        
        
        //set selectd indext and its color
       // (alcohalSegmentedCntrol.subviews[0] as UIView).tintColor = UIColor .redColor()
        alcohalSegmentedCntrol.selectedSegmentIndex = 2
       // (smokeSegmentedControl.subviews[0] as UIView).tintColor = UIColor .redColor()
        smokeSegmentedControl.selectedSegmentIndex = 2
     //   (exerciseSegmentedControl.subviews[0] as UIView).tintColor = UIColor .redColor()
        exerciseSegmentedControl.selectedSegmentIndex = 2
      //  (medicineDailySegmentedControl.subviews[0] as UIView).tintColor = UIColor .redColor()
       
        
        //set text color of Segment control
        let titleTextAttributes = [NSForegroundColorAttributeName: UIColor (red: (81.0/255.0), green: (81.0/255.0), blue: (81.0/255.0), alpha: 1)]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: UIControlState())
        if isFromCorporate != "yes" {
        //Add skip button on Navigation bar 
        let btnSkip = BaseUIController().AButtonFrame(CGRect(x: 0  ,y: 7 , width: 50 , height: 30), withButtonTital: "Skip")as! UIButton
        btnSkip.backgroundColor = UIColor.white
        btnSkip.setTitleColor(UIColor.red, for: UIControlState())
        btnSkip.addTarget(self, action: #selector(MedicalHistorySecondViewController.btnSkipOnClick(_:)), for: .touchUpInside)
         let rightBarButton = UIBarButtonItem(customView: btnSkip)
         self.navigationItem.rightBarButtonItem = rightBarButton
        }
         //change dynamic text on UIlable
        if memberName != "" {
            lblBitYourLifeStyle.text = String(format: "A bit about %@ lifestyle" , memberName)
            lblLifeStyleSubTital.text = String(format: "%@ lifestyle plays a major role in %@ future health and onset of chronic disease.",memberName ,memberName)
            lblTakeAlcohal.attributedText = self.changeTextWithMultipleColor(String(format: "How often do %@ take " , memberName) , redString: "Alcohal?")
            lblSmoke.attributedText = self.changeTextWithMultipleColor(String(format: "How often do %@ take " , memberName) , redString: "Smoke?")
            lblExercise.attributedText = self.changeTextWithMultipleColor(String(format: "How often do %@ " , memberName) , redString: "Exercise?")
        }else{
            lblTakeAlcohal.attributedText = self.changeTextWithMultipleColor(String(format: "How often do You take ") , redString: "Alcohal?")
            lblSmoke.attributedText = self.changeTextWithMultipleColor(String(format: "How often do You take ") , redString: "Smoke?")
            lblExercise.attributedText = self.changeTextWithMultipleColor(String(format: "How often do You ") , redString: "Exercise?")
        }
        
        

    }
    
    //MARK: chageWihtMultipleTextAttributeColor
    func changeTextWithMultipleColor(_ blackString : String , redString : String) -> NSMutableAttributedString {
        
        let attrs1      = [NSFontAttributeName: UIFont().regularMediumFont, NSForegroundColorAttributeName:UIColor.black]
        let attrs2      = [NSFontAttributeName: UIFont().regularMediumFont, NSForegroundColorAttributeName: UIColor.red]
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: blackString , attributes:  attrs1))
        attributedText.append(NSAttributedString(string: redString, attributes: attrs2))
        return attributedText
    }
    
    @IBAction func alcohalSegmentedControlSelectedValue(_ sender: AnyObject) {
        if sender.selectedSegmentIndex == 0 {
            print("0")
            selectedAlcoholFrequency = "1"
            
        }else if(sender.selectedSegmentIndex == 1){
          
            selectedAlcoholFrequency = "2"
        }else{
             selectedAlcoholFrequency = "0"
        }
    }

    @IBAction func smokeSegmentedControlSelectedValue(_ sender: AnyObject) {
        
        if sender.selectedSegmentIndex == 0 {
           selectedSmokeFrequency = "1"
        }else if(sender.selectedSegmentIndex == 1){
           selectedSmokeFrequency = "2"
        }else{
            selectedSmokeFrequency = "0"
        }
    }
   
    @IBAction func exerciseSegmentedControlSelectedValue(_ sender: AnyObject) {
        if sender.selectedSegmentIndex == 0 {
            selectedexerciseFrequency = "1"
        }else if(sender.selectedSegmentIndex == 1){
            selectedexerciseFrequency = "2"
        }else{
            selectedexerciseFrequency = "0"
        }
    }
  
    //MARK: UploadDataOnServer
    
    func getMemberProfileInfo()  {
        
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            
            let allParameters = ["memberId":self.memberId, "profilePage": "2"]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetMemberProfileResult" ,methodname: "GetMemberProfile", className: self)
        }else{
            
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }

    
    
    func uploadMedicalHisotyPageSecondData()  {
       if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let allParameters = ["memberId":self.memberId, "customerId":customerId ,"alcoholFrequency":selectedAlcoholFrequency,"smokeFrequency":selectedSmokeFrequency,"exerciseFrequency":selectedexerciseFrequency]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "SaveProfilePage2Result" ,methodname: "SaveProfilePage2", className: self)
        }else{
            
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
       // print(allResponse)
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                self.activityIndicator?.stop()
                // getMemberProfileInfo result
                if(methodName == "SaveProfilePage2"){
                    let resultString = allResponse as! String
                    if (resultString == "1"){
                        self.sendToNextViweController()
                        
                    }else{
                        
                    }
                }else{
                if  allResponse is String {
                    
                }else{
                    self.arrMemberProfileInfoDetails = allResponse as! NSMutableArray
                    self.populateMemberProfileInfo()
                    
                }
                }
                
            });
        });
        
    }
    
    
    @IBAction func btnSave_NextOnClick(_ sender: AnyObject) {
      
        if isFromCorporate == "yes" {
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.corporateAllDetailsDict.setValue(selectedAlcoholFrequency, forKey: "alcohal")
            appdelegate.corporateAllDetailsDict.setValue(selectedSmokeFrequency, forKey: "smoke")
            appdelegate.corporateAllDetailsDict.setValue(selectedexerciseFrequency, forKey: "exercise")
            
             print(appdelegate.corporateAllDetailsDict)
            
            self.sendToNextViweController()
            
        }else{
          self.uploadMedicalHisotyPageSecondData()
        }
        
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.corporateAllDetailsDict.setValue(selectedAlcoholFrequency, forKey: "alcohal")
        appdelegate.corporateAllDetailsDict.setValue(selectedSmokeFrequency, forKey: "smoke")
        appdelegate.corporateAllDetailsDict.setValue(selectedexerciseFrequency, forKey: "exercise")
       
        
    }
    func btnSkipOnClick(_ button : UIButton)  {
        self.sendToNextViweController()
    }
    func sendToNextViweController()  {
        
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        let medicalHistoryThirdVC = storyboard1.instantiateViewController(withIdentifier: "MedicalHistoryThirdViewController")as! MedicalHistoryThirdViewController
        medicalHistoryThirdVC.memberId = memberId
        medicalHistoryThirdVC.isFromCorporate = isFromCorporate
        medicalHistoryThirdVC.memberName = memberName
        self.navigationController?.pushViewController(medicalHistoryThirdVC, animated: true)

    }
    func populateMemberProfileInfo()  {
        let alcohol_freq = (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "alcohol_freq")as! String
        let exercise_freq = (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "exercise_freq")as! String
        let smoke_freq = (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "smoke_freq")as! String
        if alcohol_freq == "1" {
            alcohalSegmentedCntrol.selectedSegmentIndex = 0
            selectedAlcoholFrequency = "1"
        }else if (alcohol_freq == "2"){
            alcohalSegmentedCntrol.selectedSegmentIndex = 1
            selectedAlcoholFrequency = "2"
        }else{
            alcohalSegmentedCntrol.selectedSegmentIndex = 2
            selectedAlcoholFrequency = "0"
        }
        
        if exercise_freq == "1" {
            exerciseSegmentedControl.selectedSegmentIndex = 0
            selectedexerciseFrequency = "1"
        }else if (exercise_freq == "2"){
            exerciseSegmentedControl.selectedSegmentIndex = 1
            selectedexerciseFrequency = "2"
        }else{
            exerciseSegmentedControl.selectedSegmentIndex = 2
            selectedexerciseFrequency = "0"
        }
        
        if smoke_freq == "1" {
            smokeSegmentedControl.selectedSegmentIndex = 0
            selectedSmokeFrequency = "1"
        }else if (smoke_freq == "2"){
            smokeSegmentedControl.selectedSegmentIndex = 1
            selectedSmokeFrequency = "2"
        }else{
            smokeSegmentedControl.selectedSegmentIndex = 2
            selectedSmokeFrequency = "0"
        }
        
        
        
    }

}
