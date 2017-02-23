//
//  AddNewAddressViewController.swift
//  Stetho
//
//  Created by Administrator on 17/02/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit

class AddNewAddressViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, GooglePlacesAutocompleteDelegate, serverTaskComplete {
    
    var scrollView: TPKeyboardAvoidingScrollView!
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
    var gpaViewController = GooglePlacesAutocomplete()
    var cityPickerView : UIPickerView = UIPickerView()
    var activityIndicator : ProgressViewController?
    var latitude = ""
    var longitude = ""
    var pickup_Id = "0"
    
    var updateAddress:(()->())?
    
    //For Edit Address
    
    var updateSavedAddressDict: NSDictionary?


    
    var arrCityName = ["Delhi" , "New Delhi" , "Faridabad", "Ballabhgarh", "Gurgaon" , "Ghaziabad" , "Noida" ,"Greater Noida", "Meerut", "Sonipat","Bahadurgarh"]
    var arrGeoAddressDetails = NSMutableArray()
    var dictPickupDetailsValue = NSMutableDictionary()


    var autocompleteTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
        self.title = KADDNEW_ADD
        let rightButton = UIBarButtonItem(title: KCANCEL, style: .plain, target: self, action: #selector(AddNewAddressViewController.cancelButtonClicked(_:)))
        rightButton.tintColor = KRED_COLOR
        self.navigationItem.rightBarButtonItem = rightButton
        createALayout()
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if updateSavedAddressDict != nil{
            fillEditAddress(addressDetails: updateSavedAddressDict!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelButtonClicked(_ sender: AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    
    func createALayout()  {
        
        
        scrollView = TPKeyboardAvoidingScrollView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height - 50)) //nav + topborder + segment + continue
        scrollView.backgroundColor = UIColor.white
        self.view .addSubview(scrollView)
        var xPos:CGFloat = 20
        var yPos:CGFloat = 40
        
        let doneButton = UIButton(frame: CGRect(x: 0, y:self.view.frame.height - 50 , width: mainScreenWidth, height: 50))
        doneButton.setTitle(KDONE, for: UIControlState.normal)
        doneButton.addTarget(self, action: #selector(AddNewAddressViewController.doneButtonClicked(_:)), for: .touchUpInside)
        doneButton.backgroundColor = KRED_COLOR
        doneButton.titleLabel?.font = KROBOTO_Light_19
        self.view.addSubview(doneButton)
        
        var labelName: [String] = ["Address Line 1" , "Address Line 2" , "Landmark", "City", "Locality"]
        
        for i in (0..<labelName.count) {
            let textField = BaseUIController().ATextFiedlFrame(CGRect(x:xPos , y: yPos ,width: self.view.frame.width-40 , height: 35 ), withPlaceHolder: "")as! UITextField
            textField.tag = 200 + i
            textField.delegate = self
            textField.font = KROBOTO_Regular_17
            textField.textAlignment = .left
            textField.borderStyle = .none
            textField.placeholder = labelName[i]
            textField.autocorrectionType = .no
            textField.textColor = UIColor.darkGray
            if i == 0 || i == 1 {
                textField.returnKeyType = .next
            }
            
            let lineLabel = UILabel(frame: CGRect(x: textField.frame.origin.x, y: textField.frame.size.height + textField.frame.origin.y, width: textField.frame.size.width, height: 1))
            lineLabel.textColor = UIColor.clear
            lineLabel.backgroundColor = KRED_COLOR
            scrollView.addSubview(textField)
            scrollView.addSubview(lineLabel)
            yPos += 35 + 20;
        }
        yPos += 10;
        
        let lblPincode :UILabel = BaseUIController().ALabelFrame(CGRect(x: xPos , y: yPos + 5, width:  70 , height: 21), withString: "Pincode :")as! UILabel
        lblPincode.font = KROBOTO_Light_16//UIFont().mediumFont
        scrollView.addSubview(lblPincode)
        
        
        xPos =  90//120
        let pendingSpace = mainScreenWidth-90-20
        
        let _width: CGFloat = (self.view.frame.width - (xPos + 20 + 50 ))/6
        
        let spacetoTrim = pendingSpace - ((_width + 10) * 6)
        if spacetoTrim > 0{
        xPos = spacetoTrim/2
        }
        for i in (0..<6) {
            
            let textField = UITextField(frame: CGRect(x: xPos , y: yPos ,width: _width , height: _width ))
            //            let textField = BaseUIController().ATextFiedlFrame(CGRect(x: xPos , y: yPos ,width: _width , height: _width ), withPlaceHolder: "")as! UITextField
            textField.borderStyle = .line
            textField.layer.borderWidth = 1.5
            textField.layer.cornerRadius = 4.0
            textField.layer.masksToBounds = true
            textField.layer.borderColor =  UIColor.lightGray.cgColor//UIColor.lightGray.cgColor//UIColor.init(red: (242.0/255.0), green: (237.0/255.0), blue: (237.0/255.0), alpha: 1.0).cgColor
            textField.font = KROBOTO_Regular_19
            textField.textColor = UIColor.darkGray
            textField.textAlignment = .center
            scrollView.addSubview(textField)
            textField.tag = 100 + i
            textField.delegate = self
            textField.keyboardType = .numberPad
            addToolBar(textField)
            
            xPos += _width + 10 ;
        }
        
        
        yPos += 40
        /*
        let btnContinue = BaseUIController().AButtonFrame(CGRect(x: 0 , y: scrollView.frame.height , width: self.view.frame.width, height: 40), withButtonTital: "Continue")as! UIButton
        btnContinue.backgroundColor =  KRED_COLOR//UIColor .init(red: (235.0/255.0), green: (235.0/255.0), blue: (235.0/255.0), alpha: 1)
        btnContinue.titleLabel?.font = KROBOTO_Light_15//UIFont().largeFont
        btnContinue.setTitleColor(UIColor.white, for: UIControlState())
        btnContinue.addTarget(self, action: #selector(PickUpDetailsViewController.btnContinueOnClick(_:)), for: .touchUpInside)*/
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: scrollView.frame.height - 50)
        
        //self.view.addSubview(btnContinue)
        
        
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
        
        // create a autocomplete tableView
        
        autocompleteTableView = UITableView(frame:CGRect(x: 10, y: 50,width: (UIScreen.main.bounds.width) - 20, height: 120))
        autocompleteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        autocompleteTableView.separatorStyle = .none
        autocompleteTableView.backgroundColor = UIColor.clear
        autocompleteTableView.dataSource = self
        autocompleteTableView.delegate = self
        autocompleteTableView.isHidden = true
        autocompleteTableView.layer.cornerRadius = 4
        autocompleteTableView.layer.borderWidth = 1
        scrollView.addSubview(self.autocompleteTableView)
    }
    
    //MARK: TEXTFIELD DELEGATES
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case txtAddressLine1:
            txtAddressLine2.becomeFirstResponder()
        case txtAddressLine2:
            txtLandMark.becomeFirstResponder()
        default:
            break
        }
        return true
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
        pickerLabel.textColor = UIColor.black
        pickerLabel.font = KROBOTO_Regular_17
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
            return 30;
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
                        textField.resignFirstResponder()
                        return false;
                    }
                }
            }else{
                print("back")
                
                if (textField == txtPin1) {
                    txtPin1.text = ""
                    txtPin1.becomeFirstResponder()
                    return false; // NO because we already updated the text.
                    
                }
                
                if (textField == txtPin2) {
                    txtPin2.text = ""
                    txtPin1.becomeFirstResponder()
                    return false;
                    
                }
                if (textField == txtPin3) {
                    txtPin3.text = ""
                    txtPin2.becomeFirstResponder()
                    return false;
                    
                }
                if (textField == txtPin4) {
                    txtPin4.text = ""
                    txtPin3.becomeFirstResponder()
                    return false;
                    
                }
                if (textField == txtPin5) {
                    txtPin5.text = ""
                    txtPin4.becomeFirstResponder()
                    return false;
                    
                }
                if (textField == txtPin6) {
                    
                    txtPin6.text = ""
                    txtPin5.becomeFirstResponder()
                    return false;
                    
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
    
    //MARK: - TableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if autocompleteTableView == tableView {
            return 1;
        }else{
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print(arrGeoAddressDetails.count)
        return  arrGeoAddressDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = UITableViewCell()
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
            cell.textLabel?.text = (arrGeoAddressDetails[indexPath.row] as! NSMutableDictionary).value(forKey: "description") as? String
            cell.textLabel?.font = UIFont().mediumFont
            cell.backgroundColor = UIColor.gray
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        var pinCode = ""
        autocompleteTableView.isHidden = true
        dictPickupDetailsValue = arrGeoAddressDetails[(indexPath as NSIndexPath).row] as! NSMutableDictionary
        pinCode = (arrGeoAddressDetails.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "pincode")as! String
        txtLocality.text = (arrGeoAddressDetails[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "address")as? String
    }
 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == autocompleteTableView {
            return  30;
        }else{
            return  60;
        }
        
    }
    
    //MARK: GEOCODE DELEGATES
    
    func placesFound(_ places: [Place]) {
        
        print(places)
        
    }
    func placeSelected(_ place: Place) {
        
        print(place)
        place.getDetails { details in
            print(details.name)       // Convenience accessor for name
            print(details.latitude)   // Convenience accessor for latitude
            print(details.longitude)  // Convenience accessor for longitude
            // print(details.raw)        // Complete JSON data (see below)
            self.txtLocality.text = details.name
            self.latitude = String(details.latitude)
            self.longitude = String(details.longitude)
        }
        
        dismiss(animated: false) {
            
            
        }
        
    }
    func placeViewClosed() {
        
        gpaViewController.dismiss(animated: true) {
            
        }}
    
    //MARK: IBACTIONS
    
    
    func fillEditAddress(addressDetails: NSDictionary){
        var pinCode = ""
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
    
    func doneButtonClicked(_ sender: AnyObject){
        let trimAddress1 = txtAddressLine1.text?.trimmingCharacters(in: .whitespaces)
        
        
        if trimAddress1?.isEmpty == true{
            self.present(BaseUIController().showAlertView("Please Enter Your Address"), animated: true, completion: nil)
        }else if txtCity.text?.isEmpty == true{
            self.present(BaseUIController().showAlertView("Please Select Your City"), animated: true, completion: nil)
        }
        else if txtLocality.text?.isEmpty == true{
            self.present(BaseUIController().showAlertView("Please Enter your Locality"), animated: true, completion: nil)
        }
        else  if ((txtPin1.text?.isEmpty == true) || (txtPin2.text?.isEmpty == true) || (txtPin3.text?.isEmpty == true) || (txtPin4.text?.isEmpty == true) || (txtPin5.text?.isEmpty == true) || (txtPin6.text?.isEmpty == true)){
            self.present(BaseUIController().showAlertView("Please fill Pincode!"), animated: true, completion: nil)
        }else{
            self.insertUpdatePickupAddress()
        }
    }
    
    //MARK: SERVICE DELEGATES
    
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
                 if(methodName == "InsertUpdatePickupAddress")
                {
                    if allResponse is String &&  allResponse as! String != "0"{
                        self.dismiss(animated: true, completion: nil)
                        self.pickup_Id = "0"
                        self.updateAddress!()
                    }else{
                        self.pickup_Id = "0"
                        self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    }
                    
                }
            });
        });
    }

}
