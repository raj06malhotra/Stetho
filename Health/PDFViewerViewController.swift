//
//  PDFViewerViewController.swift
//  Health
//
//  Created by HW-Anil on 7/13/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit


class PDFViewerViewController: UIViewController , serverTaskComplete {
    //MARK: - VariableDeclaration
   // var arrPDFViewerData = NSMutableArray()
    var recordObject = HealthInfo()
    var actionButton: ActionButton!
    var editPopupView : UIView = UIView()
    // Edit Record data 
    var txtValue_1 = UITextField()
    var txtValue_2 = UITextField()
    var txtValue_3 = UITextField()
    var mainBGView : UIView = UIView()
    var selectedDatabaseID = ""
    var PDFWebView = UIWebView()
    var activityIndicator : ProgressViewController?
    var pdfPopupView : UIView = UIView()
    var documentInteractionController = UIDocumentInteractionController()
    var  urlString = ""
    let datePickerView  : UIDatePicker = UIDatePicker()
    
    
 // MARK: - ViewLifeCycleMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
       
        self.createLayout(64)
        // add keyboard Hide & Show
        NotificationCenter.default.addObserver(self, selector: #selector(PDFViewerViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PDFViewerViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Do any additional setup after loading the view.
       
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("PDFViewer Screen")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func createLayout(_ pdf_height : CGFloat) {
        var yPos :CGFloat = 2;
        let xPos :CGFloat = 2;
       
        
        // assing databaseId
        if recordObject.recordId == "0" {
            selectedDatabaseID = recordObject.dataBaseId
        }else{
            selectedDatabaseID = recordObject.recordId
        }

//        print(recordObject.dataBaseId)
//        print(recordObject.recordId)
        
        let userImage = BaseUIController().AImageViewFrame(CGRect(x: xPos , y: yPos , width: 60 ,height: 60), withImageName: "user_icon.png")as! UIImageView
        userImage.layer.cornerRadius = 30
        userImage.layer.masksToBounds = true
        self.view.addSubview(userImage)
        let memberId = recordObject.memberId
        let imageString = self.getMemberPhoto(memberId)
        let Imagedata = Data(base64Encoded: imageString, options: NSData.Base64DecodingOptions(rawValue: 0))
        if imageString != "" {
            userImage.image = UIImage.init(data: Imagedata!)
        }else{
            userImage.image = UIImage(named: "avatar1.png")
        }
        let lblText1 = BaseUIController().ALabelFrame(CGRect(x: 70 , y: yPos , width: 60 ,height: 21), withString: "")as! UILabel
        lblText1.font = UIFont().mediumFont
        self.view.addSubview(lblText1)
        
        let lblValue1 = BaseUIController().ALabelFrame(CGRect(x: 150 , y: yPos , width: self.view.frame.width - 150 ,height: 21), withString: "")as! UILabel
        lblValue1.font = UIFont().mediumFont
        self.view.addSubview(lblValue1)
        yPos += 21 + 5
        let lblText2 = BaseUIController().ALabelFrame(CGRect(x: 70 , y: yPos , width: 60 ,height: 21), withString: "")as! UILabel
        lblText2.font = UIFont().mediumFont
        self.view.addSubview(lblText2)
        
        let lblValue2 = BaseUIController().ALabelFrame(CGRect(x: 150
            , y: yPos , width: self.view.frame.width - 150 ,height: 21), withString: "")as! UILabel
         lblValue2.font = UIFont().mediumFont
        self.view.addSubview(lblValue2)
        yPos += 21 + 5
        
        let lblText3 = BaseUIController().ALabelFrame(CGRect(x: 70 , y: yPos , width: 60 ,height: 21), withString: "Date:")as! UILabel
        lblText3.font = UIFont().mediumFont
        self.view.addSubview(lblText3)
        
        let lblValue3 = BaseUIController().ALabelFrame(CGRect(x: 150 , y: yPos , width: self.view.frame.width - 150 ,height: 21), withString: recordObject.reportDate)as! UILabel
         lblValue3.font = UIFont().mediumFont
        self.view.addSubview(lblValue3)
        
        print(recordObject.recordType)
        // Report
        if recordObject.recordType == "R" {
            lblText1.text = "Lab:"
            lblText2.text = "Test:"
            
            lblValue1.text = recordObject.reportLabName
            lblValue2.text = recordObject.reportTestName
            
        }else if(recordObject.recordType == "P"){
            // Prescription
            lblText1.text = "Doctor:"
            lblText2.text = "Disease:"
            
            lblValue1.text = recordObject.doctorName
            lblValue2.text = recordObject.diseaseName
            
        }else if(recordObject.recordType == "I"){
            lblText1.isHidden = true
            lblText2.text = "Disease:"
            
            lblValue1.isHidden = true
            lblValue2.text = recordObject.diseaseName
            //Invoice
            
        }else{
            //Diet Charts
            lblText1.isHidden = true
            lblText2.text = "Dietitian:"
            
            lblValue1.isHidden = true
            lblValue2.text = recordObject.dietitianName
            print(recordObject.dietitianName)
            
        }
        
        let recordString = "hela"//object.recordLink
        let url = URL(string: recordString)
        let reocordData = recordObject.PDFDataString
        print(recordObject.recordLink)
        let data = Data(base64Encoded: reocordData, options: NSData.Base64DecodingOptions(rawValue: 0))
        PDFWebView = UIWebView.init(frame: CGRect(x: 0 , y: 80 , width: self.view.frame.width ,height: self.view.frame.height - (80 + pdf_height)))
        PDFWebView.scalesPageToFit = true
       
        if recordObject.PDFDataString == "" {
            activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
            PDFWebView.addSubview(activityIndicator!)
            loadMyReport(recordObject.dataBaseId, record_Type: recordObject.recordType)
            //set activity on view
            
           
        }else{
            PDFWebView.load(data!, mimeType: "application/pdf", textEncodingName:"", baseURL: url! )
            
        }
        self.view.addSubview(PDFWebView)
        self.addActionButtonOnView()
    }
    
    func addActionButtonOnView()  {
        
        // Create  flicker action Button
        let shareImage = UIImage(named: "share_icon.png")!
        let editImage = UIImage(named: "edit_icon.png")!
        let share = ActionButtonItem(title: "Share", image: shareImage)
        share.action = { item in self.btnShareOnClick()}
        let edit = ActionButtonItem(title: "Edit", image: editImage)
        edit.action = { item in self.btnEditOnClick() }
        
       
        
        actionButton = ActionButton(attachedToView: self.view, items: [share , edit])
        actionButton.action = { button in button.toggleMenu() }
        actionButton.setTitle("+", forState: UIControlState())
        
        actionButton.backgroundColor = UIColor.red
        
        
    }
    // MARK: - TextFiedlDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        return textField.resignFirstResponder()
    }

