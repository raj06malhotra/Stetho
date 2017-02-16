//
//  UserDetailsViewController.swift
//  Stetho
//
//  Created by HW-Anil on 2/2/17.
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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class UserDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate ,serverTaskComplete {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtHeightInFeet: UITextField!
    @IBOutlet weak var txtHeightInInch: UITextField!
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var lblBasicDetails: UILabel!
    @IBOutlet weak var lblCalculateHeight: UILabel!
    @IBOutlet weak var lblCalulateBMI: UILabel!
    @IBOutlet var tickImage:UIImageView!
    @IBOutlet var viewTickUntick:UIView!
    @IBOutlet var btnTickUntick:UIButton!
    @IBOutlet var problamTableView:UITableView!
    @IBOutlet var btnDone:UIButton!
    
    
    var btnSkip = UIButton()
    
    
    let boderColor: UIColor =  UIColor (red: (252.0/255.0), green: (199.0/255.0), blue: (99.0/255.0), alpha: 1)
    var activityIndicator : ProgressViewController?
    var selectedBloodGroup = ""
    var memberId: String = ""
    var memberName: String = ""
    var arrMemberProfileInfoDetails = NSArray()
    var arrBloodGroup : Array = ["A+" ,"B+","AB+","O+","A-","B-","AB-","O-"]
    var isFromCorporate = ""
    var problamsArr = [KDIABETES, KTHYROID, KHEART_PROBLEM, KHIGH_CHOLESTROL, KHIGHT_BP, KANAEMIA, KLIVER_RELATED, KKIDNEY_RELATED, KOSTEOPOROSIS, KARTHRITIS, KPROSTATE, KPCOS_PCOD]
    var problamDict:[String: String] = [KDIABETES : "0,0,0", KTHYROID : "0,0,0", KHEART_PROBLEM : "0,0,0", KHIGH_CHOLESTROL : "0,0,0", KHIGHT_BP : "0,0,0", KANAEMIA : "0,0,0", KLIVER_RELATED : "0,0,0", KKIDNEY_RELATED : "0,0,0", KOSTEOPOROSIS : "0,0,0", KARTHRITIS : "0,0,0", KPROSTATE : "0,0,0", KPCOS_PCOD : "0,0,0"]
    let appDelegate = AppDelegate.getAppDelegate()
    var isComingfromCheckinBarCode:Bool?
    var currentTextField : UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.createAlayoutDesign()
        //add ActivityIndicator on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        self.view.addSubview(activityIndicator!)
        
        problamTableView.isScrollEnabled = false
        hideProblemTableView()
        problamTableView.separatorStyle = .none
        //        if isFromCorporate == "yes" {
        //             btnSkipAll.hidden = true
        //        }else{
        //             self.getMemberProfileInfo()
        //        }
        //                    appdelegate.corporateAllDetailsDict.setValue(selectedSegIndex, forKey: "selectedaddress")
    }
    override func viewWillAppear(_ animated: Bool) {
//        btnSave_Next.hidden = true
//        btnSkipAll.hidden = true
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.topItem?.title = "Back"
        self.title = KMEDICAL_HISTORY
        txtHeightInFeet.layer.borderWidth = 1.0
        txtHeightInFeet.layer.borderColor = UIColor(red: 255.0/255.0, green: 167.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        
        txtHeightInInch.layer.borderWidth = 1.0
        txtHeightInInch.layer.borderColor = UIColor(red: 255.0/255.0, green: 167.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        
        txtWeight.layer.borderWidth = 1.0
        txtWeight.layer.borderColor = UIColor(red: 255.0/255.0, green: 167.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        
        self.navigationController?.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
        
        if isFromHome(){
            btnDone.setTitle(KPROCEED, for: UIControlState())
        }else{
            btnDone.setTitle(KDONE, for: UIControlState())
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillLayoutSubviews() {
        //        if self.view.frame.height == 480 {
        //            scrollView.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height + 100)
        //        }
        
        if btnTickUntick.isSelected == true{
            scrollView.contentSize = CGSize(width: 0, height: 270+(37*12))
        }else{
            scrollView.contentSize = CGSize(width: 0, height: 200)
        }
    }
    
    //MARK:// Custom Methods
    
    func setProblamDictValuestoZero() {
       problamDict = [KDIABETES : "0,0,0", KTHYROID : "0,0,0", KHEART_PROBLEM : "0,0,0", KHIGH_CHOLESTROL : "0,0,0", KHIGHT_BP : "0,0,0", KANAEMIA : "0,0,0", KLIVER_RELATED : "0,0,0", KKIDNEY_RELATED : "0,0,0", KOSTEOPOROSIS : "0,0,0", KARTHRITIS : "0,0,0", KPROSTATE : "0,0,0", KPCOS_PCOD : "0,0,0"]
    }
    
    func createAlayoutDesign()  {
        //        btnAPositive.layer.borderWidth = 1
        //        btnAPositive.layer.borderColor = boderColor.CGColor
        //        btnBPositive.layer.borderWidth = 1
        //        btnBPositive.layer.borderColor = boderColor.CGColor
        //        btnABPositive.layer.borderWidth = 1
        //        btnABPositive.layer.borderColor = boderColor.CGColor
        //        btnOPositive.layer.borderWidth = 1
        //        btnOPositive.layer.borderColor = boderColor.CGColor
        //
        //        btnANegative.layer.borderWidth = 1
        //        btnANegative.layer.borderColor = boderColor.CGColor
        //        btnBNegative.layer.borderWidth = 1
        //        btnBNegative.layer.borderColor = boderColor.CGColor
        //        btnABNegative.layer.borderWidth = 1
        //        btnABNegative.layer.borderColor = boderColor.CGColor
        //        btnONegative.layer.borderWidth = 1
        //        btnONegative.layer.borderColor = boderColor.CGColor
        //
        //        txtHeightInFeet.layer.borderWidth = 1
        //        txtHeightInFeet.layer.borderColor = boderColor.CGColor
        //        txtHeightInInch.layer.borderWidth = 1
        //        txtHeightInInch.layer.borderColor = boderColor.CGColor
        //        txtWeight.layer.borderWidth = 1
        //        txtWeight.layer.borderColor = boderColor.CGColor
        //        txtWaistSize.layer.borderWidth = 1
        //        txtWaistSize.layer.borderColor = boderColor.CGColor
        //
        //        btnSave_Next.layer.borderWidth = 2
        //        btnSave_Next.layer.borderColor = UIColor .redColor().CGColor
        //        btnSkipAll.layer.borderWidth = 2
        //        btnSkipAll.layer.borderColor = UIColor .redColor().CGColor
        //add numeric keyboad & tool bar on textfield
        txtHeightInFeet.keyboardType = .numberPad
        addToolbartoTextfield(txtHeightInFeet)
        txtHeightInInch.keyboardType = .numberPad
        addToolbartoTextfield(txtHeightInInch)
        txtWeight.keyboardType = .numberPad
        addToolBar(txtWeight)
        //        txtWaistSize.keyboardType = .NumberPad
        //        addToolBar(txtWaistSize)
        if isFromCorporate != "yes" {
            //Add skip button on Navigation bar
            //        btnSkip = BaseUIController().AButtonFrame(CGRect(x: 0  ,y: 7 , width: 50 , height: 30), withButtonTital: "Skip")as! UIButton
            //        btnSkip.backgroundColor = UIColor.whiteColor()
            //        btnSkip.setTitleColor(UIColor.redColor(), forState: .Normal)
            //        btnSkip.addTarget(self, action: #selector(MedicalHistoryThirdViewController.btnSkipOnClick(_:)), forControlEvents: .TouchUpInside)
            //        let rightBarButton = UIBarButtonItem(customView: btnSkip)
            //        self.navigationItem.rightBarButtonItem = rightBarButton
        }
        //change dynamic text on UIlable
        //        if memberName != "" {
        lblBasicDetails.text = KPROVIDEBASIC_DETAILS//String(format: "Provide %@ basic detais" , memberName)
        lblCalculateHeight.text = KCALC_BMI//String(format: "To calculate %@ BMI",memberName)
        lblCalulateBMI.text = KCALC_BMI//String(format: "To calculate %@ BMI",memberName)
        //            let blackText = String(format: "Choose  %@ " , memberName)
        //            lblChooseBlooodGroup.attributedText = self.changeTextWithMultipleColor(blackText, redString: "Blood Group")
        //        }else{
        //            lblChooseBlooodGroup.attributedText = self.changeTextWithMultipleColor("Choose Your ", redString: "Blood Group")
        //        }
    }
    
    func showProblemTableView(){
        btnTickUntick.isSelected = true
        tickImage.image = UIImage(named: "check-mark")
        problamTableView.frame = CGRect(x: problamTableView.frame.origin.x, y: problamTableView.frame.origin.y, width: problamTableView.frame.size.width, height: 37*12)
        btnDone.frame = CGRect(x: btnDone.frame.origin.x, y: (problamTableView.frame.origin.y + problamTableView.frame.size.height + 10), width: btnDone.frame.size.width, height: btnDone.frame.size.height)
        
    }
    
    func hideProblemTableView(){
        btnTickUntick.isSelected = false
        tickImage.image = UIImage(named: "blank-check-box")
        problamTableView.frame = CGRect(x: problamTableView.frame.origin.x, y: problamTableView.frame.origin.y, width: problamTableView.frame.size.width, height: 0)
        
        
        btnDone.frame = CGRect(x: btnDone.frame.origin.x, y: (viewTickUntick.frame.origin.y + viewTickUntick.frame.size.height + 10), width: btnDone.frame.size.width, height: btnDone.frame.size.height)
        
    }
    
    func getProblamValuesArr(_ index:Int) -> [String]{
        let value = problamDict[problamsArr[index]]
        return value!.components(separatedBy: ",")
    }
    
    func updateProblamValuesInCellIndex(_ index: Int, forMemberIndex: Int){
        //            let value = problamDict[problamsArr[index]]
        var valuesArr = getProblamValuesArr(index)//value?.componentsSeparatedByString(",")
        if valuesArr[forMemberIndex] == "0"{
            valuesArr[forMemberIndex] = "1"
        }else{
            valuesArr[forMemberIndex] = "0"
        }
        problamDict[problamsArr[index]] = valuesArr.joined(separator: ",")
        problamTableView.reloadData()
    }
    
    func isFromHome() -> Bool{
        if appDelegate.corporateAllDetailsDict.value(forKey: "selectedaddress")as! String == "1"{
            return true
        }else{
            return false
        }
    }
    
    //MARK: TextFieldDelgete
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        switch textField {
        case txtHeightInFeet:
            txtHeightInInch.becomeFirstResponder()
        case txtHeightInInch:
            txtWeight.becomeFirstResponder()
        default:
            break
        }
        return true//
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        if textField == txtHeightInFeet {
            var startString = ""
            if (textField.text != nil)
            {
                startString += textField.text!
            }
            startString += string
            let limitNumber = Int(startString)
            return limitNumber <= 9
        }else if(textField == txtHeightInInch){
            var startString = ""
            if (textField.text != nil)
            {
                startString += textField.text!
            }
            startString += string
            let limitNumber = Int(startString)
            return limitNumber <= 11
        }else if(textField == txtWeight)
        {
            var startString = ""
            if (textField.text != nil)
            {
                startString += textField.text!
            }
            startString += string
            let limitNumber = Int(startString)
            return limitNumber <= 200
        }else{
            var startString = ""
            if (textField.text != nil)
            {
                startString += textField.text!
            }
            startString += string
            let limitNumber = Int(startString)
            return limitNumber <= 50
        }
        
    }
    
    //MARK: Tableview delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return problamsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let problemCell = tableView.dequeueReusableCell(withIdentifier: "ProblamsTableViewCell", for: indexPath) as! ProblamsTableViewCell
        
        problemCell.lblProblam.text = problamsArr[(indexPath as NSIndexPath).row]
        problemCell.btnSelf.setTitle(KSELF, for: UIControlState())
        problemCell.btnSelf.tag = (indexPath as NSIndexPath).row
        problemCell.btnSelf.layer.cornerRadius = 4.0
        problemCell.btnFather.layer.cornerRadius = 4.0
        problemCell.btnMother.layer.cornerRadius = 4.0
        problemCell.btnMother.layer.borderWidth = 1.0
        problemCell.btnFather.layer.borderWidth = 1.0
        problemCell.btnSelf.layer.borderWidth = 1.0
        
        
        
        problemCell.btnSelf.addTarget(self, action: #selector(UserDetailsViewController.selfBtnClicked(_:)), for: .touchUpInside)
        
        problemCell.btnFather.setTitle(KFATHER, for: UIControlState())
        problemCell.btnFather.tag = (indexPath as NSIndexPath).row
        problemCell.btnFather.addTarget(self, action:#selector(UserDetailsViewController.fatherBtnClicked(_:)), for: .touchUpInside)
        
        problemCell.btnMother.setTitle(KMOTHER, for: UIControlState())
        problemCell.btnMother.tag = (indexPath as NSIndexPath).row
        problemCell.btnMother.addTarget(self, action: #selector(UserDetailsViewController.motherBtnClicked(_:)), for: .touchUpInside)
        
        if (indexPath as NSIndexPath).row == 11{
            problemCell.btnFather.isHidden = true
        }else{
            problemCell.btnFather.isHidden = false
        }
        
        if (indexPath as NSIndexPath).row == 10{
            problemCell.btnMother.isHidden = true
        }else{
            problemCell.btnMother.isHidden = false
        }
        
        
        let values = getProblamValuesArr((indexPath as NSIndexPath).row)
        
        if values[0] == "0"{
            problemCell.btnSelf.layer.borderColor = UIColor(red: 255.0/255.0, green: 167.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
            problemCell.btnSelf.setTitleColor(UIColor.darkGray, for: UIControlState())
            problemCell.btnSelf.backgroundColor = UIColor.clear
        }else{
            problemCell.btnSelf.backgroundColor = UIColor.red
            problemCell.btnSelf.setTitleColor(UIColor.white, for: UIControlState())
            
        }
        
        if values[1] == "0"{
            problemCell.btnFather.layer.borderColor = UIColor(red: 255.0/255.0, green: 167.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
            problemCell.btnFather.setTitleColor(UIColor.darkGray, for: UIControlState())
            
            problemCell.btnFather.backgroundColor = UIColor.clear
        }else{
            problemCell.btnFather.backgroundColor = UIColor.red
            problemCell.btnFather.setTitleColor(UIColor.white, for: UIControlState())
        }
        
        
        if values[2] == "0"{
            problemCell.btnMother.layer.borderColor = UIColor(red: 255.0/255.0, green: 167.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
            problemCell.btnMother.setTitleColor(UIColor.darkGray, for: UIControlState())
            
            problemCell.btnMother.backgroundColor = UIColor.clear
        }else{
            problemCell.btnMother.backgroundColor = UIColor.red
            problemCell.btnMother.setTitleColor(UIColor.white, for: UIControlState())
            
        }
        
        problemCell.selectionStyle = .none
        return problemCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 37
    }
    
    func getMemberProfileInfo()  {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let allParameters = ["memberId":self.memberId, "profilePage": "1"]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetMemberProfileResult" ,methodname: "GetMemberProfile", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
        
    }
    
    //MARK: UploadDataOnServer
    //METHOD CALL WHEN NOT COMING FROM COPERATE
    func uploadMedicalHisotyPageOneData()  {
//        if Reachability.isConnectedToNetwork() == true {
//            activityIndicator?.start()
//            let customerId = NSUserDefaults.standardUserDefaults().valueForKey("loginCustomerId")as! String
//            let allParameters = ["memberId":self.memberId, "customerId":customerId ,"heightft":txtHeightInFeet.text!,"heightin":txtHeightInInch.text!,"weight":txtWeight.text!,"waist": txtWaistSize.text! ,"bloodGroup":selectedBloodGroup]
//            ServerConnectivity().callWebservice(allParameters, resulttagname: "SaveProfilePage1Result" ,methodname: "SaveProfilePage1", className: self)
//        }else{
//            
//            self.presentViewController(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
//        }
        
    }
    
    //MARK: SERVICE DELEGATES
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                self.activityIndicator?.stop()
                // getMemberProfileInfo result
                if(methodName == "SaveProfilePage1"){
                    let resultString = allResponse as! String
                    if (resultString == "1"){
                        self.sendToNextViewController()
                    }else{
                        
                    }
                }else if (methodName == "SaveCorporateCustomer_V2"){
                    UserDefaults.standard.set(false, forKey: "iscorporate")
                    self.appDelegate.loadMainview()
                }else if(methodName == "SaveCorporateCustomer_V3"){
                    if allResponse as! String == "error" || allResponse as! String == "0"{
                        self.present(BaseUIController().showAlertView("Some thing went wrong"), animated: true, completion: nil)
                    }else{
                        self.appDelegate.loadMainview()
                    }
                }else{
                    if  allResponse is String {
                        
                    }else{
                        self.arrMemberProfileInfoDetails = allResponse as! NSArray
                        self.populateMemberProfileInfo()
                    }
                }
            });
        });
        
    }
    
    //MARK: chageWihtMultipleTextAttributeColor
    func changeTextWithMultipleColor(_ blackString : String , redString : String) -> NSMutableAttributedString {
        
        let attrs1      = [NSFontAttributeName: UIFont().regularMediumFont, NSForegroundColorAttributeName:UIColor.black]
        let attrs2      = [NSFontAttributeName: UIFont().regularMediumFont, NSForegroundColorAttributeName: UIColor.red]
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: blackString , attributes:  attrs1))
        attributedText.append(NSAttributedString(string: redString, attributes: attrs2))
        return attributedText
    }
    
    //MARK: IBAction ButtonAction
    
    @IBAction func selfBtnClicked(_ sender:AnyObject){
        print("Self in %d row",sender.tag)
        // updateProblamValuesInCellIndex(sender.tag)
        updateProblamValuesInCellIndex(sender.tag, forMemberIndex: 0)
    }
    
    @IBAction func fatherBtnClicked(_ sender:AnyObject){
        print("Self in %d row",sender.tag)
        updateProblamValuesInCellIndex(sender.tag, forMemberIndex: 1)
        
        
        // updateProblamValuesInCellIndex(sender.tag)
    }
    
    @IBAction func motherBtnClicked(_ sender:AnyObject){
        print("Self in %d row",sender.tag)
        updateProblamValuesInCellIndex(sender.tag, forMemberIndex: 2)
        
        
        //  updateProblamValuesInCellIndex(sender.tag)
    }
    
    @IBAction func btnDoneClicked(_ sender: AnyObject) {
        if isFromCorporate == "yes" || isComingfromCheckinBarCode == true {
            if (txtHeightInFeet.text?.isEmpty == true || txtHeightInInch.text?.isEmpty == true) {
                self.present(BaseUIController().showAlertView(KENTER_HEIGHT), animated: true, completion: nil)
                
            }else if(txtWeight.text?.isEmpty == true){
                self.present(BaseUIController().showAlertView(KENTER_WEIGHT), animated: true, completion: nil)
            }else{
                appDelegate.corporateAllDetailsDict.setValue(txtHeightInFeet.text!, forKey: KHEIGHT_FEET)
                appDelegate.corporateAllDetailsDict.setValue(txtHeightInInch.text!, forKey: KHEIGHT_INCH)
                appDelegate.corporateAllDetailsDict.setValue(txtWeight.text!, forKey: KWEIGHT)
                appDelegate.corporateAllDetailsDict.setValue(problamDict, forKey: KPROBLEMS_DICT)
                appDelegate.corporateAllDetailsDict.setValue(problamsArr, forKey: KPROBLEMS_Arr)
                
                print(appDelegate.corporateAllDetailsDict)
                if isFromHome() {
                    //Will push to address controller
                    let corporateAddress = CorporateAddrssViewController()
                    corporateAddress.isComingfromCheckinBarCode = isComingfromCheckinBarCode
                    self.navigationController?.pushViewController(corporateAddress, animated: true)
                }else{
                    saveAllMedicalHistory()
                }
            }
        }
            //        else if isComingfromCheckinBarCode == true{
            //
            //        }
        else{
            //Will do it later
            self.uploadMedicalHisotyPageOneData()
        }
    }
    
    
    //NOT IN USE
    @IBAction func btnSave_NextOnClick(_ sender: AnyObject) {
        if (isFromCorporate == "yes") {
            
            if (txtHeightInFeet.text?.isEmpty == true || txtHeightInInch.text?.isEmpty == true) {
                
                self.present(BaseUIController().showAlertView("Please Enter Height!"), animated: true, completion: nil)
                
            }else if(txtWeight.text?.isEmpty == true){
                
                self.present(BaseUIController().showAlertView("Please Enter Weight!"), animated: true, completion: nil)
                
            }else{
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                appdelegate.corporateAllDetailsDict.setValue(txtHeightInFeet.text!, forKey: "heightinfeet")
                appdelegate.corporateAllDetailsDict.setValue(txtHeightInInch.text!, forKey: "heightininch")
                appdelegate.corporateAllDetailsDict.setValue(txtWeight.text!, forKey: "weight")
                appdelegate.corporateAllDetailsDict.setValue(selectedBloodGroup, forKey: "bloodgroup")
              //  appdelegate.corporateAllDetailsDict.setValue(txtWaistSize.text!, forKey: "waist")
                
                print(appdelegate.corporateAllDetailsDict)
                self.sendToNextViewController()
            }
            
        }else{
            self.uploadMedicalHisotyPageOneData()
        }
    }
    
    
    //NOT IN USE
    @IBAction func btnSkipAllOnClick(_ sender: UIButton) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: MyFamilyViewController.self) {
                let _ = self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                break
            }
        }
    }
    
    //NOT IN USE
    @IBAction func btnBloodGroupSelected(_ sender: AnyObject) {
        let selectedButton = self.view.viewWithTag(sender.tag) as? UIButton
        selectedButton?.backgroundColor = UIColor.red
        for i in 0..<9 {
            if sender.tag == 301 + i {
                
                selectedButton?.backgroundColor = UIColor.red
                selectedBloodGroup = (selectedButton?.titleLabel?.text)!
            }else{
                let nonSelectedButton = self.view.viewWithTag(301+i) as? UIButton
                nonSelectedButton?.backgroundColor = UIColor.clear
            }
            
        }
    }
    
    @IBAction func btnMedicalConditionClicked(_ sender:UIButton){
        if sender.isSelected == false{
            showProblemTableView()
            problamTableView.reloadData()
        }else{
            setProblamDictValuestoZero()
            hideProblemTableView()
        }
        viewWillLayoutSubviews()
    }
    
    //MARK: Custom Methods
    
    func addToolbartoTextfield(_ textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        //toolBar.barTintColor = UIColor .redColor()
        // toolBar.translucent = false
        // toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.tintColor = UIColor.red
        
        let doneButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(UserDetailsViewController.nextPressed(_:)))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action:#selector(UserDetailsViewController.cancelBtnPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        // toolBar.backgroundColor = UIColor .redColor()
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    func nextPressed(_ textField: UITextField){
       let _ = textFieldShouldReturn(currentTextField)
    }
    
    func cancelBtnPressed(){
        
        // view.endEditing(true) // or do something
        view.window!.endEditing(true)
    }

    
    func saveAllMedicalHistory()  {
        
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            
            let customerId = (UserDefaults.standard.value(forKey: "loginCustomerId")as! String)
            //            let alcohal = (appDelegate.corporateAllDetailsDict.valueForKey("alcohal")as! String)
            //            let smoke = (appDelegate.corporateAllDetailsDict.valueForKey("smoke")as! String)
            let dob = (appDelegate.corporateAllDetailsDict.value(forKey: "dob")as! String)
            let gender = (appDelegate.corporateAllDetailsDict.value(forKey: "gender")as! String)
            //let cid =  (appdelegate.corporateAllDetailsDict.valueForKey("cid")as! String)
            //            let bloodPressureStatus = (appDelegate.corporateAllDetailsDict.valueForKey("bloodPressure")as! String)
            //            let bloodGlucose = (appDelegate.corporateAllDetailsDict.valueForKey("bloodGlucose")as! String)
            
            //            let hypertension : NSMutableString = NSMutableString()
            //            hypertension.appendString(appDelegate.corporateAllDetailsDict.valueForKey("hypertensionStatus")as! String)
            //            hypertension.appendString(",")
            //            hypertension.appendString(appDelegate.corporateAllDetailsDict.valueForKey("fatherHypertensionStatus")as! String)
            //            hypertension.appendString(",")
            //            hypertension.appendString(appDelegate.corporateAllDetailsDict.valueForKey("motherHypertensionStatus")as! String)
            //            let hypertension_status = (hypertension as String)
            
            //            let cancer = NSMutableString()
            //            cancer.appendString(appDelegate.corporateAllDetailsDict.valueForKey("cancerStatus")as! String)
            //            cancer.appendString(",")
            //            cancer.appendString(appDelegate.corporateAllDetailsDict.valueForKey("fatherCancerStatus")as! String)
            //            cancer.appendString(",")
            //            cancer.appendString(appDelegate.corporateAllDetailsDict.valueForKey("motherCancerStatus")as! String)
            //            let cancer_status = (cancer as String)
            
            //            let cardio = NSMutableString()
            //            cardio.appendString(appDelegate.corporateAllDetailsDict.valueForKey("cardioStatus")as! String)
            //            cardio.appendString(",")
            //            cardio.appendString(appDelegate.corporateAllDetailsDict.valueForKey("fatherCardioStatus")as! String)
            //            cardio.appendString(",")
            //            cardio.appendString(appDelegate.corporateAllDetailsDict.valueForKey("motherCardioStatus")as! String)
            //            let cardio_status = (cardio as String)
            
            
            //            let diabetes = NSMutableString()
            //            diabetes.appendString("0")
            //            diabetes.appendString(",")
            //            diabetes.appendString(appDelegate.corporateAllDetailsDict.valueForKey("fatherDiabetesStatus")as! String)
            //            diabetes.appendString(",")
            //            diabetes.appendString(appDelegate.corporateAllDetailsDict.valueForKey("motherDiabetesStatus")as! String)
            //            let diabetes_status = (diabetes as String)
            
            let height = NSMutableString()
            height.append(appDelegate.corporateAllDetailsDict.value(forKey: "heightinfeet")as! String)
            if !(height.isEqual("")) {
                height.append(".")
                height.append(appDelegate.corporateAllDetailsDict.value(forKey: "heightininch")as! String)
            }
            
            
            print(height)
            let heightInFeetandInch = (height as String)
            //let bloodgroup = (appDelegate.corporateAllDetailsDict.valueForKey("bloodgroup")as! String)
            // let exercise = (appDelegate.corporateAllDetailsDict.valueForKey("exercise")as! String)
            let weight = (appDelegate.corporateAllDetailsDict.value(forKey: "weight")as! String)
            //NOT IN USE
            //let waist = (appDelegate.corporateAllDetailsDict.valueForKey("waist")as! String)
            
            //   print(appdelegate.corporateAllDetailsDict)
            let firstName = (appDelegate.corporateAllDetailsDict.value(forKey: "firstName")as! String)
            let middleName = ("")
            let lastName = (appDelegate.corporateAllDetailsDict.value(forKey: "lastName")as! String)
            
            
            let mobileNumber = (appDelegate.corporateAllDetailsDict.value(forKey: "mobileno")as! String)
            let personal_email = (appDelegate.corporateAllDetailsDict.value(forKey: "pemail")as! String)
            let official_email = (appDelegate.corporateAllDetailsDict.value(forKey: "oemail")as! String)
            
            var pincode = ""
            var geoAddress = ""
            var geoLong = ""
            var geoLat = ""
            var address1 = ""
            var address2 = ""
            
            var landmark = ""
            var city = ""
            var locality = ""
            var pickupDate = ""
            var pickupTime = ""
            
            //   let allParameters3 = ["firstName":appdelegate.corporateAllDetailsDict.valueForKey("firstName")as! String ,"middleName": "","lastName": appdelegate.corporateAllDetailsDict.valueForKey("lastName")as! String,"mobileNumber" : appdelegate.corporateAllDetailsDict.valueForKey("mobileno")as! String , "oEmail": appdelegate.corporateAllDetailsDict.valueForKey("oemail")as! String ,"pEmail": appdelegate.corporateAllDetailsDict.valueForKey("pemail")as! String ,"isHome": "0" , "pincode" : pincode , "geoAddress" : geoAddress , "geoLong" : geoLong ,"geoLat" : geoLat ,"address1" : address1 ,"address2" : address2, "landmark" : landmark , "city" : city , "locality": locality, "pickupDate" : pickupDate ,"pickupTime" : pickupTime ,"height":height as String,"weight": appdelegate.corporateAllDetailsDict.valueForKey("weight")as! String,"waist" : appdelegate.corporateAllDetailsDict.valueForKey("waist")as! String , "bloodGroup": appdelegate.corporateAllDetailsDict.valueForKey("bloodgroup")as! String ,"Hypertension": hypertension as String ,"Cancer": cancer as String , "Cardio" : cardio as String , "diabetes" : diabetes as String , "bp" : appdelegate.corporateAllDetailsDict.valueForKey("bloodPressure")as! String ,"smokeFrequency" : appdelegate.corporateAllDetailsDict.valueForKey("smoke")as! String ,"alcoholFrequency" : appdelegate.corporateAllDetailsDict.valueForKey("alcohal")as! String ,"exerciseFrequency" : appdelegate.corporateAllDetailsDict.valueForKey("exercise")as! String, "gender" : appdelegate.corporateAllDetailsDict.valueForKey("gender")as! String , "dob" : appdelegate.corporateAllDetailsDict.valueForKey("dob")as! String , "userId":NSUserDefaults.standardUserDefaults().valueForKey("loginCustomerId")as! String]
            
            //  print(allParameters3)
            if appDelegate.corporateAllDetailsDict.value(forKey: "selectedaddress")as! String == "0" {
                
                pincode = ("")
                geoAddress = ("")
                geoLong = ("")
                geoLat = ("")
                address1 = ("")
                address2 = ("")
                landmark = ("")
                city = ("")
                locality = ("")
                pickupDate = ("")
                pickupTime = ("")
                
                
            }
            let isHome = (appDelegate.corporateAllDetailsDict.value(forKey: "selectedaddress")as! String)
            let companyId = UserDefaults.standard.value(forKey: "company_id") as! String
            //            let departmentId = appDelegate.corporateAllDetailsDict.valueForKey("departmentID")as! String
            
            //            if let departmentId = appdelegate.corporateAllDetailsDict.valueForKey("departmentID") {
            //
            //            }else{
            //                departmentId = ""
            //            }
            
            var departmentId = ""
            if let tempId = appDelegate.corporateAllDetailsDict.value(forKey: "departmentID") {
                departmentId = tempId as! String
            }
            
            print(companyId)
            print(departmentId)
            
            
            var allParameters:Dictionary<String, String
                > = [ "firstName" : firstName,  //
                    "middleName" : middleName ,//
                    "lastName":lastName ,//
                    "mobileNumber": mobileNumber,//
                    "pEmail": personal_email ,//
                    "oEmail": official_email,//
                    "isHome":isHome,//
                    "pincode": pincode ,//
                    "geoAddress": geoAddress,//
                    "geoLong": geoLong ,//
                    "geoLat" : geoLat,//
                    "address1": address1,//
                    "address2" : address2 ,//
                    "landmark" : landmark,//
                    "city":city,//
                    "locality" : locality,//
                    "pickupDate" :pickupDate ,//
                    "pickupTime" : pickupTime,//
                    "height":heightInFeetandInch,//
                    "weight": weight,//
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
                    // "waist" : waist,
                    // "bloodGroup": bloodgroup,
                    // "Hypertension": hypertension_status ,
                    // "Cancer":cancer_status ,
                    // "Cardio" : cardio_status ,
                    // "diabetes" : diabetes_status ,
                    // "bloodPressure" : bloodPressureStatus,
                    // "bloodGlucose" : bloodGlucose,
                    // "smokeFrequency" : smoke ,
                    //  "alcoholFrequency" : alcohal ,
                    // "exerciseFrequency" : exercise,
                    "gender" : gender ,//
                    "dob" : dob ,//
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
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    
    //Not in Use
    func btnSkipOnClick(_ button : UIButton)  {
        self.sendToNextViewController()
    }
    
    //Not in Use
    func sendToNextViewController()  {
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        let medicalHistorySecondVC = storyboard1.instantiateViewController(withIdentifier: "MedicalHistorySecondViewController")as! MedicalHistorySecondViewController
        medicalHistorySecondVC.memberId = memberId
        medicalHistorySecondVC.isFromCorporate = isFromCorporate
        medicalHistorySecondVC.memberName = memberName
        self.navigationController?.pushViewController(medicalHistorySecondVC, animated: true)
        
    }
    
    func populateMemberProfileInfo() {
        let height = (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "height")as! String
        var heightSepratedbyTwoPart = height.components(separatedBy: "_")
        txtHeightInFeet.text = heightSepratedbyTwoPart[0]
        txtHeightInInch.text = heightSepratedbyTwoPart [1]
        txtWeight.text = (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "weight")as? String
       // txtWaistSize.text = arrMemberProfileInfoDetails.objectAtIndex(0).valueForKey("waist")as? String
        print(((arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "blood_group")as! String))
        
        if ((arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "blood_group")as! String) != "" {
            let buttonTag  = arrBloodGroup.index(of: (arrMemberProfileInfoDetails.object(at: 0) as AnyObject).value(forKey: "blood_group")as! String)
            let selectedButton = self.view.viewWithTag(buttonTag! + 301) as? UIButton
            selectedButton?.backgroundColor = UIColor.red
            
        }
        
    }
    
    
    //    func getAllResponse(allResponse: AnyObject, methodName: String) {
    //
    //        //   print(allResponse)
    //        //    print(methodName)
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
    //            // do your background code here
    //            dispatch_sync(dispatch_get_main_queue(), {
    //                self.activityIndicator?.stop()
    //
    //                if (allResponse .isEqual("error") || allResponse.isEqual("Something went wrong. Please try again.") || allResponse.isEqual("0") ) {
    //                    
    //                    self.presentViewController(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
    //                }else{
    //                    // getMemberProfileInfo result
    //                    if(methodName == "SaveProfilePage4"){
    //                        if (allResponse as! String == "1"){
    //                            self.popToBackViewController()
    //                        }else{
    //                            
    //                        }
    //                    }else if (methodName == "SaveCorporateCustomer_V1"){
    //                        
    //                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "iscorporate")
    //                        self.appdelegate.loadMainview()
    //                    }
    //                    else{
    //                        if  allResponse is String {
    //                            
    //                        }else{
    //                            self.arrMemberProfileInfoDetails = allResponse as! NSMutableArray
    //                            self.populateMemberProfileInfo()
    //                        }
    //                    }
    //                }
    //                
    //            });
    //        });
    //        
    //    }
    
}
