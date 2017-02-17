//
//  AddNewAddressViewController.swift
//  Stetho
//
//  Created by Administrator on 17/02/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit

class AddNewAddressViewController: UIViewController {
    
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
    var cityPickerView : UIPickerView = UIPickerView()
    var memberNamePickerView : UIPickerView = UIPickerView()
        
    var arrCityName = ["Delhi" , "New Delhi" , "Faridabad", "Ballabhgarh", "Gurgaon" , "Ghaziabad" , "Noida" ,"Greater Noida", "Meerut", "Sonipat","Bahadurgarh"]
    var autocompleteTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
        let rightButton = UIBarButtonItem(title: KCANCEL, style: .plain, target: self, action: #selector(AddNewAddressViewController.cancelButtonClicked(_:)))
        rightButton.tintColor = KRED_COLOR
        self.navigationItem.rightBarButtonItem = rightButton

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelButtonClicked(_ sender: AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    
    func createALayout()  {
        
        scrollView = TPKeyboardAvoidingScrollView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height)) //nav + topborder + segment + continue
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
            textField.font = KROBOTO_Light_17
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
        
        
        xPos =  120
        let _width: CGFloat = (self.view.frame.width - (xPos + 20 + 50 ))/6
        
        
        for i in (0..<6) {
            
            let textField = UITextField(frame: CGRect(x: xPos , y: yPos ,width: _width , height: _width ))
            //            let textField = BaseUIController().ATextFiedlFrame(CGRect(x: xPos , y: yPos ,width: _width , height: _width ), withPlaceHolder: "")as! UITextField
            textField.borderStyle = .line
            textField.layer.borderWidth = 1.5
            textField.layer.cornerRadius = 4.0
            textField.layer.masksToBounds = true
            textField.layer.borderColor =  UIColor.lightGray.cgColor//UIColor.lightGray.cgColor//UIColor.init(red: (242.0/255.0), green: (237.0/255.0), blue: (237.0/255.0), alpha: 1.0).cgColor
            textField.font = KROBOTO_Light_21
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
//        cityPickerView.dataSource = self
//        cityPickerView.delegate = self
        txtCity.inputView = cityPickerView
        addToolBar(txtCity)
        
        // Add a "textFieldDidChange" notification method to the text field control.
        txtLocality.addTarget(self, action: #selector(PickUpDetailsViewController.textFieldDidChange), for: .editingChanged)
        
        // create a autocomplete tableView
        
        autocompleteTableView = UITableView(frame:CGRect(x: 10, y: 50,width: (UIScreen.main.bounds.width) - 20, height: 120))
        autocompleteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        autocompleteTableView.separatorStyle = .none
        autocompleteTableView.backgroundColor = UIColor.clear
//        autocompleteTableView.dataSource = self
//        autocompleteTableView.delegate = self
        autocompleteTableView.isHidden = true
        autocompleteTableView.layer.cornerRadius = 4
        autocompleteTableView.layer.borderWidth = 1
        scrollView.addSubview(self.autocompleteTableView)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
