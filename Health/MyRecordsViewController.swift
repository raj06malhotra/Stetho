 //
//  MyRecordsViewController.swift
//  Health
//
//  Created by HW-Anil on 6/18/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class MyRecordsViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource ,serverTaskComplete , CustomDelegate {
    //MARK: - VariableDeclaration
    var tableView: UITableView = UITableView()
    var activityIndicator : ProgressViewController?
//    var arrMyRecords :NSArray?
    var arrReportData: NSMutableArray = NSMutableArray()
    var arrFilterRecords = NSMutableArray()
    var needToRefresh = false
    var mainBGView : UIView = UIView()
    var editPopupView : UIView = UIView()
    var selectedDatabaseID = ""
    var longPressActive = Bool()
    var arrCheckUncheck = NSMutableArray()
    var txtLabName = UITextField()
    var txtTestName = UITextField()
    var txtTestdate = UITextField()
    var btnDone = UIButton()
    var isDesc = Bool()
    var pdfPopupView : UIView = UIView()
    let datePickerView  : UIDatePicker = UIDatePicker()
    var documentInteractionController = UIDocumentInteractionController()
     var tabBarHeight : CGFloat = 0
    // add sort button
    var btnSortText : UIButton = UIButton()
    var btnSort : UIButton = UIButton()
    
    
    
   // MARK: - ViewLifeCycleMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        longPressActive = false

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.red
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.red]
        self.CreateALayout()
        //set activity on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        self.view.addSubview(activityIndicator!)
        NotificationCenter.default.addObserver(self, selector: #selector(MyRecordsViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyRecordsViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        
        if needToRefresh  {
           // self.filterData("")
            self.loadDataFromDataBase("desc")
        }else{
            //Call Webservice
             self.hitAWebServices()
           // self.loadDataFromDataBase()
        }
        
        isDesc = true
        
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - CreateLayout
    func CreateALayout()  {
        
        // create A tableView
        tableView = UITableView(frame:CGRect(x: 5, y: 20,width: (UIScreen.main.bounds.width) - 10, height: (UIScreen.main.bounds.height-(120 + tabBarHeight)))) // 64 + 40
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        self.view.addSubview(self.tableView)
        // create A sorting Button
        
         btnSortText = UIButton(frame: CGRect(x: self.view.frame.width - 70 ,y: 5,width:30,height: 20)) //UILabel(frame: CGRect(x: btnSort.frame.origin.x + 25, y: 5, width: 30, height: 20))
        btnSortText.setTitleColor(KRED_COLOR, for: .normal)
        btnSortText.titleLabel?.font = KROBOTO_Regular_14
        btnSortText.addTarget(self, action: #selector(self.btnSortOnClick), for: .touchUpInside)
        btnSortText.setTitle("Sort", for: .normal)
        self.view.addSubview(btnSortText)
        
        btnSort = UIButton(frame: CGRect(x: btnSortText.frame.origin.x + 30 + 2 ,y: 5,width:20,height: 20))
        btnSort.setImage(UIImage(named: "sort_icon"), for: UIControlState())
        btnSort.addTarget(self, action: #selector(self.btnSortOnClick), for: .touchUpInside)
        btnSort.imageEdgeInsets = UIEdgeInsetsMake(2.5, 0, 2.5, 0)
        self.view.addSubview(btnSort)
        
        btnSortText.isHidden = true
        btnSort.isHidden = true
        
        
        //  add LongPress Gesture
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressOnCell(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)
//        //  add LongPress Gesture
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MyRecordsViewController.longPressOnCell(_:)))
//        tableView.addGestureRecognizer(longPressRecognizer)
        
    }
    func openPDFPopup()  {
        
//        let  mainBGView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.window!.frame.width, height: self.view.window!.frame.height))
//        mainBGView.tag = 400
//        mainBGView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        self.view.window! .addSubview(mainBGView)
//        pdfPopupView = UIView(frame: CGRect(x: 10, y:(self.view.window!.frame.height/2 - (50)), width: self.view.window!.frame.width - 20, height: 100.00));
//        pdfPopupView.backgroundColor = UIColor.white
//        pdfPopupView.layer.cornerRadius = 2.0
//        mainBGView.addSubview(pdfPopupView)
//        var yPos:CGFloat = 10
//        
//        let btnShareLink = BaseUIController().AButtonFrame(CGRect(x: 10, y: yPos, width: mainBGView.frame.width - 20, height: 35), withButtonTital: "Share link")as! UIButton
//        btnShareLink.contentHorizontalAlignment = .left
//        btnShareLink.titleLabel?.font = UIFont().mediumFont
//        btnShareLink.addTarget(self, action: #selector(self.btnShareLinkOnClick(_:)), for: .touchUpInside)
//        pdfPopupView.addSubview(btnShareLink)
//        yPos += 10 + 35
//        let btnSharePdf = BaseUIController().AButtonFrame(CGRect(x: 10, y: yPos, width: mainBGView.frame.width - 20, height: 35), withButtonTital: "Share pdf")as! UIButton
//        btnSharePdf.contentHorizontalAlignment = .left
//        btnSharePdf.titleLabel?.font = UIFont().mediumFont
//        btnSharePdf.addTarget(self, action: #selector(self.btnSharePdfOnClikc(_:)), for: .touchUpInside)
//        pdfPopupView.addSubview(btnSharePdf)
//        // add tapgesture on view
//        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnBGView(_:)))
//        tapped.numberOfTapsRequired = 1
//        mainBGView.addGestureRecognizer(tapped)
        
        
        let alertSheet = UIAlertController(title: KSHARE, message: nil, preferredStyle: .actionSheet)
        alertSheet.view.tintColor = KRED_COLOR
        
        alertSheet.addAction(UIAlertAction(title: KSHARE_LINK, style: .default, handler: { (alert: UIAlertAction!) in
            self.btnShareLinkOnClick()
        }))
        alertSheet.addAction(UIAlertAction(title: KSHARE_PDF, style: .default, handler: { (alert: UIAlertAction!) in
            self.btnSharePdfOnClikc()
        }))
        alertSheet.addAction(UIAlertAction(title: KCANCEL, style: .cancel, handler: { (alert: UIAlertAction!) in
            alertSheet.dismiss(animated: true, completion: nil)
        }))
        present(alertSheet, animated: true, completion: nil)
        
        
    }

    //MARK: - TableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return (arrFilterRecords.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let image_width = (self.view.frame.width)/6
        let image_height = (self.view.frame.width)/5
        let lblHeight = image_height/3
        var yPos : CGFloat = 7
        
        
        
        var  reportObj = HealthInfo()
        reportObj = (arrFilterRecords.object(at: (indexPath as NSIndexPath).section)) as! HealthInfo
        
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        var lblTestName = UILabel()
        var lblLabName = UILabel()
        var lblDate = UILabel()
        lblTestName = BaseUIController().ALabelFrame(CGRect(x: image_width + 10, y: yPos, width: self.view.frame.width-70, height: lblHeight), withString: "") as! UILabel
        yPos += lblHeight
        lblLabName = BaseUIController().ALabelFrame(CGRect(x: image_width + 10, y: yPos, width: 200.0, height: lblHeight), withString: "") as! UILabel
         yPos += lblHeight
        lblDate = BaseUIController().ALabelFrame(CGRect(x: image_width + 10, y: yPos, width: 200.0, height: lblHeight), withString: "") as! UILabel
        lblTestName.font = UIFont().mediumFont
        lblLabName.font = UIFont().mediumFont
        lblDate.font = UIFont().mediumFont
        
        let test = reportObj.reportTestName
        lblTestName.text = String(format: "Test Name: %@",test)
        let labName = reportObj.reportLabName
        lblLabName.text = String(format: "Lab Name: %@",labName)
        let date = reportObj.reportDate
        lblDate.text = String(format: " Date: %@",date)
        
        cell.addSubview(lblTestName)
        cell.addSubview(lblLabName)
        cell.addSubview(lblDate)
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 3
        cell.layer.borderColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1).cgColor
        
        let pdfImageview = BaseUIController().AImageViewFrame(CGRect(x: 5, y: 5, width: image_width, height: image_height), withImageName: "pdf_icon.png")as! UIImageView
        pdfImageview.isUserInteractionEnabled = true
        pdfImageview.layer.borderWidth = 0.5
        pdfImageview.layer.cornerRadius = 2
        pdfImageview.layer.borderColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1).cgColor
        cell.addSubview(pdfImageview)
        var checkImageView = UIImageView()
        
        let lblView = BaseUIController().ALabelFrame(CGRect(x: 0, y: image_height - 15, width: image_width, height: 14.5), withString: "View")as! UILabel
        lblView.textColor = UIColor.red
        lblView.backgroundColor = UIColor.lightGray
        lblView.textAlignment = .center
        lblView.font = UIFont.boldSystemFont(ofSize: 16)//UIFont().mediumFont
        pdfImageview.addSubview(lblView)
        //set Edit button on cell
        let btnEdit = BaseUIController().AButtonFrame(CGRect(x: tableView.frame.width - 35 , y: 5 ,width:30,height:30), withButtonTital: "")as! UIButton
        btnEdit.setImage(UIImage(named: "edit_red_icon.png"), for: .normal)
        btnEdit.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        btnEdit.addTarget(self, action: #selector(btnEditOnClick(button:)), for: .touchUpInside)
        cell.addSubview(btnEdit)
        
        
        
       
        
        // add selected check & uncheck button on cell 
        if longPressActive {
            let checkImageViewLayout = UIImageView(frame: CGRect(x: tableView.frame.width - 30, y: ((image_height) - 20), width: 20, height: 20))
            checkImageViewLayout.layer.cornerRadius = 2
            checkImageViewLayout.layer.borderWidth = 2
            checkImageViewLayout.layer.borderColor  = KRED_COLOR.cgColor
            cell.addSubview(checkImageViewLayout)
            checkImageView = BaseUIController().AImageViewFrame(CGRect(x: 2.5, y: 2.5, width: 15, height: 15), withImageName: "checked")as! UIImageView
            checkImageView.isUserInteractionEnabled = true
            checkImageViewLayout.addSubview(checkImageView)
            if arrCheckUncheck.contains((indexPath as NSIndexPath).section) {
                checkImageView.isHidden = false
            }
            else{
               checkImageView.isHidden = true
            }
        }
        // Add tap Gesture on ImageViw
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyRecordsViewController.tappedOnImage(_:)))
        tapped.numberOfTapsRequired = 1
        pdfImageview.addGestureRecognizer(tapped)
        cell.selectionStyle = .none
        return cell;
      
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var  reportObj = HealthInfo()
        reportObj = (arrFilterRecords.object(at: (indexPath as NSIndexPath).section)) as! HealthInfo
        if longPressActive {
            if arrCheckUncheck .contains((indexPath as NSIndexPath).section) {
                arrCheckUncheck.remove((indexPath as NSIndexPath).section)
            }else{
                arrCheckUncheck.add((indexPath as NSIndexPath).section)
            }
            tableView.reloadData()
        }else{
          /*  var arrLabelName = NSArray()
            arrLabelName = ["Lab:" , "Test:", "Date:"]
            self.showEditView(arrLabelName, textValue: reportObj)
            // check local or server data
            if reportObj.recordId == "0" {
                selectedDatabaseID = reportObj.dataBaseId
            }else{
                selectedDatabaseID = reportObj.recordId
            } */
            
            let PDFViewVC = PDFViewerViewController()
            var recordInfo = HealthInfo()
            recordInfo = arrFilterRecords[((indexPath as NSIndexPath?)?.section)!]as! HealthInfo
            PDFViewVC.recordObject = recordInfo
            self.navigationController?.pushViewController(PDFViewVC, animated: true)
           
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let image_height = (self.view.frame.width)/5
        return  image_height + 10;
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
    // MARK: - TextFiedlDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        return textField.resignFirstResponder()
    }
    //MARK: - WebServicesCall
    
    func hitAWebServices()  {
        needToRefresh = true
        
        print(Reachability.isConnectedToNetwork())
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let allParameters = ["customerId":customerId, "recordType":"R"]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetRecordsResult" ,methodname: "GetRecords", className: self)
        }else{
             self.loadDataFromDataBase("desc")
           // self.presentViewController(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
      //  print(allResponse)
//        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if allResponse is String &&  allResponse as! String == "" {
                    self.present(BaseUIController().showAlertView("No Record"), animated: true, completion: nil)
                }else if (allResponse is String && allResponse as! String != ""){
                    //shwo error message
                  //  self.presentViewController(BaseUIController().showAlertView(allResponse as! String), animated: true, completion: nil)
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }else{
                     self.syncServertoLocalDB((allResponse as? NSArray)!)
                }
                
            });
        }//);
        
    }
    //MARK: customDelegate
    func reloadLocalDataAferbackfFromView(){
        self.loadDataFromDataBase("desc")
        
    }
    //MARK: - FilterData
    func filterData(_ memberId : String){
        
        let  member_Id = UserDefaults.standard.value(forKey: "selectedMemberId")as! String
        arrFilterRecords = NSMutableArray()
        arrFilterRecords = filterRecords(arrReportData, memberid: member_Id)
        if arrFilterRecords.count == 0 {
          // self.presentViewController(BaseUIController().showAlertView("No Recode"), animated: true, completion: nil)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.reloadData()

    }
    
   func filterRecords(_ arrRecords : NSMutableArray , memberid : String) -> NSMutableArray {
        
        for arrObject in arrRecords {
            var obj = HealthInfo()
            obj = arrObject as! HealthInfo;
            
            let filterId = obj.memberId
            print(arrObject)
            if filterId == memberid
            {
                arrFilterRecords.add(obj)
                print(arrFilterRecords)
            }
            
    }
    
        return arrFilterRecords
    }
    //MARK: - DatabaseOperation
    func syncServertoLocalDB(_ arrMyRecord : NSArray)  {
        
        for  i in (0..<arrMyRecord.count) {
            
            let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documents.appendingPathComponent("HealthDatabase.db")
            let database = FMDatabase(path: fileURL.path)
            if !(database?.open())! {
                print("Unable to open database")
                return
            }
            do {
                print(i)
                let memberId = (arrMyRecord[i] as AnyObject).value(forKey: "memberid")as! String
                let labName = (arrMyRecord[i] as AnyObject).value(forKey: "lab_name")as! String
                let date = (arrMyRecord[i] as AnyObject).value(forKey: "report_date")as! String
                let testName = (arrMyRecord[i] as AnyObject).value(forKey: "test_name")as! String
                let dataBaseId = (arrMyRecord[i] as AnyObject).value(forKey: "recordid")as! String
                
                let rs = try database?.executeQuery(String(format:"select * from recordDetails where dataBaseId = %@  and RecordType = 'R'",dataBaseId), values: nil)
               
                if rs?.next() == false {
                    try database?.executeUpdate("insert into RecordDetails (DataBaseId , MemberId ,RecordId, RecordDate , RecordLabName , RecordTestName , DoctorName, DietitianName, RecordDisease ,RecordString ,RecordLink,ServerToLocalSyncStatus,LocalToServerSyncStatus, RecordType,isDeleted) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", values: [dataBaseId , memberId ,"0", date,labName, testName ,"" ,"","","","","N","Y","R","N"])
                }
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
             database?.close()
        }
       
        self.loadDataFromDataBase("desc")
    }
    func loadDataFromDataBase(_ order : String)  {
        btnSortText.isHidden = false
        btnSort.isHidden = false
        
        let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documents.appendingPathComponent("HealthDatabase.db")
        let database = FMDatabase(path: fileURL.path)
        
        if !(database?.open())! {
            print("Unable to open database")
            return
        }
            arrReportData = NSMutableArray()
        
        do {
            let rs = try database?.executeQuery(String(format:"select * from RecordDetails where RecordType = 'R' and isDeleted = 'N' order by _id %@, recorddate %@",order,order), values: nil)
            while (rs?.next())! {
                let recordObj = HealthInfo()
                recordObj.memberId = (rs?.string(forColumn: "MemberId"))!
                recordObj.dataBaseId = (rs?.string(forColumn: "DataBaseId"))!
                recordObj.recordId = (rs?.string(forColumn: "RecordId"))!
                recordObj.reportDate = (rs?.string(forColumn: "RecordDate"))!
                recordObj.reportLabName = (rs?.string(forColumn: "RecordLabName"))!
                recordObj.reportTestName = (rs?.string(forColumn: "RecordTestName"))!
                recordObj.PDFDataString = (rs?.string(forColumn: "RecordString"))!
                recordObj.recordLink = (rs?.string(forColumn: "RecordLink"))!
                recordObj.recordType = (rs?.string(forColumn: "RecordType"))!
              //  recordObj.syncStatus = rs.stringForColumn("SyncStatus")
                arrReportData.add(recordObj)
            }
            
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database?.close()
        let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
        self.filterData(customerId)
    }
    func btnSortOnClick()  {
        if (isDesc) {
           self.loadDataFromDataBase("asc")
            isDesc = false
        }else{
           self.loadDataFromDataBase("desc")
            isDesc = true
        }
    }
    //MARK: - ClickOnImage
    func tappedOnImage(_ sender: UITapGestureRecognizer)  {
        let touch = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: touch)
        print((indexPath as NSIndexPath?)?.section)
        
        if longPressActive {
            if arrCheckUncheck .contains((indexPath! as NSIndexPath).section) {
                arrCheckUncheck.remove((indexPath! as NSIndexPath).section)
            }else{
                arrCheckUncheck.add((indexPath! as NSIndexPath).section)
            }
            tableView.reloadData()
        }else{
        let PDFViewVC = PDFViewerViewController()
        var recordInfo = HealthInfo()
        recordInfo = arrFilterRecords[((indexPath as NSIndexPath?)?.section)!]as! HealthInfo
        PDFViewVC.recordObject = recordInfo
        self.navigationController?.pushViewController(PDFViewVC, animated: true)
        }
        
    }
    func btnEditOnClick(button : UIButton) {
        let buttonPosition = button.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        var  reportObj = HealthInfo()
        reportObj = (arrFilterRecords.object(at: (indexPath?.section)!)) as! HealthInfo
        
        if longPressActive {
            if arrCheckUncheck .contains(indexPath!.section) {
                arrCheckUncheck.remove(indexPath!.section)
            }else{
                arrCheckUncheck.add(indexPath!.section)
            }
            tableView.reloadData()
        }else{
             var arrLabelName = NSArray()
             arrLabelName = ["Lab" , "Test", "Date"]
             self.showEditView(arrLabelName, textValue: reportObj)
             // check local or server data
             if reportObj.recordId == "0" {
             selectedDatabaseID = reportObj.dataBaseId
             }else{
             selectedDatabaseID = reportObj.recordId
             }
        }
        
    }
    
    func longPressOnCell(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
//      remove Navigation item from navigation bar
        for view in  (self.view.window!.viewWithTag(500)?.subviews)! {
            view.isHidden = true
        }
        //Add skip button on Navigation bar
        btnDone = BaseUIController().AButtonFrame(CGRect(x: 45  ,y: 7 , width: 40 , height: 30), withButtonTital: "Done")as! UIButton
        btnDone.tag = 111
        btnDone.backgroundColor = UIColor.white
        btnDone.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btnDone.setTitleColor(UIColor.red, for: UIControlState())
        btnDone.addTarget(self, action: #selector(self.btnDoneOnClick(_:)), for: .touchUpInside)
        self.view.window!.viewWithTag(500)?.addSubview(btnDone)
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
           
            let touchPoint = longPressGestureRecognizer.location(in: tableView)
            if tableView.indexPathForRow(at: touchPoint) != nil {
                //get pdf link & check pdf file sync or Not
              //  arrReportData = NSMutableArray()
                let indexPath = tableView.indexPathForRow(at: touchPoint)
                var pdfLink = ""
                var  selectedReportObj = HealthInfo()
                selectedReportObj = (arrFilterRecords.object(at: ((indexPath as NSIndexPath?)?.section)!)) as! HealthInfo
                pdfLink = pdfLink + String(format: "\n \n %@", selectedReportObj.recordLink)
                print(selectedReportObj.recordLink)
                if selectedReportObj.recordLink != ""  {
                longPressActive = true
                arrReportData = NSMutableArray()
                if arrCheckUncheck .contains((indexPath! as NSIndexPath).section) {
                    arrCheckUncheck.remove((indexPath! as NSIndexPath).section)
                }else{
                    arrCheckUncheck.add((indexPath! as NSIndexPath).section)
                }
                print(arrCheckUncheck)
                tableView.reloadData()
                    
                }else{
                 self.present(BaseUIController().showAlertView("Selected file not sync on server Please wait!"), animated: true, completion: nil)
                }
                
                // your code here, get the row for the indexPath or do whatever you want
            }
        }
    }
    
    func tappedOnBGView(_ sender: UITapGestureRecognizer)  {
        
        self.view.window!.viewWithTag(400)?.isHidden = true
        self.view.window!.viewWithTag(400)?.removeFromSuperview()
       
    }
    func btnSaveOnClick(_ button : UIButton)  {
                let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = documents.appendingPathComponent("HealthDatabase.db")
                let database = FMDatabase(path: fileURL.path)
                if !(database?.open())! {
                    print("Unable to open database")
                    return
                }
                
                do {
                    
                    let labName = txtLabName.text
                    let testName = txtTestName.text
                    let testDate = txtTestdate.text
                    try database?.executeUpdate(String(format:"update recordDetails set  RecordLabName = '%@', RecordTestName = '%@', RecordDate = '%@',LocalToServerSyncStatus = 'N' where (DataBaseId = '%@' OR RecordId = '%@')  and RecordType = 'R'", labName!,testName!,testDate!,selectedDatabaseID,selectedDatabaseID), values: nil)
                    }
                    
                 catch let error as NSError {
                    print("failed: \(error.localizedDescription)")
                }
                database?.close()
              self.view.window!.viewWithTag(400)?.isHidden = true
              self.view.window!.viewWithTag(400)?.removeFromSuperview()
              self.loadDataFromDataBase("desc")
              tableView.reloadData()
              HomeViewController().getNonSyncDataFromDtabase()
        
            }
    
    // MARK: - OnClickMethod
    func btnShareOnClick()  {
        
        if arrCheckUncheck.count > 0 {
            openPDFPopup()
        }else{
            self.present(BaseUIController().showAlertView("Please select record by long Pressing it."), animated: true, completion: nil)
        }
    }
    func btnDeleteOnClick()   {
        if arrCheckUncheck.count > 0 {
            for  i in (0..<arrCheckUncheck.count) {
                
                let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = documents.appendingPathComponent("HealthDatabase.db")
                let database = FMDatabase(path: fileURL.path)
                if !(database?.open())! {
                    print("Unable to open database")
                    return
                }
                
                do {
                    var  selecatedObject = HealthInfo()
                    let index = arrCheckUncheck.object(at: i)as! Int
                    selecatedObject = arrFilterRecords.object(at: index)as! HealthInfo
                    let dataBaseId = selecatedObject.dataBaseId
                    let recordId = selecatedObject.recordId
                    if recordId == "0" {
                        try database?.executeUpdate(String(format:"update recordDetails set  isDeleted = 'Y' where DataBaseId = '%@' and RecordType = 'R'",dataBaseId ), values: nil)
                    }else{
                        try database?.executeUpdate(String(format:"update recordDetails set  isDeleted = 'Y' where RecordId = '%@' and RecordType = 'R'", recordId), values: nil)
                    }
                } catch let error as NSError {
                    print("failed: \(error.localizedDescription)")
                }
                database?.close()
            }
            arrCheckUncheck = NSMutableArray()
            self.loadDataFromDataBase("desc")
            HomeViewController().getNonSyncDataFromDtabase()
        }else{
            self.present(BaseUIController().showAlertView("Please select record by long Pressing it."), animated: true, completion: nil)
        }
    }
    func btnDoneOnClick(_ button : UIButton)  {
        
        for view in  (self.view.window!.viewWithTag(500)?.subviews)! {
            view.isHidden = false
            if view.tag == 111 {
                view.isHidden = true
            }
        }
        arrCheckUncheck.removeAllObjects()
        longPressActive = false
        tableView.reloadData()
        
    }
    func btnShareLinkOnClick()  {
        var pdfLink = ""
        for i in 0..<arrCheckUncheck.count {
            let index = arrCheckUncheck.object(at: i)as! Int
            var  selectedReportObj = HealthInfo()
            selectedReportObj = (arrFilterRecords.object(at: index)) as! HealthInfo
            pdfLink = pdfLink + String(format: "\n \n %@", selectedReportObj.recordLink)
        }
        self.view.window!.viewWithTag(400)?.isHidden = true
        self.view.window!.viewWithTag(400)?.removeFromSuperview()
        let activityViewController = HomeTabSwipeViewController().shareTextImageAndURL(pdfLink, sharingImage: nil, sharingURL: nil)
        self.present(activityViewController, animated: true, completion: nil)
        arrCheckUncheck.removeAllObjects()
        longPressActive = false
        tableView.reloadData()
    }
    func btnSharePdfOnClikc()  {
        
        if (arrCheckUncheck.count > 1){
            self.present(BaseUIController().showAlertView("Please select single file!"), animated: true, completion: nil)
        }else{
            let index = arrCheckUncheck.object(at: 0)as! Int
            var  selectedReportObj = HealthInfo()
            selectedReportObj = (arrFilterRecords.object(at: index)) as! HealthInfo
            let reocordData = selectedReportObj.PDFDataString
            let data = Data(base64Encoded: reocordData, options: NSData.Base64DecodingOptions(rawValue: 0))
            let urlWhats = "whatsapp://app"
            if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                if let whatsappURL = URL(string: urlString) {
                    
                    if UIApplication.shared.canOpenURL(whatsappURL) {
                        let tempFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/report_recored.pdf")
                        do {
                            try data!.write(to: tempFile, options: .atomic)
                            self.documentInteractionController = UIDocumentInteractionController(url: tempFile)
                            self.documentInteractionController.uti = "com.adobe.pdf"
                            //  self.documentInteractionController.UTI = "public.data"
                            //self.documentInteractionController.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
                            self.documentInteractionController.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
                        } catch {
                            print(error)
                        }
                    } else {
                        // Cannot open whatsapp
                    }
                }
            }

        }
        
        self.view.window!.viewWithTag(400)?.isHidden = true
        self.view.window!.viewWithTag(400)?.removeFromSuperview()
        
        arrCheckUncheck.removeAllObjects()
        longPressActive = false
        tableView.reloadData()
        
    }
    
    //MARK: - DatePicker
    func OpenDatePicker(_ sender: UITextField) {
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.maximumDate = Date()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(PDFViewerViewController.handleDatePicker(_:)), for: UIControlEvents.valueChanged)
        
    }
    
    func handleDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        txtTestdate.text = dateFormatter.string(from: sender.date)
        print(dateFormatter.string(from: sender.date))
    }

    
    // MARK: - KeyboardShow&Hide
    func keyboardWillShow(_ notification:Notification){
       print(UIScreen.main.bounds.width)
        print(UIScreen.main.bounds.height)
        print(self.view.frame.height)
        editPopupView.frame = CGRect(x: 10, y: (UIScreen.main.bounds.height/2 - ((editPopupView.frame.height/2) + 50)), width: UIScreen.main.bounds.width-20, height: editPopupView.frame.height)
    }
    
    func keyboardWillHide(_ notification:Notification){
        editPopupView.frame = CGRect(x: 10, y: (UIScreen.main.bounds.height/2 - (editPopupView.frame.height/2 - 32)), width: UIScreen.main.bounds.width - 20 , height: editPopupView.frame.height)
        
    }
    //MARK: - EditRecordData
    func showEditView(_ totalTextField : NSArray , textValue : HealthInfo)  {
        
        let  mainBGView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.window!.frame.width, height: self.view.window!.frame.height))
        mainBGView.tag = 400
        mainBGView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        editPopupView = UIView(frame: CGRect(x: 10, y: (self.view.window!.frame.height/2 - (98)), width: self.view.window!.frame.width - 20, height: 260.0));
        editPopupView.backgroundColor = UIColor.white
        editPopupView.layer.cornerRadius = 2
        mainBGView.addSubview(editPopupView)
       // let xPos : CGFloat = 5.0
        var yPos : CGFloat = 20.0
        for i in (0..<totalTextField.count) {
//            let label = BaseUIController().ALabelFrame(CGRect(x: xPos , y: yPos , width: 60, height: 20), withString: totalTextField[i] as! String)as! UILabel
//            label.font = UIFont().regularMediumFont
//            editPopupView.addSubview(label)
//            
          //  let textField = BaseUIController().ATextFiedlFrame(CGRect(x: xPos + 70 , y: yPos , width: editPopupView.frame.width - (xPos + 80) , height: 40 ), withPlaceHolder: "")as! UITextField
            let placeHolder = "Enter " + String(totalTextField[i] as! String) + " Name"
            
            let textField = BaseUIController().ATextFiedlFrame(CGRect(x: 15 , y: yPos , width: editPopupView.frame.width - 30 , height: 40 ), withPlaceHolder: placeHolder)as! UITextField
            textField.borderStyle = .none
            textField.textAlignment = .left
            textField.font = KROBOTO_Light_18
            textField.textColor = UIColor.darkGray
            textField.delegate = self
            textField.tag = 200 + i
            editPopupView.addSubview(textField)
            
            let lblLine = UILabel(frame: CGRect(x: 15, y: yPos + 38, width: editPopupView.frame.width - 30, height: 1))
            lblLine.backgroundColor = KRED_COLOR
            editPopupView.addSubview(lblLine)
            yPos += 40 + 20
        }
        
        let btnSave = BaseUIController().AButtonFrame(CGRect(x: 0, y: editPopupView.frame.height - 40 ,width:editPopupView.frame.width  , height: 40), withButtonTital: "SAVE RECORD DETAILS")as! UIButton
