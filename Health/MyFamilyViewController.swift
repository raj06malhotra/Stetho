
//
//  MyFamilyViewController.swift
//  Health
//
//  Created by HW-Anil on 6/21/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
/*
 typedef enum ScrollDirection {
 ScrollDirectionNone,
 ScrollDirectionRight,
 ScrollDirectionLeft,
 ScrollDirectionUp,
 ScrollDirectionDown,
 ScrollDirectionCrazy,
 } ScrollDirection;
 */

enum ScrlDirection {
    case ScrollDirectionNone
    case ScrollDirectionDown
    case ScrollDirectionUp
}
class MyFamilyViewController: UIViewController ,serverTaskComplete , CNContactPickerDelegate , UITableViewDelegate ,UITableViewDataSource , UIGestureRecognizerDelegate , UIPickerViewDataSource , UIPickerViewDelegate {
    //MARK: - VariableDeclaration
    var total = 0
    fileprivate var activityIndicator : ProgressViewController?
    var mutableData:NSMutableData  = NSMutableData()
    var arrMyFamilyRecord :NSMutableArray?
    var currentElementName:NSString = ""
    var isInterSects = Bool()
    var arrUserView = NSMutableArray()
    var scrollView = UIScrollView()
    var btnDelete = UIButton()
    var fromMemberId = ""
    var toMemberId = ""
    var fromMemberName = ""
    var toMemberName = ""
    var selectedMemberId = ""
    
