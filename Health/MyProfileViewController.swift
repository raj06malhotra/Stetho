//
//  MyProfileViewController.swift
//  Stetho
//
//  Created by HW-Anil on 9/24/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit
import MobileCoreServices
class MyProfileViewController: UIViewController ,UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    @IBOutlet weak var lblLine5: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtMobileNo: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var btnUpdateInfo: UIButton!
    @IBOutlet weak var maleImageView: UIImageView!
    @IBOutlet weak var femaleImageView: UIImageView!
    var shadowBackGround = UIView()
    var arrAvatarImage = ["avatar1","avatar2","avatar3","avatar4","avatar5","avatar6"]
    var imagePicker = UIImagePickerController()
    var selectedGender: String = ""
    var myFamilyObject: MyFamilyInfo = MyFamilyInfo()
    let datePickerView  : UIDatePicker = UIDatePicker()
    
    //MARK: viewLifeCycleDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        mainView.layer.cornerRadius = 4
        mainView.layer.borderWidth = 1
        mainView.backgroundColor = UIColor.init(red: (236.0/255.0), green: (236.0/255.0), blue: (236.0/255.0), alpha: 1)
    
        mainView.layer.borderColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1).cgColor
        
        txtEmail.keyboardType = .emailAddress
        txtMobileNo.keyboardType = .numberPad
        OpenDatePicker(txtDOB)
        addToolBar(txtDOB)
        addToolBar(txtMobileNo)

        self.loadMyProfile()
        self.populateProfileInfo()
        //key board hide & show
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        txtFirstName.autocapitalizationType = .allCharacters
        txtLastName.autocapitalizationType = .allCharacters
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //set tital 
       // self.title = "My Profile"
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("MyProfile Screen")

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillLayoutSubviews() {
        
        if (UIScreen.main.bounds.height == 480) {
            mainView.frame = CGRect(x: mainView.frame.origin.x, y: mainView.frame.origin.y, width: mainView.frame.width, height: 350)
            scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 100)
        }else if(UIScreen.main.bounds.height == 568){
            mainView.frame = CGRect(x: mainView.frame.origin.x, y: mainView.frame.origin.y, width: mainView.frame.width, height: 350)
        }else if(UIScreen.main.bounds.height == 736){
            lblLine5.frame = CGRect(x: lblLine5.frame.origin.x, y: txtDOB.frame.origin.y + 36, width: lblLine5.frame.width, height: 1)
            btnUpdateInfo.frame = CGRect(x: btnUpdateInfo.frame.origin.x, y: mainView.frame.origin.y + mainView.frame.height + 50, width: btnUpdateInfo.frame.width, height: btnUpdateInfo.frame.height)

        }
    }
    // MARK: createALayoutDesign
    
    func populateProfileInfo()  {
       let member_name = myFamilyObject.memberName
        
        
        var l_Name: String = ""
        let fullNameArr = member_name.characters.split{$0 == " "}.map(String.init)
        let f_Name: String = fullNameArr[0]
        if fullNameArr.count > 1 {
          l_Name = fullNameArr[1]
        }
        
        txtFirstName.text = f_Name
        txtLastName.text = l_Name
        txtEmail.text = myFamilyObject.memberEmail
        txtMobileNo.text = myFamilyObject.memberMobileNo
        txtMobileNo.isUserInteractionEnabled = false
        let dateString = myFamilyObject.memberDOB
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let date = df.date(from: dateString)
        if let unwrappedDate = date {
            datePickerView.setDate(unwrappedDate, animated: false)
        }
        txtDOB.text = myFamilyObject.memberDOB
        let imageString = myFamilyObject.memberPhoto
        let data = Data(base64Encoded: imageString, options: NSData.Base64DecodingOptions(rawValue: 0))
        if imageString != "" {
            userImageView.image = UIImage.init(data: data!)
        }else{
            userImageView.image = UIImage(named: "avatar1.png")
        }
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        userImageView.layer.masksToBounds = true
        userImageView.isUserInteractionEnabled = true
        if myFamilyObject.memberGender == "M" {
            selectedGender = "M"
            maleImageView.image = UIImage(named: "selectedradio_icon.png")
            femaleImageView.image = UIImage(named: "nonselectedradio_icon.png")
        }else{
            selectedGender = "F"
            femaleImageView.image = UIImage(named: "selectedradio_icon.png")
            maleImageView.image = UIImage(named: "nonselectedradio_icon.png")
        }
        btnUpdateInfo.layer.cornerRadius = 4
    
        let tappedOnImage = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnUserImageView(_:)))
        userImageView.addGestureRecognizer(tappedOnImage)
        
        
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
        
        shadowBackGround = UIView(frame: CGRect(x: 0 , y: 0 , width: self.view.window!.frame.width , height: self.view.window!.frame.height))
        shadowBackGround.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.window!.addSubview(shadowBackGround)
        var xPos:CGFloat = 10
        var yPos:CGFloat = 10
        
        let popUpView = UIView(frame: CGRect(x: 20, y: (self.view.window?.center.y)! - 75 ,width: self.view.frame.width-40 ,height: 150))
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
    // add Tapgestue  on shadowBackGround
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnShadowBG(_:)))
        tapped.numberOfTapsRequired = 1
    //    tapped.delegate = self
        shadowBackGround.addGestureRecognizer(tapped)
        
    }

    // MARK: - TextFiedlDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == txtFirstName || textField == txtLastName) {
            if string.rangeOfCharacter(from: .whitespacesAndNewlines, options: .regularExpression) != nil{
                return false
            }
        }
        return true
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
    func tapOnUserImageView(_ sender: UITapGestureRecognizer)  {
        self.OpenChangeImagePopUp()
    }
     //MARK: buttonOnClick
    @IBAction func btnMaleOnClick(_ sender: UIButton) {
        selectedGender = "M"
        maleImageView.image = UIImage(named: "selectedradio_icon.png")
        femaleImageView.image = UIImage(named: "nonselectedradio_icon.png")
    }

    @IBAction func btnFemaleOnClick(_ sender: UIButton) {
        selectedGender = "F"
        femaleImageView.image = UIImage(named: "selectedradio_icon.png")
        maleImageView.image = UIImage(named: "nonselectedradio_icon.png")
    }
    @IBAction func btnUpdateInfo(_ sender: UIButton) {
        
        if txtFirstName.text?.isEmpty == true {
            self.present(BaseUIController().showAlertView("Please Enter Full Name!"), animated: true, completion: nil)
        }else if (selectedGender.isEmpty == true){
            
            self.present(BaseUIController().showAlertView("Please Select Gender!"), animated: true, completion: nil)
        }else if(txtDOB.text?.isEmpty == true){
            self.present(BaseUIController().showAlertView("Please Enter DOB!"), animated: true, completion: nil)
        }
        else if(txtEmail.text?.isEmpty == false){
            if(self.validateEmail(txtEmail.text!) == false)
            {
                self.present(BaseUIController().showAlertView("Please Enter Valid Email!"), animated: true, completion: nil)
            }
            else
                {
                    self.updateProfileInfo()
                }
        }
        else
            {
            self.updateProfileInfo()
            
            }
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
    func btnAvatarImageOnClick(_ sender: UIButton)  {
        let tag = sender.tag
        print(tag)
        shadowBackGround.removeFromSuperview()
        userImageView.image = UIImage(named: arrAvatarImage[tag - 500] )
    }
    
    // MARK: - DataBaseOperation
    
    func loadMyProfile()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        myFamilyObject = MyFamilyInfo()
        let memberId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
        
        
        do {
            let rs = try database.executeQuery(String(format: "select * from MyFamily where MemberId = %@",memberId ), values: nil)
            while rs.next() {
                myFamilyObject.memberId = rs.string(forColumn: "MemberId")
                myFamilyObject.memberName = rs.string(forColumn: "MemberName")
                myFamilyObject.memberRelation = rs.string(forColumn: "Relation")
                myFamilyObject.memberPhoto = rs.string(forColumn: "MemberPhoto")
                myFamilyObject.memberDOB = rs.string(forColumn: "MemberDOB")
                myFamilyObject.memberEmail = rs.string(forColumn: "MemberEmail")
                myFamilyObject.memberGender = rs.string(forColumn: "MemberGender")
                myFamilyObject.memberMobileNo = rs.string(forColumn: "MemberMobileNo")
                myFamilyObject.memberVerefyStatus = rs.string(forColumn: "Verified")
                myFamilyObject.memberActiveStatus = rs.string(forColumn: "Active")
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
    
    func updateProfileInfo() {
       
        let userName = txtFirstName.text! + String(format: " %@",txtLastName.text!)
        let memberId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
        
        let reSizeImage = DrawerViewController().resizeImage(userImageView.image!, targetSize: CGSize(width: 200.0, height: 200.0))
        let imageData = UIImagePNGRepresentation(reSizeImage)
        let base64String = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        print(base64String)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        do {
            try database.executeUpdate(String(format:"update MyFamily set MemberName = '%@',MemberPhoto ='%@', MemberEmail = '%@', MemberGender = '%@',MemberDOB= '%@',SyncStatus = 'N'  where MemberId = '%@'",userName,base64String,txtEmail.text!,selectedGender,txtDOB.text!,memberId), values: nil)
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
         self.present(BaseUIController().showAlertView("Your profile update successfully!"), animated: true, completion: nil)
       // HomeViewController().getNonSyncDataFromMyFamilyTable()
        SyncMyFamilyData.shareMyFamilyData.getNonSyncDataFromMyFamilyTable()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)        
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

    // MARK: - KeyboardShow&Hide
    func keyboardWillShow(_ notification:Notification){
        scrollView.frame = CGRect(x: 0 , y: -20 , width: self.view.frame.width , height: self.view.frame.height)
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 100)
    }
    
    func keyboardWillHide(_ notification:Notification){
        
        scrollView.frame = CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height)
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height - 100)
    }

}

