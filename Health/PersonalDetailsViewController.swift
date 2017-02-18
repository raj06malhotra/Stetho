//
//  PersonalDetailsViewController.swift
//  Health
//
//  Created by HW-Anil on 6/25/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class PersonalDetailsViewController: UIViewController {
var maleImageView: UIImageView = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.createALayout()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func createALayout()  {
        
        let scrollView:UIScrollView = UIScrollView(frame: CGRect(x: 0 , y: 0 , width: self.view.frame.width , height: self.view.frame.height))
        self.view .addSubview(scrollView)
        let xPos:CGFloat = 20
        var yPos:CGFloat = 5
        var labelName: [String] = ["First Name :" , "Last Name :" , "Mobile Number :", "Email ID :"]
        
        
        
        for i in (0..<4) {
            let label = BaseUIController().ALabelFrame(CGRect(x:xPos , y: yPos ,width: 200 , height: 30 ), withString: labelName[i])as! UILabel
            scrollView.addSubview(label)
            yPos += 21+2;
            let textField = BaseUIController().ATextFiedlFrame(CGRect(x:xPos , y: yPos ,width: self.view.frame.width-40 , height: 30 ), withPlaceHolder: "")as! UITextField
            textField.borderStyle = .line
            scrollView.addSubview(textField)
            
            yPos += 30+5;
        }
        yPos += 10;
        let lblDOB:UILabel = BaseUIController().ALabelFrame(CGRect(x: xPos , y: yPos, width: 100, height: 21), withString: "Date of Birth :")as! UILabel
        scrollView.addSubview(lblDOB)
        let txtDateOfBirth:UITextField = BaseUIController().ATextFiedlFrame(CGRect(x: self.view.frame.width-170 ,y: yPos,width: 150,height: 30), withPlaceHolder: "")as! UITextField
        txtDateOfBirth.borderStyle = .line
        scrollView.addSubview(txtDateOfBirth)
        yPos += 30+10;
        let lblGender:UILabel = BaseUIController().ALabelFrame(CGRect(x: xPos , y: yPos, width: 100, height: 21), withString: "Gender :")as! UILabel
        scrollView.addSubview(lblGender)
        
        let btnMale: UIButton = BaseUIController().AButtonFrame(CGRect (x: txtDateOfBirth.frame.origin.x , y: yPos, width: 80, height: 25), withButtonTital: "Male")as! UIButton
        btnMale.addTarget(self, action: #selector(PersonalDetailsViewController.btnMaleOnClick(_:)), for: .touchUpInside)
       // btnMale.backgroundColor = UIColor .redColor()
        scrollView.addSubview(btnMale)
         maleImageView = BaseUIController().AImageViewFrame(CGRect (x: 0 , y: 8 , width: 10 , height: 10), withImageName: "chat_icon")as! UIImageView
        maleImageView.tag = 260;
        maleImageView.backgroundColor = UIColor.yellow
        btnMale.addSubview(maleImageView)
        
        let btnFemale: UIButton = BaseUIController().AButtonFrame(CGRect (x: btnMale.frame.origin.x+90 , y: yPos, width: 90, height: 25), withButtonTital: "Female")as! UIButton
        btnFemale.addTarget(self, action: #selector(PersonalDetailsViewController.btnMaleOnClick(_:)), for: .touchUpInside)
       // btnFemale.backgroundColor = UIColor .greenColor()
        scrollView.addSubview(btnFemale)
        let femaleImageView: UIImageView = BaseUIController().AImageViewFrame(CGRect (x: 0 , y: 8 , width: 10 , height: 10), withImageName: "chat_icon")as! UIImageView
        femaleImageView.backgroundColor = UIColor.yellow
        btnFemale.addSubview(femaleImageView)
        yPos += 25 + 10 ;
        
        let btnNext = BaseUIController().AButtonFrame(CGRect(x: self.view.frame.width - 80 , y: yPos, width: 60, height: 30), withButtonTital: "NEXt")as! UIButton
        btnNext.backgroundColor = KRED_COLOR
        btnNext.setTitleColor(UIColor.white, for: UIControlState())
        scrollView.addSubview(btnNext)
        
        
        
        
        
        
        
    }
    func btnMaleOnClick(_ button: UIButton)  {
        button.imageView?.image = UIImage (named: "my_family")
        if maleImageView.isHidden == true {
            maleImageView.isHidden = false
        }else{
            maleImageView.isHidden = true
        }
        
        print("button on click")
        print(button)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
