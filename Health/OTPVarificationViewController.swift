//
//  OTPVarificationViewController.swift
//  Health
//
//  Created by HW-Anil on 6/15/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class OTPVarificationViewController: UIViewController , UITextViewDelegate , serverTaskComplete{
    //MARK: - VariableDeclaration
    var textView: UITextView = UITextView()
    var scrollView:UIScrollView = UIScrollView()
    var activityIndicator : ProgressViewController?
    var otpPassword: String = ""
    var identifire: String = ""
    var txtOTP1 = UITextField()
    var txtOTP2 = UITextField()
    var txtOTP3 = UITextField()
    var txtOTP4 = UITextField()
    var txtOTP5 = UITextField()
    var txtOTP6 = UITextField()
    var isCorporate : Bool!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // set background color of view 
        self.view.backgroundColor = UIColor.white
//        [self .createALayout()]
        self.createALayout()
        
        // text field 
            
        txtOTP1 = scrollView.viewWithTag(100) as! UITextField
        txtOTP2 = scrollView.viewWithTag(101) as! UITextField
        txtOTP3 = scrollView.viewWithTag(102) as! UITextField
        txtOTP4 = scrollView.viewWithTag(103) as! UITextField
        txtOTP5 = scrollView.viewWithTag(104) as! UITextField
        txtOTP6 = scrollView.viewWithTag(105) as! UITextField
        
        if identifire == "forgotpassword" {
            activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
            // self.view.addSubview(activityIndicator!) Comment Progress
            self.hitAWebServices()
             self.title = "FORGOT PASSWORD"
        }else{
             self.title = "LOGIN / SIGN UP"
        }
        
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func createALayout()  {
        
     
        var xPos: CGFloat = (self.view.frame.size.width - 240)/2
        var yPos: CGFloat = 20 + 64
        
        
//        let lbl_1: UILabel = UILabel(frame: CGRect(x: 20, y: 100, width: self.view.bounds.width-40, height: 30.00));
//        lbl_1.text = "ENTER VERIFICATION CODE"
//        //lbl_1.textColor = UIColor (red: (146.0/255.0), green: (146.0/255.0), blue: (146.0/255.0), alpha: 1)
//        lbl_1.textAlignment = NSTextAlignment.Center;
//        self.view.addSubview(lbl_1)
//        
//        let lbl_2: UILabel = UILabel(frame: CGRect(x: 20, y: 100+30, width: self.view.bounds.width-40, height: 30.00));
//        lbl_2.text = "The code has been sent your on mobile number "
//        lbl_2.textColor = UIColor (red: (146.0/255.0), green: (146.0/255.0), blue: (146.0/255.0), alpha: 1)
//        lbl_2.textAlignment = NSTextAlignment.Center;
//        lbl_2.font = lbl_2.font.fontWithSize(12)
//        self.view.addSubview(lbl_2)
        
        let logoImageView = BaseUIController().AImageViewFrame(CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-40), withImageName: "bg_login")as! UIImageView
        
        self.view.addSubview(logoImageView)
        
        scrollView = UIScrollView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height))
        self.view .addSubview(scrollView)
        
        
        
        let otpMessages = "One Time Password(OTP) has been sent to the provided mobile number."
        
        let lblOTPMessages = BaseUIController().ALabelFrame(CGRect(x: 20 , y: yPos ,width: self.view.frame.width - 40, height: 60), withString: otpMessages)as! UILabel
        lblOTPMessages.numberOfLines = 0
        lblOTPMessages.textColor = UIColor (red: (146.0/255.0), green: (146.0/255.0), blue: (146.0/255.0), alpha: 1)
        lblOTPMessages.textAlignment = NSTextAlignment.center;
        lblOTPMessages.font = UIFont(name: "Roboto-Light", size: 18.0)//.regularMediumFont
        
        
        scrollView.addSubview(lblOTPMessages)
        
        yPos += 60 + 20
       
        
        for i in (0..<6) {
            

            
            
            let txtField: UITextField = UITextField(frame: CGRect(x: xPos, y: yPos, width: 24.00, height: 24.00));
            scrollView.addSubview(txtField)
            txtField.borderStyle = UITextBorderStyle.none
            txtField.layer.cornerRadius = 12;
            txtField.layer.masksToBounds = true
            txtField.delegate = self
            txtField.keyboardType = .numberPad
            addToolBar(txtField)
            txtField.tag = 100 + i
            txtField.textAlignment = .center
            txtField.backgroundColor = UIColor.darkGray//UIColor (red: (230.0/255.0), green: (231.0/255.0), blue: (232.0/255.0), alpha: 1)
            xPos += 40
            
            
//            let lbl_3: UILabel = UILabel(frame: CGRect(x: 20, y: 250, width: self.view.bounds.width-40, height: 60.00));
//            lbl_3.textAlignment = NSTextAlignment.Center;
//            lbl_3.numberOfLines=0
//            lbl_3.font = lbl_3.font.fontWithSize(12)
            
      
        }
        
      /*  textView = UITextView(frame: CGRect(x: 20, y: 250, width: self.view.bounds.width-40, height: 60))
        textView.delegate=self
        textView.editable = false
        
        
        
        let attributedString = NSMutableAttributedString(string: "If you've not received the code, Click here to receive")
        
        attributedString.addAttribute(NSLinkAttributeName, value: "Click here", range: NSRange(location: 33, length: 10))
        
        let linkAttributes = [
            NSForegroundColorAttributeName: KRED_COLORColor(),
            // NSUnderlineColorAttributeName: KRED_COLORColor(),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue ]
        
        // let str: String = "If you've not received the code, Click here to receive"
        // lbl_3.attributedText = attributedString
        textView.attributedText = attributedString
        textView.linkTextAttributes = linkAttributes
        
        
        
        // lbl_2.text = "If you've not received the code, Click here to receive"
        //lbl_2.textAlignment = NSTextAlignment.Center;
        // lbl_2.font = lbl_2.font.fontWithSize(12)
        
        // self.view.addSubview(lbl_3)
        self.view.addSubview(textView)
        
        
        // add tap gesture on textView
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OTPVarificationViewController.textViewTapped(_:)));
        gestureRecognizer.numberOfTapsRequired = 1;
        gestureRecognizer.numberOfTouchesRequired = 1;
        self.textView.addGestureRecognizer(gestureRecognizer); */
        yPos += 100 + 24
