//
//  CheckOutViewController.swift
//  Health
//
//  Created by HW-Anil on 8/9/16.
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class CheckOutViewController: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource , UITableViewDelegate , UITableViewDataSource , serverTaskComplete ,UIGestureRecognizerDelegate ,UISearchDisplayDelegate , UISearchResultsUpdating , GooglePlacesAutocompleteDelegate   {
    // MARK: variableDeclaration
    let fontSize = UIFont().mediumFont
    var currencySymbol = ""
    var totalAmount = ""
    let pickupAddressObj = PickupAddressInfo()
    var arrPackageOrderData = NSMutableArray()
    var timePickerView : UIPickerView = UIPickerView()
    var arrTime = ["04:00-04:30", "04:30-05:00" ,"05:00-05:30" , "05:30-06:00" , "06:00-06:30" , "06:30-07:00" , "07:00-07:30" , "07:30-08:00" , "08:00-08:30", "08:30-09:00" , "09:00-09:30" , "09:30-10:00" , "10:00-10:30" ,"10:30-11:00" , "11:00-11:30" , "11:30-12:00" , "12:00-12:30" , "13:00-13:30" , "13:30-14:00" , "14:00-14:30" , "14:30-15:00" , "15:00-15:30" , "15:30-16:00" , "16:00-16:30" , "16:30-17:00" , "17:00-17:30" , "17:00-18:00"]
    var arrDay = ["Tomorrow " ,"Day after Tomorrow "]
    var bgView = UIView()
    var lblPickUpDate = UILabel()
    var pickupDay_Time = ""
    var pickupTime = ""
    var pickupDay = ""
    var arrOldPickupAddress = NSMutableArray()
    var activityIndicator : ProgressViewController?
    var pickupAddressTableView = UITableView()
    var lblPickupFullAddress = UILabel()
    var scrollView = UIScrollView()
    var txtCouponCode : UITextField = UITextField()
    var isCouponCodeApply = false
    var isWalletBalanceUse = false
    var afterDiscoutTotalPrice = 0
    var totalDiscout = 0
    var discountPercentage = 0
    var pkg_type = ""
    var coupon_type = ""
    var customGrayColor = UIColor.init(red: (72.0/255.0), green: (72.0/255.0), blue: (72.0/255.0), alpha: 1)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // for barCode Scanner
    var packageTableView: UITableView = UITableView()
    var arrPakageData = NSMutableArray()
    var arrFilterPakageData = NSArray()
    let searchController = UISearchController(searchResultsController: nil)
    let kCellIdentifier = "Cell"
    var lblTestSelectd = UILabel()
    var btnContinue: UIButton = UIButton()
    var packageIdFromBarCode = ""
    var memberListTableView = UITableView()
    var arrMyFamilyList = NSMutableArray()
    var btnMemberName = UIButton()
    var selectedMemberName = ""
    var btnProcess = UIButton()
    var btnAddAnotherMember = UIButton()
    
    // for address 
    var scrollViewForAddress = UIScrollView()
    var txtPin1 = UITextField()
    var txtPin2 = UITextField()
    var txtPin3 = UITextField()
    var txtPin4 = UITextField()
    var txtPin5 = UITextField()
    var txtPin6 = UITextField()
    
    var txtAddressLine1 = UITextField()
    var txtAddressLine2 = UITextField()
    var txtLandMark = UITextField()
    var txtLocality = UITextField()
    var txtCity = UITextField()
    var cityPickerView : UIPickerView = UIPickerView()
    var arrCityName = ["Delhi" , "New Delhi" , "Faridabad", "Ballabhgarh", "Gurgaon" , "Ghaziabad" , "Noida" ,"Greater Noida", "Meerut", "Sonipat","Bahadurgarh"]
    var baseView = UIView()
    var autoPopulateAddressTableView = UITableView()
    
    var arrGeoAddressDetails = NSMutableArray()
    var dictValue = NSMutableDictionary()
    var dictPickupDetailsValue = NSMutableDictionary()
    var latitude = ""
    var longitude = ""
    var pickup_Id = ""
    var addressId = ""
    var gpaViewController = GooglePlacesAutocomplete()
    

    
  //MARK: viewLifeCycleMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        // Do any additional setup after loading the view.
        //set Tital
        self.title = "CHECKOUT "
        self.navigationController!.navigationBar.topItem!.title = "CHECKOUT";
        // get currency sysmbol
//        let currencyCode = "INR"
//        let localeComponents = [NSLocale.Key.currencyCode: currencyCode]
//        let localeIdentifier = Locale.localeIdentifier(fromComponents: localeComponents as! [String : String])
//        let locale = Locale(localeIdentifier: localeIdentifier)
//        currencySymbol = (locale as NSLocale).object(forKey: NSLocale.Key.currencySymbol) as! String
        currencySymbol = (Locale(identifier:"de") as NSLocale).displayName(forKey: .currencySymbol, value: "INR")!
        //check is coming form package id from barcode scanner
        if (packageIdFromBarCode != "") {
            var pkgOrderInfo = PackgeOrederInfo()
            pkgOrderInfo = arrPackageOrderData[0] as! PackgeOrederInfo
            UserDefaults.standard.setValue(pkgOrderInfo.orderId, forKey: "selectedMemberId")
        }else{
            self.getPurchasedPackageData()
        }
        let myFamilyObject = DrawerViewController().loadMyProfile()
        selectedMemberName = myFamilyObject.memberName
        
        arrPakageData = UserDefaults.standard.value(forKey: "allpackages") as! NSMutableArray
        
        
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;
        
        //add button on Bottom
        btnAddAnotherMember = BaseUIController().AButtonFrame(CGRect(x: 0, y: self.view.frame.height - 104, width: self.view.frame.width/2 - 1, height: 40), withButtonTital: "ADD ANOTHER MEMBER")as! UIButton
        btnAddAnotherMember.addTarget(self, action: #selector(self.btnAddAnotherMemberOnClick(_:)), for: .touchUpInside)
        btnAddAnotherMember.backgroundColor = UIColor.red
        btnAddAnotherMember.setTitleColor(UIColor.white, for: UIControlState())
        btnAddAnotherMember.titleLabel?.font = UIFont().smallFont
        self.view.addSubview(btnAddAnotherMember)
        
        btnProcess = BaseUIController().AButtonFrame(CGRect(x: self.view.frame.width/2 + 1, y: self.view.frame.height - 104 , width: self.view.frame.width/2, height: 40), withButtonTital: "PROCEED")as! UIButton
        btnProcess.backgroundColor = UIColor.red
        btnProcess.setTitleColor(UIColor.white, for: UIControlState())
        btnProcess.titleLabel?.font = UIFont().smallFont
        btnProcess.addTarget(self, action: #selector(CheckOutViewController.btnMakePaymentOnClick), for: .touchUpInside)
        self.view.addSubview(btnProcess)
        
        
        self.createALayout()
        // add progress on View 
        
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        self.view.addSubview(activityIndicator!)
        // show & hide keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("PaymentCheckOut Screen")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     //MARK: createALayoutDesign
    
    func createALayout() {
         self.view.backgroundColor =  UIColor.init(red: (236.0/255.0), green: (236.0/255.0), blue: (236.0/255.0), alpha: 1)
        var btnSelectDate = UIButton()
        btnSelectDate.removeFromSuperview()
        var yPos : CGFloat = 10
        btnSelectDate = BaseUIController().AButtonFrame(CGRect(x: 0 , y: yPos , width: self.view.frame.width , height: 40), withButtonTital: "")as! UIButton
        btnSelectDate.addTarget(self, action: #selector(self.btnSelectDateOnClick(_:)), for: .touchUpInside)
        lblPickUpDate = BaseUIController().ALabelFrame(CGRect(x: 5, y: 5, width: 200, height: 20), withString: "")as! UILabel
        lblPickUpDate.font = UIFont().mediumFont
        let _ = self.getPickupAddressDetails()
        lblPickUpDate.text = pickupDay_Time
        btnSelectDate.addSubview(lblPickUpDate)
        let editImageView = BaseUIController().AImageViewFrame(CGRect(x: self.view.frame.width - 40 , y: 5, width: 25, height: 25), withImageName: "edit_black_icon.png")as! UIImageView
        btnSelectDate.addSubview(editImageView)
        self.view.addSubview(btnSelectDate)
        yPos += 40
        if  packageIdFromBarCode != ""{
            btnMemberName.removeFromSuperview()
             btnMemberName =  BaseUIController().AButtonFrame(CGRect(x: 10, y: yPos, width: self.view.frame.width/2, height: 35), withButtonTital: "anil") as! UIButton
            btnMemberName.setImage(UIImage(named: "arrow_down_icon.png"), for: UIControlState())
            btnMemberName.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            btnMemberName.contentHorizontalAlignment = .left
            btnMemberName.imageEdgeInsets = UIEdgeInsetsMake(13, (self.view.frame.width/2 - 30), 13, 10)
            btnMemberName.addTarget(self, action: #selector(btnSelectmemberName(_:)), for: .touchUpInside)
            self.view.addSubview(btnMemberName)
            btnMemberName.setTitle(selectedMemberName, for: UIControlState())
            btnMemberName.setTitleColor(UIColor.red, for: UIControlState())
            
            
            let btnaddPackage = BaseUIController().AButtonFrame(CGRect(x: self.view.frame.width/2 + 20, y: yPos, width: self.view.frame.width/2 - 30, height: 35), withButtonTital: "") as! UIButton
            btnaddPackage.setImage(UIImage(named: "add_packages_icon.png"), for: UIControlState())
            btnaddPackage.titleLabel?.font = UIFont().mediumFont
            btnaddPackage.contentHorizontalAlignment = .left
            btnaddPackage.imageEdgeInsets = UIEdgeInsetsMake(8, 10, 7, (btnaddPackage.frame.width - 30))
            btnaddPackage.addTarget(self, action: #selector(btnAddExtraPackage(_:)), for: .touchUpInside)
            self.view.addSubview(btnaddPackage)
            let lblAddTest = BaseUIController().ALabelFrame(CGRect(x: 40, y: 0, width: 200, height: 35), withString: "ADD TEST")as! UILabel
            lblAddTest.textColor = UIColor.red
            lblAddTest.font =  UIFont.boldSystemFont(ofSize: 14)
            lblAddTest.textAlignment = .left
            btnaddPackage.addSubview(lblAddTest)
            
            btnaddPackage.setTitleColor(UIColor.red, for: UIControlState())
            //set frame of button 
            btnProcess.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 104 , width: UIScreen.main.bounds.width, height: 40)
            btnAddAnotherMember.isHidden = true
           

            yPos += 40
        }
        
        var xPos : CGFloat = 0
        for i in 0..<50 {
            
            let triangelImageView = BaseUIController().AImageViewFrame(CGRect(x: xPos , y: yPos, width: 10, height: 10), withImageName: "triangle.png")as! UIImageView
            self.view.addSubview(triangelImageView)
            xPos += 10
        
        }

        yPos += 10
        
        let headingView = UIView.init(frame: CGRect(x: 0, y: yPos, width: self.view.frame.width, height: 30))
        headingView.backgroundColor = UIColor.white
        self.view.addSubview(headingView)
        
        let lblPackageHeadingName = BaseUIController().ALabelFrame(CGRect(x: 45, y: 5, width: self.view.frame.width - 235, height: 20), withString: "PACKAGE")as! UILabel
        lblPackageHeadingName.textAlignment = .center
        lblPackageHeadingName.textColor = customGrayColor
        lblPackageHeadingName.font = UIFont.boldSystemFont(ofSize: 12)
        headingView.addSubview(lblPackageHeadingName)
        
        let lblMRPHeading = BaseUIController().ALabelFrame(CGRect(x: lblPackageHeadingName.frame.origin.x + lblPackageHeadingName.frame.width + 5, y: 5, width: 50, height: 20), withString: "MRP")as! UILabel
        lblMRPHeading.textAlignment = .center
        lblMRPHeading.textColor = customGrayColor
        lblMRPHeading.font = UIFont.boldSystemFont(ofSize: 12)
        lblMRPHeading.isHidden = true
        headingView.addSubview(lblMRPHeading)
        
        let lblDiscoutHeading = BaseUIController().ALabelFrame(CGRect(x: lblMRPHeading.frame.origin.x + lblMRPHeading.frame.width + 7, y: 5, width: 32, height: 20), withString: "DIST")as! UILabel
        lblDiscoutHeading.textAlignment = .center
        lblDiscoutHeading.textColor = customGrayColor
        lblDiscoutHeading.font = UIFont.boldSystemFont(ofSize: 12)
        lblDiscoutHeading.isHidden = true
        headingView.addSubview(lblDiscoutHeading)
        
        let lblPayableHeading = BaseUIController().ALabelFrame(CGRect(x: lblDiscoutHeading.frame.origin.x + lblDiscoutHeading.frame.width + 10, y: 5, width: 60, height: 20), withString: "PAYABLE")as! UILabel
        lblPayableHeading.textColor = customGrayColor
        lblPayableHeading.font = UIFont.boldSystemFont(ofSize: 12)
        headingView.addSubview(lblPayableHeading)
        
        let lblVerticalleftLine = BaseUIController().ALabelFrame(CGRect(x: 10, y: 0, width: 0.5, height: 30), withString: "")as! UILabel
        lblVerticalleftLine.backgroundColor = UIColor.red
        headingView.addSubview(lblVerticalleftLine)
        
        let lblHorizontalLineOnHeadingView = BaseUIController().ALabelFrame(CGRect(x: 0, y: 29, width: self.view.frame.width, height: 0.5), withString: "")as! UILabel
        lblHorizontalLineOnHeadingView.backgroundColor = customGrayColor
        headingView.addSubview(lblHorizontalLineOnHeadingView)
        yPos += 30
        
        
        print(yPos)
        
        scrollView = UIScrollView.init(frame: CGRect(x: 0, y: yPos, width: self.view.frame.width, height: (UIScreen.main.bounds.height  - ( yPos + 104))))
        scrollView.backgroundColor =  UIColor.init(red: (236.0/255.0), green: (236.0/255.0), blue: (236.0/255.0), alpha: 1)
        self.view.addSubview(scrollView)
        yPos = 0

        
        var lblPackageName = UILabel()
        
        for i in 0..<arrPackageOrderData.count {
            
            var pkgOrderInfoObj = PackgeOrederInfo()
            pkgOrderInfoObj = arrPackageOrderData[i] as! PackgeOrederInfo
            
            // check package id selected from barcode scanner
            
            if (packageIdFromBarCode != pkgOrderInfoObj.packageId &&  packageIdFromBarCode != "") {
                isCouponCodeApply = false
                afterDiscoutTotalPrice += Int(pkgOrderInfoObj.packagePrice)!
            }
            
            lblPackageName = BaseUIController().ALabelFrame(CGRect(x: 15 + 35, y: 20, width: self.view.frame.width - 140 , height: 0), withString: "")as! UILabel // 140 total width of other controll in row 
            lblPackageName.font = fontSize
            lblPackageName.text = pkgOrderInfoObj.packageName
            lblPackageName.sizeToFit()
            
            let mainView = UIView.init(frame: CGRect(x: 0, y: yPos, width: self.view.frame.width, height: lblPackageName.frame.height + 40))
            mainView.backgroundColor = UIColor.white
          //  lblPackageName.frame = CGRectMake(50, 20, self.view.frame.width - 135, lblPackageName.frame.height)
            scrollView.addSubview(mainView)
            let lblLeftVerticalLine = BaseUIController().ALabelFrame(CGRect(x: 10, y: 0, width: 0.5, height: mainView.frame.height), withString: "")as! UILabel
            lblLeftVerticalLine.backgroundColor = UIColor.red
            mainView.addSubview(lblLeftVerticalLine)
            
          //  let userImageView = BaseUIController().AImageViewFrame(CGRectMake(lblLeftVerticalLine.frame.origin.x + 5 , (mainView.frame.height - 30)/2 , 30, 30), withImageName: "user_icon.png")as! UIImageView
            let lblMemberName = BaseUIController().ALabelFrame(CGRect(x: lblLeftVerticalLine.frame.origin.x + 5 , y: (mainView.frame.height - 30)/2 , width: 30, height: 30), withString: "")as! UILabel
            lblMemberName.backgroundColor = UIColor.red
            lblMemberName.textAlignment = .center
            lblMemberName.font = UIFont().regularMediumFont
            lblMemberName.textColor = UIColor.white
            lblMemberName.layer.cornerRadius = lblMemberName.frame.width/2
            lblMemberName.layer.masksToBounds = true
            mainView.addSubview(lblMemberName)
            
            
            print(pkgOrderInfoObj.orderId)
            
            let imageString = self.getMemberImage(pkgOrderInfoObj.orderId)
            
            var name = imageString
            name = name.trimmingCharacters(in: .whitespaces)
            if name.characters.count > 0{
//                Array(name.characters)

                
                let firstIndex = name.startIndex
                let finalLetter = name[firstIndex]
                lblMemberName.text = String(finalLetter)
            }else{
                lblMemberName.text = ""
            }
         /*   if name.components(separatedBy: " ").count
            let firstName = (name.components(separatedBy: " ").first?.uppercased())!
//            let firstName = name.components(separatedBy: " ").first?.uppercased() as? String
//            let firstName: String = name.componentsSeparatedByString(" ").first!.uppercased() as String
            // let secondName: String = name!.componentsSeparatedByString(" ")[1].uppercaseString as String
            let firstLetter = firstName.startIndex
            let finalLetter = firstName[firstLetter]
            lblMemberName.text =  name //String(finalLetter) */
            
//            let data = NSData(base64EncodedString: imageString, options: NSDataBase64DecodingOptions(rawValue: 0))
//            
//            if imageString != "" {
//                userImageView.image = UIImage.init(data: data!)
//            }else{
//                userImageView.image = UIImage(named: "avatar1.png")
//            }

            
            mainView.addSubview(lblPackageName)
            let lblRighttVerticalLine2 = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width - (50 + 30 + 7), y: 0, width: 0.5, height: mainView.frame.height), withString: "")as! UILabel
            lblRighttVerticalLine2.backgroundColor = customGrayColor
            mainView.addSubview(lblRighttVerticalLine2)
           
            
            let lblPackagePrice = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width - (50 + 30 + 5) , y: (mainView.frame.height - 30)/2 , width: 50, height: 30), withString: "3000")as! UILabel
            lblPackagePrice.font = UIFont().smallFont
            lblPackagePrice.text = currencySymbol + String(Int(pkgOrderInfoObj.packagePrice)!)
            mainView.addSubview(lblPackagePrice)
            
            let lblRighttVerticalLine1 = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width - ( 30 + 4), y: 0, width: 0.5, height: mainView.frame.height), withString: "")as! UILabel
            lblRighttVerticalLine1.backgroundColor = customGrayColor
            mainView.addSubview(lblRighttVerticalLine1)
           
            //if coupon codeApply Here
            
            if (isCouponCodeApply) {
                lblPackageHeadingName.isHidden = false
                lblMRPHeading.isHidden = false
                lblDiscoutHeading.isHidden = false
                lblPayableHeading.isHidden = false
                lblPackageName.frame = CGRect(x: lblMemberName.frame.origin.x + 35, y: 20, width: self.view.frame.width - (245), height: 0)// total width of contoller in a row
                lblPackageName.text = pkgOrderInfoObj.packageName
                lblPackageName.sizeToFit()
                mainView.frame = CGRect(x: 0, y: yPos, width: self.view.frame.width, height: lblPackageName.frame.height + 40)
                lblLeftVerticalLine.frame = CGRect(x: 10, y: 0, width: 0.5, height: mainView.frame.height)
                lblRighttVerticalLine1.frame = CGRect(x: self.view.frame.width - ( 30 + 4), y: 0, width: 0.5, height: mainView.frame.height)
                lblRighttVerticalLine2.frame = CGRect(x: self.view.frame.width - (50 + 30 + 7), y: 0, width: 0.5, height: mainView.frame.height)

                
                lblMemberName.frame = CGRect(x: lblLeftVerticalLine.frame.origin.x + 5 , y: (mainView.frame.height - 30)/2 , width: 30, height: 30)
                
               // set size from calculating total width from right side

                let lblDiscountPrice = BaseUIController().ALabelFrame(CGRect(x: lblRighttVerticalLine2.frame.origin.x - (50 + 2), y: (mainView.frame.height - 30)/2, width: 50, height: 30), withString: "")as! UILabel
                lblDiscountPrice.font = UIFont().smallFont
                lblDiscountPrice.textAlignment = .center
                // lblDiscountPrice.text = currencySymbol + pkgOrderInfoObj.packagePrice
                mainView.addSubview(lblDiscountPrice)
                
                let lblVerticalLine2 = BaseUIController().ALabelFrame(CGRect(x: lblDiscountPrice.frame.origin.x - 2 , y: 0, width: 0.5, height: mainView.frame.height), withString: "")as! UILabel
                lblVerticalLine2.backgroundColor = customGrayColor
                mainView.addSubview(lblVerticalLine2)
                
                lblPackagePrice.frame = CGRect(x: lblVerticalLine2.frame.origin.x - (50 + 2) , y: (mainView.frame.height - 30)/2, width: 50, height: 30)
                 lblPackagePrice.textAlignment = .center
                
                let lblVerticalLine1 = BaseUIController().ALabelFrame(CGRect( x: lblVerticalLine2.frame.origin.x - (50 + 2) , y: 0, width: 0.5, height: mainView.frame.height), withString: "")as! UILabel
                lblVerticalLine1.backgroundColor = customGrayColor
                mainView.addSubview(lblVerticalLine1)
                

               
                
               let lblpayablePrice = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width - (50 + 30 + 5) , y: (mainView.frame.height - 30)/2, width: 50, height: 30), withString: "")as! UILabel
                lblpayablePrice.font = UIFont().smallFont
                lblpayablePrice.textAlignment = .center
                
               var discoutnPrice = Int()
                let pkgType = pkgOrderInfoObj.packageType
                
                if coupon_type == "P" {
                    
               
                switch pkg_type {
                case "P":
                    if pkgType == pkg_type {
                    
                          discoutnPrice = Int(pkgOrderInfoObj.packagePrice)! - (Int(pkgOrderInfoObj.packagePrice)! * discountPercentage/100)
                        afterDiscoutTotalPrice += discoutnPrice
                        totalDiscout += Int(pkgOrderInfoObj.packagePrice)! - discoutnPrice
                        lblDiscountPrice.text = currencySymbol + String(Int(pkgOrderInfoObj.packagePrice)! - discoutnPrice)
                        lblpayablePrice.text = currencySymbol + String(discoutnPrice)
                    }else{
                        lblDiscountPrice.text = "ND"
                        afterDiscoutTotalPrice += Int(pkgOrderInfoObj.packagePrice)!
                        lblpayablePrice.text = currencySymbol + String(Int(pkgOrderInfoObj.packagePrice)!)

                    }
                case "A":
                         discoutnPrice = Int(pkgOrderInfoObj.packagePrice)! - (Int(pkgOrderInfoObj.packagePrice)! * discountPercentage/100)
                        afterDiscoutTotalPrice += discoutnPrice
                        totalDiscout += Int(pkgOrderInfoObj.packagePrice)! - discoutnPrice
                        lblDiscountPrice.text = currencySymbol + String(Int(pkgOrderInfoObj.packagePrice)! - discoutnPrice)
                        lblpayablePrice.text = currencySymbol + String(discoutnPrice)
                case "T":
                      if pkgType == pkg_type {
                        
                          discoutnPrice = Int(pkgOrderInfoObj.packagePrice)! - (Int(pkgOrderInfoObj.packagePrice)! * discountPercentage/100)
                        afterDiscoutTotalPrice += discoutnPrice
                        totalDiscout += Int(pkgOrderInfoObj.packagePrice)! - discoutnPrice
                        lblDiscountPrice.text = currencySymbol + String(Int(pkgOrderInfoObj.packagePrice)! - discoutnPrice)
                        lblpayablePrice.text = currencySymbol + String(discoutnPrice)
                      }else{
                        lblDiscountPrice.text = "ND"
                        afterDiscoutTotalPrice += Int(pkgOrderInfoObj.packagePrice)!
                        lblpayablePrice.text = currencySymbol + String(Int(pkgOrderInfoObj.packagePrice)!)
                      }
                case "S":
                    if pkgType == pkg_type {
                        
                         discoutnPrice = Int(pkgOrderInfoObj.packagePrice)! - (Int(pkgOrderInfoObj.packagePrice)! * discountPercentage/100)
                        afterDiscoutTotalPrice += discoutnPrice
                        totalDiscout += Int(pkgOrderInfoObj.packagePrice)! - discoutnPrice
                        lblDiscountPrice.text = currencySymbol +  String(Int(pkgOrderInfoObj.packagePrice)! - discoutnPrice)
                        lblpayablePrice.text = currencySymbol + String(discoutnPrice)
                    }else{
                        lblDiscountPrice.text = "ND"
                        afterDiscoutTotalPrice += Int(pkgOrderInfoObj.packagePrice)!
                        lblpayablePrice.text = currencySymbol + String(Int(pkgOrderInfoObj.packagePrice)!)
                    }
                default: break
                }
                }else{
                    
                    
                    
                    print(Int(pkgOrderInfoObj.packagePrice)!)
                    
                    print(discountPercentage)
                    print(discoutnPrice)
                     discoutnPrice = Int(pkgOrderInfoObj.packagePrice)! - (Int(pkgOrderInfoObj.packagePrice)! * discountPercentage/100)
                    afterDiscoutTotalPrice += discoutnPrice
                    totalDiscout += Int(pkgOrderInfoObj.packagePrice)! - discoutnPrice
                    lblDiscountPrice.text = currencySymbol + String(Int(pkgOrderInfoObj.packagePrice)! - discoutnPrice)
                    lblpayablePrice.text = currencySymbol + String(discoutnPrice)
                    
                    print(totalDiscout)
                    
                    print(afterDiscoutTotalPrice)
                }
                mainView.addSubview(lblpayablePrice)
                
            }
            let btnDelete = BaseUIController().AButtonFrame(CGRect(x: self.view.frame.width - 32  , y: (mainView.frame.height - 30)/2 , width: 30, height: 30), withButtonTital: "")as! UIButton
            btnDelete.tag = 101 + i
            btnDelete.addTarget(self, action: #selector(self.btnDeleteSelectedPackage(_:)), for: .touchUpInside)
            btnDelete.setImage(UIImage(named: "verified_no.png"), for: UIControlState())
            mainView.addSubview(btnDelete)
            
            
            let lblHorizontalLine = BaseUIController().ALabelFrame(CGRect(x: 0,  y: mainView.frame.height - 1, width: self.view.frame.width, height: 0.5), withString: "")as! UILabel
            lblHorizontalLine.backgroundColor = customGrayColor
            mainView.addSubview(lblHorizontalLine)
            yPos += mainView.frame.height // 70
            
        }
     //   check is coming form package id from barcode scanner
        if (packageIdFromBarCode != "") {
            isCouponCodeApply = true
            //discountPercentage = 0
        }
        
        let totalView = UIView.init(frame: CGRect(x: 0, y: yPos, width: self.view.frame.width, height: 50))
        totalView.backgroundColor = UIColor.white
        scrollView.addSubview(totalView)

        let lbltotalView_H_lLine = BaseUIController().ALabelFrame(CGRect(x: 0,  y: 1, width: self.view.frame.width, height: 0.5), withString: "")as! UILabel
        lbltotalView_H_lLine.backgroundColor = customGrayColor
        totalView.addSubview(lbltotalView_H_lLine)
        
        let lbltotalView_V_lLine = BaseUIController().ALabelFrame(CGRect(x: 10, y: 2, width: 0.5, height: 50), withString: "")as! UILabel
        lbltotalView_V_lLine.backgroundColor = UIColor.red
        totalView.addSubview(lbltotalView_V_lLine)
        
        let lblTotal = BaseUIController().ALabelFrame(CGRect(x: 30, y: 15, width: 120, height: 20), withString: "Total Amount")as! UILabel
        lblTotal.font = UIFont.boldSystemFont(ofSize: 16)
        lblTotal.textColor = customGrayColor
        lblTotal.textAlignment = .left
        totalView.addSubview(lblTotal)
        
        let lblTotalAmount = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width - 90, y: 15, width: 80, height: 21), withString: "")as! UILabel
        lblTotalAmount.font = UIFont.boldSystemFont(ofSize: 16)
        lblTotalAmount.textColor = customGrayColor
        lblTotalAmount.text = String(currencySymbol + self.totalAmount(arrPackageOrderData)) //self.totalAmount(arrPackageOrderData)
        totalView.addSubview(lblTotalAmount)
        // if wallet use
        if(isWalletBalanceUse == true && isCouponCodeApply == false){
            //totalDiscout = Int(appDelegate.walletBalance)!
            if (Int(self.totalAmount(arrPackageOrderData))! < Int(appDelegate.walletBalance)!) {
                // wallet balance is more then packages price
                afterDiscoutTotalPrice = 0
            }else{
                afterDiscoutTotalPrice = Int(self.totalAmount(arrPackageOrderData))! - Int(appDelegate.walletBalance)!
            }
            
            lbltotalView_V_lLine.frame = CGRect(x: 10, y: 2, width: 0.5, height: 120)
            totalView.frame = CGRect(x: 0, y: yPos, width: self.view.frame.width, height: 120)
            lblTotalAmount.frame = CGRect(x: self.view.frame.width - 90 , y: 15, width: 80, height: 20)
            
            lblTotal.font = UIFont.boldSystemFont(ofSize: 14)
            lblTotal.textColor = UIColor.black
            lblTotalAmount.font = UIFont.boldSystemFont(ofSize: 14)
            lblTotalAmount.textColor = UIColor.black
            
            let lblTotalDiscontAmount = BaseUIController().ALabelFrame(CGRect(x: 30, y: 50, width: 200, height: 20), withString: "Credit used")as! UILabel
            lblTotalDiscontAmount.font = UIFont.boldSystemFont(ofSize: 14)
            lblTotalDiscontAmount.textAlignment = .left
            totalView.addSubview(lblTotalDiscontAmount)
            
            let lblDiscountAmount = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width - 90 ,
                y: 50, width: 120, height: 20), withString: "")as! UILabel
            lblDiscountAmount.font = UIFont.boldSystemFont(ofSize: 14)
            
            lblDiscountAmount.text = currencySymbol + String(appDelegate.walletBalance)
            totalView.addSubview(lblDiscountAmount)
            
            let lblHorizontalLineOntotalView = BaseUIController().ALabelFrame(CGRect(x: 10, y: 80, width: self.view.frame.width, height: 0.5), withString: "")as! UILabel
            lblHorizontalLineOntotalView.backgroundColor = UIColor.red
            totalView.addSubview(lblHorizontalLineOntotalView)
            
            let lblTotalPayableAmount = BaseUIController().ALabelFrame(CGRect(x: 30, y: 85, width: 200, height: 20), withString: "Payable Amount")as! UILabel
            lblTotalPayableAmount.font = UIFont.boldSystemFont(ofSize: 16)
            lblTotalPayableAmount.textColor = customGrayColor
            lblTotalPayableAmount.textAlignment = .left
            totalView.addSubview(lblTotalPayableAmount)
            
            let lblAfterDiscountPayableAmount = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width - 90 , y: 85, width: 120, height: 21), withString: "")as! UILabel
            lblAfterDiscountPayableAmount.font = UIFont.boldSystemFont(ofSize: 16)
            lblAfterDiscountPayableAmount.textColor = customGrayColor
            lblAfterDiscountPayableAmount.text = currencySymbol + String(afterDiscoutTotalPrice)
            totalView.addSubview(lblAfterDiscountPayableAmount)
            yPos += 70
            let creditAmount = Int(self.totalAmount(arrPackageOrderData))!
            if (Int(totalAmount) < Int(appDelegate.walletBalance)) {
               lblDiscountAmount.text = currencySymbol + String(creditAmount)
            }
        
        }
        //check is coming form package id from barcode scanner
                if (packageIdFromBarCode != "") {
                    isCouponCodeApply = true
                    //discountPercentage = 0
                    
                    print(afterDiscoutTotalPrice)
                    
                 //   afterDiscoutTotalPrice = afterDiscoutTotalPrice - 2650 //Int(appDelegate.walletBalance)!2666
                }
        // coupon applya
        if isCouponCodeApply {
            lbltotalView_V_lLine.frame = CGRect(x: 10, y: 2, width: 0.5, height: 120)
            totalView.frame = CGRect(x: 0, y: yPos, width: self.view.frame.width, height: 120)
            lblTotalAmount.frame = CGRect(x: self.view.frame.width - 90 , y: 15, width: 80, height: 20)
            
            lblTotal.font = UIFont.boldSystemFont(ofSize: 14)
            lblTotal.textColor = UIColor.black
            lblTotalAmount.font = UIFont.boldSystemFont(ofSize: 14)
            lblTotalAmount.textColor = UIColor.black
            
            let lblTotalDiscontAmount = BaseUIController().ALabelFrame(CGRect(x: 30, y: 50, width: 200, height: 20), withString: "Discount Amount")as! UILabel
            lblTotalDiscontAmount.font = UIFont.boldSystemFont(ofSize: 14)
            lblTotalDiscontAmount.textAlignment = .left
            totalView.addSubview(lblTotalDiscontAmount)
            
            let lblDiscountAmount = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width - 90 ,
                y: 50, width: 120, height: 20), withString: "")as! UILabel
            lblDiscountAmount.font = UIFont.boldSystemFont(ofSize: 14)
            lblDiscountAmount.text = currencySymbol + String(totalDiscout)
            totalView.addSubview(lblDiscountAmount)
            
            var lblHorizontalLineOntotalView = UILabel()
            var lblTotalPayableAmount = UILabel()
            var lblAfterDiscountPayableAmount = UILabel()
            var lblWalletCreditAmount = UILabel()
            if (isWalletBalanceUse) {
                totalView.frame = CGRect(x: 0, y: yPos, width: self.view.frame.width, height: 150)
                
                let lblWalletCreditAmountText = BaseUIController().ALabelFrame(CGRect(x: 30, y: 85, width: 200, height: 20), withString: "Credit used")as! UILabel
                lblWalletCreditAmountText.font = UIFont.boldSystemFont(ofSize: 14)
                lblWalletCreditAmountText.textAlignment = .left
                totalView.addSubview(lblWalletCreditAmountText)
                
                lblWalletCreditAmount = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width - 90 ,
                    y: 85, width: 120, height: 20), withString: "")as! UILabel
                lblWalletCreditAmount.font = UIFont.boldSystemFont(ofSize: 14)
                lblWalletCreditAmount.text = currencySymbol + String(appDelegate.walletBalance)
                totalView.addSubview(lblWalletCreditAmount)
                
                lblHorizontalLineOntotalView = BaseUIController().ALabelFrame(CGRect(x: 10, y: 115, width: self.view.frame.width, height: 0.5), withString: "")as! UILabel
                lblTotalPayableAmount = BaseUIController().ALabelFrame(CGRect(x: 30, y: 120, width: 200, height: 20), withString: "Payable Amount")as! UILabel
                lblAfterDiscountPayableAmount = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width - 90 , y: 120, width: 120, height: 21), withString: "")as! UILabel
                yPos += 30
                if (afterDiscoutTotalPrice < Int(appDelegate.walletBalance)!) {
                    afterDiscoutTotalPrice = 0
                }else
                {
                 afterDiscoutTotalPrice = afterDiscoutTotalPrice - Int(appDelegate.walletBalance)!
                }
                
                
            }else{
                lblHorizontalLineOntotalView = BaseUIController().ALabelFrame(CGRect(x: 10, y: 80, width: self.view.frame.width, height: 0.5), withString: "")as! UILabel
                lblTotalPayableAmount = BaseUIController().ALabelFrame(CGRect(x: 30, y: 85, width: 200, height: 20), withString: "Payable Amount")as! UILabel
                lblAfterDiscountPayableAmount = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width - 90 , y: 85, width: 120, height: 21), withString: "")as! UILabel
            }
            
            
            
            
            
            lblHorizontalLineOntotalView.backgroundColor = UIColor.red
            totalView.addSubview(lblHorizontalLineOntotalView)

            
            
            lblTotalPayableAmount.font = UIFont.boldSystemFont(ofSize: 16)
            lblTotalPayableAmount.textColor = customGrayColor
            lblTotalPayableAmount.textAlignment = .left
            totalView.addSubview(lblTotalPayableAmount)
            
    
            lblAfterDiscountPayableAmount.font = UIFont.boldSystemFont(ofSize: 16)
            lblAfterDiscountPayableAmount.textColor = customGrayColor
            lblAfterDiscountPayableAmount.text = currencySymbol + String(afterDiscoutTotalPrice)
            totalView.addSubview(lblAfterDiscountPayableAmount)
            yPos += 70
            let creditAmount = Int(self.totalAmount(arrPackageOrderData))! - totalDiscout
            
            if (creditAmount < Int(appDelegate.walletBalance)) {
                lblWalletCreditAmount.text = currencySymbol + String(creditAmount)
            }
 
        }
        
        yPos += 50
        xPos = 0
        for k in 0..<50 {
            
            let triangelImageView = BaseUIController().AImageViewFrame(CGRect(x: xPos , y: yPos, width: 10, height: 10), withImageName: "reverse_triangle.png")as! UIImageView
            scrollView.addSubview(triangelImageView)
            xPos += 10
        }
        yPos += 20
        
        let couponView = UIView.init(frame: CGRect(x: 0, y: yPos, width: self.view.frame.width, height: 120))
        couponView.backgroundColor = UIColor.white
        scrollView.addSubview(couponView)
        
        let leftImageView = BaseUIController().AImageViewFrame(CGRect(x: 10 , y: 0, width: 23, height: 120), withImageName: "app_credits_left.png")as! UIImageView
        couponView.addSubview(leftImageView)
        txtCouponCode = BaseUIController().ATextFiedlFrame(CGRect(x: 30, y: 25, width: self.view.frame.width - 150 , height: 30), withPlaceHolder: "Enter a coupon code")as! UITextField
        txtCouponCode.delegate = self
        txtCouponCode.font = fontSize
        couponView.addSubview(txtCouponCode)
        
        let lbltextbottomLine = BaseUIController().ALabelFrame(CGRect(x: 30, y: 56, width: self.view.frame.width - 150 , height: 1), withString: "")as! UILabel
        lbltextbottomLine.backgroundColor = customGrayColor
        couponView.addSubview(lbltextbottomLine)
        
        let lblMessage = BaseUIController().ALabelFrame(CGRect(x: 40, y: 70, width: couponView.frame.width - 80, height: 30), withString: "Enter your coupon code here and applicable only in Stetho.")as! UILabel
        lblMessage.numberOfLines = 0
        //lblMessage.backgroundColor = UIColor.redColor()
        lblMessage.font = UIFont().smallFont
        couponView.addSubview(lblMessage)
        
        let rightImageView = BaseUIController().AImageViewFrame(CGRect(x: self.view.frame.width - 20 , y: 0, width: 23, height: 120), withImageName: "app_credits_left.png")as! UIImageView
        couponView.addSubview(rightImageView)
        
        let btnApply = BaseUIController().AButtonFrame(CGRect(x: rightImageView.frame.origin.x - 70 , y: 25, width: 70, height: 35), withButtonTital: "Apply")as! UIButton
        btnApply.layer.cornerRadius = 4
        btnApply.layer.borderWidth = 1
        btnApply.layer.borderColor = UIColor.red.cgColor
        btnApply.setTitleColor(UIColor.red, for: UIControlState())
        btnApply.addTarget(self, action: #selector(self.btnApplyOnClick(_:)), for: .touchUpInside)
        btnApply.titleLabel?.font = fontSize
        couponView.addSubview(btnApply)
        
        
        // show wallet selection layout
        if (Int(appDelegate.walletBalance) > 0) {
            couponView.frame = CGRect(x: 0, y: yPos, width: self.view.frame.width, height: 150)
            rightImageView.frame = CGRect(x: self.view.frame.width - 20 , y: 0, width: 28, height: 150)
            leftImageView.frame = CGRect(x: 10 , y: 0, width: 28, height: 150)
            
            let lblMessagebottomLine = BaseUIController().ALabelFrame(CGRect(x: 30, y: 105, width: self.view.frame.width - 60 , height: 0.5), withString: "")as! UILabel
            lblMessagebottomLine.backgroundColor = customGrayColor
            couponView.addSubview(lblMessagebottomLine)
            
            let btnWalletCheck_UnCheck = BaseUIController().AButtonFrame(CGRect(x: 40, y: 110, width: 30, height: 30), withButtonTital: "")as! UIButton
            btnWalletCheck_UnCheck.addTarget(self, action: #selector(self.btnWalletBalanceOnClick(_:)), for: .touchUpInside)
            btnWalletCheck_UnCheck.setImage(UIImage(named: "ic_outline.png"), for: UIControlState())
            couponView.addSubview(btnWalletCheck_UnCheck)
            btnWalletCheck_UnCheck.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
            if isWalletBalanceUse == true {
                btnWalletCheck_UnCheck.setImage(UIImage(named: "verified_yes.png"), for: UIControlState())
            }else{
                btnWalletCheck_UnCheck.setImage(UIImage(named: "ic_outline.png"), for: UIControlState())
            }
            let lblWalletMessage = BaseUIController().ALabelFrame(CGRect(x: 80, y: 120, width: couponView.frame.width - 60, height: 15), withString: String(format: "Use  your wallet balance ₹ %@",appDelegate.walletBalance))as! UILabel
            lblWalletMessage.numberOfLines = 0
            lblWalletMessage.textColor = UIColor (red: (0/255), green: (121/255), blue: (107/255), alpha: 1)
            lblWalletMessage.font = UIFont(name: "HelveticaNeue-Bold", size: 12.0)!
            couponView.addSubview(lblWalletMessage)
            yPos += 30
        }
        
        
        
        
        if isCouponCodeApply {
            txtCouponCode.isHidden = true
            lblMessage.isHidden = true
            btnApply.setTitle("REMOVE", for: UIControlState())
            lbltextbottomLine.isHidden = true
            let lblTotalDistAmount = BaseUIController().ALabelFrame(CGRect(x: 30, y: 20, width: 200 , height: 20), withString: "")as! UILabel
            lblTotalDistAmount.textColor = UIColor.blue
            lblTotalDistAmount.text = String(format: "Discount amount %@ " , currencySymbol + String(totalDiscout)) 
            couponView.addSubview(lblTotalDistAmount)
            
            let lblCouponSuccefullyMessages = BaseUIController().ALabelFrame(CGRect(x: 30, y: 40, width: 200 , height: 40), withString: "Coupon applied successfully!")as! UILabel
           // lblCouponSuccefullyMessages.textColor = UIColor.redColor()
            lblCouponSuccefullyMessages.text = "Coupon applied successfully!" + "\n Payble amount is ₹ " + String(afterDiscoutTotalPrice)
            couponView.addSubview(lblCouponSuccefullyMessages)
        }
        
        yPos += 120
        
        
        let lblPickupAddress = BaseUIController().ALabelFrame(CGRect(x: 5, y: yPos + 5, width: 120, height: 21), withString: "PICKUP ADDRESS")as! UILabel
        lblPickupAddress.font = fontSize
        scrollView.addSubview(lblPickupAddress)
        
        let btnPickUpAddressEdit = BaseUIController().AButtonFrame(CGRect(x: self.view.frame.width - 60, y: yPos, width: 60, height: 35), withButtonTital: "")as! UIButton
        btnPickUpAddressEdit.imageEdgeInsets = UIEdgeInsetsMake(5, 20, 5, 15)
        btnPickUpAddressEdit.setImage(UIImage(named: "edit_black_icon.png"), for: UIControlState())
        btnPickUpAddressEdit.addTarget(self, action: #selector(CheckOutViewController.btnPickUpAddressEditOnClick), for: .touchUpInside)
        scrollView.addSubview(btnPickUpAddressEdit)
        
        yPos += 35
        let pickupAddressView = UIView.init(frame: CGRect(x: 4, y: yPos, width: self.view.frame.width - 10, height: 100))
        pickupAddressView.backgroundColor = UIColor.white
        scrollView.addSubview(pickupAddressView)
        
        let pickUpleftImageView = BaseUIController().AImageViewFrame(CGRect(x: 5 , y: 0, width: 20, height: 100), withImageName: "checkout_address_left.png")as! UIImageView
        pickupAddressView.addSubview(pickUpleftImageView)
        
        lblPickupFullAddress = BaseUIController().ALabelFrame(CGRect(x: 40, y: 5, width: pickupAddressView.frame.width - 80 , height: 90), withString: "")as! UILabel
        // get address from local database
        lblPickupFullAddress.text = self.getPickupAddressDetails()
        lblPickupFullAddress.font = fontSize
        lblPickupFullAddress.sizeToFit()
        pickupAddressView.addSubview(lblPickupFullAddress)
        pickupAddressView.frame = CGRect(x: 4, y: yPos, width: self.view.frame.width - 10, height: lblPickupFullAddress.frame.height + 10)
        pickUpleftImageView.frame = CGRect(x: 5 , y: 0, width: 20, height: lblPickupFullAddress.frame.height + 10)
        yPos += lblPickupFullAddress.frame.height + 20
        print(yPos)
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: yPos + 64)
    }
    func showOldPickupAddress()  {
        
        bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        bgView.tag = 500
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(bgView)
        
        pickupAddressTableView = UITableView(frame:CGRect(x: 10, y: ((UIScreen.main.bounds.height/2)-(150)),width: bgView.bounds.width - 20, height: 180))
        pickupAddressTableView.separatorStyle = .none
        // inviteTableView.scrollEnabled = false
        pickupAddressTableView.layer.cornerRadius = 4.0
        pickupAddressTableView.tag = 501
        pickupAddressTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        pickupAddressTableView.backgroundColor = UIColor.clear
        bgView.addSubview(pickupAddressTableView)
        // if getting more then 3 member then increaase height of view
//        if arrOldPickupAddress.count >= 3 {
            //            bgView.frame = CGRectMake(10, ((UIScreen.mainScreen().bounds.height/2)-(90)), (UIScreen.mainScreen().bounds.width-20), 180)
           // pickupAddressTableView.frame = CGRectMake(10, ((UIScreen.mainScreen().bounds.height/2)-(45)), bgView.bounds.width - 20, 150)
            
      //  }
        // ITapGestureRecognizer(target:self
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnBGView(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        bgView.addGestureRecognizer(tapped)
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        bgView.addSubview(activityIndicator!)
        activityIndicator?.start()
    }
    func showAllPackages()  {
        self.title = "PACKAGES"
        bgView = UIView.init(frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20 , height: UIScreen.main.bounds.height))
        bgView.tag = 500
      //  bgView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        bgView.backgroundColor = UIColor.white
     
        self.view.addSubview(bgView)
        
        /* Search controller parameters */
        searchController.searchResultsUpdater = self  // This protocol allows your class to be informed as text changes within the UISearchBar.
        searchController.dimsBackgroundDuringPresentation = false  // In this instance,using current view to show the results, so do not want to dim current view.
        definesPresentationContext = false   // ensure that the search bar does not remain on the screen if the user navigates to another view controller while the UISearchController is active.
         searchController.searchBar.frame = CGRect(x: 0, y: 0, width: bgView.frame.width, height: 44)
        let tableHeaderView: UIView = UIView.init(frame: searchController.searchBar.frame)
        tableHeaderView.addSubview(searchController.searchBar)
        //  self.tableView.tableHeaderView = tableHeaderView
         bgView.addSubview(tableHeaderView)
        
        searchController.hidesNavigationBarDuringPresentation = false
        
        packageTableView = UITableView(frame:CGRect(x: 0, y: 44,width: bgView.frame.width, height: (UIScreen.main.bounds.height - 148))) // nav height + familymember Slider + tab +  40 (buttom widht)
        packageTableView.delegate      =   self
        packageTableView.dataSource    =   self
        packageTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        packageTableView.backgroundColor = UIColor.clear
        packageTableView.separatorInset = UIEdgeInsets.zero
        packageTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        bgView.addSubview(packageTableView)
        
        // create a label and button in bottom view
        lblTestSelectd = UILabel(frame: CGRect(x: 0, y: packageTableView.frame.height + 50 ,width: bgView.frame.width/2,height: 40))
        lblTestSelectd.text = "None"
        lblTestSelectd.textAlignment = NSTextAlignment.center
        lblTestSelectd.backgroundColor = UIColor (red: (209.0/255.0), green: (209.0/255.0), blue: (209.0/255.0), alpha: 1)
        lblTestSelectd.font = UIFont().mediumFont
        bgView .addSubview(lblTestSelectd)
        btnContinue = UIButton(frame: CGRect(x: self.view.frame.width/2, y: packageTableView.frame.height + 50 ,width: bgView.frame.width/2,height: 40))
        btnContinue.setTitle("Continue", for: UIControlState())
        btnContinue.backgroundColor = UIColor.red
        btnContinue.titleLabel?.font = UIFont().mediumFont
        btnContinue.addTarget(self, action: #selector(self.btnContinueOnClick(_:)), for: .touchUpInside)
        bgView .addSubview(btnContinue)
        updateUILayout()
    }
    
    func showMemberList()  {
         self.title = "MEMBER LIST"
        
        // create A tableView
        //        bgView = UIView(frame:CGRectMake(0, 0,self.view.frame.width, self.view.frame.height))
        bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(bgView)
        let tableHeight : CGFloat = CGFloat((arrMyFamilyList.count * 44) + 30)
        print(tableHeight)
        print(UIScreen.main.bounds.height)
        print(((UIScreen.main.bounds.height - tableHeight)/2))
        
        if ((UIScreen.main.bounds.height - tableHeight)/2) >= 70 {
            memberListTableView = UITableView(frame:CGRect(x: 10, y: (UIScreen.main.bounds.height - tableHeight)/2, width: self.view.frame.width - 20 ,height: tableHeight))
        }else{
            memberListTableView = UITableView(frame:CGRect(x: 10, y: 10, width: self.view.frame.width - 20 ,height: self.view.frame.height - 20 ))
            
        }
        
        memberListTableView.delegate      =   self
        memberListTableView.dataSource    =   self
        memberListTableView.layer.cornerRadius = 4.0
        memberListTableView.tableFooterView = UIView()
        memberListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        memberListTableView.backgroundColor = UIColor.clear
        bgView.addSubview(memberListTableView)
        // add Tapgestue  on shadowBackGround
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnMemberListBG(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        bgView.addGestureRecognizer(tapped)
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
        
        
        
        scrollViewForAddress = UIScrollView(frame: CGRect(x: 0 , y: 42 , width: baseView.frame.width , height: baseView.frame.height -  80)) //
        scrollViewForAddress.backgroundColor = UIColor.white
        baseView.addSubview(scrollViewForAddress)
        var xPos:CGFloat = 20
        var yPos:CGFloat = 10
        var labelName: [String] = ["Address Line 1 :" , "Address Line 2 :" , "Landmark :", "City :", "Locality :"]
        
        for i in (0..<labelName.count) {
            let label = BaseUIController().ALabelFrame(CGRect(x:xPos , y: yPos ,width: 200 , height: 30 ), withString: labelName[i])as! UILabel
            label.font = UIFont().mediumFont
            scrollViewForAddress.addSubview(label)
            yPos += 21+5;
            let textField = BaseUIController().ATextFiedlFrame(CGRect(x:xPos , y: yPos ,width: baseView.frame.width-40 , height: 35 ), withPlaceHolder: "")as! UITextField
            textField.tag = 200 + i
            textField.delegate = self
            textField.textAlignment = .left
            textField.borderStyle = .roundedRect
            scrollViewForAddress.addSubview(textField)
            
            yPos += 35+5;
        }
        yPos += 10;
        let lblPincode :UILabel = BaseUIController().ALabelFrame(CGRect(x: xPos , y: yPos, width:  80 , height: 21), withString: "Pincode :")as! UILabel
        lblPincode.font = UIFont().mediumFont
        scrollViewForAddress.addSubview(lblPincode)
        
        
        xPos =  90
        let _width: CGFloat = (baseView.frame.width - (xPos + 20 + 50 ))/6
        
        
        for i in (0..<6) {
            
            let textField = BaseUIController().ATextFiedlFrame(CGRect(x: xPos , y: yPos ,width: _width , height: 20 ), withPlaceHolder: "")as! UITextField
            textField.borderStyle = .line
            textField.layer.borderWidth = 1
            textField.layer.borderColor =  UIColor.init(red: (242.0/255.0), green: (237.0/255.0), blue: (237.0/255.0), alpha: 1.0).cgColor
            scrollViewForAddress.addSubview(textField)
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
        
        
        txtPin1 = scrollViewForAddress.viewWithTag(100) as! UITextField
        txtPin2 = scrollViewForAddress.viewWithTag(101) as! UITextField
        txtPin3 = scrollViewForAddress.viewWithTag(102) as! UITextField
        txtPin4 = scrollViewForAddress.viewWithTag(103) as! UITextField
        txtPin5 = scrollViewForAddress.viewWithTag(104) as! UITextField
        txtPin6 = scrollViewForAddress.viewWithTag(105) as! UITextField
        
        txtAddressLine1 = scrollViewForAddress.viewWithTag(200)as! UITextField
        txtAddressLine2 = scrollViewForAddress.viewWithTag(201)as! UITextField
        txtLandMark = scrollViewForAddress.viewWithTag(202)as! UITextField
        txtCity = scrollViewForAddress.viewWithTag(203)as! UITextField
        txtLocality = scrollViewForAddress.viewWithTag(204)as! UITextField
        
        //Add PickerView
        cityPickerView.dataSource = self
        cityPickerView.delegate = self
        txtCity.inputView = cityPickerView
        addToolBar(txtCity)
        

        
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
        scrollViewForAddress.addSubview(self.autoPopulateAddressTableView)
        
        
    }


    //MARK: PickerViewDelegate
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        if pickerView == cityPickerView {
            return 1
        }else{
        return 2
        }
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if (pickerView == cityPickerView) {
            return arrCityName.count
        }else{
            if component == 0 {
                return arrDay.count
            }else{
                return arrTime.count
            }
        
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == cityPickerView) {
            return arrCityName[row]
        }else{
        if component == 0 {
            return arrDay[row]
        }else{
            return arrTime[row]
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if (pickerView == cityPickerView) {
            txtCity.text = arrCityName[row]
            
        }else{
        if component == 0 {
          pickupDay = arrDay[row]
            
        }
        else{
            pickupTime = arrTime[row]
        }
        pickupDay_Time = pickupDay  +  pickupTime
        lblPickUpDate.text = pickupDay_Time
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        if (pickerView == cityPickerView) {
             pickerLabel.text = arrCityName[row]
            
        }else{
            if component == 0 {
                pickerLabel.text = arrDay[row]
            }else{
                pickerLabel.text = arrTime[row]
            }
        }
        // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
        pickerLabel.font = UIFont().mediumFont // In this use your custom font
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    //MARK: - TableViewDelegate
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == packageTableView {
            return 1
        }else{
           return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == packageTableView {
            if searchController.isActive == true {
                return arrFilterPakageData.count
            }else{
                
                return arrPakageData.count
               
            }
        }else if(tableView == memberListTableView){
            return arrMyFamilyList.count
        
        }else if (tableView == autoPopulateAddressTableView) {
            return arrGeoAddressDetails.count
        }
        else{
             return arrOldPickupAddress.count
        
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = UITableViewCell()
        if tableView == packageTableView {
             cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: kCellIdentifier)
            // let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: kCellIdentifier)
            cell.selectionStyle = .none
            
            var btnAdd = UIButton()
            var lblBookingAmount = UILabel()
            
            btnAdd = UIButton(frame: CGRect(x: packageTableView.frame.width - 60, y: 10, width: 50.0, height: 25))
            btnAdd.setTitle("ADD", for: UIControlState())
            btnAdd.setTitleColor(UIColor (red: (114.0/255.0), green: (114.0/255.0), blue: (114.0/255.0), alpha: 1), for: UIControlState())
            btnAdd.titleLabel?.font = UIFont().mediumFont
            btnAdd.layer.borderColor = UIColor.orange.cgColor
            btnAdd.layer.borderWidth = 1
            btnAdd.layer.cornerRadius = 5
            btnAdd.tag = 1001 + (indexPath as NSIndexPath).row
            btnAdd.addTarget(UIButton(), action: #selector(BookAnOrderViewController.btnAddOnClick(_:)), for: UIControlEvents.touchUpInside)
            
            lblBookingAmount = BaseUIController().ALabelFrame(CGRect(x: btnAdd.frame.origin.x - 15, y: 40, width: 80.0, height: 25), withString: "") as! UILabel
            lblBookingAmount.textAlignment = NSTextAlignment.center
            lblBookingAmount.font = UIFont().mediumFont
            //lblBookingAmount.textColor = UIColor (red: (105.0/255.0), green: (105.0/255.0), blue: (105.0/255.0), alpha: 1)
//            let currencyCode = "INR"
//            
//            let localeComponents = [NSLocale.Key.currencyCode: currencyCode]
//            let localeIdentifier = Locale.localeIdentifier(fromComponents: localeComponents as! [String : String])
//            let locale = Locale(localeIdentifier: localeIdentifier)
//            let currencySymbol = (locale as NSLocale).object(forKey: NSLocale.Key.currencySymbol) as! String
            let currencySymbol = (Locale(identifier:"de") as NSLocale).displayName(forKey: .currencySymbol, value: "INR")!
            cell.addSubview(btnAdd)
            cell.addSubview(lblBookingAmount)
            
            let pdfImageview = BaseUIController().AImageViewFrame(CGRect(x: 5, y: 22, width: 25, height: 25), withImageName: "test_report_icon")as! UIImageView
            //  pdfImageview.image = UIImage(named: "pdf_icon")
            cell.addSubview(pdfImageview)
            
            let lblTestName = BaseUIController().ALabelFrame(CGRect(x: 35, y: 5, width: self.view.frame.width-100, height: 50), withString: "")as! UILabel
            lblTestName.font = UIFont().mediumFont
            lblTestName.textColor = UIColor.black//UIColor (red: (105.0/255.0), green: (105.0/255.0), blue: (105.0/255.0), alpha: 1)
            cell.addSubview(lblTestName)
            
//            let lblTestDetails = BaseUIController().ALabelFrame(CGRect(x: 35, y: 45, width: self.view.frame.width-100, height: 15), withString: "")as! UILabel
//            lblTestDetails.font = UIFont.italicSystemFontOfSize(12)
//            lblTestDetails.textColor = UIColor (red: (114.0/255.0), green: (114.0/255.0), blue: (114.0/255.0), alpha: 1)
//            cell.addSubview(lblTestDetails)
//            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "View details")
//            attributeString.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: NSMakeRange(0, attributeString.length))
//            lblTestDetails.attributedText = attributeString
            
            
            if searchController.isActive == true {
                // block user interaction on searchcontroller active
               // homeTabVC.dissableTapSegmentController("active")
                let filterPackageDict = arrFilterPakageData[indexPath.row] as! NSDictionary
                lblTestName.text = filterPackageDict.value(forKey: "pkg_name")as? String
                let price = filterPackageDict.value(forKey: "pkg_price")as! String
                lblBookingAmount.text = currencySymbol + price
                // hide View Details label
                if filterPackageDict.value(forKey: "pac_test_type")as? String != "P" {
                  //  lblTestDetails.hidden = true
                }
            } else {
                // block user interaction on searchcontroller active
            //    homeTabVC.dissableTapSegmentController("Inactive")
                let packageDict = arrPakageData[indexPath.row] as! NSDictionary

                lblTestName.text = packageDict.value(forKey: "pkg_name")as? String
                let price = packageDict.value(forKey: "pkg_price")as! String
                lblBookingAmount.text = currencySymbol + price
                // hide View Details label
                if packageDict.value(forKey: "pac_test_type")as? String != "P" {
                  //  lblTestDetails.hidden = true
                }
            }
            for i in 0..<arrPackageOrderData.count {
                var pkgOrderInfo = PackgeOrederInfo()
                pkgOrderInfo = arrPackageOrderData[i] as! PackgeOrederInfo
                let selectedMemberId = UserDefaults.standard.value(forKeyPath: "selectedMemberId")as! String
                var pkg_id = ""
                if searchController.isActive == false {
                    pkg_id = (arrPakageData[indexPath.row] as! NSDictionary).value(forKey: "pkg_id")as! String
                }else{
                    pkg_id = (arrFilterPakageData[indexPath.row] as! NSDictionary).value(forKey: "pkg_id")as! String
                }
                if (pkgOrderInfo.packageId == pkg_id) && pkgOrderInfo.orderId == selectedMemberId  {
                    btnAdd.backgroundColor = UIColor.red
                    btnAdd.setTitleColor(UIColor.white, for: UIControlState())
                    btnAdd.isSelected = true
                }
            }

            
        }else if(tableView == memberListTableView){
            let myFamilyMemberObj = arrMyFamilyList[(indexPath as NSIndexPath).row]as! MyFamilyInfo
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
            
            
            let userImageView = BaseUIController().AImageViewFrame(CGRect(x: 10, y: 10, width: 24, height: 24), withImageName: "user_icon.png")as! UIImageView
            userImageView.layer.masksToBounds = true
            userImageView.layer.cornerRadius = userImageView.frame.width/2
            cell.addSubview(userImageView)
            let lbluserName = BaseUIController().ALabelFrame(CGRect( x: 50, y: 10, width: 250, height: 24), withString: "")as! UILabel
            cell.addSubview(lbluserName)
            lbluserName.text = myFamilyMemberObj.memberName
            lbluserName.textColor = UIColor (red: (55.0/255.0), green: (54/255.0), blue: (54.0/255.0), alpha: 1)
            lbluserName.font = UIFont.systemFont(ofSize: 12)
            
            let imageString = myFamilyMemberObj.memberPhoto
            let data = Data(base64Encoded: imageString, options: NSData.Base64DecodingOptions(rawValue: 0))
            if imageString != "" {
                userImageView.image = UIImage.init(data: data!)
            }else{
                userImageView.image = UIImage(named: "avatar1.png")
            }
        }else if(tableView == autoPopulateAddressTableView){
            
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
                cell.textLabel?.text = ((arrGeoAddressDetails.object(at: (indexPath.row)) as! NSDictionary).value(forKey: "address")) as? String
                cell.textLabel?.font = UIFont().mediumFont
                cell.backgroundColor = UIColor.gray
        }
        else{
            cell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell4")
            cell.textLabel?.font = UIFont().mediumFont
            let addDict = arrOldPickupAddress.object(at: indexPath.row) as! NSDictionary
            let address_line1 = addDict.value(forKey: "a_address_line_1")as? String
            let address_line2 = addDict.value(forKey: "a_address_line_2")as? String
            let landmark = addDict.value(forKey: "a_landmark")as? String
            let pincode = addDict.value(forKey: "a_pincode")as? String
            let cityName = addDict.value(forKey: "city_name")as? String
            let geo_address = addDict.value(forKey: "geo_address")as? String
            var fullAddress = ""
            if address_line2 != "" {
                fullAddress = String(format: "%@ , %@,%@,%@,%@ %@", address_line1! ,address_line2! , landmark! ,geo_address! ,cityName! , pincode!)
            }else{
                fullAddress = String(format: "%@ ,%@,%@,%@ %@", address_line1!,landmark! ,geo_address! ,cityName! , pincode!)
            }
            cell.textLabel?.text = fullAddress
        
        }
       

        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == packageTableView {
            
        }else if(tableView == memberListTableView){
            bgView.removeFromSuperview()
            let myFamilyMemberObj = arrMyFamilyList[(indexPath as NSIndexPath).row]as! MyFamilyInfo
            btnMemberName.setTitle(myFamilyMemberObj.memberName, for: UIControlState())
            selectedMemberName = myFamilyMemberObj.memberName
            UserDefaults.standard.setValue(myFamilyMemberObj.memberId, forKey: "selectedMemberId")
            
        }else{
            let addDict = arrOldPickupAddress.object(at: indexPath.row) as! NSDictionary
            let address_line1 = addDict.value(forKey: "a_address_line_1")as? String
            let address_line2 = addDict.value(forKey: "a_address_line_2")as? String
            let landmark = addDict.value(forKey: "a_landmark")as? String
            let pincode = addDict.value(forKey: "a_pincode")as? String
            let cityName = addDict.value(forKey: "city_name")as? String
            let geo_address = addDict.value(forKey: "geo_address")as? String
            let fullAddress = String(format: "%@ , %@,%@,%@,%@ %@", address_line1! ,address_line2! , landmark! ,geo_address! ,cityName! , pincode!)
            lblPickupFullAddress.text = fullAddress
            bgView.removeFromSuperview()
        }
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == packageTableView {
           return  70;
        }else{
            return  50;
        
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
       
        if tableView == packageTableView {
            return 0;
        }else{
           return 30;
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 10, width: tableView.bounds.size.width, height: 200))
        headerView.backgroundColor = UIColor.white
        let label = BaseUIController().ALabelFrame(CGRect(x: 10 , y: 5 ,width: 200 , height: 21), withString: "")as! UILabel
        label.text = "SAVED ADDRESSES"
        headerView.addSubview(label)
        let lblLine = BaseUIController().ALabelFrame(CGRect(x: 0 , y: 29 ,width: self.view.frame.width , height: 1), withString: "")as! UILabel
        lblLine.backgroundColor = UIColor.red
        headerView.addSubview(lblLine)
        return headerView
    }
    //MARK: textFieldDelegate
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
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
            self.bgView.isHidden = false
            
            
        }
        
    }
    func placeViewClosed() {
        
        gpaViewController.dismiss(animated: true) {
            self.bgView.isHidden = false
            
        }
        // self.navigationController?.popViewControllerAnimated(true)
        
        
    }


    //MARK: searchBarDelegate
    func updateSearchResults(for searchController: UISearchController) {
        
        arrFilterPakageData = NSArray()
        let searchPredicate = NSPredicate(format: "pkg_name CONTAINS[c] %@", searchController.searchBar.text!)
        arrFilterPakageData = arrPakageData.filtered(using: searchPredicate) as NSArray
//        arrFilterPakageData = arrPakageData.filter {searchPredicate.evaluate(with: $0)}
        
        packageTableView.reloadData()
        
    }
    
    //MARK: - GestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view == bgView ){
            
            return true
        }
        else{
            
            return false
        }
    }
    func tappedOnBGView(_ sender: UITapGestureRecognizer)  {
        
        bgView.removeFromSuperview()
        
    }
    func tappedOnMemberListBG(_ gesture : UITapGestureRecognizer)  {
        
        bgView.removeFromSuperview()
    }
    //MARK: buttonOnClick
    func btnSelectDateOnClick(_ button : UIButton)  {
        
        bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(bgView)
        timePickerView = UIPickerView(frame: CGRect(x: 20 , y: self.view.center.y - 144 , width: self.view.frame.width - 40, height: 160 ))
        timePickerView.backgroundColor = UIColor.white
        timePickerView.dataSource = self
        timePickerView.delegate = self
        let dayIndex = Int(arrDay.index(of: pickupDay)!)
        let timeIndex = Int(arrTime.index(of: pickupTime)!)
        timePickerView.selectRow(dayIndex, inComponent: 0, animated: true)
        timePickerView.selectRow(timeIndex, inComponent: 1, animated: true)
       
        
//        timePickerView.selectRow(2, inComponent: 0, animated: true)
//        timePickerView.selectRow(8, inComponent: 1, animated: true)
        bgView.addSubview(timePickerView)
        
        let okView = UIView.init(frame: CGRect(x: 20, y: timePickerView.frame.height + timePickerView.frame.origin.y , width: self.view.frame.width - 40, height: 25))
        okView.backgroundColor = UIColor.white
        bgView.addSubview(okView)
        
        let btnOk = BaseUIController().AButtonFrame(CGRect(x: okView.frame.width - 60 , y: 0, width: 40, height: 20), withButtonTital: "Ok")as! UIButton
        btnOk.titleLabel?.font = fontSize
        btnOk.addTarget(self, action: #selector(CheckOutViewController.btnOkOnclick(_:)), for: .touchUpInside)
        okView.addSubview(btnOk)
        
        
        
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnBGView(_:)))
        tapped.numberOfTapsRequired = 1
        bgView.addGestureRecognizer(tapped)
    }
    
    func btnOkOnclick(_ button : UIButton)  {
        
       // Condition for order booking check out 
        
        let date = Date()
        let calendar = Calendar.current
        let comp = (calendar as NSCalendar).components([.hour, .minute,.weekday,.weekdayOrdinal], from: date)
        let hour = comp.hour
        let minute = comp.minute
        let weekday = comp.weekday
//        let weekday_ordinal = comp.weekdayOrdinal
        
        if (pickupDay == "Tomorrow " && hour >= 22 && minute >= 30 && weekday > 1) {
            
            print(" today is Mon ------ Sat  ")
            pickupDay = "Day after Tomorrow "
            self.present(BaseUIController().showAlertView("Thank you for choosing Hindustan Wellness. You will receive a verification call to confirm your sample pickup slot for tomorrow ."), animated: true, completion: nil)

        }
        else if(pickupDay == "Tomorrow " && hour >= 19 && minute >= 30 && weekday == 1)
        {
            pickupDay = "Day after Tomorrow "
            print(" today is Sunday ")
            
            self.present(BaseUIController().showAlertView("Thank you for choosing Hindustan Wellness. You will receive a verification call to confirm your sample pickup slot for tomorrow ."), animated: true, completion: nil)
        
        }
            
            self.updatePickupTime()
            bgView.removeFromSuperview()
            pickupDay_Time = pickupDay  +  pickupTime
            lblPickUpDate.text = pickupDay_Time
        
    }
    func btnMakePaymentOnClick()  {
        
        if self.getPickupAddressDetails() != "" {
            let paymentOptionsVC = PaymentOptionsViewController()
            if isCouponCodeApply {
                paymentOptionsVC.totalAmount =  currencySymbol + String(afterDiscoutTotalPrice)
                paymentOptionsVC.discout_Percentage = discountPercentage
            }else{
                paymentOptionsVC.totalAmount = currencySymbol + totalAmount
            }
            paymentOptionsVC.isUseWalletBalance = isWalletBalanceUse
            self.navigationController?.pushViewController(paymentOptionsVC, animated: true)
        }else {
        pickup_Id = "0"
        self.createAddressPopup()
      
        }
    }
    func btnAddAnotherMemberOnClick(_ button : UIButton)  {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: HomeTabSwipeViewController.self) {
                let _ = self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                break
            }else{
                let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
                let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
                homeTapSwipeVC.identifires = "BOOK AN ORDER"
                homeTapSwipeVC.currentSelectedTapIndex = 0
                self.navigationController?.pushViewController(homeTapSwipeVC, animated: true)
                break
            }
        }
        
    }
    func btnPickUpAddressEditOnClick(){
        self.getCustomerAddress()
        self.showOldPickupAddress()
    }
    func btnDeleteSelectedPackage(_ button : UIButton)  {
        var pkgOrderInfoObj = PackgeOrederInfo()
        pkgOrderInfoObj = arrPackageOrderData[button.tag - 101] as! PackgeOrederInfo
        print(arrPackageOrderData.count)
        if arrPackageOrderData.count != 1 {
            // delete  order from cart from barcode scanner 
            if packageIdFromBarCode != "" {
                let selectedPackageId = pkgOrderInfoObj.packageId
                for i in 0..<arrPackageOrderData.count {
                    
                    var packgeOrderInfo = PackgeOrederInfo()
                    packgeOrderInfo = arrPackageOrderData[i] as! PackgeOrederInfo
                    if (selectedPackageId == packgeOrderInfo.packageId) {
                        arrPackageOrderData.removeObject(at: i)
                        afterDiscoutTotalPrice = 0
                        totalDiscout = 0
                        createALayout()
                        break
                    }
                }
            }else{
               self.disCartPackage(pkgOrderInfoObj)
            
            }
            
        }else{
        self.showAlertView(pkgOrderInfoObj)
        
        }
    }
    func btnApplyOnClick(_ button : UIButton)  {
        txtCouponCode.resignFirstResponder()
        if (button.titleLabel?.text == "Apply"){
            // add progress on View
            activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
            self.view.addSubview(activityIndicator!)
            
            if txtCouponCode.text?.isEmpty == true {
            self.present(BaseUIController().showAlertView("Please enter coupon code and try again."), animated: true, completion: nil)
            }else{
                 getCouponCode()
            }
           
        }else{
            self.isCouponCodeApply = false
            self.afterDiscoutTotalPrice = 0
            self.totalDiscout = 0
            self.scrollView.removeFromSuperview()
            
            if (packageIdFromBarCode != "") {
//                isCouponCodeApply = false
                packageIdFromBarCode = ""
                // afterDiscoutTotalPrice += Int(pkgOrderInfoObj.packagePrice)!
            }
            self.createALayout()
        }
    }
    
    func barButtonBackClick(_ barButton : UIBarButtonItem)  {
        if (self.title == "PACKAGES" || self.title == "MEMBER LIST"){
            self.title = "CHECKOUT"
            bgView.removeFromSuperview()
        }else{
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: HomeViewController.self) {
                    let _ = self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                    break
                }
            }

        }
       
       
        
    }
    func btnWalletBalanceOnClick(_ button : UIButton)  {
        if isWalletBalanceUse == false {
            self.isWalletBalanceUse = true
        }else{
            self.isWalletBalanceUse = false
        }
        if (packageIdFromBarCode != "") {
         isCouponCodeApply = true
        }
        self.afterDiscoutTotalPrice = 0
        self.totalDiscout = 0
        self.scrollView.removeFromSuperview()
        self.createALayout()
        
    }
    func btnContinueOnClick(_ Sender:UIButton)  {
        
//        if arrCartPackageOrderData.count != 0 {
//            let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
//            let homeTapSwipeVC = storyboard1.instantiateViewControllerWithIdentifier("HomeTabSwipeViewController") as! HomeTabSwipeViewController
//            homeTapSwipeVC.identifires = "BOOK AN ORDER"
//            homeTapSwipeVC.currentSelectedTapIndex = 1
//            self.navigationController?.pushViewController(homeTapSwipeVC, animated: true)
//            
//        }else{
//            self.presentViewController(BaseUIController().showAlertView("Please Select a test to Continue Booking order."), animated: true, completion: nil)
//        }
        afterDiscoutTotalPrice = 0
        totalDiscout = 0
        isCouponCodeApply = true
        self.scrollView.removeFromSuperview()
        bgView.removeFromSuperview()
        createALayout()
        
        
    }
    
    func btnAddOnClick(_ Sender:UIButton)  {
        
        let buttonPosition = Sender.convert(CGPoint.zero, to: packageTableView)
        let indexPath = packageTableView.indexPathForRow(at: buttonPosition)
        
        
        if Sender.isSelected == false {
            Sender.backgroundColor = UIColor.red
            Sender.layer.borderColor = UIColor.red.cgColor
            Sender.setTitleColor(UIColor.white, for: UIControlState())
            Sender.isSelected = true
            if searchController.isActive == false  {
              //  self.insertOrderPackageInDB(arrPakageData.objectAtIndex((indexPath?.row)!) as! NSDictionary)
                addNewPackageInArray(arrPakageData.object(at: ((indexPath as NSIndexPath?)?.row)!) as! NSDictionary)
                
            }else{
              //  self.insertOrderPackageInDB(self.arrFilterPakageData.objectAtIndex((indexPath?.row)!) as! NSDictionary)
                addNewPackageInArray(arrFilterPakageData.object(at: ((indexPath as NSIndexPath?)?.row)!) as! NSDictionary)
            }
            
        }else{
            Sender.backgroundColor = UIColor.clear
            Sender.layer.borderColor = UIColor.orange.cgColor
            Sender.setTitleColor(UIColor.red, for: UIControlState())
            Sender.isSelected = false
            if searchController.isActive == false  {
            //    self.deleteOrderPackageFromDB(arrPakageData.objectAtIndex((indexPath?.row)!) as! NSDictionary)
                 self.deleteAddedPackageFromArray(arrPakageData.object(at: ((indexPath as NSIndexPath?)?.row)!) as! NSDictionary)
                
            }else{
             //   self.deleteOrderPackageFromDB(self.arrFilterPakageData.objectAtIndex((indexPath?.row)!) as! NSDictionary)
                self.deleteAddedPackageFromArray(self.arrFilterPakageData.object(at: ((indexPath as NSIndexPath?)?.row)!) as! NSDictionary)

            }
        }
        
    }
    func btnSelectmemberName(_ button : UIButton)  {
        
        
         arrMyFamilyList = HomeViewController().getMyFamilyList()
         self.showMemberList()
        
    }
    func btnAddExtraPackage(_ button : UIButton)  {
       // showAllPackages()
        
        if arrPakageData.count != 0 {
           // arrPakageData = NSUserDefaults.standardUserDefaults().valueForKey("allpackages") as! NSMutableArray
            showAllPackages()
        }else{
            self.getAllTestProduct()
        }
        
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
    
    func addNewPackageInArray(_ selectedData : NSDictionary)  {
        
        let memberId  = UserDefaults.standard.value(forKeyPath: "selectedMemberId")as! String

        
        let packgeOrderInfo = PackgeOrederInfo()
        packgeOrderInfo.orderId =  memberId //NSUserDefaults.standardUserDefaults().valueForKey("loginCustomerId") as! String
        packgeOrderInfo.packageId = selectedData.value(forKey: "pkg_id") as! String
        packgeOrderInfo.packageName = selectedData.value(forKey: "pkg_name") as! String

        packgeOrderInfo.packagePrice = selectedData.value(forKey: "pkg_price") as! String
        packgeOrderInfo.packageType = selectedData.value(forKey: "pac_test_type") as! String
        arrPackageOrderData.add(packgeOrderInfo)
        updateUILayout()
    }
    func deleteAddedPackageFromArray(_ selectedData : NSDictionary)  {
        for i in 0..<arrPackageOrderData.count {
            let selectedPackageId = selectedData.value(forKey: "pkg_id") as! String
            var packgeOrderInfo = PackgeOrederInfo()
            packgeOrderInfo = arrPackageOrderData[i] as! PackgeOrederInfo
            print(packgeOrderInfo.packageId)
            if (selectedPackageId == packgeOrderInfo.packageId) {
                arrPackageOrderData.removeObject(at: i)
                updateUILayout()
                break
            }
            
            
        }
        
    }
    
    func updateUILayout()  {
        if arrPackageOrderData.count > 0 {
            lblTestSelectd.text = String(arrPackageOrderData.count) + " Tests Selected"
        }else{
            lblTestSelectd.text = "None"
        }
        var price = 0
        for i in 0..<arrPackageOrderData.count {
            var pkgOrderInfo = PackgeOrederInfo()
            pkgOrderInfo = arrPackageOrderData[i] as! PackgeOrederInfo
            price +=  Int(pkgOrderInfo.packagePrice)!
        }
//        let currencyCode = "INR"
//        let localeComponents = [NSLocale.Key.currencyCode: currencyCode]
//        let localeIdentifier = Locale.localeIdentifier(fromComponents: localeComponents as! [String : String])
//        let locale = Locale(localeIdentifier: localeIdentifier)
//        let currencySymbol = (locale as NSLocale).object(forKey: NSLocale.Key.currencySymbol) as! String
        let currencySymbol = (Locale(identifier:"de") as NSLocale).displayName(forKey: .currencySymbol, value: "INR")!
        btnContinue.setTitle(String(format: "Continue(%@)",currencySymbol + String(price)), for: UIControlState())
    }

    
    
    // MARK: CallWebservice
    func getCustomerAddress() {
        if Reachability.isConnectedToNetwork() == true {
          //  activityIndicator?.start()
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            
            let allParameters = ["customerId" : customerId]
            ServerConnectivity().callWebservice(allParameters , resulttagname: "GetCustomerAddressesResult" ,methodname: "GetCustomerAddresses", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    func getCouponCode()  {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let allParameters = ["coupon" : txtCouponCode.text!]
            ServerConnectivity().callWebservice(allParameters , resulttagname: "ApplyCouponResult" ,methodname: "ApplyCoupon", className: self)
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
    
    func getAllTestProduct()  {
        
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            
            let allParameters = ["testId":"0"]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetPackagePriceResult" ,methodname: "GetPackagePrice", className: self)
        }else{
            
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
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
                    self.bgView.removeFromSuperview()
                    self.present(BaseUIController().showAlertView("No Record"), animated: true, completion: nil)
                }else if (allResponse is String && allResponse as! String == "error") // allResponse is String && allResponse as! String != "" ||
                {
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }else if(methodName == "InsertUpdatePickupAddress")
                {
                    if allResponse is String &&  allResponse as! String != "0"{
                        self.pickup_Id = "0"
                        self.insertPickupDetailsInDataBase()
                        // get address from local database
                        self.lblPickupFullAddress.text = self.getPickupAddressDetails()
                        
                    }else{
                        self.pickup_Id = "0"
                        self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    }
                }else if(methodName == "GetPackagePrice" ){
                    
                     UserDefaults.standard.set((allResponse as? NSMutableArray)!, forKey: "allpackages")
                     self.arrPakageData = UserDefaults.standard.value(forKey: "allpackages") as! NSMutableArray
                     self.showAllPackages()
                }
                else{
                    if(methodName == "GetCustomerAddresses"){
                        self.pickupAddressTableView.delegate      =   self
                        self.pickupAddressTableView.dataSource    =   self
                        self.arrOldPickupAddress = allResponse as! NSMutableArray
                        self.pickupAddressTableView.reloadData()
                    }else{
                      self.applyCoupon(allResponse as! NSArray)
                    }
                }
                
            });
        }//);
    }
    
    //MARK: dataBaseOperation
    func getPurchasedPackageData()  {
        
        
        let database = appDelegate.openDataBase()
        do {
               // let rs = try database.executeQuery("select * from Order_Package_Purchased", values: nil)
               let rs = try database.executeQuery("select * from Order_Package_Purchased order by orderid", values: nil)
                arrPackageOrderData = NSMutableArray()
                while rs.next() {
                    let pkgOrderInfo = PackgeOrederInfo()
                    pkgOrderInfo.orderId = rs.string(forColumn: "OrderId")
                    pkgOrderInfo.packageId = rs.string(forColumn: "PackageId")
                    pkgOrderInfo.packageName = rs.string(forColumn: "PackageName")
                    pkgOrderInfo.packagePrice = rs.string(forColumn: "PackagePrice")
                    pkgOrderInfo.packageType = rs.string(forColumn: "PackageType")
                    arrPackageOrderData.add(pkgOrderInfo)
                }
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            
            database.close()
    }
    
    
    func totalAmount(_ arrData : NSMutableArray) -> String   {
        var price:Int = 0
        for i in 0..<arrData.count {
            var pkgOrderInfo = PackgeOrederInfo()
            pkgOrderInfo = arrData[i] as! PackgeOrederInfo
            price +=  Int(pkgOrderInfo.packagePrice)!
            
        }
        totalAmount = String(price)
        return totalAmount
    }
    func getMemberImage(_ memberId : String) -> String {
        
        
        let database = appDelegate.openDataBase()
        var photoSting = ""
        
        do {
            let rs = try database.executeQuery(String(format:"select MemberName from myfamily where MemberId = '%@'",memberId ), values: nil)
            while rs.next() {
                
             photoSting = rs.string(forColumn: "MemberName")
                            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
        return photoSting
    }
    
    func updatePickupTime(){
        
        let database = appDelegate.openDataBase()
        let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
        do {
            try database.executeUpdate(String(format:"update PickupAddress set  OrderDay = '%@', OrderTime = '%@' where MemberId = '%@'",pickupDay, pickupTime , customerId), values: nil)
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
       
    }
    func getPickupAddressDetails() -> String  {
        
       
        let database = appDelegate.openDataBase()
        do {
            let rs = try database.executeQuery("select * from PickupAddress ", values: nil)
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
                
                pickupDay = pickupAddressObj.OrderDay
                pickupTime = pickupAddressObj.OrderTime
                pickupDay_Time = pickupDay  +  pickupTime
            }

        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        var fullAddress = ""
        if pickupAddressObj.AddressLine2 != "" {
            fullAddress = String(format: "%@ , %@,%@,%@,%@ %@", pickupAddressObj.AddressLine1 ,pickupAddressObj.AddressLine2 , pickupAddressObj.LandMark ,pickupAddressObj.GeoAddress ,pickupAddressObj.City , pickupAddressObj.Pincode)
        }else{
            fullAddress = String(format: "%@ ,%@,%@,%@ %@", pickupAddressObj.AddressLine1 , pickupAddressObj.LandMark ,pickupAddressObj.GeoAddress ,pickupAddressObj.City , pickupAddressObj.Pincode)
        }
        if (fullAddress == " ,,, " || fullAddress == " ,,,, ") {
            fullAddress = ""
            pickupDay = "Tomorrow "
            pickupTime =  "06:00-06:30"
            pickupDay_Time = pickupDay  +  pickupTime
            lblPickUpDate.text = pickupDay_Time
            
            return  fullAddress
        }else{
        
        return fullAddress
        }
        
    }
    func disCartPackage(_ pkgOrderInfo : PackgeOrederInfo)  {
        
        let database = appDelegate.openDataBase()
        
        do {
            let memberId  = pkgOrderInfo.orderId
            let PackageId = pkgOrderInfo.packageId
            
            try database.executeUpdate(String(format:"delete from Order_Package_Purchased where OrderId = %@  and PackageId = '%@'",memberId,PackageId), values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        getPurchasedPackageData()
        afterDiscoutTotalPrice = 0
        totalDiscout = 0
        scrollView.removeFromSuperview()
        createALayout()
        
    }
    
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

    // MARK: - KeyboardShow&Hide
    func keyboardWillShow(_ notification:Notification){
        scrollView.frame = CGRect(x: 0 , y: -60 , width: self.view.frame.width , height: scrollView.frame.height)
       // scrollView.contentSize = CGSizeMake(self.view.frame.width, scrollView.frame.height + 250)
        scrollViewForAddress.contentSize = CGSize(width: baseView.frame.width, height: baseView.frame.height + 100)
    }
    
    func keyboardWillHide(_ notification:Notification){
        scrollView.frame = CGRect(x: 0 , y: 90 , width: self.view.frame.width , height: scrollView.frame.height )
       // scrollView.contentSize = CGSizeMake(self.view.frame.width, scrollView.frame.height + 250)
        scrollViewForAddress.contentSize = CGSize(width: baseView.frame.width, height: baseView.frame.height + 100)
        
    }
    func applyCoupon(_ arrCouponData : NSArray) {
        
        
        coupon_type = (arrCouponData[0] as AnyObject).value(forKey: "couponType")as! String
        let couponVlaue = (arrCouponData[0] as AnyObject).value(forKey: "couponValue")as! String
        if couponVlaue != "0" {
        if ((arrCouponData[0] as AnyObject).value(forKey: "couponType")as! String == "A") {
            
            let minAmount = (arrCouponData[0] as AnyObject).value(forKey: "minAmount")as! String
            if (Int(totalAmount) >= Int(minAmount)) {
                self.discountPercentage = Int((arrCouponData[0] as AnyObject).value(forKey: "couponValue")as! String)!
                self.isCouponCodeApply = true
                self.afterDiscoutTotalPrice = 0
                self.totalDiscout = 0
                self.scrollView.removeFromSuperview()
                self.createALayout()
            }else{
                self.present(BaseUIController().showAlertView("Coupon not apply less then total amount of  " + minAmount), animated: true, completion: nil)
            }
        }else{
            self.discountPercentage = Int((arrCouponData[0] as AnyObject).value(forKey: "couponValue")as! String)!
            self.pkg_type = (arrCouponData[0] as AnyObject).value(forKey: "pkg_type")as! String
           // pkg_type = "P"
            self.isCouponCodeApply = true
            self.afterDiscoutTotalPrice = 0
            self.totalDiscout = 0
            self.scrollView.removeFromSuperview()
            self.createALayout()
        }
        }else{
           self.present(BaseUIController().showAlertView("Coupon not vailid"), animated: true, completion: nil)
        }
        
    }
    
 /*   //MARK: getGEOLocation
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
        
    }  */

    //MARK: showAlert
    
    func showAlertView(_ pkgOrderInfo : PackgeOrederInfo)  {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: "Do you want to add new packages?", preferredStyle: .alert)
        //Create and add the Continue action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Do some stuff
            
        }
        actionSheetController.addAction(cancelAction)
        //        //Create and add the Discart action
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
            //Do some stuff
            self.disCartPackage(pkgOrderInfo)
           // self.navigationController?.popViewControllerAnimated(true)
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: HomeTabSwipeViewController.self) {
                    let _ = self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                    break
                }else{
                    let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
                    let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
                    homeTapSwipeVC.identifires = "BOOK AN ORDER"
                    homeTapSwipeVC.currentSelectedTapIndex = 0
                    self.navigationController?.pushViewController(homeTapSwipeVC, animated: true)
                    break
                }
            }
            
           
        }
        actionSheetController.addAction(okAction)
        //self.presentViewController(actionSheetController, animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.present(actionSheetController, animated: true, completion: nil)
    }

    
 

}
