//
//  RegisterViewController.swift
//  Health
//
//  Created by HW-Anil on 6/15/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, XMLParserDelegate , NSURLConnectionDelegate ,serverTaskComplete {
    
    //MARK: - VariableDeclaration

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtMobileNo: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnCreateAnAccount: UIButton!
    
    @IBOutlet weak var txtRePassword: UITextField!
    var activityIndicator : ProgressViewController?
    var mutableData:NSMutableData  = NSMutableData()
    var currentElementName:NSString = ""
    
    //MARK: - ViewLifeCycleMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        // Do any additional setup after loading the view.
        
        txtMobileNo.isUserInteractionEnabled = false
        let mobileNo = UserDefaults.standard.value(forKey: "mobileNo")as! String
        print(mobileNo)
        txtMobileNo.text = mobileNo
        
        // add activity indicator
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        self.view.addSubview(activityIndicator!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        // set height of textField
        var txtMobileNo_frameRect : CGRect = txtMobileNo.frame;
        txtMobileNo_frameRect.size.height = 40 // <-- Specify the height you want here.
        txtMobileNo.frame = txtMobileNo_frameRect
        
        var txtFullName_frameRect : CGRect = txtFullName.frame;
        txtFullName_frameRect.size.height = 40 // <-- Specify the height you want here.
        txtFullName.frame = txtFullName_frameRect
        
        var txtPassword_frameRect : CGRect = txtPassword.frame;
        txtPassword_frameRect.size.height = 40 // <-- Specify the height you want here.
        txtPassword.frame = txtPassword_frameRect
        
        var txtRePassword_frameRect : CGRect = txtRePassword.frame;
        txtRePassword_frameRect.size.height = 40 // <-- Specify the height you want here.
        txtRePassword.frame = txtRePassword_frameRect
        btnCreateAnAccount.frame = CGRect(x: 0, y: self.view.frame.height - 104, width: self.view.frame.width, height: 40)
        self.title = "LOGIN / SIGN UP"
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;
        txtPassword.keyboardType = .numberPad
        addToolBar(txtPassword)
        txtRePassword.keyboardType = .numberPad
        addToolBar(txtRePassword)
        
        txtFullName.autocapitalizationType = .allCharacters

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - ButtonOnClick
    
    @IBAction func btnCreateAnAccountOnClick(_ sender: AnyObject) {
        
        let f_name = txtFullName.text?.trimmingCharacters(in: .whitespaces)
        
        if f_name?.isEmpty == true {
            self.present(BaseUIController().showAlertView("Please Enter Full Name!"), animated: true, completion: nil)
        }else if (txtPassword.text?.isEmpty == true || txtPassword.text?.characters.count != 4){
             self.present(BaseUIController().showAlertView("Please Enter 4 digit Password!"), animated: true, completion: nil)
            
        }else if(txtRePassword.text?.isEmpty == true || txtRePassword.text?.characters.count != 4){
             self.present(BaseUIController().showAlertView("Please Enter 4 digit Re-Password!"), animated: true, completion: nil)
            
        }else if (txtPassword.text != txtRePassword.text){
             self.present(BaseUIController().showAlertView("Sorry, the password you entered does not match!"), animated: true, completion: nil)
            
        }else{
            self.hitAWebServices()
//           self.navigationController?.popToRootViewControllerAnimated(true) 
        }
        
        
    }
    func barButtonBackClick(_ button : UIButton)  {
        let _ = self.navigationController?.popViewController(animated: true)
    }

    //MARK: - TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        return textField.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        
        
        if textField == txtPassword || textField == txtRePassword {
            let maxLength = 4
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length == maxLength && textField == txtPassword   {
                txtPassword.text = newString as String
                textField.resignFirstResponder()
            }
            if newString.length == maxLength && textField == txtRePassword   {
                txtRePassword.text = newString as String
                textField.resignFirstResponder()
            }
            
            return newString.length <= maxLength
        }else{
            let maxLength = 50
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        
        
    }
    //MARK: - CallWebService
    func hitAWebServices()  {
        
        if Reachability.isConnectedToNetwork() {
            
            
           activityIndicator?.start()
           
            let allParameters = ["mobileNo":txtMobileNo.text!,"name":txtFullName.text!,"password":txtPassword.text!]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "Create_User_NewResult" ,methodname: "Create_User_New", className: self)
            
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String){
        
//        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if  (allResponse as! String  == "Something went wrong. Please try again." || allResponse as! String  == "error" ){
                    
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }else{
                  // self.navigationController?.popToRootViewControllerAnimated(true)
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: ViewController.self) {
                           let _ = self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                            break
                        }
                    }
                }
                
            });
        }
        
    }

    //MARK: - KeyboardHide&Show
    func keyboardWillShow(_ notification:Notification){
        
//        var userInfo = notification.userInfo!
//        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
//        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
//        
//        var contentInset:UIEdgeInsets = self.scrollView.contentInset
//        contentInset.bottom = keyboardFrame.size.height
//        self.scrollView.contentInset = contentInset
         scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 100)
    }
    
    func keyboardWillHide(_ notification:Notification){
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height-60)
//        let contentInset:UIEdgeInsets = UIEdgeInsetsZero
//        self.scrollView.contentInset = contentInset
    }
    
    


}
