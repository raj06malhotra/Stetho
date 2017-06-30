 //
//  PaymentOptionsViewController.swift
//  Health
//
//  Created by HW-Anil on 8/10/16.
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PaymentOptionsViewController: UIViewController , serverTaskComplete {
     let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var scrollView = UIScrollView()
    let pickupAddressObj = PickupAddressInfo()
 //   let myfamilyInfoObj = MyFamilyInfo()
//    var packageOrderInfoObj = PackgeOrederInfo()
    
    var arrMemberDetails = NSMutableArray()
    var arrSelectedPackges = NSMutableArray()
    var member_Id = ""
    var activityIndicator : ProgressViewController?
    var totalAmount = ""
    var discout_Percentage : Int = 0
    var isUseWalletBalance : Bool = Bool()
    var remainingWalletBalance = ""
    var selectedPaymetnTag : Int = 204
    var btnPlaceOrder = UIButton()
    var isComingFromClass = ""
    var failPaymentAmount = ""
    var checkBackfromPayment = false
    var tempArr : NSMutableArray!
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FBEventClass.logEvent("Payment Options")
        self.view.backgroundColor = UIColor.white
        
//        if isComingFromClass == "paymentFail" {
////            self.getPickupAddressDetails()
////            self.getMemberList()
////            self.gothoughOnlinePayment()
//        }else{
        self.createALayout()
      //   }
        //set Tital
        self.title = "PAYMENT OPTION"
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress

       remainingWalletBalance = appDelegate.walletBalance
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentOptionsViewController.getDetails(_:)), name: NSNotification.Name(rawValue: "backNotification"), object: nil)



        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        // call google analytics for screen tracking
        
