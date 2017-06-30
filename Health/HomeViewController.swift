 /*
Copyright (c) 2015 Kyohei Yamaguchi. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import UIKit
import SOAPEngine64
import ZDCChat
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



class HomeViewController: UIViewController, NSURLConnectionDelegate, XMLParserDelegate,serverTaskComplete , UIScrollViewDelegate ,LineChartDelegate , UITableViewDelegate , UITableViewDataSource,UIGestureRecognizerDelegate, UIActionSheetDelegate, UISearchBarDelegate {
     //MARK: - VariableDeclaration
    var activityIndicator : ProgressViewController?
    var updatedRecordType = ""
    var member_Id = ""
    var dbReminderId = Int()
    var deletedReminderId = ""
    var deletedReportId = ""
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    var isComingFromClass = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var arrGetAllTestList = NSMutableArray()
    var arrTestList = NSMutableArray()
    //var graphView = UIView()
   // var graphValueScrollView = UIScrollView()
   // var graphScrollView = UIScrollView()
    // new screen (17 Nov 2016)
    var tblView = UITableView()
    var arrAllTestByFamily = NSArray()
    var baseScrollView: UIScrollView = UIScrollView()
    
    //Adding Search Bar
    var searchController: UISearchController!
    var searchBar : UISearchBar!
    
    var graph_width : CGFloat = 0
    var graph_value_width : CGFloat = 0
    var graph_Xpos: CGFloat = 0
    var graph_Value_Xpos: CGFloat = 0
    var arrSelectedTestListGraphValue = NSArray()
    var borderColor : UIColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1)
    var textColor : UIColor = KRED_COLOR
    var max_Value = CGFloat()
    var min_Value = CGFloat()
    // timer varibale
    var timerSyncRecordDataFromServerToLocal = Timer()
    var reminderTimerSycnServerToLocal = Timer()
    var createdRecordId = ""
    var selectedTestName = ""
    var arrGraphValueCopy: [CGFloat] = []
    
    //  x axis values
    var arrGraphDateCopy: [String] = []
    var lblManageHealthRecord = UILabel()
    var  bgView = UIView()
    
    
   // var check : Bool = true
    
    // y axis Value
    var arrGraphValue: [CGFloat] = []
    
    //  x axis values
    var arrGraphDate: [String] = []
    var tapIndex : Int = 0
    
    
    var label = UILabel()
    var lineChart: LineChart!
    
    
    //MARK: newDesing
  //  var baseScrollView: UIScrollView = UIScrollView()
    var arrMyFamilyRecord = NSMutableArray()
    var selectedbutton = UIButton()
    var lblUserName: UILabel = UILabel()
    var isComingFromAddRecordViewWithMemberId = ""
    var bgImageView = UIImageView()
    var myFamilyMemberObj = MyFamilyInfo()
    
    var memberListTableView = UITableView()
    var arrMyFamilyList = NSMutableArray()
    var lblSelectedMemberName = UILabel()
    
    
    var lblNotifications = UILabel()
    var failPaymentAmount = ""
    var actionSheet : UIActionSheet!
    var tempDataFamily = NSMutableArray()
    
    
    
    
//    @IBOutlet weak var requestHomeVisitView: UIView!
//    @IBOutlet weak var remindersView: UIView!
//    @IBOutlet weak var addRecordsView: UIView!
//    @IBOutlet weak var lblUserName: UILabel!
    
    
//    var wsUrl : String = "http://23.101.24.132/healthservice/webservice.asmx"
//    var mutableData:NSMutableData  = NSMutableData()
//    var currentElementName:NSString = ""
//    var lastElementName:NSString = ""
    
//    var dbpath : String {
//        get {
//            let docsdir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!
//            return (docsdir as NSString).stringByAppendingPathComponent("HealthDatabase")
//        }
//    }

    //MARK: - ViewLifeCycleMethod

    override func viewDidLoad() {
        super.viewDidLoad()
       FBEventClass.logEvent("My Home")
        //Show Push Alert or Not
        showPushNotificationAlert()
        
        // register DeviceToken
        let checkForceUpdate = UserDefaults.standard.bool(forKey: "forceupdate")
        if checkForceUpdate == true {
            self.registerDeviceTone()
        }
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        self.view.window?.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = KRED_COLOR
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: textColor]
        self.automaticallyAdjustsScrollViewInsets = false
       
        self .setStatusBarBackgroundColor( UIColor(red: 196/255.0, green: 35/255.0, blue: 24/255.0, alpha: 1))
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
        })
        
        self.pushOnNextView()
        
        // call new layout
        self.createNewLayout()
        
        //set activity on view
        activityIndicator = ProgressViewController(inview:tblView,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        //tblView.addSubview(activityIndicator!)
        
        if(UserDefaults.standard.value(forKey: "GetAllTestsByFamily") == nil){
//            activityIndicator?.frame = CGRect(x: tblView.frame.width/2 - 30, y: 100, width: 60, height: 60)
            activityIndicator?.start()
           // self.getAllTestsByFamily("")
        }else{
            arrAllTestByFamily = UserDefaults.standard.value(forKey: "GetAllTestsByFamily") as! NSArray
            tblView.backgroundColor = UIColor (red: (237/255), green: (64/255), blue: (56/255), alpha: 1)
            self.tblView.delegate = self
            self.tblView.dataSource = self
            self.tblView.reloadData()
            //self.getAllTestsByFamily("")
        }
    }
    
    func makeInfoView(height: CGFloat, ypos:CGFloat){
        if(UserDefaults.standard.value(forKey: "showguideline") == nil && UserDefaults.standard.value(forKey: "loginCustomerId") != nil ){
            UIApplication.shared.endIgnoringInteractionEvents()
            self.showGuideLineView(h: height, y: ypos)
            UserDefaults.standard.setValue("hide", forKey: "showguideline")
        }
    }
    
    func showGuideLineView(h: CGFloat , y:CGFloat)  {
        var height = h
        var yPos = y + (height/2)
        
        bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        bgView.tag = 500
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        UIApplication.shared.keyWindow?.addSubview(bgView);
        //self.view.addSubview(bgView)
        
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnBGView(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        bgView.addGestureRecognizer(tapped)
        
        let cancelImageView = BaseUIController().AImageViewFrame(CGRect(x: 20, y: 40, width: 20, height: 20), withImageName: "verified_no.png")as! UIImageView
        cancelImageView.tintColor = UIColor.white
        bgView.addSubview(cancelImageView)
        let lblTapAnyWhereToClose = BaseUIController().ALabelFrame(CGRect(x: 50, y: 40, width: 200, height: 20), withString: "Tap anywhere to close")as! UILabel
        lblTapAnyWhereToClose.textColor = UIColor.white
        bgView.addSubview(lblTapAnyWhereToClose)
        
        let savedOrederImageView = BaseUIController().AImageViewFrame(CGRect(x: self.view.frame.width - 100, y: 40, width: 40, height: 40), withImageName: "finger_point.png")as! UIImageView
        bgView.addSubview(savedOrederImageView)
        let lblSaveOrder = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width - 120, y: 90, width: 85, height: 20), withString: "Saved Orders")as! UILabel
        lblSaveOrder.textColor = UIColor.white
        bgView.addSubview(lblSaveOrder)
        
        let healthTrendImageView = BaseUIController().AImageViewFrame(CGRect(x: (self.view.frame.width)/2 - 20, y: 100 + 64, width: 40, height: 40), withImageName: "finger_point.png")as! UIImageView
        bgView.addSubview(healthTrendImageView)
        let lblHealthTrand = BaseUIController().ALabelFrame(CGRect(x: (self.view.frame.width)/2 - 60, y: 140 + 64, width: 120, height: 20), withString: "Top 10 test results")as! UILabel
        lblHealthTrand.textColor = UIColor.white
        bgView.addSubview(lblHealthTrand)
        
        let lblText = ["Schedule free sample collection from home" , "Create Health Records","Create medicine or test reminders"]
        
        //        var yPos :CGFloat =  260 + 64 + 40 + 25 //tblView.frame.width + 64
        //        print(yPos)
        //        print(lblSelectedMemberName.frame.origin.y + 64 + 40 + 35)
        
        
//        let h = (self.view.frame.height/2)/3
//        var yPos :CGFloat =  self.view.frame.height/2 + 40 + (h/2) //tblView.frame.width + 64
        
        
        for k in 0..<3 {
            
            let fingerImageView = BaseUIController().AImageViewFrame(CGRect(x: (10 + ((height - 30)/2)), y: yPos, width: 40, height: 40), withImageName: "finger_point.png")as! UIImageView
            bgView.addSubview(fingerImageView)
            
            
            let lblText = BaseUIController().ALabelFrame(CGRect(x: (height - 30) + 30, y: yPos - 15, width: 250, height: 40), withString: lblText[k])as! UILabel
            //  lblHealthTrand.backgroundColor = UIColor.yellowColor()
            lblText.numberOfLines = 0
            lblText.textColor = UIColor.white
            bgView.addSubview(lblText)
            
            //            if k == 1 {
            //                lblText.frame = CGRectMake(xPos - 50, lblManageHealthRecord.frame.origin.y + 20, 150, 20)
            //            }
            yPos += height
        }
    }
    
    
    func pushOnNextView(){
        
        if isComingFromClass == "remoteNotifications" {
             let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
             FBEventClass.logEvent("Push Notification")
            switch appDelegate.notification_type {
            case "1": // New Order Booked
                let myOrdersVC = MyOrderViewController()
                self.navigationController?.pushViewController(myOrdersVC, animated: false)
                break
            case "2":// Order Verified
                let myOrdersVC = MyOrderViewController()
                self.navigationController?.pushViewController(myOrdersVC, animated: false)
                break
            case "3":  // Phlebo Assigned
                let myOrdersVC = MyOrderViewController()
                self.navigationController?.pushViewController(myOrdersVC, animated: false)
                break
            case "4": // Phlebo Arrived
                let myOrdersVC = MyOrderViewController()
                self.navigationController?.pushViewController(myOrdersVC, animated: false)
                break
            case "32": // Order booked from CRM
                let myOrdersVC = MyOrderViewController()
                self.navigationController?.pushViewController(myOrdersVC, animated: false)
                break
            case "5": //Submitted to lab
                break
                
            case "6":// Report Uploaded
                let myOrdersVC = MyOrderViewController()
                self.navigationController?.pushViewController(myOrdersVC, animated: false)
                break
                
            case "7":// Doctor Assigned
                let myOrdersVC = MyOrderViewController()
                self.navigationController?.pushViewController(myOrdersVC, animated: false)
                break
            case "8":// Dietitian Assigned
                let myOrdersVC = MyOrderViewController()
                self.navigationController?.pushViewController(myOrdersVC, animated: false)
                break
            case "10"://Diet Chart Upload
                let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
                homeTapSwipeVC.identifires = "MY RECORDS"
                self.navigationController?.pushViewController(homeTapSwipeVC, animated: false)
                
                break
            case "11":////Health Manager
                break
                
            case "12":// New Record by me
                break
                
            case "13":// New Record by other member
                 let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
                let reportType = (appDelegate.notificationPayload["recordType"] as! String).uppercased()
                switch   reportType{
                case "REPORT":
                    homeTapSwipeVC.currentSelectedTapIndex = 0
                    
                    break;
                case "PRESCRIPTION":
                   homeTapSwipeVC.currentSelectedTapIndex = 1
                    break;
                case "INVOICE":
                   homeTapSwipeVC.currentSelectedTapIndex = 2
                    break;
                case "DIET PLAN":
                   homeTapSwipeVC.currentSelectedTapIndex = 3
                    break;
                default: break
                }
                homeTapSwipeVC.identifires = "MY RECORDS"
                self.navigationController?.pushViewController(homeTapSwipeVC, animated: false)
                
            case "14":// New Member Creation
                break
                
            case "15":// New Reminder
                let myReminderVC = MyReminderViewController()
                myReminderVC.isComingFromNotification = true
                self.navigationController?.pushViewController(myReminderVC, animated: false)
                break
                
            case "16":// Updated Reminder
                let myReminderVC = MyReminderViewController()
                myReminderVC.isComingFromNotification = true
                self.navigationController?.pushViewController(myReminderVC, animated: false)
                break
                
            case "17":// Reschedule Order
                break
                
            case "18":// Member updated info
                // sync
                break
                
            case "19":// Order cancel
                let myOrdersVC = MyOrderViewController()
                self.navigationController?.pushViewController(myOrdersVC, animated: false)
                break
                
            case "20":
                break
                
            case "21":// Delete reminder
                let myReminderVC = MyReminderViewController()
                myReminderVC.isComingFromNotification = true
                self.navigationController?.pushViewController(myReminderVC, animated: false)
                break
                
            case "23":// Record updated by other member.
                 let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
                let reportType = (appDelegate.notificationPayload["recordType"] as! String).uppercased()
                switch   reportType{
                case "REPORT":
                    homeTapSwipeVC.currentSelectedTapIndex = 0
                    break;
                case "PRESCRIPTION":
                    homeTapSwipeVC.currentSelectedTapIndex = 1
                    break;
                case "INVOICE":
                    homeTapSwipeVC.currentSelectedTapIndex = 2
                    break;
                case "DIET PLAN":
                    homeTapSwipeVC.currentSelectedTapIndex = 3
                    break;
                default: break
                }
                 homeTapSwipeVC.identifires = "MY RECORDS"
                 self.navigationController?.pushViewController(homeTapSwipeVC, animated: false)
                 
                break
            case "25":// Record Delete
                // data base oprations pending
                break
                
            case "26":// Member Delete
                let myFamilyVC = storyboard1.instantiateViewController(withIdentifier: "MyFamilyViewController")as! MyFamilyViewController
                myFamilyVC.isComingFromNotification = true
                self.navigationController?.pushViewController(myFamilyVC, animated: false)
                break
                
            case "27":// Member Reject
                let myFamilyVC = storyboard1.instantiateViewController(withIdentifier: "MyFamilyViewController")as! MyFamilyViewController
                myFamilyVC.isComingFromNotification = true
                self.navigationController?.pushViewController(myFamilyVC, animated: false)
                break
                
            case "9":// feedback view
                FBEventClass.logEvent("FeedBack")
                
                break
                
            case "28":// feedback view
                FBEventClass.logEvent("FeedBack")
                
                break
                
            case "29":// feedback view
                FBEventClass.logEvent("FeedBack")
                break
                
            case "30":// feedback view
                FBEventClass.logEvent("FeedBack")
                break
                
            case "31": // feedback view
               FBEventClass.logEvent("FeedBack")
                break
                
            case "32":
                // Nothing Operations
                break
                
            case "33":
                let myFamilyVC = storyboard1.instantiateViewController(withIdentifier: "MyFamilyViewController")as! MyFamilyViewController
                myFamilyVC.isComingFromNotification = true
                self.navigationController?.pushViewController(myFamilyVC, animated: false)
                break
                
            case "34":// Member verified
                // sync
                break
                
            case "35":// CRM Member verified
                // sync
                break
                
            case "36":// Force Logout
                break
                
            case "37":// Payment Due
                break
                
            case "38":// New Notification tobe Store
                 self.getNotificatiosFromServer()
                let notificationVC = NotificationsViewController()
                self.navigationController?.pushViewController(notificationVC, animated: true)
                
                break
                
            case "39":// Referral code first order add Rs.75
                break
                
            default: break
            }
        }else{
            if isComingFromClass == "myreminder" {
                let myReminderVC = MyReminderViewController()
                self.navigationController?.pushViewController(myReminderVC, animated: false)
            }else if (isComingFromClass == "myaccount"){
                let myAccountVC = MyAccountViewController()
                self.navigationController?.pushViewController(myAccountVC, animated: true)
            }else if(isComingFromClass == "Chat"){
                // open chat window
//               let chatViewController = KMAINSTORYBOARD.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
//                self.navigationController?.pushViewController(chatViewController, animated: true)
                ZDCChat.start(in: self.navigationController, withConfig: nil)
            }else if(isComingFromClass == "callSupport"){
                //call support
                let phone = "tel://9810981073";
                let url:URL = URL(string:phone)!
                UIApplication.shared.openURL(url)
            }else if (isComingFromClass == "notifications"){
                 self.getNotificatiosFromServer()
                let notificationVC = NotificationsViewController()
                self.navigationController?.pushViewController(notificationVC, animated: true)
               
            }else if(isComingFromClass == "wallet"){
                let walletVC = WalletViewController()
                self.navigationController?.pushViewController(walletVC, animated: true)
            }
            else if(isComingFromClass == "barcode"){
                openActionSheettoUploadBarcode()
            }
            else if(isComingFromClass == "Graph"){
                let graphVC = showGraphViewController()
                self.navigationController?.pushViewController(graphVC, animated: true)
            }else if(isComingFromClass == "paymentFail"){
                let paymentVC = PaymentOptionsViewController()
                paymentVC.isComingFromClass = "paymentFail"
                paymentVC.failPaymentAmount = failPaymentAmount
                self.navigationController?.pushViewController(paymentVC, animated: true)
            
            }else{
                 self.getNotificatiosFromServer()
                self.getAllTestsByFamily("")
            
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addBarButtonOnNavigation()
     //   self.getNotificatiosFromServer()
        self.navigationController?.navigationBar.isTranslucent = true
        self.view.backgroundColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = appDelegate.navigationTitalFontSize
        
        var myFamilyObj = MyFamilyInfo()
        myFamilyObj = DrawerViewController().loadMyProfile()
        let userName = myFamilyObj.memberName //NSUserDefaults.standardUserDefaults().valueForKey("userName")as! String
        let firstName: String = userName.components(separatedBy: " ").first!.uppercased() as String
//        let firstName: String = userName.componentsSeparatedByString(" ").first!.uppercased() as String
       // title = "WELCOME " + firstName
        self.navigationItem.titleView = GlobalInfo.sharedInfo.getTitleView(title: "WELCOME " + firstName)
        appDelegate.trackViewOnGoogleAnalytics("Home Screen")
    }
    
    func setStatusBarBackgroundColor(_ color: UIColor) {
        
        guard  let statusBar = (UIApplication.shared.value(forKey: "statusBarWindow") as AnyObject).value(forKey: "statusBar") as? UIView else {
            return
        }
        
        statusBar.backgroundColor = color
    }
    
        //MARK: - CreateLayout
    func createNewLayout()  {
        // create a autocomplete tableView
        baseScrollView.frame = CGRect(x: 2.5, y: 8, width: self.view.frame.width-5, height: self.view.frame.height)
        self.view.addSubview(baseScrollView)
        if (self.view.frame.height != 480) {
             baseScrollView.isScrollEnabled = false
        }
       
        
        tblView = UITableView(frame:CGRect(x: 0, y: 64 ,width: self.view.frame.width, height: self.view.frame.height/2 - 64)) //260
        tblView.separatorStyle = .none
        tblView.showsVerticalScrollIndicator = false
//        tblView.dataSource = self
//        tblView.delegate = self
        baseScrollView.addSubview(tblView)
        // add button on view 
        let btnselectedMemeberName = BaseUIController().AButtonFrame(CGRect(x: 0, y: tblView.frame.height + 64, width: self.view.frame.width, height: 40), withButtonTital: "")as! UIButton
        btnselectedMemeberName.backgroundColor =  UIColor (red: (235/255), green: (236/255), blue: (237/255), alpha: 1)
        btnselectedMemeberName.addTarget(self, action: #selector(btnSelectMemberNameOnClick), for: .touchUpInside)
        baseScrollView.addSubview(btnselectedMemeberName)
        
        lblSelectedMemberName = BaseUIController().ALabelFrame(CGRect(x: 10 , y: 10,width: 300, height: 20), withString: "")as! UILabel
        lblSelectedMemberName.textColor =  UIColor (red: (224/255), green: (83/255), blue: (0/255), alpha: 1)
        lblSelectedMemberName.textAlignment = .left
        lblSelectedMemberName.font = UIFont(name: KROBOTO_REGULAR, size: 15)
        btnselectedMemeberName.addSubview(lblSelectedMemberName)
        //set selected member name
        var myFamilyObj = MyFamilyInfo()
        myFamilyObj = DrawerViewController().loadMyProfile()
        let userName = myFamilyObj.memberName
        let selelctedName: String = userName.uppercased() as String
        lblSelectedMemberName.text = selelctedName

        
       // selectedMemeberName.titleEdgeInsets.left = 10;
        
       let imgArrowIndicator = UIImageView(frame: CGRect(x: baseScrollView.frame.width - 20, y: ((btnselectedMemeberName.frame.size.height/2) - (15/2)), width: 15, height: 15))
        imgArrowIndicator.image = UIImage(named: "rightarr_orange")
        btnselectedMemeberName.addSubview(imgArrowIndicator)
        
        
        let arrButtonTitalName = ["BOOK AN ORDER","ADD RECORDS","REMINDERS"]
        let arrButtonSubTitalName = ["Never wait! Anytime anyWhere with Hindustan Wellness" , "Lets create history of your medical records." ,"Medicine reminders & test schedules."]
        
        let arrButtonIcon = ["book_an_order.png","add_records.png","reminders.png"]
        var yPos :CGFloat = btnselectedMemeberName.frame.origin.y + 40
        
        print(yPos)
        
        
        let h = (self.view.frame.height - (yPos + 10))/3
        print(self.view.frame.height)
        print(h)
        makeInfoView(height: h, ypos: yPos)
//        makeInfoViewwith(height, yps)
        
        for i in 0..<3 {
            let buttonLayoutView = UIView.init(frame: CGRect(x: 0, y: yPos, width: self.view.frame.width, height: h))
            buttonLayoutView.tag = 1001 + i
//            buttonLayoutView.backgroundColor = UIColor.yellowColor()
            baseScrollView.addSubview(buttonLayoutView)
            
            let imgView = BaseUIController().AImageViewFrame(CGRect(x: 15, y: 15, width: h - 30, height: h - 30), withImageName:arrButtonIcon[i])as! UIImageView
            buttonLayoutView.addSubview(imgView)
            let lblTital = BaseUIController().ALabelFrame(CGRect(x: imgView.frame.width + imgView.frame.origin.x + 20, y: (h - 40)/2 , width: 200, height: 20), withString: arrButtonTitalName[i])as! UILabel
            lblTital.font = UIFont(name: KROBOTO_REGULAR, size: 15)
            lblTital.textColor = KRED_COLOR
            buttonLayoutView.addSubview(lblTital)
            let lblSubTital = BaseUIController().ALabelFrame(CGRect(x: imgView.frame.width + imgView.frame.origin.x + 20, y: lblTital.frame.origin.y + 20 , width: 250, height: 0), withString: arrButtonSubTitalName[i])as! UILabel
            lblSubTital.sizeToFit()
            lblSubTital.font = UIFont(name: KROBOTO_LIGHTITALIC, size: 12)
            lblSubTital.textColor = UIColor.gray //UIColor (red: (89/255), green: (89/255), blue: (89/255), alpha: 1)
            buttonLayoutView.addSubview(lblSubTital)
            
            
            let imgArrowIndicator = UIImageView(frame: CGRect(x: baseScrollView.frame.width - 20, y: ((buttonLayoutView.frame.size.height/2) - (15/2)), width: 15, height: 15))
            imgArrowIndicator.image = UIImage(named: "rightarr_gray")
            //        let lblIndicator = BaseUIController().ALabelFrame(CGRect(x: baseScrollView.frame.width - 25 , y: 10,width: 20, height: 20), withString: ">")as! UILabel
            //        lblIndicator.textColor = UIColor (red: (224/255), green: (83/255), blue: (0/255), alpha: 1)
            //        lblIndicator.font = UIFont(name: KROBOTO_REGULAR, size: 18)
            buttonLayoutView.addSubview(imgArrowIndicator)
            
            
//            let lblIndicator = BaseUIController().ALabelFrame(CGRect(x: baseScrollView.frame.width - 15 , y: (h - 20)/2,width: 10, height: 20), withString: ">")as! UILabel
//            lblIndicator.textColor = UIColor (red: (132/255), green: (132/255), blue: (132/255), alpha: 1)
//            lblIndicator.font = UIFont(name: KROBOTO_REGULAR, size: 18)
//            buttonLayoutView.addSubview(lblIndicator)
            
            let lblLine = BaseUIController().ALabelFrame(CGRect(x: 0, y: h - 2, width: self.view.frame.width, height: 1), withString: "")as! UILabel
            lblLine.backgroundColor = UIColor (red: (238/255), green: (238/255), blue: (238/255), alpha: 1)
            buttonLayoutView.addSubview(lblLine)
            
            yPos += h
            
            let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.btnManageHealthRecordsOnclick(_:)))
            tapped.numberOfTapsRequired = 1
            buttonLayoutView.addGestureRecognizer(tapped)
            
            
            
        }
        baseScrollView.contentSize = CGSize(width: self.view.frame.width, height: yPos)
        
        
//        saveAddresstableView = UITableView(frame:CGRectMake(10, 90,(UIScreen.mainScreen().bounds.width) - 20, UIScreen.mainScreen().bounds.height - 184))
//        saveAddresstableView.backgroundColor = UIColor .whiteColor()
//        saveAddresstableView.allowsSelection = false
//        saveAddresstableView.separatorInset = UIEdgeInsetsZero
//        self.saveAddresstableView.separatorStyle = .None
//        saveAddresstableView.delegate = self
//        saveAddresstableView.dataSource = self
//        self.view.addSubview(saveAddresstableView)
        
    }
    
    func createALayout()  {
        
        let testListScrollView  = UIScrollView.init(frame: CGRect(x: 0, y: self.view.frame.height/2 + 10, width: self.view.frame.width, height: 46))
        testListScrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(testListScrollView)
        
        //let testListView = UIView.init(frame: CGRectMake(5, -62, self.view.frame.width - 10, 62))
        let testListView = UIView.init(frame: CGRect(x: 5, y: 2, width: self.view.frame.width - 10, height: 42))
        testListView.layer.masksToBounds = true
        testListView.layer.cornerRadius = 4
        testListView.layer.borderWidth = 1
        testListView.layer.borderColor = borderColor.cgColor
        testListScrollView.addSubview(testListView)
      //  let arrTestName = ["test 1 " , "test 2 ttttytttyty ", "test 5 fdasfasdfasf", "test - 6" , "test 5 fdasfasdfasf", "test - 6" , "test 5 ", "test - 6" ,"test 1 " , "test 2 ttttytttyty ", "test 5 fdasfasdfasf", "test - 6" , "test 5 fdasfasdfasf", "test - 6" , "test 5 ", "test - 6"]
        
        var xPos :CGFloat = 0
        let yPos : CGFloat = 0
        var heigherStringWidth : CGFloat = 0
        for i in 0..<arrTestList.count{
            let testName = arrTestList[i]as! String
            
            
            let size: CGSize = testName.size(attributes: [NSFontAttributeName: UIFont().smallFont])
            heigherStringWidth = size.width
    
            let btnTest = BaseUIController().AButtonFrame(CGRect(x: xPos , y: yPos, width: heigherStringWidth + 30 , height: 42), withButtonTital: testName) as! UIButton //(self.view.frame.width - 10)/3
            btnTest.tag = 101 + i
            if btnTest.tag == 101 {
                btnTest.backgroundColor = UIColor (red: (227/255), green: (227/255), blue: (227/255), alpha: 1)
            }
            btnTest.addTarget(self, action: #selector(HomeViewController.btnTestOnClick(_:)), for: .touchUpInside)
            btnTest.titleLabel?.font = UIFont().smallFont
            //btnTest.sizeToFit()
            btnTest.setTitleColor(UIColor (red: (72/255), green: (72/255), blue: (72/255), alpha: 1), for: UIControlState())
            testListView.addSubview(btnTest)
            xPos += heigherStringWidth + 30 //(self.view.frame.width - 10)/3
            let lblVerticalLine = BaseUIController().ALabelFrame(CGRect(x: xPos, y: 0, width: 1, height: 42), withString: "") as! UILabel
            lblVerticalLine.backgroundColor = borderColor // (line background color )
            testListView.addSubview(lblVerticalLine)
            
        }
       
            testListView.frame =  CGRect(x: 5, y: 2, width: xPos, height: 42)
            testListScrollView.contentSize = CGSize(width: xPos + 10, height: 1)
        
        // comment for new screen
   /*
        graphView = UIView.init(frame: CGRectMake(5, 70, self.view.frame.width - 10,  self.view.frame.height/2 - 64 ))
        graphView.layer.masksToBounds = true
        graphView.layer.cornerRadius = 4
        graphView.layer.borderWidth = 1
        graphView.layer.borderColor = borderColor.CGColor
        self.view.addSubview(graphView)
    
        
        let btnNext = BaseUIController().AButtonFrame(CGRectMake(graphView.frame.width - 20, graphView.frame.height - 60, 20, 60), withButtonTital: ">")as! UIButton
        btnNext.setTitleColor(textColor, forState: .Normal)
        btnNext.addTarget(self, action: #selector(HomeViewController.btnNextOnClick(_:)), forControlEvents: .TouchUpInside)
        graphView.addSubview(btnNext)
        
        let btnPrevious = BaseUIController().AButtonFrame(CGRectMake(0, graphView.frame.height - 60, 20, 60), withButtonTital: "<")as! UIButton
        btnPrevious.setTitleColor(textColor, forState: .Normal)
        btnPrevious.addTarget(self, action: #selector(HomeViewController.btnPrevious(_:)), forControlEvents: .TouchUpInside)
        graphView.addSubview(btnPrevious)
        
        
       */
        
        var arrSelectedTestListGraphValue = NSArray()
        if  arrGetAllTestList.count != 0{
           
            let searchPredicate = NSPredicate(format: "test_name CONTAINS[c] %@", (arrGetAllTestList[0] as AnyObject).value(forKey: "test_name")as! String)
//            arrSelectedTestListGraphValue = arrGetAllTestList.filter {searchPredicate.evaluate(with: $0)}
            arrSelectedTestListGraphValue = arrGetAllTestList.filter {searchPredicate.evaluate(with: $0)} as NSArray

//            arrGraphDate.removeAll()activityIndicator
            arrGraphValue.removeAll()
            for i in 0..<arrSelectedTestListGraphValue.count {
                let value  = ((arrSelectedTestListGraphValue[i] as AnyObject).value(forKey: "value")as! String)
                var cgFloat: CGFloat?
                if let doubleValue = Double(value) {
                    cgFloat = CGFloat(doubleValue)
                }
                arrGraphDate.append((arrSelectedTestListGraphValue[i] as AnyObject).value(forKey: "o_date1")as! String)
                arrGraphValue.append(cgFloat!)
            }
            // Comment for new screen only 2 line
//            self.loadGraphData(arrSelectedTestListGraphValue)
//            self.loadGraph("test")
        }

        
        lblManageHealthRecord = BaseUIController().ALabelFrame(CGRect(x: 0, y: testListScrollView.frame.origin.y + 60 + 40 , width: self.view.frame.width, height: 21), withString: "MANAGE HEALTH RECORDS") as! UILabel
        lblManageHealthRecord.textAlignment = .center
        lblManageHealthRecord.textColor = textColor
        self.view.addSubview(lblManageHealthRecord)
        //set bottom button
        xPos = (self.view.frame.width - 120)/4
        let arrButtonTitalName = ["Book Order","Add Records","Reminders"]
        let arrButtonIcon = ["package_name.png","my_records_icon.png","my_reminders_icon.png"]
        for k in 0..<3 {
            let btnManageHealthRecord = BaseUIController().AButtonFrame(CGRect(x: xPos, y: lblManageHealthRecord.frame.origin.y + 40, width: 30, height: 30), withButtonTital: "")as! UIButton
            btnManageHealthRecord.tag = 1001 + k
            btnManageHealthRecord.setImage(UIImage(named: arrButtonIcon[k]), for: UIControlState())
            btnManageHealthRecord.addTarget(self, action:#selector(HomeViewController.btnManageHealthRecordsOnclick(_:)), for: .touchUpInside)
            self.view.addSubview(btnManageHealthRecord)
            let lblButtonText = BaseUIController().ALabelFrame(CGRect(x: xPos - 25, y: btnManageHealthRecord.frame.origin.y + 30, width: 80, height: 21), withString:arrButtonTitalName[k])as! UILabel
            lblButtonText.font = UIFont.systemFont(ofSize: 14)
            lblButtonText.textColor = UIColor(red: 51.0/255, green: 51.0/255, blue: 51.0/255, alpha: 1)
            lblButtonText.textAlignment = .center
            self.view.addSubview(lblButtonText)
            xPos += (self.view.frame.width - 180)/4 + 60 //(self.view.frame.width - 120)/4 + 40 //(self.view.frame.width - 180)/4 + 60
        }
    }
    
    

    
    func showMemberList()  {
        
        // create A tableView
//        bgView = UIView(frame:CGRectMake(0, 0,self.view.frame.width, self.view.frame.height))
        bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(bgView)
        let tableHeight : CGFloat = CGFloat((arrMyFamilyList.count * 44) + 30)
        print(tableHeight)
        print(UIScreen.main.bounds.height)
        print(((UIScreen.main.bounds.height - tableHeight)/2))
        
        if ((UIScreen.main.bounds.height - tableHeight)/2) >= 70 {
            memberListTableView = UITableView(frame:CGRect(x: 10, y: (UIScreen.main.bounds.height - tableHeight)/2, width: self.view.frame.width - 20 ,height: tableHeight))
        }else{
            memberListTableView = UITableView(frame:CGRect(x: 10, y: 74, width: self.view.frame.width - 20 ,height: self.view.frame.height - 84 ))
        
        }
        
        memberListTableView.delegate      =   self
        memberListTableView.dataSource    =   self
        memberListTableView.layer.cornerRadius = 4.0
        memberListTableView.tableFooterView = UIView()
        memberListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        memberListTableView.backgroundColor = UIColor.clear
        bgView.addSubview(memberListTableView)
        // add Tapgestue  on shadowBackGround
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnMemberListBG(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        bgView.addGestureRecognizer(tapped)
    }
    func tappedOnMemberListBG(_ gesture : UITapGestureRecognizer)  {
        bgView.removeFromSuperview()
    }

    
    // comment for new screen
    
  /*  func loadGraphData(arrGraphValue : NSArray)  {
        
        graphValueScrollView.removeFromSuperview()
        graphValueScrollView  = UIScrollView.init(frame: CGRectMake(20, graphView.frame.height - 60, graphView.frame.width - 40 , 60))
        graphValueScrollView.delegate = self
        graphValueScrollView.showsHorizontalScrollIndicator = false
        graphView.addSubview(graphValueScrollView)
        //get max and min value
//        max_Value = CGFloat(arrGraphValue[0].valueForKey("maxvalue"))
//        min_Value = CGFloat(arrGraphValue[0].valueForKey("minvalue"))
        max_Value = CGFloat(Double(arrGraphValue[0].valueForKey("maxvalue")as! String)!)
        min_Value =  CGFloat(Double(arrGraphValue[0].valueForKey("minvalue")as! String)!)
        
        var xPos : CGFloat = 0
        let gv_width : CGFloat = (graphView.frame.width - 40)/3 - 2
        for i in 0..<arrGraphValue.count {
            
            let btnGraphValue = BaseUIController().AButtonFrame(CGRectMake(xPos, 0, gv_width, 60), withButtonTital: "")as! UIButton
            btnGraphValue.tag = 501 + i
            btnGraphValue.addTarget(self, action:#selector(HomeViewController.btnGraphOnValueClick(_:)), forControlEvents: .TouchUpInside)
            
            graphValueScrollView.addSubview(btnGraphValue)
            
            let lblDate = BaseUIController().ALabelFrame(CGRectMake(0, 10, gv_width, 15), withString: arrGraphValue[i].valueForKey("o_date1")as! String)as! UILabel
          //  let lblDate = BaseUIController().ALabelFrame(CGRectMake(0, 10, gv_width, 10), withString: arrGraphValue[i] as! String)as! UILabel
            lblDate.tag = 601 + i
           // lblDate.textColor = textColor
            lblDate.textAlignment = .Center
            lblDate.font = UIFont().smallFont
            btnGraphValue.addSubview(lblDate)
            
            
            let testValue   = arrGraphValue[i].valueForKey("value")as! String
            let testUnit =  arrGraphValue[i].valueForKey("t_meas")as! String
            let attrs1      = [NSFontAttributeName: UIFont.boldSystemFontOfSize(16), NSForegroundColorAttributeName:UIColor (red: (72/255), green: (72/255), blue: (72/255), alpha: 1)]
            let attrs2      = [NSFontAttributeName: UIFont.boldSystemFontOfSize(10), NSForegroundColorAttributeName: UIColor (red: (72/255), green: (72/255), blue: (72/255), alpha: 1)]
            let attributedText = NSMutableAttributedString()
            attributedText.appendAttributedString(NSAttributedString(string: testValue , attributes:  attrs1))
            attributedText.appendAttributedString(NSAttributedString(string: testUnit, attributes: attrs2))
           

            
            
            let lblTestValue = BaseUIController().ALabelFrame(CGRectMake(0, 30, gv_width, 20), withString:"")as! UILabel
           // let lblTestValue = BaseUIController().ALabelFrame(CGRectMake(0, 30, gv_width, 20), withString: arrGraphValue[i]as! String)as! UILabel
            lblTestValue.tag = 701 + i
            lblTestValue.textAlignment = .Center
            lblTestValue.attributedText = attributedText
            //lblTestValue.font = UIFont.systemFontOfSize(1)
            btnGraphValue.addSubview(lblTestValue)
            
            
            
            xPos += gv_width + 2
            
            let lblVerticalLine = BaseUIController().ALabelFrame(CGRectMake(xPos - 1  , 15, 1, 30), withString: "")as! UILabel
            lblVerticalLine.backgroundColor  = textColor
            graphValueScrollView.addSubview(lblVerticalLine)
        }
        graphValueScrollView.contentSize = CGSizeMake(xPos, 1.0)
        graph_Xpos = xPos
    } */
     // comment for new screen
  /*  func loadGraph(clickOn : String)  {
        var views: [String: AnyObject] = [:]
        
        label.text = "..."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.Center
        self.view.addSubview(label)
        views["label"] = label
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-80-[label]", options: [], metrics: nil, views: views))
        
        lineChart = LineChart()
        lineChart.animation.enabled = true
        lineChart.area = false
        lineChart.x.labels.visible = true
        lineChart.x.grid.count = 5
        lineChart.y.grid.count = 5
        lineChart.x.grid.visible = false
       // lineChart.y.grid.visible = false
        if clickOn == "test" {
            arrGraphDate.append("")
            lineChart.x.labels.values = arrGraphDate
        }else{
            arrGraphDateCopy.append("")
            lineChart.x.labels.values = arrGraphDateCopy
            
        }
       
       // lineChart.y.labels.visible = false
//        lineChart.y.axis.visible = false
//        lineChart.x.axis.visible = false
       
        graph_width = graphView.frame.width  //CGFloat(3 * Int(graphView.frame.width/3))
        print(graphView)
      //  graph_width = self.view.frame.width + 20
      //  graph_value_width = CGFloat(arrGraphValue.count * Int((graphView.frame.width - 20)/3))
        if clickOn == "test" {
            graph_width = graphView.frame.width + 40
            arrGraphValue.append(max_Value)
            lineChart.addLine(arrGraphValue, min_Value: min_Value, max_Value: max_Value, line_width: graph_width,testName: selectedTestName)
             // high light a dot after
            let triggerTime = (Int64(NSEC_PER_MSEC) * 50)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.higlightDot(0)
            })
//            higlightDot(0)
        }else{
            graph_width = graphView.frame.width + 100
            arrGraphValueCopy.append(max_Value)
            lineChart.addLine(arrGraphValueCopy, min_Value: min_Value, max_Value: max_Value, line_width: graph_width,testName: selectedTestName)
            // high light a dot after
            if arrGraphDate.count - 1 == tapIndex {
                let triggerTime = (Int64(NSEC_PER_MSEC) * 50)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                    self.higlightDot(2)
                })
            }else if(tapIndex == 0){
                let triggerTime = (Int64(NSEC_PER_MSEC) * 50)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                    self.higlightDot(0)
                })
            }else{
                let triggerTime = (Int64(NSEC_PER_MSEC) * 50)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                    self.higlightDot(1)
                })
            }
            
        }
        
     //   lineChart.addLine(data2)
        // try to drow line on graph
        lineChart.lineWidth = 3
        lineChart.colors = [UIColor.whiteColor()]
        
      //  lineChart.drawMax_MinLine(2, min: 5)
        
       
        
//        graph_width = CGFloat(arrGraphValue.count * Int(graphView.frame.width/3))
        graphScrollView.removeFromSuperview()
        graphScrollView  =  UIScrollView.init(frame: CGRectMake(0, 0, graphView.frame.width , graphView.frame.height - 60))
        graphScrollView.delegate = self
        graphScrollView.scrollEnabled = false
        graphScrollView.backgroundColor = UIColor(patternImage: UIImage(named: "graphbg_icon.png")!)
       
        
        graphScrollView.showsHorizontalScrollIndicator = false
        graphView.addSubview(graphScrollView)
        
        lineChart.frame = CGRectMake(0, 0, graph_width , graphView.frame.height - 60)
       
       // lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
       
        graphScrollView.addSubview(lineChart)
        views["chart"] = lineChart
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[chart]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[label]-[chart(==200)]", options: [], metrics: nil, views: views))
    } */
    
    func higlightDot(_ selectedIndex : Int)  {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//            // do your background code here
//            dispatch_sync(dispatch_get_main_queue(), {
               self.lineChart.highlightDataPoints(selectedIndex)
//            });
//        });
    }
    
    func addBarButtonOnNavigation() {
        
        let menuBarButton = UIBarButtonItem(image: UIImage(named: "menu_icon.png"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(HomeViewController.didTapMenuBarButton(_:)))
        self.navigationItem.leftBarButtonItem = menuBarButton
        
        // Add custom View on right navigation Bar
        let rightBarView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 44))
        let btnCart = BaseUIController().AButtonFrame(CGRect(x: 0, y: 2, width: 30,height: 40), withButtonTital: "")as! UIButton
        btnCart.setImage(UIImage (named: "cart_icon"), for: UIControlState())
        btnCart.addTarget(self, action: #selector(HomeViewController.didTapCartButton(_:)), for: UIControlEvents.touchUpInside)
        rightBarView.addSubview(btnCart)
        btnCart.imageEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 5)
        
        let lblCart = BaseUIController().ALabelFrame(CGRect(x: 20 ,y: 0, width: 16, height: 16), withString: "")as! UILabel
        lblCart.text = String(self.getCartMemebrtCount())
        if self.getCartMemebrtCount() == 0 {
            lblCart.isHidden = true
        }
        lblCart.layer.cornerRadius = 8
        lblCart.layer.masksToBounds = true
        lblCart.font = UIFont().smallFont
        lblCart.textAlignment = .center
        lblCart.textColor = UIColor.white
        lblCart.backgroundColor = KRED_COLOR
        rightBarView.addSubview(lblCart)
        
        let btnNotificaitons = BaseUIController().AButtonFrame(CGRect(x:35 , y: 2, width: 30,height: 40), withButtonTital: "")as! UIButton
        btnNotificaitons.setImage(UIImage (named: "notifications_icon"), for: UIControlState())
        btnNotificaitons.addTarget(self, action: #selector(HomeViewController.didTapNotificationBarButton(_:)), for: UIControlEvents.touchUpInside)
        rightBarView.addSubview(btnNotificaitons)
        btnNotificaitons.imageEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 5)
        
        lblNotifications = BaseUIController().ALabelFrame(CGRect(x: 55 ,y: 0, width: 16, height: 16), withString: "0")as! UILabel
         lblNotifications.text = String(NotificationsViewController().getNotificationsCount())// get total  Notifications count
        if NotificationsViewController().getNotificationsCount() == 0 {
            lblNotifications.isHidden = true
        }
        lblNotifications.layer.cornerRadius = 8
        lblNotifications.layer.masksToBounds = true
        lblNotifications.backgroundColor = KRED_COLOR
        lblNotifications.font = UIFont().smallFont
        lblNotifications.textAlignment = .center
        lblNotifications.textColor = UIColor.white
        
        let btnShare = BaseUIController().AButtonFrame(CGRect(x:60 , y: 2, width: 30,height: 40), withButtonTital: "")as! UIButton
        btnShare.setImage(UIImage (named: "package_share.png"), for: UIControlState())
        btnShare.addTarget(self, action: #selector(self.didTapShareBarButton(_:)), for: UIControlEvents.touchUpInside)
        rightBarView.addSubview(btnShare)
        btnShare.imageEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 5)
        
        rightBarView.addSubview(lblNotifications)
        let barButtonItem = UIBarButtonItem(customView: rightBarView)
        self.navigationItem.rightBarButtonItem = barButtonItem        
    }
    //MARK: - LineChartDelegate
    func didSelectDataPoint(_ x: CGFloat, yValues: Array<CGFloat>) {
       // label.text = "x: \(x)     y: \(yValues)"
        
        
//        graphScrollView.setContentOffset(CGPointMake(x, 0), animated: true)
//        graphValueScrollView.setContentOffset(CGPointMake(x - 40 , 0), animated: true)
        
       
  /*      for i in 0..<arrGraphDate.count {
            if 501 + Int(x) == i + 501 {
                let lblDate  = self.view.viewWithTag(601 + i)as! UILabel
                lblDate.textColor = textColor
                let lblvalue  = self.view.viewWithTag(701 + i)as! UILabel
                lblvalue.textColor = textColor
            }else{
                let lblDate  = self.view.viewWithTag(601 + i)as! UILabel
                lblDate.textColor = UIColor.blackColor()
                let lblvalue  = self.view.viewWithTag(701 + i)as! UILabel
                lblvalue.textColor = UIColor.blackColor()
            }
            
        } */
        
        
        
    }
    //MARK: - scrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        
        
        
        let xPos = baseScrollView.contentOffset.x
        print(xPos)
        
