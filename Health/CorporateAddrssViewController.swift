                                                                                                                                                           //
//  CorporateAddrssViewController.swift
//  Stetho
//
//  Created by HW-Anil on 1/3/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit

class CorporateAddrssViewController: UIViewController , UIPickerViewDelegate ,UIPickerViewDataSource ,serverTaskComplete ,GooglePlacesAutocompleteDelegate {
    //MARK: variableDecleration
    var scrollView = UIScrollView()
    var txtPin1 = UITextField()
    var txtPin2 = UITextField()
    var txtPin3 = UITextField()
    var txtPin4 = UITextField()
    var txtPin5 = UITextField()
    var txtPin6 = UITextField()
    var activeTextField = UITextField()
    fileprivate var activityIndicator : ProgressViewController?
    
    var txtAddressLine1 = UITextField()
    var txtAddressLine2 = UITextField()
    var txtDate = UITextField()
    var txtTime = UITextField()
    var txtLandMark = UITextField()
    var txtLocality = UITextField()
    var txtCity = UITextField()
    var cityPickerView : UIPickerView = UIPickerView()
    var timePickerView : UIPickerView = UIPickerView()
    let datePickerView  : UIDatePicker = UIDatePicker()
    var arrTime = ["04:00-04:30", "04:30-05:00" ,"05:00-05:30" , "05:30-06:00" , "06:00-06:30" , "06:30-07:00" , "07:00-07:30" , "07:30-08:00" , "08:00-08:30", "08:30-09:00" , "09:00-09:30" , "09:30-10:00" , "10:00-10:30" ,"10:30-11:00" , "11:00-11:30" , "11:30-12:00" , "12:00-12:30" , "13:00-13:30" , "13:30-14:00" , "14:00-14:30" , "14:30-15:00" , "15:00-15:30" , "15:30-16:00" , "16:00-16:30" , "16:30-17:00" , "17:00-17:30" , "17:00-18:00"]

    var arrCityName = ["Delhi" , "New Delhi" , "Faridabad", "Ballabhgarh", "Gurgaon" , "Ghaziabad" , "Noida" ,"Greater Noida", "Meerut", "Sonipat","Bahadurgarh"]
    
    var f_Name = ""
    var l_Name = ""
    var  _dob = ""
    var _gender = ""
    var  mobileNo = ""
    var p_Email_id = ""
    var o_Email_id = ""
    var latitude = ""
    var longitude = ""
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var gpaViewController = GooglePlacesAutocomplete()
    let appDelegate = AppDelegate.getAppDelegate()
    var isComingfromCheckinBarCode:Bool?

    
    
//MARK: viewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.init(red: (235.0/255.0), green: (236.0/255.0), blue: (236.0/255.0), alpha: 1)
        self.createALayout()
        // show & hide keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        // add activity on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.navigationBar.topItem!.title = "Back"
        self.title = KPICKUP_ADD
        self.navigationController?.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: layOutDesign
    func createALayout()  {
        
        let lblCompanyName = BaseUIController().ALabelFrame(CGRect(x: 0, y: 64 + 15, width: self.view.frame.width, height: 0), withString: "HINDUSTAN WELLNESS Pvt. Ltd.")as! UILabel
        lblCompanyName.textAlignment = .center
        lblCompanyName.textColor = KRED_COLOR
        lblCompanyName.font = UIFont.boldSystemFont(ofSize: 14)
        //self.view.addSubview(lblCompanyName)
        
       scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIScreen.main.bounds.height))
        scrollView.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        
        var xPos:CGFloat = 20
        var yPos:CGFloat = 10
        
        let lblEmployeeDetails = BaseUIController().ALabelFrame(CGRect(x: 10, y: yPos + 5, width: self.view.frame.width, height: 20), withString: KHOMEADD_DETAILS)as! UILabel
        lblEmployeeDetails.textAlignment = .left
        lblEmployeeDetails.font =  UIFont(name: "Roboto-Light", size: 24.0)// UIFont().regularMediumFont
        scrollView.addSubview(lblEmployeeDetails)
        yPos += 10 + 20
        
