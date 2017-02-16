//
//  SaveAddressViewController.swift
//  Stetho
//
//  Created by HW-Anil on 9/24/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class SaveAddressViewController: UIViewController ,UITableViewDelegate , UITableViewDataSource ,UIPickerViewDelegate , UIPickerViewDataSource,UIGestureRecognizerDelegate, serverTaskComplete , GooglePlacesAutocompleteDelegate {
    var saveAddresstableView = UITableView()
    var scrollView = UIScrollView()
    var txtPin1 = UITextField()
    var txtPin2 = UITextField()
    var txtPin3 = UITextField()
    var txtPin4 = UITextField()
    var txtPin5 = UITextField()
    var txtPin6 = UITextField()
    var activeTextField = UITextField()
    
    var txtAddressLine1 = UITextField()
    var txtAddressLine2 = UITextField()
    var txtLandMark = UITextField()
    var txtLocality = UITextField()
    var txtCity = UITextField()
    var cityPickerView : UIPickerView = UIPickerView()
    var arrCityName = ["Delhi" , "New Delhi" , "Faridabad", "Ballabhgarh", "Gurgaon" , "Ghaziabad" , "Noida" ,"Greater Noida", "Meerut", "Sonipat","Bahadurgarh"]
    var bgView = UIView()
    var baseView = UIView()
    var autoPopulateAddressTableView = UITableView()
    var arrGeoAddressDetails = NSMutableArray()
    var dictValue = NSMutableDictionary()
    var dictPickupDetailsValue = NSMutableDictionary()
    var activityIndicator : ProgressViewController?
    var arrOldPickupAddress = NSMutableArray()
    var latitude = ""
    var longitude = ""
    var pickup_Id = ""
    var addressId = ""
    var customColor = UIColor.init(red: (125.0/255.0), green: (125.0/255.0), blue: (125.0/255.0), alpha: 1)
    var gpaViewController = GooglePlacesAutocomplete()
    
