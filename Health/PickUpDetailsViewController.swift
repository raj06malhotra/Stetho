//
//  PickUpDetailsViewController.swift
//  Health
//
//  Created by HW-Anil on 6/25/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
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


class PickUpDetailsViewController: UIViewController  ,UIPickerViewDelegate , UIPickerViewDataSource , UITableViewDelegate , UITableViewDataSource , serverTaskComplete , UIGestureRecognizerDelegate ,GooglePlacesAutocompleteDelegate{
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
    var memberNamePickerView : UIPickerView = UIPickerView()
    
    var scrollView = TPKeyboardAvoidingScrollView()
    
    var arrCityName = ["Delhi" , "New Delhi" , "Faridabad", "Ballabhgarh", "Gurgaon" , "Ghaziabad" , "Noida" ,"Greater Noida", "Meerut", "Sonipat","Bahadurgarh"]
    var autocompleteTableView = UITableView()
    var extraTestPkgTableView = UITableView()
    var extraSelecteTestPkgTableView = UITableView()
    var pickupAddressTableView = UITableView()
    
    var arrGeoAddressDetails = NSMutableArray()
    //var arr = NSMutableArray()
    var dictValue = NSMutableDictionary()
    var dictPickupDetailsValue = NSMutableDictionary()
    let pickupAddressObj = PickupAddressInfo()
    var bgView = UIView()
    var baseView = UIView()
    //var lblCount = UILabel()
    var activityIndicator : ProgressViewController?
    var arrGetExtraPackage = NSMutableArray()
    var  maxCount : Int = 0
    var btnAdd: UIButton = UIButton()
    var totalSelectedPrice = 0
    var currencySymbol = ""
    var pickup_Id = "0"
    var arrSelectedTestPackage = NSMutableArray()
    var arrSortSelectedTestPackage = NSArray()
    var arrMemberNameList = NSMutableArray()
    var dictMemberNameList = NSMutableDictionary()
    var arrOldPickupAddress = NSMutableArray()
    var extraTestScrollView = UIScrollView()
    // Profile Info
    var maleImageView: UIImageView = UIImageView()
    var femaleImageView: UIImageView = UIImageView()
    var btnMale: UIButton = UIButton()
    var btnFemale: UIButton = UIButton()
    var selectedGender: String = ""
    var gpaViewController = GooglePlacesAutocomplete()
    var tabBarHeight : CGFloat = 0
    
    
    
    
 //MARK: viewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.createALayout()
        self.getPickupAddressDetails()
//        NotificationCenter.default.addObserver(self, selector: #selector(PickUpDetailsViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(PickUpDetailsViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
//        
//        let locale = Locale.current
//        let currencySymbol = locale.object(forKey: .currencySymbol)!
//        let currencyCode = locale.object(forKey: .currencyCode)!
//        locale.com
//        
        
        
        // get currency sysmbol
//        let currencyCode = "INR"
        
//        let localeComponents = [NSLocale.Key.currencyCode: currencyCode]
//        let localeIdentifier = Locale.localeIdentifier(fromComponents: localeComponents)
//        let locale = Locale(localeIdentifier: localeIdentifier)
        currencySymbol = (Locale(identifier:"de") as NSLocale).displayName(forKey: .currencySymbol, value: "INR")!//(locale as NSLocale).object(forKey: NSLocale.Key.currencySymbol) as! String
        //get selected member count
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.getTotalMemberCount()
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("PickupAddress Screen")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
      //MARK: createALayoutDesign
    func createALayout()  {
        
        scrollView = TPKeyboardAvoidingScrollView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height - (64+tabBarHeight+40+40))) //nav + topborder + segment + continue
        self.view .addSubview(scrollView)
        var xPos:CGFloat = 20
        var yPos:CGFloat = 40
        
        let btnEdit: UIButton = BaseUIController().AButtonFrame(CGRect(x:self.view.frame.width - 40, y: 10 ,width: 20 ,height: 20), withButtonTital: "")as! UIButton
        btnEdit.setImage(#imageLiteral(resourceName: "edit_red_icon"), for: UIControlState())
        btnEdit.addTarget(self, action: #selector(PickUpDetailsViewController.btnEditOnClick(_:)), for: .touchUpInside)
        scrollView.addSubview(btnEdit)
        
        var labelName: [String] = ["Address Line 1" , "Address Line 2" , "Landmark", "City", "Locality"]
        
        let lblSaved = BaseUIController().ALabelFrame(CGRect(x: btnEdit.frame.origin.x - 130 , y: 10 , width: 120 , height: 21), withString: "Saved Addresses")as! UILabel
        
        lblSaved.font = KROBOTO_Light_19//UIFont().mediumFont
        scrollView.addSubview(lblSaved)
        
        
        for i in (0..<labelName.count) {
//            let label = BaseUIController().ALabelFrame(CGRect(x:xPos , y: yPos ,width: 200 , height: 30 ), withString: labelName[i])as! UILabel
//            label.font = KROBOTO_Light_18//UIFont().mediumFont
//            scrollView.addSubview(label)
//            yPos += 21+4;
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
        
        let lblPincode :UILabel = BaseUIController().ALabelFrame(CGRect(x: xPos , y: yPos + 5, width:  80 , height: 21), withString: "Pincode :")as! UILabel
        lblPincode.font = KROBOTO_Light_16//UIFont().mediumFont
        scrollView.addSubview(lblPincode)
        
       
        xPos =  90
        let _width: CGFloat = (self.view.frame.width - (xPos + 20 + 50 ))/6
        
        
        for i in (0..<6) {
            
            let textField = UITextField(frame: CGRect(x: xPos , y: yPos ,width: _width , height: _width ))
//            let textField = BaseUIController().ATextFiedlFrame(CGRect(x: xPos , y: yPos ,width: _width , height: _width ), withPlaceHolder: "")as! UITextField
            textField.borderStyle = .line
            textField.layer.borderWidth = 1.5
            textField.layer.cornerRadius = 4.0
            textField.layer.masksToBounds = true
            textField.layer.borderColor =  UIColor.lightGray.cgColor//UIColor.lightGray.cgColor//UIColor.init(red: (242.0/255.0), green: (237.0/255.0), blue: (237.0/255.0), alpha: 1.0).cgColor
            textField.font = KROBOTO_Regular_21
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
        let btnContinue = BaseUIController().AButtonFrame(CGRect(x: 0 , y: scrollView.frame.height , width: self.view.frame.width, height: 40), withButtonTital: "Continue")as! UIButton
        btnContinue.backgroundColor =  KRED_COLOR//UIColor .init(red: (235.0/255.0), green: (235.0/255.0), blue: (235.0/255.0), alpha: 1)
        btnContinue.titleLabel?.font = KROBOTO_Light_15//UIFont().largeFont
        btnContinue.setTitleColor(UIColor.white, for: UIControlState())
        btnContinue.addTarget(self, action: #selector(PickUpDetailsViewController.btnContinueOnClick(_:)), for: .touchUpInside)
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: scrollView.frame.height + 70)
        
        self.view.addSubview(btnContinue)
        
        
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
        txtLocality.addTarget(self, action: #selector(PickUpDetailsViewController.textFieldDidChange), for: .editingChanged)
        
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
    func populatePickupAddressDetailsInfo()  {
        txtAddressLine1.text = pickupAddressObj.AddressLine1
        txtAddressLine2.text = pickupAddressObj.AddressLine2
        txtLandMark.text = pickupAddressObj.LandMark
        txtCity.text = pickupAddressObj.City
        txtLocality.text = pickupAddressObj.GeoAddress
        let pinCode = pickupAddressObj.Pincode
        
        
        if pinCode != "" {
            txtPin1.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 0)])
            txtPin2.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 1)])
            txtPin3.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 2)])
            txtPin4.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 3)])
            txtPin5.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 4)])
            txtPin6.text = String(pinCode[pinCode.characters.index(pinCode.startIndex, offsetBy: 5)])
        }
        
    }
    func createExtraTestLayout()  {
        bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        bgView.tag = 500
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        UIApplication.shared.keyWindow?.addSubview(bgView);
        
        print(arrGetExtraPackage.count)
        
//        extraTestPkgTableView = UITableView(frame:CGRectMake(10, 30,(UIScreen.mainScreen().bounds.width) - 20, UIScreen.mainScreen().bounds.height - 85))
//        extraTestPkgTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell2")
//        extraTestPkgTableView.backgroundColor = UIColor .whiteColor()
//        extraTestPkgTableView.separatorStyle = UITableViewCellSeparatorStyle.None
//        extraTestPkgTableView.dataSource = self
//        extraTestPkgTableView.delegate = self
//        bgView.addSubview(extraTestPkgTableView)
        let extraTestView = UIView.init(frame: CGRect(x: 10, y: 30, width: (UIScreen.main.bounds.width) - 20, height: UIScreen.main.bounds.height - 85))
        bgView.addSubview(extraTestView)
        extraTestView.backgroundColor = UIColor.white
        extraTestScrollView = UIScrollView.init(frame: CGRect(x: 0, y: 30, width: (UIScreen.main.bounds.width) - 20, height: UIScreen.main.bounds.height - 85))
        extraTestView.addSubview(extraTestScrollView)
        let label = BaseUIController().ALabelFrame(CGRect(x: 10 , y: 5 ,width: 200 , height: 21), withString: "WHY NOT TRY?")as! UILabel
        label.font = UIFont().largeFont
        extraTestView.addSubview(label)
        
        let lblFirstLine = BaseUIController().ALabelFrame(CGRect(x: 0, y: 1, width: self.view.frame.width, height: 0.5), withString: "")as! UILabel
        lblFirstLine.backgroundColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1)
        extraTestScrollView.addSubview(lblFirstLine)
        
        var yPox:CGFloat = 5
        
         for i in 0..<arrGetExtraPackage.count {
            
            let lblTestName = BaseUIController().ALabelFrame(CGRect(x: 5, y: yPox, width: extraTestView.frame.width - 90, height: 0), withString: "")as! UILabel
            lblTestName.text = (arrGetExtraPackage.object(at: i) as AnyObject).value(forKey: "pkg_name")as? String
            lblTestName.sizeToFit()
            extraTestScrollView.addSubview(lblTestName)
            yPox += 30
            let lblPrice = BaseUIController().ALabelFrame(CGRect(x: 5, y: yPox, width: extraTestView.frame.width - 90, height: 20), withString: "")as! UILabel
            lblPrice.text = currencySymbol + ((arrGetExtraPackage.object(at: i) as AnyObject).value(forKey: "pkg_price")as? String)!
            extraTestScrollView.addSubview(lblPrice)
            
            
            
            let btnMinus = BaseUIController().AButtonFrame(CGRect(x: extraTestView.frame.width - 80 , y: yPox - 25, width: 30, height: 30), withButtonTital: "-")as! UIButton
            btnMinus.tag = i + 2000
            btnMinus.addTarget(self, action: #selector(PickUpDetailsViewController.btnMinusOnClick(_:)), for: .touchUpInside)
            btnMinus.titleLabel?.font = UIFont().mediumFont
            extraTestScrollView.addSubview(btnMinus)
           let lblCount = BaseUIController().ALabelFrame(CGRect(x: extraTestView.frame.width - 55 ,y: yPox - 25 ,width: 20 , height : 30), withString: "0")as! UILabel
            lblCount.textAlignment = .center
            lblCount.font = UIFont().mediumFont
            lblCount.tag =  i + 1000 //indexPath.row + 1000
            extraTestScrollView.addSubview(lblCount)
            
            let btnPlus = BaseUIController().AButtonFrame(CGRect(x: extraTestView.frame.width - 35 , y: yPox - 25, width: 30, height: 30), withButtonTital: "+")as! UIButton
            btnPlus.tag = i + 3000
            btnPlus.addTarget(self, action: #selector(PickUpDetailsViewController.btnPlusOnClick(_:)), for: .touchUpInside)
            btnPlus.titleLabel?.font = UIFont().smallFont
            extraTestScrollView.addSubview(btnPlus)
            
            yPox += 20
           
            let seprationLine = BaseUIController().ALabelFrame(CGRect(x: 0, y: yPox, width: self.view.frame.width, height: 0.5), withString: "")as! UILabel
            seprationLine.backgroundColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1)
            extraTestScrollView.addSubview(seprationLine)
             yPox += 5
            
        }
        extraTestScrollView.contentSize = CGSize(width: extraTestView.frame.width, height: yPox + 30)
        
        
        
        let btnNotNow = BaseUIController().AButtonFrame(CGRect(x: 10 , y: UIScreen.main.bounds.height - 50 , width: UIScreen.main.bounds.width / 2 - 12   , height: 40), withButtonTital: "Not Now")as! UIButton
        btnNotNow.backgroundColor = KRED_COLOR//UIColor .init(red: (235.0/255.0), green: (235.0/255.0), blue: (235.0/255.0), alpha: 1)
        btnNotNow.titleLabel?.font = UIFont().largeFont
        btnNotNow.setTitleColor(UIColor.white, for: UIControlState())
        btnNotNow.addTarget(self, action: #selector(PickUpDetailsViewController.btnNotNowOnClick(_:)), for: .touchUpInside)
        bgView.addSubview(btnNotNow)
        
        btnAdd = BaseUIController().AButtonFrame(CGRect(x: btnNotNow.frame.width + 12 , y: UIScreen.main.bounds.height - 50 , width: UIScreen.main.bounds.width / 2 - 12   , height: 40), withButtonTital: String(format: "Add %@ 0",currencySymbol))as! UIButton
        btnAdd.backgroundColor = KRED_COLOR //UIColor .init(red: (235.0/255.0), green: (235.0/255.0), blue: (235.0/255.0), alpha: 1)
        btnAdd.titleLabel?.font = UIFont().largeFont
        btnAdd.setTitleColor(UIColor.white, for: UIControlState())
        btnAdd.addTarget(self, action: #selector(PickUpDetailsViewController.btnAddOnClick(_:)), for: .touchUpInside)
        bgView.addSubview(btnAdd)
        
        //        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PickUpDetailsViewController.tappedOnBGView(_:)))
        //        tapped.numberOfTapsRequired = 1
        //        bgView.addGestureRecognizer(tapped)
        
        //set activity on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        bgView.addSubview(activityIndicator!)
    }
    
    func showExtraSelectedPackageListByMember()  {
        bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        bgView.tag = 500
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        UIApplication.shared.keyWindow?.addSubview(bgView);
        
        extraSelecteTestPkgTableView = UITableView(frame:CGRect(x: 10, y: 30,width: (UIScreen.main.bounds.width) - 20, height: UIScreen.main.bounds.height - 85))
        extraSelecteTestPkgTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell3")
        extraSelecteTestPkgTableView.backgroundColor = UIColor.white
        extraSelecteTestPkgTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        extraSelecteTestPkgTableView.dataSource = self
        extraSelecteTestPkgTableView.delegate = self
        bgView.addSubview(extraSelecteTestPkgTableView)
        
        let bottomView = UIView.init(frame: CGRect(x: 10, y: extraSelecteTestPkgTableView.frame.height + 30 , width: UIScreen.main.bounds.width - 20 , height: 40))
        bottomView.backgroundColor =  UIColor (red: (209.0/255.0), green: (209.0/255.0), blue: (209.0/255.0), alpha: 1)
        bgView.addSubview(bottomView)
        
        let btnDone = BaseUIController().AButtonFrame(CGRect(x: extraSelecteTestPkgTableView.frame.width  - 100 , y: 5  , width: 100 , height: 30), withButtonTital: "Done")as! UIButton
        btnDone.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20)
        btnDone.titleLabel?.font = UIFont().largeFont
        btnDone.addTarget(self, action: #selector(PickUpDetailsViewController.btnDoneOnClick(_:)), for: .touchUpInside)
        bottomView.addSubview(btnDone)
        
        
    }
    func showOldPickAddress()  {
        bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        bgView.tag = 500
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        UIApplication.shared.keyWindow?.addSubview(bgView);
        
        pickupAddressTableView = UITableView(frame:CGRect(x: 10, y: ((UIScreen.main.bounds.height/2)-(90)),width: bgView.bounds.width - 20, height: 180))
        pickupAddressTableView.separatorStyle = .none
        // inviteTableView.scrollEnabled = false
        pickupAddressTableView.layer.cornerRadius = 4.0
        pickupAddressTableView.tag = 501
        pickupAddressTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell4")
        pickupAddressTableView.backgroundColor = UIColor.clear
        self.pickupAddressTableView.delegate      =   self
        self.pickupAddressTableView.dataSource    =   self
        bgView.addSubview(pickupAddressTableView)
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PickUpDetailsViewController.tappedOnBGView(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        bgView.addGestureRecognizer(tapped)
        self.pickupAddressTableView.reloadData()

    }
    
    
    

    //MARK: TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        switch textField {
        case txtAddressLine1:
            txtAddressLine2.becomeFirstResponder()
        case txtAddressLine2:
            txtLandMark.becomeFirstResponder()
        case txtAddressLine2:
            txtLandMark.becomeFirstResponder()
        default:
            break
        }
        return true
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == autocompleteTableView {
            print(arrGeoAddressDetails.count)
            return  arrGeoAddressDetails.count
        }else if  tableView == extraSelecteTestPkgTableView{
            print(arrSortSelectedTestPackage.count)
            return arrSortSelectedTestPackage.count
        }else if(tableView == pickupAddressTableView){
            return arrOldPickupAddress.count
        }else{
            return arrGetExtraPackage.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = UITableViewCell()
        if tableView == autocompleteTableView {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
            
//            cell.textLabel?.text = (arrGeoAddressDetails[indexPath.row] as! NSMutableDictionary).o ["description"] as! String
            
            cell.textLabel?.text = (arrGeoAddressDetails[indexPath.row] as! NSMutableDictionary).value(forKey: "description") as? String

            
//            .value(forKey: "pincode")as! String
            
                //[(indexPath as NSIndexPath).row] as! Dictionary<String, String>)["description"] as! String
            //arrGeoAddressDetails.objectAtIndex(indexPath.row).valueForKey("address") as? String
            cell.textLabel?.font = UIFont().mediumFont
            cell.backgroundColor = UIColor.gray
        }else if(tableView == extraSelecteTestPkgTableView){
//             cell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell3")
//             cell.textLabel?.font = UIFont().mediumFont
//             cell.textLabel?.text = arrSortSelectedTestPackage.objectAtIndex(indexPath.row).valueForKey("pkg_name")as? String
             let lblTestName = BaseUIController().ALabelFrame(CGRect(x: 5, y: 10, width: extraSelecteTestPkgTableView.frame.width - 120, height: 40), withString: "")as! UILabel
             lblTestName.text = (arrSortSelectedTestPackage.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "pkg_name")as? String
             lblTestName.sizeToFit()
             cell.addSubview(lblTestName)
            
            
            memberNamePickerView = UIPickerView(frame: CGRect(x: extraSelecteTestPkgTableView.frame.width - 110 , y: -10 , width: 100, height: 70 ))
            memberNamePickerView.dataSource = self
            memberNamePickerView.delegate = self
            memberNamePickerView.tag = 1001 + (indexPath as NSIndexPath).row
            cell.addSubview(memberNamePickerView)
            extraSelecteTestPkgTableView.separatorStyle = .singleLine
            
        }else if (tableView == pickupAddressTableView){
            cell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell4")
            cell.textLabel?.font = UIFont().mediumFont
            let address_line1 = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "a_address_line_1")as? String
            let address_line2 = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "a_address_line_2")as? String
            let landmark = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "a_landmark")as? String
            let pincode = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "a_pincode")as? String
            let cityName = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "city_name")as? String
            let geo_address = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "geo_address")as? String
            pickup_Id = ((arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "opick_id")as? String)!
            
            let fullAddress = String(format: "%@ , %@,%@,%@,%@ %@", address_line1! ,address_line2! , landmark! ,geo_address! ,cityName! , pincode!)
            cell.textLabel?.text = fullAddress
            cell.textLabel?.numberOfLines = 2
            
          //cell.textLabel?.text = arrOldPickupAddress.objectAtIndex(indexPath.row).valueForKey("city_name")as? String
            
        }
        else{
        /*    cell = tableView.dequeueReusableCellWithIdentifier("cell2", forIndexPath: indexPath) as UITableViewCell
            
            //cell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell2")
            cell.selectionStyle = .None
            print(indexPath.row)
//            cell.textLabel?.font = UIFont().mediumFont
//            cell.textLabel?.text = arrGetExtraPackage.objectAtIndex(indexPath.row).valueForKey("pkg_name")as? String
//            cell.detailTextLabel?.font = UIFont().mediumFont
//            cell.detailTextLabel?.text = currencySymbol + (arrGetExtraPackage.objectAtIndex(indexPath.row).valueForKey("pkg_price")as? String)!
            let lblTestName = BaseUIController().ALabelFrame(CGRectMake(5, 5, extraTestPkgTableView.frame.width - 90, 0), withString: "")as! UILabel
            lblTestName.text = arrGetExtraPackage.objectAtIndex(indexPath.row).valueForKey("pkg_name")as? String
            lblTestName.sizeToFit()
            cell.addSubview(lblTestName)
            let lblPrice = BaseUIController().ALabelFrame(CGRectMake(5, 35, extraTestPkgTableView.frame.width - 90, 20), withString: "")as! UILabel
            lblPrice.text = currencySymbol + (arrGetExtraPackage.objectAtIndex(indexPath.row).valueForKey("pkg_price")as? String)!
            cell.addSubview(lblPrice)
            
            
            
            
            let btnMinus = BaseUIController().AButtonFrame(CGRectMake(extraTestPkgTableView.frame.width - 80 , 10, 30, 30), withButtonTital: "-")as! UIButton
            btnMinus.addTarget(self, action: #selector(PickUpDetailsViewController.btnMinusOnClick(_:)), forControlEvents: .TouchUpInside)
            btnMinus.titleLabel?.font = UIFont().mediumFont
            cell.addSubview(btnMinus)
            lblCount = BaseUIController().ALabelFrame(CGRect(x: extraTestPkgTableView.frame.width - 55 ,y: 10 ,width: 20 , height : 30), withString: "0")as! UILabel
            lblCount.textAlignment = .Center
            lblCount.font = UIFont().mediumFont
            lblCount.tag = indexPath.row + 1000
            cell.addSubview(lblCount)

            let btnPlus = BaseUIController().AButtonFrame(CGRectMake(extraTestPkgTableView.frame.width - 35 , 10, 30, 30), withButtonTital: "+")as! UIButton
           
            btnPlus.addTarget(self, action: #selector(PickUpDetailsViewController.btnPlusOnClick(_:)), forControlEvents: .TouchUpInside)
            btnPlus.titleLabel?.font = UIFont().smallFont
            cell.addSubview(btnPlus)
            extraTestPkgTableView.separatorStyle = .SingleLine  */
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        var pinCode = ""
        
        if tableView == autocompleteTableView {
            autocompleteTableView.isHidden = true
            if arrGeoAddressDetails.count != 0
            {
            dictPickupDetailsValue = arrGeoAddressDetails[(indexPath as NSIndexPath).row] as! NSMutableDictionary
            pinCode = (arrGeoAddressDetails.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "pincode")as! String
            txtLocality.text = (arrGeoAddressDetails[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "address")as? String
            }
        }
        else if (tableView == pickupAddressTableView)
            {
                let address_line1 = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "a_address_line_1")as? String
                let address_line2 = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "a_address_line_2")as? String
                let landmark = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "a_landmark")as? String
                pinCode = ((arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "a_pincode")as? String)!
                let cityName = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "city_name")as? String
                let geo_address = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "geo_address")as? String
                txtAddressLine1.text = address_line1
                txtAddressLine2.text = address_line2
                txtLandMark.text = landmark
                txtCity.text = cityName
                txtLocality.text = geo_address
                bgView.removeFromSuperview()
                
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
        if tableView == autocompleteTableView {
            return  30;
        }else{
            return  60;
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if autocompleteTableView == tableView {
          return 0;
        }else{
          return 30;
        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 10, width: tableView.bounds.size.width, height: 30))
        headerView.backgroundColor = UIColor.white
        let label = BaseUIController().ALabelFrame(CGRect(x: 10 , y: 5 ,width: 200 , height: 21), withString: "WHY NOT TRY?")as! UILabel
        label.font = UIFont().largeFont
        if tableView == extraSelecteTestPkgTableView {
            label.text = "Assign Members "
        }else if(tableView == pickupAddressTableView){
           label.text = "SAVED ADDRESSES"
        }
        headerView.addSubview(label)
         let lblLine = BaseUIController().ALabelFrame(CGRect(x: 0 , y: 29 ,width: self.view.frame.width , height: 1), withString: "")as! UILabel
        lblLine.backgroundColor = KRED_COLOR
        headerView.addSubview(lblLine)
        
        return headerView
    }
    
    
    //MARK: PickerViewDelegate
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerView == cityPickerView {
            return arrCityName.count
        }else{
            return arrMemberNameList.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == cityPickerView {
           return arrCityName[row]
        }else{
           return arrMemberNameList[row] as? String
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView == cityPickerView {
           txtCity.text = "\(arrCityName[row])"
        }else{
           print(arrMemberNameList[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        if pickerView == cityPickerView {
            pickerLabel.text = arrCityName[row]
            pickerLabel.textColor = UIColor.black
            pickerLabel.font = KROBOTO_Regular_17//UIFont().mediumFont
        }else{
            pickerLabel.text = arrMemberNameList[row] as? String
            pickerLabel.font = KROBOTO_Light_14
        }
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        if pickerView == cityPickerView {
            return 30;
        }else{
            return 15;
        }
        
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

    // MARK: - KeyboardShow&Hide
//    func keyboardWillShow(_ notification:Notification){
//       
////        print(notification)
////        
////        scrollView.frame = CGRect(x: 0 , y: -30 , width: self.view.frame.width , height: scrollView.frame.height)
////        scrollView.contentSize = CGSizeMake(self.view.frame.width, scrollView.frame.height + 250)
//        
//        if activeTextField == txtLandMark || activeTextField == txtCity || activeTextField == txtLocality || activeTextField == txtPin1 || activeTextField == txtPin2 || activeTextField == txtPin3 || activeTextField == txtPin4 || activeTextField == txtPin5 || activeTextField == txtPin6 {
//            scrollView.frame = CGRect(x: 0 , y: -120 , width: scrollView.frame.width , height: scrollView.frame.height)
//        }else{
//            scrollView.frame = CGRect(x: 0 , y: 0 , width: scrollView.frame.width , height: scrollView.frame.height )
//            
//        }
//    }
    
//    func keyboardWillHide(_ notification:Notification){
////        scrollView.frame = CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: scrollView.frame.height)
////        scrollView.contentSize = CGSizeMake(self.view.frame.width, scrollView.frame.height + 250)
//        
//        if activeTextField == txtLandMark || activeTextField == txtCity || activeTextField == txtLocality || activeTextField == txtPin1 || activeTextField == txtPin2 || activeTextField == txtPin3 || activeTextField == txtPin4 || activeTextField == txtPin5 || activeTextField == txtPin6  {
//            scrollView.frame = CGRect(x: 0 , y: 0 , width: scrollView.frame.width , height: scrollView.frame.height )
//        }else{
//            scrollView.frame = CGRect(x: 0 , y: 0 , width: scrollView.frame.width , height: scrollView.frame.height )
//            
//        }
//
//        
//    }
    
    
    //MARK: textFieldDelegate
    func textFieldDidChange()  {
//        self.getGEOLocation(String(format: "http://maps.google.com/maps/api/geocode/json?address=%@&sensor=false&components=country:IN",txtLocality.text!))
        
       //  self.getGEOLocation(String(format: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input= \(txtLocality.text!)&types=geocode&language=en&key=AIzaSyCoEvSzsfnL5WPUw4WF2KAWmekxkO6qgI8&components=country:IN"))
        
//         gpaViewController = GooglePlacesAutocomplete(
//            apiKey: "AIzaSyCoEvSzsfnL5WPUw4WF2KAWmekxkO6qgI8",
//            placeType: .Address
//        )
//        
//        gpaViewController.placeDelegate = self // Conforms to GooglePlacesAutocompleteDelegate
//        
//        presentViewController(gpaViewController, animated: true, completion: nil)
       
    }
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
        }
        
        dismiss(animated: false) {
            
            
        }
        
    }
    func placeViewClosed() {
        
        gpaViewController.dismiss(animated: true) { 
            
        }
       // self.navigationController?.popViewControllerAnimated(true)
        
        
    }
    //MARK: textFieldDelegate
    func getGEOLocation(_ addressUrl : String)  {
        
        
        print(addressUrl)
        
        
        let urlPath: String = addressUrl
        let escapedAddress = urlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url: URL = URL(string: escapedAddress!)!
        let request1: URLRequest = URLRequest(url: url)
        let queue:OperationQueue = OperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: URLResponse?, data: Data?, error: NSError?) -> Void in
            
            do {
                if (data != nil){
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    
                    
                    
                    print("ASynchronous\(jsonResult)")
                    self.arrGeoAddressDetails = (jsonResult["predictions"] as? NSMutableArray)!
                    self.autocompleteTableView.isHidden = false
                    self.autocompleteTableView.reloadData()
                    
                    
                    
                    //self.filterGeoLocation(jsonResult)
                }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            
        } as! (URLResponse?, Data?, Error?) -> Void)
        
    }
    func filterGeoLocation(_ locationData : NSDictionary)  {
        let arrGeoLocaiton = locationData.value(forKey: "results") as! NSArray
       arrGeoAddressDetails = NSMutableArray()
       //arrpinCode  = NSMutableArray()
       autocompleteTableView.isHidden = false
        
        for i in 0..<(arrGeoLocaiton ).count {
            let arrAddressComponent = (arrGeoLocaiton[i] as! NSMutableDictionary).value(forKey: "address_components") as! NSArray

            let dictLocation = arrGeoLocaiton as! NSDictionary
      //      let arrAddressComponent = arrGeoLocaiton![i].value(forKey: "address_components")
            for k in 0..<arrAddressComponent.count {
                let dict = arrAddressComponent[k] as! NSDictionary
                
                let arrtypes = dict.value(forKey: "types")as! [String]
                print(arrtypes)
                let cityName = dict.value(forKey: "long_name")as! String
                let arr = ["locality" , "political"]
                if arrtypes == arr  {
                    if txtCity.text?.lowercased() == cityName.lowercased() {
                        let address = dictLocation.value(forKey: "formatted_address")as! String
                        let lat = (((dictLocation.value(forKey: "geometry"))! as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lat")as! NSNumber
                        let lng = (((dictLocation.value(forKey: "geometry"))! as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lng")as! NSNumber
                        dictValue.setValue("\(lat)", forKey: "lat")
                        dictValue.setValue("\(lng)", forKey: "lng")
                        
                        print(address)
                        let arrtypes = (arrAddressComponent[(arrAddressComponent.count)-1] as! NSDictionary).value(forKey: "types")as! [String]
                        print(arrtypes)
                        let arr = ["postal_code"]
                        if arrtypes == arr  {
                            dictValue.setValue((arrAddressComponent[(arrAddressComponent.count)-1] as! NSDictionary).value(forKey: "long_name")as! String, forKey: "pincode")
                           
                          //  arrpinCode .addObject(arrAddressComponent![(arrAddressComponent?.count)!-1].valueForKey("long_name")as! String)
                           
                        }else{
//                             arrpinCode .addObject("")
                            dictValue.setValue("", forKey: "pincode")
                        }
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                           // self.arrGeoAddressList.addObject(address)
                            self.dictValue.setValue(address, forKey: "address")
                            self.arrGeoAddressDetails.add(self.dictValue)
                            let count = self.arrGeoAddressDetails.count
                            self.autocompleteTableView.frame = CGRect(x: 10 , y: (self.txtLocality.frame.origin.y - 30 * CGFloat(count))-2, width: self.view.frame.width - 20, height: 30 * CGFloat(count))
                            
                                self.autocompleteTableView.isHidden = false
                                self.autocompleteTableView.reloadData()
                            
                        })
                    }
                }
            }
        }
    }
    /*
     {
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
     */
    //MARK: buttonOnclick
    func btnContinueOnClick(_ button : UIButton)  {
        let trimAddress1 = txtAddressLine1.text?.trimmingCharacters(in: .whitespaces)
        if maxCount == 0  {
            self.present(BaseUIController().showAlertView("Please Select a test to Continue Booking order."), animated: true, completion: nil)
        }
        else if trimAddress1?.isEmpty == true {
            self.present(BaseUIController().showAlertView("Please Enter Your Address"), animated: true, completion: nil)
        }else if(txtCity.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please Select Your City"), animated: true, completion: nil)
            
        }else if (txtLocality.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please Enter your Locality"), animated: true, completion: nil)
            
        }else  if ((txtPin1.text?.isEmpty == true) || (txtPin2.text?.isEmpty == true) || (txtPin3.text?.isEmpty == true) || (txtPin4.text?.isEmpty == true) || (txtPin5.text?.isEmpty == true) || (txtPin6.text?.isEmpty == true)){
             self.present(BaseUIController().showAlertView("Please fill Pincode!"), animated: true, completion: nil)
        }else{
            self.updateOrderPackagePurchased()
            self.insertPickupDetailsInDataBase()
            //self.createExtraTestLayout()
            //set activity on view
            activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
            self.view.addSubview(activityIndicator!)
            self.getExtraTest()
        }
        
        
    }
    func btnPlusOnClick(_ button : UIButton)  {
        
//        let buttonPosition = button.convertPoint(CGPointZero, toView: extraTestPkgTableView)
//        let indexPath = extraTestPkgTableView.indexPathForRowAtPoint(buttonPosition)
        let indexPath = button.tag
        let lblCount = extraTestScrollView.viewWithTag((indexPath - 2000))as! UILabel
        let totalCount = Int(lblCount.text!)
        if totalCount < maxCount {
            lblCount.text = String(totalCount! + 1)
            let price = Int((arrGetExtraPackage.object(at: indexPath - 3000) as AnyObject).value(forKey: "pkg_price")as! String)
            totalSelectedPrice = totalSelectedPrice + (price! * 1)
//            String(format: "Continue(%@)",currencySymbol + String(price)
            btnAdd.setTitle(String(format: "Add(%@)",currencySymbol + String(totalSelectedPrice)), for: UIControlState())
            arrSelectedTestPackage.add(arrGetExtraPackage.object(at: indexPath - 3000))
            
        }
    }
    func btnMinusOnClick(_ button: UIButton)  {
        
//        let buttonPosition = button.convertPoint(CGPointZero, toView: extraTestPkgTableView)
//        let indexPath = extraTestPkgTableView.indexPathForRowAtPoint(buttonPosition)
        
        let indexPath = button.tag
        
        let lblCount = extraTestScrollView.viewWithTag((indexPath - 1000))as! UILabel
        let totalCount = Int(lblCount.text!)
        if totalCount != 0 {
            lblCount.text = String(totalCount! - 1)
            let price = Int((arrGetExtraPackage.object(at: (indexPath - 2000)) as AnyObject).value(forKey: "pkg_price")as! String)
             totalSelectedPrice = totalSelectedPrice - (price! * 1)
            btnAdd.setTitle(String(format: "Add(%@)",currencySymbol + String(totalSelectedPrice)), for: UIControlState())
            arrSelectedTestPackage.remove(arrGetExtraPackage.object(at: indexPath - 2000))
        }
    }
    func btnNotNowOnClick(_ button: UIButton)  {
        
        bgView.isHidden = true
        bgView.removeFromSuperview()
        totalSelectedPrice = 0
        let checkOutVC = CheckOutViewController()
        self.navigationController?.pushViewController(checkOutVC, animated: true)

        
        
    }
    func btnAddOnClick(_ button: UIButton)  {
         self.getPackagePurchasedMemberName()
        
        if totalSelectedPrice == 0   {
            bgView.isHidden = true
            bgView.removeFromSuperview()
            totalSelectedPrice = 0
            let checkOutVC = CheckOutViewController()
            self.navigationController?.pushViewController(checkOutVC, animated: true)
        }else if(arrMemberNameList.count == 1){
            bgView.isHidden = true
            bgView.removeFromSuperview()
            let memberName = arrMemberNameList.object(at: 0) as! String
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: "pkg_name", ascending: true)
//            arrSortSelectedTestPackage = arrSelectedTestPackage.sortedArray(using: [descriptor])
            
            arrSortSelectedTestPackage = arrSelectedTestPackage.sortedArray(using: [descriptor]) as NSArray

            for i in 0..<arrSortSelectedTestPackage.count {
             self.insertOrderPackageInDB(arrSortSelectedTestPackage[i] as! NSDictionary, memberId: dictMemberNameList.value(forKey: memberName)as! String)
            }
            let checkOutVC = CheckOutViewController()
            self.navigationController?.pushViewController(checkOutVC, animated: true)
           
        
        }else{
            arrSortSelectedTestPackage = NSMutableArray()
            bgView.isHidden = true
            bgView.removeFromSuperview()
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: "pkg_name", ascending: true)
//            arrSortSelectedTestPackage = arrSelectedTestPackage.sortedArray(using: [descriptor])
            
            arrSortSelectedTestPackage = arrSelectedTestPackage.sortedArray(using: [descriptor]) as NSArray
            self.showExtraSelectedPackageListByMember()
            arrSelectedTestPackage.removeAllObjects()
        }
    }
    func btnDoneOnClick(_ button: UIButton)  {
        
        for i in 0..<arrSortSelectedTestPackage.count {
            let indexPath = IndexPath(row: i, section: 0)
            
            let cell = extraSelecteTestPkgTableView.cellForRow(at: indexPath)
            let picker = cell?.viewWithTag(1001 + i)as! UIPickerView
            print(picker.selectedRow(inComponent: 0))
            let index = picker.selectedRow(inComponent: 0)
            let memberName = arrMemberNameList.object(at: index) as! String
            //get id of family Member
            self.insertOrderPackageInDB(arrSortSelectedTestPackage[i] as! NSDictionary, memberId: dictMemberNameList.value(forKey: memberName)as! String)
            print(dictMemberNameList.value(forKey: memberName))
            
            
        }
        bgView.removeFromSuperview()
        totalSelectedPrice = 0
        let checkOutVC = CheckOutViewController()
        self.navigationController?.pushViewController(checkOutVC, animated: true)
    }
    
    func btnEditOnClick(_ button : UIButton)  {
        self.getCustomerAddress()
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
           // self.insertUpdatePickupAddress()
            
        }
    }
    //MARK: removeBGView
    func tappedOnBGView(_ sender: UITapGestureRecognizer)  {
        
        bgView.isHidden = true
        bgView.removeFromSuperview()
    }
    //MARK: dataBaseOperation
    func insertPickupDetailsInDataBase() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        do {
            
            try database.executeUpdate("delete from PickupAddress", values: nil)
            
            let memberId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let addressLine_1 = txtAddressLine1.text
            let addressLine_2 = txtAddressLine2.text
            let landMark = txtLandMark.text
            let city = txtCity.text
            let pinCode = txtPin1.text!+txtPin2.text!+txtPin3.text!+txtPin4.text!+txtPin5.text!+txtPin6.text!
            let geoAddress = txtLocality.text
            var latitude = ""
            var longitude = ""
            if dictPickupDetailsValue.allKeys.count > 0 {
                 latitude = dictPickupDetailsValue.value(forKey: "lat")as! String
                 longitude = dictPickupDetailsValue.value(forKey: "lng")as! String
            }
            try database.executeUpdate("insert into PickupAddress (MemberId ,AddressLine1  , AddressLine2 , LandMark , City ,Pincode , GeoAddress,Latitude,Longitude ,OrderDay ,OrderDate,OrderTime) values (?,?,?,?,?,?,?,?,?,?,?,?)", values: [memberId, addressLine_1!,addressLine_2!, landMark! ,city!,pinCode,geoAddress!,latitude,longitude,"Tomorrow ","","06:00-06:30"])
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
    }
    
    func insertOrderPackageInDB(_ selectedData : NSDictionary , memberId : String)  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        //let memberId  = NSUserDefaults.standardUserDefaults().valueForKeyPath("selectedMemberId")as! String
        let PackageId = selectedData.value(forKey: "pkg_id")
        let PackageName = selectedData.value(forKey: "pkg_name")
        let PackagePrice = selectedData.value(forKey: "pkg_price")
        let PackageType = selectedData.value(forKey: "pkg_type")
        
        
        do {
            //Check Order Exit or not
            let rs = try database.executeQuery(String(format:"select * from Order_Package_Purchased where OrderId = %@  and PackageId = '%@'",memberId,selectedData.value(forKey: "pkg_id") as! String), values: nil)
            if rs.next() == false {
                 try database.executeUpdate("insert into Order_Package_Purchased (OrderId , PackageId , PackageName , PackagePrice ,PackageType,addedToCart) values (?,?,?,?,?,?)", values: [memberId,PackageId!,PackageName!,PackagePrice!,PackageType!,"0"])
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        
    }
    
    
    func getPickupAddressDetails()  {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        do {
            let rs = try database.executeQuery("select * from PickupAddress ", values: nil)
            if rs.next() == false {  return  }
            while rs.next() {
                pickupAddressObj.MemberId = rs.string(forColumn: "MemberId")
                pickupAddressObj.AddressLine1 = rs.string(forColumn: "AddressLine1")
                pickupAddressObj.AddressLine2 = rs.string(forColumn: "AddressLine2")
                pickupAddressObj.LandMark = rs.string(forColumn: "LandMark")
                pickupAddressObj.City = rs.string(forColumn: "City")
                pickupAddressObj.Pincode = rs.string(forColumn: "Pincode")
                pickupAddressObj.GeoAddress = rs.string(forColumn: "GeoAddress")
                pickupAddressObj.Latitude = rs.string(forColumn: "Latitude")
                pickupAddressObj.Longitude = rs.string(forColumn: "Longitude")
                pickupAddressObj.OrderDay = rs.string(forColumn: "OrderDay")
                pickupAddressObj.OrderDate = rs.string(forColumn: "OrderDate")
                pickupAddressObj.OrderTime = rs.string(forColumn: "OrderTime")
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
        self.populatePickupAddressDetailsInfo()
}
    
    func getTotalMemberCount()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        do {
            let rs = try database.executeQuery("SELECT COUNT(DISTINCT orderId) FROM order_Package_Purchased ", values: nil)
            while rs.next() {
                print("Total Records:", rs.int(forColumn: "COUNT(DISTINCT orderId)"))
                maxCount = Int(rs.int(forColumn: "COUNT(DISTINCT orderId)"))
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
    func getPackagePurchasedMemberName() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        arrMemberNameList = NSMutableArray()
        dictMemberNameList = NSMutableDictionary()
        
        do {
            let rs = try database.executeQuery("SELECT DISTINCT MemberId , MemberName  FROM myFamily CROSS JOIN order_Package_Purchased  where memberid == OrderId;", values: nil)
            while rs.next() {
                arrMemberNameList.add(rs.string(forColumn: "MemberName")as String)
                dictMemberNameList.setValue(rs.string(forColumn: "MemberId"), forKey: rs.string(forColumn: "MemberName"))
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
    func updateOrderPackagePurchased()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
            do {
                
            try database.executeUpdate(("update Order_Package_Purchased set addedToCart = '1' where addedToCart = 0"), values: nil)
              
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            database.close()
    }
    
// MARK: callWebservices
    func getExtraTest() {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            
            let allParameters : NSDictionary = NSDictionary()
            ServerConnectivity().callWebservice(allParameters as! Dictionary<String, String>, resulttagname: "GetExtraTestsResult" ,methodname: "GetExtraTests", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }

    }
    
    func getCustomerAddress() {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
            self.view.addSubview(activityIndicator!)
            activityIndicator?.start()
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let allParameters = ["customerId" : customerId]
            ServerConnectivity().callWebservice(allParameters , resulttagname: "GetCustomerAddressesResult" ,methodname: "GetCustomerAddresses", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
       func getAllResponse(_ allResponse: AnyObject, methodName: String) {
        print(methodName)
     //   print(allResponse)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if allResponse is String &&  allResponse as! String == "" {
                    self.present(BaseUIController().showAlertView("No Record"), animated: true, completion: nil)
                }else if (allResponse is String && allResponse as! String != ""){
                   // self.presentViewController(BaseUIController().showAlertView(allResponse as! String), animated: true, completion: nil)
                     self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }else{
                    if(methodName == "GetCustomerAddresses"){
//                        self.arrOldPickupAddress = allResponse as! NSArray
                        
                        self.arrOldPickupAddress = NSMutableArray(array: self.arrOldPickupAddress.reverseObjectEnumerator().allObjects)
                        
                         let saveAddressViewController =  KMAINSTORYBOARD.instantiateViewController(withIdentifier: "SavedAddressTableViewController") as! SavedAddressTableViewController
                        saveAddressViewController.arrOldPickupAddress = NSArray(array: (allResponse as! NSArray).reverseObjectEnumerator().allObjects)
                        //allResponse as! NSArray
                         let navigationController = UINavigationController(rootViewController: saveAddressViewController)
                         self.navigationController?.present(navigationController, animated: true, completion: nil)
                        
                        saveAddressViewController.selectedAddress = {(addressDict:NSDictionary) in
                          self.fillSelectedDatafrom(addressDict: addressDict)
                        }
                
//                        if self.arrOldPickupAddress.count > 0{
//                            self.showOldPickAddress()
//                        }
                    }else{
                        self.arrGetExtraPackage = allResponse as! NSMutableArray
                       // self.extraTestPkgTableView.reloadData()
                        self.createExtraTestLayout()
                    }
                }
            });
        }); 
    }
    
    func fillSelectedDatafrom(addressDict: NSDictionary){
        let address_line1 = addressDict.value(forKey: "a_address_line_1")as? String
        let address_line2 = addressDict.value(forKey: "a_address_line_2")as? String
        let landmark = addressDict.value(forKey: "a_landmark")as? String
        let pinCode = (addressDict.value(forKey: "a_pincode")as? String)!
        let cityName = addressDict.value(forKey: "city_name")as? String
        let geo_address = addressDict.value(forKey: "geo_address")as? String
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
}