//        let lblLine = BaseUIController().ALabelFrame(CGRectMake(0, yPos, scrollView.frame.width, 1), withString: "")as! UILabel
//        lblLine.backgroundColor = UIColor.init(red: (242.0/255.0), green: (237.0/255.0), blue: (237.0/255.0), alpha: 1.0)
//        scrollView.addSubview(lblLine)
        
        yPos += 10
        
        let lblPinCode = BaseUIController().ALabelFrame(CGRect(x: 10, y: yPos, width: 60, height: 30), withString: KPINCODE)as! UILabel
        lblPinCode.font =  UIFont(name: "Roboto-Light", size: 18.0)//UIFont().regularMediumFont
        scrollView.addSubview(lblPinCode)
        xPos = 80
        
        let _width: CGFloat = (scrollView.frame.width - (xPos + 20 + 50 ))/6
        
        for i in (0..<6) {
            
            let textField = BaseUIController().ATextFiedlFrame(CGRect(x: xPos , y: yPos ,width: _width , height: 30 ), withPlaceHolder: "")as! UITextField
            textField.borderStyle = .line
            textField.layer.borderWidth = 1
            textField.layer.borderColor =  UIColor.init(red: (242.0/255.0), green: (237.0/255.0), blue: (237.0/255.0), alpha: 1.0).cgColor
            textField.font = UIFont(name: "Roboto-Light", size: 17.0)
            scrollView.addSubview(textField)
            textField.tag = 100 + i
            textField.delegate = self
            textField.keyboardType = .numberPad
            addToolBar(textField)
            
            xPos += _width + 10
            
        }
        yPos += 45
        xPos = 10
        
        var labelName: [String] = ["Address Line 1 ", KADDRESS2, "Landmark ", KCITY, KLOCALITY ,KSELECT_DATE,KSELECT_TIME]
        
        var iconeName: [String] = ["corp_address_icon.png", "corp_address_icon.png", "corp_address_icon.png", "corp_address_icon.png", "corp_address_icon.png" ,"corp_date_icon.png","corp_time_icon.png"]
        
        for i in (0..<labelName.count) {

            let textField = BaseUIController().ATextFiedlFrame(CGRect(x:xPos , y: yPos ,width: scrollView.frame.width-20 , height: 40 ), withPlaceHolder:labelName[i])as! UITextField
            textField.tag = 200 + i
            textField.delegate = self
            textField.textAlignment = .left
            textField.borderStyle = .line
            textField.layer.borderWidth = 1
            textField.layer.borderColor =  UIColor.init(red: (242.0/255.0), green: (237.0/255.0), blue: (237.0/255.0), alpha: 1.0).cgColor
            let imageName = iconeName[i]
            
            textField.leftViewMode = UITextFieldViewMode.always
            textField.font = UIFont(name: "Roboto-Light", size: 18.0)
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            let image = UIImage(named: imageName)
            imageView.image = image
            textField.leftView = imageView
            scrollView.addSubview(textField)
            yPos += 40 + 10;
        }
        
        txtPin1 = scrollView.viewWithTag(100) as! UITextField
        txtPin2 = scrollView.viewWithTag(101) as! UITextField
        txtPin3 = scrollView.viewWithTag(102) as! UITextField
        txtPin4 = scrollView.viewWithTag(103) as! UITextField
        txtPin5 = scrollView.viewWithTag(104) as! UITextField
        txtPin6 = scrollView.viewWithTag(105) as! UITextField
        
        txtAddressLine1 = scrollView.viewWithTag(200)as! UITextField
        txtAddressLine2 = scrollView.viewWithTag(201)as! UITextField
        txtLandMark = scrollView.viewWithTag(202)as! UITextField
        txtCity = scrollView.viewWithTag(203)as! UITextField
        txtLocality = scrollView.viewWithTag(204)as! UITextField
        txtDate = scrollView.viewWithTag(205)as! UITextField
        txtTime = scrollView.viewWithTag(206)as! UITextField
        
       let btnSubmit = UIButton(frame: CGRect(x: xPos+5,  y: (txtTime.frame.origin.y + txtTime.frame.size.height + 15), width: UIScreen.main.bounds.width-2*(xPos+5), height: 40))
        btnSubmit.setTitle(KDONE, for: UIControlState())
        btnSubmit.titleLabel?.font = UIFont(name: "Roboto-Light", size: 18.0)
