//
//  SetReminderTimeViewController.swift
//  Health
//
//  Created by HW-Anil on 8/18/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class SetReminderTimeViewController: UIViewController {
     //MARK: VariableDeclaration
    var morningSlider = UISlider()
    var hiddenMorningSlider = UISlider()
    var afternoonSlider = UISlider()
    var hiddenAfternoonSlider = UISlider()
    var eveningSlider = UISlider()
    var hiddenEveningSlider = UISlider()
    let textColor = UIColor.init(red: (180.0/255.0), green: (180.0/255.0), blue: (180.0/255.0), alpha: 1)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let arrMorningTimeList = ["06:00 AM", "07:00 AM" , "08:00 AM" , "09:00 AM", "10:00 AM" , "11:00 AM"]
    let arrAfterNoonTimeList = ["12:00 PM", "01:00 PM" , "02:00 PM" , "03:00 PM", "04:00 PM" , "05:00 PM"]
    let arrEveningTimeList = ["06:00 PM", "07:00 PM" , "08:00 PM" , "09:00 PM", "10:00 PM" , "11:00 PM"]
    var arrSelectedTimeList = [String]()
    
    
   //MARK: ViewLifeCycleMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        self.createALayout()
        let barButtonOk = UIBarButtonItem(title: "  Ok   " ,style: .done,target: self,action:#selector(SetReminderTimeViewController.barButtonOkOnClick(_:)) )
        self.navigationItem.rightBarButtonItem = barButtonOk
        
        // Populate selected  time
        let selectedIndexForMorning = Float (arrMorningTimeList.index(of: arrSelectedTimeList[0])!)
        morningSlider.setValue(selectedIndexForMorning + 1 , animated: true)
        hiddenMorningSlider.setValue(selectedIndexForMorning + 1 , animated: true)
        let selectedIndexForAfternoon = Float (arrAfterNoonTimeList.index(of: arrSelectedTimeList[1])!)
        afternoonSlider.setValue(selectedIndexForAfternoon + 1 , animated: true)
        hiddenAfternoonSlider.setValue(selectedIndexForAfternoon + 1 , animated: true)
        let selectedIndexForEvening = Float (arrEveningTimeList.index(of: arrSelectedTimeList[2])!)
        eveningSlider.setValue(selectedIndexForEvening + 1 , animated: true)
        hiddenEveningSlider.setValue(selectedIndexForEvening + 1 , animated: true)

        let label_MorningTime = self.view.viewWithTag(101 + Int(selectedIndexForMorning))as! UILabel
        label_MorningTime.textColor = UIColor.red
        let label_AfternoonTime = self.view.viewWithTag(201 + Int(selectedIndexForAfternoon))as! UILabel
        label_AfternoonTime.textColor = UIColor.blue
        let label_EveningTime = self.view.viewWithTag(301 + Int(selectedIndexForEvening))as! UILabel
        label_EveningTime.textColor = UIColor.orange
    }
    override func viewWillAppear(_ animated: Bool) {
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;
        self.title = "SET TIME"
        
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("SetReminder Screen")
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: DesignLayout
    func createALayout() {
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.view.addSubview(scrollView)
        
        var yPos :CGFloat = 20
        let sliderWidth = (self.view.frame.height  - (64 + 80))/3
        // set slider heigh manually
        var addExtraYpos = CGFloat()
        if (UIScreen.main.bounds.size.height == 480){
            addExtraYpos = 40
        }else if(UIScreen.main.bounds.size.height == 568){
            addExtraYpos = 60
        }else if(UIScreen.main.bounds.size.height == 667){
            addExtraYpos = 70
        }
        else if(UIScreen.main.bounds.size.height == 736){
            addExtraYpos = 85
        }
        
        
        
        //Slider for Morning
        morningSlider = UISlider.init(frame: CGRect(x: 30, y: yPos + addExtraYpos, width: sliderWidth , height: 30))
        morningSlider.maximumValue = 6
        morningSlider.minimumValue = 1
      //  morningSlider.continuous = true
        morningSlider.minimumTrackTintColor = UIColor.red
        morningSlider.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        morningSlider.addTarget(self, action: #selector(SetReminderTimeViewController.morningSliderChange(_:)), for: .valueChanged)
        morningSlider.addTarget(self, action: #selector(SetReminderTimeViewController.morningSliderTouchEndEvent(_:)), for:.touchUpInside)
        scrollView.addSubview(morningSlider)
        
        hiddenMorningSlider = UISlider.init(frame: CGRect(x: 140, y: yPos + addExtraYpos, width: sliderWidth , height: 30))
        hiddenMorningSlider.setThumbImage(UIImage(named: "reminder_icons_morning_blank.png"), for: UIControlState())
        hiddenMorningSlider.setMinimumTrackImage(UIImage(), for: UIControlState())
        hiddenMorningSlider.setMaximumTrackImage(UIImage(), for: UIControlState())
        hiddenMorningSlider.maximumValue = 6
        hiddenMorningSlider.minimumValue = 1
      //  hiddenMorningSlider.continuous = true
        hiddenMorningSlider.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        hiddenMorningSlider.addTarget(self, action: #selector(SetReminderTimeViewController.morningSliderChange(_:)), for: .valueChanged)
        hiddenMorningSlider.addTarget(self, action: #selector(SetReminderTimeViewController.morningSliderTouchEndEvent(_:)), for:.touchUpInside)
        scrollView.addSubview(hiddenMorningSlider)
        for i in 1..<7 {
            let lblTime = BaseUIController().ALabelFrame(CGRect(x: 10, y: yPos, width: 80, height: sliderWidth/6), withString: arrMorningTimeList[i - 1])as! UILabel
            lblTime.tag = 100 + i
            scrollView.addSubview(lblTime)
            yPos += sliderWidth/6
//            if i == 1 {
//                lblTime.textColor = UIColor.redColor()
//            }else{
//               lblTime.textColor = textColor
//            }
        }
        yPos += 10
        // Slider for AfterNoon
        afternoonSlider = UISlider.init(frame: CGRect(x: 30, y: yPos + addExtraYpos, width: sliderWidth , height: 30))
        afternoonSlider.maximumValue = 6
        afternoonSlider.minimumValue = 1
      //  afternoonSlider.continuous = true
        afternoonSlider.minimumTrackTintColor = UIColor.blue
        afternoonSlider.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        afternoonSlider.addTarget(self, action: #selector(SetReminderTimeViewController.afternoonSliderChange(_:)), for: .valueChanged)
        afternoonSlider.addTarget(self, action: #selector(SetReminderTimeViewController.afternoonSliderTouchEndEvent(_:)), for: .touchUpInside)
        scrollView.addSubview(afternoonSlider)
        
        hiddenAfternoonSlider = UISlider.init(frame: CGRect(x: 140, y: yPos + addExtraYpos , width: sliderWidth , height: 30))
        hiddenAfternoonSlider.setThumbImage(UIImage(named: "reminder_icon_afternoon_blank.png"), for: UIControlState())
        hiddenAfternoonSlider.setMinimumTrackImage(UIImage(), for: UIControlState())
        hiddenAfternoonSlider.setMaximumTrackImage(UIImage(), for: UIControlState())
        hiddenAfternoonSlider.maximumValue = 6
        hiddenAfternoonSlider.minimumValue = 1
      //  hiddenAfternoonSlider.continuous = true
        hiddenAfternoonSlider.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        hiddenAfternoonSlider.addTarget(self, action: #selector(SetReminderTimeViewController.afternoonSliderChange(_:)), for: .valueChanged)
        hiddenAfternoonSlider.addTarget(self, action: #selector(SetReminderTimeViewController.afternoonSliderTouchEndEvent(_:)), for: .touchUpInside)
        scrollView.addSubview(hiddenAfternoonSlider)
        for i in 1..<7 {
            let lblTime = BaseUIController().ALabelFrame(CGRect(x: 10, y: yPos, width: 80, height: sliderWidth/6), withString: arrAfterNoonTimeList[i - 1])as! UILabel
            lblTime.tag = 200 + i
            scrollView.addSubview(lblTime)
            yPos += sliderWidth/6
//            if i == 1 {
//                lblTime.textColor = UIColor.blueColor()
//            }else{
//                 lblTime.textColor = textColor
//            }
        }
        yPos += 10
        // Slider for Evening
        
        eveningSlider = UISlider.init(frame: CGRect(x: 30, y: yPos + addExtraYpos , width: sliderWidth , height: 30))
        eveningSlider.maximumValue = 6
        eveningSlider.minimumValue = 1
       // eveningSlider.continuous = false
        eveningSlider.minimumTrackTintColor = UIColor.orange
        eveningSlider.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        eveningSlider.addTarget(self, action: #selector(SetReminderTimeViewController.eveningSliderChange(_:)), for: .valueChanged)
        eveningSlider.addTarget(self, action: #selector(SetReminderTimeViewController.eveningSliderTouchEndEvent(_:)), for: .touchUpInside)
        scrollView.addSubview(hiddenAfternoonSlider)
        scrollView.addSubview(eveningSlider)
        
        hiddenEveningSlider = UISlider.init(frame: CGRect(x: 140, y: yPos + addExtraYpos  , width: sliderWidth , height: 30))
        hiddenEveningSlider.setThumbImage(UIImage(named: "reminder_icon_evening_blank.png"), for: UIControlState())
        hiddenEveningSlider.setMinimumTrackImage(UIImage(), for: UIControlState())
        hiddenEveningSlider.setMaximumTrackImage(UIImage(), for: UIControlState())
        hiddenEveningSlider.maximumValue = 6
        hiddenEveningSlider.minimumValue = 1
     //   hiddenEveningSlider.continuous = false
        hiddenEveningSlider.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        hiddenEveningSlider.addTarget(self, action: #selector(SetReminderTimeViewController.eveningSliderChange(_:)), for: .valueChanged)
        hiddenEveningSlider.addTarget(self, action: #selector(SetReminderTimeViewController.eveningSliderTouchEndEvent(_:)), for: .touchUpInside)
        scrollView.addSubview(hiddenEveningSlider)
        for i in 1..<7 {
            let lblTime = BaseUIController().ALabelFrame(CGRect(x: 10, y: yPos, width: 80, height: sliderWidth/6), withString: arrEveningTimeList[i - 1])as! UILabel
            lblTime.tag = 300 + i
            scrollView.addSubview(lblTime)
            yPos += sliderWidth/6
//            if i == 1 {
//                lblTime.textColor = UIColor.greenColor()
//            }else{
//                lblTime.textColor = textColor
//            }
        }
    }
    //MARK: SliderValueChange
    func morningSliderChange(_ slider : UISlider)  {
        let arrTag = [101 , 102 , 103 , 104 , 105, 106]
        let lblTag = Int(round(slider.value))
        hiddenMorningSlider.setValue(round(slider.value), animated: true)
        hiddenMorningSlider.setThumbImage(UIImage(named: "reminder_icons_morning_red.png"), for: UIControlState())
        morningSlider.setValue(round(slider.value), animated: true)
        for i in 0..<6 {
            if lblTag + 100 == arrTag[i] {
                let label = self.view.viewWithTag(arrTag[i])as! UILabel
                label.textColor = UIColor.red
                 appDelegate.morningAlarmTime = arrMorningTimeList[i]
            }else{
                let label = self.view.viewWithTag(arrTag[i])as! UILabel
                label.textColor = textColor
             }
         }
       
    }
    func morningSliderTouchEndEvent(_ sliderEvent : UISlider)  {
         hiddenMorningSlider.setThumbImage(UIImage(named: "reminder_icons_morning_blank.png"), for: UIControlState())
        
    }
    func afternoonSliderChange(_ slider : UISlider) {
        let arrTag = [201 , 202 , 203 , 204 , 205, 206]
        let lblTag = Int(round(slider.value))
        hiddenAfternoonSlider.setValue(round(slider.value), animated: true)
        hiddenAfternoonSlider.setThumbImage(UIImage(named: "reminder_icon_afternoon_blue.png"), for: UIControlState())
        afternoonSlider.setValue(round(slider.value), animated: true)
        for i in 0..<6 {
            if lblTag + 200 == arrTag[i] {
                let label = self.view.viewWithTag(arrTag[i])as! UILabel
                label.textColor = UIColor.blue
                appDelegate.afternoonAlarmTime = arrAfterNoonTimeList[i]
            }else{
                let label = self.view.viewWithTag(arrTag[i])as! UILabel
                label.textColor = textColor
            }
        }
    }
    func afternoonSliderTouchEndEvent(_ sliderEvent : UISlider)  {
        hiddenAfternoonSlider.setThumbImage(UIImage(named: "reminder_icon_afternoon_blank.png"), for: UIControlState())
        
    }
    func eveningSliderChange(_ slider : UISlider) {
        let arrTag = [301 , 302 , 303 , 304 , 305, 306]
        let labelTag = Int(round(slider.value))
        hiddenEveningSlider.setValue(round(slider.value), animated: true)
        hiddenEveningSlider.setThumbImage(UIImage(named: "reminder_icon_evening_yellow.png"), for: UIControlState())
        eveningSlider.setValue(round(slider.value), animated: true)
        for i in 0..<6 {
            if labelTag + 300 == arrTag[i] {
                let label = self.view.viewWithTag(arrTag[i])as! UILabel
                label.textColor = UIColor.orange
                appDelegate.eveningAlarmTime = arrEveningTimeList[i]
            }else{
                let label = self.view.viewWithTag(arrTag[i])as! UILabel
                label.textColor = textColor
            }
        }
    }
    func eveningSliderTouchEndEvent(_ sliderEvent : UISlider)  {
        hiddenEveningSlider.setThumbImage(UIImage(named: "reminder_icon_evening_blank.png"), for: UIControlState())
        
    }
    func barButtonOkOnClick(_ barButton : UIBarButtonItem)  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.isReminderValueChange = true
        self.navigationController?.popViewController(animated: true)
        
    }
    func barButtonBackClick(_ barButton : UIBarButtonItem)  {
        
        self.navigationController?.popViewController(animated: true)
    }


}
