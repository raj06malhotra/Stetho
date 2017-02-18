//
//  OrderBookedViewController.swift
//  Health
//
//  Created by HW-Anil on 8/16/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class OrderBookedViewController: UIViewController {
    let fontSize = UIFont().mediumFont
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.createALayoutView()
        //set Tital
        self.title = "ORDER BOOKED"
       
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;
       
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("OrderBooked Screen")
    }
    
    func barButtonBackClick(_ button : UIButton)  {
        for controller in self.navigationController!.viewControllers as Array {
            print(controller)
            if controller.isKind(of: HomeViewController.self) {
                self.navigationController?.navigationBar.isTranslucent = true
                self.navigationController?.popToViewController(controller as UIViewController, animated: true)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func createALayoutView()  {
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.view.addSubview(scrollView)
        var yPos : CGFloat = 20
        
        let imageView = BaseUIController().AImageViewFrame(CGRect(x: self.view.center.x - 30,y: yPos, width: 60, height: 60), withImageName: "menu_orders.png")as! UIImageView
        scrollView.addSubview(imageView)
        yPos += 40 + 20
        let label1 = BaseUIController().ALabelFrame(CGRect(x: 10, y: yPos, width: self.view.frame.width - 20 , height: 50), withString: "")as! UILabel
        label1.text = "Order Booked Successfully! \n Hindustan Wellness team will get in touch with you shortly to confirm rest of the details."
        label1.textAlignment = .center
//        let multiColorTextAttributeString = self.changeTextWithMultipleColor("Order Booked Successfully! \n", blackString: "\n Hindustan Wellness team will get in touch with you shortly to confirm rest of the details.")
//        
//        label1.attributedText = multiColorTextAttributeString
//
        
        label1.font = fontSize
        scrollView.addSubview(label1)
        yPos += 50 + 10
        let label2 = BaseUIController().ALabelFrame(CGRect(x: 10, y: yPos, width: self.view.frame.width - 20 , height: 20), withString: "Instructions:")as! UILabel
        label2.font = UIFont().regularMediumFont
        label2.textColor = KRED_COLOR
       // label2.backgroundColor = UIColor .yellowColor()
        scrollView.addSubview(label2)
        yPos += 20 + 10
        
        let label3 = BaseUIController().ALabelFrame(CGRect(x: 10, y: yPos, width: self.view.frame.width - 20 , height: 160), withString: "Instructions:")as! UILabel
        label3.font = fontSize
        label3.textAlignment = .left
        //label3.backgroundColor = UIColor.blueColor()
        scrollView.addSubview(label3)
        label3.text = "No alcohal intake is permutted 48 hours prior to your appointment. \n \n if you are on medicaiton , kindly display the course/Prescription of the medication. \n \n Test might require at least 12-24 hours of fasting prior to your scheduled appointment. However you may drink plain water "
        yPos += 160 + 20
        let btnTrackOrder = BaseUIController().AButtonFrame(CGRect(x: 10, y: yPos, width: self.view.frame.width - 20, height: 30), withButtonTital: "TRACK ORDER")as! UIButton
        btnTrackOrder.layer.masksToBounds = true
        btnTrackOrder.layer.borderWidth = 1
        btnTrackOrder.layer.borderColor = KRED_COLOR.cgColor
        btnTrackOrder.layer.cornerRadius = 3
        btnTrackOrder.titleLabel?.font = fontSize
        btnTrackOrder.titleLabel?.textColor = KRED_COLOR
        btnTrackOrder.addTarget(self, action: #selector(OrderBookedViewController.btnTrackOrderOnClick(_:)), for: .touchUpInside)
        scrollView.addSubview(btnTrackOrder)
        
        
        
    }
    func btnTrackOrderOnClick(_ button : UIButton)  {
        let myOrderVC = MyOrderViewController()
        myOrderVC.isComingFrom = "orederbooked"
        self.navigationController?.pushViewController(myOrderVC, animated: true)
        
        
    }
    
    //MARK: chageWihtMultipleTextAttributeColor
    func changeTextWithMultipleColor(_ orangeString : String , blackString : String) -> NSMutableAttributedString {
        
        let attrs1      = [NSFontAttributeName: UIFont().smallFont, NSForegroundColorAttributeName:UIColor.orange]
        let attrs2      = [NSFontAttributeName: UIFont().smallFont, NSForegroundColorAttributeName: UIColor.black]
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: blackString , attributes:  attrs1))
        attributedText.append(NSAttributedString(string: orangeString, attributes: attrs2))
        return attributedText
    }
    

   

}