// MARK: viewLifeCycleDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        //key board hide & show
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.createALayout()
        // add progress on View
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        self.view.addSubview(activityIndicator!)
        
        
        self.getCustomerAddress()
    }
    override func viewWillAppear(_ animated: Bool) {
        //set tital
       // self.title = "My Address"
        
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("MySavedAddress Screen")

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: createALayout
    func createALayout()  {
        let btnAddNewAddress = BaseUIController().AButtonFrame(CGRect(x: 10, y: 10, width: self.view.frame.width - 20, height: 40), withButtonTital: "Add a New Address")as! UIButton
        btnAddNewAddress.layer.borderWidth = 1
        btnAddNewAddress.layer.borderColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1).cgColor //customColor.CGColor
        btnAddNewAddress.setTitleColor(customColor, for: UIControlState())
        btnAddNewAddress.contentHorizontalAlignment = .left
        btnAddNewAddress.contentEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        btnAddNewAddress.titleLabel?.font = UIFont().smallFont
        btnAddNewAddress.addTarget(self, action: #selector(self.btnAddNewAddress(_:)), for: .touchUpInside)
        self.view.addSubview(btnAddNewAddress)
        let addImageView = BaseUIController().AImageViewFrame(CGRect(x: 10, y: 5, width: 30, height: 30), withImageName: "add.png")as! UIImageView
        btnAddNewAddress.addSubview(addImageView)
        let lblsaveAddress = BaseUIController().ALabelFrame(CGRect(x: 10, y: 60, width: 200, height: 21), withString: "Saved Addresses")as! UILabel
        lblsaveAddress.font = UIFont().regularMediumFont
        self.view.addSubview(lblsaveAddress)

        saveAddresstableView = UITableView(frame:CGRect(x: 10, y: 90,width: (UIScreen.main.bounds.width) - 20, height: UIScreen.main.bounds.height - 184))
        saveAddresstableView.backgroundColor = UIColor.white
        saveAddresstableView.allowsSelection = false
        saveAddresstableView.separatorInset = UIEdgeInsets.zero
        self.saveAddresstableView.separatorStyle = .none
//        saveAddresstableView.delegate = self
//        saveAddresstableView.dataSource = self
        self.view.addSubview(saveAddresstableView)
        
        
    }
    func createAddressPopup()  {
        bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        bgView.tag = 500
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.window!.addSubview(bgView)
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnBGView(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        bgView.addGestureRecognizer(tapped)
        
        // create base view 
        baseView = UIView.init(frame: CGRect(x: 15, y: 30, width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.height - 60 ))
        baseView.backgroundColor = UIColor.white
        baseView.layer.cornerRadius = 4
        baseView.layer.borderWidth = 2
        baseView.layer.borderColor = UIColor.gray.cgColor
        bgView.addSubview(baseView)
        
        let lblHeading = BaseUIController().ALabelFrame(CGRect(x: 10, y: 0, width: self.view.frame.width, height: 40), withString: "Add New Address")as! UILabel
        baseView.addSubview(lblHeading)
        let lblLine = BaseUIController().ALabelFrame(CGRect(x: 0, y: 41, width: self.view.frame.width, height: 1), withString: "")as! UILabel
        lblLine.backgroundColor = UIColor.red
        baseView.addSubview(lblLine)
        

        
        scrollView = UIScrollView(frame: CGRect(x: 0 , y: 42 , width: baseView.frame.width , height: baseView.frame.height -  80)) //
        scrollView.backgroundColor = UIColor.white
        baseView.addSubview(scrollView)
        var xPos:CGFloat = 20
        var yPos:CGFloat = 10
        var labelName: [String] = ["Address Line 1 :" , "Address Line 2 :" , "Landmark :", "City :", "Locality :"]
       
        for i in (0..<labelName.count) {
            let label = BaseUIController().ALabelFrame(CGRect(x:xPos , y: yPos ,width: 200 , height: 30 ), withString: labelName[i])as! UILabel
            label.font = UIFont().mediumFont
            scrollView.addSubview(label)
            yPos += 21+5;
            let textField = BaseUIController().ATextFiedlFrame(CGRect(x:xPos , y: yPos ,width: baseView.frame.width-40 , height: 35 ), withPlaceHolder: "")as! UITextField
            textField.tag = 200 + i
            textField.delegate = self
            textField.textAlignment = .left
            textField.borderStyle = .roundedRect
            scrollView.addSubview(textField)
            
            yPos += 35+5;
        }
        yPos += 10;
        let lblPincode :UILabel = BaseUIController().ALabelFrame(CGRect(x: xPos , y: yPos, width:  80 , height: 21), withString: "Pincode :")as! UILabel
        lblPincode.font = UIFont().mediumFont
        scrollView.addSubview(lblPincode)
        
        
        xPos =  90
        let _width: CGFloat = (baseView.frame.width - (xPos + 20 + 50 ))/6
        
        
        for i in (0..<6) {
            
            let textField = BaseUIController().ATextFiedlFrame(CGRect(x: xPos , y: yPos ,width: _width , height: 20 ), withPlaceHolder: "")as! UITextField
            textField.borderStyle = .line
            textField.layer.borderWidth = 1
            textField.layer.borderColor =  UIColor.init(red: (242.0/255.0), green: (237.0/255.0), blue: (237.0/255.0), alpha: 1.0).cgColor
            scrollView.addSubview(textField)
            textField.tag = 100 + i
            textField.delegate = self
            textField.keyboardType = .numberPad
            addToolBar(textField)
            
            xPos += _width + 10 ;
        }
        
        
        yPos += 40
        let btnCancel = BaseUIController().AButtonFrame(CGRect(x: 1 , y: baseView.frame.height - 40 , width: (baseView.frame.width)/2 - 2, height: 40), withButtonTital: "CANCEL")as! UIButton
        btnCancel.backgroundColor =  UIColor.red//UIColor .init(red: (235.0/255.0), green: (235.0/255.0), blue: (235.0/255.0), alpha: 1)
        btnCancel.titleLabel?.font = UIFont().largeFont
        btnCancel.setTitleColor(UIColor.white, for: UIControlState())
        btnCancel.addTarget(self, action: #selector(self.btnCancelOnClick(_:)), for: .touchUpInside)
       // scrollView.contentSize = CGSizeMake(self.view.frame.width, scrollView.frame.height + 100)
        baseView.addSubview(btnCancel)
        
        
        let btnDone = BaseUIController().AButtonFrame(CGRect(x: (baseView.frame.width)/2 + 2 , y: baseView.frame.height - 40 , width: (baseView.frame.width)/2 - 2, height: 40), withButtonTital: "DONE")as! UIButton
        btnDone.backgroundColor =  UIColor.red//UIColor .init(red: (235.0/255.0), green: (235.0/255.0), blue: (235.0/255.0), alpha: 1)
        btnDone.titleLabel?.font = UIFont().largeFont
        btnDone.setTitleColor(UIColor.white, for: UIControlState())
        btnDone.addTarget(self, action: #selector(self.btnDoneOnclick(_:)), for: .touchUpInside)
        // scrollView.contentSize = CGSizeMake(self.view.frame.width, scrollView.frame.height + 100)
        baseView.addSubview(btnDone)
        
        
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
        
        //Add PickerView
        cityPickerView.dataSource = self
        cityPickerView.delegate = self
        txtCity.inputView = cityPickerView
        addToolBar(txtCity)
        
        // Add a "textFieldDidChange" notification method to the text field control.
      //  txtLocality.addTarget(self, action: #selector(self.textFieldDidChange), forControlEvents: .EditingChanged)
        
        // create a autocomplete tableView
        
        autoPopulateAddressTableView = UITableView(frame:CGRect(x: 10, y: 50,width: (baseView.frame.width) - 20, height: 120))
        autoPopulateAddressTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        autoPopulateAddressTableView.separatorStyle = .none
        autoPopulateAddressTableView.backgroundColor = UIColor.clear
        autoPopulateAddressTableView.dataSource = self
        autoPopulateAddressTableView.delegate = self
        autoPopulateAddressTableView.isHidden = true
        autoPopulateAddressTableView.layer.cornerRadius = 4
        autoPopulateAddressTableView.layer.borderWidth = 1
        scrollView.addSubview(self.autoPopulateAddressTableView)
        
      
    }
    
    
    //MARK: - TableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == autoPopulateAddressTableView {
            return 1
        }else{
             return arrOldPickupAddress.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == autoPopulateAddressTableView {
            return arrGeoAddressDetails.count
        }else{
           return 1
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = UITableViewCell()
        if tableView == autoPopulateAddressTableView {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
            cell.textLabel?.text = (arrGeoAddressDetails.object(at: indexPath.row) as! NSDictionary).value(forKey: "address") as? String
//            cell.textLabel?.text = arrGeoAddressDetails.object(at: (indexPath as NSIndexPath).row).value(forKey: "address") as? String
            cell.textLabel?.font = UIFont().mediumFont
            cell.backgroundColor = UIColor.gray
            return cell
        }else{
        let cellIdentifier:String = "saveAddress"
        var cell:saveAddressTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? saveAddressTableViewCell
//        if (cell == nil)
//        {
            var nib:Array = Bundle.main.loadNibNamed("saveAddressTableViewCell", owner: self, options: nil)!
            cell = nib[0] as? saveAddressTableViewCell
            cell!.layer.borderWidth = 1
            cell!.layer.cornerRadius = 3
            cell?.layer.masksToBounds = true
            cell!.layer.borderColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1).cgColor
            
            let addressDict = arrOldPickupAddress.object(at: indexPath.row) as! NSDictionary
            
            let address_line1 = addressDict.value(forKey: "a_address_line_1")as? String
            let address_line2 = addressDict.value(forKey: "a_address_line_2")as? String
            let landmark = addressDict.value(forKey: "a_landmark")as? String
            let pincode = addressDict.value(forKey: "a_pincode")as? String
            let cityName = addressDict.value(forKey: "city_name")as? String
            let geo_address = addressDict.value(forKey: "geo_address")as? String
            
            let fullAddress = String(format: "%@ , %@,%@,%@,%@ %@", address_line1! ,address_line2! , landmark! ,geo_address! ,cityName! , pincode!)
            let userName = UserDefaults.standard.value(forKey: "userName")as! String
            let mobileNo = UserDefaults.standard.value(forKey: "mobileNo")as! String
            cell?.lblName.text = userName
            cell?.lblMobileNo.text = "+91" + mobileNo
            cell?.lblAddress.text = fullAddress
            
            cell?.btnDelete.addTarget(self, action: #selector(self.btnDeleteOnClick(_:)), for: .touchUpInside)
            cell?.btnEdit.addTarget(self, action: #selector(self.btnEditOnClick(_:)), for: .touchUpInside)
            //}
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var pinCode = ""
        
        if tableView == autoPopulateAddressTableView {
            autoPopulateAddressTableView.isHidden = true
            if arrGeoAddressDetails.count != 0
            {
                dictPickupDetailsValue = arrGeoAddressDetails[indexPath .row] as! NSMutableDictionary
                pinCode = dictPickupDetailsValue.value(forKey: "pincode")as! String
                txtLocality.text = dictPickupDetailsValue.value(forKey: "address")as? String
                latitude = (dictPickupDetailsValue.value(forKey: "lat")as? String)!
                longitude = (dictPickupDetailsValue.value(forKey: "lng")as? String)!
            }
        }
        if pinCode != "" && pinCode.characters.count == 6 {
            txtPin1.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 0)])
            txtPin2.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 1)])
            txtPin3.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 2)])
            txtPin4.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 3)])
            txtPin5.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 4)])
            txtPin6.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 5)])
        }else{
            txtPin1.text = ""
            txtPin2.text = ""
            txtPin3.text = ""
            txtPin4.text = ""
            txtPin5.text = ""
            txtPin6.text = ""
        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == autoPopulateAddressTableView {
           return  30
        }else{
           return  150
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if tableView == autoPopulateAddressTableView {
            return 0
        }else{
            return 10;
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 1, width: tableView.bounds.size.width, height: 8))
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    //MARK: PickerViewDelegate
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
            return arrCityName.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

            return arrCityName[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
            txtCity.text = "\(arrCityName[row])"
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
            pickerLabel.text = arrCityName[row]
            pickerLabel.font = UIFont().mediumFont
        
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
            return 30;
    }
    // MARK: - TextFiedlDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        return textField.resignFirstResponder()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        if(textField == txtLocality){
            bgView.isHidden = true
            gpaViewController = GooglePlacesAutocomplete(
                apiKey: "AIzaSyCoEvSzsfnL5WPUw4WF2KAWmekxkO6qgI8",
                placeType: .address
            )
            
            gpaViewController.placeDelegate = self // Conforms to GooglePlacesAutocompleteDelegate
            
            present(gpaViewController, animated: true, completion: nil)
        }
        
    }
    
    
