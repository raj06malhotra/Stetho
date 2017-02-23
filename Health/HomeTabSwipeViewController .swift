//
//  HomeTabSwipeViewController.swift
//  Health
//
//  Created by HW-Anil on 6/18/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class HomeTabSwipeViewController: UIViewController, CarbonTabSwipeNavigationDelegate, CustomDelegate ,UIGestureRecognizerDelegate {
    var items = NSArray()
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation = CarbonTabSwipeNavigation()
    var identifires: String = ""
    var selectedbutton = UIButton()
    var lblUserName: UILabel = UILabel()
    var baseScrollView: UIScrollView = UIScrollView()
    var currentVC : CustomDelegate?
    var arrMyFamilyRecord = NSMutableArray()
    var actionButton: ActionButton!
    var rightBarView = UIView()
    var currentSelectedTapIndex = 0
    var comingFromBack : Bool = true
    var lblNotifications = UILabel()
    var isComingFromAddRecordViewWithMemberId = ""
    
    
    
    var scrollView:UIScrollView = UIScrollView()
    var bgView = UIView()
    var baseView = UIView()
    // Profile Info
    var maleImageView: UIImageView = UIImageView()
    var femaleImageView: UIImageView = UIImageView()
    var btnMale: UIButton = UIButton()
    var btnFemale: UIButton = UIButton()
    var selectedGender: String = "M"
    var memberIDForUpdateProfile = ""
    var txtFullName: UITextField!
    var txtEmail: UITextField!
    var txtMobileNo: UITextField!
    var txtDOB: UITextField!
    let datePickerView  : UIDatePicker = UIDatePicker()
    let heightOFTopsScrollView = UIScreen.main.bounds.height/6
    
    
    
    //let A:UIViewController = UIViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")
        if !(identifires == "BOOK AN ORDER" && currentSelectedTapIndex == 1) {
           // when load pickup view need selected member on screen
           UserDefaults.standard.setValue(customerId, forKey: "selectedMemberId")
        }
        // Do any additional setup after loading the view.
        self.addUpcomingView()
        if identifires != "MyAccount" {
            let menuBarButton = UIBarButtonItem(image: UIImage(named: "menu_icon.png"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(HomeTabSwipeViewController.didTapMenuBarButton(_:)))
            self.navigationItem.leftBarButtonItem = menuBarButton
        }
        
        self.style()
        comingFromBack = false
    }
    func dissableTapSegmentController(_ searchStatus : String)  {
        
        if searchStatus == "active" {
            carbonTabSwipeNavigation.carbonSegmentedControl?.isUserInteractionEnabled = false
           
        }else{
            carbonTabSwipeNavigation.carbonSegmentedControl?.isUserInteractionEnabled = true
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        //set Navigation Font size
        self.addBarButtonOnNavigation()
        self.navigationController!.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
        
        if identifires == "BOOK AN ORDER" {
            self.title = identifires
            if comingFromBack == false {
                comingFromBack = true
            }else{
                carbonTabSwipeNavigation.currentTabIndex = 1
                currentVC?.reloadLocalDataAferbackfFromView!()
            }
        }
        if  identifires == "MY RECORDS"{
            self.title = identifires
            if comingFromBack == false {
                comingFromBack = true
            }else{
                currentVC?.reloadLocalDataAferbackfFromView!()
            }
            
            // call google analytics for screen tracking
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.trackViewOnGoogleAnalytics("MyReports Screen")
        }
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func style() {
       
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = KRED_COLOR
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: KRED_COLOR]//KRED_COLOR]
        self.navigationController!.navigationBar.barTintColor = UIColor.white
       // self.navigationController!.navigationBar.barStyle = .BlackTranslucent
        //set width of segment control
        carbonTabSwipeNavigation.carbonSegmentedControl?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30)
        //carbonTabSwipeNavigation.carbonSegmentedControl?.layer.cornerRadius = 0.0 // for backgorund color
        carbonTabSwipeNavigation.carbonSegmentedControl?.clipsToBounds = true
        carbonTabSwipeNavigation.toolbar.isTranslucent = false
        carbonTabSwipeNavigation.setIndicatorColor(KRED_COLOR)
        carbonTabSwipeNavigation.setTabExtraWidth(0)
        carbonTabSwipeNavigation.setTabBarHeight(40)
        carbonTabSwipeNavigation.carbonSegmentedControl?.tintColor = UIColor.white
        carbonTabSwipeNavigation.carbonSegmentedControl?.backgroundColor = KRED_COLOR
       // carbonTabSwipeNavigation.setNormalColor(UIColor .whiteColor())
        carbonTabSwipeNavigation.setSelectedColor(KRED_COLOR, font: UIFont().largeFont)
        carbonTabSwipeNavigation.setNormalColor(UIColor.white, font: UIFont().largeFont)
        carbonTabSwipeNavigation.carbonTabSwipeScrollView.isScrollEnabled = false

        
        
        
//        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(120, forSegmentAtIndex: 0)
//        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(120, forSegmentAtIndex: 1)
//        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(80, forSegmentAtIndex: 2)
      
        if identifires == "BOOK AN ORDER" {
           // carbonTabSwipeNavigation.carbonSegmentedControl?.userInteractionEnabled = false
//            carbonTabSwipeNavigation.pageViewController.delegate = nil
//            carbonTabSwipeNavigation.pageViewController.dataSource = nil
            carbonTabSwipeNavigation.carbonSegmentedControl?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
            //carbonTabSwipeNavigation.setTabExtraWidth(70)
        }
       
        
        
    }
    func addUpcomingView()  {
         let heightOFTopsScrollView = UIScreen.main.bounds.height/6
        
       
        if identifires == "Notifications" {
            self.title = "Notifications"
            items =  ["Request(0)", "Notifications(0)"]
            carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items as [AnyObject], delegate: self)
            
            carbonTabSwipeNavigation.insert(intoRootViewController: self)
            carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(self.view.frame.width/2, forSegmentAt: 0)
            carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(self.view.frame.width/2, forSegmentAt: 1)
            
        }else if identifires == "MY RECORDS"{
            self.title = "MY RECORDS"
            items =  ["Report", "Prescription", "Invoice","Diet Charts"]
            carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items as [AnyObject], delegate: self)
            let customSwipeView: UIView = UIView(frame: CGRect(x: 0,y: heightOFTopsScrollView ,width: self.view.frame.width ,height: self.view.frame.height-154))
            self.view .addSubview(customSwipeView)
            carbonTabSwipeNavigation.insert(intoRootViewController: self, andTargetView: customSwipeView)
            carbonTabSwipeNavigation.currentTabIndex = UInt(currentSelectedTapIndex)
            self.loadMyFamilyData()
              self.addActionButtonOnView()
            
            
        }else if identifires == "BOOK AN ORDER"{
            
            items =  ["   Products   ", "Pickup Details"]
            carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items as [AnyObject], delegate: self)
            let customSwipeView: UIView = UIView(frame: CGRect(x: 0,y: heightOFTopsScrollView ,width: self.view.frame.width ,height: self.view.frame.height-154))
            self.view .addSubview(customSwipeView)
            carbonTabSwipeNavigation.insert(intoRootViewController: self, andTargetView: customSwipeView)
            self.loadMyFamilyData()
            //send to Pickup Details View
            if currentSelectedTapIndex == 1 {
                carbonTabSwipeNavigation.currentTabIndex = 1
            }

        }else if (identifires == "MyAccount"){
            self.title = "PROFILE"
            self.navigationController!.navigationBar.topItem!.title = "Back"
            items =  ["Profile", "Address"]
            carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items as [AnyObject], delegate: self)
            carbonTabSwipeNavigation.insert(intoRootViewController: self)
            carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(self.view.frame.width/2, forSegmentAt: 0)
            carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(self.view.frame.width/2, forSegmentAt: 1)
            carbonTabSwipeNavigation.currentTabIndex = UInt(currentSelectedTapIndex)
        }
            
        
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        
        if identifires == "Notifications" {
            let notificationsVC = NotificationsViewController()
            return notificationsVC
            
        }else if identifires == "MY RECORDS"{
            if index == 0 {
            let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
            let myRecordsVC = storyboard1.instantiateViewController(withIdentifier: "MyRecordsViewController") as! MyRecordsViewController
                myRecordsVC.tabBarHeight = heightOFTopsScrollView
                currentVC = myRecordsVC
            return myRecordsVC
                
        }else if index == 1 {
            let myRecrodsPrescriptionVC = MyRecordPrescriptionViewController()
              //currentVC = myRecrodsPrescriptionVC
                myRecrodsPrescriptionVC.tabBarHeight = heightOFTopsScrollView
            return myRecrodsPrescriptionVC
            }
            else if index == 2{
            let myRecrodsInvoiceVC = MyRecordsInvoiceViewController()
               // currentVC = myRecrodsInvoiceVC
                myRecrodsInvoiceVC.tabBarHeight = heightOFTopsScrollView
            return myRecrodsInvoiceVC
            }else{
            let myRecrodsDietChartsVC = MyRecordsDietChartsViewController()
               // currentVC = myRecrodsDietChartsVC
                myRecrodsDietChartsVC.tabBarHeight = heightOFTopsScrollView
            return myRecrodsDietChartsVC
            }
            
            
        }else if identifires == "BOOK AN ORDER"{
            if index == 0 {
                let bookAnOrderVC = BookAnOrderViewController()
                bookAnOrderVC.selectedIndexPath = currentSelectedTapIndex
                bookAnOrderVC.homeTabVC = self
                bookAnOrderVC.tabBarHeight = heightOFTopsScrollView
                 currentVC = bookAnOrderVC
                return bookAnOrderVC
            }else {
                
                let pickUpDetailsVC = PickUpDetailsViewController()
                pickUpDetailsVC.tabBarHeight = heightOFTopsScrollView
                return pickUpDetailsVC
            }
        }else if (identifires == "MyAccount"){
            if index == 0 {
                let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
                let myProfileVC = storyboard1.instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
                return myProfileVC

            }else{
                let saveAddressVC = SaveAddressViewController()
                return saveAddressVC
            }
        }else {
            let notificationsVC = NotificationsViewController()
            return notificationsVC
        }
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAt index: UInt) {
        NSLog("Did move at index: %ld", index)
        if identifires == "Notifications" {
            
        }else if (identifires == "BOOK AN ORDER"){
            if (index == 1) {
                let selectedMemberId = UserDefaults.standard.value(forKey: "selectedMemberId")as! String
                // call
                self.loadMyProfile(selectedMemberId)
            }
        }
        else if (identifires == "MY RECORDS"){
            let vc = carbonTabSwipeNavigation.viewControllers[index]as! CustomDelegate
            currentVC = vc
            currentVC?.filterData!("")
        }
    }
    
    func loadMyFamilyData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
         arrMyFamilyRecord = NSMutableArray()
        do {
            let rs = try database.executeQuery("select * from MyFamily", values: nil)
            while rs.next() {
                let familyMemberObj = MyFamilyInfo()
                familyMemberObj.memberId = rs.string(forColumn: "MemberId")
                familyMemberObj.memberName = rs.string(forColumn: "MemberName")
                familyMemberObj.memberRelation = rs.string(forColumn: "Relation")
                familyMemberObj.memberPhoto = rs.string(forColumn: "MemberPhoto")
                familyMemberObj.memberDOB = rs.string(forColumn: "MemberDOB")
                familyMemberObj.memberEmail = rs.string(forColumn: "MemberEmail")
                familyMemberObj.memberGender = rs.string(forColumn: "MemberGender")
                familyMemberObj.memberVerefyStatus = rs.string(forColumn: "Verified")
                familyMemberObj.memberMobileNo = rs.string(forColumn: "MemberMobileNo")
                
                familyMemberObj.memberActiveStatus = rs.string(forColumn: "Active")
                
                arrMyFamilyRecord.add(familyMemberObj)
                
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
       self.createATopViewLayout()
        
       
        
    }
    func getCartMemebrtCount() -> Int{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        var  mCount = 0
        do {
            let rs = try database.executeQuery("SELECT COUNT(DISTINCT orderId) FROM order_Package_Purchased where addedToCart = '1'", values: nil)
            while rs.next() {
                mCount = Int(rs.int(forColumn: "COUNT(DISTINCT orderId)"))
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        return mCount
    }
    //MARK: createLayoutView
    func createATopViewLayout()
    {
        
        let baseView: UIView = UIView(frame: CGRect(x: 0,y: 0,width: self.view.frame.width ,height: heightOFTopsScrollView))
        self.view .addSubview(baseView)
        
        baseScrollView = UIScrollView(frame: CGRect(x: 0,y: 0,width: self.view.frame.width ,height: heightOFTopsScrollView))
        baseScrollView.showsHorizontalScrollIndicator = false
        baseView .addSubview(baseScrollView)
        let lblLine = UILabel.init(frame: CGRect(x: 0, y: heightOFTopsScrollView, width: self.view.frame.width, height: 0.5))
        lblLine.backgroundColor = UIColor.gray
        baseView.addSubview(lblLine)
        
        var xPos: CGFloat = 20.0
        let yPos: CGFloat = 8
      //  var i = 101
      //  let arrMyFamilyRecord = NSUserDefaults.standardUserDefaults().objectForKey("myfamily")
        
         var myFamilyMemberObj = MyFamilyInfo()
        for i in (0..<arrMyFamilyRecord.count) {
            
            myFamilyMemberObj = arrMyFamilyRecord[i] as! MyFamilyInfo
            var name = myFamilyMemberObj.memberName
        
           
            
            print(name)
           var firstName = (name.components(separatedBy: " ").first?.uppercased())! as String
//            var firstName: String = name.componentsSeparatedByString(" ").first!.uppercased() as String
            if firstName == "" {
               let sliced = String(name.characters.dropFirst())
                name = sliced
                

            }
            firstName = name.components(separatedBy: " ").first!.uppercased() as String
           // let secondName: String = name!.componentsSeparatedByString(" ")[1].uppercaseString as String
            print(firstName)
            let firstLetter = firstName.startIndex
            let finalLetter = firstName[firstLetter]
            print(finalLetter)
            let btnProfileimage: UIButton = UIButton(frame: CGRect(x: xPos, y: yPos, width: heightOFTopsScrollView - 40, height: heightOFTopsScrollView - 40));
            
//            btnProfileimage.tag = myFamilyObj.memberId
            
            
            btnProfileimage.tag = Int(myFamilyMemberObj.memberId)!
            self.view.addSubview(btnProfileimage)
            lblUserName = BaseUIController().ALabelFrame(CGRect(x: xPos - 12  , y: btnProfileimage.frame.height + btnProfileimage.frame.origin.y + 5 , width: heightOFTopsScrollView - 25  , height: 15), withString: "") as! UILabel
            lblUserName.font = UIFont().smallFont
            lblUserName.minimumScaleFactor = 12
            lblUserName.adjustsFontSizeToFitWidth = true
            lblUserName.textAlignment = .center
            lblUserName.text = firstName
            lblUserName.tag = Int(myFamilyMemberObj.memberId)!
            baseScrollView.addSubview(lblUserName)
            
            btnProfileimage.setTitle(String(finalLetter), for: UIControlState())
            btnProfileimage.layer.cornerRadius = (btnProfileimage.bounds.width/2);
            btnProfileimage.layer.masksToBounds = true
            btnProfileimage.addTarget(self, action: #selector(buttonOnClick), for: .touchUpInside)
            btnProfileimage.backgroundColor = UIColor (red: (224.0/255.0), green: (224.0/255.0), blue: (224.0/255.0), alpha: 1)
            let imageString = myFamilyMemberObj.memberPhoto
            let data = Data(base64Encoded: imageString, options: NSData.Base64DecodingOptions(rawValue: 0))
            btnProfileimage.setImage(UIImage.init(data: data!), for: UIControlState())
            //set first selected member (not first depend on screeen so user selectedMemberID)
             // when load pickup view need selected member on screen
            let customerId = UserDefaults.standard.value(forKey: "selectedMemberId")as! String //NSUserDefaults.standardUserDefaults().valueForKey("loginCustomerId")as! String
            if customerId == myFamilyMemberObj.memberId  && isComingFromAddRecordViewWithMemberId == ""{
                btnProfileimage.frame = CGRect(x: xPos, y: yPos, width: heightOFTopsScrollView - 20, height: heightOFTopsScrollView - 20)
                btnProfileimage.layer.cornerRadius = (btnProfileimage.bounds.width/2);
                selectedbutton = btnProfileimage
                btnProfileimage.backgroundColor = KRED_COLOR
                // btnProfileimage.setImage(UIImage(named: "user_icon"), forState: .Normal)
                lblUserName.isHidden = true
            }
            // if comnign from AddRecordView 
            if isComingFromAddRecordViewWithMemberId == myFamilyMemberObj.memberId {
                btnProfileimage.frame = CGRect(x: xPos, y: yPos, width: heightOFTopsScrollView - 20, height: heightOFTopsScrollView - 20)
                btnProfileimage.layer.cornerRadius = (btnProfileimage.bounds.width/2);
                selectedbutton = btnProfileimage
                btnProfileimage.backgroundColor = KRED_COLOR
                // btnProfileimage.setImage(UIImage(named: "user_icon"), forState: .Normal)
                lblUserName.isHidden = true
                 UserDefaults.standard.setValue(isComingFromAddRecordViewWithMemberId, forKey: "selectedMemberId")
            }
            
            xPos += btnProfileimage.frame.width + 20
            baseScrollView.addSubview(btnProfileimage)
            
            //i ++
            
        }
        let btnAddMember = BaseUIController().AButtonFrame(CGRect(x: xPos , y: yPos , width: heightOFTopsScrollView - 30, height: heightOFTopsScrollView - 30), withButtonTital: "")as! UIButton
        btnAddMember.setImage(UIImage(named: "add_family_icon.png"), for: UIControlState())
        btnAddMember.addTarget(self, action: #selector(self.btnAddNewMemberOnClick(_:)), for: .touchUpInside)
        baseScrollView.addSubview(btnAddMember)
       let  lblAddMember = BaseUIController().ALabelFrame(CGRect(x: xPos-5 , y: btnAddMember.frame.height + btnAddMember.frame.origin.y + 5 , width: 80 , height: 15), withString: "") as! UILabel
        lblAddMember.font = UIFont().smallFont
        lblAddMember.textAlignment = .center
        lblAddMember.text = "ADD MEMBER"
        baseScrollView.addSubview(lblAddMember)
        
        xPos += 80 + 20
        
        baseScrollView.contentSize = CGSize(width: xPos, height: 90)
        
    }
    
        func addBarButtonOnNavigation() {
        
        // Add custom View on right navigation Bar
        
        rightBarView.removeFromSuperview()
        rightBarView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 44))
        rightBarView.tag = 500
        
        let btnHome = BaseUIController().AButtonFrame(CGRect(x: 0, y: 2, width: 30,height: 40), withButtonTital: "")as! UIButton
        btnHome.setImage(UIImage (named: "home_icon"), for: UIControlState())
        btnHome.addTarget(self, action: #selector(HomeTabSwipeViewController.didTapHomeButton(_:)), for: UIControlEvents.touchUpInside)
        rightBarView.addSubview(btnHome)
        btnHome.imageEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 5)
        
        
        let btnCart = BaseUIController().AButtonFrame(CGRect(x: 30, y: 2, width: 30,height: 40), withButtonTital: "")as! UIButton //  5 12 //CGRect(x: 30, y: 2, width: 30,height: 40)
        btnCart.imageEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 5)
        
        btnCart.setImage(UIImage (named: "cart_icon"), for: UIControlState())
        btnCart.addTarget(self, action: #selector(HomeTabSwipeViewController.didTapCartButton(_:)), for: UIControlEvents.touchUpInside)
        rightBarView.addSubview(btnCart)
        
        let lblCart = BaseUIController().ALabelFrame(CGRect(x: 50 ,y: 0, width: 16, height: 16), withString: "12")as! UILabel
        lblCart.text = String(self.getCartMemebrtCount())// get count of Selected Member in cart
            if  self.getCartMemebrtCount() == 0{
                lblCart.isHidden = true
            }
        lblCart.layer.cornerRadius = 8
        lblCart.layer.masksToBounds = true
        lblCart.font = UIFont().smallFont
        lblCart.textAlignment = .center
        lblCart.textColor = UIColor.white
        lblCart.backgroundColor = KRED_COLOR
        rightBarView.addSubview(lblCart)
        
        
        let btnNotificaitons = BaseUIController().AButtonFrame(CGRect(x:60 , y: 2, width: 30,height: 40), withButtonTital: "")as! UIButton  // 35
        //btnNotificaitons.backgroundColor = UIColor .redColor()
        btnNotificaitons.setImage(UIImage (named: "notifications_icon"), for: UIControlState())
        btnNotificaitons.addTarget(self, action: #selector(HomeTabSwipeViewController.didTapNotificationBarButton(_:)), for: UIControlEvents.touchUpInside)
        rightBarView.addSubview(btnNotificaitons)
        btnNotificaitons.imageEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 5)
        
        lblNotifications = BaseUIController().ALabelFrame(CGRect(x: 75 ,y: 0, width: 16, height: 16), withString: "0")as! UILabel
        lblNotifications.text = String(NotificationsViewController().getNotificationsCount())// get total  Notifications count
        if  NotificationsViewController().getNotificationsCount() == 0{
                lblNotifications.isHidden = true
            }
        lblNotifications.layer.cornerRadius = 8
        lblNotifications.layer.masksToBounds = true
        lblNotifications.backgroundColor = KRED_COLOR
        lblNotifications.font = UIFont().smallFont
        lblNotifications.textAlignment = .center
        lblNotifications.textColor = UIColor.white
        
        rightBarView.addSubview(lblNotifications)
        let barButtonItem = UIBarButtonItem(customView: rightBarView)
        self.navigationItem.rightBarButtonItem = barButtonItem
        
    }


    
    
    //MARK: - NavigationBarButtonOnClick
    
    func didTapNotificationBarButton(_ sender: AnyObject){
        
        if NotificationsViewController().getNotificationsCount() != 0 {
            let notificationVC = NotificationsViewController()
            self.navigationController?.pushViewController(notificationVC, animated: true)
        }else{
            self.present(BaseUIController().showAlertView("No new notifications"), animated: true, completion: nil)
        }
    }
    
    func didTapCartButton(_ sender: AnyObject){
        if self.getCartMemebrtCount() != 0 {
            let checkoutVC = CheckOutViewController()
            self.navigationController?.pushViewController(checkoutVC, animated: true)
        }else{
           self.present(BaseUIController().showAlertView("There are currently no orders in your cart."), animated: true, completion: nil)
        }
    }
    func didTapHomeButton(_ sender: AnyObject)  {
        var isFindHomeViewController = true
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: HomeViewController.self) {
                self.navigationController?.navigationBar.isTranslucent = true
                isFindHomeViewController = false
                let _ = self.navigationController?.popToViewController(controller as UIViewController, animated: true)
            }
        }
        if isFindHomeViewController {
             self.navigationController?.navigationBar.isTranslucent = true
            let homeVC = HomeViewController()
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    
    func didTapMenuBarButton(_ sender: AnyObject) {
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    func tappedOnBGView(_ sender: UITapGestureRecognizer)  {
        
        self.view.window!.viewWithTag(400)?.isHidden = true
        self.view.window!.viewWithTag(400)?.removeFromSuperview()
        
    }
    //MARK: - buttonOnClick
    func buttonOnClick(_ sender : UIButton!)  {
        
        
        if !(carbonTabSwipeNavigation.currentTabIndex == 1 && identifires == "BOOK AN ORDER") {
            
            if selectedbutton != sender{
                selectedbutton.frame = CGRect(x: selectedbutton.frame.origin.x + 5, y: selectedbutton.frame.origin.y+5, width: heightOFTopsScrollView - 40, height: heightOFTopsScrollView - 40)
                selectedbutton.layer.cornerRadius = (selectedbutton.frame.width/2)
                selectedbutton.backgroundColor = UIColor (red: (224.0/255.0), green: (224.0/255.0), blue: (224.0/255.0), alpha: 1)
                
                sender.frame = CGRect(x: sender.frame.origin.x - 10, y: sender.frame.origin.y-5, width: heightOFTopsScrollView - 20 , height: heightOFTopsScrollView - 20)
                sender.layer.cornerRadius = (sender.frame.width/2)
                sender.backgroundColor = KRED_COLOR
            }
            
            selectedbutton = sender
            
            for v in baseScrollView.subviews{
                if v is UILabel{
                    if v.tag == sender.tag {
                        v.isHidden = true
                    }else{
                        v.isHidden = false
                    }
                    
                }
            }
            UserDefaults.standard.setValue("\(sender.tag)", forKey: "selectedMemberId")
            currentVC?.filterData!("\(sender.tag)")
            
            let selectedMemberId = UserDefaults.standard.value(forKey: "selectedMemberId")as! String
            self.loadMyProfile(selectedMemberId)
        }
    }
    

    
    func addActionButtonOnView()  {
        
        // Create  flicker action Button
        let shareImage = UIImage(named: "share_icon.png")!
        let deleteImage = UIImage(named: "delete_icon.png")!
        let addNewImage = UIImage(named: "edit_icon.png")!
        
        
        
        let share = ActionButtonItem(title: "Share", image: shareImage)
        share.action = { item in self.btnShareOnClick()}
        let delete = ActionButtonItem(title: "Delete", image: deleteImage)
        delete.action = { item in self.btnDeleteOnClick() }
        let addNew = ActionButtonItem(title: "Add New", image: addNewImage)
        addNew.action = { item in self.btnAddNewOnClick() }
        
        
        
        actionButton = ActionButton(attachedToView: self.view, items: [share , delete, addNew])
        actionButton.action = { button in button.toggleMenu() }
        actionButton.setTitle("+", forState: UIControlState())
        
        
        actionButton.backgroundColor =  KRED_COLOR //UIColor(red: 238.0/255.0, green: 130.0/255.0, blue: 34.0/255.0, alpha:1.0)
        // assing databaseId
        //selectedDatabaseID = recordObject.dataBaseId
        
        
    }
    
    func btnShareOnClick()  {
        actionButton.toggleMenu()
        currentVC?.btnShareOnClick!()
        
    }
       func btnDeleteOnClick()   {
        actionButton.toggleMenu()
        currentVC?.btnDeleteOnClick!()
    }
    
    func btnAddNewOnClick()  {
        actionButton.toggleMenu()
       // currentVC?.btnAddNewOnClick!()
        let cameraVC = CameraViewController()
        cameraVC.selectedTag = Int(carbonTabSwipeNavigation.currentTabIndex)
        cameraVC.isComingFrom = "reportView"
        //cameraVC.
        self.navigationController?.pushViewController(cameraVC, animated: true)
    }
    func btnAddNewMemberOnClick(_ button : UIButton)  {
        let myFamilyMemberInfo = MyFamilyMemberInfoViewController()
        myFamilyMemberInfo.familyMemberDetails = MyFamilyInfo() // pass nil object
        self.navigationController?.pushViewController(myFamilyMemberInfo, animated: true)
    }
   

    internal func shareTextImageAndURL(_ sharingText: String?, sharingImage: UIImage?, sharingURL: URL?) -> UIActivityViewController {
        var sharingItems = [AnyObject]()
        
        if let text = sharingText {
            sharingItems.append(text as AnyObject)
        }
        if let image = sharingImage {
            sharingItems.append(image)
        }
        if let url = sharingURL {
            sharingItems.append(url as AnyObject)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        return activityViewController
    }
    
    //call when user not fill fullinfo when going to book order  
    
    func createProfileInfoLayout()  {
        bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        bgView.tag = 500
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
       // self.view.window!.addSubview(bgView)
        self.view.addSubview(bgView)
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnMyProfileBGView(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        bgView.addGestureRecognizer(tapped)
        
        // create base view
        baseView = UIView.init(frame: CGRect(x: 15, y: 100, width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.height - 200 ))
        baseView.backgroundColor = UIColor.white
        baseView.layer.cornerRadius = 4
        baseView.layer.borderWidth = 2
        baseView.layer.borderColor = UIColor.gray.cgColor
        bgView.addSubview(baseView)
        
        let lblHeading = BaseUIController().ALabelFrame(CGRect(x: 10, y: 0, width: self.view.frame.width, height: 40), withString: "My Profile")as! UILabel
        baseView.addSubview(lblHeading)
        let lblLine = BaseUIController().ALabelFrame(CGRect(x: 0, y: 41, width: self.view.frame.width, height: 1), withString: "")as! UILabel
        lblLine.backgroundColor = KRED_COLOR
        baseView.addSubview(lblLine)
        
        
        
        scrollView = UIScrollView(frame: CGRect(x: 0 , y: 42 , width: baseView.frame.width , height: baseView.frame.height -  80)) //
        scrollView.backgroundColor = UIColor.white
        baseView.addSubview(scrollView)
        var xPos:CGFloat = 20
        var yPos:CGFloat = 10
        var labelName: [String] = ["Full Name :" , "Date of Birth :" , "Mobile Number :", "Email :"]
        
        for i in (0..<labelName.count) {
            let label = BaseUIController().ALabelFrame(CGRect(x:xPos , y: yPos ,width: 200 , height: 30 ), withString: labelName[i])as! UILabel
            label.font = UIFont().mediumFont
            scrollView.addSubview(label)
            yPos += 21+5;
            let textField = BaseUIController().ATextFiedlFrame(CGRect(x:xPos , y: yPos ,width: baseView.frame.width-40 , height: 35 ), withPlaceHolder: "")as! UITextField
            textField.tag = 200 + i
            textField.delegate = self
            textField.textAlignment = .left
            textField.borderStyle = .roundedRect
            scrollView.addSubview(textField)
            
            yPos += 35+5;
        }
        yPos += 10;
        //        let lblPincode :UILabel = BaseUIController().ALabelFrame(CGRect(x: xPos , y: yPos, width:  80 , height: 21), withString: "Pincode :")as! UILabel
        //        lblPincode.font = UIFont().mediumFont
        //        scrollView.addSubview(lblPincode)
        
        let lblGender:UILabel = BaseUIController().ALabelFrame(CGRect(x: 10 , y: yPos, width: 100, height: 21), withString: "Gender :")as! UILabel
        scrollView.addSubview(lblGender)
        
        btnMale = BaseUIController().AButtonFrame(CGRect (x: 80
            , y: yPos, width: 80, height: 25), withButtonTital: "Male")as! UIButton
        btnMale.titleLabel?.font = UIFont().mediumFont
        btnMale.addTarget(self, action: #selector(MyFamilyMemberInfoViewController.btnMaleOnClick(_:)), for: .touchUpInside)
        scrollView.addSubview(btnMale)
        maleImageView = BaseUIController().AImageViewFrame(CGRect (x: 0 , y: 5 , width: 15 , height: 15), withImageName: "")as! UIImageView
        maleImageView.image = UIImage(named: "selectedradio_icon")
        btnMale.isSelected = true
      //  selectedGender = "M"
        btnMale.addSubview(maleImageView)
        
        btnFemale = BaseUIController().AButtonFrame(CGRect (x: btnMale.frame.origin.x+90 , y: yPos, width: 90, height: 25), withButtonTital: "Female")as! UIButton
        btnFemale.titleLabel?.font = UIFont().mediumFont
        btnFemale.addTarget(self, action: #selector(MyFamilyMemberInfoViewController.btnFeMaleOnClick(_:)), for: .touchUpInside)
        scrollView.addSubview(btnFemale)
        femaleImageView = BaseUIController().AImageViewFrame(CGRect (x: 0 , y: 5 , width: 15 , height: 15), withImageName: "")as! UIImageView
        femaleImageView.image = UIImage(named: "nonselectedradio_icon")
        btnFemale.addSubview(femaleImageView)
        
        
        xPos =  90
        
        let btnCancel = BaseUIController().AButtonFrame(CGRect(x: 1 , y: baseView.frame.height - 40 , width: (baseView.frame.width)/2 - 2, height: 40), withButtonTital: "CANCEL")as! UIButton
        btnCancel.backgroundColor =  KRED_COLOR//UIColor .init(red: (235.0/255.0), green: (235.0/255.0), blue: (235.0/255.0), alpha: 1)
        btnCancel.titleLabel?.font = UIFont().largeFont
        btnCancel.setTitleColor(UIColor.white, for: UIControlState())
          btnCancel.addTarget(self, action: #selector(self.btnCancelOnClick(_:)), for: .touchUpInside)
        // scrollView.contentSize = CGSizeMake(self.view.frame.width, scrollView.frame.height + 100)
        baseView.addSubview(btnCancel)
        
        
        let btnDone = BaseUIController().AButtonFrame(CGRect(x: (baseView.frame.width)/2 + 2 , y: baseView.frame.height - 40 , width: (baseView.frame.width)/2 - 2, height: 40), withButtonTital: "DONE")as! UIButton
        btnDone.backgroundColor =  KRED_COLOR//UIColor .init(red: (235.0/255.0), green: (235.0/255.0), blue: (235.0/255.0), alpha: 1)
        btnDone.titleLabel?.font = UIFont().largeFont
        btnDone.setTitleColor(UIColor.white, for: UIControlState())
           btnDone.addTarget(self, action: #selector(self.btnDoneOnclick(_:)), for: .touchUpInside)
        // scrollView.contentSize = CGSizeMake(self.view.frame.width, scrollView.frame.height + 100)
        baseView.addSubview(btnDone)
        
        
        
        
        txtFullName = scrollView.viewWithTag(200)as! UITextField
        txtDOB = scrollView.viewWithTag(201)as! UITextField
        txtMobileNo = scrollView.viewWithTag(202)as! UITextField
        txtEmail = scrollView.viewWithTag(203)as! UITextField
        txtEmail.keyboardType = .emailAddress
        OpenDatePicker(txtDOB)
        addToolBar(txtDOB)
       // self.loadMyProfile("")
        
      
        //        //Add PickerView
        //        cityPickerView.dataSource = self
        //        cityPickerView.delegate = self
        //        txtCity.inputView = cityPickerView
        //        addToolBar(txtCity)
        //        
        //        // Add a "textFieldDidChange" notification method to the text field control.
        //        txtLocality.addTarget(self, action: #selector(self.textFieldDidChange), forControlEvents: .EditingChanged)
        //       
    }
    
    func btnMaleOnClick(_ button: UIButton)  {
        if btnMale.isSelected  == false {
            maleImageView.image = UIImage(named: "selectedradio_icon")
            femaleImageView.image = UIImage(named: "nonselectedradio_icon")
            btnFemale.isSelected = false
            
        }else{
            btnFemale.isSelected = false
        }
        selectedGender = "M"
    }
    func btnFeMaleOnClick(_ button: UIButton){
        if button.isSelected == false {
            femaleImageView.image = UIImage(named: "selectedradio_icon")
            maleImageView.image = UIImage(named: "nonselectedradio_icon")
            btnMale.isSelected = false
        }else{
            btnMale.isSelected = false
        }
        selectedGender = "F"
    }
    func btnCancelOnClick(_ button : UIButton)  {
      //  pickup_Id = "0"
//        bgView.hidden = true
       // self.viewDidLoad()
      // self.carbonTabSwipeNavigation(carbonTabSwipeNavigation, viewControllerAtIndex: 0)
        //currentSelectedTapIndex = 0
        bgView.removeFromSuperview()
        
        // i will try to fix proper way
        
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
        homeTapSwipeVC.identifires = "BOOK AN ORDER"
        homeTapSwipeVC.currentSelectedTapIndex = 0
        self.navigationController?.pushViewController(homeTapSwipeVC, animated: true)

    }
    func btnDoneOnclick(_ button : UIButton)  {
        
        if txtFullName.text?.isEmpty == true {
            self.present(BaseUIController().showAlertView("Please Enter Full Name"), animated: true, completion: nil)
        }else if (txtDOB.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please select Date of Birth"), animated: true, completion: nil)
            
        }else if(txtMobileNo.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please Enter Mobile Number "), animated: true, completion: nil)
            
        }else if (selectedGender.isEmpty == true){
            
            self.present(BaseUIController().showAlertView("Please Select Gender!"), animated: true, completion: nil)
        }
        else if (txtEmail.text?.isEmpty == false){
            if(self.validateEmail(txtEmail.text!) == false){
                self.present(BaseUIController().showAlertView("Please Enter Valid Email!"), animated: true, completion: nil)
            }else{
            bgView.removeFromSuperview()
            self.updateFamilyMemberData()
            }
        }else {
            bgView.removeFromSuperview()
            self.updateFamilyMemberData()
        }
    }
    
    //MARK: removeBGView
    func tappedOnMyProfileBGView(_ sender: UITapGestureRecognizer)  {
        
       // bgView.hidden = true
       // bgView.removeFromSuperview()
    }
    // populate view if myprofile not fill fully 
    
    func loadMyProfile(_ member_ID : String)  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
      let  myFamilyObject = MyFamilyInfo()
       // let memberId = NSUserDefaults.standardUserDefaults().valueForKey("loginCustomerId")as! String
      //  member_ID = memberId
        do {
            let rs = try database.executeQuery(String(format: "select * from MyFamily where MemberId = %@",member_ID ), values: nil)
            while rs.next() {
                myFamilyObject.memberId = rs.string(forColumn: "MemberId")
                myFamilyObject.memberName = rs.string(forColumn: "MemberName")
                myFamilyObject.memberRelation = rs.string(forColumn: "Relation")
                myFamilyObject.memberPhoto = rs.string(forColumn: "MemberPhoto")
                myFamilyObject.memberDOB = rs.string(forColumn: "MemberDOB")
                myFamilyObject.memberEmail = rs.string(forColumn: "MemberEmail")
                myFamilyObject.memberGender = rs.string(forColumn: "MemberGender")
                myFamilyObject.memberMobileNo = rs.string(forColumn: "MemberMobileNo")
                myFamilyObject.memberVerefyStatus = rs.string(forColumn: "Verified")
                myFamilyObject.memberActiveStatus = rs.string(forColumn: "Active")
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        
        if (myFamilyObject.memberDOB == "" || myFamilyObject.memberGender == "" || myFamilyObject.memberGender == "" || myFamilyObject.memberName == "" || myFamilyObject.memberMobileNo == "") {
             self.createProfileInfoLayout()
             self.populateProfileInfo(myFamilyObject)
        }
    }
    
    func populateProfileInfo(_ myFamilyObject : MyFamilyInfo)  {
        
        print(myFamilyObject.memberName)
        print(myFamilyObject.memberEmail)
        print(myFamilyObject.memberGender)
        print(myFamilyObject.memberDOB)
        memberIDForUpdateProfile = myFamilyObject.memberId
        txtFullName.text = myFamilyObject.memberName
        txtEmail.text = myFamilyObject.memberEmail
        txtMobileNo.text = myFamilyObject.memberMobileNo
        txtMobileNo.isUserInteractionEnabled = false
        txtDOB.text = myFamilyObject.memberDOB
        let dateString = myFamilyObject.memberDOB
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let date = df.date(from: dateString)
        if let unwrappedDate = date {
            datePickerView.setDate(unwrappedDate, animated: false)
        }
        if myFamilyObject.memberGender == "M" {
            selectedGender = "M"
            maleImageView.image = UIImage(named: "selectedradio_icon.png")
            femaleImageView.image = UIImage(named: "nonselectedradio_icon.png")
        }else if (myFamilyObject.memberGender == "F"){
            selectedGender = "F"
            femaleImageView.image = UIImage(named: "selectedradio_icon.png")
            maleImageView.image = UIImage(named: "nonselectedradio_icon.png")
        }
        
    }
    
    //MARK: - GestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        print(touch.view)
        //UITableViewCellContentView
        if (touch.view == bgView ){
            
            return true
        }
        else{
            
            return false
        }
    }
    
    //MARK: - DatePicker
    func OpenDatePicker(_ sender: UITextField) {
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.maximumDate = Date()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.handleDatePicker(_:)), for: UIControlEvents.valueChanged)
    }
    
    func handleDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        txtDOB.text = dateFormatter.string(from: sender.date)
        print(dateFormatter.string(from: sender.date))
    }
    
    func validateEmail(_ enteredEmail:String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
        
    }
    
    func updateFamilyMemberData() {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        do {
            try database.executeUpdate(String(format:"update MyFamily set MemberName = '%@',MemberEmail = '%@', MemberGender = '%@',MemberMobileNo = '%@',MemberDOB= '%@',SyncStatus = 'Y'  where MemberId = '%@'",txtFullName.text!,txtEmail.text!,selectedGender,txtMobileNo.text!,txtDOB.text!,memberIDForUpdateProfile), values: nil)
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        //sync data on server
       // HomeViewController().getNonSyncDataFromMyFamilyTable()
        SyncMyFamilyData.shareMyFamilyData.getNonSyncDataFromMyFamilyTable()
        
    }
}
