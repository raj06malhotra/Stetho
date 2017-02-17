//
//  MyOrderDetailsViewController.swift
//  Health
//
//  Created by HW-Anil on 8/12/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class MyOrderDetailsViewController: UIViewController , UITableViewDataSource , UITableViewDelegate  ,serverTaskComplete{
    var orderDetailsTableView = UITableView()
    var activityIndicator : ProgressViewController?
    var arrTrackOrderDetails = NSMutableArray()
    var currencySymbol = ""
    var orderId = ""
    var btnEdit = UIButton()
    var orderCancelStatus = ""
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
       // self.navigationController!.navigationBar.topItem!.title = "Back"
        self.view.backgroundColor = UIColor.white
        orderDetailsTableView = UITableView(frame:CGRect(x: 10, y: 0,width: (UIScreen.main.bounds.width) - 20, height: UIScreen.main.bounds.height))
        orderDetailsTableView.backgroundColor = UIColor.white
        
        orderDetailsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(orderDetailsTableView)
        orderDetailsTableView.tableFooterView = UIView()
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        orderDetailsTableView.addSubview(activityIndicator!)
        // get currency sysmbol
//        let currencyCode = "INR"
//        let localeComponents = [NSLocale.Key.currencyCode: currencyCode]
//        let localeIdentifier = Locale.localeIdentifier(fromComponents: localeComponents as! [String : String])
//        let locale = Locale(localeIdentifier: localeIdentifier)
//        currencySymbol = (locale as NSLocale).object(forKey: NSLocale.Key.currencySymbol) as! String
        
        currencySymbol = (Locale(identifier:"de") as NSLocale).displayName(forKey: .currencySymbol, value: "INR")!
        
        // add edit button on tableview
        btnEdit = (BaseUIController().AButtonFrame(CGRect(x: orderDetailsTableView.frame.width - 40, y: 20, width: 30, height: 30), withButtonTital: "")as? UIButton)!
        btnEdit.isHidden = true
        btnEdit.setImage(UIImage(named: "edit_black_icon.png"), for: UIControlState())
        btnEdit.addTarget(self, action: #selector(MyOrderDetailsViewController.btnEditOnClick(_:)), for: .touchUpInside)
        orderDetailsTableView.addSubview(btnEdit)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "ORDER DETAILS"
       // self.navigationController!.navigationBar.topItem!.title = "Back";
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack
        
        self.getOrderDetails()
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("TarckOrderDetails Screen")
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - TableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
       
       let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
            cell.textLabel?.font  = UIFont().regularMediumFont
            cell.textLabel?.textColor = UIColor .init(red: (109.0/255.0), green: (109.0/255.0), blue: (109.0/255.0), alpha: 1)
        cell.selectionStyle = .none
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.font  = UIFont().smallFont
        
        switch (indexPath as NSIndexPath).row {
        case 0:
           cell.textLabel?.text = "Oder Id"
           cell.detailTextLabel?.text = (arrTrackOrderDetails[0] as AnyObject).value(forKey: "o_number")as? String
        case 1:
            cell.textLabel?.text = "Date & Time"
            cell.detailTextLabel?.text = String(format: "%@  %@",(arrTrackOrderDetails[0] as AnyObject).value(forKey: "o_date")as! String,(arrTrackOrderDetails[0] as AnyObject).value(forKey: "o_time")as! String)
        case 2:
            cell.textLabel?.text = "Test Details"
            cell.detailTextLabel?.text = (arrTrackOrderDetails[0] as AnyObject).value(forKey: "product_name")as? String
        case 3:
            cell.textLabel?.text = "Order Amount"
            cell.detailTextLabel?.text = String(currencySymbol + String(describing: (arrTrackOrderDetails[0] as! NSDictionary).value(forKey: "o_net_payable")!) + "/-")
            
        case 4:
            cell.textLabel?.text = "Pickup Address"
            cell.detailTextLabel?.text = (arrTrackOrderDetails[0] as AnyObject).value(forKey: "pickupaddress")as? String
        default: break
            
        }
            
        
            
       
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath as NSIndexPath).row == 4 {
            return 100
        }else{
           return  60
        }
        
    }
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
//    {
//        return 10;
//    }
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
//    {
//        let headerView = UIView(frame: CGRectMake(0, 1, tableView.bounds.size.width, 8))
//        headerView.backgroundColor = UIColor.clearColor()
//        return headerView
//    }
    func getOrderDetails() {
        if (Reachability.isConnectedToNetwork() == true) {
            self.activityIndicator?.start()
            let allParameters = ["orderId" : self.orderId]
            ServerConnectivity().callWebservice(allParameters , resulttagname: "GetOrderDetailsResult" ,methodname: "GetOrderDetails", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
      //  print(allResponse)
//        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if allResponse is String &&  allResponse as! String == "" {
                    self.present(BaseUIController().showAlertView("No Details"), animated: true, completion: nil)
                }else if (allResponse is NSMutableArray ){
                        self.orderDetailsTableView.dataSource = self
                        self.orderDetailsTableView.delegate = self
                        self.arrTrackOrderDetails = allResponse as! NSMutableArray
                        self.orderDetailsTableView.reloadData()
                   self.orderCancelStatus = (self.arrTrackOrderDetails[0] as AnyObject).value(forKey: "ordercancelstatus")as! String
                    if self.orderCancelStatus == "1" {
                        self.btnEdit.isHidden = false
                    }else{
                        self.btnEdit.isHidden = true
                    }

                }else {
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }
            });
        }//);
    }
    
    func btnEditOnClick(_ button : UIButton)  {
        let cancel_resheduleVC = Cancel_RecheduleViewController()
        cancel_resheduleVC.orderId = self.orderId
        print((arrTrackOrderDetails[0] as AnyObject).value(forKey: "o_date")as! String)
        print((arrTrackOrderDetails[0] as AnyObject).value(forKey: "o_time")as! String)
        cancel_resheduleVC.order_secheduleTime = String(format: "%@  %@",(arrTrackOrderDetails[0] as AnyObject).value(forKey: "o_date")as! String,(arrTrackOrderDetails[0] as AnyObject).value(forKey: "o_time")as! String)
        cancel_resheduleVC.order_Number = ((arrTrackOrderDetails[0] as AnyObject).value(forKey: "o_number")as? String)!
        self.navigationController?.pushViewController(cancel_resheduleVC, animated: true)
    }
    func barButtonBackClick(_ barButton : UIBarButtonItem)  {
        
            let _ = self.navigationController?.popViewController(animated: true)
    }
}
