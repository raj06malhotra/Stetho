//
//  MyFamilyMemberInfoViewController.swift
//  Health
//
//  Created by HW-Anil on 7/19/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit
import MobileCoreServices

class MyFamilyMemberInfoViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UIGestureRecognizerDelegate ,serverTaskComplete , UIImagePickerControllerDelegate , UINavigationControllerDelegate , UIPickerViewDelegate , UIPickerViewDataSource{
    //MARK: VariableDeclaration
//    var maleImageView: UIImageView = UIImageView()
//    var femaleImageView: UIImageView = UIImageView()
    var btnMale: UIButton = UIButton()
    var btnFemale: UIButton = UIButton()
    var familyMemberDetails : MyFamilyInfo = MyFamilyInfo()
    var txtName : UITextField = UITextField()
    var txtDateOfBirth : UITextField = UITextField()
    var txtMobileNo : UITextField = UITextField()
    var txtEmail : UITextField = UITextField()
    var txtRelation : UITextField = UITextField()
    var tableView : UITableView = UITableView()
    var inviteTableView : UITableView = UITableView()
    var arrRelationCategory:[String] = []
    var arrTextPlaceHolder = NSArray()
    var shadowBackGround : UIView = UIView()
    var selectedGender: String = ""
    var progressView = MBProgressHUD()
    var arrExistingUser = NSMutableArray()
    var arrExistigUserDetails = NSMutableArray()
    var userImageView = UIImageView()
    var imagePicker = UIImagePickerController()
    let  arrAvatarImage = ["avatar1","avatar2","avatar3","avatar4","avatar5","avatar6"]
    var btnUpdate = UIButton()
    var member_id = ""
    var member_Name = ""
    var dictContactDetails = NSMutableDictionary()
    let datePickerView  : UIDatePicker = UIDatePicker()
    let relationPickerView : UIPickerView = UIPickerView()
    
    //MARK: - ViewLifeCycleMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        arrRelationCategory = ["Spouse" , "Father", "Mother" , "Sibling","Child","Others","You"]
        
