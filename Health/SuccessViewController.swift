//
//  SuccessViewController.swift
//  Stetho
//
//  Created by HW-Anil on 12/6/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController,serverTaskComplete {
    var jsondict=NSMutableDictionary()  //Global variable
    var activityIndicator : ProgressViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(SuccessViewController.ResponseNew(_:)), name: NSNotification.Name(rawValue: "JSON_NEW"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "JSON_DICT"), object: nil, userInfo: nil)
        
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.title = "PAYMENT STATUS"
        self.navigationItem.leftBarButtonItem = barButtonBack;
        
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        self.view.addSubview(activityIndicator!)
        self.activityIndicator?.start()
        

    }
    override func viewWillAppear(_ animated: Bool) {
          self.navigationController!.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Please add the below method to receive the transaction details
    func ResponseNew(_ message: Notification) {
        
        if (message.name.rawValue == "JSON_NEW") {
            
            
            print("Response = %@", message.object)
            
            jsondict = NSMutableDictionary(dictionary: message.object as! NSDictionary)
            //message.object as! NSMutableDictionary
            self.onlinePayment(jsondict)
        }
    }
    
    func onlinePayment(_ jsonResponse : NSMutableDictionary)  {
        
        if (Reachability.isConnectedToNetwork() == true) {
            activityIndicator?.start()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
           
            
            print(appDelegate.bookedOrderId)
            
            print(jsonResponse.value(forKey: "Amount") as! String)
            
             print(jsonResponse.value(forKey: "PaymentId") as! String)
            
            print(jsonResponse.value(forKey: "DateCreated")as! String)
                        
            print(jsonResponse.value(forKey: "PaymentStatus") as! String)
                            
            print(jsonResponse.value(forKey: "PaymentMode") as! String)
            
            print(UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
                
            self.activityIndicator?.start()
           
            var totalamount = jsonResponse.value(forKey: "Amount") as! String
            
            if let dotRange = totalamount.range(of: ".") {
                totalamount.removeSubrange(dotRange.lowerBound..<totalamount.endIndex)
            }
            var payment_status = ""
            
            if (jsonResponse.value(forKey: "PaymentStatus") as! String == "Authorized") {
                payment_status = "1"
            }else{
                payment_status = "0"
            }
            
            
            
            let orderId = appDelegate.bookedOrderId as String
            let paymentId = (jsonResponse.value(forKey: "PaymentId") as! String)
            let amount = (totalamount)
            let paymentDate = (jsonResponse.value(forKey: "DateCreated") as! String)
            let status = (payment_status)
            let paymentMode = (jsonResponse.value(forKey: "PaymentMode") as! String)
            let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            
            let allParameters = ["OrderId" : orderId , "Payment_id": paymentId ,"amount": amount , "Paymentdate" : paymentDate, "status" : status,"PaymentMode": paymentMode , "customerId": customerId]
            
            ServerConnectivity().callWebservice(allParameters , resulttagname: "OnlinePaymentResult" ,methodname: "OnlinePayment", className: self)
            
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
        
        print(allResponse)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if (allResponse is String &&  allResponse as! String == "" || allResponse is String &&  allResponse as! String == "error" || allResponse is String && allResponse as! String == "Something went wrong. Please try again.") {
                    
                    self.present(BaseUIController().showAlertView("your payment has been processed successfully. please contact to Hindustan wellness at 9810981083 "), animated: true, completion: nil)
                    self.createSuccessView()
                    
                }else{
                    
                 //   print(allResponse)
                    self.createSuccessView()
                    
                }
            });
        });
    }

    
    func createSuccessView()  {
        
            
            let lblSuccess = BaseUIController().ALabelFrame(CGRect(x: 0, y: ((self.view.frame.height)/2 - 55), width: self.view.frame.width,  height: 30), withString: "Success!")as! UILabel
            lblSuccess.font =  UIFont.boldSystemFont(ofSize: 30)
            lblSuccess.textAlignment = .center
            lblSuccess.textColor = UIColor (red: (80/255), green: (79/255), blue: (79/255), alpha: 1)
            self.view.addSubview(lblSuccess)
        
            let lblLine = BaseUIController().ALabelFrame(CGRect(x: 20, y: (self.view.frame.height)/2, width: self.view.frame.width - 40, height: 1), withString: "")as! UILabel
            lblLine.backgroundColor = UIColor.gray
            self.view.addSubview(lblLine)
        
          let successImageView = BaseUIController().AImageViewFrame(CGRect(x: ((self.view.frame.width)/2 - 20), y: ((self.view.frame.height)/2 - 20 ), width: 40, height: 40), withImageName: "verified_yes.png")as! UIImageView
          self.view.addSubview(successImageView)
        
            let lblSuccessMessage = BaseUIController().ALabelFrame(CGRect(x: 0, y: ((self.view.frame.height)/2 + 20), width: self.view.frame.width,  height: 30), withString: "Your payment is successful.")as! UILabel
            lblSuccessMessage.font = UIFont().veryLargeFont
            lblSuccessMessage.textAlignment = .center
            self.view.addSubview(lblSuccessMessage)
            
            let btnDone = BaseUIController().AButtonFrame(CGRect(x: 0, y: self.view.frame.height - 40, width: self.view.frame.width, height: 40), withButtonTital: "DONE")as! UIButton
            btnDone.backgroundColor = KRED_COLOR
            btnDone.setTitleColor(UIColor.white, for: UIControlState())
            btnDone.addTarget(self, action: #selector(self.barButtonBackClick(_:)), for: .touchUpInside)
            btnDone.titleLabel?.font = UIFont().veryLargeFont
            self.view.addSubview(btnDone)
        

    }
    
    func barButtonBackClick(_ button : UIButton)  {
        
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

    
 
}
