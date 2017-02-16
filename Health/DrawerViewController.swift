/*
Copyright (c) 2015 Kyohei Yamaguchi. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import UIKit
import MobileCoreServices

class DrawerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , UIGestureRecognizerDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    //MARK: - VariableDeclaration
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var tableView: UITableView  =   UITableView()
    
    //UPDATE FOR NEW BARCODE FLOE
   // let itemList : [String] = ["HOME" , "MY FAMILY","MY RECORDS","MY ORDERS","MY REMINDERS","HEALTH TREANDS","NOTIFICATIONS","WALLET","SCAN BARCODE","SUBMIT A QUERY","CHAT WITH US","CALL SUPPORT"]
    let itemList : [String] = ["HOME" , "MY FAMILY","MY RECORDS","MY ORDERS","MY REMINDERS","HEALTH TRENDS","NOTIFICATIONS","WALLET",KCORP_CHECKIN,"SUBMIT A QUERY","CHAT WITH US","CALL SUPPORT"]

//    let itemListIcon: [String] = ["home_icon.png","my_family.png", "my_records_icon.png", "my_orders_icon.png", "my_reminders_icon.png","health_trend.png", "notifications_icon.png","menu_wallet.png","menu_barcode.png", "submit_query_icon.png", "chat_icon.png","call_support_icon.png"]
    
    let itemListIcon: [String] = ["home_icon.png","my_family.png", "my_records_icon.png", "my_orders_icon.png", "my_reminders_icon.png","health_trend.png", "notifications_icon.png","menu_wallet.png","menu_barcode_corporate", "submit_query_icon.png", "chat_icon.png","call_support_icon.png"]

    
    //menu_barcode_corporate
    let  arrAvatarImage = ["avatar1","avatar2","avatar3","avatar4","avatar5","avatar6"]
    var shadowBackGround = UIView()
    var userImageView = UIImageView()
    var imagePicker = UIImagePickerController()
    var myFamilyObject: MyFamilyInfo = MyFamilyInfo()
    
    
    //MARK: - ViewLifeCycleMethod
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.bounces = false
        NotificationCenter.default.addObserver(self, selector: #selector(DrawerViewController.reloadTableData(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        myFamilyObject = self.loadMyProfile()
        //create A tableView
        tableView = UITableView(frame:CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width-50), height: (UIScreen.main.bounds.height)))
        tableView.delegate      =   self
        tableView.dataSource    =   self
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
        //  self.navigationController?.navigationBar.hidden = true
        view.backgroundColor = UIColor.white
        
    
    }
    override func viewWillAppear(_ animated: Bool) {
        
        print("hey willl appperrr ")
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        shadowBackGround.removeFromSuperview()
    }
    
    //MARK: - TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0 {
            return 1
        }else{
         return itemList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        if (indexPath as NSIndexPath).section == 0 {
            
            // create first cell of tableview for Name , Image & Mobile Number
            
            let userName = myFamilyObject.memberName
            var mobileNo = myFamilyObject.memberMobileNo
            let firstName: String = userName.components(separatedBy:" ").first!.uppercased() as String
            mobileNo = "+91" + mobileNo
            
            userImageView = BaseUIController().AImageViewFrame(CGRect(x: 20, y: 35, width: 70, height: 70), withImageName: "avatar1.png")as! UIImageView
            userImageView.layer.masksToBounds = true
            userImageView.layer.cornerRadius = userImageView.frame.width/2;
            userImageView.isUserInteractionEnabled = true
            cell.addSubview(userImageView)
            
            let lblUserName = BaseUIController().ALabelFrame(CGRect(x: 20,y: 110,width: 200,height: 21), withString: firstName)as! UILabel
            lblUserName.textColor = UIColor.white
            lblUserName.font = UIFont(name: KROBOTO_LIGHT, size: 16)
            cell.addSubview(lblUserName)
            let lblMobileNo:UILabel = BaseUIController().ALabelFrame(CGRect(x: 20, y: 130, width: 200,height: 21), withString: mobileNo) as! UILabel
            lblMobileNo.textColor = UIColor.white
            lblMobileNo.font = UIFont(name: KROBOTO_LIGHT, size: 16)
            cell.addSubview(lblMobileNo)
            //Set Back ground image on Cell
            cell.backgroundView = UIImageView(image: UIImage(named: "drawer_background.png")!)
           
            if (myFamilyObject.memberPhoto != "") {
                let imageString = myFamilyObject.memberPhoto
                let data = Data(base64Encoded: imageString, options: NSData.Base64DecodingOptions(rawValue: 0))
                if imageString != "" {
                    userImageView.image = UIImage.init(data: data!)
                }else{
                    userImageView.image = UIImage(named: "avatar1.png")
                }
            }
            // add gesture on User ImageView
            let tapGesture = UITapGestureRecognizer(target: self , action: #selector(DrawerViewController.tapOnUserView(_:)))
            tapGesture.numberOfTapsRequired = 1
            userImageView.addGestureRecognizer(tapGesture)

            
            cell.selectionStyle = .none
            
        }else{
            let imgViewOfItemList = BaseUIController().AImageViewFrame(CGRect(x: 20, y: 13, width: 24 ,height: 24), withImageName: itemListIcon [(indexPath as NSIndexPath).row])
            cell.addSubview(imgViewOfItemList as! UIView)
            let lblItemList = BaseUIController().ALabelFrame(CGRect(x: 60, y: 0, width: self.view.frame.width - 60,height: 50), withString: itemList[(indexPath as NSIndexPath).row])as! UILabel
            lblItemList.font = UIFont(name: KROBOTO_LIGHT, size: 17)
            lblItemList.textColor = UIColor.darkGray
            if (indexPath as NSIndexPath).row == 7 {
                
                print(String(format: "%@",appDelegate.walletBalance))
                lblItemList.text = "WALLET ₹ " + String(format: "%@",appDelegate.walletBalance)
            }
            cell.addSubview(lblItemList)
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var navController:UINavigationController = UINavigationController()
        let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
        
        if (indexPath as NSIndexPath).section == 0 {
            // i will manage later writing code for handel crash on logout 
            UserDefaults.standard.set(false, forKey: "forceupdate")
            let homeVC:HomeViewController = HomeViewController()
            homeVC.isComingFromClass = "myaccount"
            navController = UINavigationController(rootViewController:homeVC )
        }else if ((indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0) {
            
            let homeVC:HomeViewController = HomeViewController()
            navController = UINavigationController(rootViewController:homeVC )
            
        }
        else if ((indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1) {
            let myFamilyVC = storyboard1.instantiateViewController(withIdentifier: "MyFamilyViewController")as! MyFamilyViewController
            navController = UINavigationController(rootViewController:myFamilyVC)
        }else if ((indexPath as NSIndexPath).row == 2){
            
            let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
            homeTapSwipeVC.identifires = "MY RECORDS"
            navController = UINavigationController(rootViewController:homeTapSwipeVC)
            
        }
        else if ((indexPath as NSIndexPath).row == 3){
            let myOrdersVC = MyOrderViewController()
            navController = UINavigationController(rootViewController:myOrdersVC)
        }else if((indexPath as NSIndexPath).row == 4){
            //                let myReminderVC = MyReminderViewController()
            //                navController = UINavigationController(rootViewController:myReminderVC)
            // let homeVC = storyboard1.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
            let homeVC:HomeViewController = HomeViewController()
            homeVC.isComingFromClass = "myreminder"
            navController = UINavigationController(rootViewController:homeVC )
        }
        else if((indexPath as NSIndexPath).row == 5){
            
            let homeVC:HomeViewController = HomeViewController()
            homeVC.isComingFromClass = "Graph"
            navController = UINavigationController(rootViewController:homeVC )
        }
        else if ((indexPath as NSIndexPath).row == 6){
            let homeVC:HomeViewController = HomeViewController()
            homeVC.isComingFromClass = "notifications"
            navController = UINavigationController(rootViewController:homeVC )
            
        }else if ((indexPath as NSIndexPath).row == 7){
            let homeVC:HomeViewController = HomeViewController()
            homeVC.isComingFromClass = "wallet"
            navController = UINavigationController(rootViewController:homeVC )
        }else if((indexPath as NSIndexPath).row == 8){
            let homeVC:HomeViewController = HomeViewController()
            homeVC.isComingFromClass = "barcode"
            navController = UINavigationController(rootViewController:homeVC )
        
        }
        else if((indexPath as NSIndexPath).row == 9){
            let submitQueryVC = SubmitQueryViewController()
            navController = UINavigationController(rootViewController:submitQueryVC)
        }else if ((indexPath as NSIndexPath).row == 10){
            let homeVC:HomeViewController = HomeViewController()
            homeVC.isComingFromClass = "Chat"
            navController = UINavigationController(rootViewController:homeVC )
        }
        else {
            let homeVC:HomeViewController = HomeViewController()
            homeVC.isComingFromClass = "callSupport"
            navController = UINavigationController(rootViewController:homeVC )
    
        }
            let drawerController = parent as? KYDrawerController
            drawerController!.mainViewController = navController
            drawerController!.setDrawerState(.closed, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if ((indexPath as NSIndexPath).section == 0) {
            return 160;
            
        }else{
            return  50;
        }
        
    }
    //MARK: - ImagePickerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
        userImageView.image = image
        self.changeUserImage()
    }
    //MARK: - createPopupView
    
    func OpenChangeImagePopUp()   {
        
        shadowBackGround = UIView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height))
        shadowBackGround.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(shadowBackGround)
        let xPos:CGFloat = 10
        var yPos:CGFloat = 5
        
        
        
        let popUpView = UIView(frame: CGRect(x: 20, y: self.view.center.y - 70 ,width: self.view.frame.width-40 ,height: 130))
        popUpView.layer.cornerRadius = 4
        popUpView.backgroundColor = UIColor.white
        shadowBackGround .addSubview(popUpView)
        
        let lblChangePhoto = BaseUIController().ALabelFrame(CGRect(x: xPos ,y: yPos , width: 200 , height: 21), withString: "Change Photo")as! UILabel
        lblChangePhoto.font = UIFont().largeFont
        popUpView.addSubview(lblChangePhoto)
        
        yPos += 21 + 5
        
        let btnTakePhoto = BaseUIController().AButtonFrame(CGRect(x: xPos, y: yPos, width: self.view.frame.width-20, height: 25 ), withButtonTital: "Take Photo")as! UIButton
        btnTakePhoto.addTarget(self, action: #selector(MyFamilyMemberInfoViewController.btnTakephotoOnClick), for: .touchUpInside)
        btnTakePhoto.titleLabel?.font = UIFont().mediumFont
        btnTakePhoto.contentHorizontalAlignment = .left
        popUpView.addSubview(btnTakePhoto)
        
        yPos += 25 + 5
        
        let btnChooseFormGallery = BaseUIController().AButtonFrame(CGRect(x: xPos, y: yPos, width: self.view.frame.width-20, height: 25 ), withButtonTital: "Choose from Gallery") as! UIButton
        btnChooseFormGallery.addTarget(self, action: #selector(MyFamilyMemberInfoViewController.btnChooseFromGalleryOnClick), for: .touchUpInside)
        btnChooseFormGallery.titleLabel!.font = UIFont().mediumFont
        btnChooseFormGallery.contentHorizontalAlignment = .left
        popUpView.addSubview(btnChooseFormGallery)
        
        yPos += 25 + 5
        
        let btnChoseAvatar = BaseUIController().AButtonFrame(CGRect(x: xPos, y: yPos, width: self.view.frame.width-20, height: 25 ), withButtonTital: "Choose Avatar") as! UIButton
        btnChoseAvatar.addTarget(self, action: #selector(MyFamilyMemberInfoViewController.btnChooseAvatarOnClick), for: .touchUpInside)
        btnChoseAvatar.titleLabel!.font = UIFont().mediumFont
        btnChoseAvatar.contentHorizontalAlignment = .left
        popUpView.addSubview(btnChoseAvatar)
        
        // add Tapgestue  on shadowBackGround
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyFamilyMemberInfoViewController.tappedOnShadowBG(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        shadowBackGround.addGestureRecognizer(tapped)
    }
    
    func openAvatarPopup()  {
        
        shadowBackGround = UIView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width  , height: self.view.frame.height))
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
            btnAvatarImage.addTarget(self, action: #selector(MyFamilyMemberInfoViewController.btnAvatarImageOnClick(_:)), for: .touchUpInside)
            
        }
        
        // add Tapgestue  on shadowBackGround
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyFamilyMemberInfoViewController.tappedOnShadowBG(_:)))
        tapped.numberOfTapsRequired = 1
        tapped.delegate = self
        shadowBackGround.addGestureRecognizer(tapped)
        
    }

    //MARK: - GestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //UITableViewCellContentView
        if (touch.view == shadowBackGround ){
            
            return true
        }
        else{
            
            return false
        }
    }
    

    
   // MARK: TapGestureRecognizerMethod
    
    func tapOnUserView(_ sender: UITapGestureRecognizer)  {
       self.OpenChangeImagePopUp()
    }

    func tappedOnShadowBG(_ sender: UITapGestureRecognizer)  {
        shadowBackGround.removeFromSuperview()
    }

    //MARK:- ButtonOnClick
    
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
        shadowBackGround.removeFromSuperview()
        userImageView.image = UIImage(named: arrAvatarImage[tag - 500] )
        self.changeUserImage()
    }
    
    func didTapCloseButton(_ sender: UIButton) {
        if let drawerController = parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
        }
    }
    
    //MARK: - UpdateDatabase
    func changeUserImage() {
        let reSizeImage = self.resizeImage(userImageView.image!, targetSize: CGSize(width: 200.0, height: 200.0))
        let imageData = UIImagePNGRepresentation(reSizeImage)
        let base64String = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        do {
            try database.executeUpdate(String(format:"update MyFamily set MemberPhoto ='%@', SyncStatus = 'N'  where MemberId = '%@'",base64String,customerId), values: nil)
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        database.close()
        //sync data on server
        HomeViewController().getNonSyncDataFromMyFamilyTable()
    }
    func loadMyProfile()-> MyFamilyInfo  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        let  myFamilyObj = MyFamilyInfo()
        let memberId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
        do {
            let rs = try database.executeQuery(String(format: "select * from MyFamily where MemberId = %@",memberId ), values: nil)
            while rs.next() {
                myFamilyObj.memberId = rs.string(forColumn: "MemberId")
                myFamilyObj.memberName = rs.string(forColumn: "MemberName")
                myFamilyObj.memberRelation = rs.string(forColumn: "Relation")
                myFamilyObj.memberPhoto = rs.string(forColumn: "MemberPhoto")
                myFamilyObj.memberDOB = rs.string(forColumn: "MemberDOB")
                myFamilyObj.memberEmail = rs.string(forColumn: "MemberEmail")
                myFamilyObj.memberGender = rs.string(forColumn: "MemberGender")
                myFamilyObj.memberMobileNo = rs.string(forColumn: "MemberMobileNo")
                myFamilyObj.memberVerefyStatus = rs.string(forColumn: "Verified")
                myFamilyObj.memberActiveStatus = rs.string(forColumn: "Active")
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
        return myFamilyObj
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
    func reloadTableData(_ notification: Notification) {
        myFamilyObject = self.loadMyProfile()
        print(myFamilyObject.memberName)
        tableView.reloadData()
    }


    
}
