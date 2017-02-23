//
//  ForgotPasswordViewController.swift
//  Health
//
//  Created by HW-Anil on 6/15/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController,serverTaskComplete {
    
    // MARK: - VariableDeclration

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRePassword: UITextField!
    var activityIndicator : ProgressViewController?
  
    // MARK: - ViewLifeCycleMethods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //call popup method 
       // [self .CreateRecoveryPopup()]
        
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        
        txtPassword.keyboardType = .numberPad
        addToolBar(txtPassword)
        txtRePassword.keyboardType = .numberPad
        addToolBar(txtRePassword)
        txtPassword.frame = CGRect(x: txtPassword.frame.origin.x, y: txtPassword.frame.origin.y, width: txtPassword.frame.width,height: 40)
        txtRePassword.frame = CGRect(x: txtRePassword.frame.origin.x, y: txtRePassword.frame.origin.y, width: txtRePassword.frame.width,height: 40)
        self.title = "FORGOT PASSWORD"
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - buttonOnClick
    
    @IBAction func btnChangePasswordOnClick(_ sender: AnyObject) {
        if (txtPassword.text?.isEmpty == true || txtPassword.text?.characters.count != 4){
            self.present(BaseUIController().showAlertView("Please Enter 4 digit Password!"), animated: true, completion: nil)
            
        }else if(txtRePassword.text?.isEmpty == true || txtRePassword.text?.characters.count != 4){
            self.present(BaseUIController().showAlertView("Please Enter 4 digit Re-Password!"), animated: true, completion: nil)
            
        }else if (txtPassword.text != txtRePassword.text){
            self.present(BaseUIController().showAlertView("Sorry, the password you entered does not match!"), animated: true, completion: nil)
            
        }else{
            self.hitAWebServices()
            
        }
    }
    
    func barButtonBackClick(_ barButton : UIBarButtonItem)  {
   
        let _ = self.navigationController?.popViewController(animated: true)
    
    }

    
  /*     func CreateRecoveryPopup()  {
      
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
       // blurEffectView.backgroundColor = UIColor .yellowColor()
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        view.addSubview(blurEffectView)
        
        
        //show popup on view
          let popUpView: UIView = UIView(frame: CGRect(x: 10, y: 150, width: self.view.bounds.width-20, height: 300.00));
        popUpView.backgroundColor = UIColor .grayColor()
        popUpView.backgroundColor = UIColor .redColor()
        self.view .addSubview(popUpView)
        //add controller on PopupView
        
        let successImageView:UIImageView = UIImageView(frame: CGRect(x: self.view.bounds.midX-40, y: 40, width: 80, height: 80))
        successImageView.backgroundColor = UIColor .yellowColor()
        popUpView .addSubview(successImageView)
        
        
        let lbl_1:UILabel = UILabel(frame: CGRect(x: 20, y: 120, width: self.view.bounds.width-40, height:21))
        lbl_1.text = "Recovery Succeful"
        lbl_1.textAlignment = NSTextAlignment.Center
        popUpView .addSubview(lbl_1)
        
        let lbl_2:UILabel = UILabel(frame: CGRect(x: 20, y: 160, width: self.view.bounds.width-40, height:60))
        lbl_2.text = "You may login to Hindustan Wellness app or website using your new password."
        lbl_2.numberOfLines = 0
        lbl_2.textAlignment = NSTextAlignment.Center
        lbl_2.font = lbl_1.font.fontWithSize(12)
        popUpView .addSubview(lbl_2)
        
        let btnGotit:UIButton = UIButton(frame: CGRect(x: 20, y: 250, width: popUpView.bounds.width-40, height: 40))
        btnGotit.setTitle("Got It!", forState: UIControlState.Normal)
        btnGotit.backgroundColor = UIColor .cyanColor()
        popUpView .addSubview(btnGotit)
        
        
        
        
        
        
        //let popupView: UIView = UIView(frame: c)
        
        
    }  */
    
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
        return newString.length <= maxLength
    }
    
   // MARK: - KeyboardShow&Hide
    func keyboardWillShow(_ notification:Notification){
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 100)
    }
    
    func keyboardWillHide(_ notification:Notification){
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height-60)
      
    }
    //MARK: - CallWebService
    func hitAWebServices()  {
        if Reachability.isConnectedToNetwork() == true {
            
            activityIndicator?.start()
            let mobileNo = UserDefaults.standard.value(forKey: "mobileNo")as! String
            let allParameters = ["number":mobileNo, "password":txtPassword.text!]
            
            ServerConnectivity().callWebservice(allParameters, resulttagname: "ChangePasswordResult" ,methodname: "ChangePassword", className: self)
            
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String){
       
       // print(allResponse)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if allResponse as! String == "1" {
                    self.navigationController?.popToRootViewController(animated: true)
                    
                }else{
                    
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                
                }
                
            });
        });

        
    }
}
