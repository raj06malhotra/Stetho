  //
//  AddRecordsViewController.swift
//  Health
//
//  Created by HW-Anil on 9/3/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class AddRecordsViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    //MARK: VariableDeclaration

    var scrollView = UIScrollView()
    var tableView: UITableView = UITableView()
    var btnSelectMemberRecord = UIButton()
    var btnAddFamilyMember = UIButton()
    var btnDone = UIButton()
    var btnAddMemeber = UIButton()
    var arrTotalImages = NSArray()
    var txtDate = UITextField()
    var txtAddFamilyMember = UITextField()
    var  arrMyFamilyRecordList = NSMutableArray()
    var bgColor = UIColor.init(red: (242.0/255.0), green: (242.0/255.0), blue: (242.0/255.0), alpha: 1.0)
    let arrImageName :[String] = ["report.png","prescription.png","invoice1.png","report.png"]
    let arrSelectedImageName : [String] = ["report_selected.png","prescription_selected.png","invoice1_selected.png","report_selected.png"]
    var recordType = ""
    var memberid =  ""
    var createdDate = ""
    var isComingFrom = ""
    var selectedTag = 0   // (report = 0 , Prescription = 1 , Invoice = 2 , DietChart = 4)
    var userName = String()
    var arrRecordTypeFirstCharcter : Array = ["R" , "P" , "I" , "D"]
    
   
    
    
