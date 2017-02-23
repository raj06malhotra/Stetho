                                 //
//  ViewController.swift
//  Health
//
//  Created by HW-Anil on 6/15/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit
import Crashlytics
                    

class ViewController: UIViewController , XMLParserDelegate , NSURLConnectionDelegate ,serverTaskComplete  {
    var activityIndicator : ProgressViewController?
    var mutableData:NSMutableData  = NSMutableData()
    var dictRespovarData:NSMutableDictionary  = NSMutableDictionary()
    var currentElementName:NSString = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    
   
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var txtMobileNo: UITextField!
   
    var attrs = [
        NSFontAttributeName : UIFont.systemFont(ofSize: 15.0),
        NSForegroundColorAttributeName : UIColor (red: (243.0/255.0), green: (193.0/255.0), blue: (0/255.0), alpha: 1),
        NSUnderlineStyleAttributeName : 1] as [String : Any]
    
    var attributedString = NSMutableAttributedString(string:"")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // open corporate page if iscoporate (yes) user
        self.pushForCorporateSignup()
        
        // Do any additional setup after loading the view, typically from a nib.
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
      //  // self.view.addSubview(activityIndicator!) Comment Progress
        
        //set back button and tital 
        self.navigationItem.setHidesBackButton(true, animated:true)
        //set navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.navigationBar.isTranslucent = true;
       // self.navigationController!.navigationBar.barTintColor = UIColor(red: 212.0/255, green: 47.0/255, blue: 41.0/255, alpha: 1)
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = KRED_COLOR
//        
//        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.systemFontOfSize(14), NSForegroundColorAttributeName : KRED_COLORColor()]
        self.navigationController!.navigationBar.titleTextAttributes = appDelegate.navigationTitalFontSize
        self .setStatusBarBackgroundColor(UIColor(red: 193.0/255, green: 38.0/255, blue: 33.0/255, alpha: 1))
        self.title = "LOGIN / SIGN UP"
        let defaults = UserDefaults.standard
        let slide1 : UIImage!
        let slide2 : UIImage!
        let slide3 : UIImage!
        let slide4 : UIImage!

        if (defaults .object(forKey: "into_screen_viewed") == nil) {
            
            switch UIScreen.main.bounds.size.width {
            case 320:
                slide1 = #imageLiteral(resourceName: "slide_1_5s")
                slide2 = #imageLiteral(resourceName: "slide_2_5s")
                slide3 = #imageLiteral(resourceName: "slide_3_5s")
                slide4 = #imageLiteral(resourceName: "slide_4_5s")
            case 375:
                slide1 = #imageLiteral(resourceName: "slide_1_6")
                slide2 = #imageLiteral(resourceName: "slide_2_6")
                slide3 = #imageLiteral(resourceName: "slide_3_6")
                slide4 = #imageLiteral(resourceName: "slide_4_6")
                
            default:
                slide1 = #imageLiteral(resourceName: "slide_1_6")
                slide2 = #imageLiteral(resourceName: "slide_2_6")
                slide3 = #imageLiteral(resourceName: "slide_3_6")
                slide4 = #imageLiteral(resourceName: "slide_4_6")
            }
            
            
            let item1 = RMParallaxItem(image: slide1, text: "")
            let item2 = RMParallaxItem(image: slide2, text: "")
            let item3 = RMParallaxItem(image: slide3, text: "")
            let item4 = RMParallaxItem(image: slide4, text: "")
            
            let rmParallaxViewController = RMParallax(items: [item1, item2, item3, item4], motion: true)
            rmParallaxViewController.completionHandler = {
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    rmParallaxViewController.view.alpha = 0.0
                })
            }
            // Adding parallax view controller.
            self.addChildViewController(rmParallaxViewController)
            self.view.addSubview(rmParallaxViewController.view)
            rmParallaxViewController.didMove(toParentViewController: self)
        }else{
             self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        txtMobileNo.frame = CGRect(x: txtMobileNo.frame.origin.x, y: txtMobileNo.frame.origin.y, width: txtMobileNo.frame.width,height: 40)
        btnContinue.frame = CGRect(x: 0, y: self.view.frame.height - 104, width: self.view.frame.width, height: 40)
        txtMobileNo.keyboardType = .numberPad
        addToolBar(txtMobileNo)
        
//        let buttonTitleStr = NSMutableAttributedString(string:"New User? Sign Up", attributes:attrs)
//        attributedString.appendAttributedString(buttonTitleStr)
//        btnNewUserSignUp.setAttributedTitle(attributedString, forState: .Normal)
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
     //  addCrashButton()
  
    }
