//
//  MyOrderViewController.swift
//  Health
//
//  Created by HW-Anil on 8/12/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class MyOrderViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , serverTaskComplete{
    
    var trackOrderstableView = UITableView()
    var total = 10
    var isHide : Bool = false
    var isComingFrom = ""
    var scrollView = UIScrollView()
    var activityIndicator : ProgressViewController?
    var arrTrackOrderList = NSMutableArray()
    var arrTrackOrderInfoList = NSMutableArray()
    var arrTrackOrderSelectdList = NSMutableArray()
    var refreshControl: UIRefreshControl!

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white

        // Do any additional setup after loading the view.
        
        trackOrderstableView = UITableView(frame:CGRect(x: 10, y: 0,width: (UIScreen.main.bounds.width) - 20, height: UIScreen.main.bounds.height))
        trackOrderstableView.backgroundColor = UIColor.white
        trackOrderstableView.allowsSelection = false
        self.view.addSubview(trackOrderstableView)
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        trackOrderstableView.tableFooterView = UIView()
        // self.view.addSubview(activityIndicator!) Comment Progress
        
        // add pool to refresh on tableview
        refreshControl = UIRefreshControl()
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(MyOrderViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        trackOrderstableView.addSubview(refreshControl) // not required when using UITableViewController
        

    }
    override func viewWillAppear(_ animated: Bool) {
        self.getOrederList("")
        self.title = "MY ORDERS"
        self.navigationController?.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
        if isComingFrom != "orederbooked" {
             self.addLeftBarButton()
        }else{
            // add back butotn on Navigaiton
            let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
            self.navigationItem.leftBarButtonItem = barButtonBack;
           
        }
        self.navigationController?.navigationBar.tintColor = KRED_COLOR
        self.navigationController?.navigationBar.isTranslucent = true
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("TrackABookingOrder Screen")
        
    }
    func barButtonBackClick(_ button : UIButton)  {
        for controller in self.navigationController!.viewControllers as Array {
        print(controller)
        if controller.isKind(of: HomeViewController.self)
        {
        self.navigationController?.navigationBar.isTranslucent = true
        let _ = self.navigationController?.popToViewController(controller as UIViewController, animated: true)
        }
    }
        
    }
    // MARK: - AddMenuButton
    func addLeftBarButton()  {
        let menuBarButton = UIBarButtonItem(image: UIImage(named: "menu_icon"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(MyFamilyViewController.didTapMenuBarButton(_:)))
        self.navigationItem.leftBarButtonItem = menuBarButton
    }
    
    func didTapMenuBarButton(_ sender: AnyObject) {
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
       //MARK: - TableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isHide == true {
            return arrTrackOrderSelectdList.count
        }else{
            return arrTrackOrderList.count
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier:String = "myOrdersCell"
        var cell:MyOrdersTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MyOrdersTableViewCell
        if (cell == nil)
        {
            var nib:Array = Bundle.main.loadNibNamed("MyOrdersTableViewCell", owner: self, options: nil)!
            cell = nib[0] as? MyOrdersTableViewCell
            cell!.layer.borderWidth = 1
            cell!.layer.cornerRadius = 3
            cell?.layer.masksToBounds = true
            cell!.layer.borderColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1).cgColor
            cell?.btnDetails.addTarget(self, action: #selector(MyOrderViewController.btnDetailsOnClick(_:)), for: .touchUpInside)
            cell?.btnTrackOrder.addTarget(self, action: #selector(MyOrderViewController.btnTrackOrderOnClikc(_:)), for: .touchUpInside)
            cell?.btnTrackFhlebo.addTarget(self, action: #selector(self.btnTrackPhlebo(_:)), for: .touchUpInside)
            cell?.btnPayNow.addTarget(self, action: #selector(self.btnPayNowOnClick(_:)), for: .touchUpInside)
        }
        if isHide  == false {
           // cell?.btnDetails.userInteractionEnabled = true
            let orderDict = arrTrackOrderList.object(at: indexPath.section) as! NSDictionary
            cell?.lblOrderId.text = String(format: "OrderId %@", orderDict.value(forKey: "o_number")as! String)
            cell?.lblPickupTime.text = String(format: "Pickup on  %@ at %@", orderDict.value(forKey: "o_date")as! String,orderDict.value(forKey: "o_time") as! String)
            cell?.lblPackageName.text = orderDict.value(forKey: "product_type")as? String
            cell?.lblSubPackageName.text = orderDict.value(forKey: "product_name")as? String
            // show and hide pay button
            let amount = orderDict.value(forKey: "amount")as! String
            
            cell?.btnPayNow.setTitle("PAY NOW  ₹ " + amount, for: UIControlState())
            
            
            print(orderDict.value(forKey: "paymentstatus")as! String)
            
            
            if (orderDict.value(forKey: "paymentstatus") as! String == "1") {
               cell?.btnPayNow.isHidden = true
            }else{
                cell?.btnPayNow.isHidden = false
            
            }
            
            // show and hide phlebo tracking button
            let pickUpdate = orderDict.value(forKey: "o_date")as! String
            let pickUpTime =  orderDict.value(forKey: "o_time")as! String // "14:30"
            
            let isFleboTracking = self.isLayingBetweenPickupTime(pickUpdate, pickupTime: pickUpTime)
            if isFleboTracking == false {
                cell?.btnTrackFhlebo.isHidden = true
            }else{
                cell?.btnTrackFhlebo.isHidden = false
            }
            print(isFleboTracking)
            
        }else{
            let selectedAddressDict = arrTrackOrderSelectdList.object(at: indexPath.section) as! NSDictionary
            cell?.lblOrderId.text = String(format: "OrderId %@", selectedAddressDict.value(forKey: "o_number") as! String)
            cell?.lblPickupTime.text = String(format: "Pickup on  %@ at %@", selectedAddressDict.value(forKey: "o_date") as! String,selectedAddressDict.value(forKey: "o_time") as! String)
            cell?.lblPackageName.text = selectedAddressDict.value(forKey: "product_type")as? String
            cell?.lblSubPackageName.text = selectedAddressDict.value(forKey: "product_name")as? String
            // show and hide pay button
            if ((selectedAddressDict.value(forKey: "paymentstatus")as! String) == "1")
              {
                cell?.btnPayNow.isHidden = true
            }else{
                cell?.btnPayNow.isHidden = false
                
            }
            // show and hide phlebo tracking button
            let pickUpdate = selectedAddressDict.value(forKey: "o_date")as! String
            let pickUpTime = selectedAddressDict.value(forKey: "o_time")as! String // "13:30"
            
            let isFleboTracking = self.isLayingBetweenPickupTime(pickUpdate, pickupTime: pickUpTime)
            if isFleboTracking == false {
                cell?.btnTrackFhlebo.isHidden = true
            }else{
                cell?.btnTrackFhlebo.isHidden = false
            }
        }
        
        
        
      
        return cell!
    }
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  120;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 10;
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 1, width: tableView.bounds.size.width, height: 8))
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    // MARK: ButtonOnClick
    func btnDetailsOnClick(_ button : UIButton)  {
        let buttonPosition = button.convert(CGPoint.zero, to: self.trackOrderstableView)
        let indexPath = self.trackOrderstableView.indexPathForRow(at: buttonPosition)
        
        let myOrderDetailsVC = MyOrderDetailsViewController()
        if isHide == false {
           myOrderDetailsVC.orderId = (arrTrackOrderList.object(at: (indexPath?.section)!) as! NSDictionary).value(forKey: "o_id")as! String
            //arrTrackOrderList.object(at: ((indexPath as NSIndexPath?)?.section)!).value(forKey: "o_id")as! String
        }else{
//            (arrTrackOrderSelectdList.object(at: (indexPath?.section)!) as! NSDictionary).value(forKey: "o_id")as! String

           myOrderDetailsVC.orderId = (arrTrackOrderSelectdList.object(at: (indexPath?.section)!) as! NSDictionary).value(forKey: "o_id")as! String
            //arrTrackOrderSelectdList.object(at: ((indexPath as NSIndexPath?)?.section)!).value(forKey: "o_id")as! String
        }
        
        self.navigationController?.pushViewController(myOrderDetailsVC, animated: true)
        
        
    }
    func btnTrackPhlebo(_ button : UIButton)  {
        let buttonPosition = button.convert(CGPoint.zero, to: self.trackOrderstableView)
        let indexPath = self.trackOrderstableView.indexPathForRow(at: buttonPosition)
        let trackingVC = TrackingViewController()
        if isHide == false {
            
            trackingVC.orderId = (arrTrackOrderList.object(at: (indexPath?.section)!) as! NSDictionary).value(forKey: "o_id") as! String//arrTrackOrderList.object(at: ((indexPath as NSIndexPath?)?.section)!).value(forKey: "o_id")as! String
        }else{
            trackingVC.orderId = (arrTrackOrderSelectdList.object(at: (indexPath?.section)!) as! NSDictionary).value(forKey: "o_id") as! String
            //arrTrackOrderSelectdList.object(at: ((indexPath as NSIndexPath?)?.section)!).value(forKey: "o_id")as! String
        }
        self.navigationController?.pushViewController(trackingVC, animated: true)
    }
    
    func btnPayNowOnClick(_ button : UIButton)  {
        
        let buttonPosition = button.convert(CGPoint.zero, to: self.trackOrderstableView)
        let indexPath = self.trackOrderstableView.indexPathForRow(at: buttonPosition)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let paymentVC = PaymentOptionsViewController()
        paymentVC.isComingFromClass = "paymentFail"
    //    paymentVC.failPaymentAmount = failPaymentAmount
        if isHide == false {
            let trackOderDict = arrTrackOrderList.object(at: (indexPath?.section)!) as! NSDictionary
           appDelegate.bookedOrderId.append(trackOderDict.value(forKey: "o_id")as! String)
            paymentVC.failPaymentAmount =  trackOderDict.value(forKey: "amount")as! String
        }else{
            let selectedTrackOderDict = arrTrackOrderSelectdList.object(at: (indexPath?.section)!) as! NSDictionary

           paymentVC.failPaymentAmount =  selectedTrackOderDict.value(forKey: "amount")as! String
           appDelegate.bookedOrderId.append(selectedTrackOderDict.value(forKey: "o_id")as! String)
        }
        self.navigationController?.pushViewController(paymentVC, animated: true)
       
    }
    
    func btnTrackOrderOnClikc(_ button : UIButton)  {
        if isHide == true {
            total = 10
            trackOrderstableView.frame = CGRect(x: 10, y: 0, width: (UIScreen.main.bounds.width) - 20, height: UIScreen.main.bounds.height)
            trackOrderstableView.isScrollEnabled = true
            isHide = false
            scrollView.removeFromSuperview()
        }else{
            total = 1
            trackOrderstableView.frame = CGRect(x: 10, y: 0, width: (UIScreen.main.bounds.width) - 20, height: 195)
            trackOrderstableView.isScrollEnabled = false
            isHide = true
            let buttonPosition = button.convert(CGPoint.zero, to: self.trackOrderstableView)
            let indexPath = self.trackOrderstableView.indexPathForRow(at: buttonPosition)
            
            print(indexPath!.section)
            print(indexPath!.row)
            self.getOrderInfo((arrTrackOrderList.object(at: (indexPath?.section)!) as! NSDictionary).value(forKey: "o_id")as! String)
            arrTrackOrderSelectdList = NSMutableArray()
            arrTrackOrderSelectdList.add(arrTrackOrderList.object(at: ((indexPath as NSIndexPath?)?.section)!) as! NSMutableDictionary)
            
        }
        trackOrderstableView.reloadData()
    }
    func createTrackOrderInfoLayout()  {
        scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 195, width: self.view.frame.width, height: self.view.frame.height))
        self.view.addSubview(scrollView)
        var yPos :CGFloat = 10
        
        
        for i in 0..<arrTrackOrderInfoList.count {
            let trackView = UIView.init(frame: CGRect(x: 50, y: yPos, width: self.view.frame.width - 60, height: 100))
            trackView.layer.borderWidth = 1
            trackView.layer.cornerRadius = 3
            trackView.layer.masksToBounds = true
            trackView.layer.borderColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1).cgColor
            scrollView.addSubview(trackView)
            
            let lblTrackTital = BaseUIController().ALabelFrame(CGRect(x: 40, y: 5, width: trackView.frame.width - 40, height: 20), withString: "HEALTH MANAGER")as! UILabel
            lblTrackTital.font = UIFont().mediumFont
            trackView.addSubview(lblTrackTital)
            
            let lblSepratorLine = BaseUIController().ALabelFrame(CGRect(x: 40, y: 30, width: trackView.frame.width - 50, height: 1), withString: "")as! UILabel
            lblSepratorLine.backgroundColor = UIColor (red: (160/255), green: (160/255), blue: (160/255), alpha: 1)
            trackView.addSubview(lblSepratorLine)
            
            let lblTrackSubTital = BaseUIController().ALabelFrame(CGRect(x: 40, y: 35, width: 200, height: 60), withString: "Your health manager is Gaurav Sharma. you can reach him at 9810981083")as! UILabel
            lblTrackSubTital.font = UIFont().smallFont
            lblTrackSubTital.textColor = UIColor (red: (76/255), green: (76/255), blue: (76/255), alpha: 1)
            trackView.addSubview(lblTrackSubTital)
            //set text on lable
            lblTrackTital.text = (arrTrackOrderInfoList.object(at: i) as! NSDictionary).value(forKey: "header")as? String
            lblTrackSubTital.text = (arrTrackOrderInfoList.object(at: i) as! NSDictionary).value(forKey: "msg")as? String
            lblTrackSubTital.sizeToFit()
             trackView.frame = CGRect(x: 50, y: yPos, width: self.view.frame.width - 60, height: lblTrackSubTital.frame.height + 40)
            
            let imageView = BaseUIController().AImageViewFrame(CGRect(x: 5, y: 5, width: 25, height: 25), withImageName: "package_name.png")as! UIImageView
            trackView.addSubview(imageView)
            
            // add image on right side
            let checkIconImageView =  BaseUIController().AImageViewFrame(CGRect(x: 10, y: yPos, width: 30, height: 30), withImageName: "check_icon.png")as! UIImageView
            scrollView.addSubview(checkIconImageView)
            var lblRightSideSepratorLine = UILabel()
            if i == 0 {
                lblRightSideSepratorLine = BaseUIController().ALabelFrame(CGRect(x: 25, y: 0, width: 1, height: 12), withString: "")as! UILabel
                lblRightSideSepratorLine.backgroundColor = KRED_COLOR
               let  lblRightSideSepratorLine2 = BaseUIController().ALabelFrame(CGRect(x: 25, y: 38, width: 1, height: lblTrackSubTital.frame.height + 40), withString: "")as! UILabel
                lblRightSideSepratorLine2.backgroundColor = KRED_COLOR
                scrollView.addSubview(lblRightSideSepratorLine2)
            }else{
                lblRightSideSepratorLine = BaseUIController().ALabelFrame(CGRect(x: 25, y: yPos + 28, width: 1, height: lblTrackSubTital.frame.height + 25), withString: "")as! UILabel
                lblRightSideSepratorLine.backgroundColor = KRED_COLOR
                
            }
           
            scrollView.addSubview(lblRightSideSepratorLine)
            yPos += trackView.frame.height + 10 // 110
        }
        print(yPos)
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: yPos + 195)
    }
    func refresh(_ sender:AnyObject) {
        // Code to refresh table view
        self.getOrederList("refresh")
    }
    //MARK: onlinepayment
    
    // MARK: CallWebservice
    func getOrederList(_ isFromRefresh : String) {
        
         let customerId =  UserDefaults.standard.value(forKey: "loginCustomerId")as! String
         if (Reachability.isConnectedToNetwork() == true) {
            if isFromRefresh != "refresh" {
                self.activityIndicator?.start()
            }
          let allParameters = ["customerId" : customerId]
            ServerConnectivity().callWebservice(allParameters , resulttagname: "GetOrdersResult" ,methodname: "GetOrders", className: self)
          }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
          }
    }
    
    func getOrderInfo(_ order_id : String) {
        
        if (Reachability.isConnectedToNetwork() == true) {
            self.activityIndicator?.start()
            let allParameters = ["orderId" : order_id]
            ServerConnectivity().callWebservice(allParameters , resulttagname: "GetOrderInformationResult" ,methodname: "GetOrderInformation", className: self)
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
                    self.present(BaseUIController().showAlertView("No Order"), animated: true, completion: nil)
                }else if (allResponse is NSMutableArray ){
                    if methodName == "GetOrders" {
                        self.refreshControl.endRefreshing()
                        self.trackOrderstableView.dataSource = self
                        self.trackOrderstableView.delegate = self
                        self.arrTrackOrderList = allResponse as! NSMutableArray
                        self.trackOrderstableView.reloadData()
                    }else{
                        
                        self.arrTrackOrderInfoList = allResponse as! NSMutableArray
                         self.createTrackOrderInfoLayout()
                      }
                    
    
                }else {
                    self.refreshControl.endRefreshing()
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }
            });
        }//);
    }
    
    
    func isLayingBetweenPickupTime(_ pickupDate : String , pickupTime : String) -> Bool {
        
        
        // arrTrackOrderList.objectAtIndex(indexPath.section).valueForKey("o_date")as! String
        let todayDate = Date()
        let dateFormatter = DateFormatter()
        // this is imporant - we set our input date format to match our input string
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let todayStringDate = dateFormatter.string(from: todayDate)
        
        
        
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
       // let currentTime = timeFormatter.stringFromDate(todayDate)
        
        let samplePickupDate = timeFormatter.date(from: pickupTime)
        print(samplePickupDate ?? "")
        
        
        // Get the date that was 1hr before now
        let earlyDate = (Calendar.current as NSCalendar).date(
            byAdding: .hour,
            value: -1,
            to: samplePickupDate!,
            options: [])
        
        let pickupTimeBeforOneHours = timeFormatter.string(from: earlyDate!)
        print(pickupTimeBeforOneHours)
        
        
        // Get the date that  1hr after now
        let afterDate = (Calendar.current as NSCalendar).date(
            byAdding: .minute,
            value: +15,
            to: samplePickupDate!,
            options: [])
        
        let pickupTimeafterOneHours = timeFormatter.string(from: afterDate!)
        
        print(pickupTimeBeforOneHours)
        
        print(pickupTimeafterOneHours)
        
        let timeInBetweeb = self.compareTimeBetweenTwoTime(pickupTimeBeforOneHours, endTime: pickupTimeafterOneHours)
        
        
        if (pickupDate == todayStringDate && timeInBetweeb) {
            print("same date")
            return true
            
        }else{
            print("Diffrent Date")
            return false
        }
        
        
    
    }
    
    
    
    
    func compareTimeBetweenTwoTime(_ startTime : String , endTime : String) -> Bool  {
        
        let todaysDate  = Date()
        let startString = startTime
        let endString   = endTime
        
        // convert strings to `NSDate` objects
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let startTime = formatter.date(from: startString)
        let endTime = formatter.date(from: endString)
        
        // extract hour and minute from those `NSDate` objects
        
        let calendar = Calendar.current
        
        var startComponents = (calendar as NSCalendar).components([.hour, .minute], from: startTime!)
        var endComponents = (calendar as NSCalendar).components([.hour, .minute], from: endTime!)
        
        // extract day, month, and year from `todaysDate`
        
        let nowComponents = (calendar as NSCalendar).components([.month, .day, .year], from: todaysDate)
        
        // adjust the components to use the same date
        
        startComponents.year  = nowComponents.year
        startComponents.month = nowComponents.month
        startComponents.day   = nowComponents.day
        
        endComponents.year  = nowComponents.year
        endComponents.month = nowComponents.month
        endComponents.day   = nowComponents.day
        
        // combine hour/min from date strings with day/month/year of `todaysDate`
        
        let startDate = calendar.date(from: startComponents)
        let endDate = calendar.date(from: endComponents)
        
        // now we can see if today's date is inbetween these two resulting `NSDate` objects
        
        let isInRange = todaysDate.compare(startDate!) != .orderedAscending && todaysDate.compare(endDate!) != .orderedDescending
        print(isInRange)
        return isInRange
        
    }

    

}