//        let btnSubmit = BaseUIController().AButtonFrame(CGRectMake(xPos+5,  (txtTime.frame.origin.y + txtTime.frame.size.height + 15), UIScreen.mainScreen().bounds.width-(xPos+5), 40), withButtonTital: "SUBMIT")as! UIButton
        btnSubmit.backgroundColor = UIColor.init(red: (191.0/255.0), green: (46.0/255.0), blue: (42.0/255.0), alpha: 1.0)
        btnSubmit.addTarget(self, action: #selector(self.btnSubmitOnClick(_:)), for: .touchUpInside)
        btnSubmit.setTitleColor(UIColor.white, for: UIControlState())
//        self.view.addSubview(btnSubmit)
        scrollView.addSubview(btnSubmit)

        
        
        
        //Add PickerView
        cityPickerView.dataSource = self
        cityPickerView.delegate = self
        txtCity.inputView = cityPickerView
        
        timePickerView.dataSource = self
        timePickerView.delegate = self
        txtTime.inputView = timePickerView
        
        
        addToolBar(txtCity)
        addToolBar(txtDate)
        addToolBar(txtTime)
        
        OpenDatePicker(txtDate)
        
    }
    //MARK: PickerViewDelegate
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if (pickerView == cityPickerView) {
          return arrCityName.count
        }else{
          return arrTime.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == cityPickerView) {
            return arrCityName[row]
        }else{
            return arrTime[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if (pickerView == cityPickerView) {
            txtCity.text = "\(arrCityName[row])"
        }else{
            txtTime.text = "\(arrTime[row])"
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        if (pickerView == cityPickerView) {
             pickerLabel.text = arrCityName[row]
        }else{
             pickerLabel.text = arrTime[row]
        }
        pickerLabel.font = UIFont(name: "Roboto-Light", size: 16.0)//.mediumFont
        
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 30;
    }

    
//MARK: textFieldDelegate
     func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        return textField.resignFirstResponder()
    
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
        
        if(textField == txtLocality){
            gpaViewController = GooglePlacesAutocomplete(
                apiKey: "AIzaSyCoEvSzsfnL5WPUw4WF2KAWmekxkO6qgI8",
                placeType: .address
            )
            
            gpaViewController.placeDelegate = self // Conforms to GooglePlacesAutocompleteDelegate
            
            present(gpaViewController, animated: true, completion: nil)
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        if (textField == txtPin1 || textField == txtPin2 || textField == txtPin3 || textField == txtPin4 || textField == txtPin5 || textField == txtPin6) {
            let maxLength = 1
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if(textField.text?.isEmpty == true || textField.text?.characters.count == 0){
                
                
                if (textField == txtPin1) {
                    if (maxLength == 1) {
                        txtPin1.text = newString as String
                        txtPin2.becomeFirstResponder()
                        return false; // NO because we already updated the text.
                    }
                }
                
                if (textField == txtPin2) {
                    if (maxLength == 1) {
                        txtPin2.text = newString as String
                        txtPin3.becomeFirstResponder()
                        return false;
                    }
                }
                if (textField == txtPin3) {
                    if (maxLength == 1) {
                        txtPin3.text = newString as String
                        txtPin4.becomeFirstResponder()
                        return false;
                    }
                }
                if (textField == txtPin4) {
                    if (maxLength == 1) {
                        txtPin4.text = newString as String
                        txtPin5.becomeFirstResponder()
                        return false;
                    }
                }
                if (textField == txtPin5) {
                    if (maxLength == 1) {
                        txtPin5.text = newString as String
                        txtPin6.becomeFirstResponder()
                        return false;
                    }
                }
            }
            
            return newString.length <= maxLength
        }else{
            let maxLength = 100
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        
    }
    
    //MARK: googlePlaceAutocompleteDelegate
    
    func placesFound(_ places: [Place]) {
        
        // print(places)
        
    }
    
    func placeSelected(_ place: Place) {
        
        print(place)
        place.getDetails { details in
            print(details.name)       // Convenience accessor for name
            print(details.latitude)   // Convenience accessor for latitude
            print(details.longitude)
            // Convenience accessor for longitude
            print(details.raw)
            
            // Complete JSON data (see below)
            self.txtLocality.text = details.name
            self.latitude = String(details.latitude)
            self.longitude = String(details.longitude)
        }
        
        dismiss(animated: false) {
            
            
            
        }
        
    }
    
//    func placesFound(_ places: [Place]) {
//        
//        // print(places)
//        
//    }
//    func placeSelected(_ place: Place) {
//        
//        print(place)
//        place.getDetails { details in
//            print(details.name)       // Convenience accessor for name
//            print(details.latitude)   // Convenience accessor for latitude
//            print(details.longitude)
//            // Convenience accessor for longitude
//            print(details.raw)
//            
//            // Complete JSON data (see below)
//            self.txtLocality.text = details.name
//            self.latitude = String(details.latitude)
//            self.longitude = String(details.longitude)
//        }
//        
//        dismiss(animated: false) {
//           
//            
//            
//        }
//        
//    }
    
    func placeViewClosed() {
        
        gpaViewController.dismiss(animated: true) {
           
            
        }
        // self.navigationController?.popViewControllerAnimated(true)
        
        
    }

    // MARK: - KeyboardShow&Hide
    func keyboardWillShow(_ notification:Notification){
        if activeTextField == txtTime || activeTextField == txtDate || activeTextField == txtLocality || activeTextField == txtCity {
             scrollView.frame = CGRect(x: 0 , y: -80 , width: scrollView.frame.width , height: scrollView.frame.height)
        }else{
            scrollView.frame = CGRect(x: 0 , y: 0 , width: scrollView.frame.width , height: scrollView.frame.height )
        
        }
    }
    
    func keyboardWillHide(_ notification:Notification){
        
        if activeTextField == txtTime || activeTextField == txtDate || activeTextField == txtLocality || activeTextField == txtCity  {
             scrollView.frame = CGRect(x: 0 , y: 0 , width: scrollView.frame.width , height: scrollView.frame.height )
        }else{
            scrollView.frame = CGRect(x: 0 , y: 0 , width: scrollView.frame.width , height: scrollView.frame.height )
        
        }
    }
    //MARK: - DatePicker
    func OpenDatePicker(_ sender: UITextField) {
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.minimumDate = Date()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.handleDatePicker(_:)), for: UIControlEvents.valueChanged)
        
    }
    
    func handleDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        txtDate.text = dateFormatter.string(from: sender.date)
        print(dateFormatter.string(from: sender.date))
    }
    //MARK: callWebservices
    
       func saveAllMedicalHistory()  {
        
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
//            let alcohal = appdelegate.corporateAllDetailsDict.valueForKey("alcohal")as! String
//            let smoke = (appdelegate.corporateAllDetailsDict.valueForKey("smoke")as! String)
            let dob = (appdelegate.corporateAllDetailsDict.value(forKey: "dob")as! String)
            let gender = (appdelegate.corporateAllDetailsDict.value(forKey: "gender")as! String)
            //let cid =  (appdelegate.corporateAllDetailsDict.valueForKey("cid")as! String)
//            let bloodPressureStatus = (appdelegate.corporateAllDetailsDict.valueForKey("bloodPressure")as! String)
//            let bloodGlucose = (appdelegate.corporateAllDetailsDict.valueForKey("bloodGlucose")as! String)
            
            
//            let hypertension : NSMutableString = NSMutableString()
//            hypertension.appendString(appdelegate.corporateAllDetailsDict.valueForKey("hypertensionStatus")as! String)
//            hypertension.appendString(",")
//            hypertension.appendString(appdelegate.corporateAllDetailsDict.valueForKey("fatherHypertensionStatus")as! String)
//            hypertension.appendString(",")
//            hypertension.appendString(appdelegate.corporateAllDetailsDict.valueForKey("motherHypertensionStatus")as! String)
//            let hypertension_status = (hypertension as String)
            
//            let cancer = NSMutableString()
//            cancer.appendString(appdelegate.corporateAllDetailsDict.valueForKey("cancerStatus")as! String)
//            cancer.appendString(",")
//            cancer.appendString(appdelegate.corporateAllDetailsDict.valueForKey("fatherCancerStatus")as! String)
//            cancer.appendString(",")
//            cancer.appendString(appdelegate.corporateAllDetailsDict.valueForKey("motherCancerStatus")as! String)
//            let cancer_status = (cancer as String)
            
//            let cardio = NSMutableString()
//            cardio.appendString(appdelegate.corporateAllDetailsDict.valueForKey("cardioStatus")as! String)
//            cardio.appendString(",")
//            cardio.appendString(appdelegate.corporateAllDetailsDict.valueForKey("fatherCardioStatus")as! String)
//            cardio.appendString(",")
//            cardio.appendString(appdelegate.corporateAllDetailsDict.valueForKey("motherCardioStatus")as! String)
//            let cardio_status = (cardio as String)
            
            
//            let diabetes = NSMutableString()
//            diabetes.appendString("0")
//            diabetes.appendString(",")
//            diabetes.appendString(appdelegate.corporateAllDetailsDict.valueForKey("fatherDiabetesStatus")as! String)
//            diabetes.appendString(",")
//            diabetes.appendString(appdelegate.corporateAllDetailsDict.valueForKey("motherDiabetesStatus")as! String)
//            let diabetes_status = (diabetes as String)
            
            let height = NSMutableString()
            height.append(appdelegate.corporateAllDetailsDict.value(forKey: "heightinfeet")as! String)
            if !(height.isEqual("")) {
                height.append(".")
                height.append(appdelegate.corporateAllDetailsDict.value(forKey: "heightininch")as! String)
            }
            
            
            print(height)
            let heightInFeetandInch = (height as String)
//            let bloodgroup = (appdelegate.corporateAllDetailsDict.valueForKey("bloodgroup")as! String)
//            let exercise = (appdelegate.corporateAllDetailsDict.valueForKey("exercise")as! String)
            let weight = (appdelegate.corporateAllDetailsDict.value(forKey: "weight")as! String)
//            let waist = (appdelegate.corporateAllDetailsDict.valueForKey("waist")as! String)
            
          //  print(appdelegate.corporateAllDetailsDict)
            
            let firstName = (appdelegate.corporateAllDetailsDict.value(forKey: "firstName")as! String)
            let middleName = ("")
            let lastName = (appdelegate.corporateAllDetailsDict.value(forKey: "lastName")as! String)
            
            
            let mobileNumber = (appdelegate.corporateAllDetailsDict.value(forKey: "mobileno")as! String)
            let personal_email = (appdelegate.corporateAllDetailsDict.value(forKey: "pemail")as! String)
            let official_email = (appdelegate.corporateAllDetailsDict.value(forKey: "oemail")as! String)
            
            print(appdelegate.corporateAllDetailsDict.value(forKey: "selectedaddress")as! String)
            
            let isHome = (appdelegate.corporateAllDetailsDict.value(forKey: "selectedaddress")as! String)
            
            
            
            let p_code =  txtPin1.text!+txtPin2.text!+txtPin3.text!+txtPin4.text!+txtPin5.text!+txtPin6.text!
            
            let pincode = (p_code)
            
            let geoAddress = ("")
            let geoLong = (longitude)
            let geoLat = (latitude)
            let address1 = (txtAddressLine1.text!)
            let address2 = (txtAddressLine2.text!)
            
            let landmark = (txtLandMark.text!)
            let city = (txtCity.text!)
            let locality = (txtLocality.text!)
            let pickupDate = (txtDate.text!)
            
            let  newPickupTime = txtTime.text!.components(separatedBy: "-")
            
            let pickupTime = (newPickupTime[0])
            
            let companyId = UserDefaults.standard.value(forKey: "company_id") as! String
//            guard let departmentId = appdelegate.corporateAllDetailsDict.valueForKey("departmentID") as? String else {
//                return ""
//            }
            var departmentId = ""
            if let tempId = appDelegate.corporateAllDetailsDict.value(forKey: "departmentID") {
                departmentId = tempId as! String
            }
//            let departmentId = appdelegate.corporateAllDetailsDict.valueForKey("departmentID")as! String
            print(companyId)
            print(departmentId)
            
            
//            let allParameters3 = ["firstName":appdelegate.corporateAllDetailsDict.valueForKey("firstName")as? String ,"middleName": "","lastName": appdelegate.corporateAllDetailsDict.valueForKey("lastName")as? String,"mobileNumber" : appdelegate.corporateAllDetailsDict.valueForKey("mobileno")as? String , "oEmail": appdelegate.corporateAllDetailsDict.valueForKey("oemail")as? String ,"pEmail": appdelegate.corporateAllDetailsDict.valueForKey("pemail")as? String ,"isHome": "0" , "pincode" : p_code , "geoAddress" : "" , "geoLong" : "" ,"geoLat" : "" ,"address1" : txtAddressLine1.text ,"address2" : "", "landmark" : txtLandMark.text , "city" : txtCity.text , "locality": txtLocality.text, pickupDate : txtDate.text ,"pickupTime" : txtTime.text ,"height":height as String,"weight": appdelegate.corporateAllDetailsDict.valueForKey("weight")as? String,"waist" : appdelegate.corporateAllDetailsDict.valueForKey("waist")as? String , "bloodGroup": appdelegate.corporateAllDetailsDict.valueForKey("bloodgroup")as? String ,"Hypertension": hypertension as String ,"Cancer": cancer as String , "Cardio" : cardio as String , "diabetes" : diabetes as String , "bp" : appdelegate.corporateAllDetailsDict.valueForKey("bloodPressure")as? String ,"smokeFrequency" : appdelegate.corporateAllDetailsDict.valueForKey("smoke")as? String ,"alcoholFrequency" : appdelegate.corporateAllDetailsDict.valueForKey("alcohal")as? String ,"exerciseFrequency" : appdelegate.corporateAllDetailsDict.valueForKey("exercise")as? String, "gender" : appdelegate.corporateAllDetailsDict.valueForKey("gender")as? String , "dob" : appdelegate.corporateAllDetailsDict.valueForKey("dob")as? String , "userId":NSUserDefaults.standardUserDefaults().valueForKey("loginCustomerId")as? String]
//            
//            print(allParameters3)
            let problamsArr = appdelegate.corporateAllDetailsDict.value(forKey: KPROBLEMS_Arr) as! [String]
            let problamDict = appdelegate.corporateAllDetailsDict.value(forKey: KPROBLEMS_DICT)as! [String: String]

            
            var allParameters = [ "firstName" : firstName,
                                  "middleName" : middleName ,
                                  "lastName":lastName ,
                                  "mobileNumber": mobileNumber,
                                  "pEmail": personal_email ,
                                  "oEmail": official_email,
                                  "isHome":isHome,
                                  "pincode": pincode ,
                                  "geoAddress": geoAddress,
                               
                                  "geoLong": geoLong ,
                                  "geoLat" : geoLat,
                                  "address1": address1,
                                  "address2" : address2 ,
                                  "landmark" : landmark,
                                  "city":city,
                                  "locality" : locality,
                                  "pickupDate" :pickupDate ,
                                  "pickupTime" : pickupTime,
                                  "height":heightInFeetandInch,
                                  "weight": weight,
                                  "Diabetes" : problamDict[problamsArr[0]]!,
                                  "Thyroid" : problamDict[problamsArr[1]]!,
                                  "HeartProblem" : problamDict[problamsArr[2]]!,
                                  "HighCholestrol" : problamDict[problamsArr[3]]!,
                                  "HighBP" : problamDict[problamsArr[4]]!,
                                  "Anaemia" : problamDict[problamsArr[5]]!,
                                  "Liver" : problamDict[problamsArr[6]]!,
                                  "Kidney" : problamDict[problamsArr[7]]!,
                                  "Osteporosis" : problamDict[problamsArr[8]]!,
                                  "Arthritis" : problamDict[problamsArr[9]]!,
                                  "Prostate" : problamDict[problamsArr[10]]!,
                                  "PCOS" : problamDict[problamsArr[11]]!,
                "gender" : gender ,
                "dob" : dob ,
                "userId":customerId,
                "departmentId" : departmentId ,
                "COMP_ID" : companyId
            ]
            
            
            if isComingfromCheckinBarCode == true{
                allParameters["barcode"] = UserDefaults.standard.object(forKey: KCHECKIN_CODE) as? String
                allParameters["COMP_NAME"] = GlobalInfo.sharedInfo.getValuefromDefault(KCOPERATE_NAME) as? String
                print(allParameters)
                ServerConnectivity().callWebservice(allParameters, resulttagname: "SaveCorporateCustomer_V3Result" ,methodname: "SaveCorporateCustomer_V3", className: self)
                
            }else{
                print(allParameters)
                ServerConnectivity().callWebservice(allParameters, resulttagname: "SaveCorporateCustomer_V2Result" ,methodname: "SaveCorporateCustomer_V2", className: self)
            }
            
            
            
            
            
//            print(allParameters)
//            ServerConnectivity().callWebservice(allParameters, resulttagname: "SaveCorporateCustomer_V2Result" ,methodname: "SaveCorporateCustomer_V2", className: self)
        }else{
            
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    
       
    
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
         print(methodName)
     //    print(allResponse)
//        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {

            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                //||allResponse.isEqual("0")
                if allResponse .isEqual("error") || allResponse.isEqual("Something went wrong. Please try again.") || allResponse.isEqual("0")   {
                    
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }else if(methodName == "SaveCorporateCustomer_V3Result"){
                    self.appDelegate.loadMainview()
                }else{
                     UserDefaults.standard.set(false, forKey: "iscorporate")
                     self.appdelegate.loadMainview()
                    
                }
            });
        }//);
    }
 
    
    