//        if scrollView == graphScrollView {
//            
//           // graphValueScrollView.delegate = nil
//            let scrollViewXpos = graphScrollView.contentOffset.x
//            graphValueScrollView.setContentOffset(CGPointMake(scrollViewXpos  , 0), animated: true)
//            
//            print(scrollViewXpos)
//        }else if (scrollView ==  graphValueScrollView){
//            
//            graphScrollView.delegate = nil
//            let scrollViewXpos = graphValueScrollView.contentOffset.x
//            graphScrollView.setContentOffset(CGPointMake(scrollViewXpos, 0), animated: true)
//            
//            print(scrollViewXpos)
//        }
        
        //        if sss > 1 {
       //
       //
        //   }
        // scrollView.setContentOffset(CGPointMake(280 * CGFloat(sss), 10), animated: true)
        
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        
        
        
//           graphScrollView.delegate = self
//    
//           graphValueScrollView.delegate = self
        
   /*     if scrollView == graphScrollView {
            
          //  graphValueScrollView.delegate = nil
            let scrollViewXpos = graphScrollView.contentOffset.x
            graphValueScrollView.setContentOffset(CGPointMake(scrollViewXpos  , 0), animated: true)
            
            
        }else if (scrollView ==  graphValueScrollView){
            
          //  graphScrollView.delegate = nil
            let scrollViewXpos = graphValueScrollView.contentOffset.x
            graphScrollView.setContentOffset(CGPointMake(scrollViewXpos, 0), animated: true)
            
            
        } */  //comment on 3 oct 2016
       
        
    }

    //MARK: - TabGestureMethod
    func tapOnaddRecordsView(_ gesture: UITapGestureRecognizer)  {
       
    }
    //MARK: removeBGView
    func tappedOnBGView(_ sender: UITapGestureRecognizer)  {
        bgView.removeFromSuperview()
    }
    func tapOnRequestHomeVistView(_ gesture: UITapGestureRecognizer)  {
//        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
//        let homeTapSwipeVC = storyboard1.instantiateViewControllerWithIdentifier("HomeTabSwipeViewController") as! HomeTabSwipeViewController
//        homeTapSwipeVC.identifires = "BOOK AN ORDER"
//        self.navigationController?.pushViewController(homeTapSwipeVC, animated: true)
    }
    func tapOnReminderView(_ gesture: UITapGestureRecognizer)  {
        
    }
    
    //MARK: - GestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        print(touch.view)
        
        if (touch.view == bgView ){
            return true
        }
        else{
            return false
        }
    }

    //MARK: - barButtonClick
    
    func didTapNotificationBarButton(_ sender: AnyObject){
      //  if NotificationsViewController().getNotificationsCount() != 0 {
            let notificationVC = NotificationsViewController()
            self.navigationController?.pushViewController(notificationVC, animated: true)
//        }else{
//            self.presentViewController(BaseUIController().showAlertView("No new notifications"), animated: true, completion: nil)
//        }
    }
    
    func didTapCartButton(_ sender: AnyObject){
        FBEventClass.logEvent("Cart Click")
        print("btn cart  click")
        if self.getCartMemebrtCount() != 0 {
            self.navigationController?.navigationBar.isTranslucent = false
            let checkoutVC = CheckOutViewController()
            self.navigationController?.pushViewController(checkoutVC, animated: true)
        }else{
            
             self.present(BaseUIController().showAlertView("There are currently no orders in your cart."), animated: true, completion: nil)
        }
    }
    func didTapShareBarButton(_ sender: AnyObject){
        FBEventClass.logEvent("App Sharing")
        let refrralCode = appDelegate.referralCode
        let msg = "Being healthy made easier Download STETHO app " + "http://onelink.to/gae3x8 and use " + "'"+refrralCode+"'" + " and get 20% off on your first purchase.*T&C."
        
        
        let activityViewController = HomeTabSwipeViewController().shareTextImageAndURL(msg, sharingImage: nil, sharingURL: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }

   
    
    func didTapMenuBarButton(_ sender: AnyObject){
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
           
        }
    }
    
    func didTapOpenButton(_ sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    // comment for new screen 
    
  /*  func btnNextOnClick(button : UIButton)  {
        
        if arrGraphDate.count > 3 {
             graphValueScrollView.setContentOffset(CGPointMake(graph_Xpos - (self.view.frame.width - 50) , 0), animated: true) // 10 +
        }
    }
    func btnPrevious(button : UIButton)  {

            graphValueScrollView.setContentOffset(CGPointMake(graph_Value_Xpos , 0), animated: true)
    
    } */
    func btnTestOnClick(_ button : UIButton)  {
      
        
        var arrSelectedTestListGraphValue = NSArray()
        let searchPredicate = NSPredicate(format: "test_name CONTAINS[c] %@",(button.titleLabel?.text)!)
        arrSelectedTestListGraphValue = arrGetAllTestList.filter{
            searchPredicate.evaluate(with: $0)
        } as NSArray
        for i in 0..<arrTestList.count {
            let btn = self.view.viewWithTag(101 + i)as! UIButton
            if button.tag == btn.tag{
                selectedTestName = arrTestList[btn.tag - 101] as! String
                print(selectedTestName)
               btn.backgroundColor = UIColor (red: (227/255), green: (227/255), blue: (227/255), alpha: 1)
            }else{
               btn.backgroundColor = UIColor.clear
            }
        }
        arrGraphDate.removeAll()
        arrGraphValue.removeAll()
        for i in 0..<arrSelectedTestListGraphValue.count {
            let value  = ((arrSelectedTestListGraphValue[i] as AnyObject).value(forKey: "value")as! String)
            var cgFloat: CGFloat?
            if let doubleValue = Double(value) {
                cgFloat = CGFloat(doubleValue)
            }
            arrGraphDate.append((arrSelectedTestListGraphValue[i] as AnyObject).value(forKey: "o_date1")as! String)
            arrGraphValue.append(cgFloat!)
        }
        // comment for new screen 2 line
//        self.loadGraphData(arrSelectedTestListGraphValue)
//        self.loadGraph("test")
        
    }
    // comment for new screen 2 line
    
 /*   func btnGraphOnValueClick(button : UIButton)  {
        arrGraphValueCopy.removeAll()
        arrGraphDateCopy.removeAll()
        if arrGraphValue.count == arrGraphDate.count {
            arrGraphDate.removeLast()
        }
        for i in 0..<arrGraphDate.count {
            if button.tag == i + 501 {
               let lblDate  = self.view.viewWithTag(601 + i)as! UILabel
                lblDate.textColor = textColor
                let lblvalue  = self.view.viewWithTag(701 + i)as! UILabel
                lblvalue.textColor = textColor
                tapIndex = i
            }else{
                let lblDate  = self.view.viewWithTag(601 + i)as! UILabel
                lblDate.textColor = UIColor.blackColor()
                let lblvalue  = self.view.viewWithTag(701 + i)as! UILabel
                lblvalue.textColor = UIColor.init(red: (72.0/255.0), green: (72.0/255.0), blue: (72.0/255.0), alpha: 1) //UIColor.blackColor()
            }
        }
        lineChart.highlightDataPoints(button.tag - 501)
        if arrGraphDate.count > 3 {
            
            print(arrGraphDate.count)
            print(arrGraphValue.count)
            
            if(arrGraphDate.count == tapIndex + 1){
                arrGraphDateCopy.append(arrGraphDate[tapIndex - 2])
                arrGraphDateCopy.append(arrGraphDate[tapIndex - 1])
                arrGraphDateCopy.append(arrGraphDate[tapIndex])
                
                arrGraphValueCopy.append(arrGraphValue[tapIndex - 2])
                arrGraphValueCopy.append(arrGraphValue[tapIndex - 1])
                arrGraphValueCopy.append(arrGraphValue[tapIndex])
                
//                arrSelectedTestListGraphValueCopy.addObject(arrSelectedTestListGraphValue.objectAtIndex(tapIndex - 2))
//                arrSelectedTestListGraphValueCopy.addObject(arrSelectedTestListGraphValue.objectAtIndex(tapIndex - 1))
//                arrSelectedTestListGraphValueCopy.addObject(arrSelectedTestListGraphValue.objectAtIndex(tapIndex))
                
            }else if (tapIndex == 0){
               
                arrGraphDateCopy.append(arrGraphDate[tapIndex])
                arrGraphDateCopy.append(arrGraphDate[tapIndex + 1])
                arrGraphDateCopy.append(arrGraphDate[tapIndex + 2])
                
                arrGraphValueCopy.append(arrGraphValue[tapIndex])
                arrGraphValueCopy.append(arrGraphValue[tapIndex + 1])
                arrGraphValueCopy.append(arrGraphValue[tapIndex + 2])
                
                
            }else{
            
           arrGraphDateCopy.append(arrGraphDate[tapIndex - 1])
           arrGraphDateCopy.append(arrGraphDate[tapIndex])
           arrGraphDateCopy.append(arrGraphDate[tapIndex + 1])
            
            arrGraphValueCopy.append(arrGraphValue[tapIndex - 1])
            arrGraphValueCopy.append(arrGraphValue[tapIndex])
            arrGraphValueCopy.append(arrGraphValue[tapIndex + 1])
                
            }
            
            loadGraph("value")
        }
        print(String(format: "taped Index %d",tapIndex))
    } */
    func btnManageHealthRecordsOnclick(_ sender: UITapGestureRecognizer)  {
        
        let v = sender.view
        
        if v!.tag == 1001 {
            self.deletePackageNotAddedInCart()
            let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
            let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
            homeTapSwipeVC.identifires = "BOOK AN ORDER"
            self.navigationController?.pushViewController(homeTapSwipeVC, animated: true)
            
        }else if(v!.tag == 1002){
            FBEventClass.logEvent("Camera Record")
            let cameraVC = CameraViewController()
            self.navigationController?.pushViewController(cameraVC, animated: true)
        }else if(v!.tag == 1003){
            let myReminderVC = MyReminderViewController()
            self.navigationController?.pushViewController(myReminderVC, animated: false)
        }
    }
    func btnSelectMemberNameOnClick()  {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let familyMemberListViewController = mainStoryboard.instantiateViewController(withIdentifier: "FamilyMemberListViewController") as! FamilyMemberListViewController
        familyMemberListViewController.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(familyMemberListViewController, animated: true, completion: nil)
        
        familyMemberListViewController.selectedMemberInfo = { info in
            print(info.memberName)
            self.getAllTestByMember(info: info)
        }
    }
    
    func getAllTestByMember(info: MyFamilyInfo){
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        activityIndicator?.start()
        myFamilyMemberObj = info
        self.getAllTestsByFamily(myFamilyMemberObj.memberId)
    }
    
    //MARK: - SyncData
    
//    func syncRecordData()  {
//        self.loadDataFromDataBase()
//        
//        
//    }
    
    func loadDataFromDataBase()  {
        
        let database = appDelegate.openDataBase()
        let reportIds : NSMutableString = NSMutableString()
        let prescriptionIds : NSMutableString = NSMutableString()
        let dietChartIds : NSMutableString = NSMutableString()
        let invoiceIds : NSMutableString = NSMutableString()
        
        
        do {
            let rs = try database.executeQuery("select DatabaseId , recordtype from recordDetails where ServerToLocalSyncStatus = 'Y' ", values: nil)
            while rs.next() {
                let recordObj = HealthInfo()
               
                recordObj.dataBaseId = rs.string(forColumn: "DataBaseId")
                let rocordTyep = rs.string(forColumn: "RecordType")as String
                
                switch rocordTyep {
                case "R"  :
                    if reportIds.isEqual("") {
                        reportIds.append(recordObj.dataBaseId)
                    }else{
                        reportIds.append(",")
                        reportIds.append(recordObj.dataBaseId)
                    }
                   break
                case "P"  :
                    if prescriptionIds.isEqual("") {
                        prescriptionIds.append(recordObj.dataBaseId)
                    }else{
                        prescriptionIds.append(",")
                        prescriptionIds.append(recordObj.dataBaseId)
                    }
                   break
                case "I"  :
                    if invoiceIds.isEqual("") {
                        invoiceIds.append(recordObj.dataBaseId)
                    }else{
                        invoiceIds.append(",")
                        invoiceIds.append(recordObj.dataBaseId)
                    }
                   break
                case "D"  :
                    if dietChartIds.isEqual("") {
                        dietChartIds.append(recordObj.dataBaseId)
                    }else{
                        dietChartIds.append(",")
                        dietChartIds.append(recordObj.dataBaseId)
                    }
                   break
                default :
                    print( "default case")
                }
              
            }
            
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
        self.getRecordDetaislData(reportIds, prescriptionString: prescriptionIds, dietChatString: dietChartIds, invoiceString: invoiceIds)
    }
    

    
    //MARK: - callWebservice
    
    func getRecordDetaislData(_ reportString : NSMutableString , prescriptionString : NSMutableString , dietChatString : NSMutableString , invoiceString : NSMutableString)  {
        
        print(reportString)
        print(prescriptionString)
        print(dietChatString)
        print(invoiceString)
        
       
        if Reachability.isConnectedToNetwork() == true {
            
          if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
            let customerid = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            let r_Id = reportString as String
            let p_Id = prescriptionString as String
            let i_Id = invoiceString as String
            let d_Id = dietChatString as String
            
            let allParameters = ["reportIds":r_Id, "prescriptionIds":p_Id,"dietChartIds":d_Id,"invoiceIds":i_Id,"customerId":customerid]
            
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetRecordsFromServerResult" ,methodname: "GetRecordsFromServer", className: self)
            }
            
        }else{
            //self.loadDataFromDataBase()
            // self.presentViewController(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    // get Notifications
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
        print(methodName)
        print(allResponse)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if allResponse .isEqual("error") || allResponse.isEqual("") || allResponse.isEqual("Something went wrong. Please try again.")  {
                  //  print("some problem")
                    if methodName == "GetRecordsFromServer" && allResponse .isEqual("") {
                        //stop syncing process
                     self.timerSyncRecordDataFromServerToLocal.invalidate()
                    }
                    if methodName == "GetReminders" && allResponse .isEqual("") {
                        //stop syncing process
                        self.reminderTimerSycnServerToLocal.invalidate()
                    }
                    if methodName == "GetAllTests" && allResponse .isEqual("error") {
                       self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil) 
                    }
                    if(allResponse .isEqual("error") || allResponse.isEqual("Something went wrong. Please try again.")){
                        print("some Sync problem")
                    }
                }else{
                     if (methodName == "GetAllTests"){
                        //set All test in NSUserDefault
                        self.arrGetAllTestList = allResponse as! NSMutableArray
//                        if(NSUserDefaults.standardUserDefaults().valueForKey("GetAllTests") == nil){
                           UserDefaults.standard.set((allResponse as? NSMutableArray)!, forKey: "GetAllTests")
                        // comment for new screen 
                        
                        //   self.loadTestData()
                    //    }
                    }else if(methodName == "GetAllTestsByFamily"){
                    // get all test by family 
                        self.activityIndicator?.stop()
                        self.arrAllTestByFamily = allResponse as! NSArray
                        self.tblView.backgroundColor = UIColor (red: (237/255), green: (64/255), blue: (56/255), alpha: 1)
                        if(self.myFamilyMemberObj.memberName != ""){
                            self.lblSelectedMemberName.text = self.myFamilyMemberObj.memberName

                        }
                        self.tblView.delegate = self
                        self.tblView.dataSource = self
                        self.tblView.reloadData()
                        UserDefaults.standard.set((allResponse as? NSArray)!, forKey: "GetAllTestsByFamily")
                        
                    }
//                    else if (methodName == "DeleteRecords"){
//                        if(allResponse as! String == "1"){
//                        self.deleteReportFromDatabase()
//                        }
//                    }
                    else if (methodName == "GetNotifications"){
                        
                        self.syncNotificationsFromServerToLocal(allResponse as! NSArray)
                    }else if (methodName == "GCMRegisterationV2"){
                        
                    //    print(allResponse)
                        
                        let arr = allResponse as! NSArray
                        let arrDepartment = NSMutableArray()
                        
                        //check is corporate User 
                        if((arr[0] as AnyObject).value(forKey: "ISCORP")as! String == "1"){
                        UserDefaults.standard.setValue((arr[0] as AnyObject).value(forKey: "PACK_NAME")as! String, forKey: "PACK_NAME")
                       UserDefaults.standard.setValue((arr[0] as AnyObject).value(forKey: "COMP_ID")as! String, forKey: "company_id")
                            
                            GlobalInfo.sharedInfo.setValueInDefault((arr[0] as! NSDictionary).value(forKey: "company_name") as! String as AnyObject, forKey: KCOPERATE_NAME)
                            GlobalInfo.sharedInfo.setValueInDefault("" as AnyObject, forKey: KCOPERATE_URL)
                        UserDefaults.standard.set(true, forKey: "iscorporate")
                            
                            for i in (0..<arr.count){
                                let dictDepartment = NSMutableDictionary()
                                print((arr[i] as AnyObject).value(forKey: "department_name")as! String)
                                print((arr[i] as AnyObject).value(forKey: "cwd_id")as! String)
                                
                                
                            dictDepartment.setValue((arr[i] as AnyObject).value(forKey: "department_name")as! String, forKey: "departmentName")
                            dictDepartment.setValue((arr[i] as AnyObject).value(forKey: "cwd_id")as! String, forKey: "department_id")
                                
                                arrDepartment.add(dictDepartment)
                            }
                            UserDefaults.standard.setValue(arrDepartment, forKey: "department")
                            
                            
                        let corporateVC = CorporateViewController()
                            corporateVC.isComingfromCheckinBarCode = false
                        self.navigationController?.pushViewController(corporateVC, animated: true)
                        
                        }
                        
                        // set referal code & wallet balance in NSUserDefault
                        self.appDelegate.referralCode = (arr[0] as AnyObject).value(forKey: "referal_code")as! String
                        self.appDelegate.walletBalance = (arr[0] as AnyObject).value(forKey: "wallet_balance")as! String
                        UserDefaults.standard.setValue(self.appDelegate.referralCode, forKey: "referal_code")
                         UserDefaults.standard.setValue(self.appDelegate.walletBalance, forKey: "wallet_balance")
                        // for update getall packages
                        UserDefaults.standard.setValue((arr[0] as AnyObject).value(forKey: "healthtestversion") as! String, forKey: "healthtestversion")
                        
                        let reportCount = (arr[0] as AnyObject).value(forKey: "reportCount")as! String
                        let userName = UserDefaults.standard.value(forKey: "userName")as! String
                        let message = String(format: "Dear %@ view your %@ previous medical records.",userName,reportCount)
                        if (Int(reportCount) > 0)
                        {
                            if(UserDefaults.standard.bool(forKey: "shworeportspopup") == true){
                                UserDefaults.standard.set(false, forKey: "shworeportspopup")
                                self.showAlertView(message)
                                let triggerTime = (Int64(NSEC_PER_SEC) * 10)
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                    self.registerDeviceTone()
                                })
                            }
                        }
                        if(UserDefaults.standard.value(forKey: "showguideline") != nil){
                            
                            self.ForceUpdate(allResponse as! NSArray)
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil) 
                    }
                }
            });
        });
    }
    
