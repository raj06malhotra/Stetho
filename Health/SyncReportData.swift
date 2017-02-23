//
//  SyncData.swift
//  Stetho
//
//  Created by HW-Anil on 2/20/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit

class SyncReportData: NSObject , serverTaskComplete{
    static let shareReportData = SyncReportData()
     var createdRecordId = ""
     var updatedRecordType = ""
     var deletedReportId = ""
    
    func loadDataFromDataBase()  {
        
        let database = AppDelegate.getAppDelegate().openDataBase()
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
    
    
    internal  func syncServertoLocalDB(_ arrMyRecord : NSArray)  {
        
        for i in (0..<arrMyRecord.count) {
            let database = AppDelegate.getAppDelegate().openDataBase()
            
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
        let database = AppDelegate.getAppDelegate().openDataBase()
        
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
            let database = AppDelegate.getAppDelegate().openDataBase()
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
        self.getNonSyncDataFromDtabase()
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
                    
                    let database = AppDelegate.getAppDelegate().openDataBase()
                    
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
    
    
    // MARK: deleteReport(bySyncProcess)
    func getListofDeletedReport()  {
        let database = AppDelegate.getAppDelegate().openDataBase()
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
        let database = AppDelegate.getAppDelegate().openDataBase()
        do {
            
            try database.executeUpdate(String(format:"delete from RecordDetails where DataBaseId = '%@' ",deletedReportId), values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        self.getListofDeletedReport()
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
                    if methodName == "GetRecordsFromServer" {
                        self.syncServertoLocalDB(allResponse as! NSArray)
                    }
                    else if(methodName == "SaveRecord_New"){
                        self.updateLocalDBAfterSync(allResponse as! NSArray)
                    }
                    else if (methodName == "DeleteRecords"){
                        if(allResponse as! String == "1"){
                            self.deleteReportFromDatabase()
                        }
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