//    func textFieldDidChange()  {
//        self.getGEOLocation(String(format: "http://maps.google.com/maps/api/geocode/json?address=%@&sensor=false&components=country:IN",txtLocality.text!))
//        
//    }
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
            let maxLength = 500
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
            self.bgView.isHidden = false
           
            
        }
        
    }
    func placeViewClosed() {
        
        gpaViewController.dismiss(animated: true) {
             self.bgView.isHidden = false
            
        }
        // self.navigationController?.popViewControllerAnimated(true)
        
        
    }

    //MARK: - GestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        print(touch.view)
        //UITableViewCellContentView
        if (touch.view == bgView ){
            
            return true
        }
        else{
            
            return false
        }
    }
    //MARK: buttonOnClick   
    func btnDeleteOnClick(_ button : UIButton)  {
        let buttonPosition = button.convert(CGPoint.zero, to: saveAddresstableView)
        let indexPath = saveAddresstableView.indexPathForRow(at: buttonPosition)
         addressId = (arrOldPickupAddress.object(at: indexPath!.section) as! NSDictionary).value(forKey: "opick_id") as! String
//        addressId = (arrOldPickupAddress.object(at: ((indexPath as NSIndexPath?)?.section)!).value(forKey: "opick_id")as? String)!
        self.showAlertView()
        
    }
    func btnEditOnClick(_ button : UIButton)  {
        
        self.createAddressPopup()
        var pinCode = ""
        let buttonPosition = button.convert(CGPoint.zero, to: saveAddresstableView)
        let indexPath = saveAddresstableView.indexPathForRow(at: buttonPosition)
        let addressDetails = arrOldPickupAddress.object(at: indexPath!.section) as! NSDictionary
        pickup_Id = addressDetails.value(forKey: "opick_id")as! String
        let address_line1 = addressDetails.value(forKey: "a_address_line_1")as? String
        let address_line2 = addressDetails.value(forKey: "a_address_line_2")as? String
        let landmark = addressDetails.value(forKey: "a_landmark")as? String
        pinCode = addressDetails.value(forKey: "a_pincode")as! String
        let cityName = addressDetails.value(forKey: "city_name")as? String
        let geo_address = addressDetails.value(forKey: "geo_address")as? String
        txtAddressLine1.text = address_line1
        txtAddressLine2.text = address_line2
        txtLandMark.text = landmark
        txtCity.text = cityName
        txtLocality.text = geo_address
        if pinCode != "" && pinCode.characters.count == 6 {
            txtPin1.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 0)])
            txtPin2.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 1)])
            txtPin3.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 2)])
            txtPin4.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 3)])
            txtPin5.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 4)])
            txtPin6.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 5)])
        }else{
            txtPin1.text = ""
            txtPin2.text = ""
            txtPin3.text = ""
            txtPin4.text = ""
            txtPin5.text = ""
            txtPin6.text = ""
        }
        
    }
    func btnAddNewAddress(_ button : UIButton){
        pickup_Id = "0"
        self.createAddressPopup()
    }
    func btnCancelOnClick(_ button : UIButton)  {
        pickup_Id = "0"
        bgView.isHidden = true
        bgView.removeFromSuperview()
    }
    func btnDoneOnclick(_ button : UIButton)  {
        
        if txtAddressLine1.text?.isEmpty == true {
            self.present(BaseUIController().showAlertView("Please Enter Your Address"), animated: true, completion: nil)
        }else if (txtLandMark.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please Enter Your LandMarks"), animated: true, completion: nil)
            
        }else if(txtCity.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please Select Your City"), animated: true, completion: nil)
            
        }else if (txtLocality.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please Enter your Locality"), animated: true, completion: nil)
            
        }else  if ((txtPin1.text?.isEmpty == true) || (txtPin2.text?.isEmpty == true) || (txtPin3.text?.isEmpty == true) || (txtPin4.text?.isEmpty == true) || (txtPin5.text?.isEmpty == true) || (txtPin6.text?.isEmpty == true)){
            self.present(BaseUIController().showAlertView("Please fill Pincode!"), animated: true, completion: nil)
        }else{
            bgView.isHidden = true
            bgView.removeFromSuperview()
            self.insertUpdatePickupAddress()
            
        }
        

    }
    //MARK: removeBGView
    func tappedOnBGView(_ sender: UITapGestureRecognizer)  {
        pickup_Id = "0"
        bgView.isHidden = true
        bgView.removeFromSuperview()
    }
    
    // MARK: CallWebservice
    func getCustomerAddress() {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            
            let allParameters = ["customerId" : customerId]
            ServerConnectivity().callWebservice(allParameters , resulttagname: "GetCustomerAddressesResult" ,methodname: "GetCustomerAddresses", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    
    func deleteCustomerAddress(_ address_Id : String) {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let allParameters = ["customerId" : customerId, "addressId" : address_Id]
            ServerConnectivity().callWebservice(allParameters , resulttagname: "DeleteAddressResult" ,methodname: "DeleteAddress", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    func insertUpdatePickupAddress()  {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let pincode = txtPin1.text!+txtPin2.text!+txtPin3.text!+txtPin4.text!+txtPin5.text!+txtPin6.text!
            
            let allParameters = ["customerId" : customerId, "pickupId" : pickup_Id , "addressLine1" : txtAddressLine1.text! , "addressLine2" : txtAddressLine2.text! , "landmark": txtLandMark.text! , "city":txtCity.text! ,"pincode" : pincode , "geoAddress": txtLocality.text!, "latitude":latitude ,"longitude" : longitude ]
            ServerConnectivity().callWebservice(allParameters , resulttagname: "InsertUpdatePickupAddressResult" ,methodname: "InsertUpdatePickupAddress", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
      //  print(allResponse)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                 if(methodName == "GetCustomerAddresses"){
                if allResponse is String &&  allResponse as! String == "" {
                    self.arrOldPickupAddress.removeAllObjects()
                    self.saveAddresstableView.separatorStyle = .none
                    self.saveAddresstableView.separatorInset = UIEdgeInsets.zero
                    self.saveAddresstableView.reloadData()
                   // self.presentViewController(BaseUIController().showAlertView("No Record"), animated: true, completion: nil)
                }else if (allResponse is String && allResponse as! String != ""){
                   // self.presentViewController(BaseUIController().showAlertView(allResponse as! String), animated: true, completion: nil)
                     self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    
                }else{
                        self.arrOldPickupAddress.removeAllObjects()
                        self.saveAddresstableView.delegate      =   self
                        self.saveAddresstableView.dataSource    =   self
                       // self.saveAddresstableView.separatorStyle = .SingleLine
                        self.arrOldPickupAddress = allResponse as! NSMutableArray
                        self.saveAddresstableView.reloadData()
                    }
                }else if(methodName == "DeleteAddress")
                 {
                     if allResponse is String &&  allResponse as! String == "1"{
                        self.getCustomerAddress()
                     }else{
                         self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    }
                    
                 }else if(methodName == "InsertUpdatePickupAddress")
                 {
                    if allResponse is String &&  allResponse as! String != "0"{
                        self.getCustomerAddress()
                        self.pickup_Id = "0"
                    }else{
                        self.pickup_Id = "0"
                        self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    }
                    
                }
            });
        });
    }
    
