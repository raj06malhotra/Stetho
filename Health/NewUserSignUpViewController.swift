//
//  NewUserSignUpViewController.swift
//  Health
//
//  Created by HW-Anil on 6/30/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class NewUserSignUpViewController: UIViewController , XMLParserDelegate ,serverTaskComplete {
    var txtMobileNo = UITextField()
    var mutableData:NSMutableData  = NSMutableData()
    var currentElementName:NSString = ""
    var activityIndicator : ProgressViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        self.createALayout()
        // add activity Indicator 
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    func getAllResponse(allResponse : AnyObject){
//        
//        print(activityIndicator)
//        print(allResponse)
//       // dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), { ()->() in
//          
//                self.activityIndicator?.hidden = true
//                self.activityIndicator?.stop()
//       // })
//        let pwd = allResponse.valueForKey("password")
//        
//        
//        activityIndicator?.hidden = true
//        activityIndicator?.stop()
//        
//        
//        print(pwd)
//        
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func createALayout()  {
        let scrollView:UIScrollView = UIScrollView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height))
        self.view .addSubview(scrollView)
        var yPos: CGFloat = 10;
        
        let logoImageView = BaseUIController().AImageViewFrame(CGRect(x: self.view.center.x-45 , y: yPos , width: 90 , height: 90), withImageName: "app_logo.png")as! UIImageView
        scrollView.addSubview(logoImageView)
        yPos += 110
        txtMobileNo = BaseUIController().ATextFiedlFrame(CGRect(x: 20 ,y:yPos, width: self.view.frame.width - 40 , height: 35 ), withPlaceHolder: "Mobile Number")as! UITextField
        scrollView.addSubview(txtMobileNo)
        txtMobileNo.backgroundColor = UIColor .init(red: (230.0/255.0), green: (231.0/255.0), blue: (232.0/255.0), alpha: 1)
        txtMobileNo.keyboardType = .numberPad
        txtMobileNo.delegate = self
        addToolBar(txtMobileNo)
        
        yPos += 35 + 20
        
        let btnProcess = BaseUIController().AButtonFrame(CGRect(x: 20, y: yPos , width: self.view.frame.width - 40 , height: 35), withButtonTital: "PROCEED")as! UIButton
        btnProcess.backgroundColor = KRED_COLOR
        btnProcess.setTitleColor(UIColor.white, for: UIControlState())
       
        btnProcess.addTarget(self, action: #selector(NewUserSignUpViewController().btnProcessOnClick), for: .touchUpInside)
        scrollView.addSubview(btnProcess)
    }
    //validate PhoneNumber
    
    func btnProcessOnClick()  {
        txtMobileNo.resignFirstResponder()
        if (txtMobileNo.text?.isEmpty == true) {
            self.present(BaseUIController().showAlertView("Please Enter Mobile Number!"), animated: true, completion: nil)
        }else{
            if self.phoneNumberValidation(txtMobileNo.text!) == true {
                
                self.hitAWebServices()
                
            }else{
                self.present(BaseUIController().showAlertView("Please Enter Valide Mobile Number!"), animated: true, completion: nil)
            }
            
        }
        
    }
    func phoneNumberValidation(_ value: String) -> Bool {
        let mobileNumberPattern: String = "[789][0-9]{9}"
        let mobileNumberPred: NSPredicate = NSPredicate(format: "SELF MATCHES %@", mobileNumberPattern)
        let matched: Bool = mobileNumberPred.evaluate(with: value)
        return matched
    }
    
    func hitAWebServices()  {
        
        print(Reachability.isConnectedToNetwork())
        
        if Reachability.isConnectedToNetwork() == true {
            
            activityIndicator!.start()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let allParameters = ["mobileNo":txtMobileNo.text!, "appVersion":appDelegate.appVersion,"mobileName":UIDevice.current.modelName]
//            ServerConnectivity().callWebservice(allParameters, resulttagname: "CheckUserLogin_NewResult")
            ServerConnectivity().callWebservice(allParameters, resulttagname: "CheckUserLogin_NewResult", methodname: "CheckUserLogin_New", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
       
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String){
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                
                
                if  allResponse is String {
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }else{
                    self.jsonResponseData(allResponse)
                }
                
            });
        });
        
    }

    func jsonResponseData(_ josnResponseData : AnyObject)  {
        let arr = josnResponseData as! NSArray
        let id = (arr[0] as! NSDictionary).value(forKey: "id")
        print(id)
        let name = (arr[0] as! NSDictionary).value(forKey: "name")
        print(name)
        let password = (arr[0] as! NSDictionary).value(forKey: "password")
        print(password)
        let userType = (arr[0] as! NSDictionary).value(forKey: "type")as! String
        
        
        let defaults = UserDefaults.standard
        defaults.setValue(name, forKey: "userName")
        defaults.setValue(password, forKey: "password")
        defaults.setValue(id, forKey: "loginCustomerId")
        
        let defaults2 = UserDefaults.standard.value(forKey: "password")
        print(defaults2)
        
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        
        if userType == "N"  {
            let OTPVarification = OTPVarificationViewController()
            OTPVarification.otpPassword =  password as! String
            self.navigationController?.pushViewController(OTPVarification, animated: true)
            
        }else if(userType == "E"){
            let setPassword = storyboard1.instantiateViewController(withIdentifier: "SetPasswordViewController") as! SetPasswordViewController
            setPassword.userType = "E"
            self.navigationController?.pushViewController(setPassword, animated: true)
            
        }else if(userType == "R"){
            let setPassword = storyboard1.instantiateViewController(withIdentifier: "SetPasswordViewController") as! SetPasswordViewController
            setPassword.userType = "R"
            self.navigationController?.pushViewController(setPassword, animated: true)
        }
    }
}


