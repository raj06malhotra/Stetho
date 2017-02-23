//
//  SetPasswordViewController.swift
//  Health
//
//  Created by HW-Anil on 6/15/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class SetPasswordViewController: UIViewController ,serverTaskComplete {
    var userType = ""
    var activityIndicator : ProgressViewController?
    var isCorporate : Bool!
    
   
    

    @IBOutlet weak var txtSetPassword: UITextField!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnLogin_setPassword: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "LOGIN / SIGN UP"
        
        let attrs = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 15.0),
            NSForegroundColorAttributeName : UIColor (red: (146.0/255.0), green: (146.0/255.0), blue: (146.0/255.0), alpha: 1),
            NSUnderlineStyleAttributeName : 1] as [String : Any]
        let attributedString = NSMutableAttributedString(string:"")
        // button
        let buttonTitleStr = NSMutableAttributedString(string:"Forgot Password?", attributes:attrs)
        attributedString.append(buttonTitleStr)
        btnForgotPassword.setAttributedTitle(attributedString, for: UIControlState())
        if userType == "R" {
            btnForgotPassword.isHidden = true
            btnLogin_setPassword.setTitle("SET PASSWORD", for: UIControlState())
        }
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        
        txtSetPassword.frame = CGRect(x: txtSetPassword.frame.origin.x, y: txtSetPassword.frame.origin.y, width: txtSetPassword.frame.width, height: 40)
        btnLogin_setPassword.frame = CGRect(x: 0, y: self.view.frame.height - 104, width: self.view.frame.width, height: 40)
        txtSetPassword.keyboardType = .numberPad
        addToolBar(txtSetPassword)
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btnLoginOnClick(_ sender: AnyObject) {

        let  password = UserDefaults.standard.value(forKey: "password")as! String
        
        txtSetPassword.resignFirstResponder()
        if txtSetPassword.text?.isEmpty == true || txtSetPassword.text?.characters.count != 4 {
            self.present(BaseUIController().showAlertView("Please Enter 4 digit Password!"), animated: true, completion: nil)
            
        }else if (userType == "R"){
             self.hitAWebServices()
             self.callGetMyFamilyWebservice()
        }else if txtSetPassword.text == password &&  userType == "E" {
            self.callGetMyFamilyWebservice()

        }else{
            self.present(BaseUIController().showAlertView("Wrong Password."), animated: true, completion: nil)
        }
    }
    
    func barButtonBackClick(_ button : UIButton)  {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func loadMainview()  {
        
         AppDelegate.getAppDelegate().loadRecordfromBackground()
        
        // Override point for customization after application launch.
        
      //  let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
       // let mainViewController = storyboard1.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        UserDefaults.standard.set(true, forKey: "shworeportspopup")
        UserDefaults.standard.set(true, forKey: "forceupdate")
        DispatchQueue.main.async(execute: {
            let homeVC = HomeViewController()
            //homeVC.registerDeviceTone()
            let drawerViewController = DrawerViewController()
            let drawerController     = KYDrawerController()
             self.view.window?.backgroundColor = UIColor.white
            drawerController.mainViewController = UINavigationController(
                rootViewController: homeVC
            )
            drawerController.drawerViewController = drawerViewController
     
        /* Customize */
        drawerController.drawerDirection = .left
        drawerController.drawerWidth     = (UIScreen.main.bounds.width-50)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window!.rootViewController = drawerController
        appDelegate.window!.makeKeyAndVisible()
        
               });
        
    }
    
    func pushForCorporateSignup()  {
        // open corporate page if iscoporate (yes) user
      //  dispatch_async(dispatch_get_main_queue()){
            
            let isCorporate = UserDefaults.standard.bool(forKey: "iscorporate")
            if isCorporate  {
                let corporateVC = CorporateViewController()
                corporateVC.isComingfromCheckinBarCode = false
                self.navigationController!.pushViewController(corporateVC, animated: true)
            }
            
       // }

       
    }

    @IBAction func btnForgotPasswordOnClick(_ sender: AnyObject) {
//        let forgotPassword = self.storyboard?.instantiateViewControllerWithIdentifier("ForgotPasswordViewController") as! ForgotPasswordViewController
//        // Take user to SecondViewController
//        self.navigationController?.pushViewController(forgotPassword, animated: true)
        
        let OTPVarification = OTPVarificationViewController()
        OTPVarification.identifire = "forgotpassword"
        self.navigationController?.pushViewController(OTPVarification, animated: true)
        
        
    }
    // MARK: - TextFiedlDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 4
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length == maxLength   {
            txtSetPassword.text = newString as String
            textField.resignFirstResponder()
        }
        return newString.length <= maxLength
    }
    
    // MARK: - webservicesCall
    func hitAWebServices()  {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let defaults = UserDefaults.standard
            let userName = defaults.value(forKey: "userName")as! String
            let mobileNo = defaults.value(forKey: "mobileNo")as! String
           // let password = txtSetPassword.text
            let password = txtSetPassword.text!.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines
            )
            let allParameters = ["mobileNo":mobileNo,"name":userName,"password":password]
            
            ServerConnectivity().callWebservice(allParameters, resulttagname: "Create_User_NewResult" ,methodname: "Create_User_New", className: self)
            
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    func getAllResponse(_ allResponse: AnyObject, methodName: String){
     
     //   print(allResponse)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                
                if(allResponse is String){
                if  (allResponse as! String == "Something went wrong. Please try again."  || allResponse as! String == "error") {
                    
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    
                }
                }else if (methodName == "Create_User_New"){

                }else if(methodName == "GetMyFamily"){
                    var arrResponseData :NSArray?
                    arrResponseData = allResponse as? NSArray
                    // insetData in MyFamily table
                    if arrResponseData?.count != 0 {
                        for var i in (0..<arrResponseData!.count) {
                            
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            let database = appDelegate.openDataBase()
                            do {
                                let member_id = (arrResponseData![i] as AnyObject).value(forKey: "memberid")as! String
                                let MemberName = (arrResponseData![i] as AnyObject).value(forKey: "name")as! String
                                let relation = (arrResponseData![i] as AnyObject).value(forKey: "relation")as! String
                                let memberPhoto = (arrResponseData![i] as AnyObject).value(forKey: "photo")as! String
                                let active = (arrResponseData![i] as AnyObject).value(forKey: "active")as! String
                                let dob = (arrResponseData![i] as AnyObject).value(forKey: "ca_dob")as! String
                                let email = (arrResponseData![i] as AnyObject).value(forKey: "ca_email")as! String
                                let mobileNo = (arrResponseData![i] as AnyObject).value(forKey: "ca_mob")as! String
                                let gender = (arrResponseData![i] as AnyObject).value(forKey: "ca_gender")as! String
                                let verified = (arrResponseData![i] as AnyObject).value(forKey: "verified")as! String
                                
                                let defaults = UserDefaults.standard
                                let customerId = defaults.value(forKey: "loginCustomerId")as! String
                                if member_id == customerId {
                                    let defaults = UserDefaults.standard
                                    defaults.setValue(memberPhoto, forKey: "photo")
                                }
                                
                                try database.executeUpdate("insert into MyFamily (MemberId , MemberName , Relation , MemberPhoto ,MemberEmail,MemberGender,MemberMobileNo, MemberDOB,SyncStatus,Verified,Active) values (?,?,?,?,?,?,?,?,?,?,?)", values: [member_id , MemberName , relation,memberPhoto,email,gender,mobileNo,dob,"Y",verified,active])
                                i += 1
                                
                                
                            } catch let error as NSError {
                                print("failed: \(error.localizedDescription)")
                            }
                            database.close()
                        }
                        
                        UserDefaults.standard.set(true, forKey: "loginstatus")
                        // open corporate page
                        //                let isCorporate = NSUserDefaults.standardUserDefaults().boolForKey("iscorporate")
                        if (self.isCorporate == true) {
                            UserDefaults.standard.set(true, forKey: "iscorporate")
                            self.pushForCorporateSignup()
                        }else{
                            self.loadMainview()
                           
                        }
                        
                    }
                }
                
            });
        });
    }
    
    func callGetMyFamilyWebservice()  {
        if Reachability.isConnectedToNetwork() == true {
             activityIndicator?.start()
            let defaults = UserDefaults.standard
            let memberId = defaults.value(forKey: "loginCustomerId")as! String
            let allParameters = ["customerId":memberId]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetMyFamilyResult" , methodname: "GetMyFamily", className: self)
        }
    }
}