//    
//    func addCrashButton(){
//        let button = UIButton(type: UIButtonType.RoundedRect)
//        button.frame = CGRectMake(20, 50, 100, 30)
//        button.setTitle("Crash", forState: UIControlState.Normal)
//        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//        view.addSubview(button)
//  
//    }
//    
//    @IBAction func crashButtonTapped(sender: AnyObject) {
//        Crashlytics.sharedInstance().crash()
//    }

    
    func pushForCorporateSignup()  {
        // open corporate page if iscoporate (yes) user
        let isCorporate = UserDefaults.standard.bool(forKey: "iscorporate")
        if isCorporate  {
            let corporateVC = CorporateViewController()
            corporateVC.isComingfromCheckinBarCode = false
            self.navigationController!.pushViewController(corporateVC, animated: true)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        if self.navigationController?.isNavigationBarHidden == true {
            return true
        }
        else
        {
            return false
        }
       
    }
    
   
    @IBAction func btnLoginOnclick(_ sender: AnyObject) {
//          let signUp = self.storyboard?.instantiateViewControllerWithIdentifier("registerVC") as! RegisterViewController
//          self.navigationController?.pushViewController(signUp, animated: true)
 
        
        txtMobileNo.resignFirstResponder()
        if (txtMobileNo.text?.isEmpty == true) {
             self.present(BaseUIController().showAlertView("Please Enter Mobile Number!"), animated: true, completion: nil)
        }else{
            if GlobalInfo.sharedInfo.phoneNumberValidation(txtMobileNo.text!) == true {
//            if self.phoneNumberValidation(txtMobileNo.text!) == true {
                
                self.hitAWebServices()
                
            }else{
                 self.present(BaseUIController().showAlertView("Please Enter Valide Mobile Number!"), animated: true, completion: nil)
            }
         
        }

    }

    @IBAction func btnForgotPasswordOnClick(_ sender: AnyObject) {
        
          let forgotPassword = self.storyboard?.instantiateViewController(withIdentifier: "forgotpasswordVC") as! ForgotPasswordViewController
            // Take user to SecondViewController
          self.navigationController?.pushViewController(forgotPassword, animated: true)

    }
    
    @IBAction func btnSignUpOnClick(_ sender: AnyObject) {
      //  let signUp = self.storyboard?.instantiateViewControllerWithIdentifier("registerVC") as! RegisterViewController
        // Take user to SecondViewController
        
        let newUserSignupVC = NewUserSignUpViewController()
        
        self.navigationController?.pushViewController(newUserSignupVC, animated: true)

    }
    func setStatusBarBackgroundColor(_ color: UIColor) {
        
        guard  let statusBar = (UIApplication.shared.value(forKey: "statusBarWindow") as AnyObject).value(forKey: "statusBar") as? UIView else {
            return
        }
        
        statusBar.backgroundColor = color
    }
    // MARK: - TextFiedlDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 10
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length == maxLength   {
            txtMobileNo.text = newString as String
            textField.resignFirstResponder()
        }
        return newString.length <= maxLength
    }
    
    func hitAWebServices()  {
        if Reachability.isConnectedToNetwork() == true {
//        // self.view.addSubview(activityIndicator!) Comment Progress
        activityIndicator?.start()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
       //set mobile no in NSUserDefault
        UserDefaults.standard.setValue(txtMobileNo.text!, forKey: "mobileNo")
        let allParameters = ["mobileNo":txtMobileNo.text!, "appVersion":appDelegate.appVersion,"mobileName":UIDevice.current.modelName]
        ServerConnectivity().callWebservice(allParameters, resulttagname: "CheckUserLogin_V2Result" ,methodname: "CheckUserLogin_V2", className: self)

        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }

    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String)
        
   {
    
         print(allResponse)
    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
//        DispatchQueue.global(priority:
//            DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
//                self.activityIndicator?.removeFromSuperview()
                self.activityIndicator?.stop()
                if  allResponse is String {
                self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }else{
                     self.jsonResponseData(allResponse)
                }
                
            });
        };
       
    }

    

   //validate PhoneNumber
        func jsonResponseData(_ josnResponseData : AnyObject)  {
        let infoData = (josnResponseData as! NSArray)[0] as! NSDictionary
        let id = infoData.value(forKey: "id")
        let name = infoData.value(forKey: "name")
        let password = infoData.value(forKey: "password")
        let userType = infoData.value(forKey: "type")as! String
        let isCorporate = infoData.value(forKey: "ISCORP") as! String
       // isCorporate = "1" //did for local testing
        let defaults = UserDefaults.standard
        defaults.setValue(name, forKey: "userName")
        defaults.setValue(password, forKey: "password")
        defaults.setValue(id, forKey: "loginCustomerId")
        
        
        if (isCorporate == "1") {
            
           UserDefaults.standard.setValue(infoData.value(forKey: "PACK_NAME")as! String, forKey: "PACK_NAME")
             UserDefaults.standard.setValue(infoData.value(forKey: "COMP_ID")as! String, forKey: "company_id")
            GlobalInfo.sharedInfo.setValueInDefault(infoData.value(forKey: KCOPERATE_NAME) as AnyObject, forKey: KCOPERATE_NAME)
            GlobalInfo.sharedInfo.setValueInDefault(infoData.value(forKey: KCOPERATE_URL) as AnyObject, forKey: KCOPERATE_URL)
            
            //NSUserDefaults.standardUserDefaults().setBool(true, forKey: "iscorporate")
            let arrDepartment = NSMutableArray()
            
            
            for i in (0..<josnResponseData.count){
                let dictDetails = (josnResponseData as! NSArray)[i] as! NSDictionary
                let dictDepartment = NSMutableDictionary()
                print(dictDetails.value(forKey: "department_name")as! String)
                
                dictDepartment.setValue(dictDetails.value(forKey: "department_name")as! String, forKey: "departmentName")
                dictDepartment.setValue(dictDetails.value(forKey: "cwd_id")as! String, forKey: "department_id")
                
                arrDepartment.add(dictDepartment)
            }
            UserDefaults.standard.setValue(arrDepartment, forKey: "department")
            
        }
        if (userType == "N")  {
            let OTPVarification = OTPVarificationViewController()
            OTPVarification.otpPassword =  password as! String
            self.navigationController?.pushViewController(OTPVarification, animated: true)
            
        }else if(userType == "E"){
            let setPassword = self.storyboard?.instantiateViewController(withIdentifier: "SetPasswordViewController") as! SetPasswordViewController
            if (isCorporate == "1") {
                setPassword.isCorporate = true
            }else{
                setPassword.isCorporate = false
            }
             setPassword.userType = "E"
             self.navigationController?.pushViewController(setPassword, animated: true)
            
        }else if(userType == "R"){
            let OTPVarification = OTPVarificationViewController()
            if (isCorporate == "1") {
                OTPVarification.isCorporate = true
            }else{
                OTPVarification.isCorporate = false
            }
            OTPVarification.identifire = "ExitingUser"
            OTPVarification.otpPassword =  password as! String
            self.navigationController?.pushViewController(OTPVarification, animated: true)
        }
    }
    
 
}

extension UIViewController: UITextFieldDelegate{
    func addToolBar(_ textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        //toolBar.barTintColor = UIColor .redColor()
       // toolBar.translucent = false
       // toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.tintColor = KRED_COLOR
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(UIViewController.donePressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIViewController.cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
       // toolBar.backgroundColor = UIColor .redColor()
        textField.delegate = self
        textField.inputAccessoryView = toolBar

    }
    
    func donePressed(){
      //  view.endEditing(true)
         view.window!.endEditing(true)
    }
    func cancelPressed(){
        
       // view.endEditing(true) // or do something
         view.window!.endEditing(true)
    }
}





