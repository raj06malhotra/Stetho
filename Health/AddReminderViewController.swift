//
//  AddReminderViewController.swift
//  Health
//
//  Created by HW-Anil on 8/20/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class AddReminderViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UIGestureRecognizerDelegate ,UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    //MARK: VariableDeclaration
    var lblCount = UILabel()
    var lblMemberName = UILabel()
    var lblDurationTime = UILabel()
    var txtMedicine = UITextField()
    var memberListTableView = UITableView()
    var bgView = UIView()
    var arrMyFamilyList = NSMutableArray()
    var startDate  = ""
    var endDate = ""
    var myReminderObj = MyReminderInfo()
    var memberId = Int() //Int(NSUserDefaults.standardUserDefaults().valueForKey("loginCustomerId")as! String)
    var memberName = "" //NSUserDefaults.standardUserDefaults().valueForKey("userName")as! String
    let textColor = UIColor.init(red: (108.0/255.0), green: (108.0/255.0), blue: (108.0/255.0), alpha: 1)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let arrDaysInMonth = ["1 Day","2 Days", "3 Days" , "5 Days", "1 Week" ,"10 Days", "2 Weeks" ,"3 Weeks" , "1 Month", "2 Months" , "3 Months" ,"6 Months"]
    let arrDays = ["1","2", "3" , "5", "7" ,"10", "14" ,"21" , "30", "60" , "90" ,"180"]
    var slider = UISlider()
    var arrMyReminderList = NSMutableArray()
    var imagePicker = UIImagePickerController()
    var btnSelectImage = UIButton()
    var base64StringImage = ""
    var reminderImageView = UIImageView()

    
    
    //MARK: ViewLifeCycleMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        if myReminderObj.r_ReminderId != "" {
            memberId = Int(myReminderObj.r_MemberId)!
            memberName = myReminderObj.r_MemberName
        }else{
            memberId = Int(UserDefaults.standard.value(forKey: "loginCustomerId")as! String)!
            memberName = UserDefaults.standard.value(forKey: "userName")as! String
        
        }
        
        self.createALayout()
        self.navigationController?.navigationBar.tintColor = UIColor.red
        self.title = "ADD REMINDER"
        
        // add barbutton on navigation bar 
        let barButtonSave = UIBarButtonItem(title:"  SAVE  " ,style: .done,target: self,action:#selector(AddReminderViewController.barButtonSaveClick(_:)) )
        self.navigationItem.rightBarButtonItem = barButtonSave
        self.navigationItem.hidesBackButton = true
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;
        //check its new reminder or old
        self.populatePreviouseRecord()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if appDelegate.isReminderValueChange == true {
            let lblMorningTime = self.view.viewWithTag(401)as! UILabel
            let lblAfternoonTime = self.view.viewWithTag(402)as! UILabel
            let lblEveningTime = self.view.viewWithTag(403)as! UILabel
            lblMorningTime.text = appDelegate.morningAlarmTime
            lblAfternoonTime.text = appDelegate.afternoonAlarmTime
            lblEveningTime.text = appDelegate.eveningAlarmTime
            appDelegate.isReminderValueChange = false
            
        }
        
        // call google analytics for screen tracking
        
        appDelegate.trackViewOnGoogleAnalytics("AddReminder Screen")
    }
    override func viewWillDisappear(_ animated: Bool) {
        appDelegate.morningAlarmTime = "08:00 AM"
        appDelegate.afternoonAlarmTime = "02:00 PM"
        appDelegate.eveningAlarmTime = "08:00 PM"
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: LayoutDesign
    func createALayout()  {
        
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.view.addSubview(scrollView)
        var xPos: CGFloat = 10
        var yPos: CGFloat = 10
        let  width = self.view.frame.width - 20
        let lblMedicineName = BaseUIController().ALabelFrame(CGRect(x: xPos, y: yPos, width: width, height: 20), withString: "MEDICINE / REMINDER NAME")as! UILabel
        lblMedicineName.textColor = textColor
        scrollView.addSubview(lblMedicineName)
        yPos += 20 + 5
        txtMedicine = BaseUIController().ATextFiedlFrame(CGRect(x: xPos, y: yPos, width: width, height: 40), withPlaceHolder: "Enter Medicine Name")as! UITextField
        txtMedicine.borderStyle = .roundedRect
        txtMedicine.delegate = self
        txtMedicine.textAlignment = .left
       // txtMedicine.backgroundColor = UIColor (red: (230.0/255.0), green: (231.0/255.0), blue: (232.0/255.0), alpha: 1)
        scrollView.addSubview(txtMedicine)
        yPos +=  40 + 10
        let lblLine_1 = BaseUIController().ALabelFrame(CGRect(x: xPos, y: yPos, width: width, height: 0.5), withString: "")as! UILabel
        lblLine_1.backgroundColor = textColor
        scrollView.addSubview(lblLine_1)
        
        yPos += 5
        let lblImage = BaseUIController().ALabelFrame(CGRect(x: xPos, y: yPos, width: width, height: 20), withString: "IMAGE")as! UILabel
        lblImage.textColor = textColor
        scrollView.addSubview(lblImage)
        
        yPos += 20 + 10
        btnSelectImage = BaseUIController().AButtonFrame(CGRect(x: xPos, y: yPos, width: width, height: 100), withButtonTital: "")as! UIButton
        btnSelectImage.layer.masksToBounds = true
        btnSelectImage.layer.cornerRadius = 4
        btnSelectImage.contentMode = .scaleAspectFill
        btnSelectImage.contentHorizontalAlignment = .fill;
        btnSelectImage.contentVerticalAlignment = .fill;
        btnSelectImage.addDashedBorder()
        btnSelectImage.addTarget(self, action: #selector(self.btnSelectImageOnClick), for: .touchUpInside)
        scrollView.addSubview(btnSelectImage)
        
        
        reminderImageView = BaseUIController().AImageViewFrame(CGRect( x: width/2 - 20  , y: 30 , width: 40, height: 40), withImageName: "add_reminder_upload_image.png")as! UIImageView
        btnSelectImage.addSubview(reminderImageView)
        
        yPos += 100 + 10
        let lblLine_2 = BaseUIController().ALabelFrame(CGRect(x: xPos, y: yPos, width: width, height: 0.5), withString: "")as! UILabel
        lblLine_2.backgroundColor = textColor
        scrollView.addSubview(lblLine_2)
        yPos += 5
        
        let lblDailyShedule = BaseUIController().ALabelFrame(CGRect(x: xPos, y: yPos, width: width, height: 20), withString: "DAILY SCHEDULE")as! UILabel
        lblDailyShedule.textColor = textColor
        scrollView.addSubview(lblDailyShedule)
        
        yPos += 20 + 10
        //create Schedul Time
        let scheduleTimeView = UIView.init(frame: CGRect(x: xPos, y: yPos, width: width, height: 100))
        scheduleTimeView.layer.cornerRadius = 2
        scheduleTimeView.layer.borderWidth = 0.5
        scheduleTimeView.layer.borderColor = textColor.cgColor
        scrollView.addSubview(scheduleTimeView)
        let scheduleimageName = ["ic_morning_blank_imageview.png" , "ic_afternoon_blank_imageview.png" , "ic_evening_blank_imageview.png"]
        let scheduleName = ["MORNING" , "AFTERNOON" , "EVENING"]
        let scheduleTime = ["08:00 AM" , "02:00 PM" , "08:00 PM"]
        for i in 0..<3 {
            let  btnSelectMedicineDailySchedule = BaseUIController().AButtonFrame(CGRect(x: xPos - 10 , y: 0, width: width/3 - 2, height: 100), withButtonTital: "")as! UIButton
            btnSelectMedicineDailySchedule.isSelected = false
            btnSelectMedicineDailySchedule.addTarget(self, action: #selector(AddReminderViewController.btnSelectMedicineDailyScheduleOnClick(_:)), for: .touchUpInside)
            scheduleTimeView.addSubview(btnSelectMedicineDailySchedule)
            btnSelectMedicineDailySchedule.tag = 101 + i
            
            if i != 0 {
                let lblLine = BaseUIController().ALabelFrame(CGRect(x: xPos - 11, y: 0, width: 0.5, height: 100), withString: "")as! UILabel
                lblLine.backgroundColor = textColor
                scheduleTimeView.addSubview(lblLine)
                
            }
            let imgView = BaseUIController().AImageViewFrame(CGRect(x: ((width/3)/2 - 20), y: 10, width: 40, height: 40), withImageName: scheduleimageName[i])as! UIImageView
            imgView.tag = 201 + i
            btnSelectMedicineDailySchedule.addSubview(imgView)
            
            let lbl = BaseUIController().ALabelFrame(CGRect(x: 0, y: 50, width: width/3 - 2 , height: 15), withString: scheduleName[i])as! UILabel
            lbl.tag = 301 + i
            lbl.textColor = textColor
            lbl.textAlignment = .center
            btnSelectMedicineDailySchedule.addSubview(lbl)
            let lblTime = BaseUIController().ALabelFrame(CGRect(x: 0, y: 70, width: width/3 - 2 , height: 15), withString:scheduleTime[i])as! UILabel
            lblTime.tag = 401 + i
            lblTime.textColor = textColor
            lblTime.textAlignment = .center
            btnSelectMedicineDailySchedule.addSubview(lblTime)
            xPos += width/3
          
        }
        xPos = 10
        yPos += 100 + 10
        let btnChangeTiming = BaseUIController().AButtonFrame(CGRect(x: xPos, y: yPos, width: width, height: 30), withButtonTital: "Change timing for reminder >")as! UIButton
        btnChangeTiming.addTarget(self, action: #selector(AddReminderViewController.btnChangeTimingForReminder(_:)), for: .touchUpInside)
        btnChangeTiming.setTitleColor(UIColor.red, for: UIControlState())
        btnChangeTiming.titleLabel?.font = UIFont().regularMediumFont
        btnChangeTiming.contentHorizontalAlignment = .left
        scrollView.addSubview(btnChangeTiming)
        yPos += 30 + 5
        let lblLine_3 = BaseUIController().ALabelFrame(CGRect(x: xPos, y: yPos, width: width, height: 0.5), withString: "")as! UILabel
        lblLine_3.backgroundColor = textColor
        scrollView.addSubview(lblLine_3)
        yPos += 10
        let lblDuration = BaseUIController().ALabelFrame(CGRect(x: xPos, y: yPos, width: width, height: 20), withString: "Duration")as! UILabel
        lblDuration.textColor = textColor
        lblDuration.textAlignment = .left
        scrollView.addSubview(lblDuration)
        yPos += 10
        lblDurationTime = BaseUIController().ALabelFrame(CGRect(x: xPos, y: yPos, width: width, height: 20), withString: "5 Days")as! UILabel
        lblDurationTime.textAlignment = .center
        scrollView.addSubview(lblDurationTime)
        yPos += 20 + 5
        slider = UISlider.init(frame: CGRect(x: xPos, y: yPos, width: width, height: 20))
        slider.minimumTrackTintColor = UIColor.red
        slider.maximumValue = 12
        slider.minimumValue = 1
        slider.setValue(5, animated: true)
        slider.addTarget(self, action: #selector(AddReminderViewController.sliderValueChange(_:)), for: .valueChanged)
        scrollView.addSubview(slider)
        yPos += 20 + 20
        let lblLine_4 = BaseUIController().ALabelFrame(CGRect(x: xPos, y: yPos, width: width, height: 0.5), withString: "")as! UILabel
        lblLine_4.backgroundColor = textColor
        scrollView.addSubview(lblLine_4)
        yPos += 2
      /*  let lblQuantity = BaseUIController().ALabelFrame(CGRectMake(xPos, yPos, width - 100, 30), withString: "QUANTITY")as! UILabel
        lblQuantity.textColor = textColor
        scrollView.addSubview(lblQuantity)
        let btnMinus = BaseUIController().AButtonFrame(CGRectMake(width - 80 , yPos, 20, 30), withButtonTital: "-")as! UIButton
        btnMinus.setTitleColor(UIColor.redColor(), forState:.Normal)
        btnMinus.addTarget(self, action:#selector(AddReminderViewController.btnMinusOnClick(_:)), forControlEvents: .TouchUpInside)
        btnMinus.titleLabel?.font = UIFont.systemFontOfSize(12)
        scrollView.addSubview(btnMinus)
        
        lblCount = BaseUIController().ALabelFrame(CGRect(x: width - 60 ,y: 0 ,width: 20 , height : 30), withString: "1")as! UILabel
        lblCount.textAlignment = .Center
        lblCount.font = UIFont.systemFontOfSize(12)
        lblQuantity.addSubview(lblCount)
        
        let btnPlus = BaseUIController().AButtonFrame(CGRectMake(width - 20 , yPos, 20, 30), withButtonTital: "+")as! UIButton
        btnPlus.setTitleColor(UIColor.redColor(), forState: .Normal)
        btnPlus.addTarget(self, action:#selector(AddReminderViewController.btnPlusOnClick(_:)), forControlEvents: .TouchUpInside)
        btnPlus.titleLabel?.font = UIFont.systemFontOfSize(12)
        scrollView.addSubview(btnPlus)
        
        yPos +=  30 + 5
        
        let lblLine_5 = BaseUIController().ALabelFrame(CGRectMake(xPos, yPos, width, 1), withString: "")as! UILabel
        lblLine_5.backgroundColor = textColor
        scrollView.addSubview(lblLine_5) */
        
        let btnSelectMember = BaseUIController().AButtonFrame(CGRect(x: xPos, y: yPos, width: width, height: 30), withButtonTital: "")as! UIButton
        btnSelectMember.addTarget(self, action: #selector(AddReminderViewController.btnSelectMemberOnClick(_:)), for: .touchUpInside)
        scrollView.addSubview(btnSelectMember)
        
        let lblSelectMember = BaseUIController().ALabelFrame(CGRect(x: xPos, y: 0, width: width/2, height: 30), withString: "Select Member")as! UILabel
        lblSelectMember.textColor = UIColor.red
        lblSelectMember.font = UIFont().regularMediumFont
        btnSelectMember.addSubview(lblSelectMember)
        
        lblMemberName = BaseUIController().ALabelFrame(CGRect(x: xPos + width/2, y: 0, width: width/2, height: 30), withString:memberName)as! UILabel
        btnSelectMember.addSubview(lblMemberName)
        
        yPos += 35
        let lblLine_6 = BaseUIController().ALabelFrame(CGRect(x: xPos, y: yPos, width: width, height: 0.5), withString: "")as! UILabel
        lblLine_6.backgroundColor = textColor
        scrollView.addSubview(lblLine_6)
        yPos += 10
        if appDelegate.isOldReminder == true {
            let btnRemoveReminder = BaseUIController().AButtonFrame(CGRect(x: 10, y: yPos, width: self.view.frame.width, height: 30), withButtonTital: "Remove Reminder")as! UIButton
            btnRemoveReminder.setTitleColor(UIColor.red, for: UIControlState())
            btnRemoveReminder.titleLabel?.font = UIFont().regularMediumFont
            btnRemoveReminder.contentHorizontalAlignment = .left
            btnRemoveReminder.addTarget(self, action:#selector(AddReminderViewController.btnRemoveReminderClick(_:)), for: .touchUpInside)
            scrollView.addSubview(btnRemoveReminder)
            //populate all old Value
            txtMedicine.text = myReminderObj.r_MedicineName
            let index =  (arrDays.index(of: myReminderObj.r_Duration)!)
            lblDurationTime.text = arrDaysInMonth[index]
            lblCount.text = myReminderObj.r_Quantity
            lblMemberName.text = myReminderObj.r_MemberName
            
            let imageString = myReminderObj.r_ReminderImage
            let data = Data(base64Encoded: imageString, options: NSData.Base64DecodingOptions(rawValue: 0))
            if imageString != "" {
                btnSelectImage.setImage(UIImage.init(data: data!), for: UIControlState())
               // userImageView.image = UIImage.init(data: data!)
                reminderImageView.image = UIImage(named: "")
            }else{
                //userImageView.image = UIImage(named: "avatar1.png")
            }
        }
        yPos += 50
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: yPos)
    }
    func populatePreviouseRecord()  {
        let lblMorningTime = self.view.viewWithTag(401)as! UILabel
        let lblAfternoonTime = self.view.viewWithTag(402)as! UILabel
        let lblEveningTime = self.view.viewWithTag(403)as! UILabel
        if appDelegate.isOldReminder == true {
            
            if myReminderObj.r_MorningTime != "" {
                let btn = self.view.viewWithTag(101)as! UIButton
                let scheduleImageView = self.view.viewWithTag(201)as! UIImageView
                let lblschedule = self.view.viewWithTag(301)as! UILabel
                let lblTime = self.view.viewWithTag(401)as! UILabel
                
                lblTime.text = self.chageTime24FormateTo12(myReminderObj.r_MorningTime)
                btn.isSelected = true
                scheduleImageView.image = UIImage(named:"ic_morning_red_imageview.png")
                lblschedule.textColor = UIColor.red
                lblTime.textColor = UIColor.red
            }
            if myReminderObj.r_AfternoonTime != "" {
                let btn = self.view.viewWithTag(102)as! UIButton
                let scheduleImageView = self.view.viewWithTag(202)as! UIImageView
                let lblschedule = self.view.viewWithTag(302)as! UILabel
                let lblTime = self.view.viewWithTag(402)as! UILabel
                lblTime.text = self.chageTime24FormateTo12(myReminderObj.r_AfternoonTime)
                btn.isSelected = true
                scheduleImageView.image = UIImage(named:"ic_afternoon_blue_imageview.png")
                lblschedule.textColor = UIColor.blue
                lblTime.textColor = UIColor.blue
            }
            if myReminderObj.r_EveningTime != "" {
                let btn = self.view.viewWithTag(103)as! UIButton
                let scheduleImageView = self.view.viewWithTag(203)as! UIImageView
                let lblschedule = self.view.viewWithTag(303)as! UILabel
                let lblTime = self.view.viewWithTag(403)as! UILabel
                lblTime.text = self.chageTime24FormateTo12(myReminderObj.r_EveningTime)
                btn.isSelected = true
                scheduleImageView.image = UIImage(named:"ic_evening_yellow_imageview.png")
                lblschedule.textColor = UIColor.orange
                lblTime.textColor = UIColor.orange
            }
            let index = Float (arrDays.index(of: myReminderObj.r_Duration)!)
            slider.setValue(index + 1 , animated: true)
        }else{
            lblMorningTime.text = appDelegate.morningAlarmTime
            lblAfternoonTime.text = appDelegate.afternoonAlarmTime
            lblEveningTime.text = appDelegate.eveningAlarmTime
        }
        
        // set bydefault Start and End date 
        let todayDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        startDate = dateFormatter.string(from: todayDate)
        endDate  = dateFormatter.string(from: self.addUnitToDate(.day, number: 5, date: todayDate))
    }
    func showMemberList()  {
        
        // create A tableView
        bgView = UIView(frame:CGRect(x: 0, y: 0,width: self.view.frame.width, height: self.view.frame.height))
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(bgView)
        memberListTableView = UITableView(frame:CGRect(x: 10, y: 74, width: self.view.frame.width - 20 ,height: self.view.frame.height - 84 ))
        memberListTableView.delegate      =   self
        memberListTableView.dataSource    =   self
        memberListTableView.layer.cornerRadius = 4.0
        memberListTableView.tableFooterView = UIView()
        memberListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        memberListTableView.backgroundColor = UIColor.clear
        bgView.addSubview(memberListTableView)
        // add Tapgestue  on shadowBackGround
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddReminderViewController.tappedOnBG(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        bgView.addGestureRecognizer(tapped)
    }
    
    func OpenChangeImagePopUp()   {
        
        let alertSheet = GlobalInfo.sharedInfo.getPhotoSelectionAlertSheet()
        
        alertSheet.addAction(UIAlertAction(title: KTAKEPHOTO, style: .default, handler: { (alert: UIAlertAction!) in
            self.btnTakephotoOnClick()
        }))
        
        alertSheet.addAction(UIAlertAction(title: KPHOTO_GALLERY, style: .default, handler: { (alert: UIAlertAction!) in
            self.btnChooseFromGalleryOnClick()
        }))
    
        alertSheet.addAction(UIAlertAction(title: KCANCEL, style: .cancel, handler: { (alert: UIAlertAction!) in
            alertSheet.dismiss(animated: true, completion: nil)
        }))
        present(alertSheet, animated: true, completion: nil)
    }

    
    // MARK: - TextFiedlDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        return textField.resignFirstResponder()
    }
    //MARK: - ImagePickerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
        let addRecordVC = AddRecordsViewController()
        
        let compresedImage = addRecordVC.resizeImage(image, targetSize: CGSize(width: image.size.width, height: image.size.height))   //DrawerViewController().resizeImage(image, targetSize: CGSizeMake(350.0, 350.0))
       // compresedImage.mediumQualityJPEGNSData
        btnSelectImage.imageView?.contentMode = .scaleAspectFill
        btnSelectImage.setImage(compresedImage, for: UIControlState())
        let imageData = UIImageJPEGRepresentation(compresedImage, 0.5)//UIImagePNGRepresentation(compresedImage)
        let imageSize: Int = imageData!.count
        print(Double(imageSize/1024))
        
        base64StringImage = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        reminderImageView.isHidden = true
    }

    
    //MARK: - TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrMyFamilyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myFamilyMemberObj = arrMyFamilyList[(indexPath as NSIndexPath).row]as! MyFamilyInfo
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        
        let userImageView = BaseUIController().AImageViewFrame(CGRect(x: 10, y: 10, width: 24, height: 24), withImageName: "user_icon.png")as! UIImageView
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        cell.addSubview(userImageView)
        let lbluserName = BaseUIController().ALabelFrame(CGRect( x: 50, y: 10, width: 250, height: 24), withString: "")as! UILabel
        cell.addSubview(lbluserName)
        lbluserName.text = myFamilyMemberObj.memberName
        lbluserName.textColor = UIColor (red: (55.0/255.0), green: (54/255.0), blue: (54.0/255.0), alpha: 1)
        lbluserName.font = UIFont.systemFont(ofSize: 12)
        
        let imageString = myFamilyMemberObj.memberPhoto
        let data = Data(base64Encoded: imageString, options: NSData.Base64DecodingOptions(rawValue: 0))
        if imageString != "" {
            userImageView.image = UIImage.init(data: data!)
        }else{
            userImageView.image = UIImage(named: "avatar1.png")
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let myFamilyMemberObj = arrMyFamilyList[(indexPath as NSIndexPath).row]as! MyFamilyInfo
        lblMemberName.text = myFamilyMemberObj.memberName
        memberId = Int(myFamilyMemberObj.memberId)!
        memberName = myFamilyMemberObj.memberName
        bgView.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 30;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  44;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        headerView.backgroundColor = UIColor.white
        let lblSelectMember = BaseUIController().ALabelFrame(CGRect(x: 10 ,y:5 ,width: tableView.frame.width , height: 20), withString: "Select Member") as! UILabel
        headerView.addSubview(lblSelectMember)
        return headerView
    }
    //MARK: - GestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view == bgView ){
            return true
        }
        else{
            return false
        }
    }
    //MARK: ButtonOnClick
    func btnSelectMedicineDailyScheduleOnClick(_ button : UIButton)  {
        let tag = button.tag
        let scheduleImageView = self.view.viewWithTag(tag + 100)as! UIImageView
        let lblschedule = self.view.viewWithTag(tag + 200)as! UILabel
        let lblTime = self.view.viewWithTag(tag + 300)as! UILabel
        if tag == 101 {
            if button.isSelected == false {
                scheduleImageView.image = UIImage(named: "ic_morning_red_imageview.png")
                lblschedule.textColor = UIColor.red
                lblTime.textColor = UIColor.red
                button.isSelected = true
            }else{
                scheduleImageView.image = UIImage(named: "ic_morning_blank_imageview.png")
                lblschedule.textColor = textColor
                lblTime.textColor = textColor
                button.isSelected = false
            }
        }else if (tag == 102){
            if button.isSelected == false {
                scheduleImageView.image = UIImage(named: "ic_afternoon_blue_imageview.png")
                lblschedule.textColor = UIColor.blue
                lblTime.textColor = UIColor.blue
                button.isSelected = true
            }else{
                scheduleImageView.image = UIImage(named: "ic_afternoon_blank_imageview.png")
                lblschedule.textColor = textColor
                lblTime.textColor = textColor
                button.isSelected = false
            }
            
        }else if (tag == 103) {
            if button.isSelected == false {
                scheduleImageView.image = UIImage(named: "ic_evening_yellow_imageview.png")
                lblschedule.textColor = UIColor.orange
                lblTime.textColor =  UIColor.orange
                button.isSelected = true
                
            }else{
                scheduleImageView.image = UIImage(named: "ic_evening_blank_imageview.png")
                lblschedule.textColor = textColor
                lblTime.textColor = textColor
                button.isSelected = false
            }
        }
    }
    func btnChangeTimingForReminder(_ button : UIButton)  {
        let lblMorningTime = self.view.viewWithTag(401)as! UILabel
        let lblAfternoonTime = self.view.viewWithTag(402)as! UILabel
        let lblEveningTime = self.view.viewWithTag(403)as! UILabel
        
        let setReminderTimeVC = SetReminderTimeViewController()
        setReminderTimeVC.arrSelectedTimeList.append(lblMorningTime.text!)
        setReminderTimeVC.arrSelectedTimeList.append(lblAfternoonTime.text!)
        setReminderTimeVC.arrSelectedTimeList.append(lblEveningTime.text!)
//        appDelegate.isOldReminder = true
        self.navigationController?.pushViewController(setReminderTimeVC, animated: true)
    }
    func btnSelectMemberOnClick(_ button : UIButton)  {
        self.getMyFamilyList()
        self.showMemberList()
    }
//    func btnPlusOnClick(button : UIButton)  {
//        let totalCount = Int(lblCount.text!)
//        if totalCount < 10 {   
//            lblCount.text = String(totalCount! + 1)
//        }
//    }
//    func btnMinusOnClick(button: UIButton)  {
//        let totalCount = Int(lblCount.text!)
//        if totalCount != 1 {
//            lblCount.text = String(totalCount! - 1)
//        }
//    }
    func tappedOnBG(_ gesture : UITapGestureRecognizer)  {
        bgView.removeFromSuperview()
    }
    func btnRemoveReminderClick(_ barButton : UIBarButtonItem)  {
        self.deleteReminder(Int(myReminderObj.r_MemberId)!)
    
    }
    func barButtonBackClick(_ barButton : UIBarButtonItem)  {
        let reminderCount = self.getTotalReminderCount()
        if reminderCount == 0 {
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: HomeViewController.self) {
                    self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                    break
                }
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    func barButtonSaveClick(_ barButton : UIBarButtonItem)  {
        let btnMorning = self.view.viewWithTag(101)as! UIButton
        let btnAfternoon = self.view.viewWithTag(102)as! UIButton
        let btnEvening = self.view.viewWithTag(103)as! UIButton
        
        let lblMorningTime = self.view.viewWithTag(401)as! UILabel
        let lblAfternoonTime = self.view.viewWithTag(402)as! UILabel
        let lblEveningTime = self.view.viewWithTag(403)as! UILabel
        
        
        if txtMedicine.text?.isEmpty == true {
            self.present(BaseUIController().showAlertView("Please Enter Medicine Name!"), animated: true, completion: nil)
        }else if (btnMorning.isSelected != true && btnAfternoon.isSelected != true && btnEvening.isSelected != true){
            self.present(BaseUIController().showAlertView("Please Select Medicine Time Schedule"), animated: true, completion: nil)
        }else{
            if (btnMorning.isSelected == false) {
                appDelegate.morningAlarmTime = "00:00 AM"
            }else{
                appDelegate.morningAlarmTime = (lblMorningTime.text)!
            }
            if (btnAfternoon.isSelected == false){
                appDelegate.afternoonAlarmTime = "00:00 AM"
            }else{
                appDelegate.afternoonAlarmTime = (lblAfternoonTime.text)!
            }
            if (btnEvening.isSelected == false) {
                appDelegate.eveningAlarmTime = "00:00 AM"
            }else{
                appDelegate.eveningAlarmTime = (lblEveningTime.text)!
            }
            if appDelegate.isOldReminder {
                self.updateReminder()
            }else{
                self.saveReminder()
            }
        }
        // schedul alarm   or local notification
        self.getReminderList()
    }

    func btnSelectImageOnClick()  {
//        shadowBackGround.removeFromSuperview()
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
//            
//            imagePicker.delegate = self
//            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
//           // imagePicker.mediaTypes = [kUTTypeImage as String]
//            imagePicker.allowsEditing = false
//            self.presentViewController(imagePicker, animated: true, completion: nil)
//        }
        self.OpenChangeImagePopUp()
    }
    
    func btnTakephotoOnClick()  {
        bgView.removeFromSuperview()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
         //   imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func btnChooseFromGalleryOnClick()  {
        bgView.removeFromSuperview()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    
    //MARK: DataBaseOperation
    
    func getTotalReminderCount()-> Int  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        var  totalReminder = 0
        do {
            let rs = try database.executeQuery("SELECT COUNT(DISTINCT MemberId) FROM Reminder WHERE IsDeleted = 0", values: nil)
            while rs.next() {
                totalReminder = Int(rs.int(forColumn: "COUNT(DISTINCT MemberId)"))
               
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        return totalReminder
    }
      
    
    func getMyFamilyList()  {
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
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }
    func saveReminder()  {
         // change 12 hours to 24 hours
        var morningTime = self.chageTime12formateTo24(appDelegate.morningAlarmTime)
        var afternoonTime = self.chageTime12formateTo24(appDelegate.afternoonAlarmTime)
        var eveningTime = self.chageTime12formateTo24(appDelegate.eveningAlarmTime)
        if morningTime == "00:00" {
            morningTime = ""
        }
        if afternoonTime == "00:00" {
            afternoonTime = ""
        }
        if eveningTime == "00:00" {
            eveningTime = ""
        }
        let duration = arrDays[Int(slider.value) - 1 ]
        
        let database = appDelegate.openDataBase()
        do {
            try database.executeUpdate("insert into Reminder (ReminderId , MemberId , MemberName , MedicineName ,ReminderImage , MorningTime , AfternoonTime , EveningTime , StartDate ,EndDate ,Quantity,Duration ,IsDeleted ,SyncStatus) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)", values: ["0",memberId,memberName ,txtMedicine.text! ,base64StringImage ,morningTime ,afternoonTime , eveningTime, startDate ,endDate , "" , duration ,0 ,0])
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        self.showAlertController()
    }
    func updateReminder()  {
        
        // change 12 hours to 24 hours
//        var morningTime = myReminderObj.r_MorningTime
//        var afternoonTime = myReminderObj.r_AfternoonTime
//        var eveningTime = myReminderObj.r_EveningTime
        
        var morningTime = self.chageTime12formateTo24(appDelegate.morningAlarmTime)
        var afternoonTime = self.chageTime12formateTo24(appDelegate.afternoonAlarmTime)
        var eveningTime = self.chageTime12formateTo24(appDelegate.eveningAlarmTime)
        
        let duration = arrDays[Int(slider.value) - 1 ]
        
       
        
        if morningTime == "00:00" {
            morningTime = ""
        }
        if afternoonTime == "00:00" {
            afternoonTime = ""
        }
        if eveningTime == "00:00" {
            eveningTime = ""
        }
        if base64StringImage == "" {
            base64StringImage = myReminderObj.r_ReminderImage
        }
        let database = appDelegate.openDataBase()
        do {
            try database.executeUpdate(String(format:"update Reminder set ReminderId ='%@', MemberId = %d,MemberName = '%@' , MedicineName = '%@', ReminderImage ='%@', MorningTime = '%@', AfternoonTime = '%@' , EveningTime = '%@', StartDate = '%@' , EndDate = '%@', Quantity = '%@',Duration = '%@', IsDeleted = %d, SyncStatus = %d where _id = %d ",myReminderObj.r_ReminderId,memberId , memberName , txtMedicine.text! , base64StringImage ,morningTime ,afternoonTime ,eveningTime, startDate ,endDate , "" , duration ,0 ,0 ,myReminderObj.r_Id), values: nil)
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
      //  self.showAlertController()
        self.navigationController?.popViewController(animated: true)
    }
    
    func sliderValueChange(_ slider : UISlider)  {
        let sliderValue = Int(round(slider.value))
        lblDurationTime.text = arrDaysInMonth[sliderValue - 1]
        
        let todayDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        startDate = dateFormatter.string(from: todayDate)
        
        switch sliderValue {
        case 1:
            endDate  = dateFormatter.string(from: self.addUnitToDate(.day, number: 1, date: todayDate))
        case 2:
            endDate  = dateFormatter.string(from: self.addUnitToDate(.day, number: 2, date: todayDate))
        case 3:
            endDate  = dateFormatter.string(from: self.addUnitToDate(.day, number: 3, date: todayDate))
        case 4:
            endDate  = dateFormatter.string(from: self.addUnitToDate(.day, number: 5, date: todayDate))
        case 5:
            endDate  = dateFormatter.string(from: self.addUnitToDate(.day, number: 7, date: todayDate))
        case 6:
            endDate  = dateFormatter.string(from: self.addUnitToDate(.day, number: 10, date: todayDate))
        case 7:
            endDate  = dateFormatter.string( from: self.addUnitToDate(.day, number: 14, date: todayDate))
        case 8:
            endDate  = dateFormatter.string(from: self.addUnitToDate(.day, number: 21, date: todayDate))
        case 9:
            endDate  = dateFormatter.string(from: self.addUnitToDate(.month, number: 1, date: todayDate))
        case 10:
            endDate  = dateFormatter.string(from: self.addUnitToDate(.month, number: 2, date: todayDate))
        case 11:
            endDate  = dateFormatter.string(from: self.addUnitToDate(.month, number: 3, date: todayDate))
        case 12:
            endDate  = dateFormatter.string(from: self.addUnitToDate(.month, number: 6, date: todayDate))
            
        default: break
            
        }
        
    }
    func deleteReminder(_ memberId : Int)  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        do {
           // try database.executeUpdate(String(format:"delete from Reminder where _id = %d",myReminderObj.r_Id), values: nil)
            try database.executeUpdate(String(format:"update Reminder set IsDeleted = 1 where _id =%d ", myReminderObj.r_Id), values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
       let reminderCount = self.getTotalReminderCount()
       let  alertController = UIAlertController(title: "Alert", message: "Your reminder delete successfully.", preferredStyle: .alert)
        // Create the actions
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("ok Pressed")
            if (reminderCount != 0)
            {
              self.navigationController?.popViewController(animated: true)
            }else{
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: HomeViewController.self) {
                        self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                        break
                    }
                }
            }
            
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addUnitToDate(_ unitType: NSCalendar.Unit, number: Int, date:Date) -> Date {

        
        return (Calendar.current as NSCalendar).date(
            byAdding: unitType,
            value: number,
            to: date,
            options: NSCalendar.Options(rawValue: 0))!
    }
    func chageTime12formateTo24(_ time : String) -> String {
        let dateAsString = time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let date = dateFormatter.date(from: dateAsString)
        
        dateFormatter.dateFormat = "HH:mm"
        let date24 = dateFormatter.string(from: date!)
        return String(date24)
    }
    
    func chageTime24FormateTo12(_ time : String) -> String {
        let dateAsString = time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.date(from: dateAsString)
        
        dateFormatter.dateFormat = "hh:mm a"
        let date12 = dateFormatter.string(from: date!)
        return String(date12)
    }
    func showAlertController()  {
        
        let reminderCount = self.getTotalReminderCount()
        
        
        var alertController = UIAlertController()
        if appDelegate.isOldReminder {
            alertController = UIAlertController(title: "Alert", message: "Your reminder update successfully!", preferredStyle: .alert)
            // Create the actions
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                UIAlertAction in
                NSLog("ok Pressed")
                self.navigationController?.popViewController(animated: true)
            }
             alertController.addAction(okAction)
        }else{
            alertController = UIAlertController(title: "Alert", message: "Reminder saved. Would you like to add another reminder?", preferredStyle: .alert)
            // Create the actions
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                UIAlertAction in
                NSLog("yes Pressed")
                self.appDelegate.isOldReminder = false
                for v1 in self.view.subviews{
                    v1.removeFromSuperview()
                }
                self.navigationController?.navigationBar.isTranslucent = false
                self.createALayout()
    
            }
            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                if (reminderCount != 0){
                    self.navigationController?.popViewController(animated: true)
                }else{
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: HomeViewController.self) {
                            self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                            break
                        }
                    }
                }
                
            }
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
        }
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func schedulLocalNotification()  {
       
        UIApplication.shared.cancelAllLocalNotifications()
        
      for i in 0..<arrMyReminderList.count {
            var myReminderObj = MyReminderInfo()
            myReminderObj = arrMyReminderList[i] as! MyReminderInfo
            let noOfDay = myReminderObj.r_Duration
            let no : Int = Int(noOfDay)!
       for k in 0..<no {
        let dateFormatter22 = DateFormatter()
        dateFormatter22.dateFormat = "yyyy-MM-dd"
        let startingDate = dateFormatter22.date(from: myReminderObj.r_StartDate)
        
        let dateFormatter11 = DateFormatter()
        dateFormatter11.dateFormat = "yyyy-MM-dd"
        let notificationFireDate  = dateFormatter11.string(from: self.addUnitToDate(.day, number: k, date: startingDate!))
        if myReminderObj.r_MorningTime != "" {
            
            let fireDate = notificationFireDate + String(format:" %@",chageTime24FormateTo12(myReminderObj.r_MorningTime))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
            let date = dateFormatter.date(from: fireDate)
            //Get Current Date/Time
            let currentDateTime = Date()
            
            //Get Reminder Date (which is Due date minus 7 days lets say)
            let reminderDate = date
            
            //Check if reminderDate is Greater than Right now
            if(reminderDate!.isGreaterThanDate(currentDateTime)) {
                //Do Something...
                // Create reminder by setting a local notification
                let localNotification = UILocalNotification() // Creating an instance of the notification.
                if #available(iOS 8.2, *) {
                    localNotification.alertTitle = "REMINDER"
                } else {
                    // Fallback on earlier versions
                }
                localNotification.alertBody = String(format: "Time to take (%@) Medicine",myReminderObj.r_MedicineName)
                localNotification.alertAction = "Morning"
                localNotification.fireDate = date //NSDate().dateByAddingTimeInterval(60*1) // 5 minutes(60 sec * 5) from now
                //        localNotification.repeatInterval = NSCalendarUnit.Day
                localNotification.userInfo = ["alarmTime" : date! , "medicineName" : myReminderObj.r_MedicineName]
                localNotification.timeZone = TimeZone.current
                localNotification.soundName =  "alarmtone.mp3" //UILocalNotificationDefaultSoundName // Use the default notification tone/ specify a file in the application bundle
                //localNotification.applicationIconBadgeNumber = 1 // Badge number to set on the application Icon.
                localNotification.category = "ACTIONABLE" // Category to use the specified actions
                UIApplication.shared.scheduleLocalNotification(localNotification) // Scheduling the notification.
                
            }
            
            
        }
        if myReminderObj.r_AfternoonTime != "" {
            let fireDate = notificationFireDate + String(format:" %@",chageTime24FormateTo12(myReminderObj.r_AfternoonTime))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
            let date = dateFormatter.date(from: fireDate)
            //Get Current Date/Time
            let currentDateTime = Date()
            //Get Reminder Date (which is Due date minus 7 days lets say)
            let reminderDate = date
            //Check if reminderDate is Greater than Right now
            if(reminderDate!.isGreaterThanDate(currentDateTime)) {
            // Create reminder by setting a local notification
            let localNotification = UILocalNotification() // Creating an instance of the notification.
            if #available(iOS 8.2, *) {
                localNotification.alertTitle = "REMINDER"
            } else {
                // Fallback on earlier versions
            }
            localNotification.alertBody = String(format: "Time to take (%@) Medicine",myReminderObj.r_MedicineName)
            localNotification.alertAction = "AfterNoon"
            localNotification.fireDate = date //NSDate().dateByAddingTimeInterval(60*1) // 5 minutes(60 sec * 5) from now
            //        localNotification.repeatInterval = NSCalendarUnit.Day
            localNotification.userInfo = ["alarmTime" : date! , "medicineName" : myReminderObj.r_MedicineName]
            localNotification.timeZone = TimeZone.current
            localNotification.soundName =  "alarmtone.mp3" //UILocalNotificationDefaultSoundName // Use the default notification tone/ specify a file in the application bundle
            //localNotification.applicationIconBadgeNumber = 1 // Badge number to set on the application Icon.
            localNotification.category = "ACTIONABLE" // Category to use the specified actions
            UIApplication.shared.scheduleLocalNotification(localNotification) // Scheduling the notification.
            }
        }
        if myReminderObj.r_EveningTime != "" {
            let fireDate = notificationFireDate + String(format:" %@",chageTime24FormateTo12(myReminderObj.r_EveningTime))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
            let date = dateFormatter.date(from: fireDate)
            //Get Current Date/Time
            let currentDateTime = Date()
            
            //Get Reminder Date (which is Due date minus 7 days lets say)
            let reminderDate = date
            
            //Check if reminderDate is Greater than Right now
            if(reminderDate!.isGreaterThanDate(currentDateTime)) {
            
            // Create reminder by setting a local notification
            let localNotification = UILocalNotification() // Creating an instance of the notification.
            if #available(iOS 8.2, *) {
                localNotification.alertTitle = "REMINDER"
            } else {
                // Fallback on earlier versions
            }
            localNotification.alertBody = String(format: "Time to take (%@) Medicine",myReminderObj.r_MedicineName)
            localNotification.alertAction = "Evening"
            localNotification.fireDate = date //NSDate().dateByAddingTimeInterval(60*1) // 5 minutes(60 sec * 5) from now
            //        localNotification.repeatInterval = NSCalendarUnit.Day
            localNotification.userInfo = ["alarmTime" : date! , "medicineName" : myReminderObj.r_MedicineName]
            localNotification.timeZone = TimeZone.current
            localNotification.soundName =  "alarmtone.mp3" //UILocalNotificationDefaultSoundName // Use the default notification tone/ specify a file in the application bundle
            //localNotification.applicationIconBadgeNumber = 1 // Badge number to set on the application Icon.
            localNotification.category = "ACTIONABLE" // Category to use the specified actions
            UIApplication.shared.scheduleLocalNotification(localNotification) // Scheduling the notification.
            }
        }
        
            }
        
        }
    }
 internal func getReminderList()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        arrMyReminderList = NSMutableArray()
        do {
            let rs = try database.executeQuery("select * from Reminder where IsDeleted = 0 ", values: nil)
            while rs.next() {
                let myReminderObj = MyReminderInfo()
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
                arrMyReminderList.add(myReminderObj)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        self.schedulLocalNotification()
    }
}


extension Date {
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(_ daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(_ hoursToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}

//MARK: UNUSED CODE

//        bgView = UIView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height))
//        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        self.view.addSubview(bgView)
//        let xPos:CGFloat = 10
//        var yPos:CGFloat = 5
//
//
//
//        let popUpView = UIView(frame: CGRect(x: 20, y: self.view.center.y - 70 ,width: self.view.frame.width-40 ,height: 100))
//        popUpView.layer.cornerRadius = 4
//        popUpView.backgroundColor = UIColor.white
//        bgView .addSubview(popUpView)
//
//        let lblChangePhoto = BaseUIController().ALabelFrame(CGRect(x: xPos ,y: yPos , width: 200 , height: 21), withString: "Change Photo")as! UILabel
//        lblChangePhoto.font = UIFont().largeFont
//        popUpView.addSubview(lblChangePhoto)
//        if  appDelegate.isOldReminder == false{
//            lblChangePhoto.text = "Select Photo"
//        }
//
//        yPos += 21 + 5
//
//        let btnTakePhoto = BaseUIController().AButtonFrame(CGRect(x: xPos, y: yPos, width: self.view.frame.width-20, height: 25 ), withButtonTital: "Take Photo")as! UIButton
//        btnTakePhoto.addTarget(self, action: #selector(self.btnTakephotoOnClick), for: .touchUpInside)
//        btnTakePhoto.titleLabel?.font = UIFont().mediumFont
//        btnTakePhoto.contentHorizontalAlignment = .left
//        popUpView.addSubview(btnTakePhoto)
//
//        yPos += 25 + 5
//
//        let btnChooseFormGallery = BaseUIController().AButtonFrame(CGRect(x: xPos, y: yPos, width: self.view.frame.width-20, height: 25 ), withButtonTital: "Choose from Gallery") as! UIButton
//        btnChooseFormGallery.addTarget(self, action: #selector(self.btnChooseFromGalleryOnClick), for: .touchUpInside)
//        btnChooseFormGallery.titleLabel!.font = UIFont().mediumFont
//        btnChooseFormGallery.contentHorizontalAlignment = .left
//        popUpView.addSubview(btnChooseFormGallery)
//
//
//        // add Tapgestue  on shadowBackGround
//        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnBG(_:)))
//        tapped.numberOfTapsRequired = 1
//        tapped.delegate = self
//        bgView.addGestureRecognizer(tapped)
