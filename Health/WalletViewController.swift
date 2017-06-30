//
//  WalletViewController.swift
//  Stetho
//
//  Created by HW-Anil on 11/15/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class WalletViewController: UIViewController {
    var lblreferalCode = UILabel()
    var textColor : UIColor = UIColor (red: (72/255), green: (72/255), blue: (72/255), alpha: 1)
     let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        FBEventClass.logEvent("Wallet")

        self.view.backgroundColor = UIColor.white
        self.title =  "WALLET"
        self.createALayout()
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("Wallet Screen")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func createALayout()  {
        var yPox : CGFloat = 0
        var xPox : CGFloat = 0
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.view.addSubview(scrollView)
        let lblShareMessage = BaseUIController().ALabelFrame(CGRect(x: 30, y: 30, width: self.view.frame.width - 60, height: 70), withString: "Share and Earn! \n Share the Stetho app with a friend and get Rs. 75 in your Stetho on their first purchase.")as! UILabel
        lblShareMessage.textAlignment = .center
        lblShareMessage.textColor = textColor
        scrollView.addSubview(lblShareMessage)
        yPox += 70 + 50
        
        let lblreferalCodeText = BaseUIController().ALabelFrame(CGRect(x: self.view.center.x - 80, y: yPox, width: 160, height: 21), withString: "REFERRAL CODE")as! UILabel
        lblreferalCodeText.textAlignment = .center
        lblreferalCodeText.textColor = KRED_COLOR
        scrollView.addSubview(lblreferalCodeText)
        yPox += 20 + 20
        
        lblreferalCode = BaseUIController().ALabelFrame(CGRect(x: self.view.center.x - 75, y: yPox, width: 150, height: 40), withString: "")as! UILabel
        lblreferalCode.text = UserDefaults.standard.value(forKey: "referal_code")as? String//appDelegate.referralCode
        lblreferalCode.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)!
        lblreferalCode.textAlignment = .center
        lblreferalCode.addDashedBorder()
       // self.setRedTextColor()
        scrollView.addSubview(lblreferalCode)
        yPox += 40 + 30
        let lblShareVia = BaseUIController().ALabelFrame(CGRect(x: self.view.center.x - 75, y: yPox, width: 150, height: 21), withString: "Share via...")as! UILabel
        lblShareVia.textAlignment = .center
        lblShareVia.textColor = textColor
        scrollView.addSubview(lblShareVia)
        yPox += 20 + 5
        xPox = self.view.center.x - 90
        let arrImageName = ["ic_fb","ic_twitter","ic_whatsapp"]
        for i in 0..<arrImageName.count {
//                let shareImageView = BaseUIController().AImageViewFrame(CGRectMake(xPox, yPox, 40, 40), withImageName: arrImageName[i])as! UIImageView
             let button = BaseUIController().AButtonFrame(CGRect(x: xPox, y: yPox, width: 40, height: 40), withButtonTital: "")as! UIButton
            button.setImage(UIImage(named: arrImageName[i]), for: UIControlState())
            button.addTarget(self, action: #selector(self.btnOnClikc(_:)), for: .touchUpInside)
                xPox += 45
            scrollView.addSubview(button)
        }
        
//        let lblMore = BaseUIController().ALabelFrame(CGRectMake(xPox, yPox, 50, 40), withString: "+ MORE")as! UILabel
//        lblMore.textColor = textColor
//        scrollView.addSubview(lblMore)
        let btnMore = BaseUIController().AButtonFrame(CGRect(x: xPox, y: yPox, width: 50, height: 40), withButtonTital: "+ MORE")as! UIButton
        btnMore.addTarget(self, action: #selector(self.btnOnClikc(_:)), for: .touchUpInside)
        btnMore.setTitleColor(textColor, for: UIControlState())
        btnMore.titleLabel?.font = UIFont().mediumFont
        scrollView.addSubview(btnMore)
        
        
        yPox += 60
        let lblLine = BaseUIController().ALabelFrame(CGRect(x: 30, y: yPox, width: self.view.frame.width - 60, height: 1), withString: "")as! UILabel
        lblLine.backgroundColor = UIColor.black
        scrollView.addSubview(lblLine)
        yPox += 50
        let lblWalletBalanceText = BaseUIController().ALabelFrame(CGRect(x: self.view.center.x - 100, y: yPox,width: 200 ,height: 20), withString: "YOUR WALLET BALANCE")as! UILabel
        lblWalletBalanceText.textAlignment = .center
        lblWalletBalanceText.font = UIFont().regularMediumFont
        lblWalletBalanceText.textColor = KRED_COLOR
        scrollView.addSubview(lblWalletBalanceText)
        yPox += 50
        let lblWalletBalance = BaseUIController().ALabelFrame(CGRect(x: self.view.center.x - 100, y: yPox, width: 200, height: 50), withString: "₹566")as! UILabel
        lblWalletBalance.text = "₹ " + String(format: "%@",(UserDefaults.standard.value(forKey: "wallet_balance")as? String)!)
        lblWalletBalance.textAlignment = .center
        lblWalletBalance.textColor = textColor
        lblWalletBalance.font = UIFont(name: "HelveticaNeue-Bold", size: 20.0)!
        scrollView.addSubview(lblWalletBalance)
    }
    func barButtonBackClick(_ button : UIButton)
    {
        self.navigationController?.popViewController(animated: true)
     }
//    func setRedTextColor()  {
//        lblreferalCode.textColor = KRED_COLORColor()
//        let triggerTime = (Int64(NSEC_PER_SEC) * 1)
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
//            self.setBlueTextColor()
//        })
//        
//    }
//    func setBlueTextColor()  {
//        lblreferalCode.textColor = UIColor.blueColor()
//        let triggerTime = (Int64(NSEC_PER_SEC) * 1)
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
//            self.setOrangeTextColor()
//        })
//        
//    }
//    func setOrangeTextColor()  {
//        lblreferalCode.textColor = UIColor.orangeColor()
//        let triggerTime = (Int64(NSEC_PER_SEC) * 1)
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
//            self.setRedTextColor()
//        })
//        
//    }
    func btnOnClikc(_ button: UIButton)  {
        
        let refrralCode = String(describing: UserDefaults.standard.value(forKey: "referal_code")) //appDelegate.referralCode
        
        let msg = "Being healthy made easier Download STETHO app " + "http://onelink.to/gae3x8 and use " + "'"+refrralCode+"'" + " and get 20% off on your first purchase.*T&C."
        let activityViewController = HomeTabSwipeViewController().shareTextImageAndURL(msg, sharingImage: nil, sharingURL: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
