//
//  NotificationsViewController.swift
//  Health
//
//  Created by HW-Anil on 6/23/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,serverTaskComplete {
     var tableView: UITableView = UITableView()
     var arrNotifications = NSMutableArray()
    var activityIndicator : ProgressViewController?
    var  notification_Id = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: viewLifeCycleMethod
    
    override func viewDidLoad() {
        FBEventClass.logEvent("Notifications")
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "NOTIFICATIONS"
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;
        // load local DB Data 
      //  self.loadNotificationsData()
        getNotificatiosFromServer()
        // create A tableView
        tableView = UITableView(frame:CGRect(x: 5, y: 10,width: (UIScreen.main.bounds.width) - 10, height: (UIScreen.main.bounds.height - 20)))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        //add ActivityIndicator on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
//         self.view.addSubview(activityIndicator!) // Comment Progress
        activityIndicator?.start()
    }
    override func viewWillAppear(_ animated: Bool) {
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("Notifications Screen")

    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    //MARK: -TableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrNotifications.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let notificationsObj = arrNotifications[(indexPath as NSIndexPath).section] as! NotificationsInfo
        
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        if (notificationsObj.notiType == "M") {
            var lblNotiTest = UILabel()
            let memberImageview = BaseUIController().AImageViewFrame(CGRect(x: 5, y: 25, width: 50, height: 50), withImageName: "")as! UIImageView
            memberImageview.layer.masksToBounds = true
            let imageString = notificationsObj.notiMemberPhoto
            let data = Data(base64Encoded: imageString, options: NSData.Base64DecodingOptions(rawValue: 0))
            
            if imageString != "" {
                memberImageview.image = UIImage.init(data: data!)
                memberImageview.layer.cornerRadius = 25
            }else{
                memberImageview.image = UIImage(named: "avatar1.png")
                
            }
            
            
            cell.addSubview(memberImageview)
            
            lblNotiTest = BaseUIController().ALabelFrame(CGRect(x: 60, y: 5, width: self.view.frame.width-70, height: 50), withString: "") as! UILabel
            lblNotiTest.text = notificationsObj.notiText
            lblNotiTest.font = UIFont().mediumFont
            cell.addSubview(lblNotiTest)
            
            let btnAccept = BaseUIController().AButtonFrame(CGRect(x: 60, y: 60, width: ((self.view.frame.width - 60)/2 - 20), height: 30), withButtonTital: "Accept")as! UIButton
            btnAccept.layer.borderWidth = 1
            btnAccept.layer.cornerRadius = 5
            btnAccept.titleLabel?.font = UIFont().mediumFont
            btnAccept.setTitleColor(UIColor.gray, for: UIControlState())
            btnAccept.layer.borderColor = UIColor.orange.cgColor
            btnAccept.addTarget(self, action:#selector(self.btnAcceptOnClick(_:)), for: .touchUpInside)
            cell.addSubview(btnAccept)
            
            
            let btnDeny = BaseUIController().AButtonFrame(CGRect(x: btnAccept.frame.origin.x + ((self.view.frame.width - 60)/2) , y: 60, width: ((self.view.frame.width - 60)/2 - 20), height: 30), withButtonTital: "Deny")as! UIButton
            btnDeny.layer.borderWidth = 1
            btnDeny.layer.cornerRadius = 5
            btnDeny.setTitleColor(UIColor.gray, for: UIControlState())
            btnDeny.titleLabel?.font = UIFont().mediumFont
            //UIColor (red: (227/255), green: (227/255), blue: (227/255), alpha: 1)
            btnDeny.layer.borderColor = UIColor.orange.cgColor
            btnDeny.addTarget(self, action: #selector(self.btnDenyOnClikc(_:)), for: .touchUpInside)
            cell.addSubview(btnDeny)
            
            
        }else if(notificationsObj.notiType == "I"){
          //  let notiImageView = BaseUIController().AImageViewFrame(CGRectMake(10, 5, 30, 30), withImageName: "notifications_icon.png")as! UIImageView
          //  cell.addSubview(notiImageView)
            let lblNotificationHeading = BaseUIController().ALabelFrame(CGRect(x: 10, y: 5, width: tableView.frame.width - 20, height: 35), withString: "Order Booked")as! UILabel
            lblNotificationHeading.font = UIFont().regularMediumFont
            lblNotificationHeading.text = notificationsObj.notiText
            lblNotificationHeading.numberOfLines = 0
            cell.addSubview(lblNotificationHeading)
            
            let lblLine = BaseUIController().ALabelFrame(CGRect(x: 10, y: 45, width: tableView.frame.width - 20, height: 1), withString: "")as! UILabel
            lblLine.backgroundColor = UIColor.gray
            cell.addSubview(lblLine)
            
            let lblNotificationText = BaseUIController().ALabelFrame(CGRect(x: 10, y: 47, width: tableView.frame.width - 20, height: 35), withString: "Order Booked")as! UILabel
            lblNotificationText.font = UIFont().smallFont
            lblNotificationText.text = notificationsObj.notiMessages
            lblNotificationText.numberOfLines = 0
            cell.addSubview(lblNotificationText)
            
            
            
            let tipsImageView = BaseUIController().AImageViewFrame(CGRect(x: 10, y: 85, width: tableView.frame.width - 20, height: 190), withImageName: "")as! UIImageView
            tipsImageView.layer.cornerRadius = 2
            cell.addSubview(tipsImageView)
            
            tipsImageView.image = UIImage(named: "img_loading.png")
            
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                // do your background code here
                DispatchQueue.main.sync(execute: {
                    // stop the activity indicator (you are now on the main queue again)
                    if notificationsObj.notiImage != "" {
                        tipsImageView.imageFromUrl(notificationsObj.notiImage)
                    }
                });
            });
        }else if(notificationsObj.notiType == "T"){
            
//            let notiImageView = BaseUIController().AImageViewFrame(CGRectMake(10, 5, 30, 30), withImageName: "notifications_icon.png")as! UIImageView
//            cell.addSubview(notiImageView)
            let lblNotificationHeading = BaseUIController().ALabelFrame(CGRect(x: 60, y: 10, width: self.view.frame.width - 120, height: 21), withString: "Order Booked")as! UILabel
            lblNotificationHeading.text = notificationsObj.notiText
            lblNotificationHeading.font = UIFont().regularMediumFont
            cell.addSubview(lblNotificationHeading)
            let lblLine = BaseUIController().ALabelFrame(CGRect(x: 60, y: 32, width: self.view.frame.width - 120, height: 1), withString: "")as! UILabel
            lblLine.backgroundColor = UIColor.gray
            cell.addSubview(lblLine)
            
            let lblDetailsMessage = BaseUIController().ALabelFrame(CGRect(x: 60, y: 35, width: self.view.frame.width - 120, height: 60), withString: " ")as! UILabel
            lblDetailsMessage.numberOfLines = 0
            lblDetailsMessage.textColor = UIColor.gray
            lblDetailsMessage.text = notificationsObj.notiMessages
            lblDetailsMessage.font = UIFont().mediumFont
            cell.addSubview(lblDetailsMessage)
        
        }
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 3
        cell.layer.borderColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1).cgColor
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
      
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let notificationsObj = arrNotifications[(indexPath as NSIndexPath).section] as! NotificationsInfo
        
        if notificationsObj.notiType == "I" {
             return  285;
            
        }else if (notificationsObj.notiType == "T"){
             return  100;
        
        }else {
             return  100;
        
        }
       
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 8;
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 1, width: tableView.bounds.size.width, height: 5))
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    //MARK: -LoadNotificationsData
    
    func loadNotificationsData()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        arrNotifications = NSMutableArray()
        do {
            let rs = try database.executeQuery("select * from Notifications ORDER BY NotificationId DESC", values: nil)
            while rs.next() {
                let notificationsObj = NotificationsInfo()
                notificationsObj.notiId = rs.string(forColumn: "NotificationId")
                notificationsObj.notiText = rs.string(forColumn: "NotificationText")
                notificationsObj.notiMessages = rs.string(forColumn: "NotificationMessage")
                notificationsObj.notiImage = rs.string(forColumn: "NotificationImage")
                notificationsObj.notiTime = rs.string(forColumn: "NotificationTime")
                notificationsObj.notiMemberPhoto = rs.string(forColumn: "MemberPhoto")
                notificationsObj.notiMemberName = rs.string(forColumn: "MemberName")
                notificationsObj.notiMemberMobile = rs.string(forColumn: "MemberNumber")
                notificationsObj.notiMemberEmail = rs.string(forColumn: "MemberEmail")
                notificationsObj.notiMemberGender = rs.string(forColumn: "MemberGender")
                notificationsObj.notimemberDOB = rs.string(forColumn: "MemberDOB")
                notificationsObj.notiMemberRelation = rs.string(forColumn: "Relation")
                notificationsObj.notiMemberID = rs.string(forColumn: "MemberId")
                notificationsObj.notiAcceptStatus = rs.string(forColumn: "AcceptStatus")
                notificationsObj.notiSeenStatus = rs.string(forColumn: "SeenStatus")
                notificationsObj.notiRecordlink = rs.string(forColumn: "RecordLink")
                notificationsObj.notiRecordType = rs.string(forColumn: "RecordType")
                notificationsObj.notiType = rs.string(forColumn: "NotificationType")
                
                arrNotifications.add(notificationsObj)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        tableView.reloadData()
    }
    
    
    func deleteNotificaionsAfterAcceptOrReject(_ notificationID : String)  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        do {
           try database.executeUpdate(String(format:"delete from Notifications where NotificationId = %@",notificationID), values: nil)
            
        }catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        let count = self.getNotificationsCount()
        if count == 0 {
         self.navigationController?.popViewController(animated: true)
        }
    }
    func getNotificationsCount() -> Int{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        var  mCount = 0
        do {
            let rs = try database.executeQuery("SELECT COUNT(DISTINCT NotificationId) FROM Notifications where NotificationType = 'M'", values: nil)
            while rs.next() {
                mCount = Int(rs.int(forColumn: "COUNT(DISTINCT NotificationId)"))
                print(mCount)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        return mCount
    }
    
    //MARK: -NovigationsBarButton
    func barButtonBackClick(_ barButton : UIBarButtonItem)  {
        
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: -ButtonOnClick
    func btnAcceptOnClick(_ button : UIButton){
        let buttonPosition = button.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        var notiObj = NotificationsInfo()
        notiObj = arrNotifications[((indexPath as NSIndexPath?)?.section)!] as! NotificationsInfo
        
        self.saveNotificationsResponse(notiObj.notiId, _status: "1")
  
    }
    func btnDenyOnClikc(_ button : UIButton)  {
        let buttonPosition = button.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        var notiObj = NotificationsInfo()
        notiObj = arrNotifications[((indexPath as NSIndexPath?)?.section)!] as! NotificationsInfo
        
        self.saveNotificationsResponse(notiObj.notiId, _status: "0")

    }
    
    //MARK: NotificationsSync
    func getNotificatiosFromServer(){
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
                let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
                let allParameters = ["customerId":customerId]
                ServerConnectivity().callWebservice(allParameters, resulttagname: "GetNotificationsResult" ,methodname: "GetNotifications", className: self)
            }
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
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
//            if NotificationsViewController().getNotificationsCount() != 0 {
//                lblNotifications.isHidden = false
//                lblNotifications.text = String(NotificationsViewController().getNotificationsCount())// get total  Notifications count
//                
//            }
            
        }
        loadNotificationsData()
    }
    //MARK: -RespondNotifications
    func saveNotificationsResponse(_ _noti_ID : String , _status : String)  {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            notification_Id = _noti_ID
            let allParameters = ["nId":_noti_ID , "status" : _status]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "SaveNotificationResultResult" ,methodname: "SaveNotificationResult", className: self)
        }
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                self.activityIndicator?.stop()
                // getMemberProfileInfo result
                if (methodName == "GetNotifications"){
                    self.syncNotificationsFromServerToLocal(allResponse as! NSArray)
                }else{
                if (allResponse as! String == "1"){
                self.deleteNotificaionsAfterAcceptOrReject(self.notification_Id)
                }else{
                 self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }
                }
            });
        });
    }
    
    

    

}

extension UIImageView {
    public func imageFromUrl(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { (response, data, error) in
                if error == nil {
                    self.image = UIImage(data: data!)
                }
            })
//            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {
//                (response: URLResponse?, data: Data?, error: NSError?) -> Void in
//                self.image = UIImage(data: data!)
//            } as! (URLResponse?, Data?, Error?) -> Void as! (URLResponse?, Data?, Error?) -> Void as! (URLResponse?, Data?, Error?) -> Void as! (URLResponse?, Data?, Error?) -> Void as! (URLResponse?, Data?, Error?) -> Void as! (URLResponse?, Data?, Error?) -> Void as! (URLResponse?, Data?, Error?) -> Void
        }
    }
}