//        if isComingFromClass == "paymentFail" {
//            self.getPickupAddressDetails()
//            self.getMemberList()
////            self.gothoughOnlinePayment()
//        }else{
//            self.createALayout()
//        }
         tempArr = NSMutableArray()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("PaymentOptions Screen")
        // if is coming form fail or remaining payment goto to back viewcontroller
        if (checkBackfromPayment) {
            self.navigationController?.popViewController(animated: true)
        }
        if (isComingFromClass == "paymentFail"){
            checkBackfromPayment = true
        }
        
    }
    

    func createALayout()   {
        
        scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.view .addSubview(scrollView)
        
        let xPos: CGFloat = 0
        var yPos: CGFloat = 40
        
        
        let lblTotalPaymentAmount = BaseUIController().ALabelFrame(CGRect(x: 0, y: yPos, width: self.view.frame.width, height: 21), withString: "'")as! UILabel
        lblTotalPaymentAmount.textAlignment = .center
        lblTotalPaymentAmount.textColor = KRED_COLOR
        lblTotalPaymentAmount.font = UIFont.boldSystemFont(ofSize: 18)
        if isComingFromClass == "paymentFail" {
            lblTotalPaymentAmount.text =  failPaymentAmount
        }else{
        lblTotalPaymentAmount.text =  totalAmount
        }
        print(totalAmount)
        scrollView.addSubview(lblTotalPaymentAmount)
        yPos += 30
        let lblPaymentAmountText = BaseUIController().ALabelFrame(CGRect(x: 0, y: yPos, width: self.view.frame.width, height: 21), withString: "Your payable amount")as! UILabel
        lblPaymentAmountText.font = UIFont().regularMediumFont
        lblPaymentAmountText.textAlignment = .center
        scrollView.addSubview(lblPaymentAmountText)
        yPos += 30 + 50 // after removign all payment
        
        let arrPaymentOption = ["Net Banking" , "Credit Card" , "Debit Card" , "Cash on Pickup"]
       // let arrPaymentOption = ["Cash on Pickup"]
      
        for i in 0..<arrPaymentOption.count {
            
            let lblPaymentOption = BaseUIController().ALabelFrame(CGRect(x: 30, y: yPos, width: 200, height: 30), withString: "")as! UILabel
            lblPaymentOption.font = UIFont().largeFont
            lblPaymentOption.text = arrPaymentOption[i]
            scrollView.addSubview(lblPaymentOption)
            
            let button = BaseUIController().AButtonFrame(CGRect(x: self.view.frame.width - 60 , y: yPos, width: 50, height: 30), withButtonTital: "")as! UIButton
            button.tag = 201 + i
            if button.tag == 204 {
               button.setImage(UIImage(named: "selectedradio_icon.png"), for: UIControlState())
            }else{
               button.setImage(UIImage(named: "nonselectedradio_icon.png"), for: UIControlState())
            }
          
            
            button.imageEdgeInsets = UIEdgeInsetsMake(2.5, 12.5, 2.5, 12.5)
            scrollView.addSubview(button)
            button.addTarget(self, action: #selector(self.btnSelectedPaymentOption(_:)), for: .touchUpInside)
            yPos += 35
            
        }
        yPos += 60
        btnPlaceOrder = BaseUIController().AButtonFrame(CGRect(x: 20 , y: yPos, width: self.view.frame.width - 40, height: 40), withButtonTital: "PLACE ORDER")as! UIButton
         btnPlaceOrder.addTarget(self, action: #selector(PaymentOptionsViewController.btnPlaceOrderOnClick(_:)), for:.touchUpInside)
        btnPlaceOrder.backgroundColor = KRED_COLOR
        btnPlaceOrder.titleLabel?.font = UIFont().mediumFont
        btnPlaceOrder.setTitleColor(UIColor.white, for: UIControlState())
        scrollView.addSubview(btnPlaceOrder)
        
    }
    func btnSelectedPaymentOption(_ button : UIButton)  {
        
        
        for i in 0..<4 {
            let tag = 201 + i
            let btn = scrollView.viewWithTag(tag)as! UIButton
            if button.tag ==  tag{
                btn.setImage(UIImage(named: "selectedradio_icon.png"), for: UIControlState())
                selectedPaymetnTag = tag
            }else{
               btn.setImage(UIImage(named: "nonselectedradio_icon.png"), for: UIControlState())
            }
            
        }
       
    }
    func btnPlaceOrderOnClick(_ button : UIButton)  {
        
        self.getPickupAddressDetails()
        self.getMemberList()
        
        
        if arrMemberDetails.count == 0{
            if let memberDetails = GlobalInfo.sharedInfo.getSelectedTest(){
                arrMemberDetails = memberDetails
            }
            self.gothoughOnlinePayment()
        }else{
            self.bookAnOrder()
        }
        
       
    }
    
    func barButtonBackClick(_ barButton : UIBarButtonItem)  {
       arrMemberDetails = self.getMemberList()
        
        if arrMemberDetails.count == 0{
            if isComingFromClass == "paymentFail"{
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: MyOrderViewController.self) {
                        self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                        break
                    }
                    
                }
            }
            else{
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: HomeViewController.self) {
                        self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                        break
                    }
                }
            }
          
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        

        
    }
    //MARK: DataBaseOperations
    
    func getPickupAddressDetails()  {
        
       
        let database = appDelegate.openDataBase()
        do {
            let rs = try database.executeQuery("select * from PickupAddress ", values: nil)
            while rs.next() {
                pickupAddressObj.MemberId = rs.string(forColumn: "MemberId")
                pickupAddressObj.AddressLine1 = rs.string(forColumn: "AddressLine1")
                pickupAddressObj.AddressLine1 = rs.string(forColumn: "AddressLine2")
                pickupAddressObj.LandMark = rs.string(forColumn: "LandMark")
                pickupAddressObj.City = rs.string(forColumn: "City")
                pickupAddressObj.Pincode = rs.string(forColumn: "Pincode")
                pickupAddressObj.GeoAddress = rs.string(forColumn: "GeoAddress")
                pickupAddressObj.Latitude = rs.string(forColumn: "Latitude")
                pickupAddressObj.Longitude = rs.string(forColumn: "Longitude")
                pickupAddressObj.OrderDay = rs.string(forColumn: "OrderDay")
                pickupAddressObj.OrderDate = rs.string(forColumn: "OrderDate")
                pickupAddressObj.OrderTime = rs.string(forColumn: "OrderTime")
                print(pickupAddressObj.OrderTime)
                print(pickupAddressObj.OrderDate)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }
    
    //MARK: DataBaseOperations
    
    func getMemberList() -> NSMutableArray  {
        
        
        let database = appDelegate.openDataBase()
        arrMemberDetails.removeAllObjects()
        do {
            let rs = try database.executeQuery("SELECT DISTINCT MemberId , MemberName ,MemberDOB , membergender , MemberMobileNo , MemberEmail FROM myFamily CROSS JOIN order_Package_Purchased  where memberid == OrderId ", values: nil) // ORDER BY MemberId ASC LIMIT 1
            while rs.next() {
                let myfamilyInfoObj = MyFamilyInfo()
                myfamilyInfoObj.memberId = rs.string(forColumn: "MemberId")
                myfamilyInfoObj.memberName = rs.string(forColumn: "MemberName")
                myfamilyInfoObj.memberDOB = rs.string(forColumn: "MemberDOB")
                myfamilyInfoObj.memberEmail = rs.string(forColumn: "MemberEmail")
                myfamilyInfoObj.memberMobileNo = rs.string(forColumn: "MemberMobileNo")
                myfamilyInfoObj.memberGender = rs.string(forColumn: "membergender")
                arrMemberDetails.add(myfamilyInfoObj)
                tempArr.add(myfamilyInfoObj)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        if tempArr.count > 0{
            GlobalInfo.sharedInfo.setSelectedTest(data: tempArr)
        }
        print(arrMemberDetails)
        
        return arrMemberDetails
    }
    
    func getSelectedPackages(_ memberId : String) -> NSMutableArray  {
        
       
        let database = appDelegate.openDataBase()
        arrSelectedPackges.removeAllObjects()
        do {
            let rs = try database.executeQuery(String(format: "select  * from  order_package_Purchased  where  orderId = '%@'",memberId), values: nil)
            while rs.next() {
                let packageOrderInfoObj = PackgeOrederInfo()
                packageOrderInfoObj.orderId = rs.string(forColumn: "OrderId")
                packageOrderInfoObj.packageId = rs.string(forColumn: "PackageId")
                packageOrderInfoObj.packageName = rs.string(forColumn: "PackageName")
                packageOrderInfoObj.packagePrice = rs.string(forColumn: "PackagePrice")
                packageOrderInfoObj.packageType = rs.string(forColumn: "PackageType")
                arrSelectedPackges.add(packageOrderInfoObj)
                
                
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        return arrSelectedPackges
    }
    
    func deletedPackageOrder(_ memberId : String) -> NSMutableArray  {
    
        let database = appDelegate.openDataBase()
        
       
        
        arrSelectedPackges.removeAllObjects()
        self.arrMemberDetails.removeObject(at: 0)
        print(tempArr)
        do {
             try database.executeUpdate(String(format:"delete from order_Package_Purchased where OrderId = %@ ",member_Id), values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        print(arrSelectedPackges)
        print(arrMemberDetails)
        return arrSelectedPackges
    }



    
    // MARK: CallWebservice
    func bookAnOrder() {
       
          //  activityIndicator?.start()
        
            var member_name = ""
            var packages = [String]()
            var packagePrices = [String]()//"Tomorrow " "Today "
        var pickupDate = ""
        
        let  todayDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if pickupAddressObj.OrderDay == "Today " {
            pickupDate = dateFormatter.string(from: todayDate)
        }else if(pickupAddressObj.OrderDay == "Tomorrow "){
            let tomorrowDate = self.addUnitToDate(.day, number: 1, date: todayDate)
            pickupDate = dateFormatter.string(from: tomorrowDate)
        }else{
            let dayAfterTomorrowDate = self.addUnitToDate(.day, number: 2, date: todayDate)
            pickupDate = dateFormatter.string(from: dayAfterTomorrowDate)
        }
        let  newPickupTime = pickupAddressObj.OrderTime.components(separatedBy: "-")
        
        print(pickupDate)
        print(newPickupTime)
        
        
            let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            let latitude = (pickupAddressObj.Latitude)
            let longitude = (pickupAddressObj.Longitude)
            let  geoAddress = (pickupAddressObj.GeoAddress)
            let addressLine1 = (pickupAddressObj.AddressLine1)
            let addressLine2 = (pickupAddressObj.AddressLine2)
            let landmark = (pickupAddressObj.LandMark)
            let city = (pickupAddressObj.City)
            let pincode = (pickupAddressObj.Pincode)
            let orderDate = (pickupDate)
            let orderTime = (newPickupTime[0])
        
        print(pickupAddressObj.OrderTime)
        print(pickupAddressObj.OrderDate)
        print(pickupAddressObj.AddressLine1)
        print(pickupAddressObj.City)

        
        print(arrMemberDetails.count)
        
        //    for i in 0..<arrMemberDetails.count {
                var myfamilyInfoObj = MyFamilyInfo()
                myfamilyInfoObj = arrMemberDetails.object(at: 0) as! MyFamilyInfo
                member_name = myfamilyInfoObj.memberName
                print(member_name)
//                let f_Name: String = member_name.componentsSeparated(by: " ").first!.uppercased() as String
//                let l_Name: String = member_name.componentsSeparated(by: " ").last!.uppercased() as String
        
        let f_Name: String = member_name.components(separatedBy:" ").first!.uppercased() as String
        let l_Name: String = member_name.components(separatedBy:" ").last!.uppercased() as String


        
        
        
        
                print(f_Name)
                print(l_Name)
                member_Id = myfamilyInfoObj.memberId
                let memberId = (myfamilyInfoObj.memberId)
                let fName = (f_Name)
                let lName = (l_Name)
                let mobileNo = (myfamilyInfoObj.memberMobileNo)
                let email = (myfamilyInfoObj.memberEmail)
                let  dob = (myfamilyInfoObj.memberDOB)
                let gender = (myfamilyInfoObj.memberGender)
               
                
                self.getSelectedPackages(member_Id)
                packages.removeAll()
                packagePrices.removeAll()
                for k in 0..<arrSelectedPackges.count {
                    var packageOrderInfoObje = PackgeOrederInfo()
                    packageOrderInfoObje = arrSelectedPackges[k] as! PackgeOrederInfo
                    packages.append(packageOrderInfoObje.packageId)
                    if discout_Percentage != 0 {
                      var  discoutnPrice = Int(packageOrderInfoObje.packagePrice)! - (Int(packageOrderInfoObje.packagePrice)! * discout_Percentage/100)
                        
                        print(packageOrderInfoObje.packagePrice)
                        print(discoutnPrice)
                        if (isUseWalletBalance == true && Int(remainingWalletBalance) > 0 ) {
                            if (Int(packageOrderInfoObje.packagePrice) < Int(remainingWalletBalance)) {
                                let r_Balance = Int(remainingWalletBalance)! - discoutnPrice
                                discoutnPrice = 0
                                remainingWalletBalance = String(r_Balance)
                            }else{
                              discoutnPrice = discoutnPrice - Int(remainingWalletBalance)!
                                remainingWalletBalance = "0"
                            }
                        }
                       packagePrices.append(String(discoutnPrice))
                    }else{
                        if (isUseWalletBalance == true && Int(remainingWalletBalance) > 0 ) {
                             var discoutnPrice = Int()
                            
                            if (Int(packageOrderInfoObje.packagePrice) < Int(remainingWalletBalance)) {
                                 //Int(packageOrderInfoObje.packagePrice)! - Int(appDelegate.walletBalance)!
                                let r_Balance = Int(remainingWalletBalance)! - Int(packageOrderInfoObje.packagePrice)!
                                discoutnPrice = 0
                                remainingWalletBalance = String(r_Balance)
                            }else{
                                discoutnPrice = Int(packageOrderInfoObje.packagePrice)! - Int(remainingWalletBalance)!
                                remainingWalletBalance = "0"
                            }
                            
                            packagePrices.append(String(discoutnPrice))
                        }else{
                           packagePrices.append(packageOrderInfoObje.packagePrice)
                        }
                    }
                }
        // check
        if appDelegate.walletBalance != "" {
            appDelegate.walletBalance = String(Int(appDelegate.walletBalance)! - Int(remainingWalletBalance)!)
        }
        
        
                print(packages)
                print(packagePrices)
                print(appDelegate.walletBalance)
                print(appDelegate.walletBalance)
                print(remainingWalletBalance)
        
                let purchased_packages = (packages.joined(separator: ","))
                let purchased_packagePrices = (packagePrices.joined(separator: ","))
                print(packages.joined(separator: ","))
                print(packagePrices.joined(separator: ","))
                print(memberId)
               //add two parameter android version 2 with (wallet balance)
                let refrralCode = (appDelegate.referralCode)
                let walletAmountApplied = (appDelegate.walletBalance)
        
                UIApplication.shared.endIgnoringInteractionEvents()
                if (Reachability.isConnectedToNetwork() == true) {
                    self.activityIndicator?.start()
                    
                    //
//                    let allParameters = ["customerId" : customerId , "memberId": memberId ,"firstName": fName , "lastName" : lName, "phone" : mobileNo,"email": email , "dob": dob , "gender": gender , "addressLine1" : addressLine1 , "addressLine2" : addressLine2 , "landmark" : landmark , "city" : city , "geoAddress" : geoAddress , "pincode" : pincode , "latitude" : latitude , "longitude" : longitude , "orderId" : memberId , "orderDate" :  orderDate, "orderTime" : orderTime, "packages" : purchased_packages , "packagePrices" : purchased_packagePrices]
//                    
//                    ServerConnectivity().callWebservice(allParameters , resulttagname: "BookOrderResult" ,methodname: "BookOrder", className: self)
                    
                    let allParameters = ["customerId" : customerId , "memberId": memberId ,"firstName": fName , "lastName" : lName, "phone" : mobileNo,"email": email , "dob": dob , "gender": gender , "addressLine1" : addressLine1 , "addressLine2" : addressLine2 , "landmark" : landmark , "city" : city , "geoAddress" : geoAddress , "pincode" : pincode , "latitude" : latitude , "longitude" : longitude , "orderId" : memberId , "orderDate" :  orderDate, "orderTime" : orderTime, "packages" : purchased_packages , "packagePrices" : purchased_packagePrices,"walletAmountApplied" : walletAmountApplied ,"couponCode" : refrralCode]
                    
                        ServerConnectivity().callWebservice(allParameters , resulttagname: "BookOrderVersion2Result" ,methodname: "BookOrderVersion2", className: self)

                }else{
                    self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
                }
         //  }
    }
    
    func gothoughOnlinePayment()  {
        FBEventClass.logEvent("Payment Gateway")
        DispatchQueue.main.async{
            self.activityIndicator?.start()
            // code here
//            var myFamilyObject: MyFamilyInfo = MyFamilyInfo()
//            myFamilyObject = DrawerViewController().loadMyProfile()
            
            
            let paymentView = PaymentModeViewController(nibName: "PaymentModeViewController", bundle: nil)
            var t_amount = ""
            if self.isComingFromClass == "paymentFail" {
                t_amount = self.failPaymentAmount
            }else{
            t_amount = String(self.totalAmount.characters.dropFirst())
            t_amount = t_amount + ".00"
            }
            
            
            /*         paymentView.paymentAmtString = t_amount
             paymentView.strSaleAmount = t_amount
             paymentView.strCurrency = "INR";
             paymentView.strDisplayCurrency = "USD";
             //Reference no has to be configured
             paymentView.reference_no = "223";
             paymentView.strDescription = "Test Description";
             paymentView.strBillingName = "Test";
             paymentView.strBillingAddress = "Bill address";
             paymentView.strBillingCity = self.pickupAddressObj.City;
             paymentView.strBillingState = "DL";
             paymentView.strBillingPostal = self.pickupAddressObj.Pincode
             paymentView.strBillingCountry = "IND";
             paymentView.strBillingEmail = myFamilyObject.memberEmail
             paymentView.strBillingTelephone = myFamilyObject.memberMobileNo */
            
            var myFamilyObj = MyFamilyInfo()
            myFamilyObj = DrawerViewController().loadMyProfile()
            let userName = myFamilyObj.memberName
            
            paymentView.paymentAmtString = t_amount
            paymentView.strSaleAmount = t_amount
            paymentView.strCurrency = "INR";
            paymentView.strDisplayCurrency = "USD";
            
            
            if myFamilyObj.memberMobileNo.isEmpty{
                paymentView.reference_no = "9810981073"
            }else{
                paymentView.reference_no = myFamilyObj.memberMobileNo
            }
            
            if String(self.appDelegate.bookedOrderId).isEmpty{
                 paymentView.strDescription = "Hindustanwellness"
            }else{
                 paymentView.strDescription = self.appDelegate.bookedOrderId as String
            }
            
            if userName.isEmpty{
                paymentView.strBillingName = "Hindustan wellness"
            }else{
                paymentView.strBillingName = userName
            }
            
            if self.pickupAddressObj.GeoAddress.isEmpty{
                paymentView.strBillingAddress = "2nd floor Hindustan wellness"

            }else{
                paymentView.strBillingAddress = self.pickupAddressObj.GeoAddress

            }
            
            if self.pickupAddressObj.City.isEmpty{
                 paymentView.strBillingCity =  "Gurgaon"
                
            }else{
                 paymentView.strBillingCity =  self.pickupAddressObj.City
                
            }
    
            
            if self.pickupAddressObj.Pincode.isEmpty{
                paymentView.strBillingPostal = "122001"//self.pickupAddressObj.Pincode
            }else{
                paymentView.strBillingPostal = self.pickupAddressObj.Pincode
            }
            
            if myFamilyObj.memberEmail.isEmpty{
                paymentView.strBillingEmail = "stetho.hindustanwellness@gmail.com"
            }else{
                paymentView.strBillingEmail = myFamilyObj.memberEmail
            }
            
            if myFamilyObj.memberMobileNo.isEmpty{
                 paymentView.strBillingTelephone = "9810981073"
            }else{
                 paymentView.strBillingTelephone = myFamilyObj.memberMobileNo
            }
            
            paymentView.strBillingState = "DL";
            paymentView.strBillingCountry = "IND";
            
            
            
            //Reference no has to be configured
           // paymentView.reference_no = myFamilyObj.memberMobileNo
//            paymentView.strDescription = self.appDelegate.bookedOrderId as String
         //   paymentView.strBillingName = userName
//            paymentView.strBillingAddress = ""//self.pickupAddressObj.GeoAddress
          //  paymentView.strBillingCity =  ""//self.pickupAddressObj.City
         //   paymentView.strBillingState = "DL";
//            paymentView.strBillingPostal = ""//self.pickupAddressObj.Pincode
         //   paymentView.strBillingCountry = "IND";
//            paymentView.strBillingEmail = myFamilyObj.memberEmail
//            paymentView.strBillingTelephone = myFamilyObj.memberMobileNo
            
            
            
            
            
            
            // Non mandatory parameters
            paymentView.strDeliveryName = "";
            paymentView.strDeliveryAddress = "";
            paymentView.strDeliveryCity = "";
            paymentView.strDeliveryState = "";
            paymentView.strDeliveryPostal = "";
            paymentView.strDeliveryCountry = "";
            paymentView.strDeliveryTelephone = "";
            //Dynamic Values configuration
            //var dynamicKeyValueDictionary: NSMutableDictionary = NSMutableDictionary()
            // dynamicKeyValueDictionary.setValue("savings", forKey: "account_detail")
            //  dynamicKeyValueDictionary.setValue("gold", forKey: "merchant_type")
            //  paymentView.dynamicKeyValueDictionary = dynamicKeyValueDictionary
            //  self.navigationController?.navigationBarHidden = true
           
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = KRED_COLOR
            GlobalInfo.sharedInfo.setPaymentOptionsNavigation(navController: self.navigationController!)
            self.navigationController!.pushViewController(paymentView, animated: true)
             self.activityIndicator?.stop()
        }
        
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
     //   print(allResponse)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if (allResponse is String &&  allResponse as! String == "" || allResponse is String &&  allResponse as! String == "error" || allResponse is String && allResponse as! String == "Something went wrong. Please try again.") {
                    
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    
                }else{
                    
                    if self.arrMemberDetails.count > 1 {
//                        self.arrMemberDetails.removeObject(at: 0)
                        print(((allResponse as! NSArray)[0] as AnyObject).value(forKey: "wallet_balance")as! String)
                        self.appDelegate.walletBalance = ((allResponse as! NSArray)[0] as AnyObject).value(forKey: "wallet_balance")as! String
                       self.deletedPackageOrder(self.member_Id)
                        // set booked order
                        self.appDelegate.bookedOrderId.append(((allResponse as! NSArray)[0] as AnyObject).value(forKey: "o_id")as! String)
                        self.appDelegate.bookedOrderId.append(",")
                        self.bookAnOrder()
                    }else{
                        print(((allResponse as! NSArray)[0] as AnyObject).value(forKey: "wallet_balance")as! String)
                        self.appDelegate.walletBalance = ((allResponse as! NSArray)[0] as AnyObject).value(forKey: "wallet_balance")as! String
//                        self.arrMemberDetails.removeObject(at: 0)
                        self.deletedPackageOrder(self.member_Id)
                       // self.presentViewController(BaseUIController().showAlertView("Your order placed successfully"), animated: true, completion: nil)
                       // self.showAlertView()
                         NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil) 
                        self.appDelegate.walletBalance = ((allResponse as! NSArray)[0] as AnyObject).value(forKey: "wallet_balance")as! String
                        
                
                        if (self.selectedPaymetnTag == 204) {
                            let orderBookedVC = OrderBookedViewController()
                            self.navigationController?.pushViewController(orderBookedVC, animated: true)
                        }else{
                            // online payment
                            self.appDelegate.bookedOrderId.append(((allResponse as! NSArray)[0] as AnyObject).value(forKey: "o_id")as! String)
                            print(self.appDelegate.bookedOrderId)
                            self.gothoughOnlinePayment()
                        }
                    }
                }
            });
        });
    }
    // MARK: paymentDetails
    func getDetails(_ message: Notification)
    {
        print(message)
    }

    func showAlertView()  {
        //FBEventClass.logEvent("Order Booking Success")
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "Your order placed successfully!", preferredStyle: .alert)
        //Create and add the Cancel action
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel) { action -> Void in
            //Do some stuff
            let orderBookedVC = OrderBookedViewController()
            self.navigationController?.pushViewController(orderBookedVC, animated: true)
        }
        actionSheetController.addAction(okAction)
//        //Create and an option action
//        let nextAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
//            //Do some other stuff
//        }
//        actionSheetController.addAction(nextAction)
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    func addUnitToDate(_ unitType: NSCalendar.Unit, number: Int, date:Date) -> Date {
        
        return (Calendar.current as NSCalendar).date(
            byAdding: unitType,
            value: number,
            to: date,
            options: NSCalendar.Options(rawValue: 0))!
    }
}