//        btnSave.layer.borderWidth = 2.0
//        btnSave.layer.borderColor = UIColor.black.cgColor
        btnSave.backgroundColor = KRED_COLOR
        btnSave.titleLabel?.font = KROBOTO_Light_18
        btnSave.setTitleColor(UIColor.white, for: .normal)
        btnSave.addTarget(self, action: #selector(MyRecordsViewController.btnSaveOnClick(_:)), for: .touchUpInside)
        editPopupView.addSubview(btnSave)
        
         self.view.window!.addSubview(mainBGView)
        // add tapgesture on view 
        
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyRecordsViewController.tappedOnBGView(_:)))
        tapped.numberOfTapsRequired = 1
        mainBGView.addGestureRecognizer(tapped)
        // asssing tag of all textField
        txtTestName = editPopupView.viewWithTag(200) as! UITextField
        txtLabName = editPopupView.viewWithTag(201) as! UITextField
        txtTestdate = editPopupView.viewWithTag(202) as! UITextField
        txtLabName.text = textValue.reportLabName
        txtTestName.text = textValue.reportTestName
        let dateString = textValue.reportDate
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let date = df.date(from: dateString)
        if let unwrappedDate = date {
            datePickerView.setDate(unwrappedDate, animated: false)
        }
        txtTestdate.text = textValue.reportDate
        OpenDatePicker(txtTestdate)
        addToolBar(txtTestdate)
        
    }

}

