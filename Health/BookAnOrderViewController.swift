//
//  BookAnOrderViewController.swift
//  Health
//
//  Created by HW-Anil on 6/21/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class BookAnOrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate , serverTaskComplete , UISearchResultsUpdating ,CustomDelegate{
     // MARK: - VariableDeclration
   var tableView: UITableView = UITableView()
   let kCellIdentifier = "Cell"
   var activityIndicator : ProgressViewController?
   var arrPakageData = NSMutableArray()
   var arrFilterPakageData = NSArray()
   let searchController = UISearchController(searchResultsController: nil)
   var arrCartPackageOrderData = NSMutableArray()
   var lblTestSelectd = UILabel()
   var btnContinue: UIButton = UIButton()
   var bgView = UIView()
   var buttonAdd : UIButton = UIButton()
   var pdfLink = ""
   var selectedIndexPath = 0
    var currentVC : CustomDelegate?
   var homeTabVC :HomeTabSwipeViewController = HomeTabSwipeViewController()
   var tabBarHeight : CGFloat = 0
    
   
    

    
    
    
   
    
    
    
   // MARK: - ViewLifeCycleMethods
    override func viewDidLoad() {
        super.viewDidLoad()
      

        // Do any additional setup after loading the view.
        // add searchBar on view 
        /* Search controller parameters */
        searchController.searchResultsUpdater = self  // This protocol allows your class to be informed as text changes within the UISearchBar.
        searchController.dimsBackgroundDuringPresentation = false  // In this instance,using current view to show the results, so do not want to dim current view.
        definesPresentationContext = true   // ensure that the search bar does not remain on the screen if the user navigates to another view controller while the UISearchController is active.
        
        let tableHeaderView: UIView = UIView.init(frame: searchController.searchBar.frame)
        tableHeaderView.addSubview(searchController.searchBar)
        //  self.tableView.tableHeaderView = tableHeaderView
        self.view.addSubview(tableHeaderView)
        
        searchController.hidesNavigationBarDuringPresentation = false

        self.view.backgroundColor = UIColor.white
        self.CreateALayout()
        // add activity indicator on View
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        activityIndicator?.frame = CGRect(x: activityIndicator!.frame.origin.x, y: activityIndicator!.frame.origin.y - 100, width: activityIndicator!.frame.width, height: activityIndicator!.frame.height)
        self.view.addSubview(activityIndicator!)
        
        var healthtestversion = ""
        var packageupdateversion = ""
        for key in Array(UserDefaults.standard.dictionaryRepresentation().keys) {
            if (key == "healthtestversion"){
                healthtestversion = UserDefaults.standard.value(forKey: "healthtestversion")as! String
                
            }else if (key == "packageupdateversion"){
                packageupdateversion =  UserDefaults.standard.value(forKey: "packageupdateversion")as! String
            
            }
        }
        
        print(healthtestversion)
        print(packageupdateversion)
        
        // get all package in nsuserDefault 
        
        
        
        
        if(UserDefaults.standard.value(forKey: "allpackages") == nil || packageupdateversion == "" || healthtestversion != packageupdateversion){
            self.getAllTestProduct()
        }else{
            arrPakageData =   NSMutableArray(array: UserDefaults.standard.value(forKey: "allpackages") as! NSArray) //UserDefaults.standard.value(forKey: "allpackages") as! NSMutableArray
            self.tableView.delegate      =   self
            self.tableView.dataSource    =   self
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            self.tableView.reloadData()
         
            
            
        }
        self.getSelectedPackageOrder()
        if selectedIndexPath == 0 {
           // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                if self.arrCartPackageOrderData.count != 0 {
                    self.showAlertView()
                }
           // }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("Booking Screen")
        
        
        
        
        print("yessss")
        
        print(self.view.frame.width)
        
       

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: CreateLayout
    func CreateALayout()  {
        
       
        tableView = UITableView(frame:CGRect(x: 0, y: 50,width: (UIScreen.main.bounds.width), height: (UIScreen.main.bounds.height-(64 + 40 + 40 + 50 + tabBarHeight)))) // nav height + familymember Slider + tab +  40 (buttom widht)
//        tableView.delegate      =   self
//        tableView.dataSource    =   self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor.clear
        tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.view.addSubview(self.tableView)
      
        
        // create a label and button in bottom view
        lblTestSelectd = UILabel(frame: CGRect(x: 0, y: tableView.frame.height + 50 ,width: self.view.frame.width/2,height: 40))
        lblTestSelectd.text = "None"
        lblTestSelectd.textAlignment = NSTextAlignment.center
        lblTestSelectd.backgroundColor = UIColor (red: (209.0/255.0), green: (209.0/255.0), blue: (209.0/255.0), alpha: 1)
        lblTestSelectd.font = UIFont().mediumFont
        self.view .addSubview(lblTestSelectd)
        btnContinue = UIButton(frame: CGRect(x: self.view.frame.width/2, y: tableView.frame.height + 50 ,width: self.view.frame.width/2,height: 40))
        btnContinue.setTitle("Continue", for: UIControlState())
        btnContinue.backgroundColor = UIColor.red
        btnContinue.titleLabel?.font = UIFont().mediumFont
        btnContinue.addTarget(self, action: #selector(BookAnOrderViewController.btnContinueOnClick(_:)), for: .touchUpInside)
        self.view .addSubview(btnContinue)
        
    }
    func updateUILayout()  {
        if arrCartPackageOrderData.count > 0 {
            lblTestSelectd.text = String(arrCartPackageOrderData.count) + " Tests Selected"
        }else{
            lblTestSelectd.text = "None"
        }
        var price = 0
        for i in 0..<arrCartPackageOrderData.count {
            var pkgOrderInfo = PackgeOrederInfo()
            pkgOrderInfo = arrCartPackageOrderData[i] as! PackgeOrederInfo
            price +=  Int(pkgOrderInfo.packagePrice)!
        }
//        let currencyCode = "INR"
//        let localeComponents = [NSLocale.Key.currencyCode: currencyCode]
//        let localeIdentifier = Locale.localeIdentifier(fromComponents: localeComponents as! [String : String])
//        let locale = Locale(localeIdentifier: localeIdentifier)
//        let currencySymbol = (locale as NSLocale).object(forKey: NSLocale.Key.currencySymbol) as! String
        let currencySymbol = (Locale(identifier:"de") as NSLocale).displayName(forKey: .currencySymbol, value: "INR")!
        btnContinue.setTitle(String(format: "Continue(%@)",currencySymbol + String(price)), for: UIControlState())
    }
    func populatePackageDetails(_ arrPackageDetaisls : NSArray)  {
        bgView.removeFromSuperview()
        bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        bgView.tag = 333
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        UIApplication.shared.keyWindow?.addSubview(bgView);
        // add UIView on background 
        let mainView = UIView.init(frame: CGRect(x: 10, y: 22, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - 40))
        mainView.backgroundColor = UIColor.white
//        mainView.layer.masksToBounds = true
//        mainView.layer.cornerRadius = 4
//        mainView.layer.borderWidth = 2
//        mainView.layer.borderColor = UIColor.grayColor().CGColor
        bgView.addSubview(mainView)
        let width = mainView.frame.width
        var yPos : CGFloat = 0
        
        let btnDone = BaseUIController().AButtonFrame(CGRect(x: 0, y: yPos, width: width,  height: 40), withButtonTital: "PACKAGE DETAILS")as! UIButton
        btnDone.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        //btnBack.contentHorizontalAlignment = .Right
        btnDone.addTarget(self, action: #selector(self.btnPackageDetailsOnclick(_:)), for: .touchUpInside)
        mainView.addSubview(btnDone)
        yPos += 40 + 1
        
        let cancelImage = BaseUIController().AImageViewFrame(CGRect(x: (width - 40), y: 0, width: 30, height: 30), withImageName: "verified_no.png")as! UIImageView
        btnDone.addSubview(cancelImage)
        
//        let lblPackageDetails = BaseUIController().ALabelFrame(CGRectMake(10, yPos, 200, 21), withString: "PACKAGE DETAILS")as! UILabel
//        lblPackageDetails.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
//        mainView.addSubview(lblPackageDetails)
//        yPos += 20 + 5
        let lblLine1 = BaseUIController().ALabelFrame(CGRect(x: 0, y: yPos, width: width, height: 1), withString: "")as! UILabel
        lblLine1.backgroundColor = UIColor.red
        mainView.addSubview(lblLine1)
        yPos += 5
        let pckImageView = BaseUIController().AImageViewFrame(CGRect(x: 5, y: yPos, width: 30, height: 30), withImageName: "package_name.png")as! UIImageView
        mainView.addSubview(pckImageView)
        let pckName = (arrPackageDetaisls[0] as AnyObject).value(forKey: "package")as! String
        pdfLink = (arrPackageDetaisls[0] as AnyObject).value(forKey: "pdflink")as! String
        let lblPackName = BaseUIController().ALabelFrame(CGRect( x: 40, y: yPos,width: mainView.frame.width - 50 , height: 0), withString: pckName)as! UILabel
        
        mainView.addSubview(lblPackName)
        lblPackName.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        lblPackName.sizeToFit()
        yPos += lblPackName.frame.height + 10
        let pckDetailsSting = (arrPackageDetaisls[0] as AnyObject).value(forKey: "value")as! String
        let newpckDetailsSting = pckDetailsSting.replacingOccurrences(of: "!@#", with: "\n", options: NSString.CompareOptions.literal, range: nil)
        
        let lblPckDetails = BaseUIController().ALabelFrame(CGRect( x: 40, y: yPos,width: mainView.frame.width - 50 , height: 0), withString: newpckDetailsSting)as! UILabel
        mainView.addSubview(lblPckDetails)
        lblPckDetails.sizeToFit()
        yPos += lblPckDetails.frame.height + 10
        let lblLine2 = BaseUIController().ALabelFrame(CGRect(x: 0, y: yPos, width: width, height: 1), withString: "")as! UILabel
        lblLine2.backgroundColor = UIColor.red
        mainView.addSubview(lblLine2)
        yPos += 2
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: yPos, width: width, height: UIScreen.main.bounds.height - (yPos + 40)))
        mainView.addSubview(scrollView)
        var scrollYpos :CGFloat = 5
        
        
        let rupesSymboleImageView = BaseUIController().AImageViewFrame(CGRect(x: 5, y: scrollYpos, width: 30, height: 30), withImageName: "package_price.png")as! UIImageView
        scrollView.addSubview(rupesSymboleImageView)
        let lblCharges = BaseUIController().ALabelFrame(CGRect(x: 40, y: scrollYpos, width: UIScreen.main.bounds.width - 50, height: 21), withString: "CHARGES")as! UILabel
        lblCharges.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        scrollView.addSubview(lblCharges)
        scrollYpos += scrollYpos + 21 + 5
        let lblAmount = BaseUIController().ALabelFrame(CGRect(x: 40, y: scrollYpos, width: UIScreen.main.bounds.width - 50, height: 21), withString: (arrPackageDetaisls[1] as! NSDictionary).value(forKey: "value")as! String)as! UILabel
        scrollView.addSubview(lblAmount)
        scrollYpos += 21 + 5 
        let lblLine3 = BaseUIController().ALabelFrame(CGRect(x: 0, y: scrollYpos, width: width, height: 1), withString: "")as! UILabel
        lblLine3.backgroundColor = UIColor.red
        scrollView.addSubview(lblLine3)
        scrollYpos += 10
        let testImageView = BaseUIController().AImageViewFrame(CGRect(x: 5, y: scrollYpos, width: 30, height: 30), withImageName: "test_report_icon.png")as! UIImageView
        scrollView.addSubview(testImageView)
//        let mutableString = NSMutableString()
        let lblTestHeading = BaseUIController().ALabelFrame(CGRect(x: 40, y: scrollYpos, width: width - 50, height: 21), withString: "TEST AND DETAILS")as! UILabel
        lblTestHeading.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        scrollView.addSubview(lblTestHeading)
        scrollYpos += 20 + 10
        
        let lblTestDetails = BaseUIController().ALabelFrame(CGRect(x: 40, y: scrollYpos, width: width - 50, height: 0), withString: "")as! UILabel
        scrollView.addSubview(lblTestDetails)
        
        let attributedText = NSMutableAttributedString()
        for i in 0..<arrPackageDetaisls.count {
            if i > 1 {
                let heading = (arrPackageDetaisls[i] as AnyObject).value(forKey: "heading")as! String
                 let newHeading = (String(format: "\n%@ . %@ \n",String(i - 1),heading))
                let valueString = (arrPackageDetaisls[i] as AnyObject).value(forKey: "value")as! String
                let newValueString = valueString.replacingOccurrences(of: "!@#", with: "\n", options: NSString.CompareOptions.literal, range: nil)
               // mutableString.appendString(newValueString)
//                mutableString.appendString("\n")
                let attrs1      = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 12.0)!, NSForegroundColorAttributeName:UIColor.black]
                let attrs2      = [NSFontAttributeName: UIFont().mediumFont, NSForegroundColorAttributeName: UIColor.black]
                attributedText.append(NSAttributedString(string: newHeading , attributes:  attrs1))
                attributedText.append(NSAttributedString(string: newValueString, attributes: attrs2))
            }
        }
       // lblTestDetails.text = mutableString as String
     //   yourLabel.intrinsicContentSize().width
       
        lblTestDetails.attributedText = attributedText
        lblTestDetails.sizeToFit()
        scrollYpos += lblTestDetails.frame.height
        scrollView.contentSize = CGSize(width: mainView.frame.width, height: scrollYpos + 50)
        
        let btnBook = BaseUIController().AButtonFrame(CGRect(x: 0, y: mainView.frame.height - 40.5, width: (mainView.frame.width/2) - 1, height: 40), withButtonTital: "Book")as! UIButton
        btnBook.backgroundColor = UIColor (red: (209.0/255.0), green: (209.0/255.0), blue: (209.0/255.0), alpha: 1)
        btnBook.setTitleColor(UIColor.white, for: UIControlState())
        btnBook.addTarget(self, action: #selector(self.btnBookOnClick(_:)), for: .touchUpInside)
        mainView.addSubview(btnBook)
        let bookImageView = BaseUIController().AImageViewFrame(CGRect(x: 30, y: 7, width: 25, height: 25), withImageName: "package_book.png")as! UIImageView
        bookImageView.tintColor = UIColor.white
        btnBook.addSubview(bookImageView)
        

        let btnShare = BaseUIController().AButtonFrame(CGRect(x: (mainView.frame.width/2) + 1, y: mainView.frame.height - 40.5, width: (mainView.frame.width/2) - 1, height: 40), withButtonTital: "Share")as! UIButton
        btnShare.backgroundColor = UIColor (red: (209.0/255.0), green: (209.0/255.0), blue: (209.0/255.0), alpha: 1)
        btnShare.setTitleColor(UIColor.white, for: UIControlState())
        btnShare.addTarget(self, action: #selector(self.btnShareOnClick(_:)), for: .touchUpInside)
        mainView.addSubview(btnShare)
        let shareImageView = BaseUIController().AImageViewFrame(CGRect(x: 30, y: 7, width: 25, height: 25), withImageName: "package_share.png")as! UIImageView
        shareImageView.tintColor = UIColor.white
         btnShare.addSubview(shareImageView)
    }
    //MARK: customDelegate
    func reloadLocalDataAferbackfFromView(){
        self.getSelectedPackageOrder()
        tableView.reloadData()
        
    }
    
    //MARK: TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchController.isActive == true {
            return arrFilterPakageData.count
        }else{
            
            return arrPakageData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: kCellIdentifier)
        // let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: kCellIdentifier)
        cell.selectionStyle = .none
        
        var btnAdd = UIButton()
        var lblBookingAmount = UILabel()
        
        btnAdd = UIButton(frame: CGRect(x: self.tableView.frame.width - 60, y: 10, width: 50.0, height: 25))
        btnAdd.setTitle("ADD", for: UIControlState())
        btnAdd.setTitleColor(UIColor (red: (114.0/255.0), green: (114.0/255.0), blue: (114.0/255.0), alpha: 1), for: UIControlState())
        btnAdd.titleLabel?.font = UIFont().mediumFont
        btnAdd.layer.borderColor = UIColor.orange.cgColor
        btnAdd.layer.borderWidth = 1
        btnAdd.layer.cornerRadius = 5
        btnAdd.tag = 1001 + (indexPath as NSIndexPath).row
        btnAdd.addTarget(UIButton(), action: #selector(BookAnOrderViewController.btnAddOnClick(_:)), for: UIControlEvents.touchUpInside)
        
        lblBookingAmount = BaseUIController().ALabelFrame(CGRect(x: btnAdd.frame.origin.x - 15, y: 40, width: 80.0, height: 25), withString: "") as! UILabel
        lblBookingAmount.textAlignment = NSTextAlignment.center
        lblBookingAmount.font = UIFont().mediumFont
        //lblBookingAmount.textColor = UIColor (red: (105.0/255.0), green: (105.0/255.0), blue: (105.0/255.0), alpha: 1)
//        let currencyCode = "INR"
//        
//        let localeComponents = [NSLocale.Key.currencyCode: currencyCode]
//        let localeIdentifier = Locale.localeIdentifier(fromComponents: localeComponents as! [String : String])
//        let locale = Locale(localeIdentifier: localeIdentifier)
//        let currencySymbol = (locale as NSLocale).object(forKey: NSLocale.Key.currencySymbol) as! String
        let currencySymbol = (Locale(identifier:"de") as NSLocale).displayName(forKey: .currencySymbol, value: "INR")!

        cell.addSubview(btnAdd)
        cell.addSubview(lblBookingAmount)
        
        let pdfImageview = BaseUIController().AImageViewFrame(CGRect(x: 5, y: 22, width: 25, height: 25), withImageName: "test_report_icon")as! UIImageView
      //  pdfImageview.image = UIImage(named: "pdf_icon")
        cell.addSubview(pdfImageview)
        
        let lblTestName = BaseUIController().ALabelFrame(CGRect(x: 35, y: 5, width: self.view.frame.width-100, height: 50), withString: "")as! UILabel
        lblTestName.font = UIFont().mediumFont
        lblTestName.textColor = UIColor.black//UIColor (red: (105.0/255.0), green: (105.0/255.0), blue: (105.0/255.0), alpha: 1)
        cell.addSubview(lblTestName)
        
        let lblTestDetails = BaseUIController().ALabelFrame(CGRect(x: 35, y: 45, width: self.view.frame.width-100, height: 15), withString: "")as! UILabel
        lblTestDetails.font = UIFont.italicSystemFont(ofSize: 12)
        lblTestDetails.textColor = UIColor (red: (114.0/255.0), green: (114.0/255.0), blue: (114.0/255.0), alpha: 1)
        cell.addSubview(lblTestDetails)
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "View details")
        attributeString.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: NSMakeRange(0, attributeString.length))
        lblTestDetails.attributedText = attributeString
    
        
        if searchController.isActive == true {
            // block user interaction on searchcontroller active
            homeTabVC.dissableTapSegmentController("active")
            let packageDictFilter = arrFilterPakageData[indexPath.row] as! NSDictionary
            lblTestName.text = packageDictFilter.value(forKey: "pkg_name") as? String
            let price = (packageDictFilter.value(forKey: "pkg_price")) as! String
            lblBookingAmount.text = currencySymbol + price
            // hide View Details label
            if packageDictFilter.value(forKey: "pac_test_type")as? String != "P" {
                lblTestDetails.isHidden = true
            }
        } else {
            // block user interaction on searchcontroller active
             homeTabVC.dissableTapSegmentController("Inactive")
            let packageDict = arrPakageData[indexPath.row] as! NSDictionary

            lblTestName.text = packageDict.value(forKey: "pkg_name")as? String
            let price = packageDict.value(forKey: "pkg_price")as! String
            lblBookingAmount.text = currencySymbol + price
             // hide View Details label
            if packageDict.value(forKey: "pac_test_type")as? String != "P" {
                lblTestDetails.isHidden = true
            }
        }
        for i in 0..<arrCartPackageOrderData.count {
            var pkgOrderInfo = PackgeOrederInfo()
            pkgOrderInfo = arrCartPackageOrderData[i] as! PackgeOrederInfo
            let selectedMemberId = UserDefaults.standard.value(forKeyPath: "selectedMemberId")as! String
            var pkg_id = ""
            if searchController.isActive == false {
               pkg_id = (arrPakageData[(indexPath as NSIndexPath).row] as! NSDictionary).value(forKey: "pkg_id")as! String
            }else{
                pkg_id = (arrFilterPakageData[(indexPath as NSIndexPath).row] as! NSDictionary).value(forKey: "pkg_id")as! String
            }
            if (pkgOrderInfo.packageId == pkg_id) && pkgOrderInfo.orderId == selectedMemberId  {
                btnAdd.backgroundColor = UIColor.red
                btnAdd.setTitleColor(UIColor.white, for: UIControlState())
                btnAdd.isSelected = true
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        buttonAdd  = self.view.viewWithTag(1001 + (indexPath as NSIndexPath).row)as! UIButton
        
        var pkg_id = ""
        if searchController.isActive == false {
            pkg_id = (arrPakageData[indexPath.row] as! NSDictionary).value(forKey: "pkg_id")as! String
        if (arrPakageData[indexPath.row] as! NSDictionary).value(forKey: "pac_test_type")as? String == "P" {
                self.getTestDetails(pkg_id)
            }
        }else{
            pkg_id = (arrFilterPakageData[indexPath.row] as! NSDictionary).value(forKey: "pkg_id")as! String
        if (arrFilterPakageData[indexPath.row] as! NSDictionary).value(forKey: "pac_test_type")as? String == "P" {
                self.getTestDetails(pkg_id)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  70;
    }
    //MARK: searchBarDelegate
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        arrFilterPakageData = NSArray()
        let searchPredicate = NSPredicate(format: "pkg_name CONTAINS[c] %@", searchController.searchBar.text!)
         arrFilterPakageData = arrPakageData.filtered(using: searchPredicate) as NSArray
//        arrFilterPakageData = arrPakageData.filter {searchPredicate.evaluate(with: $0)}
        
        
//        if arrFilterPakageData.count == 0 {
//           searchController = false
//        }else
//         {
//           searchController.active = true
//        }
         tableView.reloadData()
        
    }

    //MARK: callWebservice
    func getAllTestProduct()  {
        
    if Reachability.isConnectedToNetwork() == true {
        activityIndicator?.start()
        let allParameters = ["testId":"0"]
        ServerConnectivity().callWebservice(allParameters, resulttagname: "GetPackagePriceResult" ,methodname: "GetPackagePrice", className: self)
    }else{
               
        self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
    }
            
    }
    
    func getTestDetails(_ testId : String)  {
        
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            
            let allParameters = ["testId":testId]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetTestDetailsResult" ,methodname: "GetTestDetails", className: self)
        }else{
            
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
     
        
      //  print(allResponse)
        
           // DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                // do your background code here
                DispatchQueue.main.sync(execute: {
                    // stop the activity indicator (you are now on the main queue again)
                    self.activityIndicator?.stop()
                    if allResponse is String &&  allResponse as! String == "error" {
                        
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    }
                    else if allResponse is String &&  allResponse as! String == "" {
                       self.present(BaseUIController().showAlertView("No Test Details!"), animated: true, completion: nil)
                    }else if (allResponse is String && allResponse as! String != ""){
                        self.present(BaseUIController().showAlertView(allResponse as! String), animated: true, completion: nil)
                    }else{
                        if (methodName == "GetTestDetails"){
                           self.populatePackageDetails(allResponse as! NSArray)
                        }else{
                            self.arrPakageData = (allResponse as? NSMutableArray)!
                            UserDefaults.standard.set((allResponse as? NSMutableArray)!, forKey: "allpackages")
                            let healthtestversion = UserDefaults.standard.value(forKey: "healthtestversion")as! String
                            UserDefaults.standard.set(healthtestversion, forKey: "packageupdateversion")
                            self.tableView.delegate      =   self
                            self.tableView.dataSource    =   self
                            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                            self.tableView.reloadData()
                        }
                    }
                });
            }//);
    }

    //MARK: ButtonOnClick
    func btnAddOnClick(_ Sender:UIButton)  {
        
        let buttonPosition = Sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
       
        
        if Sender.isSelected == false {
            Sender.backgroundColor = UIColor.red
            Sender.layer.borderColor = UIColor.red.cgColor
            Sender.setTitleColor(UIColor.white, for: UIControlState())
            Sender.isSelected = true
            if searchController.isActive == false  {
               self.insertOrderPackageInDB(arrPakageData.object(at: ((indexPath as NSIndexPath?)?.row)!) as! NSDictionary)
            }else{
                 self.insertOrderPackageInDB(self.arrFilterPakageData.object(at: ((indexPath as NSIndexPath?)?.row)!) as! NSDictionary)
            }
            
        }else{
            Sender.backgroundColor = UIColor.clear
            Sender.layer.borderColor = UIColor.orange.cgColor
            Sender.setTitleColor(UIColor.red, for: UIControlState())
            Sender.isSelected = false
            if searchController.isActive == false  {
                self.deleteOrderPackageFromDB(arrPakageData.object(at: ((indexPath as NSIndexPath?)?.row)!) as! NSDictionary)
            }else{
                self.deleteOrderPackageFromDB(self.arrFilterPakageData.object(at: ((indexPath as NSIndexPath?)?.row)!) as! NSDictionary)
            }
        }
        
    }
    func btnContinueOnClick(_ Sender:UIButton)  {
        if arrCartPackageOrderData.count != 0 {
            let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
            let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
            homeTapSwipeVC.identifires = "BOOK AN ORDER"
            homeTapSwipeVC.currentSelectedTapIndex = 1
            self.navigationController?.pushViewController(homeTapSwipeVC, animated: true)
            
        }else{
             self.present(BaseUIController().showAlertView("Please Select a test to Continue Booking order."), animated: true, completion: nil)
        }
        
        
    }
    func btnPackageDetailsOnclick(_ button : UIButton)  {
        bgView.removeFromSuperview()
    }
    func btnBookOnClick(_ button : UIButton)  {
        if buttonAdd.isSelected == false {
            buttonAdd.backgroundColor = UIColor.red
            buttonAdd.layer.borderColor = UIColor.red.cgColor
            buttonAdd.setTitleColor(UIColor.white, for: UIControlState())
            buttonAdd.isSelected = true
            if searchController.isActive == false  {
                self.insertOrderPackageInDB(arrPakageData.object(at: (buttonAdd.tag - 1001)) as! NSDictionary)
            }else{
                self.insertOrderPackageInDB(self.arrFilterPakageData.object(at: (buttonAdd.tag - 1001)) as! NSDictionary)
            }
        }
        bgView.removeFromSuperview()
    }
    func btnShareOnClick(_ button : UIButton) {
        
        let activityViewController = HomeTabSwipeViewController().shareTextImageAndURL(pdfLink, sharingImage: nil, sharingURL: nil)
        self.present(activityViewController, animated: true, completion: nil)
        bgView.removeFromSuperview()
    }
    //MARK: dataBaseOperation
    func insertOrderPackageInDB(_ selectedData : NSDictionary)  {
    
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
       let database = appDelegate.openDataBase()
        
        let memberId  = UserDefaults.standard.value(forKeyPath: "selectedMemberId")as! String
        let PackageId = selectedData.value(forKey: "pkg_id")
        let PackageName = selectedData.value(forKey: "pkg_name")
        let PackagePrice = selectedData.value(forKey: "pkg_price")
        let Package_type = selectedData.value(forKey: "pac_test_type")
        
            
            do {
                 try database.executeUpdate("insert into Order_Package_Purchased (OrderId , PackageId , PackageName , PackagePrice,PackageType ,addedToCart) values (?,?,?,?,?,?)", values: [memberId,PackageId!,PackageName!,PackagePrice!,Package_type!,"0"])
                
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            database.close()
           self.getSelectedPackageOrder()
    }
    
    func deleteOrderPackageFromDB(_ selectedData : NSDictionary)  {
        
        

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
                do {
                    let memberId  = UserDefaults.standard.value(forKeyPath: "selectedMemberId")as! String
                    let PackageId = selectedData.value(forKey: "pkg_id")as! String
                    
                    try database.executeUpdate(String(format:"delete from Order_Package_Purchased where OrderId = %@  and PackageId = '%@'",memberId,PackageId), values: nil)
                } catch let error as NSError {
                    print("failed: \(error.localizedDescription)")
                }
                database.close()
                self.getSelectedPackageOrder()
        }
    func getSelectedPackageOrder()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        do {
            let rs = try database.executeQuery("select * from Order_Package_Purchased", values: nil)
            arrCartPackageOrderData = NSMutableArray()
            while rs.next() {
                let pkgOrderInfo = PackgeOrederInfo()
                pkgOrderInfo.orderId = rs.string(forColumn: "OrderId")
                pkgOrderInfo.packageId = rs.string(forColumn: "PackageId")
                pkgOrderInfo.packageName = rs.string(forColumn: "PackageName")
                pkgOrderInfo.packagePrice = rs.string(forColumn: "PackagePrice")
                pkgOrderInfo.packageType = rs.string(forColumn: "PackageType")
                arrCartPackageOrderData.add(pkgOrderInfo)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        self.updateUILayout()
    }
    
    func filterData(_ memberId : String){
        tableView .reloadData()
    }
    func clearSelectedPackageCart()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        do {
            try database.executeUpdate("delete from Order_Package_Purchased", values: nil)
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
       
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
        homeTapSwipeVC.identifires = "BOOK AN ORDER"
        homeTapSwipeVC.currentSelectedTapIndex = 0
        self.navigationController?.pushViewController(homeTapSwipeVC, animated: true)
    }
    
    //MARK: showAlert
    func showAlertView()  {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Cart", message: "You have selected package previously, Discard?", preferredStyle: .alert)
        //Create and add the Continue action
        let continueAction: UIAlertAction = UIAlertAction(title: "Continue", style: .cancel) { action -> Void in
            //Do some stuff
           
        }
        actionSheetController.addAction(continueAction)
//        //Create and add the Discart action
        let discardAction: UIAlertAction = UIAlertAction(title: "Discard", style: .default) { action -> Void in
            //Do some stuff
            
            self.clearSelectedPackageCart()
        }
        actionSheetController.addAction(discardAction)
        //self.presentViewController(actionSheetController, animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.present(actionSheetController, animated: true, completion: nil)
    }
    
}