//MARK: buttonOnClick
    func btnSubmitOnClick(_ button : UIButton)  {
        
          if ((txtPin1.text?.isEmpty == true) || (txtPin2.text?.isEmpty == true) || (txtPin3.text?.isEmpty == true) || (txtPin4.text?.isEmpty == true) || (txtPin5.text?.isEmpty == true) || (txtPin6.text?.isEmpty == true)){
            self.present(BaseUIController().showAlertView("Please fill Pincode!"), animated: true, completion: nil)
        }else if txtAddressLine1.text?.isEmpty == true {
            self.present(BaseUIController().showAlertView("Please Enter Address"), animated: true, completion: nil)
        }else if (txtLandMark.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please Enter Landmark"), animated: true, completion: nil)
            
        }else if(txtCity.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please Select City"), animated: true, completion: nil)
            
        }else if (txtLocality.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please Enter Locality"), animated: true, completion: nil)
            
        }else if (txtDate.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please Enter Pickup Date!"), animated: true, completion: nil)
            
        }else if (txtTime.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please Enter Pickup Time"), animated: true, completion: nil)
            
        }
        else{
           
            
            let p_code =  txtPin1.text!+txtPin2.text!+txtPin3.text!+txtPin4.text!+txtPin5.text!+txtPin6.text!
            
            let geoAddress = ""
            let geoLong = ""
            let geoLat = ""
            let address2 = ""
            
            let  newPickupTime = txtTime.text!.components(separatedBy: "-")
            let pickupTime = newPickupTime[0]
            
            appdelegate.corporateAllDetailsDict.setValue(p_code, forKey: "pincode")
            appdelegate.corporateAllDetailsDict.setValue(geoAddress, forKey: "geoaddress")
            appdelegate.corporateAllDetailsDict.setValue(geoLong, forKey: "geoLong")
            appdelegate.corporateAllDetailsDict.setValue(geoLat, forKey: "geoLat")
            appdelegate.corporateAllDetailsDict.setValue(txtAddressLine1.text, forKey: "address1")
            appdelegate.corporateAllDetailsDict.setValue(address2, forKey: "address2")
            appdelegate.corporateAllDetailsDict.setValue(txtLandMark.text!, forKey: "landmark")
            appdelegate.corporateAllDetailsDict.setValue(txtCity.text!, forKey: "city")
            appdelegate.corporateAllDetailsDict.setValue(txtLocality.text!, forKey: "locality")
            appdelegate.corporateAllDetailsDict.setValue(txtDate.text!, forKey: "date")
            appdelegate.corporateAllDetailsDict.setValue(pickupTime, forKey: "time")
            
             self.saveAllMedicalHistory ()
        }
    }
}