     // MARK: - OnClickMethod
    func btnShareOnClick()  {
      //  self.shareTextImageAndURL("Gmail", sharingImage: nil, sharingURL: nil)
        self.openPDFPopup()
        
    }
    func btnArchiveOnClick()  {
        
    }
    
    
    func btnEditOnClick()  {
         var arrLabelName = NSArray()
        
        if recordObject.recordType == "R" {
            arrLabelName = ["Lab:" , "Test:", "Date:"]
        }else if(recordObject.recordType == "P"){
            // Prescription
           arrLabelName = ["Doctor:" , "Disease:", "Date:"]
        }else if(recordObject.recordType == "I"){
            //Invoice
            arrLabelName = ["Disease:", "Date:"]
        }else{
            //Diet Charts
           arrLabelName = ["Dietitian:", "Date:"]
        }
        showEditView(arrLabelName)
    }
    
    func btnShareLinkOnClick(_ button : UIButton)  {
        var pdfLink = ""
        pdfLink = pdfLink + String(format: "%@", recordObject.recordLink)
        if recordObject.recordLink == "" {
            pdfLink = pdfLink + String(format: "%@", urlString)
        }
        actionButton.toggleMenu()
        self.view.window!.viewWithTag(405)?.isHidden = true
        self.view.window!.viewWithTag(405)?.removeFromSuperview()
        let activityViewController = HomeTabSwipeViewController().shareTextImageAndURL(pdfLink, sharingImage: nil, sharingURL: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    func btnSharePdfOnClikc(_ button : UIButton)  {
        actionButton.toggleMenu()
        self.view.window!.viewWithTag(405)?.isHidden = true
        self.view.window!.viewWithTag(405)?.removeFromSuperview()
        
        let reocordData = recordObject.PDFDataString
        if recordObject.PDFDataString != "" {
        
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
        }else{
             self.present(BaseUIController().showAlertView("Selected file not sync on server Please wait!"), animated: true, completion: nil)
            
        }
        
    }
   
    func btnSaveOnClick(_ button : UIButton)  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        do {
            if recordObject.recordType == "R" {
                let labName = txtValue_1.text
                let testName = txtValue_2.text
                let testDate = txtValue_3.text
                try database.executeUpdate(String(format:"update recordDetails set  RecordLabName = '%@', RecordTestName = '%@', RecordDate = '%@' where (DataBaseId = '%@' OR RecordId = '%@')  and RecordType = 'R'", labName!,testName!,testDate!,selectedDatabaseID,selectedDatabaseID), values: nil)
                
            }else if(recordObject.recordType == "P"){
                // Prescription
                let doctorName = txtValue_1.text
                let diseaseName = txtValue_2.text
                let Date = txtValue_3.text
                print(doctorName)
                try database.executeUpdate(String(format:"update recordDetails set  DoctorName = '%@', RecordDisease = '%@', RecordDate = '%@' where (DataBaseId = '%@' OR RecordId = '%@')  and RecordType = 'P'", doctorName!,diseaseName!,Date!,selectedDatabaseID,selectedDatabaseID), values: nil)
               

            }else if(recordObject.recordType == "I"){
                //Invoice
                let diseaseName = txtValue_1.text
                let Date = txtValue_2.text
                print(diseaseName)
                try database.executeUpdate(String(format:"update recordDetails set  RecordDisease = '%@', RecordDate = '%@' where (DataBaseId = '%@' OR RecordId = '%@')  and RecordType = 'I'", diseaseName!,Date!,selectedDatabaseID,selectedDatabaseID), values: nil)
            }else{
                //Diet Charts
                let dietitianName = txtValue_1.text
                let Date = txtValue_2.text
                try database.executeUpdate(String(format:"update recordDetails set  DietitianName = '%@', RecordDate = '%@' where (DataBaseId = '%@' OR RecordId = '%@') and RecordType = 'D'", dietitianName!,Date!,selectedDatabaseID,selectedDatabaseID), values: nil)

                
            }
            
        }
            
        catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        self.view.viewWithTag(400)?.isHidden = true
        self.view.viewWithTag(400)?.removeFromSuperview()
       // self.navigationController?.navigationBar.translucent = false
        self.loadDataFromDataBase()
//        tableView.reloadData()
        HomeViewController().getNonSyncDataFromDtabase()

    }
    func tappedOnBGView(_ sender: UITapGestureRecognizer)  {
        self.view.viewWithTag(400)?.isHidden = true
        self.view.viewWithTag(400)?.removeFromSuperview()
    }
    func tappedOnBGView2(_ sender: UITapGestureRecognizer)  {
        actionButton.toggleMenu()
        self.view.window!.viewWithTag(405)?.isHidden = true
        self.view.window!.viewWithTag(405)?.removeFromSuperview()
    }
    // MARK: - KeyboardShow&Hide
    func keyboardWillShow(_ notification:Notification){
        
        if(recordObject.recordType == "I" || recordObject.recordType == "D"){
             editPopupView.frame = CGRect(x: 10, y: (self.view.frame.height/2)-160, width: self.view.bounds.width-20, height: 160)
        }else{
            editPopupView.frame = CGRect(x: 10, y: (self.view.frame.height/2)-180, width: self.view.bounds.width-20, height: 200)
        }
       
    }
    
    func keyboardWillHide(_ notification:Notification){
       if(recordObject.recordType == "I" || recordObject.recordType == "D"){
        editPopupView.frame = CGRect(x: 10, y: (self.view.frame.height/2) - 80, width: self.view.bounds.width-20, height: 160.00)
       }else{
        editPopupView.frame = CGRect(x: 10, y: (self.view.frame.height/2) - 100, width: self.view.bounds.width-20, height: 200.00)
        }
        
        
    }
     // MARK: - OpenShare&EditView
    
    func shareTextImageAndURL(_ sharingText: String?, sharingImage: UIImage?, sharingURL: URL?) {
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
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func showEditView(_ totalTextField : NSArray)  {
        
    let  mainBGView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        mainBGView.tag = 400
        mainBGView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(mainBGView)
        
    
     editPopupView = UIView(frame: CGRect(x: 10, y: (self.view.frame.height/2)-80, width: self.view.bounds.width-20, height: 200.00));
     editPopupView.backgroundColor = UIColor.white
     editPopupView.layer.cornerRadius = 2
     mainBGView.addSubview(editPopupView)
        if recordObject.recordType == "I" || recordObject.recordType == "D"{
            editPopupView.frame = CGRect(x: 10, y: (self.view.frame.height/2)-60, width: self.view.bounds.width-20, height: 160.00)
        }
    let xPos : CGFloat = 5.0
    var yPos : CGFloat = 10.0
    for i in (0..<totalTextField.count) {
    let label = BaseUIController().ALabelFrame(CGRect(x: xPos , y: yPos , width: 60, height: 30), withString: totalTextField[i] as! String)as! UILabel
        label.font = UIFont().regularMediumFont
    editPopupView.addSubview(label)
    
    let textField = BaseUIController().ATextFiedlFrame(CGRect(x: xPos + 70 , y: yPos , width: editPopupView.frame.width - (xPos + 80) , height: 30 ), withPlaceHolder: "")as! UITextField
    textField.borderStyle = .roundedRect
    textField.textAlignment = .left
    textField.delegate = self
    textField.tag = 200 + i
    editPopupView.addSubview(textField)
    yPos += 50
    }
    
    let btnSave = BaseUIController().AButtonFrame(CGRect(x: 5, y: editPopupView.frame.height - 35 ,width:editPopupView.frame.width - 10 , height: 30), withButtonTital: "SAVE RECORD DETAILS")as! UIButton
    btnSave.layer.borderWidth = 2.0
    btnSave.addTarget(self, action: #selector(self.btnSaveOnClick(_:)), for: .touchUpInside)
    btnSave.titleLabel?.font = UIFont().regularMediumFont
    btnSave.layer.borderColor = UIColor.black.cgColor
    editPopupView.addSubview(btnSave)
        
    
        // add tapgesture on view
    let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PDFViewerViewController.tappedOnBGView(_:)))
        tapped.numberOfTapsRequired = 1
        mainBGView.addGestureRecognizer(tapped)

        let dateString = recordObject.reportDate
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let date = df.date(from: dateString)
        if let unwrappedDate = date {
            datePickerView.setDate(unwrappedDate, animated: false)
        }
        
        // add tag on TextFieldDelegate 
        if totalTextField.count == 3 {
            txtValue_1 = editPopupView.viewWithTag(200) as! UITextField
            txtValue_2 = editPopupView.viewWithTag(201) as! UITextField
            txtValue_3 = editPopupView.viewWithTag(202) as! UITextField
            txtValue_3.text = recordObject.reportDate
            addToolBar(txtValue_3)
            self.OpenDatePicker(txtValue_3)

        }else{
            txtValue_1 = editPopupView.viewWithTag(200) as! UITextField
            txtValue_2 = editPopupView.viewWithTag(201) as! UITextField
            txtValue_2.text = recordObject.reportDate
            addToolBar(txtValue_2)
            self.OpenDatePicker(txtValue_2)

        }
        
        if recordObject.recordType == "R" {
            // Record
            txtValue_1.text = recordObject.reportLabName
            txtValue_2.text = recordObject.reportTestName
            
        }else if(recordObject.recordType == "P"){
            // Prescription
            txtValue_1.text = recordObject.doctorName
            txtValue_2.text = recordObject.diseaseName
            
        }else if(recordObject.recordType == "I"){
            txtValue_1.text = recordObject.diseaseName
            //Invoice
            
        }else{
            //Diet Charts
           txtValue_1.text = recordObject.dietitianName
            print(recordObject.dietitianName)
            
        }
        
    }
    
    func openPDFPopup()  {
        
        let  mainBGView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.window!.frame.width, height: self.view.window!.frame.height))
        mainBGView.tag = 405
        mainBGView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.window! .addSubview(mainBGView)
        pdfPopupView = UIView(frame: CGRect(x: 10, y:(self.view.window!.frame.height/2 - (50)), width: self.view.window!.frame.width - 20, height: 100.00));
        pdfPopupView.backgroundColor = UIColor.white
        pdfPopupView.layer.cornerRadius = 2.0
        mainBGView.addSubview(pdfPopupView)
        var yPos:CGFloat = 10
        