        arrTextPlaceHolder = ["Full Name","Date of Birth","Mobile Number","Email","Select Relation"]
        self.createALayout()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        //set navigation setup
        self.navigationController?.navigationBar.topItem?.title = "Back"
        self.title = "MEMBER INFO"
        self.navigationController!.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("MyFamily_Add_Edit Screen")

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - CreateALayout
    func createALayout()  {
        var yPos = CGFloat()
        
        yPos = 20
//        TPKeyboardAvoidingScrollView(f)
        let scrollView = TPKeyboardAvoidingScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 40))
        self.view.addSubview(scrollView)
        
        let imageSize = self.view.frame.height/6 // for daynamic height & width
        
         userImageView = BaseUIController().AImageViewFrame(CGRect(x: (self.view.frame.width/2 - imageSize/2), y:yPos , width: imageSize ,height: imageSize), withImageName: "avatar1.png")as! UIImageView
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        userImageView.isUserInteractionEnabled = true
        userImageView.layer.borderColor = KRED_COLOR.cgColor
        scrollView.addSubview(userImageView)
        
        let tappedOnImage = UITapGestureRecognizer.init(target: self, action: #selector(MyFamilyMemberInfoViewController.tappedOnUserImageView(_:)))
        userImageView.addGestureRecognizer(tappedOnImage)
        
        
        yPos += imageSize + 20
        
        for i in 0..<5 {
            let textField = BaseUIController().ATextFiedlFrame(CGRect(x: 15, y: yPos, width:self.view.frame.width - 30 , height: 40 ), withPlaceHolder:arrTextPlaceHolder.object(at: i) as! String)as! UITextField
            textField.tag = 100 + i
            textField.delegate = self
            textField.font = KROBOTO_Regular_17
            textField.textAlignment = .left
           textField.borderStyle = .none
            textField.textColor = UIColor.darkGray
            scrollView.addSubview(textField)
            print(i)
            let lblLine = UILabel.init(frame: CGRect(x: 15, y: textField.frame.origin.y + 37, width: self.view.frame.width - 30, height: 1))
            lblLine.backgroundColor = KRED_COLOR
            lblLine.textColor = UIColor.clear
                scrollView.addSubview(lblLine)
            
            
            
            yPos += 40 + 20
            
        }
        
        let lblGender:UILabel = BaseUIController().ALabelFrame(CGRect(x: 15 , y: yPos, width: 100, height: 21), withString: "Gender :")as! UILabel
        lblGender.font = KROBOTO_Regular_17
        lblGender.textColor = UIColor.darkGray
        scrollView.addSubview(lblGender)
        yPos += 40
        
        btnMale = BaseUIController().AButtonFrame(CGRect (x: (self.view.frame.width - 150)/2
            , y: yPos, width: 60, height: 60), withButtonTital: "")as! UIButton
        btnMale.addTarget(self, action: #selector(self.btnMaleOnClick(_:)), for: .touchUpInside)
        btnMale.setImage(#imageLiteral(resourceName: "male_selected"), for: .normal)
        scrollView.addSubview(btnMale)
        btnMale.isSelected = true
        selectedGender = "M"
    
        btnFemale = BaseUIController().AButtonFrame(CGRect (x: btnMale.frame.origin.x+90 , y: yPos, width: 60, height: 60), withButtonTital: "Female")as! UIButton
        btnFemale.setImage(#imageLiteral(resourceName: "female_nonselected"), for: .normal)
        btnFemale.titleLabel?.font = UIFont().mediumFont
        btnFemale.addTarget(self, action: #selector(self.btnFeMaleOnClick(_:)), for: .touchUpInside)
        scrollView.addSubview(btnFemale)
        yPos += 30 + 20 ;
        
        btnUpdate = BaseUIController().AButtonFrame(CGRect(x: 0 , y: self.view.frame.height - 40 ,width: self.view.frame.width , height: 40), withButtonTital: "ADD MEMBER")as! UIButton
        btnUpdate.backgroundColor = KRED_COLOR
        btnUpdate.titleLabel?.font = KROBOTO_Light_18
        btnUpdate.setTitleColor(UIColor.white, for: UIControlState())
        btnUpdate.addTarget(self, action: #selector(MyFamilyMemberInfoViewController.btnUpdateOnClick), for: .touchUpInside)
        self.view.addSubview(btnUpdate)
        
        scrollView.contentSize = CGSize(width: self.view.frame.width , height: yPos + 55 )
        
        // set tag of TextField 
        
        txtName = scrollView.viewWithTag(100) as! UITextField
        txtDateOfBirth = scrollView.viewWithTag(101) as! UITextField
        txtMobileNo = scrollView.viewWithTag(102) as! UITextField
        txtEmail = scrollView.viewWithTag(103) as! UITextField
        txtRelation = scrollView.viewWithTag(104) as! UITextField
        txtName.autocapitalizationType = .allCharacters
        print(familyMemberDetails.memberId)
        print(familyMemberDetails.memberActiveStatus)

        
        if familyMemberDetails.memberId != "" {
            
            txtName.text = familyMemberDetails.memberName
            txtMobileNo.text = familyMemberDetails.memberMobileNo
            txtDateOfBirth.text = familyMemberDetails.memberDOB
            txtEmail.text = familyMemberDetails.memberEmail
            txtRelation.text = familyMemberDetails.memberRelation
            
            let loginId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            
            if familyMemberDetails.memberId == loginId   && familyMemberDetails.memberRelation == "You" {
                txtMobileNo.isUserInteractionEnabled = false
                txtMobileNo.textColor = KDISABLE_TEXTCOLOR
                txtRelation.isUserInteractionEnabled = false
                txtRelation.textColor = KDISABLE_TEXTCOLOR
            }else if(familyMemberDetails.memberActiveStatus == "1"){
                txtName.isUserInteractionEnabled = false
                txtDateOfBirth.isUserInteractionEnabled = false
                txtMobileNo.isUserInteractionEnabled = false
                txtEmail.isUserInteractionEnabled = false
                txtRelation.isUserInteractionEnabled = false
                btnMale.isUserInteractionEnabled = false
                btnFemale.isUserInteractionEnabled = false
                txtName.textColor = KDISABLE_TEXTCOLOR
                txtDateOfBirth.textColor = KDISABLE_TEXTCOLOR
                txtMobileNo.textColor = KDISABLE_TEXTCOLOR
                txtEmail.textColor = KDISABLE_TEXTCOLOR
                txtRelation.textColor = KDISABLE_TEXTCOLOR

            }
            
            // set male or female
            if familyMemberDetails.memberGender == "F" {
                btnFemale.setImage(#imageLiteral(resourceName: "female_selected"), for: .normal)
                btnFemale.isSelected = true
                selectedGender = "F"
                btnMale.setImage(#imageLiteral(resourceName: "male_nonselected"), for: .normal)
            }else{
                
                btnMale.setImage(#imageLiteral(resourceName: "male_selected"), for: .normal)
                btnMale.isSelected = true
                selectedGender = "M"
                btnFemale.setImage(#imageLiteral(resourceName: "female_nonselected"), for: .normal)
            }
            
            let imageString = familyMemberDetails.memberPhoto
            let data = Data(base64Encoded: imageString, options: NSData.Base64DecodingOptions(rawValue: 0))
            if imageString != "" {
                userImageView.image = UIImage.init(data: data!)
            }else{
                userImageView.image = UIImage(named: "avatar1.png")
            }
            btnUpdate.setTitle("UPDATE INFO", for: UIControlState())
        }else if((dictContactDetails.value(forKey: "phoneNumber")) != nil){
            txtName.text = dictContactDetails.value(forKey: "fullName")as? String
            txtEmail.text = dictContactDetails.value(forKey: "email")as? String
            txtMobileNo.text = dictContactDetails.value(forKey: "phoneNumber")as? String
            userImageView.image = dictContactDetails.value(forKey: "profileImage")as? UIImage
            
        }
        txtEmail.keyboardType = .emailAddress
        txtMobileNo.keyboardType = .numberPad
        OpenDatePicker(txtDateOfBirth)
        addToolBar(txtDateOfBirth)
        addToolBar(txtMobileNo)
        relationPickerView.delegate = self
        relationPickerView.dataSource = self
        txtRelation.inputView = relationPickerView
        addToolBar(txtRelation)
        
    }
    
    func openRelationPopup() {
//        shadowBackGround = UIView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height))
//        shadowBackGround.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        self.view.addSubview(shadowBackGround)
//        // create A tableView
//        tableView = UITableView(frame:CGRect(x: 10, y: ((UIScreen.main.bounds.height/2)-(120)),width: (UIScreen.main.bounds.width-20), height: 240))
//        tableView.delegate      =   self
//        tableView.dataSource    =   self
//        tableView.separatorStyle = .none
//        tableView.isScrollEnabled = false
//        tableView.layer.cornerRadius = 4.0
//        tableView.tag = 501
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        tableView.backgroundColor = UIColor.clear
//        shadowBackGround.addSubview(self.tableView)
//        // add Tapgestue  on shadowBackGround
//        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyFamilyMemberInfoViewController.tappedOnShadowBG(_:)))
//        tapped.numberOfTapsRequired = 1
//        tapped.delegate = self
//        shadowBackGround.addGestureRecognizer(tapped)
    }
    func openInvitePopup() {
        shadowBackGround = UIView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height))
        shadowBackGround.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(shadowBackGround)
        // create A tableView
        let bgView = UIView(frame:CGRect(x: 10, y: ((UIScreen.main.bounds.height/2)-(60)),width: (UIScreen.main.bounds.width-20), height: 120))
        bgView.backgroundColor = UIColor.white
        bgView.layer.cornerRadius = 4.0
        shadowBackGround.addSubview(bgView)
        
        inviteTableView = UITableView(frame:CGRect(x: 0, y: 0,width: bgView.bounds.width, height: 90))
        inviteTableView.delegate      =   self
        inviteTableView.dataSource    =   self
        inviteTableView.separatorStyle = .none
       // inviteTableView.scrollEnabled = false
        inviteTableView.layer.cornerRadius = 4.0
        inviteTableView.tag = 501
        inviteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        inviteTableView.backgroundColor = UIColor.clear
        bgView.addSubview(inviteTableView)
        // if getting more then 3 member then increaase height of view
        if arrExistingUser.count >= 3 {
            bgView.frame = CGRect(x: 10, y: ((UIScreen.main.bounds.height/2)-(150)), width: (UIScreen.main.bounds.width-20), height: 300)
            inviteTableView.frame = CGRect(x: 0, y: 0, width: bgView.bounds.width, height: 270)
            
        }
        let btnSkip = BaseUIController().AButtonFrame(CGRect(x:bgView.frame.width - 60  , y:bgView.frame.height - 30 ,width:60  ,height: 25 ), withButtonTital: "Skip")as! UIButton
        btnSkip.titleLabel?.font = KROBOTO_BOLD_12
        btnSkip.addTarget(self, action: #selector(MyFamilyMemberInfoViewController.btnSkipOnClick), for: .touchUpInside)
        bgView.addSubview(btnSkip)
        // add Tapgestue  on shadowBackGround
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyFamilyMemberInfoViewController.tappedOnShadowBG(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        shadowBackGround.addGestureRecognizer(tapped)
    }
    
    func OpenChangeImagePopUp()   {
        
        let alertSheet = GlobalInfo.sharedInfo.getPhotoSelectionAlertSheet()
        
        alertSheet.addAction(UIAlertAction(title: KTAKEPHOTO, style: .default, handler: { (alert: UIAlertAction!) in
            self.btnTakephotoOnClick()
        }))
        
        alertSheet.addAction(UIAlertAction(title: KPHOTO_GALLERY, style: .default, handler: { (alert: UIAlertAction!) in
            self.btnChooseFromGalleryOnClick()
        }))
        alertSheet.addAction(UIAlertAction(title: KPHOTO_AVATAR, style: .default, handler: { (alert: UIAlertAction!) in
            self.btnChooseAvatarOnClick()
        }))
        alertSheet.addAction(UIAlertAction(title: KCANCEL, style: .cancel, handler: { (alert: UIAlertAction!) in
            alertSheet.dismiss(animated: true, completion: nil)
        }))
        present(alertSheet, animated: true, completion: nil)
    }
    
    func openAvatarPopup()  {
        
       /* shadowBackGround = UIView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height))
        shadowBackGround.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(shadowBackGround)
        var xPos:CGFloat = 10
        var yPos:CGFloat = 10
        
        let popUpView = UIView(frame: CGRect(x: 20, y: self.view.center.y - 75 ,width: self.view.frame.width-40 ,height: 150))
        popUpView.layer.cornerRadius = 4
        popUpView.backgroundColor = UIColor.white
        shadowBackGround .addSubview(popUpView)
        xPos = (popUpView.frame.width - 180)/4 // set gap between all avtar images
        for i in 0..<6 {
         let   btnAvatarImage = BaseUIController().AButtonFrame(CGRect(x: xPos , y: yPos , width: 60 , height: 60), withButtonTital: "")as! UIButton
            btnAvatarImage.setImage((UIImage(named:arrAvatarImage[i] as! String)), for: UIControlState())
            btnAvatarImage.layer.masksToBounds = true
            btnAvatarImage.layer.cornerRadius = btnAvatarImage.frame.width/2
            btnAvatarImage.tag = 500 + i
            popUpView.addSubview(btnAvatarImage)
            
            xPos += 60 + (popUpView.frame.width - 180)/4
            
            if i == 2 {
                yPos += 60 + 10
               xPos = (popUpView.frame.width - 180)/4
            }
            btnAvatarImage.addTarget(self, action: #selector(MyFamilyMemberInfoViewController.btnAvatarImageOnClick(_:)), for: .touchUpInside)
            
        }
        
        // add Tapgestue  on shadowBackGround
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyFamilyMemberInfoViewController.tappedOnShadowBG(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        shadowBackGround.addGestureRecognizer(tapped) */
        
        
        var xPos:CGFloat = 10
        var yPos:CGFloat = 10
        let controller = UIAlertController(title: "\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        controller.view.tintColor = KRED_COLOR
        
        let popUpView = UIView(frame: CGRect(x: 0, y: 0 ,width: controller.view.bounds.size.width-20 ,height: 160))
        
        popUpView.layer.cornerRadius = 4
        popUpView.backgroundColor = UIColor.white
        shadowBackGround .addSubview(popUpView)
        xPos = (popUpView.frame.width - 180)/4 // set gap between all avtar images
        for i in 0..<6 {
            let   btnAvatarImage = BaseUIController().AButtonFrame(CGRect(x: xPos , y: yPos , width: 60 , height: 60), withButtonTital: "")as! UIButton
            btnAvatarImage.setImage((UIImage(named:arrAvatarImage[i] )), for: UIControlState())
            btnAvatarImage.layer.masksToBounds = true
            btnAvatarImage.layer.cornerRadius = btnAvatarImage.frame.width/2
            btnAvatarImage.tag = 500 + i
            popUpView.addSubview(btnAvatarImage)
            
            xPos += 60 + (popUpView.frame.width - 180)/4
            
            if i == 2 {
                yPos += 60 + 10
                xPos = (popUpView.frame.width - 180)/4
            }
            btnAvatarImage.addTarget(self, action: #selector(self.btnAvatarImageOnClick(_:)), for: .touchUpInside)
            
        }
        controller.view.addSubview(popUpView)
        controller.view.bringSubview(toFront: popUpView)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in controller.dismiss(animated: true, completion: nil)})
        controller.addAction(cancelAction)
        
        
        self.present(controller, animated: true, completion: nil)
        
    }
    
    //MARK: - TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
       
            return arrExistingUser.count
            
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.textLabel!.font = KROBOTO_Light_17
        cell.textLabel?.textColor = UIColor (red: (55.0/255.0), green: (54/255.0), blue: (54.0/255.0), alpha: 1)
        cell.textLabel?.text = (arrExistingUser[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "name")as? String
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
            self.getUserInfo((arrExistingUser[(indexPath as NSIndexPath).row] as AnyObject).value(forKey: "ca_id")as! String)
        shadowBackGround.isHidden = true
        shadowBackGround.removeFromSuperview()
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 30;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  30;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        headerView.backgroundColor = UIColor.white
        
         let lblSelectRelation = BaseUIController().ALabelFrame(CGRect(x: 10 ,y:5 ,width: tableView.frame.width , height: 20), withString: "Invite Existing Member.") as! UILabel
        lblSelectRelation.font = KROBOTO_BOLD_12
        headerView.addSubview(lblSelectRelation)
        return headerView
    }
    //MARK: PickerViewDelegate
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return arrRelationCategory.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
            return arrRelationCategory[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        txtRelation.text = arrRelationCategory[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        pickerLabel.text = arrRelationCategory[row]
        pickerLabel.font = KROBOTO_Regular_17
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
            return 40;
        
    }

    //MARK: - GestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
       
        print(touch.view)
        //UITableViewCellContentView
        if (touch.view == shadowBackGround ){
          
            return true
        }
        else{
          
            return false
        }
    }

    //MARK: TextFieldDelegate
     func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        return textField .resignFirstResponder()
    }
    func textFieldDidBeginEditing(_ textField: UITextField){
        
        if textField == txtRelation {
//            textField .resignFirstResponder()
//            self.openRelationPopup()
           
            
        }
        
    }
    func textFieldDidEndEditing(_ textField: UITextField){
        textField .resignFirstResponder()
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        if textField == txtMobileNo {
            let maxLength = 10
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if familyMemberDetails.memberId == "" &&  newString.length == 10{
                print("10 digit completed")
                print(newString)
                self.checkExitingMember(newString as String)
            }
            return newString.length <= maxLength
        }else{
            let maxLength = 50
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        
    }
    //MARK: - ImagePickerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
                userImageView.image = image
    }

    //MARK: - GestureActionMethod
    func tappedOnShadowBG(_ sender: UITapGestureRecognizer)  {
        

            shadowBackGround.isHidden = true
            shadowBackGround.removeFromSuperview()
    }
    func tappedOnUserImageView(_ sender: UITapGestureRecognizer)  {
       self.OpenChangeImagePopUp()
    }
    
    func btnAvatarImageOnClick(_ sender: UIButton)  {
        
        let tag = sender.tag
        print(tag)
        shadowBackGround.removeFromSuperview()
        userImageView.image = UIImage(named: arrAvatarImage[tag - 500] as! String)
        
    }
    //MARK: - btnOnclickMethod
    func btnMaleOnClick(_ button: UIButton)  {
        if btnMale.isSelected  == false {
            btnMale.setImage(#imageLiteral(resourceName: "male_selected"), for: .normal)
            btnFemale.setImage(#imageLiteral(resourceName: "female_nonselected"), for: .normal)
            btnFemale.isSelected = false
          
        }else{
            btnFemale.isSelected = false
        }
        selectedGender = "M"
     }
    func btnFeMaleOnClick(_ button: UIButton){
        if button.isSelected == false {

            btnFemale.setImage(#imageLiteral(resourceName: "female_selected"), for: .normal)
            btnMale.setImage(#imageLiteral(resourceName: "male_nonselected"), for: .normal)

            btnMale.isSelected = false
        }else{
             btnMale.isSelected = false
        }
        selectedGender = "F"
    }
    func btnUpdateOnClick()  {
        let f_Name = txtName.text?.trimmingCharacters(in: .whitespaces)
        
        
       if f_Name?.isEmpty == true {
            self.present(BaseUIController().showAlertView("Please Enter Full Name!"), animated: true, completion: nil)
        }else if(txtDateOfBirth.text?.isEmpty == true){
             self.present(BaseUIController().showAlertView("Please Enter DOB!"), animated: true, completion: nil)
        }else if (txtMobileNo.text?.isEmpty == true){
             self.present(BaseUIController().showAlertView("Please Enter Mobile Number"), animated: true, completion: nil)
            
        }else if(self.phoneNumberValidation(txtMobileNo.text!) == false){
             self.present(BaseUIController().showAlertView("Please Enter Valid Mobile Number!"), animated: true, completion: nil)
            
        }else if (txtRelation.text?.isEmpty == true){
             self.present(BaseUIController().showAlertView("Please Select Relation!"), animated: true, completion: nil)
            
        }else if (selectedGender.isEmpty == true){
            
           self.present(BaseUIController().showAlertView("Please Select Gender!"), animated: true, completion: nil)
        
        }else if(txtEmail.text?.isEmpty == false){
        //here Email is not mandatry 
            if(self.validateEmail(txtEmail.text!) == false){
                self.present(BaseUIController().showAlertView("Please Enter Valid Email!"), animated: true, completion: nil)
            }else{
                print("update value  ")
                
                if  btnUpdate.titleLabel?.text == "UPDATE INFO"{
                    self.updateFamilyMemberData()
                    print(familyMemberDetails.memberId)
                    member_id = familyMemberDetails.memberId
                    member_Name = familyMemberDetails.memberName
                    self.sendToNextViewController()
                }else{
                   self.addNewMember()
                }
            }
        }else{
            if  btnUpdate.titleLabel?.text == "UPDATE INFO"{
                 self.updateFamilyMemberData()
                print(familyMemberDetails.memberId)
                member_id = familyMemberDetails.memberId
                member_Name = familyMemberDetails.memberName
                self.sendToNextViewController()
            }else{
                self.addNewMember()
            }
        }
    }
    func btnSkipOnClick()  {
        
        shadowBackGround.removeFromSuperview()
        
    }
    func btnTakephotoOnClick()  {
        shadowBackGround.removeFromSuperview()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    
    }
    func btnChooseFromGalleryOnClick()  {
        shadowBackGround.removeFromSuperview()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func btnChooseAvatarOnClick()  {
        shadowBackGround.removeFromSuperview()
        self.openAvatarPopup()
        
        
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
        txtDateOfBirth.text = dateFormatter.string(from: sender.date)
        print(dateFormatter.string(from: sender.date))
    }
    //MARK: - validate PhoneNumber
    func phoneNumberValidation(_ value: String) -> Bool {
        let mobileNumberPattern: String = "[789][0-9]{9}"
        let mobileNumberPred: NSPredicate = NSPredicate(format: "SELF MATCHES %@", mobileNumberPattern)
        let matched: Bool = mobileNumberPred.evaluate(with: value)
        return matched
    }
    func validateEmail(_ enteredEmail:String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
        
    }
    //MARK: - UpdateDatabase
    func updateFamilyMemberData() {
        let reSizeImage = self.resizeImage(userImageView.image!, targetSize: CGSize(width: 200.0, height: 200.0))
            let imageData = UIImagePNGRepresentation(reSizeImage)
            let base64String = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
           // print(strBase64)
           // let finalImageString = strBase64.stringByReplacingOccurrencesOfString("\r", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
             print(base64String)
        
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let database = appDelegate.openDataBase()
            do {
                try database.executeUpdate(String(format:"update MyFamily set MemberName = '%@', Relation = '%@',MemberPhoto ='%@', MemberEmail = '%@', MemberGender = '%@',MemberMobileNo = '%@',MemberDOB= '%@',SyncStatus = 'N'  where MemberId = '%@'",txtName.text!,txtRelation.text!,base64String,txtEmail.text!,selectedGender,txtMobileNo.text!,txtDateOfBirth.text!,familyMemberDetails.memberId), values: nil)
                
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            database.close()
        
        //sync data on server
        // HomeViewController().getNonSyncDataFromMyFamilyTable()
        SyncMyFamilyData.shareMyFamilyData.getNonSyncDataFromMyFamilyTable()
        // reload Drawer Data 
         NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
        
        // create the alert
//        let alert = UIAlertController(title: "Alert", message: "Member Information update Successfully !", preferredStyle: UIAlertControllerStyle.Alert)
//        self.presentViewController(alert, animated: true, completion: nil)
//        
//        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
//            switch action.style{
//            case .Default:
//                print("default")
//                self.navigationController?.popViewControllerAnimated(true)
//                
//            case .Cancel:
//                print("cancel")
//                
//            case .Destructive:
//                print("destructive")
//            }
//        }))
        
        }
    func addNewMemberInDataBase(_ m_id : String)  {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        do {
            let reSizeImage = self.resizeImage(userImageView.image!, targetSize: CGSize(width: 200.0, height: 200.0))
            let imageData = UIImagePNGRepresentation(reSizeImage)
            let base64String = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let MemberName = txtName.text!
            let relation = txtRelation.text!
            let memberPhoto = base64String
            let active = ""
            let dob = txtDateOfBirth.text!
            let email = txtEmail.text!
            let mobileNo = txtMobileNo.text!
            let gender = selectedGender
            try database.executeUpdate("insert into MyFamily (MemberId , MemberName , Relation , MemberPhoto ,MemberEmail,MemberGender,MemberMobileNo, MemberDOB,SyncStatus,Verified,Active) values (?,?,?,?,?,?,?,?,?,?,?)", values: [m_id , MemberName , relation,memberPhoto,email,gender,mobileNo,dob,"Y","0",active])
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
        
    }
    //MARK: - callWebServices
    
    func checkExitingMember(_ mobileNo : String)  {
        
        if Reachability.isConnectedToNetwork() == true {
            progressView = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressView.show(animated: true)
            progressView.mode = MBProgressHUDMode.indeterminate
            progressView.label.text = "Check Eisting Memeber"
            
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let allParameters = ["mobile":mobileNo, "customerId":customerId]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "CheckForExistingMembersResult" ,methodname: "CheckForExistingMembers", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    
    func getUserInfo(_ memberid : String)  {
        
        if Reachability.isConnectedToNetwork() == true {
            progressView = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressView.show(animated: true)
            let allParameters = ["memberId":memberid, "customerId":"0"]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetMemberInfoResult" ,methodname: "GetMemberInfo", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    
    func addNewMember()  {
        if Reachability.isConnectedToNetwork() == true {
            progressView = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressView.show(animated: true)
            //get image data in base64 string
            let reSizeImage = self.resizeImage(userImageView.image!, targetSize: CGSize(width: 200.0, height: 200.0))
            let imageData = UIImagePNGRepresentation(reSizeImage)
            let base64String = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let allParameters = ["customerId":customerId , "fullName" : txtName.text! ,"dob": txtDateOfBirth.text! ,"mobileNo": txtMobileNo.text! ,"email":txtEmail.text! , "gender":selectedGender ,"relation": txtRelation.text! ,"photo": base64String]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "AddNewMemberResult" ,methodname: "AddNewMember", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String)
    {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.progressView.hide(animated: true)
                self.txtMobileNo.resignFirstResponder()
                if(allResponse .isEqual("error")){
                   self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }
                else
                {
                if methodName == "GetMemberInfo" {
                    if allResponse is String{
                        self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                    }else{
                        self.arrExistigUserDetails = NSMutableArray()
                        self.arrExistigUserDetails = allResponse as! NSMutableArray
                        self.setUserInfoDetails()
                    }
                } else if methodName == "CheckForExistingMembers"{
                if  allResponse is String {
                   
                }else{
                  self.arrExistingUser = NSMutableArray()
                    self.arrExistingUser = allResponse as! NSMutableArray
                    self.openInvitePopup()
                    }
                }else if methodName == "AddNewMember"{
                    let resultString = allResponse as! String
        
                    if  resultString == "0"{
                        
            
                    }else{
                        self.member_id = allResponse as! String
                        self.addNewMemberInDataBase(self.member_id)
                        self.sendToNextViewController()
                    }
                }
                }
            });
        });
    }
    func setUserInfoDetails()  {
        
        let imageString = (arrExistigUserDetails[0] as AnyObject).value(forKey: "photo")as? String
        let data = Data(base64Encoded: imageString!, options: NSData.Base64DecodingOptions(rawValue: 0))
        if imageString != "" {
            userImageView.image = UIImage.init(data: data!)
        }else{
            userImageView.image = UIImage(named: "avatar1.png")
        }
        txtName.text = (arrExistigUserDetails[0] as AnyObject).value(forKey: "fullname")as? String
        let dateString = (arrExistigUserDetails[0] as AnyObject).value(forKey: "dob")as? String
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let date = df.date(from: dateString!)
        if let unwrappedDate = date {
            datePickerView.setDate(unwrappedDate, animated: false)
        }
        txtDateOfBirth.text = (arrExistigUserDetails[0] as AnyObject).value(forKey: "dob")as? String
        txtEmail.text = (arrExistigUserDetails[0] as AnyObject).value(forKey: "email")as? String
       // txtRelation.text = arrExistigUserDetails[0].valueForKey("relation")as? String
        // set male or female
        if (arrExistigUserDetails[0] as AnyObject).value(forKey: "gender")as? String == "F" {
          //  femaleImageView.image = UIImage(named: "selectedradio_icon")
            btnFemale.setImage(UIImage(named: "selectedradio_icon"), for: .normal)
            btnFemale.isSelected = true
            selectedGender = "F"
         
            btnMale.setImage(#imageLiteral(resourceName: "male_nonselected"), for: .normal)
        }else{
           // maleImageView.image = UIImage(named: "selectedradio_icon")
            btnMale.setImage(UIImage(named:"selectedradio_icon"), for: .normal)
            btnMale.isSelected = true
            selectedGender = "M"
            btnFemale.setImage(#imageLiteral(resourceName: "female_nonselected"), for: .normal)
        }
        txtName.isUserInteractionEnabled = false
        txtDateOfBirth.isUserInteractionEnabled = false
        txtEmail.isUserInteractionEnabled = false
        txtEmail.textColor = KDISABLE_TEXTCOLOR
        txtName.textColor = KDISABLE_TEXTCOLOR
        txtDateOfBirth.textColor = KDISABLE_TEXTCOLOR
    }
    
    //MARK: - ImageResizing
    
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
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
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func sendToNextViewController()  {
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        let medicalHistoryFirstVC = storyboard1.instantiateViewController(withIdentifier: "MedicalHistoryFirstViewController")as! MedicalHistoryFirstViewController
        medicalHistoryFirstVC.memberId = member_id
        let firstName: String = member_Name.components(separatedBy: " ").first!.capitalized as String
        let loginUserid =  UserDefaults.standard.value(forKey: "loginCustomerId")as! String
        if loginUserid != member_id {
            medicalHistoryFirstVC.memberName = firstName
        }
        
        self.navigationController?.pushViewController(medicalHistoryFirstVC, animated: true)
    }
    
}

//MARK: UNUSED CODE

//        shadowBackGround = UIView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height))
//        shadowBackGround.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        self.view.addSubview(shadowBackGround)
//        let xPos:CGFloat = 10
//        var yPos:CGFloat = 5
//
//
//
//        let popUpView = UIView(frame: CGRect(x: 20, y: (self.view.frame.height/2) - 70 ,width: self.view.frame.width-40 ,height: 130))
//        popUpView.layer.cornerRadius = 4
//        popUpView.backgroundColor = UIColor.white
//        shadowBackGround .addSubview(popUpView)
//
//        let lblChangePhoto = BaseUIController().ALabelFrame(CGRect(x: xPos ,y: yPos , width: 200 , height: 21), withString: "Change Photo")as! UILabel
//        lblChangePhoto.font = UIFont().largeFont
//        popUpView.addSubview(lblChangePhoto)
//
//        yPos += 21 + 5
//
//        let btnTakePhoto = BaseUIController().AButtonFrame(CGRect(x: xPos, y: yPos, width: self.view.frame.width-20, height: 25 ), withButtonTital: "Take Photo")as! UIButton
//        btnTakePhoto.addTarget(self, action: #selector(MyFamilyMemberInfoViewController.btnTakephotoOnClick), for: .touchUpInside)
//        btnTakePhoto.titleLabel?.font = UIFont().mediumFont
//        btnTakePhoto.contentHorizontalAlignment = .left
//        popUpView.addSubview(btnTakePhoto)
//
//        yPos += 25 + 5
//
//        let btnChooseFormGallery = BaseUIController().AButtonFrame(CGRect(x: xPos, y: yPos, width: self.view.frame.width-20, height: 25 ), withButtonTital: "Choose from Gallery") as! UIButton
//        btnChooseFormGallery.addTarget(self, action: #selector(MyFamilyMemberInfoViewController.btnChooseFromGalleryOnClick), for: .touchUpInside)
//        btnChooseFormGallery.titleLabel!.font = UIFont().mediumFont
//        btnChooseFormGallery.contentHorizontalAlignment = .left
//        popUpView.addSubview(btnChooseFormGallery)
//
//        yPos += 25 + 5
//
//        let btnChoseAvatar = BaseUIController().AButtonFrame(CGRect(x: xPos, y: yPos, width: self.view.frame.width-20, height: 25 ), withButtonTital: "Choose Avatar") as! UIButton
//        btnChoseAvatar.addTarget(self, action: #selector(MyFamilyMemberInfoViewController.btnChooseAvatarOnClick), for: .touchUpInside)
//        btnChoseAvatar.titleLabel!.font = UIFont().mediumFont
//        btnChoseAvatar.contentHorizontalAlignment = .left
//        popUpView.addSubview(btnChoseAvatar)
//
//        // add Tapgestue  on shadowBackGround
//        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyFamilyMemberInfoViewController.tappedOnShadowBG(_:)))
//        tapped.numberOfTapsRequired = 1
//        tapped.delegate = self
//        shadowBackGround.addGestureRecognizer(tapped)
