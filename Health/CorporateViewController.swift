//
//  CorporateViewController.swift
//  Stetho
//
//  Created by HW-Anil on 1/3/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class CorporateViewController: UIViewController,UIPickerViewDelegate ,UIPickerViewDataSource {
    var maleImageView: UIImageView = UIImageView()
    var femaleImageView: UIImageView = UIImageView()
    var btnMale: UIButton = UIButton()
    var btnFemale: UIButton = UIButton()
    var selectedGender: String = "M"
    var activeTextField = UITextField()
    let datePickerView  : UIDatePicker = UIDatePicker()
    var txtFirstName = UITextField()
    var txtLastName = UITextField()
    var txtDOB = UITextField()
    var txtMobileNo = UITextField()
    var txtPersonal_EmailId = UITextField()
    var txtOfficial_EmailId = UITextField()
    var txtDepartment = UITextField()
    var txtCompanyName = UITextField()
    
    var txtPackage = UITextField()
    var scrollView = UIScrollView()
    var activityIndicator : ProgressViewController?
    var selectedSegIndex = "0"
    var departmentPicker : UIPickerView = UIPickerView()
    var arrDepartmentList = NSArray()
    var departmentId = ""
    var isComingfromCheckinBarCode : Bool?
    var departmentIndex:Int = 0
    
    
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    
//MARK: lifeCycleDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        FBEventClass.logEvent("Corporate Profile")
        
        if let _ = UserDefaults.standard.value(forKey: "department")as? NSArray {
            arrDepartmentList = UserDefaults.standard.value(forKey: "department")as! NSArray
        }else{
            arrDepartmentList = []
        }