        let btnShareLink = BaseUIController().AButtonFrame(CGRect(x: 10, y: yPos, width: mainBGView.frame.width - 20, height: 35), withButtonTital: "Share link")as! UIButton
        btnShareLink.contentHorizontalAlignment = .left
        btnShareLink.titleLabel?.font = UIFont().mediumFont
        btnShareLink.addTarget(self, action: #selector(self.btnShareLinkOnClick(_:)), for: .touchUpInside)
        pdfPopupView.addSubview(btnShareLink)
        yPos += 10 + 35
        let btnSharePdf = BaseUIController().AButtonFrame(CGRect(x: 10, y: yPos, width: mainBGView.frame.width - 20, height: 35), withButtonTital: "Share pdf")as! UIButton
        btnSharePdf.contentHorizontalAlignment = .left
        btnSharePdf.titleLabel?.font = UIFont().mediumFont
        btnSharePdf.addTarget(self, action: #selector(self.btnSharePdfOnClikc(_:)), for: .touchUpInside)
        pdfPopupView.addSubview(btnSharePdf)
        // add tapgesture on view
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnBGView2(_:)))
        tapped.numberOfTapsRequired = 1
        mainBGView.addGestureRecognizer(tapped)
        
    }

    //MARK: -  laodDataFromDatabase
    func loadDataFromDataBase()  {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
      //  arrReportData = NSMutableArray()
        let recordType = recordObject.recordType
        
        
        do {
            if recordObject.recordId == "0" {
                
            }else{
                
            }
            let rs = try database.executeQuery(String(format:"select * from recordDetails where (dataBaseId = %@ OR  RecordId = '%@') and RecordType = '%@'",selectedDatabaseID,selectedDatabaseID,recordType), values: nil)
           // print(String(format:"select * from recordDetails where (dataBaseId = %@  RecordId = '%@') and RecordType = '%@'",selectedDatabaseID,selectedDatabaseID,recordType))
            
            while rs.next() {
                recordObject = HealthInfo()
                recordObject.memberId = rs.string(forColumn: "MemberId")
                recordObject.dataBaseId = rs.string(forColumn: "DataBaseId")
                recordObject.reportDate = rs.string(forColumn: "RecordDate")
                recordObject.dietitianName = rs.string(forColumn: "DietitianName")
                recordObject.PDFDataString = rs.string(forColumn: "RecordString")
                recordObject.recordLink = rs.string(forColumn: "RecordLink")
                recordObject.reportLabName = rs.string(forColumn: "RecordLabName")
                recordObject.reportTestName = rs.string(forColumn: "RecordTestName")
                recordObject.doctorName = rs.string(forColumn: "DoctorName")
                recordObject.recordId = rs.string(forColumn: "RecordId")
               // recordObject.syncStatus = rs.stringForColumn("SyncStatus")
                recordObject.recordType = rs.string(forColumn: "RecordType")
                recordObject.diseaseName = rs.string(forColumn: "RecordDisease")
//                arrReportData!.addObject(recordObj)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        self.createLayout(0)
    }
    func getMemberPhoto(_ memberId : String) -> String {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        let familyMemberObj = MyFamilyInfo()
        do {
            let rs = try database.executeQuery(String(format:"select * from MyFamily where MemberId = '%@'",memberId), values: nil)
            while rs.next() {
                familyMemberObj.memberPhoto = rs.string(forColumn: "MemberPhoto")
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        return familyMemberObj.memberPhoto
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
        txtValue_3.text = dateFormatter.string(from: sender.date)
        print(dateFormatter.string(from: sender.date))
    }
    func loadMyReport(_ recored_Id : String , record_Type : String)  {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let allParameters = ["recordId":recored_Id, "recordType":record_Type]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetMyReportResult" ,methodname: "GetMyReport", className: self)
        }
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
     //  print(allResponse)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                if allResponse is String &&  allResponse as! String == "error" {
                    
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    self.activityIndicator?.stop()
                }
                else if allResponse is String &&  allResponse as! String == "" {
                    self.present(BaseUIController().showAlertView("PDF not Found"), animated: true, completion: nil)
                    self.activityIndicator?.stop()
                }else{
                    let arrResponseArray = allResponse as! NSArray
                    let linkUrl = (arrResponseArray[0] as AnyObject).value(forKey: "recordlink")as! String
                     self.urlString = linkUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    
                    let requestObj = URLRequest(url: URL(string: self.urlString)!);
                    self.PDFWebView.loadRequest(requestObj)
                    self.activityIndicator?.stop()
                }
            });
        });
        
    }

    
    
}