//MARK: ViewLifeCycleMethod
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "ADD RECORD"

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        if isComingFrom == "reportView" {
            self.navigationController?.navigationBar.isTranslucent = true
            memberid = UserDefaults.standard.value(forKey: "selectedMemberId")as! String
        }else{
            memberid = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
        }
        self.loadMyFamilyData()
        self.createALayout()
    }
    override func viewWillDisappear(_ animated: Bool) {
        if isComingFrom == "reportView" {
            self.navigationController?.navigationBar.isTranslucent = true
        }
    }
    //MARK: CreateALayout
    func createALayout()  {
        
        btnDone = BaseUIController().AButtonFrame(CGRect(x: 0, y: 0, width: 60, height: 44), withButtonTital: "Done")as! UIButton
        btnDone.setTitleColor(UIColor.red, for: UIControlState())
        btnDone.addTarget(self, action: #selector(self.btnDoneOnClick(_:)), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem(customView: btnDone)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        
        scrollView.frame = self.view.bounds
        self.view.addSubview(scrollView)
        var yPos :CGFloat = 10
        
        for i in 0..<arrTotalImages.count {
            let imgView = BaseUIController().AImageViewFrame(CGRect(x: 10, y: yPos, width: self.view.frame.width - 20,  height: 400), withImageName: "")as! UIImageView
            imgView.image = arrTotalImages[i] as? UIImage
            imgView.layer.cornerRadius = 4
            imgView.layer.masksToBounds = true
            scrollView.addSubview(imgView)
            yPos += 400 + 50
 
        }
       
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: yPos)
         yPos = self.view.frame.height - 40
        
        txtDate = BaseUIController().ATextFiedlFrame(CGRect(x: 10, y: yPos , width: self.view.frame.width - 20, height: 35), withPlaceHolder: "") as! UITextField
        txtDate.borderStyle = .none
        txtDate.layer.cornerRadius = 4
        txtDate.textAlignment = .left
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, YYYY"
        let date = Date()
        createdDate = dateFormatter.string(from: date)
        let multiColorTextAttributeString = self.changeTextWithMultipleColor("  Record created on  ", redString: dateFormatter.string(from: date))
        
        txtDate.attributedText = multiColorTextAttributeString
        txtDate.backgroundColor = bgColor
        openDatePicker(txtDate)
        addToolBar(txtDate)
        self.view.addSubview(txtDate)
        
        yPos -= 110
        let recordsView = UIView.init(frame: CGRect(x: 10, y: yPos, width: self.view.frame.width - 20, height: 100))
        recordsView.backgroundColor = UIColor.white
        recordsView.layer.cornerRadius = 4
        recordsView.layer.masksToBounds = true
        self.view.addSubview(recordsView)
        
        let lblTypeofRecord = BaseUIController().ALabelFrame(CGRect(x: 0, y: 0, width: recordsView.frame.width, height: 30), withString: "  Type of Record")as! UILabel
        lblTypeofRecord.font = UIFont().mediumFont
        
        lblTypeofRecord.backgroundColor = bgColor
        recordsView.addSubview(lblTypeofRecord)
        var xPos: CGFloat =  0 //(recordsView.frame.width - 160)/5
        
        let arrReocrdName = ["Report" ,"Prescription","Invoice","DietChat"]
        
        
        for i in 0..<arrImageName.count {
            let button = BaseUIController().AButtonFrame(CGRect(x: xPos, y: 35, width: recordsView.frame.width/4, height: 65), withButtonTital: "")as! UIButton
            button.tag = 101 + i
            // set selected button

            button.addTarget(self, action: #selector(self.btnSelectTypeofRecordOnClick(_:)), for: .touchUpInside)
            recordsView.addSubview(button)
            let imageView = BaseUIController().AImageViewFrame(CGRect(x: (button.frame.width - 35)/2 , y: 5, width: 35, height: 35), withImageName: "")as! UIImageView
            imageView.tag = 201 + i
            button.addSubview(imageView)
            let lblRecordName = BaseUIController().ALabelFrame(CGRect(x: 0, y: 45, width: button.frame.width, height: 20), withString: "")as! UILabel
            lblRecordName.textAlignment = .center
            lblRecordName.tag = 301 + i
            lblRecordName.font = UIFont().mediumFont
            lblRecordName.text = arrReocrdName[i]
            button.addSubview(lblRecordName)
            //set selected record
            if i == selectedTag {
                imageView.image = UIImage(named: arrSelectedImageName[i])
                lblRecordName.textColor = UIColor.red
                button.isSelected = true
                recordType = arrRecordTypeFirstCharcter[i]
            }else{
                imageView.image = UIImage(named: arrImageName[i])
            }
            
            xPos += recordsView.frame.width/4
        }
        
        yPos -= 40
        
        
        // featch login user name
       
        let multipleAttributeText = self.changeTextWithMultipleColor("  Record for ", redString: userName)
        btnSelectMemberRecord = BaseUIController().AButtonFrame(CGRect(x: 10, y: yPos, width: self.view.frame.width - 20, height: 35), withButtonTital: String(format: ""))as! UIButton
        btnSelectMemberRecord.setAttributedTitle(multipleAttributeText, for: UIControlState())
        btnSelectMemberRecord.layer.cornerRadius = 4
        btnSelectMemberRecord.backgroundColor = bgColor
        btnSelectMemberRecord.contentHorizontalAlignment = .left
        btnSelectMemberRecord.layer.masksToBounds = true
        btnSelectMemberRecord.addTarget(self, action: #selector(self.btnSelectMemberRecordOnClick(_:)), for: .touchUpInside)
        self.view.addSubview(btnSelectMemberRecord)
        // add family Member button
        btnAddFamilyMember = BaseUIController().AButtonFrame(CGRect(x: 5, y: yPos, width: self.view.frame.width - 10, height: 35), withButtonTital: "  Add family Member")as! UIButton
        btnAddFamilyMember.backgroundColor = bgColor
        btnAddFamilyMember.layer.cornerRadius = 4
        btnAddFamilyMember.titleLabel?.font = UIFont().largeFont
        btnAddFamilyMember.contentHorizontalAlignment =  .left
        btnAddFamilyMember.layer.masksToBounds = true
        btnAddFamilyMember.addTarget(self, action: #selector(self.btnAddFamilyMemberOnClick(_:)), for: .touchUpInside)
        btnAddFamilyMember.isHidden = true
        self.view.addSubview(btnAddFamilyMember)
        //Add textField for add Famiily member 
        txtAddFamilyMember = BaseUIController().ATextFiedlFrame(CGRect(x: 5, y: yPos, width: self.view.frame.width - 100, height: 35), withPlaceHolder: "  Add Family Member")as! UITextField
        txtAddFamilyMember.isHidden = true
        txtAddFamilyMember.delegate = self
        txtAddFamilyMember.textAlignment = .left
        txtAddFamilyMember.backgroundColor = bgColor
        self.view.addSubview(txtAddFamilyMember)
        //add Member button
        btnAddMemeber = BaseUIController().AButtonFrame(CGRect(x: self.view.frame.width - 50 , y: yPos + 3, width: 30, height: 30), withButtonTital: "")as! UIButton
        btnAddMemeber.isHidden = true
        btnAddMemeber.setImage(UIImage(named: "add_family_icon.png"), for: UIControlState())
        btnAddMemeber.addTarget(self, action: #selector(self.btnAddMemberOnClick(_:)), for: .touchUpInside)
        self.view.addSubview(btnAddMemeber)
        
        yPos -= 90
        
        // create A tableView
        tableView = UITableView(frame:CGRect(x: 5, y: yPos,width: (UIScreen.main.bounds.width)-10, height: 90))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        self.view.addSubview(tableView)
        
        
    }
    //MARK: - TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return arrMyFamilyRecordList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
       // let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        var familyMemberObj = MyFamilyInfo()
        familyMemberObj = arrMyFamilyRecordList[(indexPath as NSIndexPath).row] as! MyFamilyInfo
        cell.textLabel?.text = familyMemberObj.memberName
        cell.textLabel?.font = UIFont().mediumFont
        if  (familyMemberObj.memberId == memberid ) {
            cell.accessoryType = .checkmark
            
        }
       
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var familyMemberObj = MyFamilyInfo()
        familyMemberObj = arrMyFamilyRecordList[(indexPath as NSIndexPath).row] as! MyFamilyInfo
        memberid = familyMemberObj.memberId
        let name = familyMemberObj.memberName
        let multipleColorTextAttribute = self.changeTextWithMultipleColor("  Record for ", redString: name)
        btnSelectMemberRecord.setAttributedTitle(multipleColorTextAttribute, for: UIControlState())
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  30;
    }
    //MARK: TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        return textField.resignFirstResponder()
    }
    
    //MARK: ButtonOnclick
    func btnSelectTypeofRecordOnClick(_ button : UIButton)  {
        for i in 0..<arrSelectedImageName.count {
            let selectedImage = self.view.viewWithTag(201 + i)as! UIImageView
            let selectedLabel = self.view.viewWithTag(301 + i)as! UILabel
            if button.tag == 101 + i {
                selectedImage.image = UIImage(named: arrSelectedImageName[i])
                selectedLabel.textColor = UIColor.red
                //set selected record
                selectedTag = button.tag - 101
                switch button.tag {
                case 101:
                    recordType = "R"
                case 102:
                     recordType = "P"
                case 103:
                     recordType = "I"
                case 104:
                     recordType = "D"
                default: break
                }
            }else{
                selectedImage.image = UIImage(named: arrImageName[i])
                selectedLabel.textColor = UIColor.black

            }
        }
    }
   
    func btnSelectMemberRecordOnClick(_ button : UIButton)  {
      //  CGRectMake(5, yPos, self.view.frame.width - 10, 35)
        if button.isSelected == false {
           btnSelectMemberRecord.frame = CGRect(x: 5, y: button.frame.origin.y - 125, width: self.view.frame.width - 10, height: 35)
           btnSelectMemberRecord.isSelected = true
           tableView.isHidden = false
           
           btnAddFamilyMember.isHidden = false
        }else{
           btnSelectMemberRecord.frame = CGRect(x: 5, y: button.frame.origin.y + 125 , width: self.view.frame.width - 10, height: 35)
           btnSelectMemberRecord.isSelected = false
           tableView.isHidden = true
           btnAddFamilyMember.isHidden = true
           btnAddMemeber.isHidden = true
           txtAddFamilyMember.isHidden = true
        }
    }
    func btnAddFamilyMemberOnClick(_ button : UIButton)  {
        btnAddFamilyMember.isHidden = true
        txtAddFamilyMember.isHidden = false
        btnAddMemeber.isHidden = false
    }
    func btnAddMemberOnClick(_ button : UIButton)  {
        btnAddFamilyMember.isHidden = false
        txtAddFamilyMember.isHidden = true
        btnAddMemeber.isHidden = true
    }
    func btnDoneOnClick(_ button : UIButton)  {
        // not using poptoviewcontroller becasuse some time not getting HomeTapswipeController 
            self.saveRecord()
            let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
            let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
            homeTapSwipeVC.identifires = "MY RECORDS"
            homeTapSwipeVC.isComingFromAddRecordViewWithMemberId = memberid
            homeTapSwipeVC.currentSelectedTapIndex = selectedTag
            self.navigationController?.pushViewController(homeTapSwipeVC, animated: true)
    }
    //MARK: - DatePicker
    func openDatePicker(_ sender: UITextField) {
        
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.maximumDate = Date()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(PDFViewerViewController.handleDatePicker(_:)), for: UIControlEvents.valueChanged)
        
    }
    
    func handleDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.dateFormat = "dd MMMM, yyyy"
        let multiColorTextAttributeString = self.changeTextWithMultipleColor("  Record created on  ", redString: dateFormatter.string(from: sender.date))
        txtDate.attributedText = multiColorTextAttributeString//String(format: "created date is %@",dateFormatter.stringFromDate(sender.date))
        createdDate = dateFormatter.string(from: sender.date)
    }
    // MARK: - DataBaseOperation
    
    func loadMyFamilyData()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        arrMyFamilyRecordList = NSMutableArray()
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
                // get Memeber name
                if familyMemberObj.memberId == memberid {
                     userName = familyMemberObj.memberName
                }
                arrMyFamilyRecordList.add(familyMemberObj)
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        tableView.reloadData()
    }
    
    // insert data in data base
    internal  func saveRecord()  {
        //        for i in (0..<arrTotalImages.count) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        do {
            //chnage date formate
            let dateFormatter = DateFormatter()
             dateFormatter.dateFormat = "dd MMMM, yyyy"
            let date = dateFormatter.date(from: createdDate)!
            dateFormatter.dateFormat = "YYYY-MM-dd"
            createdDate = dateFormatter.string(from: date)
            let pdfData =  self.createPDF()//self.convertImageToPDF(arrTotalImages) //= NSData.convertImageToPDF(arrTotalImages[i]as! UIImage)
            let imageSize: Int = pdfData.length
            print(Double(imageSize/1024))
            
            let base64String = pdfData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
          //  print(base64String)
//            let encrypt = AESEncryptionDecryption().EncryptAstring(base64String as String)
//            let decrypt = AESEncryptionDecryption().DecryptAstring(encrypt as String)
//            print(decrypt)
            
            let randomRecordId = self.randomStringWithLength(8)
            let pdfRecordString = base64String
            try database.executeUpdate("insert into RecordDetails (DataBaseId , MemberId ,RecordId, RecordDate , RecordLabName , RecordTestName , DoctorName, DietitianName, RecordDisease ,RecordString ,RecordLink,ServerToLocalSyncStatus,LocalToServerSyncStatus, RecordType,isDeleted) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", values: [0 , memberid ,randomRecordId, createdDate,"", "" ,"" ,"","",pdfRecordString,"","N","N",recordType,"N"])
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        HomeViewController().getNonSyncDataFromDtabase()
        //  }
    }

    // MARK: - KeyboardShow&Hide
    func keyboardWillShow(_ notification:Notification){
        
       self.view.frame = CGRect(x: 0, y: -100, width: self.view.frame.width, height: self.view.frame.height)
    }
    
    func keyboardWillHide(_ notification:Notification){
      self.view.frame = CGRect(x: 0, y: 0 , width: self.view.frame.width, height: self.view.frame.height)
        
    }
    //MARK: GenerateRandomNumber
    func randomStringWithLength (_ len : Int) -> NSString {
        
        let letters : NSString = "0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for i in 0..<len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
            print(i)
        }
        
        return randomString
    }
    //MARK: convetImageToPDF
    func convertImageToPDF(_ allImages: NSArray) -> NSMutableData {
        
   /*     let topImage = self.scaleImage(arrTotalImages[0]as! UIImage, toSize: CGSizeMake(250, 250))
        let bottomImage = self.scaleImage(arrTotalImages[1]as! UIImage, toSize: CGSizeMake(250, 250))
        
        let size = CGSizeMake(topImage.size.width, topImage.size.height + bottomImage.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        [topImage.drawInRect(CGRectMake(0,0,size.width, topImage.size.height))];
        [bottomImage.drawInRect(CGRectMake(0,topImage.size.height + 50 ,size.width, bottomImage.size.height))];
        
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext() */
        
        //set finalImage to IBOulet UIImageView
        
        var myimage1  = UIImage()
        var finalMixedImage = UIImage()
        var pdfData = NSMutableData()  //= NSData.convertImageToPDF(arrTotalImages[i]as! UIImage)
        // resize image
        for i in (0..<arrTotalImages.count) {
            
            if arrTotalImages.count > 1 {
                
            if i == 0 {
                let compresedImage = DrawerViewController().resizeImage(arrTotalImages[i]as! UIImage, targetSize: CGSize(width: 350.0, height: 350.0))
                myimage1 = compresedImage
            }
            
            if i == 1 {
                let compresedImage = DrawerViewController().resizeImage(arrTotalImages[i]as! UIImage, targetSize: CGSize(width: 350.0, height: 350.0))
                
                let myimage2 = compresedImage
                finalMixedImage = getMixedImg(myimage1, image2: myimage2)
            }
            if i > 1 {
                   let compresedImage = DrawerViewController().resizeImage(arrTotalImages[i]as! UIImage, targetSize: CGSize(width: 350.0, height: 350.0))
                  let currentImages = compresedImage
                 finalMixedImage = getMixedImg(finalMixedImage, image2: currentImages)
                
            }
                  }
            else{
              // finalMixedImage = self.scaleImage(arrTotalImages[i]as! UIImage, toSize: CGSizeMake(250, 250))
               finalMixedImage = DrawerViewController().resizeImage(arrTotalImages[i]as! UIImage, targetSize: CGSize(width: 350.0, height: 350.0))
            }
     
    
        }
        
         let image: UIImage = finalMixedImage  // 1.
            let imageData = UIImageJPEGRepresentation(finalMixedImage, 0.9)
            let pdfSize = image.size // 2.
            pdfData = NSMutableData(capacity: (imageData?.count)!)! // 3.
            UIGraphicsBeginPDFContextToData(pdfData, CGRect(origin: CGPoint(), size: pdfSize), nil)
            let context = UIGraphicsGetCurrentContext()!
            UIGraphicsBeginPDFPage()
            // required so the UIImage can render into our context
            UIGraphicsPushContext(context)
            image.draw(at: CGPoint())
            UIGraphicsPopContext()
            UIGraphicsEndPDFContext()
        return pdfData
}
    
    func createPDF() -> NSMutableData {
        let pdfData = NSMutableData()
        // 4. Create PDF context and draw
//        let img : UIImage = arrTotalImages[0] as! UIImage
//        print(img.size.height)
//        print(img.size.width)
        
            var image: UIImage = resizeImage(arrTotalImages[0]as! UIImage, targetSize: CGSize(width: 600.0, height: 600.0))
        //DrawerViewController().resizeImage(arrTotalImages[0]as! UIImage, targetSize: CGSizeMake(350.0, 350.0))
          //  image.resizeWith2(72)
           // image.lowestQualityJPEGNSData
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(origin: CGPoint(), size: image.size), nil)
         for i in (0..<arrTotalImages.count) {
            let imageTemp = arrTotalImages[i] as! UIImage
            image = resizeImage(arrTotalImages[i]as! UIImage, targetSize: CGSize(width: imageTemp.size.width, height: imageTemp.size.height)) //DrawerViewController().resizeImage(arrTotalImages[i]as! UIImage, targetSize: CGSizeMake(350.0, 350.0))
            //image.resizeWith2(72)
          //  image.lowestQualityJPEGNSData
            let context = UIGraphicsGetCurrentContext()!
            UIGraphicsBeginPDFPage()
            // required so the UIImage can render into our context
            UIGraphicsPushContext(context)
            image.draw(at: CGPoint())
            UIGraphicsPopContext()
         }
        UIGraphicsEndPDFContext();
        // 5. return PDF file
        return pdfData
    }
    
 internal   func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        //UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
       let  imgCompressed = UIImage(data: UIImageJPEGRepresentation(image, 0.3)!)
    
        imgCompressed?.draw(in: rect)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
    
        return imgCompressed!//newImage!
    }
    
    func getMixedImg(_ image1: UIImage, image2: UIImage) -> UIImage {
        
        let size = CGSize(width: image1.size.width, height: image1.size.height + image2.size.height + 50)
        
        UIGraphicsBeginImageContext(size)
        
        image1.draw(in: CGRect(x: 0,y: 0,width: size.width, height: image1.size.height))
        image2.draw(in: CGRect(x: 0,y: image1.size.height + 50 ,width: size.width, height: image2.size.height))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage!
    }
    
    
    //MARK: resizeImage
    func scaleImage(_ image: UIImage, toSize newSize: CGSize) -> (UIImage) {
        let newRect = CGRect(x: 0,y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context!.interpolationQuality = .high
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        context?.concatenate(flipVertical)
        context?.draw(image.cgImage!, in: newRect)
        let newImage = UIImage(cgImage: (context?.makeImage()!)!)
        UIGraphicsEndImageContext()
        return newImage
    }
    //MARK: chageWihtMultipleTextAttributeColor
    func changeTextWithMultipleColor(_ blackString : String , redString : String) -> NSMutableAttributedString {
      
        let attrs1      = [NSFontAttributeName: UIFont().smallFont, NSForegroundColorAttributeName:UIColor.black]
        let attrs2      = [NSFontAttributeName: UIFont().mediumFont, NSForegroundColorAttributeName: UIColor.red]
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: blackString , attributes:  attrs1))
        attributedText.append(NSAttributedString(string: redString, attributes: attrs2))
        return attributedText
    }
}
//MARK: createExtension
extension UIImage {
    var uncompressedPNGData: Data      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: Data { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: Data    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: Data  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: Data     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:Data   { return UIImageJPEGRepresentation(self, 0.0)!  }
}
extension UIFont {
   