//        let logoImageView = BaseUIController().AImageViewFrame(CGRectMake(0, self.view.frame.height - (40 + 210 + 64), self.view.frame.width, 210), withImageName: "app_slide_login.jpg")as! UIImageView
        
        
        
        
        let btnVerify_Continue: UIButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.height - 40, width: self.view.bounds.width, height: 40));
        btnVerify_Continue.setTitle("VERIFY AND CONTINUE", for: UIControlState())
        btnVerify_Continue.backgroundColor = KRED_COLOR
        btnVerify_Continue.titleLabel?.font = UIFont (name: "Roboto-Regular", size: 15)
//        btnVerify_Continue.layer.masksToBounds = true
//        btnVerify_Continue
        btnVerify_Continue.addTarget(self, action: #selector(OTPVarificationViewController().btnVarify_ContinueOnClick), for: .touchUpInside)
        self.view.addSubview(btnVerify_Continue)
        
        
    }
    //MARK: - TextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 1
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if(textField.text?.isEmpty == true || textField.text?.characters.count == 0){
            
       
        if (textField == txtOTP1) {
            if (maxLength == 1) {
                txtOTP1.text = newString as String
                txtOTP2.becomeFirstResponder()
                return false; // NO because we already updated the text.
            }
        }
        
        if (textField == txtOTP2) {
            if (maxLength == 1) {
                txtOTP2.text = newString as String
                txtOTP3.becomeFirstResponder()
                return false;
            }
        }
        if (textField == txtOTP3) {
            if (maxLength == 1) {
                txtOTP3.text = newString as String
                txtOTP4.becomeFirstResponder()
                return false;
            }
        }
        if (textField == txtOTP4) {
            if (maxLength == 1) {
                txtOTP4.text = newString as String
                txtOTP5.becomeFirstResponder()
                return false;
            }
        }
        if (textField == txtOTP5) {
            if (maxLength == 1) {
                txtOTP5.text = newString as String
                txtOTP6.becomeFirstResponder()
                return false;
            }
        }
        }
        
        return newString.length <= maxLength
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.openURL(URL)
        return false
    }
    
    func textViewTapped(_ sender: UITapGestureRecognizer) {
        let wordTarget = "Click here";
        
        let word = UITextView.getWordAtPosition(sender.location(in: self.textView), textView: self.textView);
        if word == wordTarget {
            let plainString = self.textView.attributedText.string;
            let substrings = NSMutableArray();
            let scanner = Scanner(string: plainString);
            scanner.scanUpTo("#", into: nil);
            while !scanner.isAtEnd {
                var substring:NSString? = nil;
                scanner.scanString("#", into: nil);
                let space = " ";
                if scanner.scanUpTo(space, into: &substring) {
                    // If the space immediately followed the #, this will be skipped
                    substrings.add(substring!);
                }
                scanner.scanUpTo("#", into: nil);
                //Scan all characters before next #
            }
            print(substrings.description);
            //Now you got your substrings in an array, so use those for your data passing (in a segue maybe?)
           
            
        }
    
    
}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func btnVarify_ContinueOnClick()  {
        
        
//        let txtOTP1: UITextField = scrollView.viewWithTag(100) as! UITextField
//        let txtOTP2: UITextField = scrollView.viewWithTag(101) as! UITextField
//        let txtOTP3: UITextField = scrollView.viewWithTag(102) as! UITextField
//        let txtOTP4: UITextField = scrollView.viewWithTag(103) as! UITextField
//        let txtOTP5: UITextField = scrollView.viewWithTag(104) as! UITextField
//        let txtOTP6: UITextField = scrollView.viewWithTag(105) as! UITextField
        
        if ((txtOTP1.text?.isEmpty == true) || (txtOTP2.text?.isEmpty == true) || (txtOTP3.text?.isEmpty == true) || (txtOTP4.text?.isEmpty == true) || (txtOTP5.text?.isEmpty == true) || (txtOTP6.text?.isEmpty == true)) {
            self.present(BaseUIController().showAlertView("Please fill OTP!"), animated: true, completion: nil)          
        }else{
            let otpMessages = txtOTP1.text! + txtOTP2.text! + txtOTP3.text! + txtOTP4.text! + txtOTP5.text! + txtOTP6.text!
            print(otpMessages)
            if otpMessages == otpPassword {
                if identifire == "forgotpassword" {
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let forgotPassword = storyBoard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
                    self.navigationController?.pushViewController(forgotPassword, animated: true)
                } else if(identifire == "ExitingUser"){
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    
                    let setPassword = storyBoard.instantiateViewController(withIdentifier: "SetPasswordViewController") as! SetPasswordViewController //self.storyboard?.instantiateViewControllerWithIdentifier("SetPasswordViewController") as! SetPasswordViewController
                    setPassword.isCorporate = isCorporate
                    setPassword.userType = "R"
                    self.navigationController?.pushViewController(setPassword, animated: true)
                }
                else
                {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let signUp = storyBoard.instantiateViewController(withIdentifier: "registerVC") as! RegisterViewController
                self.navigationController?.pushViewController(signUp, animated: true)
                }
            }else{
                 self.present(BaseUIController().showAlertView("Please fill Correct OTP!"), animated: true, completion: nil)
                
            }
        }
    }
    func barButtonBackClick(_ button : UIButton)  {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func hitAWebServices()  {
        if Reachability.isConnectedToNetwork() == true {
            
            activityIndicator?.start()
            let mobileNo = UserDefaults.standard.value(forKey: "mobileNo")as! String
            let allParameters = ["number":mobileNo]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "VerifyNumberResult" ,methodname: "VerifyNumber", className: self)
            
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String){
        otpPassword = allResponse as! String
        
//        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                
            });
        }//);
       
    }
    


}

extension UITextView {
    class func getWordAtPosition(_ position: CGPoint!, textView: UITextView!) -> String? {
        //Remove scrolloffset
        let correctedPoint = CGPoint(x: position.x, y: textView.contentOffset.y + position.y);
        //Get location in text from uitextposition at a certian point
        let tapPosition = textView.closestPosition(to: correctedPoint);
        //Get word at the position, will return nil if its empty.
        let wordRange = textView.tokenizer.rangeEnclosingPosition(tapPosition!, with: UITextGranularity.word, inDirection: UITextLayoutDirection.right.rawValue);
        return textView.text(in: wordRange!);
    }
}