/* internal  func syncServertoLocalDB(_ arrMyRecord : NSArray)  {
        
        for i in (0..<arrMyRecord.count) {
            let database = appDelegate.openDataBase()
            
            do {
                
                let dataBaseId = (arrMyRecord[i] as AnyObject).value(forKey: "databaseid")as! String
                let dietitianName = (arrMyRecord[i] as AnyObject).value(forKey: "dietitian")as! String
                let diseaseName = (arrMyRecord[i] as AnyObject).value(forKey: "disease")as! String
                let doctorName = (arrMyRecord[i] as AnyObject).value(forKey: "doctor")as! String
                let labName = (arrMyRecord[i] as AnyObject).value(forKey: "lab_name")as! String
                let memberId = (arrMyRecord[i] as AnyObject).value(forKey: "memberid")as! String
                
                

                let pdfRecordString = "" //arrMyRecord[i].valueForKey("record")as! String
                let recordType = (arrMyRecord[i] as AnyObject).value(forKey: "record_type")as! String
                let date = (arrMyRecord[i] as AnyObject).value(forKey: "recorddate")as! String
                let recordlink = (arrMyRecord[i] as AnyObject).value(forKey: "recordlink")as! String
                let testName = (arrMyRecord[i] as AnyObject).value(forKey: "test_name")as! String
                
               
                
                let rs = try database.executeQuery(String(format:"select * from recordDetails where dataBaseId = %@  and RecordType = '%@'",dataBaseId,recordType), values: nil)
                
                if rs.next() == false {
                    try database.executeUpdate("insert into RecordDetails (DataBaseId , MemberId ,RecordId, RecordDate , RecordLabName , RecordTestName , DoctorName, DietitianName, RecordDisease ,RecordString ,RecordLink ,LocalToServerSyncStatus, RecordType ,isDeleted) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)", values: [dataBaseId , memberId ,"0", date,labName, testName , doctorName,dietitianName,diseaseName,pdfRecordString,recordlink,"Y",recordType,"N"])
                    
                }else{
                    try database.executeUpdate(String(format:"update recordDetails set  RecordString = '%@', RecordLink = '%@' where DataBaseId = '%@'  and RecordType = '%@'",pdfRecordString,recordlink,dataBaseId,recordType), values: nil)
                }
                
                requestImage(recordlink , dbID: dataBaseId , rType: recordType) { (image) -> Void in
                    //_ = image
                }
               
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            
            database.close()
        }
    }
    func  getNonSyncDataFromDtabase(){
        let database = appDelegate.openDataBase()
        
        do {
            var recordObj = HealthInfo()
            let rs = try database.executeQuery("select * from RecordDetails where LocalToServerSyncStatus = 'N' ORDER BY RANDOM() LIMIT 1 ", values: nil)
            while rs.next() {
                
                print(rs.string(forColumn: "RecordDate"))
                recordObj = HealthInfo()
                recordObj.memberId = rs.string(forColumn: "MemberId")
                recordObj.dataBaseId = rs.string(forColumn: "DataBaseId")
                recordObj.recordId = rs.string(forColumn: "RecordId")
                recordObj.reportDate = rs.string(forColumn: "RecordDate")
                recordObj.reportLabName = rs.string(forColumn: "RecordLabName")
                recordObj.reportTestName = rs.string(forColumn: "RecordTestName")
                recordObj.PDFDataString = rs.string(forColumn: "RecordString")
                recordObj.recordType = rs.string(forColumn: "RecordType")
                recordObj.doctorName = rs.string(forColumn: "DoctorName")
                recordObj.dietitianName = rs.string(forColumn: "DietitianName")
                recordObj.diseaseName = rs.string(forColumn: "RecordDisease")
                createdRecordId = rs.string(forColumn: "RecordId")
                self.syncLocalDBToServer(recordObj)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }
    func  syncLocalDBToServer(_ recordObject : HealthInfo){
       
        if Reachability.isConnectedToNetwork() == true {
            
            // let stringRepresentation = reportData.description
            
            print(recordObject.recordId)
            var recordId = ""
            if recordObject.recordId == "0" {
                recordId = (recordObject.dataBaseId)
            }else{
                recordId = (recordObject.recordId)
            }
            if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
            let customerid = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            
            let dietitianName = (recordObject.diseaseName)
            let diseaseName = (recordObject.diseaseName)
            let doctorName = (recordObject.doctorName)
            let labName = (recordObject.reportLabName)
            let memberId = (recordObject.memberId)
            let pdfRecordString = recordObject.PDFDataString  //(recordObject.PDFDataString)
            let recordType = (recordObject.recordType)
            let date = (recordObject.reportDate)
            let testName = (recordObject.reportTestName)
           // let data = recordObject.PDFDataString.dataUsingEncoding(NSUTF8StringEncoding)
                
            updatedRecordType = recordObject.recordType
            
            let allParameters = ["customerId":customerid, "recordId":recordId,"memberId":memberId,"recordDate":date,"recordLabName":labName,"recordTestName":testName,"doctorName":doctorName,"dietitianName":dietitianName,"disease":diseaseName,"recordString": pdfRecordString,"recordType":recordType]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "SaveRecord_NewResult" ,methodname: "SaveRecord_New", className: self)
                
               // ServerConnectivity().callWebserviceForImageUploading(allParameters, resulttagname: "SaveRecord_NewResult", methodname: "SaveRecord_New", className: self)
            }
        }

    }
    func updateLocalDBAfterSync(_ arrMyUpdateResponse : NSArray)  {
        for  i in (0..<arrMyUpdateResponse.count) {
            let database = appDelegate.openDataBase()
            do {
                let dataBaseId = (arrMyUpdateResponse[i] as AnyObject).value(forKey: "databaseid")as! String
                let recordlink = (arrMyUpdateResponse[i] as AnyObject).value(forKey: "recordlink")as! String
                if createdRecordId == "0" {
                     try database.executeUpdate(String(format:"update recordDetails set RecordLink = '%@', LocalToServerSyncStatus = 'Y' where DataBaseId = '%@'  and RecordType = '%@'",recordlink,dataBaseId,updatedRecordType), values: nil)
                }else{
                    try database.executeUpdate(String(format:"update recordDetails set RecordLink = '%@',DataBaseId ='%@',  LocalToServerSyncStatus = 'Y' where recordId = '%@'  and RecordType = '%@'",recordlink,dataBaseId,createdRecordId,updatedRecordType), values: nil)
                }
               
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            database.close()
        }
    }  */
    
    //MARK: - SyncMyFamilyData 
    
   /* func getNonSyncDataFromMyFamilyTable()  {
        let database = appDelegate.openDataBase()
        do {
            
            let rs = try database.executeQuery("select * from MyFamily where SyncStatus = 'N' ORDER BY RANDOM() LIMIT 1 ", values: nil)
            while rs.next() {
                
                let myfamilyMemberObject = MyFamilyInfo()
                    
                myfamilyMemberObject.memberId = rs.string(forColumn: "MemberId")
                myfamilyMemberObject.memberName = rs.string(forColumn: "MemberName")
                myfamilyMemberObject.memberRelation = rs.string(forColumn: "Relation")
                myfamilyMemberObject.memberPhoto = rs.string(forColumn: "MemberPhoto")
                myfamilyMemberObject.memberDOB = rs.string(forColumn: "MemberDOB")
                myfamilyMemberObject.memberEmail = rs.string(forColumn: "MemberEmail")
                myfamilyMemberObject.memberGender = rs.string(forColumn: "MemberGender")
                myfamilyMemberObject.memberMobileNo = rs.string(forColumn: "MemberMobileNo")
                myfamilyMemberObject.memberVerefyStatus = rs.string(forColumn: "Verified")
                myfamilyMemberObject.memberActiveStatus = rs.string(forColumn: "Active")
                
                self.syncMyFamilyLocalDataToServer(myfamilyMemberObject)
            
            }
            
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }
    
    func  syncMyFamilyLocalDataToServer(_ myfamilyMemberObj : MyFamilyInfo){
        
        if Reachability.isConnectedToNetwork() == true {
           if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
            member_Id = myfamilyMemberObj.memberId
            let memberId = (myfamilyMemberObj.memberId)
            let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            let fullName = (myfamilyMemberObj.memberName)
            let dob = (myfamilyMemberObj.memberDOB)
            let mobileNo = (myfamilyMemberObj.memberMobileNo)
            let email = (myfamilyMemberObj.memberEmail)
            let gender = (myfamilyMemberObj.memberGender)
            let relation = (myfamilyMemberObj.memberRelation)
            let photo = (myfamilyMemberObj.memberPhoto)
            
            let allParameters = ["customerId":customerId, "memberId":memberId,"fullName":fullName,"dob":dob,"mobileNo":mobileNo,"email":email,"gender":gender,"relation":relation,"photo":photo]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "UpdateMemberInfoResult" ,methodname: "UpdateMemberInfo", className: self)
            }
        }
    }
    
    func updateMyFamilyDataAfterSync()  {

        let database = appDelegate.openDataBase()
            do {
                try database.executeUpdate(String(format:"update MyFamily set SyncStatus = 'Y' where memberId ='%@' ",member_Id), values: nil)
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            database.close()
    } */
    
    //MARK: RemindersSync
    
 /*   func getRemindersFromSever(){
        if Reachability.isConnectedToNetwork() == true {
            if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
                
           
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let allParameters = ["customerId":customerId , "reminderIds":"0"]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetRemindersResult" ,methodname: "GetReminders", className: self)
                
            }
        }
    }
    func syncReminderFromServerToDatabase(_ arrReminderList : NSArray)  {
        
        for  i in (0..<arrReminderList.count) {
            let database = appDelegate.openDataBase()
            do {
                let reminderId = (arrReminderList[i] as AnyObject).value(forKey: "reminderId")as! String
                let reminderImage = (arrReminderList[i] as AnyObject).value(forKey: "reminderImage")as! String
                let  duration = (arrReminderList[i] as AnyObject).value(forKey: "Duration")as! String
                let afternoonTime = (arrReminderList[i] as AnyObject).value(forKey: "afternoonTime")as! String
                let endDate = (arrReminderList[i] as AnyObject).value(forKey: "endDate")as! String
                let startDate = (arrReminderList[i] as AnyObject).value(forKey: "startDate")as! String
                let eveningTime = (arrReminderList[i] as AnyObject).value(forKey: "eveningTime")as! String
                let medicineName = (arrReminderList[i] as AnyObject).value(forKey: "medicineName")as! String
                let memberId = (arrReminderList[i] as AnyObject).value(forKey: "memberId")as! String
                let memberName = (arrReminderList[i] as AnyObject).value(forKey: "memberName")as! String
                let morningTime = (arrReminderList[i] as AnyObject).value(forKey: "morningTime")as! String
                let quantity = (arrReminderList[i] as AnyObject).value(forKey: "quantity")as! String
                let rs = try database.executeQuery(String(format:"select * from Reminder where ReminderId = %@",reminderId ), values: nil)
                if rs.next() == false {
                    try database.executeUpdate("insert into Reminder (ReminderId , MemberId , MemberName , MedicineName ,ReminderImage , MorningTime , AfternoonTime , EveningTime , StartDate ,EndDate ,Quantity,Duration ,IsDeleted ,SyncStatus) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)", values: [reminderId,memberId , memberName , medicineName , reminderImage , morningTime , afternoonTime , eveningTime,startDate , endDate ,quantity ,duration , 0 , 1])
                }
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            database.close()
            
        }
        //schedul reminder
        AddReminderViewController().getReminderList()
    }
    
    func syncReminderFromDataBasetoServer()  {
        
        let database = appDelegate.openDataBase()
        let myReminderObj = MyReminderInfo()
        do {
            let rs = try database.executeQuery("select * from Reminder where SyncStatus = '0' ORDER BY RANDOM() LIMIT 1 ", values: nil)
            while rs.next() {
                myReminderObj.r_Id = rs.long(forColumn: "_id")
                myReminderObj.r_ReminderId = rs.string(forColumn: "ReminderId")
                myReminderObj.r_MemberId = rs.string(forColumn: "MemberId")
                myReminderObj.r_MemberName = rs.string(forColumn: "MemberName")
                myReminderObj.r_MedicineName = rs.string(forColumn: "MedicineName")
                myReminderObj.r_ReminderImage = rs.string(forColumn: "ReminderImage")
                myReminderObj.r_MorningTime = rs.string(forColumn: "MorningTime")
                myReminderObj.r_AfternoonTime = rs.string(forColumn: "AfternoonTime")
                myReminderObj.r_EveningTime = rs.string(forColumn: "EveningTime")
                myReminderObj.r_StartDate = rs.string(forColumn: "StartDate")
                myReminderObj.r_EndDate = rs.string(forColumn: "EndDate")
                myReminderObj.r_Quantity = rs.string(forColumn: "Quantity")
                myReminderObj.r_Duration = rs.string(forColumn: "Duration")
                myReminderObj.r_IsDeleted = rs.string(forColumn: "IsDeleted")
                myReminderObj.r_SyncStatus = rs.string(forColumn: "SyncStatus")
                dbReminderId = myReminderObj.r_Id
                self.saveRemindersOnServer(myReminderObj)

            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
            }
    func saveRemindersOnServer(_ myReminderObject : MyReminderInfo)  {
        
        if Reachability.isConnectedToNetwork() == true {
            if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
            let reminderImage = (myReminderObject.r_ReminderImage)
            let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            let medicineName = (myReminderObject.r_MedicineName)
            let morningTime = (myReminderObject.r_MorningTime)
            let afternoonTime = (myReminderObject.r_AfternoonTime)
            let eveningTime = (myReminderObject.r_EveningTime)
            let startDate = (myReminderObject.r_StartDate)
            let endDate = (myReminderObject.r_EndDate)
            let memberId = (myReminderObject.r_MemberId)
            let reminderId = (myReminderObject.r_ReminderId)
            let quantity = (myReminderObject.r_Quantity)
            
            let allParameters = ["reminderImage":reminderImage, "medicineName":medicineName,"morningTime":morningTime,"afternoonTime":afternoonTime,"eveningTime":eveningTime,"startDate":startDate,"endDate":endDate,"quantity":quantity,"customerId":customerId,"memberId":memberId ,"reminderId":reminderId]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "SaveReminderResult" ,methodname: "SaveReminder", className: self)
            }
        }
    }
    

    func updateDataBaseAfterSaveReminder(_ reminderId : String) {
        let database = appDelegate.openDataBase()
        do {
            try database.executeUpdate(String(format:"update Reminder set SyncStatus = 1, ReminderId = '%@' where _id =%d ",reminderId , dbReminderId), values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()

    }
    func getListofDeletedReminder()  {
        let database = appDelegate.openDataBase()
        let myReminderObj = MyReminderInfo()
        do {
            let rs = try database.executeQuery("select * from Reminder where IsDeleted = '1' ORDER BY RANDOM() LIMIT 1 ", values: nil)
            while rs.next() {
                myReminderObj.r_ReminderId = rs.string(forColumn: "ReminderId")
                self.deleteRemindersFromServer(myReminderObj.r_ReminderId)
                deletedReminderId = myReminderObj.r_ReminderId
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }
    
    
    func deleteRemindersFromServer(_ reminderid : String)  {
        if Reachability.isConnectedToNetwork() == true {
            if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
            let reminderId = (reminderid)
            let customerid = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            let allParameters = ["reminderId":reminderId , "customerId": customerid]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "DeleteReminderResult" ,methodname: "DeleteReminder", className: self)
        }
        }
        
    }
    func deleteReminderFromDataBase()   {
        let database = appDelegate.openDataBase()
        do {
           
            try database.executeUpdate(String(format:"delete from Reminder where ReminderId = '%@' ",deletedReminderId), values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        
    }
    
    func deleteAllSyncReminderFromDataBase()  {
        let database = appDelegate.openDataBase()
        do {
            
            try database.executeUpdate(String(format:"delete from Reminder where SyncStatus = %d  and IsDeleted = %d",1,0), values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        
    }  */
    //MARK: NotificationsSync
    func getNotificatiosFromServer(){
        if Reachability.isConnectedToNetwork() == true {
            if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
            let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            let allParameters = ["customerId":customerId]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetNotificationsResult" ,methodname: "GetNotifications", className: self)
            }
        }
    }
    
    func deleteNotifications()  {
        let database = appDelegate.openDataBase()
        
        do {
            
            try database.executeUpdate("delete from Notifications ", values: nil)
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }

    
    internal  func syncNotificationsFromServerToLocal(_ arrNotifications : NSArray)  {
        
        self.deleteNotifications()
        
        for i in (0..<arrNotifications.count) {
            let database = appDelegate.openDataBase()
            do {
                let notificationsId = (arrNotifications[i] as AnyObject).value(forKey: "id")as! String
                let notificationsText = (arrNotifications[i] as AnyObject).value(forKey: "text")as! String
                let notificationsMessages = (arrNotifications[i] as AnyObject).value(forKey: "message")as! String
                let notificationsImage = (arrNotifications[i] as AnyObject).value(forKey: "image")as! String
                let notificationsTime = (arrNotifications[i] as AnyObject).value(forKey: "Column1")as? String
                let memberPhoto = (arrNotifications[i] as AnyObject).value(forKey: "photo")as! String
                let memberName = (arrNotifications[i] as AnyObject).value(forKey: "name")as! String
                let memberId = (arrNotifications[i] as AnyObject).value(forKey: "memberid")as! String
                let memberRelation = (arrNotifications[i] as AnyObject).value(forKey: "relation")as! String
                let memberDOB = (arrNotifications[i] as AnyObject).value(forKey: "dob")as! String
                let memberEmail = (arrNotifications[i] as AnyObject).value(forKey: "email")as! String
                let memberGender = (arrNotifications[i] as AnyObject).value(forKey: "gender")as! String
                let memberMobile = (arrNotifications[i] as AnyObject).value(forKey: "number")as! String
                let recordType = (arrNotifications[i] as AnyObject).value(forKey: "recordtype")as! String
                let recordlink = (arrNotifications[i] as AnyObject).value(forKey: "recordlink")as! String
                let notificationsType = (arrNotifications[i] as AnyObject).value(forKey: "n_type")as! String
                
//                let rs = try database.executeQuery(String(format:"select * from Notifications where NotificationId == %@  ",notificationsId), values: nil)
                
             //   if rs.next() == false {
                    
                    
//                    print( String(format:"insert into Notifications (NotificationId , NotificationText ,MemberPhoto, MemberName , Relation , MemberId , AcceptStatus, SeenStatus, RecordLink ,RecordType ,NotificationType) values (?,?,?,?,?,?,?,?,?,?,?)", values: [notificationsId,notificationsText,"",memberName,memberRelation,memberId,"","",recordlink,recordType,notificationsType]))
                    
                   
                    
                    try database.executeUpdate("insert into Notifications (NotificationId , NotificationText ,NotificationMessage, NotificationImage , NotificationTime , MemberPhoto , MemberName, MemberNumber, MemberEmail ,MemberGender ,MemberDOB,Relation,MemberId,AcceptStatus,SeenStatus,RecordLink,RecordType,NotificationType) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", values: [notificationsId,notificationsText,notificationsMessages,notificationsImage,notificationsTime!,memberPhoto,memberName,memberMobile,memberEmail,memberGender,memberDOB,memberRelation,memberId,1,1,recordlink,recordType,notificationsType])
                    
           //     }
                
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            database.close()
            // update notification after response
            if NotificationsViewController().getNotificationsCount() != 0 {
                lblNotifications.isHidden = false
                lblNotifications.text = String(NotificationsViewController().getNotificationsCount())// get total  Notifications count

            }
            
        }
    }
    
    func showPushNotificationAlert(){
        if GlobalInfo.sharedInfo.isNeedToShowPushAlert() {
            let showPushViewController = KMAINSTORYBOARD.instantiateViewController(withIdentifier: "ShowPushViewController") as! ShowPushViewController
        showPushViewController.modalPresentationStyle = .overFullScreen//.overCurrentContext
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {//3 Sec Delay
                 self.present(showPushViewController, animated: true, completion: nil)
            }
            AppDelegate.getAppDelegate().isComingfromLaunching = false
        }
    }
    
    func registerDeviceTone(){
        if Reachability.isConnectedToNetwork() == true {
            
           if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
            
            let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            
//            print(NSUserDefaults.standardUserDefaults().valueForKey("loginCustomerId")as! String)
//            print(NSUserDefaults.standardUserDefaults().valueForKey("device_token"))
//            print(NSUserDefaults.standardUserDefaults().valueForKey("mobileNo")as! String)
            var device_token = ""
            
            if UserDefaults.standard.value(forKey: "device_token") != nil {
                device_token = UserDefaults.standard.value(forKey: "device_token")as! String
            }
            
            //NSUserDefaults.standardUserDefaults().valueForKey("device_token") as! String
            
            let deviceToken = (device_token)
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            print(version)
            let appVersion = (version!)
            let mobile_No =  (UserDefaults.standard.value(forKey: "mobileNo")as! String)
            
            
            let allParameters = ["customerId":customerId , "gcmToken": deviceToken ,"appVersion": appVersion,"mobile":mobile_No]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GCMRegisterationV2Result" ,methodname: "GCMRegisterationV2", className: self)
            }
        }
    }
    
    //MARK: GetAllTest
    func getAllTests()  {
        
        if Reachability.isConnectedToNetwork() == true {
            if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
            let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            
            let allParameters = ["memberId":customerId ]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetAllTestsResult" ,methodname: "GetAllTests", className: self)
            }
        }
    }
    //MARK: GetAllTestsByFamily
    func getAllTestsByFamily(_ m_id : String)  {
        
        if Reachability.isConnectedToNetwork() == true {
            if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
            if (m_id == "") {
                let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
                let allParameters = ["memberId":customerId ]
                ServerConnectivity().callWebservice(allParameters, resulttagname: "GetAllTestsByFamilyResult" ,methodname: "GetAllTestsByFamily", className: self)
            }else{
                let customerId = (m_id)
                let allParameters = ["memberId":customerId ]
                ServerConnectivity().callWebservice(allParameters, resulttagname: "GetAllTestsByFamilyResult" ,methodname: "GetAllTestsByFamily", className: self)
            
            }
            }
        }
    }
    // comment for new Screen
  /*  func loadTestData()  {
        
        for i in 0..<arrGetAllTestList.count {
            let testName = arrGetAllTestList[i].valueForKey("test_name")as! String
            if !(arrTestList.containsObject(testName)) {
               arrTestList.addObject(testName)
            }
        }
        selectedTestName = arrTestList[0] as! String
        for view in self.view.subviews {
            
            view.removeFromSuperview()
        }
        self.createALayout()
        if(NSUserDefaults.standardUserDefaults().valueForKey("showguideline") == nil && NSUserDefaults.standardUserDefaults().valueForKey("loginCustomerId") != nil ){
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
           self.showGuideLineView()
           NSUserDefaults.standardUserDefaults().setValue("hide", forKey: "showguideline")
        }
    } */
    
    // MARK: deleteReport(bySyncProcess)
    
  /*  func getListofDeletedReport()  {
        let database = appDelegate.openDataBase()
        let reportdObj = HealthInfo()
        do {
            let rs = try database.executeQuery("select * from RecordDetails where isDeleted = 'Y' ORDER BY RANDOM() LIMIT 1 ", values: nil)
            while rs.next() {
                  reportdObj.dataBaseId = rs.string(forColumn: "DataBaseId")
                  reportdObj.recordType = rs.string(forColumn: "RecordType")
                  deletedReportId = reportdObj.dataBaseId
                deleteReportFromServer(deletedReportId, rType: reportdObj.recordType)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        
    }
    func deleteReportFromServer(_ databaseId : String , rType : String)  {
        if Reachability.isConnectedToNetwork() == true {
            if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
             let customerid = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            let recordId = (databaseId)
            let recordType = (rType)
            let allParameters = ["recordIds": recordId , "customerId": customerid ,"recordType": recordType]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "DeleteRecordsResult" ,methodname: "DeleteRecords", className: self)
            }
        }
    }
    func deleteReportFromDatabase()   {
        let database = appDelegate.openDataBase()
        do {
            
            try database.executeUpdate(String(format:"delete from RecordDetails where DataBaseId = '%@' ",deletedReportId), values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    } */
    // MARK: getCartCount
    func getCartMemebrtCount() -> Int{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        var  mCount = 0
        do {
            let rs = try database.executeQuery("SELECT COUNT(DISTINCT orderId) FROM order_Package_Purchased where addedToCart = '1'", values: nil)
            while rs.next() {
                mCount = Int(rs.int(forColumn: "COUNT(DISTINCT orderId)"))
                print(mCount)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        return mCount
    }
    

    //MARK: deletePackageNotAddedInCart
    func deletePackageNotAddedInCart()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        do {
            try database.executeUpdate("delete from Order_Package_Purchased where addedToCart = '0'", values: nil)
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }
    
    //MARK: - buttonOnClick
    func buttonOnClick(_ sender : UIButton!)  {
     //   if !(carbonTabSwipeNavigation.currentTabIndex == 1 && identifires == "BOOK AN ORDER") {
        
            selectedbutton.frame = CGRect(x: selectedbutton.frame.origin.x, y: selectedbutton.frame.origin.y+5, width: 60, height: 60)
            selectedbutton.layer.cornerRadius = (selectedbutton.frame.width/2)
            selectedbutton.backgroundColor = UIColor (red: (224.0/255.0), green: (224.0/255.0), blue: (224.0/255.0), alpha: 1)
            sender.frame = CGRect(x: sender.frame.origin.x, y: sender.frame.origin.y-5, width: 70, height: 70)
            sender.layer.cornerRadius = (sender.frame.width/2)
            sender.backgroundColor = KRED_COLOR
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
//            NSUserDefaults.standardUserDefaults().setValue("\(sender.tag)", forKey: "selectedMemberId")
//            currentVC?.filterData!("\(sender.tag)")
            
  //      }
    }
    func notifications()  {
        let myReminderVC = MyReminderViewController()
        self.navigationController?.pushViewController(myReminderVC, animated: false)
        
    }
    //MARK: ACTIONSHEET DELEGATE

//    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
//    {
//        switch (buttonIndex){
//            
//        case 0:
//            print("Delete")
//            actionSheet.removeFromSuperview()
//        case 1:
//            print(KCHECKIN_CODE)
//            let barCodeVC = CheckinBarcodeViewController()//BarCodeViewController()
//            self.navigationController?.pushViewController(barCodeVC, animated: true)
//            
//        case 2:
//            print(KCORP_CHECKIN)
//            let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
//            let manualBarCodeEnterViewController = storyboard1.instantiateViewController(withIdentifier: "ManualBarCodeEnterViewController") as! ManualBarCodeEnterViewController
//            self.navigationController?.pushViewController(manualBarCodeEnterViewController, animated: true)
//
//
//            
//            
//        default:
//            print("Default")
//            //Some code here..
//            
//        }
//    }
    //MARK: showAlert
    
    func openActionSheettoUploadBarcode(){
        let alertSheet = UIAlertController(title: KCHANGEPHOTO, message: nil, preferredStyle: .actionSheet)
        alertSheet.view.tintColor = KRED_COLOR
        /*
         case 1:
         print(KCHECKIN_CODE)
         let barCodeVC = CheckinBarcodeViewController()//BarCodeViewController()
         self.navigationController?.pushViewController(barCodeVC, animated: true)
         
         case 2:
         print(KCORP_CHECKIN)
         let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
         let manualBarCodeEnterViewController = storyboard1.instantiateViewController(withIdentifier: "ManualBarCodeEnterViewController") as! ManualBarCodeEnterViewController
         self.navigationController?.pushViewController(manualBarCodeEnterViewController, animated: true)
         */
        alertSheet.addAction(UIAlertAction(title: KCHECKIN_BAR, style: .default, handler: { (alert: UIAlertAction!) in
            let barCodeVC = CheckinBarcodeViewController()//BarCodeViewController()
            self.navigationController?.pushViewController(barCodeVC, animated: true)
        }))
        
        alertSheet.addAction(UIAlertAction(title: KCHECKING_ID, style: .default, handler: { (alert: UIAlertAction!) in
            let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
            let manualBarCodeEnterViewController = storyboard1.instantiateViewController(withIdentifier: "ManualBarCodeEnterViewController") as! ManualBarCodeEnterViewController
            self.navigationController?.pushViewController(manualBarCodeEnterViewController, animated: true)
        }))
        
        alertSheet.addAction(UIAlertAction(title: KCANCEL, style: .cancel, handler: { (alert: UIAlertAction!) in
            alertSheet.dismiss(animated: true, completion: nil)
        }))
        present(alertSheet, animated: true, completion: nil)
        
//        return alertSheet
//        let actionSheet = UIActionSheet(title: "", delegate: self, cancelButtonTitle: "CANCEL", destructiveButtonTitle: nil, otherButtonTitles: KCHECKIN_BAR, KCHECKING_ID)
//        actionSheet.show(in: self.view)
    }
    
    func showAlertView(_ message : String)  {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Reports", message: message, preferredStyle: .alert)
        //Create and add the Continue action
        let continueAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
            
        }
        actionSheetController.addAction(continueAction)
        //Create and add the Discart action
        let discardAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
            //Do some stuff
            let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
            let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
            homeTapSwipeVC.identifires = "MY RECORDS"
            self.navigationController?.pushViewController(homeTapSwipeVC, animated: true)
            
        }
        actionSheetController.addAction(discardAction)
        //self.presentViewController(actionSheetController, animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.present(actionSheetController, animated: true, completion: nil)
    }
    func ForceUpdate(_ responseData : NSArray)  {
        
        let market_Version = (responseData[0] as AnyObject).value(forKey: "IOS_version")as! String
        let marketVersion = Int(market_Version)
        let appupdate_Status = (responseData[0] as AnyObject).value(forKey: "IOSappupdatestatus")as! String
        let appupdateStatus = Int(appupdate_Status)
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
//        version?.components(separatedBy: ".").joined()
        print(version!.components(separatedBy: ".").joined())
        
//        let delimiter = "."
//        var token = version!.components(separatedBy: delimiter)
        let appVersion = Int(version!.components(separatedBy: ".").joined())
        
        if (appupdateStatus == 1  && appVersion < marketVersion) {
            let actionSheetController: UIAlertController = UIAlertController(title: "New Version!", message: "Please update your app to the latest version", preferredStyle: .alert)
            //Create and add the Continue action
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel) { action -> Void in
                //Do some stuff
                UIApplication.shared.openURL(URL(string: "http://onelink.to/gae3x8")!)
                self.appDelegate.forceUpdate = true
            }
            actionSheetController.addAction(okAction)
            //self.presentViewController(actionSheetController, animated: true, completion: nil)
            UIApplication.shared.keyWindow?.rootViewController?.present(actionSheetController, animated: true, completion: nil)
        }else if (appVersion < marketVersion){
              UserDefaults.standard.set(false, forKey: "forceupdate")
            let actionSheetController: UIAlertController = UIAlertController(title: "New Version!", message: "Please update your app to the latest version.", preferredStyle: .alert)
            //Create and add the Continue action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                //Do some stuff
                
            }
            actionSheetController.addAction(cancelAction)
            //Create and add the Discart action
            let oklAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
                //Do some stuff
            UIApplication.shared.openURL(URL(string: "http://onelink.to/gae3x8")!)
            }
            actionSheetController.addAction(oklAction)
           // self.presentViewController(actionSheetController, animated: true, completion: nil)
            UIApplication.shared.keyWindow?.rootViewController?.present(actionSheetController, animated: true, completion: nil)
        }
    }
    
    //MARK: - TableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (tableView == tblView) {
          return arrAllTestByFamily.count
        }else{
         return tempDataFamily.count//arrMyFamilyList.count
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if tableView == tblView {
            
       
        let index_row = (indexPath as NSIndexPath).row
        
        let cellIdentifier:String = "homeCell"
        var cell:HomeTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? HomeTableViewCell
        var nib:Array = Bundle.main.loadNibNamed("HomeTableViewCell", owner: self, options: nil)!
        
        cell = nib[0] as? HomeTableViewCell
        cell?.selectionStyle = .none
        //cell?.backgroundColor = KRED_COLORColor()
        cell?.lbltestName.text = (arrAllTestByFamily[index_row] as AnyObject).value(forKey: "test_name")as? String
        cell?.lblTestValue.text = (arrAllTestByFamily[index_row] as AnyObject).value(forKey: "value")as? String
        cell?.lblTestUnit.text = (arrAllTestByFamily[index_row] as AnyObject).value(forKey: "t_meas")as? String
        let generalRang = (arrAllTestByFamily[index_row] as AnyObject).value(forKey: "general_range")as? String
        let testUnit = (arrAllTestByFamily[index_row] as AnyObject).value(forKey: "t_meas")as? String
        cell?.lblGeneralTestRange.text = "(" + generalRang! + ")" + testUnit!
        let intesity = (arrAllTestByFamily[index_row] as AnyObject).value(forKey: "intensity")as? String
        
        cell?.lblTestValue.font = UIFont.boldSystemFont(ofSize: 15)
        if (intesity == "1") {
            cell?.lblIntensity.text = "LOW"
            cell?.intensityImageView.image = UIImage(named: "low_circle.png")
        }else if(intesity == "2"){
            cell?.lblIntensity.text = "MEDIUM"
            cell?.intensityImageView.image = UIImage(named: "medium_circle.png")
        }else if(intesity == "3"){
            cell?.lblIntensity.text = "HIGH"
            cell?.intensityImageView.image = UIImage(named: "high_circle.png")
        }
        
        switch index_row + 1 {
        case 1: // New Order Booked
           cell?.backgroundColor = UIColor (red: (255/255), green: (152/255), blue: (26/255), alpha: 1)
            break
        case 2:
              cell?.backgroundColor = UIColor (red: (255/255), green: (152/255), blue: (26/255), alpha: 0.9)
            break
        case 3:
              cell?.backgroundColor = UIColor (red: (255/255), green: (152/255), blue: (26/255), alpha: 0.8)
            break
        case 4:
             cell?.backgroundColor = UIColor (red: (255/255), green: (152/255), blue: (26/255), alpha: 0.7)
            break
        case 5:
            cell?.backgroundColor = UIColor (red: (255/255), green: (152/255), blue: (26/255), alpha: 0.6)
            break
        case 6:
             cell?.backgroundColor = UIColor (red: (255/255), green: (152/255), blue: (26/255), alpha: 0.5)
            break
            
        case 7:
            cell?.backgroundColor = UIColor (red: (255/255), green: (152/255), blue: (26/255), alpha: 0.7)
            break
            
        case 8:
             cell?.backgroundColor = UIColor (red: (255/255), green: (152/255), blue: (26/255), alpha: 0.9)
            break
        case 9:
             cell?.backgroundColor = UIColor (red: (255/255), green: (152/255), blue: (26/255), alpha: 0.8)
            break
        case 10:
              cell?.backgroundColor = UIColor (red: (255/255), green: (152/255), blue: (26/255), alpha: 0.7)
            break
            
        default: break
        }
            
            return cell!
        }else{
        
            let myFamilyMemberObj = tempDataFamily[(indexPath as NSIndexPath).row]as! MyFamilyInfo
//            arrMyFamilyList[(indexPath as NSIndexPath).row]as! MyFamilyInfo
            let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
            
            
            let userImageView = BaseUIController().AImageViewFrame(CGRect(x: 10, y: 10, width: 24, height: 24), withImageName: "user_icon.png")as! UIImageView
            userImageView.layer.masksToBounds = true
            userImageView.layer.cornerRadius = userImageView.frame.width/2
            cell.addSubview(userImageView)
            let lbluserName = BaseUIController().ALabelFrame(CGRect( x: 50, y: 10, width: 250, height: 24), withString: "")as! UILabel
            cell.addSubview(lbluserName)
            lbluserName.text = myFamilyMemberObj.memberName
            lbluserName.textColor = UIColor (red: (55.0/255.0), green: (54/255.0), blue: (54.0/255.0), alpha: 1)
            lbluserName.font = UIFont(name: KROBOTO_LIGHT, size: 16.0)
            
            let imageString = myFamilyMemberObj.memberPhoto
            let data = Data(base64Encoded: imageString, options: NSData.Base64DecodingOptions(rawValue: 0))
            if imageString != "" {
                userImageView.image = UIImage.init(data: data!)
            }else{
                userImageView.image = UIImage(named: "avatar1.png")
            }
            return cell;
        }
       
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == memberListTableView {
            bgView.removeFromSuperview()
            //set activity on view
            activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
//            activityIndicator = ProgressViewController(inview: tableView, loadingViewColor: <#T##UIColor#>, indicatorColor: <#T##UIColor#>, msg: <#T##String#>, customHeight: <#T##CGFloat#>)
            activityIndicator?.frame = CGRect(x: tableView.frame.width/2 - 30, y: 100, width: 60, height: 60)
            //tblView.addSubview(activityIndicator!)
            activityIndicator?.start()
            myFamilyMemberObj = tempDataFamily[(indexPath as NSIndexPath).row]as! MyFamilyInfo
            self.getAllTestsByFamily(myFamilyMemberObj.memberId)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (tableView == tblView) {
            return 65
        }else{
            return 44
        }
        
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if tableView == memberListTableView {
            return 90
        }else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 90))
        headerView.backgroundColor = UIColor.white
        let lblSelectMember = BaseUIController().ALabelFrame(CGRect(x: 10 ,y:0 ,width: tableView.frame.width - 10 , height: 49), withString: "Select Member") as! UILabel
        lblSelectMember.font = UIFont(name: KROBOTO_LIGHT, size: 19.0)
        lblSelectMember.textColor = UIColor.black
        
        let seperatorLine = BaseUIController().ALabelFrame(CGRect(x: 0 ,y:49 ,width: tableView.frame.width , height: 1), withString: "") as! UILabel
        seperatorLine.backgroundColor = UIColor.black
        seperatorLine.textColor = UIColor.clear
        headerView.addSubview(lblSelectMember)
        headerView.addSubview(seperatorLine)
        
        let cancelButton = UIButton(frame: CGRect(x: headerView.frame.size.width - 40, y: 10, width: 30, height: 30))
        cancelButton.setImage(#imageLiteral(resourceName: "verified_no.png"), for: .normal)
        cancelButton.addTarget(self, action: #selector(HomeViewController.cancelButtonClicked(_:)), for: .touchUpInside)
        headerView.addSubview(cancelButton)

        configureSearchBar()
        searchBar.frame = CGRect(x: headerView.frame.origin.x, y: seperatorLine.frame.origin.y + seperatorLine.frame.size.height, width: headerView.frame.size.width, height: 40)
        headerView.addSubview(searchBar)
        return headerView
    }
    
    func cancelButtonClicked(_ sender: AnyObject){
       bgView.removeFromSuperview()
    }
    
    func configureSearchBar() {
        searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.isSearchResultsButtonSelected = true
        let textField = searchBar.value(forKey: "searchField") as! UITextField
        textField.clearButtonMode = .never
        searchBar.delegate = self
       searchBar.placeholder = "Name"
    }
    
    //MARK: Search Bar Delegates
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        
//        print("again")
//    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        var completeString = ""
        if text == "\n" {
            searchBar.resignFirstResponder()
            return true
        }
        if text.isEmpty ==  false{
            completeString = searchBar.text! + text
        }else{
            completeString = searchBar.text!
            if completeString.characters.count > 0 {
                completeString = String(completeString.characters.dropLast(1))
                if completeString.isEmpty == true{
                    tempDataFamily = arrMyFamilyList
                    memberListTableView.reloadData()
                    return true
                }
            }else{
                tempDataFamily = arrMyFamilyList
                memberListTableView.reloadData()
                return true
            }
        }
        let searchPredicate = NSPredicate(format: "memberName CONTAINS[c] %@", completeString)
        tempDataFamily = (arrMyFamilyList.filtered(using: searchPredicate) as? NSMutableArray)!
        print(tempDataFamily)
        memberListTableView.reloadData()
        return true
    }
    
    
   
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Not in use
    func getMyFamilyList()-> NSMutableArray  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        arrMyFamilyList = NSMutableArray()
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
                familyMemberObj.memberMobileNo = rs.string(forColumn: "MemberMobileNo")
                familyMemberObj.memberVerefyStatus = rs.string(forColumn: "Verified")
                familyMemberObj.memberActiveStatus = rs.string(forColumn: "Active")
                arrMyFamilyList.add(familyMemberObj)
            }
            tempDataFamily = arrMyFamilyList
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        return arrMyFamilyList
    }
    
    
    
    
    
    func requestImage(_ url: String,dbID: String,rType:String, success: @escaping (UIImage?) -> Void) {
        requestURL(url , dbID: dbID, rType: rType, success: { (data) -> Void in
            if let d = data {
                success(UIImage(data: d))
            }
        })
    }
    
    func requestURL(_ url: String,dbID: String,rType:String, success: @escaping (Data?) -> Void, error: ((NSError) -> Void)? = nil) {
       
        
        print(url)
    //    let trimmedStringUrl = url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let replacedString = url.replacingOccurrences(of: " ", with: "%20")
        print(replacedString)
        NSURLConnection.sendAsynchronousRequest(
            URLRequest(url: URL (string: replacedString)!),
            queue: OperationQueue.main,
            completionHandler: { response, data, err in
                if let e = err {
                    error?(e as NSError)
                } else {
                    
                    print(dbID)
                    print(rType)
                    

                    let base64String = data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                    let database = self.appDelegate.openDataBase()
                        
                        do {
                            
                            let dataBaseId = dbID
                            let recordType = rType
                            let pdfRecordString = base64String //arrMyRecord[i].valueForKey("record")as! String
                            
                      
                            
                       try database.executeUpdate(String(format:"update recordDetails set RecordString ='%@', ServerToLocalSyncStatus = 'Y' where DataBaseId = '%@'  and RecordType = '%@'",pdfRecordString,dataBaseId,recordType), values: nil)
                            
                            
                        } catch let error as NSError {
                            print("failed: \(error.localizedDescription)")
                        }
                        database.close()
                     self.loadDataFromDataBase()
                    
                    success(data)
                }
        })
    }
    
    
}
 
 extension Data {
//    public func imageFromUrl(_ urlString: String) {
//        if let url = URL(string: urlString) {
//            let request = URLRequest(url: url)
//            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main)
//            {
//                (response: URLResponse?, data: Data?, error: Error?) -> Void in
//                if let imageData = data as Data? {
//                    imageData
//                }
//            }  -> Void
//        }
//    }
 }