//MARK: UN USE CODE

//        shadowBackGround = UIView(frame: CGRect(x: 0 , y: 0 , width: (self.view.window?.frame.width)!, height: (self.view.window?.frame.height)!))
//        shadowBackGround.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        self.view.window!.addSubview(shadowBackGround)
//        let xPos:CGFloat = 10
//        var yPos:CGFloat = 5
//
//
//
//        let popUpView = UIView(frame: CGRect(x: 20, y: (self.view.window?.center.y)! - 70 ,width: self.view.frame.width-40 ,height: 130))
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
//        btnTakePhoto.addTarget(self, action: #selector(self.btnTakephotoOnClick), for: .touchUpInside)
//        btnTakePhoto.titleLabel?.font = UIFont().mediumFont
//        btnTakePhoto.contentHorizontalAlignment = .left
//        popUpView.addSubview(btnTakePhoto)
//
//        yPos += 25 + 5
//
//        let btnChooseFormGallery = BaseUIController().AButtonFrame(CGRect(x: xPos, y: yPos, width: self.view.frame.width-20, height: 25 ), withButtonTital: "Choose from Gallery") as! UIButton
//        btnChooseFormGallery.addTarget(self, action: #selector(self.btnChooseFromGalleryOnClick), for: .touchUpInside)
//        btnChooseFormGallery.titleLabel!.font = UIFont().mediumFont
//        btnChooseFormGallery.contentHorizontalAlignment = .left
//        popUpView.addSubview(btnChooseFormGallery)
//
//        yPos += 25 + 5
//
//        let btnChoseAvatar = BaseUIController().AButtonFrame(CGRect(x: xPos, y: yPos, width: self.view.frame.width-20, height: 25 ), withButtonTital: "Choose Avatar") as! UIButton
//        btnChoseAvatar.addTarget(self, action: #selector(self.btnChooseAvatarOnClick), for: .touchUpInside)
//        btnChoseAvatar.titleLabel!.font = UIFont().mediumFont
//        btnChoseAvatar.contentHorizontalAlignment = .left
//        popUpView.addSubview(btnChoseAvatar)
//
//        // add Tapgestue  on shadowBackGround
//        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnShadowBG(_:)))
//        tapped.numberOfTapsRequired = 1
//       // tapped.delegate = self
//        shadowBackGround.addGestureRecognizer(tapped)
