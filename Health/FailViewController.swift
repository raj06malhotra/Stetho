//
//  FailViewController.swift
//  Stetho
//
//  Created by HW-Anil on 12/6/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class FailViewController: UIViewController,serverTaskComplete {
    var jsondict=NSMutableDictionary()  //Global variable
    var activityIndicator : ProgressViewController?
    var totalamount = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(FailViewController.ResponseNew(_:)), name: NSNotification.Name(rawValue: "JSON_NEW"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "JSON_DICT"), object: nil, userInfo: nil)
        
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.title = "PAYMENT STATUS"
        self.view.backgroundColor = UIColor.white
        self.navigationItem.leftBarButtonItem = barButtonBack;
        
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
       // self.createDeclineView()
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
            
            jsondict = NSMutableDictionary(dictionary: message.object as! NSDictionary)//message.object as! NSMutableDictionary
            
            self.onlinePayment(jsondict)
        }
    }
    @IBAction func tryAgainAction(_ sender: AnyObject) {
        let paymentView: PaymentModeViewController = PaymentModeViewController()
        
        paymentView.paymentAmtString = UserDefaults.standard.object(forKey: "paymentAmtString") as? String
        paymentView.descriptionString = UserDefaults.standard.object(forKey: "descriptionString") as? String
        paymentView.strSaleAmount = UserDefaults.standard.object(forKey: "strSaleAmount") as? String
        paymentView.strCurrency = UserDefaults.standard.object(forKey: "strCurrency") as? String
        paymentView.strDisplayCurrency = UserDefaults.standard.object(forKey: "strDisplayCurrency") as? String
        paymentView.strDescription = UserDefaults.standard.object(forKey: "strDescription") as? String
        paymentView.strBillingName = UserDefaults.standard.object(forKey: "strBillingName") as? String
        paymentView.strBillingAddress = UserDefaults.standard.object(forKey: "strBillingAddress") as? String
        paymentView.strBillingCity = UserDefaults.standard.object(forKey: "strBillingCity") as? String
        paymentView.strBillingState = UserDefaults.standard.object(forKey: "strBillingState") as? String
        paymentView.strBillingPostal = UserDefaults.standard.object(forKey: "strBillingPostal") as? String
        paymentView.strBillingCountry = UserDefaults.standard.object(forKey: "strBillingCountry") as? String
        paymentView.strBillingEmail = UserDefaults.standard.object(forKey: "strBillingEmail") as? String
        paymentView.strBillingTelephone = UserDefaults.standard.object(forKey: "strBillingTelephone") as? String
        paymentView.strDeliveryName = UserDefaults.standard.object(forKey: "strDeliveryName") as? String
        paymentView.strDeliveryAddress = UserDefaults.standard.object(forKey: "strDeliveryAddress") as? String
        paymentView.strDeliveryCity = UserDefaults.standard.object(forKey: "strDeliveryCity") as? String
        paymentView.strDeliveryState = UserDefaults.standard.object(forKey: "strDeliveryState") as? String
        paymentView.strDeliveryPostal = UserDefaults.standard.object(forKey: "strDeliveryPostal") as? String
        paymentView.strDeliveryCountry = UserDefaults.standard.object(forKey: "strDeliveryCountry") as? String
        paymentView.strDeliveryTelephone = UserDefaults.standard.object(forKey: "strDeliveryTelephone") as? String
        paymentView.reference_no = UserDefaults.standard.object(forKey: "reference_no") as? String
        for (i,viewController) in (self.navigationController?.viewControllers)!.enumerated()
//        for (var i = 0; i < self.navigationController?.viewControllers.count; i += 1)
        {
            if(self.navigationController?.viewControllers[i].isKind(of: PaymentModeViewController.self) == true)
            {
               let _ = self.navigationController?.popToViewController(self.navigationController!.viewControllers[i] as! PaymentModeViewController, animated: true)
                break;
            }
        }
    }
    
    @IBAction func cancelClk(_ sender: AnyObject)
    {
        var index: Int = 0
        var status: Bool = false
        //for (var i = 0; i < self.navigationController?.viewControllers.count; i += 1)
        for (i,viewController) in (self.navigationController?.viewControllers.enumerated())!
        {//Below ViewController is the view controller is to navigate on Cancel Button pressed.
            if(self.navigationController?.viewControllers[i].isKind(of: ViewController.self) == true)
            {
                index = i;
                status = true;
            }
        }
        if status
        {
           let _ = self.navigationController?.popToViewController(self.navigationController!.viewControllers[index] as! ViewController, animated: true)
        }
        else
        {
            self.navigationController!.pushViewController(self.navigationController!.viewControllers[index] as! ViewController, animated: false)
        }
    }
    
    func onlinePayment(_ jsonResponse : NSMutableDictionary)  {
        
        if (Reachability.isConnectedToNetwork() == true) {
            self.activityIndicator?.start()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            print(appDelegate.bookedOrderId)
            
            print(jsonResponse.value(forKey: "Amount") as! String)
            
            print(jsonResponse.value(forKey: "PaymentId") as! String)
            
            print(jsonResponse.value(forKey: "DateCreated")as! String)
            
            print(jsonResponse.value(forKey: "PaymentStatus") as! String)
            
            print(jsonResponse.value(forKey: "PaymentMode") as! String)
            
            totalamount = jsonResponse.value(forKey: "Amount") as! String
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
                    
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    
                }else{
                    
                //    print(allResponse)
                    self.createDeclineView()
                    

                }
            });
        });
    }

    
    func barButtonBackClick(_ button : UIButton)  {

    /*    DispatchQueue.main.async(execute: {
            let homeVC = HomeViewController()
            homeVC.isComingFromClass = "paymentFail"
            homeVC.failPaymentAmount = self.totalamount
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
            
         
        }); */
        
//        self.navigationController?.popViewController(animated: true)
        let paymentNavigation = GlobalInfo.sharedInfo.getPaymentNavigation()
        print(self.navigationController!.viewControllers)
        for controller in paymentNavigation.viewControllers {
            if controller.isKind(of: PaymentOptionsViewController.self){
                AppDelegate.getAppDelegate().window?.rootViewController = paymentNavigation
                (controller as! PaymentOptionsViewController).isComingFromClass = "paymentFail"
            paymentNavigation.popToViewController(controller, animated: true)
//                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
    
    func createDeclineView() {
        
        let lblDecline = BaseUIController().ALabelFrame(CGRect(x: 0, y: ((self.view.frame.height)/2 - 55), width: self.view.frame.width,  height: 30), withString: "Decline!")as! UILabel
        lblDecline.font =  UIFont.boldSystemFont(ofSize: 30)
        lblDecline.textAlignment = .center
        lblDecline.textColor = UIColor (red: (80/255), green: (79/255), blue: (79/255), alpha: 1)
        self.view.addSubview(lblDecline)
        
        
        let lblLine = BaseUIController().ALabelFrame(CGRect(x: 20, y: (self.view.frame.height)/2, width: self.view.frame.width - 40, height: 1), withString: "")as! UILabel
        lblLine.backgroundColor = UIColor.gray
        self.view.addSubview(lblLine)
        
        let declineImageView = BaseUIController().AImageViewFrame(CGRect(x: ((self.view.frame.width)/2 - 20), y: ((self.view.frame.height)/2 - 20 ), width: 40, height: 40), withImageName: "verified_no.png")as! UIImageView
        self.view.addSubview(declineImageView)
        
        let lblDelineMessage = BaseUIController().ALabelFrame(CGRect(x: 0, y: (((self.view.frame.height)/2) + 30), width: self.view.frame.width,  height: 30), withString: "Your payment is Decline.")as! UILabel
        lblDelineMessage.font = UIFont().veryLargeFont
        lblDelineMessage.textAlignment = .center
        self.view.addSubview(lblDelineMessage)
        
        let btnBackToStetho = BaseUIController().AButtonFrame(CGRect(x: 0, y: self.view.frame.height - 40, width: self.view.frame.width, height: 40), withButtonTital: "BACK TO STETHO")as! UIButton
        btnBackToStetho.backgroundColor = KRED_COLOR
        btnBackToStetho.setTitleColor(UIColor.white, for: UIControlState())
        btnBackToStetho.addTarget(self, action: #selector(self.barButtonBackClick(_:)), for: .touchUpInside)
        btnBackToStetho.titleLabel?.font = UIFont().regularMediumFont
        self.view.addSubview(btnBackToStetho)
    }

}
