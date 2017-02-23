//
//  SyncMyFamilyData.swift
//  Stetho
//
//  Created by HW-Anil on 2/20/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit

class SyncMyFamilyData: NSObject ,serverTaskComplete {
    static let shareMyFamilyData = SyncMyFamilyData()
    var member_Id = ""
    
    //MARK: - SyncMyFamilyData
    
    func getNonSyncDataFromMyFamilyTable()  {
        let database = AppDelegate.getAppDelegate().openDataBase()
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
        
        let database = AppDelegate.getAppDelegate().openDataBase()
        do {
            try database.executeUpdate(String(format:"update MyFamily set SyncStatus = 'Y' where memberId ='%@' ",member_Id), values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        self.getNonSyncDataFromMyFamilyTable()
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
                    
                     if methodName == "UpdateMemberInfo" && allResponse .isEqual("1") {
                        self.updateMyFamilyDataAfterSync()
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
