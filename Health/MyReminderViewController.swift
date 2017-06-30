//
//  MyReminderViewController.swift
//  Health
//
//  Created by HW-Anil on 8/18/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class MyReminderViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UIGestureRecognizerDelegate,serverTaskComplete {
     //MARK: VariableDeclaration
    var myReminderListTableView = UITableView()
    var arrMyReminderList = NSMutableArray()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate var activityIndicator : ProgressViewController?
    var isComingFromNotification = false
    var fullImageView = UIImageView()
    var scrollView: UIScrollView!
    let bgView = UIView()
    var isComingFromaddReminder = false
    
    
    
    //MARK: ViewLifeCycleMethod
    override func viewDidLoad() {
        FBEventClass.logEvent("Reminder Summery")
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        // add activity on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        self.view.addSubview(activityIndicator!)
        // only load reminder when coming from notificaiton click
        if Reachability.isConnectedToNetwork() == true && isComingFromNotification == true {
            
            self.getRemindersFromSever()
        }else{
            self.getReminderList()
            myReminderListTableView.reloadData()
            let totalCount = self.getTotalReminderCount()
            if totalCount == 0 {
                let addReminderVC = AddReminderViewController()
                appDelegate.isOldReminder = false
                self.navigationController?.pushViewController(addReminderVC, animated: true)
            }
        }
        
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = KRED_COLOR
        self.title = "MY REMINDERS"
        self.createALayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;
        //reload view after update 
        if isComingFromaddReminder == true {
            self.getReminderList()
            myReminderListTableView.reloadData()
        }
        if  isComingFromaddReminder == false{
            isComingFromaddReminder = true
        }
       // self.addLeftBarButton()
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("MyReminder Screen")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     // Dispose of any resources that can be recreated.
    }
    
 //MARK: LayoutDesign
    func createALayout()  {
        myReminderListTableView = UITableView(frame:CGRect(x: 5, y: 64, width: self.view.frame.width - 10  ,height: self.view.frame.height - 64))
        myReminderListTableView.delegate      =   self
        myReminderListTableView.dataSource    =   self
        myReminderListTableView.tableFooterView = UIView()
        myReminderListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myReminderListTableView.backgroundColor = UIColor.clear
        self.view.addSubview(myReminderListTableView)
        // create A Button
        let btnAdd: UIButton = UIButton(frame: CGRect(x: self.view.frame.width - 60 ,y: self.view.frame.height - 60 ,width:40,height: 40))
        btnAdd.addTarget(self, action:#selector(MyReminderViewController.btnAddOnClick(_:)), for: .touchUpInside)
        btnAdd.setImage(UIImage(named: "plus_icon"), for: UIControlState())
        self.view.addSubview(btnAdd)
 
    }
    func showFullImage(_ fullImageString : String)  {
        
//        let bgView = UIView(frame:CGRectMake(0, 0,(UIScreen.mainScreen().bounds.width), (UIScreen.mainScreen().bounds.height)))
//        bgView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
//        self.view.addSubview(bgView)
        
        scrollView = UIScrollView.init(frame: CGRect(x: 5, y: 74, width: self.view.frame.width - 10, height: self.view.frame.height - 84))
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
        scrollView.layer.borderWidth = 2
        scrollView.layer.backgroundColor = UIColor.white.cgColor
        scrollView.layer.cornerRadius = 4
        self.view.addSubview(scrollView)

        fullImageView = BaseUIController().AImageViewFrame(CGRect(x: 0, y: 0, width: scrollView.frame.width , height: scrollView.frame.height), withImageName: "")as! UIImageView
        fullImageView.isUserInteractionEnabled = true
      
        scrollView.addSubview(fullImageView)
        
        let data = Data(base64Encoded: fullImageString, options: NSData.Base64DecodingOptions(rawValue: 0))
        if fullImageString != "" {
            fullImageView.image = UIImage.init(data: data!)
        }
        
        let btnCancel = BaseUIController().AButtonFrame(CGRect(x: 0, y: 0, width: fullImageView.frame.width,  height: 60), withButtonTital: "")as! UIButton
        btnCancel.addTarget(self, action: #selector(self.btnCancelOnclick(_:)), for: .touchUpInside)
      //  btnCancel.imageEdgeInsets = UIEdgeInsetsMake(10, 0 , 10, 200)
        fullImageView.addSubview(btnCancel)
        let cancelImage = BaseUIController().AImageViewFrame(CGRect(x: (fullImageView.frame.width - 40), y: 15, width: 30, height: 30), withImageName: "verified_no.png")as! UIImageView
        btnCancel.addSubview(cancelImage)
        
        // Double Tap
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.handelDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        fullImageView.addGestureRecognizer(doubleTap)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        
        return fullImageView
    }
    
    // MARK: - AddMenuButton
    func addLeftBarButton()  {
        let menuBarButton = UIBarButtonItem(image: UIImage(named: "menu_icon"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(MyReminderViewController.didTapMenuBarButton(_:)))
        self.navigationItem.leftBarButtonItem = menuBarButton
    }
    
    func didTapMenuBarButton(_ sender: AnyObject) {
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }

    //MARK: - TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrMyReminderList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myRemiderObj = arrMyReminderList[(indexPath as NSIndexPath).section]as! MyReminderInfo
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 3
        cell.layer.borderColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1).cgColor
        
        let reminderImageView = BaseUIController().AImageViewFrame(CGRect(x: 10, y: 15, width: 50, height: 50), withImageName: "")as! UIImageView
        reminderImageView.layer.masksToBounds = true
        reminderImageView.isUserInteractionEnabled = true
       // userImageView.layer.cornerRadius = userImageView.frame.width/2
        cell.addSubview(reminderImageView)
        // add gesture on imageView
        // Add tap Gesture on ImageViw
        
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnreminderImageView(_:)))
        tapped.numberOfTapsRequired = 1
        reminderImageView.addGestureRecognizer(tapped)
        
        
        let lbluserName = BaseUIController().ALabelFrame(CGRect(x: 70, y: 10, width: 250, height: 20), withString: "")as! UILabel
        cell.addSubview(lbluserName)
        lbluserName.text = myRemiderObj.r_MemberName
        lbluserName.textColor = UIColor (red: (55.0/255.0), green: (54/255.0), blue: (54.0/255.0), alpha: 1)
        lbluserName.font = UIFont().regularMediumFont

        let lblMedicineName = BaseUIController().ALabelFrame(CGRect(x: 70, y: 35, width: 250, height: 15), withString: "")as! UILabel
        lblMedicineName.text = myRemiderObj.r_MedicineName
        lblMedicineName.textColor = UIColor (red: (55.0/255.0), green: (54/255.0), blue: (54.0/255.0), alpha: 1)
        lblMedicineName.font = UIFont().mediumFont
        cell.addSubview(lblMedicineName)
        
        let lblAlarmSchedule = BaseUIController().ALabelFrame(CGRect(x: 70, y: 55, width: 250, height: 15), withString: "")as! UILabel
        lblAlarmSchedule.textColor = UIColor (red: (55.0/255.0), green: (54/255.0), blue: (54.0/255.0), alpha: 1)
        lblAlarmSchedule.font = UIFont().mediumFont
        cell.addSubview(lblAlarmSchedule)
        
        var allTimeSchedule : NSMutableString = ""
        if myRemiderObj.r_MorningTime != "" {
            allTimeSchedule = NSMutableString(format: " Morning ")
        }
        if myRemiderObj.r_AfternoonTime != "" {
            if allTimeSchedule.length == 0 {
               allTimeSchedule.append(String(format: " Afternoon " ))
            }else{
                allTimeSchedule.append(String(format: ", Afternoon"))
            }
        }
        if myRemiderObj.r_EveningTime != "" {
            if allTimeSchedule.length == 0 {
               allTimeSchedule.append(String(format: " Evening "))
            }else{
               allTimeSchedule.append(String(format: ", Evening"))
            }
        }
        lblAlarmSchedule.text = allTimeSchedule as String
        

        let imageString = myRemiderObj.r_ReminderImage
        let data = Data(base64Encoded: imageString, options: NSData.Base64DecodingOptions(rawValue: 0))
        if imageString != "" {
            reminderImageView.image = UIImage.init(data: data!)
        }else{
            reminderImageView.image = UIImage(named: "app_icon.png")
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let addReminderVC = AddReminderViewController()
        appDelegate.isOldReminder = true
        addReminderVC.myReminderObj = arrMyReminderList[(indexPath as NSIndexPath).section] as! MyReminderInfo
        self.navigationController?.pushViewController(addReminderVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 5;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  80;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 5))
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    // MARK: getReminderCount
    
    func getTotalReminderCount()-> Int  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        var  totalReminder = 0
        do {
            let rs = try database.executeQuery("SELECT COUNT(DISTINCT MemberId) FROM Reminder", values: nil)
            while rs.next() {
                totalReminder = Int(rs.int(forColumn: "COUNT(DISTINCT MemberId)"))
                print(totalReminder)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        return totalReminder
    }

    
    func getReminderList()  {
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
        
    }
    //MARK: ButtonOnClick
    func btnAddOnClick(_ button : UIButton)  {
        let addReminderVC = AddReminderViewController()
        appDelegate.isOldReminder = false
        self.navigationController?.pushViewController(addReminderVC, animated: true)
    }
    func barButtonBackClick(_ barButton : UIBarButtonItem)  {
      
            self.navigationController?.popViewController(animated: true)
    }
    func btnCancelOnclick(_ button : UIButton) {
       bgView.removeFromSuperview()
       fullImageView.removeFromSuperview()
       scrollView.removeFromSuperview()
    }
    func tappedOnreminderImageView(_ sender: UITapGestureRecognizer)  {
        
        let touch = sender.location(in: myReminderListTableView)
        let indexPath = myReminderListTableView.indexPathForRow(at: touch)
        print((indexPath as NSIndexPath?)?.section)
        let myRemiderObj = arrMyReminderList[((indexPath as NSIndexPath?)?.section)!]as! MyReminderInfo
       let fullImageString = myRemiderObj.r_ReminderImage
        if (fullImageString != "") {
            self.showFullImage(fullImageString) 
        }
       
    }
    func handelDoubleTap(_ sender: UITapGestureRecognizer)  {
        
        if (scrollView.zoomScale > self.scrollView.minimumZoomScale) {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        }else{
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        
        }


        
    }
    //MARK: callWebservices
    
    func getRemindersFromSever(){
        
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let allParameters = ["customerId":customerId , "reminderIds":"0"]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetRemindersResult" ,methodname: "GetReminders", className: self)
        }
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
       // print(methodName)
       // print(allResponse)
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                
                if allResponse .isEqual("error") || allResponse.isEqual("Something went wrong. Please try again.")  {
                    
                     self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }else{
                if(allResponse.isEqual("")){
                    self.getReminderList()
                    self.myReminderListTableView.reloadData()
                    let totalCount = self.getTotalReminderCount()
                    if totalCount == 0 {
                        let addReminderVC = AddReminderViewController()
                        self.appDelegate.isOldReminder = false
                        self.navigationController?.pushViewController(addReminderVC, animated: true)
                    }
                }else{
                    HomeViewController().reminderTimerSycnServerToLocal.invalidate()
//                    HomeViewController().deleteAllSyncReminderFromDataBase()
//                    HomeViewController().syncReminderFromServerToDatabase(allResponse as! NSArray)
                    SyncReminderData.shareReminderData.deleteAllSyncReminderFromDataBase()
                    SyncReminderData.shareReminderData.syncReminderFromServerToDatabase(allResponse as! NSArray)
                    
                    self.getReminderList()
                    self.myReminderListTableView.reloadData()
                }
              }
            });
        });
    }

    
}