    var largeFont: UIFont { return UIFont (name: "Roboto-Light", size: 16)! }
    var veryLargeFont: UIFont { return UIFont (name: "Roboto-Light", size: 20)! }
    var mediumFont: UIFont { return UIFont (name: "Roboto-Light", size: 14)! }
    var regularMediumFont: UIFont { return UIFont (name: "Roboto-Regular", size: 14)! }
    var smallFont: UIFont  { return UIFont (name: "Roboto-Light", size: 12)!}
    var verySmallFont: UIFont  { return UIFont (name: "Roboto-Light", size: 10)!}
    
}
  
  
/*
let defaultResolution: Int = 72
extension NSData {
    
    class func convertImageToPDF(image: UIImage) -> NSData? {
        return convertImageToPDF(image, resolution: 96)
    }
    
    class func convertImageToPDF(image: UIImage, resolution: Double) -> NSData? {
        return convertImageToPDF(image, horizontalResolution: resolution, verticalResolution: resolution)
    }
    
    class func convertImageToPDF(image: UIImage, horizontalResolution: Double, verticalResolution: Double) -> NSData? {
        
        if horizontalResolution <= 0 || verticalResolution <= 0 {
            return nil;
        }
        
        let pageWidth: Double = Double(image.size.width) * Double(image.scale) * Double(defaultResolution) / horizontalResolution
        let pageHeight: Double = Double(image.size.height) * Double(image.scale) * Double(defaultResolution) / verticalResolution
        
        let pdfFile: NSMutableData = NSMutableData()
        
      //  let pdfConsumer: CGDataConsumerRef = CGDataConsumerCreateWithCFData(pdfFile as CFMutableDataRef)!
        let pdfConsumer: CGDataConsumerRef = CGDataConsumerCreateWithCFData(pdfFile as CFMutableDataRef)!
    
        var mediaBox: CGRect = CGRectMake(0, 0, CGFloat(pageWidth), CGFloat(pageHeight))
        let pdfContext: CGContextRef = CGPDFContextCreate(pdfConsumer, &mediaBox, nil)!
        
        
        CGContextBeginPage(pdfContext, &mediaBox)
        CGContextDrawImage(pdfContext, mediaBox, image.CGImage)
        
        CGContextEndPage(pdfContext)
    
        return pdfFile
    }
    
    class func convertImageToPDF(image: UIImage, resolution: Double, maxBoundRect: CGRect, pageSize: CGSize) -> NSData? {
        
        if resolution <= 0 {
            return nil
        }
        
        var imageWidth: Double = Double(image.size.width) * Double(image.scale) * Double(defaultResolution) / resolution
        var imageHeight: Double = Double(image.size.height) * Double(image.scale) * Double(defaultResolution) / resolution
        
        let sx: Double = imageWidth / Double(maxBoundRect.size.width)
        let sy: Double = imageHeight / Double(maxBoundRect.size.height)
        
        if sx > 1 || sy > 1 {
            let maxScale: Double = sx > sy ? sx : sy
            imageWidth = imageWidth / maxScale
            imageHeight = imageHeight / maxScale
        }
        
        let imageBox: CGRect = CGRectMake(maxBoundRect.origin.x, maxBoundRect.origin.y + maxBoundRect.size.height - CGFloat(imageHeight), CGFloat(imageWidth), CGFloat(imageHeight));
        
        let pdfFile: NSMutableData = NSMutableData()
        
        let pdfConsumer: CGDataConsumerRef = CGDataConsumerCreateWithCFData(pdfFile as CFMutableDataRef)!
        
        var mediaBox: CGRect = CGRectMake(0, 0, pageSize.width, pageSize.height);
        
        let pdfContext: CGContextRef = CGPDFContextCreate(pdfConsumer, &mediaBox, nil)!
        
        CGContextBeginPage(pdfContext, &mediaBox)
        CGContextDrawImage(pdfContext, imageBox, image.CGImage)
        CGContextEndPage(pdfContext)
        
        return pdfFile
    }
    
    
} */

extension UIImage {
    func resizeWith(_ percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWith2(_ width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