//        arrDepartmentList = UserDefaults.standard.value(forKey: "department")as? NSMutableArray
//        if arrDepartmentList == nil{
//            arrDepartmentList = []
//        }
        

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.init(red: (235.0/255.0), green: (236.0/255.0), blue: (236.0/255.0), alpha: 1)
        self.createLayout()
        
        /*
        if arrDepartmentList.count > 0{
//            txtDepartment.text = arrDepartmentList[departmentIndex] as? String
            donePressed()
        }
         */
        
        // show & hide keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        // add activity on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        
        
        txtPersonal_EmailId.keyboardType = .emailAddress
        txtOfficial_EmailId.keyboardType = .emailAddress
        txtFirstName.returnKeyType = .next
        txtLastName.returnKeyType = .next
        txtOfficial_EmailId.returnKeyType = .next
        txtPersonal_EmailId.returnKeyType = .next
        
        txtFirstName.autocorrectionType = .no
        txtLastName.autocorrectionType = .no
        txtMobileNo.autocorrectionType = .no
        txtPersonal_EmailId.autocorrectionType = .no
        txtOfficial_EmailId.autocorrectionType = .no
        txtFirstName.autocapitalizationType = .allCharacters
        txtLastName.autocapitalizationType = .allCharacters
        
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;
        
    }
    override func viewWillAppear(_ animated: Bool) {
       
        self.navigationController!.navigationBar.topItem!.title = "Back"
        self.title = "CORPORATE CHECKIN"
         self.navigationController?.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
//        let editUpdate = UIImage(named: "edit_update")?.imageWithRenderingMode(.AlwaysOriginal)
//        let editReload = UIImage(named: "edit_reload")?.imageWithRenderingMode(.AlwaysOriginal)
//
        
    }
    
    func barButtonBackClick(_ button : UIButton)  {
        if isComingfromCheckinBarCode == true{
           appdelegate.loadMainview()
        }else{
        exit(0)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func createLayout() {
        
        let lblCompanyName = BaseUIController().ALabelFrame(CGRect(x: 0, y: 64 + 15, width: self.view.frame.width, height: 30), withString: String(format: "%@%@",KWELCOME_COP_NAME, GlobalInfo.sharedInfo.getValuefromDefault(KCOPERATE_NAME) as! String))as! UILabel

       // let lblCompanyName = BaseUIController().ALabelFrame(CGRectMake(0, 64 + 15, self.view.frame.width, 30), withString: "HINDUSTAN WELLNESS Pvt. Ltd.")as! UILabel
        lblCompanyName.textAlignment = .center
        lblCompanyName.textColor = KRED_COLOR
        lblCompanyName.font = UIFont(name: "Roboto-Light", size: 20)
       // lblCompanyName.font = UIFont.boldSystemFontOfSize(14)
        self.view.addSubview(lblCompanyName)
        
        scrollView = UIScrollView.init(frame: CGRect(x: 5, y: 124, width: self.view.frame.width - 10, height: UIScreen.main.bounds.height - 164))
        scrollView.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        
        var xPos:CGFloat = 10
        var yPos:CGFloat = 10
        
        let lblEmployeeDetails = BaseUIController().ALabelFrame(CGRect(x: xPos, y: yPos, width: scrollView.frame.width, height: 20), withString: KPROVIDE_CUST_DETAILS)as! UILabel
        lblEmployeeDetails.textAlignment = .left
        lblEmployeeDetails.font = UIFont(name: "Roboto-Light", size: 19.0)
        //lblEmployeeDetails.font = UIFont().regularMediumFont
        scrollView.addSubview(lblEmployeeDetails)
        
        yPos += 20 + 10
        
        var arrLableName : [String]!
        var iconeName : [String]!
        if isComingfromCheckinBarCode == true{
            arrLableName = ["First Name" ,"Last Name","Date of Birth","", "Mobile Number", "Personal Email Id","Official Email Id", "Company Name", "Department","","Package Name"]
            iconeName = ["corp_name_icon.png" , "corp_name_icon.png","corp_date_icon.png", "", "corp_mobile_icon.png","corp_mail_icon.png","corp_mail_icon.png", "ic_corp_company", "corp_department_icon.png","","corp_package_icon.png"]
            //ic_corp_company
        }else{
            arrLableName = ["First Name" ,"Last Name","Date of Birth","", "Mobile Number", "Personal Email Id","Official Email Id","Department","","Package Name"]
            iconeName = ["corp_name_icon.png" , "corp_name_icon.png","corp_date_icon.png", "", "corp_mobile_icon.png","corp_mail_icon.png","corp_mail_icon.png","corp_department_icon.png","","corp_package_icon.png"]
        }
        
//        var iconeName: [String] = ["corp_name_icon.png" , "corp_name_icon.png","corp_date_icon.png", "", "corp_mobile_icon.png","corp_mail_icon.png","corp_mail_icon.png","corp_department_icon.png","","corp_package_icon.png"]
        
        if isComingfromCheckinBarCode == true {
            for i in (0..<arrLableName.count) {
                
                if (i == 0 || i == 1 || i == 2  || i == 4 || i == 5 || i == 6 || i == 7 || i == 8 || i == 10) {
                    
                    let textField = BaseUIController().ATextFiedlFrame(CGRect(x:xPos , y: yPos ,width: scrollView.frame.width - 20 , height: 40 ), withPlaceHolder: arrLableName[i])as! UITextField
                    textField.tag = 200 + i
                    textField.delegate = self
                    textField.textAlignment = .left
                    textField.borderStyle = .line
                    textField.layer.borderWidth = 1
                    textField.layer.borderColor =  UIColor.init(red: (242.0/255.0), green: (237.0/255.0), blue: (237.0/255.0), alpha: 1.0).cgColor
                    
                    textField.leftViewMode = UITextFieldViewMode.always
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                    let image = UIImage(named: iconeName[i])
                    imageView.image = image
                    textField.leftView = imageView
                    scrollView.addSubview(textField)
                    yPos += 40 + 10;
                }
                if i == 3 {
                    let lblGender:UILabel = BaseUIController().ALabelFrame(CGRect(x: 10 , y: yPos + 10, width: 100, height: 21), withString: "Gender :")as! UILabel
                    lblGender.font = UIFont(name: "Roboto-Light", size: 18.0)//.regularMediumFont
                    scrollView.addSubview(lblGender)
                    
                    
                    btnMale = BaseUIController().AButtonFrame(CGRect (x: 80
                        , y: lblGender.frame.origin.y, width: 80, height: 25), withButtonTital: "Male")as! UIButton
                    btnMale.titleLabel?.font = UIFont(name: "Roboto-Light", size: 18.0)//.regularMediumFont
                    btnMale.addTarget(self, action: #selector(self.btnMaleOnClick(_:)), for: .touchUpInside)
                    scrollView.addSubview(btnMale)
                    maleImageView = BaseUIController().AImageViewFrame(CGRect (x: 0 , y: 5 , width: 15 , height: 15), withImageName: "")as! UIImageView
                    maleImageView.image = UIImage(named: "selectedradio_icon")
                    btnMale.isSelected = true
                    //  selectedGender = "M"
                    btnMale.addSubview(maleImageView)
                    
                    btnFemale = BaseUIController().AButtonFrame(CGRect (x: btnMale.frame.origin.x+90 , y: lblGender.frame.origin.y, width: 90, height: 25), withButtonTital: "Female")as! UIButton
                    btnFemale.titleLabel?.font = UIFont(name: "Roboto-Light", size: 18.0)//.regularMediumFont
                    btnFemale.addTarget(self, action: #selector(self.btnFeMaleOnClick(_:)), for: .touchUpInside)
                    scrollView.addSubview(btnFemale)
                    femaleImageView = BaseUIController().AImageViewFrame(CGRect (x: 0 , y: 5 , width: 15 , height: 15), withImageName: "")as! UIImageView
                    femaleImageView.image = UIImage(named: "nonselectedradio_icon")
                    btnFemale.addSubview(femaleImageView)
                    xPos = 10
                    yPos += 40 + 10;
                    
                }
                
                if i == 9 {
                    
                    let segmentController = UISegmentedControl.init(frame: CGRect(x: xPos, y: yPos, width: scrollView.frame.width - 20, height: 40))
                    // yourSegControl.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "YourFont", size: 18.0)! ], forState: .Normal)
                    segmentController.setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Roboto-Light", size: 18.0)!], for: UIControlState())
                    
                    //segment frame size
                    segmentController.insertSegment(withTitle: "OFFICE", at: 0, animated: true)
                    //inserting new segment at index 0
                    segmentController.insertSegment(withTitle: "HOME", at: 1, animated: true)
                    //inserting new segment at index 1
                    segmentController.backgroundColor = UIColor.white
                    //setting the background color of the segment controller
                    segmentController.selectedSegmentIndex = 0
                    //setting the segment which is initially selected
                    let subViewOfSegment: UIView = segmentController.subviews[0] as UIView
                    subViewOfSegment.tintColor = UIColor.init(red: (191.0/255.0), green: (46.0/255.0), blue: (42.0/255.0), alpha: 1.0)
                    segmentController.tintColor = UIColor.init(red: (191.0/255.0), green: (46.0/255.0), blue: (42.0/255.0), alpha: 1.0)
                    
                    segmentController.addTarget(self, action: #selector(CorporateViewController.segment(_:)), for: UIControlEvents.valueChanged)
                    //calling the selector method
                    scrollView.addSubview(segmentController)
                    xPos = 10
                    yPos += 40 + 10;
                    
                }
            }
            txtFirstName = scrollView.viewWithTag(200)as! UITextField
            txtFirstName.font = UIFont(name: "Roboto-Light", size: 17)
            txtLastName = scrollView.viewWithTag(201)as! UITextField
            txtLastName.font = UIFont(name: "Roboto-Light", size: 17)
            txtDOB = scrollView.viewWithTag(202)as! UITextField
            txtDOB.font = UIFont(name: "Roboto-Light", size: 17)
            
            txtMobileNo = scrollView.viewWithTag(204)as! UITextField
            txtMobileNo.keyboardType = .numberPad
            txtMobileNo.font = UIFont(name: "Roboto-Light", size: 17)
            
            txtPersonal_EmailId = scrollView.viewWithTag(205)as! UITextField
            txtPersonal_EmailId.font = UIFont(name: "Roboto-Light", size: 17)
            
            txtOfficial_EmailId = scrollView.viewWithTag(206) as! UITextField
            txtOfficial_EmailId.font = UIFont(name: "Roboto-Light", size: 17)
            
            txtCompanyName = scrollView.viewWithTag(207) as! UITextField
            txtCompanyName.font = UIFont(name: "Roboto-Light", size: 17)
            
            txtCompanyName.text = GlobalInfo.sharedInfo.getValuefromDefault(KCOPERATE_NAME) as? String
            txtCompanyName.textColor = UIColor.lightGray
            txtCompanyName.isUserInteractionEnabled = false

           let editButton =  UIButton(frame: CGRect(x: (txtCompanyName.frame.size.width + xPos) - 40, y: txtCompanyName.frame.origin.y + 5, width: 30, height: 30))
           editButton.setImage(UIImage(named:"edit_update"), for: UIControlState())
            editButton.addTarget(self, action: #selector(CorporateViewController.editCompanyNameButtonClicked(_:)), for: .touchUpInside)
            editButton.isSelected = false
            
//            let companyEditImageView = UIImageView(frame: CGRectMake((txtCompanyName.frame.size.width + xPos) - 40, txtCompanyName.frame.origin.y + 5, 30, 30))
//            companyEditImageView.image = UIImage(named: "corp_edit_icon")
//            companyEditImageView.tintColor = KRED_COLORColor()
            scrollView.addSubview(editButton)

            
            txtDepartment = scrollView.viewWithTag(208) as! UITextField
            txtDepartment.font = UIFont(name: "Roboto-Light", size: 17)
            txtPackage = scrollView.viewWithTag(210)as! UITextField
            txtPackage.font = UIFont(name: "Roboto-Light", size: 17)
            
            txtMobileNo.isUserInteractionEnabled = true
            txtMobileNo.font = UIFont(name: "Roboto-Light", size: 17)
            addToolBar(txtMobileNo)
        }else{
            for i in (0..<arrLableName.count) {
                
                if (i == 0 || i == 1 || i == 2  || i == 4 || i == 5 || i == 6 || i == 7 || i == 9) {
                    
                    let textField = BaseUIController().ATextFiedlFrame(CGRect(x:xPos , y: yPos ,width: scrollView.frame.width - 20 , height: 40 ), withPlaceHolder: arrLableName[i])as! UITextField
                    textField.tag = 200 + i
                    textField.delegate = self
                    textField.textAlignment = .left
                    textField.borderStyle = .line
                    textField.layer.borderWidth = 1
                    textField.layer.borderColor =  UIColor.init(red: (242.0/255.0), green: (237.0/255.0), blue: (237.0/255.0), alpha: 1.0).cgColor
                    
                    textField.leftViewMode = UITextFieldViewMode.always
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                    let image = UIImage(named: iconeName[i])
                    imageView.image = image
                    textField.leftView = imageView
                    scrollView.addSubview(textField)
                    yPos += 40 + 10;
                }
                if i == 3 {
                    let lblGender:UILabel = BaseUIController().ALabelFrame(CGRect(x: 10 , y: yPos, width: 100, height: 21), withString: "Gender :")as! UILabel
                    lblGender.font = UIFont().regularMediumFont
                    scrollView.addSubview(lblGender)
                    
                    btnMale = BaseUIController().AButtonFrame(CGRect (x: 80
                        , y: yPos, width: 80, height: 25), withButtonTital: "Male")as! UIButton
                    btnMale.titleLabel?.font = UIFont().regularMediumFont
                    btnMale.addTarget(self, action: #selector(self.btnMaleOnClick(_:)), for: .touchUpInside)
                    scrollView.addSubview(btnMale)
                    maleImageView = BaseUIController().AImageViewFrame(CGRect (x: 0 , y: 5 , width: 15 , height: 15), withImageName: "")as! UIImageView
                    maleImageView.image = UIImage(named: "selectedradio_icon")
                    btnMale.isSelected = true
                    //  selectedGender = "M"
                    btnMale.addSubview(maleImageView)
                    
                    btnFemale = BaseUIController().AButtonFrame(CGRect (x: btnMale.frame.origin.x+90 , y: yPos, width: 90, height: 25), withButtonTital: "Female")as! UIButton
                    btnFemale.titleLabel?.font = UIFont().regularMediumFont
                    btnFemale.addTarget(self, action: #selector(self.btnFeMaleOnClick(_:)), for: .touchUpInside)
                    scrollView.addSubview(btnFemale)
                    femaleImageView = BaseUIController().AImageViewFrame(CGRect (x: 0 , y: 5 , width: 15 , height: 15), withImageName: "")as! UIImageView
                    femaleImageView.image = UIImage(named: "nonselectedradio_icon")
                    btnFemale.addSubview(femaleImageView)
                    xPos = 10
                    yPos += 40 + 10;
                    
                }
                
                if i == 8 {
                    
                    let segmentController = UISegmentedControl.init(frame: CGRect(x: xPos, y: yPos, width: scrollView.frame.width - 20, height: 40))
                    // yourSegControl.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "YourFont", size: 18.0)! ], forState: .Normal)
                    segmentController.setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Roboto-Light", size: 18.0)!], for: UIControlState())
                    
                    //segment frame size
                    segmentController.insertSegment(withTitle: "OFFICE", at: 0, animated: true)
                    //inserting new segment at index 0
                    segmentController.insertSegment(withTitle: "HOME", at: 1, animated: true)
                    //inserting new segment at index 1
                    segmentController.backgroundColor = UIColor.white
                    //setting the background color of the segment controller
                    segmentController.selectedSegmentIndex = 0
                    //setting the segment which is initially selected
                    let subViewOfSegment: UIView = segmentController.subviews[0] as UIView
                    subViewOfSegment.tintColor = UIColor.init(red: (191.0/255.0), green: (46.0/255.0), blue: (42.0/255.0), alpha: 1.0)
                    segmentController.tintColor = UIColor.init(red: (191.0/255.0), green: (46.0/255.0), blue: (42.0/255.0), alpha: 1.0)
                    
                    segmentController.addTarget(self, action: #selector(CorporateViewController.segment(_:)), for: UIControlEvents.valueChanged)
                    //calling the selector method
                    scrollView.addSubview(segmentController)
                    xPos = 10
                    yPos += 40 + 10;
                    
                }
            }
            txtFirstName = scrollView.viewWithTag(200)as! UITextField
            txtFirstName.font = UIFont(name: "Roboto-Light", size: 17)
            txtLastName = scrollView.viewWithTag(201)as! UITextField
            txtLastName.font = UIFont(name: "Roboto-Light", size: 17)
            txtDOB = scrollView.viewWithTag(202)as! UITextField
            txtDOB.font = UIFont(name: "Roboto-Light", size: 17)
            
            txtMobileNo = scrollView.viewWithTag(204)as! UITextField
            txtMobileNo.font = UIFont(name: "Roboto-Light", size: 17)
            
            txtPersonal_EmailId = scrollView.viewWithTag(205)as! UITextField
            txtPersonal_EmailId.font = UIFont(name: "Roboto-Light", size: 17)
            
            txtOfficial_EmailId = scrollView.viewWithTag(206) as! UITextField
            txtOfficial_EmailId.font = UIFont(name: "Roboto-Light", size: 17)
            
            txtDepartment = scrollView.viewWithTag(207) as! UITextField
            txtDepartment.font = UIFont(name: "Roboto-Light", size: 17)
            
            txtPackage = scrollView.viewWithTag(209)as! UITextField
            txtPackage.font = UIFont(name: "Roboto-Light", size: 17)
            
            txtMobileNo.isUserInteractionEnabled = false
            txtMobileNo.font = UIFont(name: "Roboto-Light", size: 17)
        }
        
        txtDepartment.tintColor = UIColor.clear
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: yPos + 20)
        
        let btnCheckIn = BaseUIController().AButtonFrame(CGRect(x: 0, y: UIScreen.main.bounds.height - 40, width: UIScreen.main.bounds.width, height: 40), withButtonTital: "PROCEED")as! UIButton
        btnCheckIn.backgroundColor = UIColor.init(red: (191.0/255.0), green: (46.0/255.0), blue: (42.0/255.0), alpha: 1.0)
        btnCheckIn.addTarget(self, action: #selector(btnCheckInOnClick), for: .touchUpInside)
        btnCheckIn.setTitleColor(UIColor.white, for: UIControlState())
        self.view.addSubview(btnCheckIn)
        
        
        
//        txtFirstName = scrollView.viewWithTag(200)as! UITextField
//        txtFirstName.font = UIFont(name: "Roboto-Light", size: 17)
//        txtLastName = scrollView.viewWithTag(201)as! UITextField
//        txtLastName.font = UIFont(name: "Roboto-Light", size: 17)
//        txtDOB = scrollView.viewWithTag(202)as! UITextField
//        txtDOB.font = UIFont(name: "Roboto-Light", size: 17)
//
//        txtMobileNo = scrollView.viewWithTag(204)as! UITextField
//        txtMobileNo.font = UIFont(name: "Roboto-Light", size: 17)
//
//        txtPersonal_EmailId = scrollView.viewWithTag(205)as! UITextField
//        txtPersonal_EmailId.font = UIFont(name: "Roboto-Light", size: 17)
//
//        txtOfficial_EmailId = scrollView.viewWithTag(206) as! UITextField
//        txtOfficial_EmailId.font = UIFont(name: "Roboto-Light", size: 17)
//
//        txtDepartment = scrollView.viewWithTag(207) as! UITextField
//        txtDepartment.font = UIFont(name: "Roboto-Light", size: 17)
//
//        txtPackage = scrollView.viewWithTag(209)as! UITextField
//        txtPackage.font = UIFont(name: "Roboto-Light", size: 17)
//
//        txtMobileNo.userInteractionEnabled = false
//        txtMobileNo.font = UIFont(name: "Roboto-Light", size: 17)

        txtPackage.isUserInteractionEnabled = false

        
        
        addToolBar(txtDOB)
        OpenDatePicker(txtDOB)
        
        departmentPicker.dataSource = self
        departmentPicker.delegate = self
        txtDepartment.inputView = departmentPicker
        addToolBarToCustomTextfield(txtDepartment)
        
        txtPackage.text =  UserDefaults.standard.value(forKey: "PACK_NAME")as? String
        txtMobileNo.text =  UserDefaults.standard.value(forKey: "mobileNo") as? String
    }
    func segment(_ sender : UISegmentedControl)  {
        
        if sender.selectedSegmentIndex == 0 {
             selectedSegIndex = "0"
           
        }else if(sender.selectedSegmentIndex == 1){
             selectedSegIndex = "1"
        }
        
    }
    
    //MARK: PickerViewDelegate
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return arrDepartmentList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        // dictDepartment.setValue(josnResponseData[i].valueForKey("department_name")as! String, forKey: "departmentName")
      //  dictDepartment.setValue(josnResponseData[i].valueForKey("cwd_id")as! String, forKey: "department_id")
       
            return (arrDepartmentList[row] as AnyObject).value(forKey: "departmentName") as? String
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        departmentIndex = row
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        pickerLabel.text = (arrDepartmentList[row] as AnyObject).value(forKey: "departmentName") as? String
        pickerLabel.font = UIFont().mediumFont
        
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 30;
    }
    
    
    //MARK: Make Custom Toolbar
    
    func addToolBarToCustomTextfield(_ textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        //toolBar.barTintColor = UIColor .redColor()
        // toolBar.translucent = false
        // toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.tintColor = KRED_COLOR
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(CorporateViewController.donePressedCustom))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CorporateViewController.cancelPressedCustom))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        // toolBar.backgroundColor = UIColor .redColor()
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    func donePressedCustom(){
        //  view.endEditing(true)
        txtDepartment.text = "\((arrDepartmentList[departmentIndex] as AnyObject).value(forKey: "departmentName") as! String)"
        departmentId = (arrDepartmentList[departmentIndex] as AnyObject).value(forKey: "department_id") as! String
        appdelegate.corporateAllDetailsDict.setValue(departmentId, forKey: "departmentID")
        if view.window != nil{
            view.window!.endEditing(true)
        }
    }
    
    func cancelPressedCustom(){
        
        // view.endEditing(true) // or do something
        view.window!.endEditing(true)
    }
    
    //MARK: textFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        
        switch textField {
        case txtFirstName:
            txtLastName.becomeFirstResponder()
        case txtLastName:
            if isComingfromCheckinBarCode == true{
                txtMobileNo.becomeFirstResponder()
            }else{
                txtOfficial_EmailId.becomeFirstResponder()
            }
        case txtMobileNo:
            txtPersonal_EmailId.becomeFirstResponder()
        case txtPersonal_EmailId:
            txtOfficial_EmailId.becomeFirstResponder()
        default:
            break
        }
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.activeTextField = textField
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        if textField == txtFirstName || textField == txtLastName {
            if string.rangeOfCharacter(from: .whitespacesAndNewlines, options: .regularExpression) != nil{
                return false
            }

        }
        else if (textField == txtMobileNo) {
            if string.isEmpty == true{
//                textField.textColor
//                var truncated = textField.text.substringToIndex(name.endIndex.predecessor())
              return true
            }
            var startString = ""
            if (textField.text != nil)
            {
                startString += textField.text!
            }
            startString += string
            let limitNumber = startString.characters.count
//            if limitNumber <= 10{
//                textField.text = startString
//            }
            return limitNumber <= 10
        }
        return true
    }
    
    // MARK: - KeyboardShow&Hide
    func keyboardWillShow(_ notification:Notification){
        if activeTextField == txtPersonal_EmailId ||  activeTextField ==  txtOfficial_EmailId || activeTextField ==  txtDepartment || activeTextField == txtCompanyName || activeTextField == txtMobileNo{
            scrollView.frame = CGRect(x: 0 , y: -80 , width: scrollView.frame.width , height: scrollView.frame.height)
        }else{
            scrollView.frame = CGRect(x: 0 , y: 124 , width: scrollView.frame.width , height: scrollView.frame.height )
            
        }
    }
    
    func keyboardWillHide(_ notification:Notification){
        
        if activeTextField == txtPersonal_EmailId ||  activeTextField ==  txtOfficial_EmailId || activeTextField ==  txtDepartment || activeTextField == txtCompanyName || activeTextField == txtMobileNo {
            scrollView.frame = CGRect(x: 0 , y: 124 , width: scrollView.frame.width , height: scrollView.frame.height )
        }else{
            scrollView.frame = CGRect(x: 0 , y: 124 , width: scrollView.frame.width , height: scrollView.frame.height )
            
        }
    }
    //MARK: - DatePicker
    func OpenDatePicker(_ sender: UITextField) {
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.maximumDate = Date()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.handleDatePicker(_:)), for: UIControlEvents.valueChanged)
        
    }
    
    func handleDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        txtDOB.text = dateFormatter.string(from: sender.date)
        print(dateFormatter.string(from: sender.date))
    }
    


    //MARK: - btnOnclickMethod
    /*
     let theImageView = UIImageView(image: UIImage(named:"foo")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
     theImageView.tintColor = KRED_COLORColor()
     */
    func editCompanyNameButtonClicked(_ button: UIButton){
        if button.isSelected == false{
            button.isSelected = true
            
            button.setImage(UIImage(named: "edit_reload"), for: UIControlState())
            txtCompanyName.isUserInteractionEnabled = true
            txtCompanyName.textColor = UIColor.darkGray
//            txtCompanyName.text = GlobalInfo.sharedInfo.getValuefromDefault(KCOPERATE_NAME) as? String
            txtCompanyName.becomeFirstResponder()
        }else{
            button.isSelected = false
//            button.setImage(UIImage(named: "corp_edit_icon"), forState: .Normal)
            
            button.setImage(UIImage(named:"edit_update"), for: UIControlState())
            txtCompanyName.isUserInteractionEnabled = false
            txtCompanyName.textColor = UIColor.lightGray
            txtCompanyName.text = GlobalInfo.sharedInfo.getValuefromDefault(KCOPERATE_NAME) as? String
            txtCompanyName.resignFirstResponder()
        }
        
    }
    
    func btnMaleOnClick(_ button: UIButton)  {
        if btnMale.isSelected  == false {
            maleImageView.image = UIImage(named: "selectedradio_icon")
            femaleImageView.image = UIImage(named: "nonselectedradio_icon")
            btnFemale.isSelected = false
            
        }else{
            btnFemale.isSelected = false
        }
        selectedGender = "M"
    }
    func btnFeMaleOnClick(_ button: UIButton){
        if button.isSelected == false {
            femaleImageView.image = UIImage(named: "selectedradio_icon")
            maleImageView.image = UIImage(named: "nonselectedradio_icon")
            btnMale.isSelected = false
        }else{
            btnMale.isSelected = false
        }
        selectedGender = "F"
    }
    func btnCheckInOnClick()  {
        
        if (txtFirstName.text?.isEmpty == true) {
            self.present(BaseUIController().showAlertView("Please Enter First Name!"), animated: true, completion: nil)
        }
        else if (txtLastName.text?.isEmpty == true) {
            
            self.present(BaseUIController().showAlertView("Please Enter Last Name!"), animated: true, completion: nil)
        }else if(txtDOB.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please Enter DOB!"), animated: true, completion: nil)
        }
        else if (selectedGender.isEmpty == true){
            
            self.present(BaseUIController().showAlertView("Please Select Gender!"), animated: true, completion: nil)
        }else if(txtPersonal_EmailId.text?.isEmpty == true){
            
            self.present(BaseUIController().showAlertView("Please Enter Personal Email Id!"), animated: true, completion: nil)
            
        }
        else if((txtPersonal_EmailId.text?.isEmpty == false) && (MyProfileViewController().validateEmail(txtPersonal_EmailId.text!) == false)){
            
                self.present(BaseUIController().showAlertView("Please Enter Valid Personal Email Id!"), animated: true, completion: nil)
        }
        else if(txtOfficial_EmailId.text?.isEmpty == true){
            
            self.present(BaseUIController().showAlertView("Please Enter Official Email Id!"), animated: true, completion: nil)
            
        }
        else if((txtOfficial_EmailId.text?.isEmpty == false) && (MyProfileViewController().validateEmail(txtOfficial_EmailId.text!) == false)){
            
                self.present(BaseUIController().showAlertView("Please Enter Valid Official Email Id!"), animated: true, completion: nil)
        }
        else if txtDepartment.text?.isEmpty == true{
            self.present(BaseUIController().showAlertView("Please Select Department!"), animated: true, completion: nil)
        }
        else if txtMobileNo.text?.isEmpty == true || txtMobileNo.text?.characters.count < 10 || GlobalInfo.sharedInfo.phoneNumberValidation(txtMobileNo.text!) == false {
            self.present(BaseUIController().showAlertView("Please Enter Valid Mobile Number!"), animated: true, completion: nil)
        }
        else if isComingfromCheckinBarCode == true && txtCompanyName.text?.isEmpty == true {
            self.present(BaseUIController().showAlertView("Please Enter Valid Company Name!"), animated: true, completion: nil)

        }
        else{
                    appdelegate.corporateAllDetailsDict.setValue(txtFirstName.text!, forKey: "firstName")
                    appdelegate.corporateAllDetailsDict.setValue(txtLastName.text!, forKey: "lastName")
                    appdelegate.corporateAllDetailsDict.setValue(txtMobileNo.text!, forKey: "mobileno")
                    appdelegate.corporateAllDetailsDict.setValue(txtPersonal_EmailId.text!, forKey: "pemail")
                    appdelegate.corporateAllDetailsDict.setValue(txtOfficial_EmailId.text!, forKey: "oemail")
                    appdelegate.corporateAllDetailsDict.setValue(txtDOB.text!, forKey: "dob")
                    appdelegate.corporateAllDetailsDict.setValue(selectedGender, forKey: "gender")
                    appdelegate.corporateAllDetailsDict.setValue(selectedSegIndex, forKey: "selectedaddress")
                    self.sendToNextViewController()
            }
        }
    
 
    
  
    func sendToNextViewController()  {
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        let medicalHistoryFirstVC = storyboard1.instantiateViewController(withIdentifier: "UserDetailsViewController")as! UserDetailsViewController
        medicalHistoryFirstVC.memberId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
        medicalHistoryFirstVC.memberName = txtFirstName.text!
        if UserDefaults.standard.bool(forKey: "iscorporate") == true{
            medicalHistoryFirstVC.isFromCorporate = "yes"
        }else{
            medicalHistoryFirstVC.isFromCorporate = "no"
        }
//        medicalHistoryFirstVC.isFromCorporate = NSUserDefaults.standardUserDefaults().boolForKey("iscorporate")//setBool(false, forKey: "iscorporate")//"yes"
        medicalHistoryFirstVC.isComingfromCheckinBarCode = isComingfromCheckinBarCode
        self.navigationController?.pushViewController(medicalHistoryFirstVC, animated: true)
    }



}