    //add new member
    var newAddedMemberId = ""
    var bgView = UIView()
    var rightBarView = UIView()
    var lblNotifications = UILabel()
    // for write text
    var progressView = MBProgressHUD()
    var inviteTableView : UITableView = UITableView()
    var tableView : UITableView = UITableView()
    var shadowBackGround : UIView = UIView()
    var arrRelationCategory = ["Spouse" , "Father", "Mother" , "Sibling","Child","Others","You"]
    var arrExistingUser = NSMutableArray()
    var relation = ""
    let dictContactDetails = NSMutableDictionary()
    var txtOtp = UITextField()
    var isComingFromaddReminder = false
    var lblAddMember: UILabel!
    var initialPoint : CGPoint!
    var relationPickerView = UIPickerView()
    var isComingFromNotification = false
    
    
    
    
  //  MARK: - viewLifeCycleMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        // set activity Indicator on view
       
//        self.loadMyFamilyData()
//        self.createALayout()
        self.addBarButtonOnNavigation()
        self.view.backgroundColor = UIColor.white
        self.addLeftBarButton()
        // show & hide keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        // add activity on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        
        if Reachability.isConnectedToNetwork() == true && isComingFromNotification == true {
            self.getMyFamilyFromWebservice()
        }else{
            self.loadMyFamilyData()
            self.createALayout()
        }
       

    }
    override func viewWillAppear(_ animated: Bool) {
        // add Navigation setup
        self.title = "MY FAMILY"
        self.navigationController?.navigationBar.tintColor = KRED_COLOR
        self.navigationController?.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
         isInterSects = false
      
        
        //reload view after update
        if isComingFromaddReminder == true {
            self.loadMyFamilyData()
            for v1 in view.subviews{
                print(v1)
                if v1 != activityIndicator {
                    
                    v1.removeFromSuperview()
                }
               
            }
            self.createALayout()
        }
        if  isComingFromaddReminder == false{
            isComingFromaddReminder = true
        }
       
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("MyFamily Screen")

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addBarButtonOnNavigation() {
        
        // Add custom View on right navigation Bar
        
        rightBarView.removeFromSuperview()
        rightBarView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 44))
        rightBarView.tag = 500
        
        let btnHome = BaseUIController().AButtonFrame(CGRect(x: 0, y: 2, width: 30,height: 40), withButtonTital: "")as! UIButton
        btnHome.setImage(UIImage (named: "home_icon"), for: UIControlState())
        btnHome.addTarget(self, action: #selector(self.btnHomeBarButtonOnClick(_:)), for: UIControlEvents.touchUpInside)
        rightBarView.addSubview(btnHome)
        btnHome.imageEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 5)
        
        
        let btnCart = BaseUIController().AButtonFrame(CGRect(x: 30, y: 2, width: 30,height: 40), withButtonTital: "")as! UIButton //  5 12 //CGRect(x: 30, y: 2, width: 30,height: 40)
        btnCart.imageEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 5)
        
        btnCart.setImage(UIImage (named: "cart_icon"), for: UIControlState())
        btnCart.addTarget(self, action: #selector(self.btnCartBarButtounOnClick(_:)), for: UIControlEvents.touchUpInside)
        rightBarView.addSubview(btnCart)
        
        let lblCart = BaseUIController().ALabelFrame(CGRect(x: 50 ,y: 0, width: 16, height: 16), withString: "")as! UILabel
        lblCart.text = String(self.getCartMemebrtCount())// get count of Selected Member in cart
        if (self.getCartMemebrtCount() == 0) {
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
        btnNotificaitons.addTarget(self, action: #selector(self.btnNotificationBarButtnOnClick(_:)), for: UIControlEvents.touchUpInside)
        rightBarView.addSubview(btnNotificaitons)
        btnNotificaitons.imageEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 5)
        
        lblNotifications = BaseUIController().ALabelFrame(CGRect(x: 75 ,y: 0, width: 16, height: 16), withString: "0")as! UILabel
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
        
        rightBarView.addSubview(lblNotifications)
        let barButtonItem = UIBarButtonItem(customView: rightBarView)
        self.navigationItem.rightBarButtonItem = barButtonItem
        
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
    //MARK: CreateLayout
    func createALayout()  {
        
        let imageSize = self.view.frame.width/5 // for daynamic height & width 
        
        let btnAddMember = BaseUIController().AButtonFrame(CGRect(x: self.view.frame.width/2 - imageSize/2 , y: 70 , width: imageSize , height: imageSize), withButtonTital: "")as! UIButton
        btnAddMember.setImage(UIImage(named: "add_family_icon.png"), for: UIControlState())
        btnAddMember.addTarget(self, action: #selector(MyFamilyViewController.btnAddMemberOnClick(_:)), for: .touchUpInside)
        self.view.addSubview(btnAddMember)
        lblAddMember = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width/2 - 100 , y: imageSize + 64 ,width: 200 , height: 21), withString: "Add Family Member")as! UILabel
        lblAddMember.textAlignment = .center
        lblAddMember.font = UIFont().regularMediumFont
        self.view.addSubview(lblAddMember)
        
        btnDelete = BaseUIController().AButtonFrame(CGRect(x: self.view.frame.width - 70, y: 80, width: 30, height: 44), withButtonTital: "Delete")as! UIButton
        btnDelete.setImage(UIImage(named: "delete-icon.png"), for: UIControlState())
        btnDelete.isHidden = true
        self.view.addSubview(btnDelete)
        var xPos:CGFloat = 0
        var yPos:CGFloat = 0
         scrollView = UIScrollView.init(frame: CGRect(x: 0, y: lblAddMember.frame.origin.y + 20 + 10, width: self.view.frame.width, height: self.view.frame.height - 140))
        self.view.addSubview(scrollView)
        var userView = UIView()
        arrUserView = NSMutableArray()
        total = (arrMyFamilyRecord?.count)!
        let widthOFUserView = (self.view.frame.width/3)
        let heightOFUserView = (self.view.frame.width/3) + 55
        for  i in 0..<total {
            if i % 3 == 0  && i != 0 {
                xPos = 0
                yPos += heightOFUserView + 10
            }
            var familyMemberObj = MyFamilyInfo()
            familyMemberObj = arrMyFamilyRecord![i] as! MyFamilyInfo
            
            userView = UIView.init(frame: CGRect(x: xPos, y: yPos, width: widthOFUserView - 1, height: heightOFUserView))
            xPos += (self.view.frame.width/3) + 1
            userView.tag = 100 + i
            scrollView.addSubview(userView)
            print(i)
            let userImageView = BaseUIController().AImageViewFrame(CGRect(x:15 ,y: 5 ,width: widthOFUserView - 30,height: widthOFUserView - 30), withImageName: "avatar1.png")as! UIImageView
            userImageView.tag = 200 + i
            userImageView.layer.masksToBounds = true
            userImageView.layer.cornerRadius = userImageView.frame.height/2
            userImageView.isUserInteractionEnabled = true
            userView.addSubview(userImageView)
            //
            let imageString = familyMemberObj.memberPhoto
            let data = Data(base64Encoded: imageString, options: NSData.Base64DecodingOptions(rawValue: 0))
            
            if imageString != "" {
                userImageView.image = UIImage.init(data: data!)
            }else{
                userImageView.image = UIImage(named: "avatar1.png")
            }
            
            print(userImageView.frame.height)
            
            let lblName = BaseUIController().ALabelFrame(CGRect(x: 0 , y: userImageView.frame.height + 15 , width:userView.frame.width ,height:0 ), withString: familyMemberObj.memberName)as! UILabel
            lblName.tag = 200 + i
            lblName.isUserInteractionEnabled = true
            lblName.sizeToFit()
            lblName.frame = CGRect(x: (userView.frame.width - lblName.frame.width)/2, y: userImageView.frame.height + 15, width: userView.frame.width, height: lblName.frame.height)
            lblName.sizeToFit()
           // lblName.adjustsFontSizeToFitWidth = true
//            let name = familyMemberObj.memberName 
//            let size: CGSize = name.sizeWithAttributes([NSFontAttributeName: UIFont().mediumFont])
//            print(size.height)
//            print(size.width)
            lblName.textAlignment = .center
            lblName.font = UIFont().mediumFont
            userView.addSubview(lblName)
//            lblName.frame = CGRectMake((userView.frame.width - lblName.frame.width)/2, 65, userView.frame.width, 0)
//            lblName.sizeToFit()
            
             print(lblName.frame.height + 70)
            
            let lblRelation = BaseUIController().ALabelFrame(CGRect(x: 0 , y: lblName.frame.height + lblName.frame.origin.y + 5  ,width: userView.frame.width ,height: 20 ), withString: String(format: "(%@)",familyMemberObj.memberRelation))as! UILabel
            lblRelation.tag = 4000 + i
            lblRelation.isUserInteractionEnabled = true
            lblRelation.textAlignment = .center
            lblRelation.font = UIFont().smallFont
            userView.addSubview(lblRelation)
            // set hidden if relation is empty
            if (familyMemberObj.memberRelation == "") {
                lblRelation.text = ""
            }
            
            // check varify member
            print(lblRelation.frame.height + lblRelation.frame.origin.x)
            
            let lblVerifyOrNot = BaseUIController().ALabelFrame(CGRect(x: (userView.frame.width - 65)/2,y: (lblRelation.frame.height + lblRelation.frame.origin.x + 5) , width: 75, height: 15), withString: "Verify")as! UILabel
            lblVerifyOrNot.tag = 5000 + i
            lblVerifyOrNot.isUserInteractionEnabled = true
            lblVerifyOrNot.font = UIFont().mediumFont
           // lblVerifyOrNot.backgroundColor = UIColor.blueColor()
            userView.addSubview(lblVerifyOrNot)
            let verifyImageView = BaseUIController().AImageViewFrame(CGRect(x: lblVerifyOrNot.frame.origin.x - 20 , y: 120, width: 16, height: 16), withImageName: "verified_yes.png")as! UIImageView
            userView.addSubview(verifyImageView)
            if familyMemberObj.memberVerefyStatus == "1" {
                 lblVerifyOrNot.textColor = UIColor.green
                lblVerifyOrNot.frame = CGRect(x: (userView.frame.width - 35)/2,y: (lblRelation.frame.height + lblRelation.frame.origin.y + 5) , width: 35, height: 15)
                verifyImageView.frame = CGRect(x: lblVerifyOrNot.frame.origin.x - 20 , y: (lblRelation.frame.height + lblRelation.frame.origin.y + 5), width: 16, height: 16)
            }else{
                lblVerifyOrNot.textColor = KRED_COLOR
                lblVerifyOrNot.text = "Not Verified"
                verifyImageView.image = UIImage(named: "verified_no.png")
                lblVerifyOrNot.frame = CGRect(x: (userView.frame.width - 65)/2,y: (lblRelation.frame.height + lblRelation.frame.origin.y + 5) , width: 75, height: 15)
                verifyImageView.frame = CGRect(x: lblVerifyOrNot.frame.origin.x - 20 , y: (lblRelation.frame.height + lblRelation.frame.origin.y + 5), width: 16, height: 16)
               
            }
            
            arrUserView.add(userView)
            // add longpress gesture on UserView 
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MyFamilyViewController.longPressOnView(_:))) //UIPanGestureRecognizer(target: self, action: #selector(MyFamilyViewController.longPressOnView(_:)))
            userView.addGestureRecognizer(longPressRecognizer)
            
            let tapGesture = UITapGestureRecognizer(target: self , action: #selector(self.tapOnUserView(_:)))
            userImageView.addGestureRecognizer(tapGesture)
            let tapGestureOnName = UITapGestureRecognizer(target: self , action: #selector(self.tapOnUserName(_:)))
            lblName.addGestureRecognizer(tapGestureOnName)
            
            let tapGestureOnNotVerify = UITapGestureRecognizer(target: self , action: #selector(self.tapOnVerify(_:)))
            lblVerifyOrNot.addGestureRecognizer(tapGestureOnNotVerify)
            
            let tapGestureOnRelation = UITapGestureRecognizer(target: self , action: #selector(self.tapOnRelation(_:)))
            lblRelation.addGestureRecognizer(tapGestureOnRelation)
        }
       // scrollView.contentSize = CGSizeMake(self.view.frame.width, yPos + lblAddMember.frame.origin.y + 20 + 50) (self.view.frame.width/3) + 55 + 10
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: yPos + heightOFUserView + 30)
       
    }
    
    func createApopUp() {
        
//        bgView = UIView.init(frame: UIScreen.main.bounds)
//        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(MyFamilyViewController.tapOnBackGroundView(_:)))
//        bgView.addGestureRecognizer(tapGesture)
//        self.view.addSubview(bgView)
//        
//        let popUpView = UIView(frame: CGRect(x: 20, y: self.view.center.y ,width: self.view.frame.width-40 ,height: 80))
//        popUpView.layer.cornerRadius = 4
//        popUpView.backgroundColor = UIColor.white
//        bgView .addSubview(popUpView)
//        
//        let btnAddNewMember = BaseUIController().AButtonFrame(CGRect(x: 10, y: 0, width: popUpView.frame.width-20, height: 35 ), withButtonTital: "Add New Member")as! UIButton
//        btnAddNewMember.addTarget(self, action: #selector(MyFamilyViewController.btnAddNewMemberOnClick), for: .touchUpInside)
//        btnAddNewMember.titleLabel?.font = UIFont().mediumFont
//        popUpView.addSubview(btnAddNewMember)
//        
//        let btnChooseFromContacts = BaseUIController().AButtonFrame(CGRect(x: 10, y: 40, width: popUpView.frame.width-20, height: 25 ), withButtonTital: "Choose from Contacts") as! UIButton
//        btnChooseFromContacts.addTarget(self, action: #selector(self.btnChooseFromContactsOnclick), for: .touchUpInside)
//        btnChooseFromContacts.titleLabel!.font = UIFont().mediumFont
//        popUpView.addSubview(btnChooseFromContacts)
        let alertSheet = UIAlertController(title: KADDMEMBER, message: nil, preferredStyle: .actionSheet)
        alertSheet.view.tintColor = KRED_COLOR
        
    
        
        alertSheet.addAction(UIAlertAction(title: KADDNEWMEMBER, style: .default, handler: { (alert: UIAlertAction!) in
            self.btnAddNewMemberOnClick()
        }))
        alertSheet.addAction(UIAlertAction(title: KCHOOSEFROMCONTACTS, style: .default, handler: { (alert: UIAlertAction!) in
            self.btnChooseFromContactsOnclick()
        }))
        alertSheet.addAction(UIAlertAction(title: KCANCEL, style: .cancel, handler: { (alert: UIAlertAction!) in
            alertSheet.dismiss(animated: true, completion: nil)
        }))
        present(alertSheet, animated: true, completion: nil)
    }
    func openInvitePopup() {
        shadowBackGround.removeFromSuperview()
        shadowBackGround = UIView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height))
        shadowBackGround.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(shadowBackGround)
        // create A tableView
        let bgView = UIView(frame:CGRect(x: 10, y: ((UIScreen.main.bounds.height/2)-(60)),width: (UIScreen.main.bounds.width-20), height: 120))
        bgView.backgroundColor = UIColor.white
        bgView.layer.cornerRadius = 4.0
        shadowBackGround.addSubview(bgView)
        
        inviteTableView = UITableView(frame:CGRect(x: 0, y: 0,width: bgView.bounds.width, height: 90))
        inviteTableView.delegate      =   self
        inviteTableView.dataSource    =   self
        inviteTableView.separatorStyle = .none
        // inviteTableView.scrollEnabled = false
        inviteTableView.layer.cornerRadius = 4.0
        inviteTableView.tag = 501
        inviteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        inviteTableView.backgroundColor = UIColor.clear
        bgView.addSubview(inviteTableView)
        // if getting more then 3 member then increaase height of view
        if arrExistingUser.count >= 3 {
            bgView.frame = CGRect(x: 10, y: ((UIScreen.main.bounds.height/2)-(90)), width: (UIScreen.main.bounds.width-20), height: 180)
            inviteTableView.frame = CGRect(x: 0, y: 0, width: bgView.bounds.width, height: 150)
            
        }
        let btnSkip = BaseUIController().AButtonFrame(CGRect(x:bgView.frame.width - 60  , y:bgView.frame.height - 30 ,width:60  ,height: 25 ), withButtonTital: "Skip")as! UIButton
        btnSkip.titleLabel?.font = UIFont().mediumFont
        btnSkip.addTarget(self, action: #selector(self.btnSkipOnClick), for: .touchUpInside)
        bgView.addSubview(btnSkip)
        // add Tapgestue  on shadowBackGround
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnShadowBG(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        shadowBackGround.addGestureRecognizer(tapped)
    }
    func openRelationPopup() {
        shadowBackGround.removeFromSuperview()
        shadowBackGround = UIView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height))
        shadowBackGround.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(shadowBackGround)
//        // create A tableView
//        tableView = UITableView(frame:CGRect(x: 10, y: ((UIScreen.main.bounds.height/2)-(120)),width: (UIScreen.main.bounds.width-20), height: 240))
//        tableView.delegate      =   self
//        tableView.dataSource    =   self
//        tableView.separatorStyle = .none
//        tableView.isScrollEnabled = false
//        tableView.layer.cornerRadius = 4.0
//        tableView.tag = 501
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        tableView.backgroundColor = UIColor.clear
//        shadowBackGround.addSubview(self.tableView)
        // add Tapgestue  on shadowBackGround
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnShadowBG(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        shadowBackGround.addGestureRecognizer(tapped)
        
        relationPickerView = UIPickerView(frame: CGRect(x: 0 , y: self.view.frame.height - 216 , width: self.view.frame.width, height: 216 ))
        relationPickerView.showsSelectionIndicator = true
        relationPickerView.selectRow(0, inComponent: 0, animated: true)
        //relationPickerView.selectRow(timeIndex, inComponent: 1, animated: true)
        relationPickerView.dataSource = self
        relationPickerView.backgroundColor = UIColor(red: 210.0/255.0, green: 213.0/255.0, blue: 219.0/255.0, alpha: 1)
        relationPickerView.delegate = self
        shadowBackGround.addSubview(relationPickerView)
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.height - 256, width: self.view.frame.width, height: 40))
        toolBar.barStyle = UIBarStyle.default
        toolBar.tintColor = UIColor.red
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.toolBarDoneOnClick))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.toolBarCancelOnClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        shadowBackGround.addSubview(toolBar)

    }
    
    func toolBarDoneOnClick(){
         self.UpdateMyFamilyRelation(relation)
        shadowBackGround.removeFromSuperview()
        
    }
    func toolBarCancelOnClick(){
        shadowBackGround.removeFromSuperview()
    }

    
    func openOTPView() {
        shadowBackGround = UIView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height))
        shadowBackGround.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(shadowBackGround)
        // create a base view 
        let bgView = UIView(frame:CGRect(x: 10, y: ((UIScreen.main.bounds.height/2)-(75)),width: (UIScreen.main.bounds.width-20), height: 160))
        bgView.backgroundColor = UIColor.white
        bgView.layer.cornerRadius = 4.0
        shadowBackGround.addSubview(bgView)
        //create lable
        let lblMassage = BaseUIController().ALabelFrame(CGRect(x: 20, y: 5,width: bgView.frame.width - 40, height: 55), withString: "Please enter the OTP(One Time Password) sent to your family member's mobile number.")as! UILabel
        lblMassage.font = UIFont().mediumFont
        bgView.addSubview(lblMassage)
        txtOtp = BaseUIController().ATextFiedlFrame(CGRect(x: 20, y: 70, width: bgView.frame.width - 40, height: 40), withPlaceHolder: "Ennter OTP")as! UITextField
        txtOtp.isSecureTextEntry = true
        txtOtp.backgroundColor = UIColor.white
        txtOtp.borderStyle = .bezel
        txtOtp.keyboardType = .numberPad
        addToolBar(txtOtp)
        bgView.addSubview(txtOtp)
        
        let btnResendOTP = BaseUIController().AButtonFrame(CGRect(x:20  , y:bgView.frame.height - 40 ,width:(bgView.frame.width - 60)/2  ,height: 35 ), withButtonTital: "RESEND OTP")as! UIButton
        btnResendOTP.titleLabel?.font = UIFont().regularMediumFont
        btnResendOTP.setTitleColor(UIColor.white, for: UIControlState())
        btnResendOTP.backgroundColor = KRED_COLOR
        btnResendOTP.addTarget(self, action: #selector(self.btnResendOTPOnClick), for: .touchUpInside)
        bgView.addSubview(btnResendOTP)
        
        let btnSubmitOTP = BaseUIController().AButtonFrame(CGRect(x:btnResendOTP.frame.origin.x + btnResendOTP.frame.width + 20  , y:bgView.frame.height - 40 ,width:(bgView.frame.width - 60)/2  ,height: 35 ), withButtonTital: "SUBMIT OTP")as! UIButton
        btnSubmitOTP.titleLabel?.font = UIFont().regularMediumFont
        btnSubmitOTP.setTitleColor(UIColor.white, for: UIControlState())
        btnSubmitOTP.backgroundColor = KRED_COLOR
        btnSubmitOTP.addTarget(self, action: #selector(self.btnSubmitOTPOnClick), for: .touchUpInside)
        bgView.addSubview(btnSubmitOTP)
        // add Tapgestue  on shadowBackGround
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnShadowBG(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        shadowBackGround.addGestureRecognizer(tapped)
    }
    
    //MARK: PickerViewDelegate
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return arrRelationCategory.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return arrRelationCategory[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
//        txtRelation.text = arrRelationCategory[row]
        
        if selectedMemberId == "" {
            relation = arrRelationCategory[row]
            self.showAlertController("add")
        }else{
            relation = arrRelationCategory[row]
            //self.UpdateMyFamilyRelation(relation)
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        pickerLabel.text = arrRelationCategory[row]
        pickerLabel.font = KROBOTO_Regular_17
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 40;
        
    }

   
    //MARK: - TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
            return arrExistingUser.count
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.textLabel!.font = UIFont().mediumFont
        
        cell.textLabel?.textColor = UIColor (red: (55.0/255.0), green: (54/255.0), blue: (54.0/255.0), alpha: 1)
        if tableView == inviteTableView {
            cell.textLabel?.text = (arrExistingUser[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "name")as? String
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
            dictContactDetails.removeObject(forKey: "fullName")
            dictContactDetails.setValue((arrExistingUser[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "name")as? String, forKey: "fullName")
            shadowBackGround.removeFromSuperview()
            //DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                // do your background code here
                DispatchQueue.main.sync(execute: {
                   self.shadowBackGround.removeFromSuperview()
                   self.openRelationPopup()
                });
            }
      
        shadowBackGround.isHidden = true
        shadowBackGround.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 30;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  30;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        headerView.backgroundColor = UIColor.white
        let lblSelectRelation = BaseUIController().ALabelFrame(CGRect(x: 10 ,y:5 ,width: tableView.frame.width , height: 20), withString: "Invite Existing Member.") as! UILabel
        lblSelectRelation.font = UIFont().largeFont
        headerView.addSubview(lblSelectRelation)
        return headerView
    }

    
    // MARK: - DataBaseOperation
    func insertMyFamilyData(_ arrFamilyData : NSArray)  {
        
        // insetData in MyFamily table
        if arrFamilyData.count != 0 {
            for var i in (0..<arrFamilyData.count) {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let database = appDelegate.openDataBase()
                do {
                    let member_id = (arrFamilyData[i] as AnyObject).value(forKey: "memberid")as! String
                    let MemberName = (arrFamilyData[i] as AnyObject).value(forKey: "name")as! String
                    let relation = (arrFamilyData[i] as AnyObject).value(forKey: "relation")as! String
                    let memberPhoto = (arrFamilyData[i] as AnyObject).value(forKey: "photo")as! String
                    let active = (arrFamilyData[i] as AnyObject).value(forKey: "active")as! String
                    let dob = (arrFamilyData[i] as AnyObject).value(forKey: "ca_dob")as! String
                    let email = (arrFamilyData[i] as AnyObject).value(forKey: "ca_email")as! String
                    let mobileNo = (arrFamilyData[i] as AnyObject).value(forKey: "ca_mob")as! String
                    let gender = (arrFamilyData[i] as AnyObject).value(forKey: "ca_gender")as! String
                    let verified = (arrFamilyData[i] as AnyObject).value(forKey: "verified")as! String
                    
//                    let defaults = NSUserDefaults.standardUserDefaults()
//                    let customerId = defaults.valueForKey("loginCustomerId")as! String
//                    if member_id == customerId {
//                        let defaults = NSUserDefaults.standardUserDefaults()
//                        defaults.setValue(memberPhoto, forKey: "photo")
//                    }
                    try database.executeUpdate("insert into MyFamily (MemberId , MemberName , Relation , MemberPhoto ,MemberEmail,MemberGender,MemberMobileNo, MemberDOB,SyncStatus,Verified,Active) values (?,?,?,?,?,?,?,?,?,?,?)", values: [member_id , MemberName , relation,memberPhoto,email,gender,mobileNo,dob,"Y",verified,active])
                    i += 1
                    
                } catch let error as NSError {
                    print("failed: \(error.localizedDescription)")
                }
                database.close()
            }
           
        }
    }
    
    func loadMyFamilyData()  {
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
                familyMemberObj.memberMobileNo = rs.string(forColumn: "MemberMobileNo")
                familyMemberObj.memberVerefyStatus = rs.string(forColumn: "Verified")
                familyMemberObj.memberActiveStatus = rs.string(forColumn: "Active")
                arrMyFamilyRecord?.add(familyMemberObj)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()

       }
    
    func updateRecordDetailsData()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        do {
            try database.executeUpdate(String(format:"update recordDetails set Memberid = '%@' where Memberid = '%@' ",toMemberId,fromMemberId), values: nil)
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
    func deleteMargeMemmberRecord()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        do {
            try database.executeUpdate(String(format:"delete from Myfamily  where Memberid = '%@' ",fromMemberId), values: nil)
            
        }
        catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
    
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
    // add new member in data base
    func addNewMemberInDataBase(_ m_id : String)  {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        do {
            
            var base64StringImage = ""
            if dictContactDetails.value(forKey: "profileImage")as? Data != nil {
                let imageData = dictContactDetails.value(forKey: "profileImage")as? Data
                base64StringImage = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            }
            let MemberName = (dictContactDetails.value(forKey: "fullName")as! String)
            let active = ""
            let dob = ""
            let email = dictContactDetails.value(forKey: "email")as! String
            let mobileNo = dictContactDetails.value(forKey: "phoneNumber")as! String
            let gender = ""
            try database.executeUpdate("insert into MyFamily (MemberId , MemberName , Relation , MemberPhoto ,MemberEmail,MemberGender,MemberMobileNo, MemberDOB,SyncStatus,Verified,Active) values (?,?,?,?,?,?,?,?,?,?,?)", values: [m_id , MemberName , relation,base64StringImage,email,gender,mobileNo,dob,"Y","0",active])
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }
    
    func UpdateMyFamilyAfterVerify(_ member_Id : String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        do {
            try database.executeUpdate(String(format:"update MyFamily set Verified = '%@', SyncStatus = 'N'  where MemberId = '%@'","1",member_Id), values: nil)
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
       // HomeViewController().getNonSyncDataFromMyFamilyTable()
        SyncMyFamilyData.shareMyFamilyData.getNonSyncDataFromMyFamilyTable()
        
    }
    func UpdateMyFamilyRelation(_ relation : String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        do {
            try database.executeUpdate(String(format:"update MyFamily set Relation = '%@' , SyncStatus = 'N'  where MemberId = '%@'",relation,selectedMemberId), values: nil)
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        // Refresh after uploading
        selectedMemberId = ""
        self.loadMyFamilyData()
        for v1 in self.view.subviews{
            v1.removeFromSuperview()
        }
        self.createALayout()
       // HomeViewController().getNonSyncDataFromMyFamilyTable()
        SyncMyFamilyData.shareMyFamilyData.getNonSyncDataFromMyFamilyTable()
    }
    func deleteAllMyFamilyData()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        do {
            try database.executeUpdate("delete from MyFamily", values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }


    //MARK: AddGestureEvent
    
    func longPressOnView(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        btnDelete.isHidden = false
        let clickedTag = longPressGestureRecognizer.view?.tag
        isInterSects = false
        for i  in 0..<total {
            
            if clickedTag != 100 + i {
                let dropableView = scrollView.viewWithTag(100 + i)
                let dropableImageView = dropableView?.viewWithTag(200 + i)
                dropableImageView!.layer.borderWidth = 1
                dropableImageView!.layer.masksToBounds = false
                dropableImageView!.clipsToBounds = true
                dropableImageView!.layer.borderColor = KRED_COLOR.cgColor
            }
        }
        let longPressView = scrollView.viewWithTag(clickedTag! )
//        // create an NSData object from myView
//        let archive = NSKeyedArchiver.archivedDataWithRootObject(longPressView!)
//        
//        // create a clone by unarchiving the NSData
//       // let myViewCopy = NSKeyedUnarchiver.unarchiveObjectWithData(archive) as! UIView
//        
//        let CopyOfLongPressView = NSKeyedUnarchiver.unarchiveObjectWithData(archive) as! UIView
        longPressView!.layer.zPosition = CGFloat.greatestFiniteMagnitude
        
        switch longPressGestureRecognizer.state {
        case .began:
            initialPoint = longPressGestureRecognizer.location(in: scrollView)
        case .changed:
            let point = longPressGestureRecognizer.location(in: scrollView)
            longPressView!.center = point
            print(point)
            if point.y - initialPoint.y > 0{
                print("down")
                scrollView.scrollRectToVisible(CGRect(x: 0, y: point.y + 100 , width: scrollView.frame.width, height: scrollView.frame.height), animated: true)
            }else{
                print("up")
                scrollView.scrollRectToVisible(CGRect(x: 0, y: point.y - 100 , width: scrollView.frame.width, height: scrollView.frame.height), animated: true)
            }
            initialPoint = point
            
            
//            selection poit    long prresss
//            vsisble ares = scrll.bounds.origi.y + self.v.f.s.h
//            sel > sisble ares ||  sel< scrll.bounds.origi.y
//            let scrollHeight = scrollView.bounds.height//self.view.frame.size.height - scrollView.frame.origin.y//scrollView.bounds.origin.y//self.view.frame.size.height //self.view.frame.size.height - scrollView.frame.origin.y
//
////            let bounds = scrollView.bounds.origin.y + scrollHeight
////            let visibleArea = self.view.frame.height -  lblAddMember.frame.//scrollView.bounds.origin.y
//            print("\(scrollHeight) and \(point.y)\n")
//            print(point.y)
//            if point.y > scrollHeight {
//                scrollView.scrollRectToVisible(CGRect(x: 0, y: point.y - 200 , width: scrollView.frame.width, height: scrollView.frame.height), animated: true)
//                // print("********************uppppp************************")
//                // lblAddMember.frame.origin.y + 20 + 10
//          //      scrollView.frame = CGRect(x: 0 , y: lblAddMember.frame.origin.y + 20 + 10 , width : scrollView.frame.width ,height : scrollView.frame.height)
//            }else if (point.y < scrollHeight){
//                 scrollView.scrollRectToVisible(CGRect(x: 0, y: point.y + 200 , width: scrollView.frame.width, height: scrollView.frame.height), animated: true)
//                //print("********************down************************")
////                scrollView.scroll
//            
//            }
        case .ended:
            
            for i  in 0..<total {
                var familyMemberObj = MyFamilyInfo()
                familyMemberObj = arrMyFamilyRecord![i] as! MyFamilyInfo
                let allViews = arrUserView.object(at: i)
                if (((allViews as AnyObject).frame).contains((longPressView?.center)!) &&  clickedTag != 100 + i)  //&&  taggg != 100 + i
                    
                {
                    toMemberId = familyMemberObj.memberId
                    toMemberName = familyMemberObj.memberName
                    familyMemberObj = MyFamilyInfo()
                    familyMemberObj = arrMyFamilyRecord![clickedTag! - 100] as! MyFamilyInfo
                    fromMemberId = familyMemberObj.memberId
                    fromMemberName = familyMemberObj.memberName
                    isInterSects = true
                    self.showAlertController("marge")
                    for v1 in view.subviews{
                        v1.removeFromSuperview()
                    }
                    self.createALayout()
                    break
                }
            }
            if (CGRect(x: self.view.frame.width - 60, y: -100, width: 100, height: 100).contains((longPressView?.center)!))
            {
                var familyMemberObj = MyFamilyInfo()
                familyMemberObj = arrMyFamilyRecord![clickedTag! - 100] as! MyFamilyInfo
                fromMemberId = familyMemberObj.memberId
                fromMemberName = familyMemberObj.memberName
                self.showAlertController("delete")
            }
            
            if isInterSects == false {
                for v1 in view.subviews{
                    v1.removeFromSuperview()
                }
                self.createALayout()
            }
            
        default:
            break
        }
    }
    
    func tapOnBackGroundView(_ gesture : UITapGestureRecognizer)  {
        
        bgView.removeFromSuperview()
    }
    func tappedOnShadowBG(_ sender: UITapGestureRecognizer)  {
        
        
        shadowBackGround.isHidden = true
        shadowBackGround.removeFromSuperview()
    }
    
    func tapOnUserView(_ gesture : UITapGestureRecognizer)  {

        let indexPath = gesture.view?.tag
        var familymemberObject = MyFamilyInfo()
        familymemberObject = arrMyFamilyRecord![indexPath! - 200] as! MyFamilyInfo
        
        
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
        homeTapSwipeVC.identifires = "MY RECORDS"
        homeTapSwipeVC.selectedMemberId = familymemberObject.memberId
        self.navigationController?.pushViewController(homeTapSwipeVC, animated: true)
       // navController = UINavigationController(rootViewController:homeTapSwipeVC)
   
    }
    
    
    func tapOnUserName(_ gesture : UITapGestureRecognizer)  {
        
        let indexPath = gesture.view?.tag
        var familymemberObject = MyFamilyInfo()
        familymemberObject = arrMyFamilyRecord![indexPath! - 200] as! MyFamilyInfo
        let myFamilyMemberInfo = MyFamilyMemberInfoViewController()
        myFamilyMemberInfo.familyMemberDetails = familymemberObject
        self.navigationController?.pushViewController(myFamilyMemberInfo, animated: true)
        
    }
    
    func tapOnVerify(_ gesture : UITapGestureRecognizer)  {
        let indexPath = gesture.view?.tag
        let label = self.view.viewWithTag(indexPath!)as! UILabel
        if (label.text != "Verify") {
            var familymemberObject = MyFamilyInfo()
            familymemberObject = arrMyFamilyRecord![indexPath! - 5000] as! MyFamilyInfo
            selectedMemberId = familymemberObject.memberId
            print(selectedMemberId)
            self.openOTPView()
        }
        
        
    }
    
    func tapOnRelation(_ gesture : UITapGestureRecognizer)  {
        print(gesture.view?.tag)
        let indexPath = gesture.view?.tag
        var familymemberObject = MyFamilyInfo()
        familymemberObject = arrMyFamilyRecord![indexPath! - 4000] as! MyFamilyInfo
        selectedMemberId = familymemberObject.memberId
        self.openRelationPopup()
    }


    //MARK: ShowAlertView
    func showAlertController(_ alertFor : String)  {
        // Create the alert controller
        var messages = ""
        if alertFor == "delete" {
            messages = (String(format: "Are you sure you want to remove %@ account from your family?",fromMemberName))
        }else if(alertFor == "add"){
            let fullName = dictContactDetails.value(forKey: "fullName")as? String
            let mobileNo = dictContactDetails.value(forKey: "phoneNumber")as? String
            messages = (String(format: "Add %@ (%@) as %@ ",fullName! ,mobileNo! ,relation))
        }else{
            messages = (String(format: "Are you sure you want to merge %@ account with %@ account?",fromMemberName ,toMemberName))
        }
        
        let alertController = UIAlertController(title: "Attention", message: messages, preferredStyle: .alert)
        // Create the actions
        var okAction = UIAlertAction()
        if alertFor == "delete" {
            okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
                NSLog("OK Pressed")
                self.deleteMemberFromAccount()
            }
        }else if(alertFor == "add"){
            okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.addNewMember()
            }
        }
        else{
             okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
                NSLog("OK Pressed")
                self.mergeAccount()
            }
        }
       
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    //MARK: - callWebService
    func getMyFamilyFromWebservice()  {
        if Reachability.isConnectedToNetwork() == true {
             activityIndicator?.start()
            let defaults = UserDefaults.standard
            let memberId = defaults.value(forKey: "loginCustomerId")as! String
            let allParameters = ["customerId":memberId]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetMyFamilyResult" , methodname: "GetMyFamily", className: self)
        }
    }

    
    func mergeAccount()  {
        
        // add activity on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        print(Reachability.isConnectedToNetwork())
        
        if Reachability.isConnectedToNetwork() == true {
            
            activityIndicator?.start()
            print(fromMemberId)
            print(toMemberId)
           
            let customerid = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let fromId = fromMemberId
            let toId = toMemberId

            let allParameters = ["customerId":customerid, "fromId":fromId , "toId":toId]
            
            ServerConnectivity().callWebservice(allParameters, resulttagname: "MergeAccountResult" ,methodname: "MergeAccount", className: self)
            
        }else{
           self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    func deleteMemberFromAccount()  {
        // add activity on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        
        print(Reachability.isConnectedToNetwork())
        
        if Reachability.isConnectedToNetwork() == true {
            
            activityIndicator?.start()
            let customerid = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let memberId = fromMemberId //frommemberid equals memberid
            let allParameters = ["customerId":customerid, "memberId":memberId]
            
            ServerConnectivity().callWebservice(allParameters, resulttagname: "DeleteAccountResult" ,methodname: "DeleteAccount", className: self)
            
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
   
    
    func checkExitingMember(_ mobileNo : String)  {
        
        if Reachability.isConnectedToNetwork() == true {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                // do your background code here
                DispatchQueue.main.sync(execute: {
                    self.shadowBackGround = UIView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height:self.view.frame.height))
                    self.shadowBackGround.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    self.view.addSubview(self.shadowBackGround)
                    self.progressView = MBProgressHUD.showAdded(to: self.shadowBackGround, animated: true)
                    self.progressView.show(animated: true)
                    self.progressView.mode = MBProgressHUDMode.indeterminate
                    self.progressView.label.text = "Check Eisting Memeber"
                    self.progressView.label.font = UIFont().regularMediumFont
                });
            });
            
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let allParameters = ["mobile":mobileNo, "customerId":customerId]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "CheckForExistingMembersResult" ,methodname: "CheckForExistingMembers", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    func addNewMember()  {
        // add activity on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            //get image data in base64 string
            var base64StringImage = ""
            if dictContactDetails.value(forKey: "profileImage")as? Data != nil {
                let imageData = dictContactDetails.value(forKey: "profileImage")as? Data
                base64StringImage = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            }
            let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            let fullName = ((dictContactDetails.value(forKey: "fullName")as! String))
            let dob = ("")
            let mobileNo = (dictContactDetails.value(forKey: "phoneNumber")as! String)
            let email = (dictContactDetails.value(forKey: "email")as! String)
            let gender = ("")
            let relation = (self.relation)
            let photo = (base64StringImage)
            let allParameters = ["customerId":customerId , "fullName" : fullName ,"dob": dob ,"mobileNo": mobileNo ,"email":email , "gender":gender ,"relation": relation ,"photo": photo]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "AddNewMemberResult" ,methodname: "AddNewMember", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    func resendOpt()  {
        // add activity on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            var memberId = ""
            let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            if selectedMemberId == "" {
                 memberId = (newAddedMemberId)
            }else{
                 memberId = (selectedMemberId)
            }
           
            let allParameters = ["customerId":customerId , "memberId" : memberId]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "ResendMemberOtpResult" ,methodname: "ResendMemberOtp", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }

    }
    func submitOtp()  {
        // add activity on view
        print(newAddedMemberId)
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            var memberId = ""
            let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            if selectedMemberId == "" {
                 memberId = (newAddedMemberId)
            }else{
                memberId = (selectedMemberId)
            }
            
            let otpMessages = (txtOtp.text!)
            let allParameters = ["customerId":customerId , "memberId" : memberId ,"otp": otpMessages ]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "VerifyOtpForFamilyMemberResult" ,methodname: "VerifyOtpForFamilyMember", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }

    }

    
    func getAllResponse(_ allResponse: AnyObject, methodName: String){
      
      //  print(allResponse)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
              //  self.progressView.hideAnimated(true)
                if (allResponse .isEqual("error")){
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                
                }else{
                if (methodName == "MergeAccount"){
                if  allResponse .isEqual("0") {
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }else if allResponse .isEqual("1"){
                    self.present(BaseUIController().showAlertView("You cann't merge"), animated: true, completion: nil)
                }else{
                    self.present(BaseUIController().showAlertView("You family merged successfully!"), animated: true, completion: nil)
                    
                    self.updateRecordDetailsData()
                    self.deleteMargeMemmberRecord()
                    self.loadMyFamilyData()
                    for v1 in self.view.subviews{
                        v1.removeFromSuperview()
                    }
                    self.createALayout()
                }
                }else if(methodName == "CheckForExistingMembers"){
                    if  allResponse is String {
                        self.openRelationPopup()
                    }else{
                        self.shadowBackGround.removeFromSuperview()
                        self.arrExistingUser = NSMutableArray()
                        self.arrExistingUser = allResponse as! NSMutableArray
                        self.openInvitePopup()
                    }
                }else if methodName == "AddNewMember"{
                    let resultString = allResponse as! String
                    
                    if  resultString == "0"{
                        
                    }else{
                        self.newAddedMemberId = allResponse as! String
                        self.addNewMemberInDataBase(self.newAddedMemberId)
                        self.loadMyFamilyData()
                        for v1 in self.view.subviews{
                            v1.removeFromSuperview()
                        }
                        self.createALayout()
                        self.openOTPView()
                    }
                }else if(methodName == "VerifyOtpForFamilyMember"){
                   // self.selectedMemberId = ""
                    if  allResponse .isEqual("0"){
                        
                       self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    }else{
                        // update myfamily DB
                        if(self.newAddedMemberId == ""){
                            self.UpdateMyFamilyAfterVerify(self.selectedMemberId)
                        }else{
                            self.UpdateMyFamilyAfterVerify(self.newAddedMemberId)
                        }
                        
                         // Refresh after uploading 
                        self.loadMyFamilyData()
                        for v1 in self.view.subviews{
                            v1.removeFromSuperview()
                        }
                        self.createALayout()
                    }
                    
                }else if(methodName == "ResendMemberOtp"){
                    self.selectedMemberId = ""
                    if  allResponse .isEqual("0"){
                        self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    }else{
                        
                    }
                }
                else if (methodName == "DeleteAccount"){
                    if  allResponse .isEqual("0") {
                        self.present(BaseUIController().showAlertView("The selected account can't be deleted,Please contact customer support"), animated: true, completion: nil)
                    }else if allResponse .isEqual("1"){
                        // after delete
                        self.deleteMargeMemmberRecord()
                        self.loadMyFamilyData()
                        for v1 in self.view.subviews{
                            v1.removeFromSuperview()
                        }
                        self.createALayout()
                    }else{
                        self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    }
                    
                }else if(methodName == "GetMyFamily"){
                    if ([allResponse].count != 0){
                        self.deleteAllMyFamilyData()
                        self.insertMyFamilyData(allResponse as! NSArray)
                        self.loadMyFamilyData()
                        self.createALayout()
                    }else{
                        self.loadMyFamilyData()
                        self.createALayout()
                    }
                }
                }
            });
        });
    }
    //MARK: - GestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view == shadowBackGround ){
            return true
        }
        else{
            return false
        }
    }
    // MARK: ButtonOnClick
    func btnAddNewMemberOnClick()  {
        bgView.removeFromSuperview()
        let myFamilyMemberInfo = MyFamilyMemberInfoViewController()
        myFamilyMemberInfo.familyMemberDetails = MyFamilyInfo() // pass nil object
        self.navigationController?.pushViewController(myFamilyMemberInfo, animated: true)
        
    }
    func btnChooseFromContactsOnclick() {
         bgView.removeFromSuperview()
        self.fetchContacts()
        
    }
    
    func btnAddMemberOnClick(_ sender : UIButton)  {
        self.createApopUp()
        
    }
    func btnHomeBarButtonOnClick(_ button : UIButton)  {
//        self.navigationController?.popViewControllerAnimated(true)
        let homeVC = HomeViewController()
        self.navigationController?.pushViewController(homeVC, animated: true)
        print("btn Home  click")
    }
    func btnCartBarButtounOnClick(_ button : UIButton)  {
        print("btn cart  click")
        if self.getCartMemebrtCount() != 0 {
//            self.navigationController?.navigationBar.isTranslucent = false
            let checkoutVC = CheckOutViewController()
            checkoutVC.isComingFrom = "myfamily"
            self.navigationController?.pushViewController(checkoutVC, animated: true)
        }else{
            self.present(BaseUIController().showAlertView("There are currently no order in your cart."), animated: true, completion: nil)
        }
        
    }
    func btnNotificationBarButtnOnClick(_ button : UIButton)  {
        print("btn notification  click")
        if NotificationsViewController().getNotificationsCount() != 0 {
            let notificationVC = NotificationsViewController()
            self.navigationController?.pushViewController(notificationVC, animated: true)
        }else{
            self.present(BaseUIController().showAlertView("No new notifications"), animated: true, completion: nil)
        }
    }
    func btnSkipOnClick()  {
        shadowBackGround.removeFromSuperview()
        self.openRelationPopup()
    }
    func btnResendOTPOnClick(){
        shadowBackGround.removeFromSuperview()
        self.resendOpt()
        
    }
    func btnSubmitOTPOnClick(){
        shadowBackGround.removeFromSuperview()
        self.submitOtp()
    }
    // MARK: - KeyboardShow&Hide
    func keyboardWillShow(_ notification:Notification){
        
        self.view.frame = CGRect(x: 0, y: -60, width: self.view.frame.width, height: self.view.frame.height)
    }
    
    func keyboardWillHide(_ notification:Notification){
        self.view.frame = CGRect(x: 0, y: 0 , width: self.view.frame.width, height: self.view.frame.height)
        
    }
    //MARK: FetchContesList
    func fetchContacts()
    {
        if #available(iOS 9.0, *) {
//             var contacts: [CNContact] = {
//                let contactStore = CNContactStore()
//                let keysToFetch = [
//                    CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
//                    CNContactEmailAddressesKey,
//                    CNContactPhoneNumbersKey,
//                    CNContactImageDataAvailableKey,
//                    CNContactThumbnailImageDataKey]
//                
//                // Get all the containers
//                var allContainers: [CNContainer] = []
//                do {
//                    allContainers = try contactStore.containersMatchingPredicate(nil)
//                } catch {
//                    print("Error fetching containers")
//                }
//                
//                var results: [CNContact] = []
//                
//                // Iterate all containers and append their contacts to our results array
//                for container in allContainers {
//                    let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
//                    
//                    do {
//                        let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
//                        results.appendContentsOf(containerResults)
//                    } catch {
//                        print("Error fetching results for container")
//                    }
//                }
//                
//                return results
//            }()
            
            
            
            
            let contactPicker = CNContactPickerViewController()
            contactPicker.delegate = self
            contactPicker.displayedPropertyKeys =
                [CNContactPhoneNumbersKey,CNContactEmailAddressesKey ,CNContactImageDataAvailableKey]
            self.present(contactPicker, animated: true, completion: nil)

    }
    }
   
//    optional func contactViewController(viewController: CNContactViewController,shouldPerformDefaultActionFor property: CNContactProperty) -> Bool{
//    
//    }
    
    @available(iOS 9.0, *)
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact){
    print(contact)
        var phone_no = ""
        var email = ""
        var profileImageData = Data()
        var thumbnailImageData = Data()
        
        
        
        
        let fullName = contact.givenName + String(format: " %@",contact.familyName)
        
//        print(contact)
       
        
        if (contact.isKeyAvailable(CNContactPhoneNumbersKey)) {
            for phoneNumber:CNLabeledValue in contact.phoneNumbers {
                let a = phoneNumber.value 
                print("\(a.stringValue)")
                let m_No = a.value(forKey: "digits")as! String
                phone_no = String(m_No.characters.suffix(10))
              
            }
        }
        
        if (contact.isKeyAvailable(CNContactEmailAddressesKey)) {
            for emailId:CNLabeledValue in contact.emailAddresses {
                let a = emailId.value
                print("\(a)")
               email = a as String
            }
        }
        
        if (contact.isKeyAvailable(CNContactImageDataAvailableKey)) {
            let imageData = contact.imageData
            if imageData != nil {
            profileImageData  = contact.imageData!
            }
        }
        if (contact.isKeyAvailable(CNContactThumbnailImageDataKey)) {
            let imageData = contact.imageData
            if imageData != nil {
               thumbnailImageData = imageData!
            }
        }
        print(phone_no)
        dictContactDetails.setValue(fullName, forKey: "fullName")
        dictContactDetails.setValue(phone_no, forKey: "phoneNumber")
        dictContactDetails.setValue(email, forKey: "email")
        dictContactDetails.setValue(profileImageData, forKey: "profileImage")
        dictContactDetails.setValue(thumbnailImageData, forKey: "thumbnailImage")
        self.checkExitingMember(phone_no)
//
//        let myFamilyMemberInfo = MyFamilyMemberInfoViewController()
//        myFamilyMemberInfo.dictContactDetails = dictContactDetails
//        self.navigationController?.pushViewController(myFamilyMemberInfo, animated: true)

    }
//    func getScrollDirection() -> ScrlDirection {
//        if (self.scrollView.last) {
//
//         }
//    }
    
    
}


    


    