/*    //MARK: getGEOLocation
    func getGEOLocation(addressUrl : String)  {
        let urlPath: String = addressUrl
        let escapedAddress = urlPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let url: NSURL = NSURL(string: escapedAddress!)!
        let request1: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            
            do {
                if (data != nil){
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                        print("ASynchronous\(jsonResult)")
                        self.filterGeoLocation(jsonResult)
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
    }
    
    func filterGeoLocation(locationData : NSDictionary)  {
        let arrGeoLocaiton = locationData.valueForKey("results")
        arrGeoAddressDetails = NSMutableArray()
        //arrpinCode  = NSMutableArray()
        autoPopulateAddressTableView.hidden = false
        
        for i in 0..<arrGeoLocaiton!.count {
            
            let arrAddressComponent = arrGeoLocaiton![i].valueForKey("address_components")
            for k in 0..<arrAddressComponent!.count {
                let arrtypes = arrAddressComponent![k].valueForKey("types")as! [String]
                print(arrtypes)
                let cityName = arrAddressComponent![k].valueForKey("long_name")as! String
                let arr = ["locality" , "political"]
                if arrtypes == arr  {
                    if txtCity.text?.lowercaseString == cityName.lowercaseString {
                        let address = arrGeoLocaiton![i].valueForKey("formatted_address")as! String
                        let lat = (arrGeoLocaiton![i].valueForKey("geometry"))!.valueForKey("location")?.valueForKey("lat")as! NSNumber
                        let lng = (arrGeoLocaiton![i].valueForKey("geometry"))!.valueForKey("location")?.valueForKey("lng")as! NSNumber
                        dictValue.setValue("\(lat)", forKey: "lat")
                        dictValue.setValue("\(lng)", forKey: "lng")
                        
                        print(address)
                        let arrtypes = arrAddressComponent![(arrAddressComponent?.count)!-1].valueForKey("types")as! [String]
                        print(arrtypes)
                        let arr = ["postal_code"]
                        if arrtypes == arr  {
                            dictValue.setValue(arrAddressComponent![(arrAddressComponent?.count)!-1].valueForKey("long_name")as! String, forKey: "pincode")
                            
                            //  arrpinCode .addObject(arrAddressComponent![(arrAddressComponent?.count)!-1].valueForKey("long_name")as! String)
                            
                        }else{
                            //                             arrpinCode .addObject("")
                            dictValue.setValue("", forKey: "pincode")
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // self.arrGeoAddressList.addObject(address)
                            self.dictValue.setValue(address, forKey: "address")
                            self.arrGeoAddressDetails.addObject(self.dictValue)
                            let count = self.arrGeoAddressDetails.count
                            self.autoPopulateAddressTableView.frame = CGRectMake(10 , (self.txtLocality.frame.origin.y - 30 * CGFloat(count))-2, self.baseView.frame.width - 20, 30 * CGFloat(count))
                            self.autoPopulateAddressTableView.hidden = false
                            self.autoPopulateAddressTableView.reloadData()
                        })
                        
                        
                    }
                    
                }
                
            }
            
        }
        
    } */
    
    // MARK: - KeyboardShow&Hide
    func keyboardWillShow(_ notification:Notification){
        if activeTextField == txtLandMark || activeTextField == txtCity || activeTextField == txtLocality || activeTextField == txtPin1 || activeTextField == txtPin2 || activeTextField == txtPin3 || activeTextField == txtPin4 || activeTextField == txtPin5 || activeTextField == txtPin6  {
            scrollView.frame = CGRect(x: 0 , y: -120 , width: scrollView.frame.width , height: scrollView.frame.height)
        }else{
            scrollView.frame = CGRect(x: 0 , y: 42 , width: scrollView.frame.width , height: scrollView.frame.height )
            
        }

       // scrollView.contentSize = CGSizeMake(baseView.frame.width, baseView.frame.height + 100)
    }
    
    func keyboardWillHide(_ notification:Notification){

        if activeTextField == txtLandMark || activeTextField == txtCity || activeTextField == txtLocality || activeTextField == txtPin1 || activeTextField == txtPin2 || activeTextField == txtPin3 || activeTextField == txtPin4 || activeTextField == txtPin5 || activeTextField == txtPin6  {
            scrollView.frame = CGRect(x: 0 , y: 42, width: scrollView.frame.width , height: scrollView.frame.height )
        }else{
            scrollView.frame = CGRect(x: 0 , y: 42 , width: scrollView.frame.width , height: scrollView.frame.height )
            
        }
       // scrollView.contentSize = CGSizeMake(baseView.frame.width, baseView.frame.height - 80)
    }
    //MARK: showAlert
    func showAlertView()  {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Alert!", message: "Do you want to Delete?", preferredStyle: .alert)
        //Create and add the Continue action
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .cancel) { action -> Void in
            //Do some stuff
             self.deleteCustomerAddress(self.addressId)
        }
        actionSheetController.addAction(yesAction)
        //        //Create and add the Discart action
        let cancleAction: UIAlertAction = UIAlertAction(title: "No", style: .default) { action -> Void in
            //Do some stuff
            
            
        }
        actionSheetController.addAction(cancleAction)
        //self.presentViewController(actionSheetController, animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.present(actionSheetController, animated: true, completion: nil)
    }


}
