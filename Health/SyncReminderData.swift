//
//  SyncReminderData.swift
//  Stetho
//
//  Created by HW-Anil on 2/20/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit

class SyncReminderData: NSObject , serverTaskComplete{
    static let shareReminderData = SyncReminderData()
     var deletedReminderId = ""
     var dbReminderId = Int()
    
    //MARK: RemindersSync
    
    func getRemindersFromSever(){
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
            let database = AppDelegate.getAppDelegate().openDataBase()
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
        
        let database = AppDelegate.getAppDelegate().openDataBase()
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
        let database = AppDelegate.getAppDelegate().openDataBase()
        do {
            try database.executeUpdate(String(format:"update Reminder set SyncStatus = 1, ReminderId = '%@' where _id =%d ",reminderId , dbReminderId), values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
      self.syncReminderFromDataBasetoServer()
        
    }
    func getListofDeletedReminder()  {
        let database = AppDelegate.getAppDelegate().openDataBase()
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
        let database = AppDelegate.getAppDelegate().openDataBase()
        do {
            
            try database.executeUpdate(String(format:"delete from Reminder where ReminderId = '%@' ",deletedReminderId), values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        self.getListofDeletedReminder()
        
    }
    
    func deleteAllSyncReminderFromDataBase()  {
        let database = AppDelegate.getAppDelegate().openDataBase()
        do {
            
            try database.executeUpdate(String(format:"delete from Reminder where SyncStatus = %d  and IsDeleted = %d",1,0), values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
        print(methodName)
        print(allResponse)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                
                if allResponse .isEqual("error") || allResponse.isEqual("") || allResponse.isEqual("Something went wrong. Please try again.")  {
                    //  print("some problem")
                    if methodName == "GetRecordsFromServer" && allResponse .isEqual("") {
                        //stop syncing process
                        // self.timerSyncRecordDataFromServerToLocal.invalidate()
                    }
                    if methodName == "GetReminders" && allResponse .isEqual("") {
                        //stop syncing process
                        //  self.reminderTimerSycnServerToLocal.invalidate()
                    }
                    if methodName == "GetAllTests" && allResponse .isEqual("error") {
                        //  self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    }
                    if(allResponse .isEqual("error") || allResponse.isEqual("Something went wrong. Please try again.")){
                        print("some Sync problem")
                    }
                }
                else{
                     if(methodName == "GetReminders"){
                        self.deleteAllSyncReminderFromDataBase()
                        self.syncReminderFromServerToDatabase(allResponse as! NSArray)
                    }
                     else if(methodName == "SaveReminder"){
                        self.updateDataBaseAfterSaveReminder(allResponse as! String)
                     }else if(methodName == "DeleteReminder"){
                        self.deleteReminderFromDataBase()
                    }
                }
                /*   else if methodName == "UpdateMemberInfo" && allResponse .isEqual("1") {
                 self.updateMyFamilyDataAfterSync()
                 }else if(methodName == "GetReminders"){
                 self.reminderTimerSycnServerToLocal.invalidate()
                 self.deleteAllSyncReminderFromDataBase()
                 self.syncReminderFromServerToDatabase(allResponse as! NSArray)
                 }else if(methodName == "SaveReminder"){
                 self.updateDataBaseAfterSaveReminder(allResponse as! String)
                 }else if(methodName == "DeleteReminder"){
                 self.deleteReminderFromDataBase()
                 }else if (methodName == "GetAllTests"){
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
                 } */
            });
        });
    }



}
