//
//  Cancel_RecheduleViewController.swift
//  Health
//
//  Created by HW-Anil on 8/16/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class Cancel_RecheduleViewController: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource ,serverTaskComplete {
    var timePickerView : UIPickerView = UIPickerView()
    var arrTime = ["04:00-04:30", "04:30-05:00" ,"05:00-05:30" , "05:30-06:00" , "06:00-06:30" , "06:30-07:00" , "07:00-07:30" , "07:30-08:00" , "08:00-08:30", "08:30-09:00" , "09:00-09:30" , "09:30-10:00" , "10:00-10:30" ,"10:30-11:00" , "11:00-11:30" , "11:30-12:00" , "12:00-12:30" , "13:00-13:30" , "13:30-14:00" , "14:00-14:30" , "14:30-15:00" , "15:00-15:30" , "15:30-16:00" , "16:00-16:30" , "16:30-17:00" , "17:00-17:30" , "17:00-18:00"]
    var arrDay = ["Tomorrow " ,"Day after Tomorrow "]
    var bgView = UIView()
    var lblPikcUpDate = UILabel()
    var pickupDay_Time = ""
    var pickupTime = ""
    var pickupDay = ""
    var activityIndicator : ProgressViewController?
    var orderId = ""
    var order_Number = ""
    var order_secheduleTime = ""
    


    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        self.createALayout()
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        self.title = "EDIT APPOINTMENT"
       // self.navigationController!.navigationBar.topItem!.title = "Back"
    }
    override func viewWillAppear(_ animated: Bool) {
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("Cancel&Reschedule Screen")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func createALayout()  {
        let view1 = UIView.init(frame: CGRect(x: 10, y: 85, width: self.view.frame.width - 20, height: 50))
        view1.backgroundColor = UIColor.init(red: (244.0/255), green: (244.0/255.0), blue: (244.0/255), alpha: 1.0)
        self.view.addSubview(view1)
        let lblOrderId = BaseUIController().ALabelFrame(CGRect(x: 5, y: 5, width: view1.frame.width - 10, height: 20), withString: "")as! UILabel
        lblOrderId.text = String(format: "Order Id: %@",self.order_Number)
        lblOrderId.font = UIFont().regularMediumFont
        view1.addSubview(lblOrderId)
        print(order_secheduleTime)
        let lblScheduled = BaseUIController().ALabelFrame(CGRect(x: 5, y: 25, width: view1.frame.width - 10, height: 20), withString: "Scheduled on ")as! UILabel
        lblScheduled.text = String(format: "Scheduled On: %@", order_secheduleTime)
        lblScheduled.font = UIFont().mediumFont
        lblScheduled.textColor = KRED_COLOR
        view1.addSubview(lblScheduled)
        
        let view2 = UIView.init(frame: CGRect(x: 10, y: 155, width: self.view.frame.width - 20, height: 100))
        view2.backgroundColor = UIColor.init(red: (244.0/255), green: (244.0/255.0), blue: (244.0/255), alpha: 1.0)
        self.view.addSubview(view2)
        
        let reschedule_clockImage = BaseUIController().AImageViewFrame(CGRect(x: 5, y: 15, width: 20, height: 20), withImageName: "clock_order.png")as! UIImageView
        view2.addSubview(reschedule_clockImage)
        let btnReschedule = BaseUIController().AButtonFrame(CGRect(x: 30, y: 5, width: view2.frame.width - 30, height: 40), withButtonTital: "Reschedule")as! UIButton
        btnReschedule.contentHorizontalAlignment = .left
        btnReschedule.titleLabel?.font = UIFont().largeFont
        btnReschedule.addTarget(self, action: #selector(Cancel_RecheduleViewController.btnReschedule(_:)), for: .touchUpInside)
        view2.addSubview(btnReschedule)
        
        let btnCancel = BaseUIController().AButtonFrame(CGRect(x: 30, y: 55, width: view2.frame.width - 30, height: 40), withButtonTital: "Cancel Appointment")as! UIButton
        btnCancel.contentHorizontalAlignment = .left
        btnCancel.titleLabel?.font = UIFont().largeFont
        btnCancel.addTarget(self, action: #selector(Cancel_RecheduleViewController.btnCancel(_:)), for: .touchUpInside)
        view2.addSubview(btnCancel)
        
        let cancel_clockImage = BaseUIController().AImageViewFrame(CGRect(x: 5, y: 65, width: 20, height: 20), withImageName: "clock_order.png")as! UIImageView
        view2.addSubview(cancel_clockImage)

    }
    //MARK: PickerViewDelegate
    
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 2
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if component == 0 {
            return arrDay.count
        }else{
            return arrTime.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return arrDay[row]
        }else{
            return arrTime[row]        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        
        if component == 0 {
            pickupDay = arrDay[row]
        }
        else{
            pickupTime = arrTime[row]
        }
        pickupDay_Time = pickupDay  +  pickupTime
        lblPikcUpDate.text = pickupDay_Time
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        if component == 0 {
            pickerLabel.text = arrDay[row]
        }else{
            pickerLabel.text = arrTime[row]
        }
        
        // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
        pickerLabel.font = KROBOTO_Light_16 // In this use your custom font
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }

    func btnReschedule(_ button : UIButton)  {
        self.openTimePicker()
        
    }
    
    func btnCancel(_ button : UIButton)  {
        self.showAlertView("Are you sure cancel this order?")
       
        
    }
    func openTimePicker()  {
        
        bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(bgView)
        timePickerView = UIPickerView(frame: CGRect(x: 0 , y: self.view.frame.height - 216 , width: self.view.frame.width, height: 216 ))
        timePickerView.backgroundColor = UIColor(red: 210.0/255.0, green: 213.0/255.0, blue: 219.0/255.0, alpha: 1)
        timePickerView.showsSelectionIndicator = true
         timePickerView.selectRow(0, inComponent: 0, animated: true)
//        let dayIndex = Int(arrDay.index(of: pickupDay)!)
//        let timeIndex = Int(arrTime.index(of: pickupTime)!)
//        timePickerView.selectRow(0, inComponent: 0, animated: true)
//        timePickerView.selectRow(0, inComponent: 1, animated: true)
        timePickerView.dataSource = self
        timePickerView.delegate = self
        bgView.addSubview(timePickerView)
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.height - 256, width: self.view.frame.width, height: 40))
        toolBar.barStyle = UIBarStyle.default
        toolBar.tintColor = UIColor.red
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.toolBarDoneOnClick))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.toolBarCancelOnClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        bgView.addSubview(toolBar)
        

        
//        let okView = UIView.init(frame: CGRectMake(20, (timePickerView.frame.height + timePickerView.frame.origin.y), timePickerView.frame.width, 25))
//        okView.backgroundColor = UIColor.blueColor()
//        bgView.addSubview(okView)
        
//        let btnOk = BaseUIController().AButtonFrame(CGRect(x: 20 , y: (timePickerView.frame.height + timePickerView.frame.origin.y), width: timePickerView.frame.width, height: 60), withButtonTital: "Ok")as! UIButton
//        btnOk.titleLabel?.font = UIFont().regularMediumFont
//        btnOk.titleEdgeInsets = UIEdgeInsetsMake(0, btnOk.frame.width - 100, 0, 0)
//        btnOk.backgroundColor = UIColor.white
//        btnOk.addTarget(self, action: #selector(Cancel_RecheduleViewController.btnOkOnclick(_:)), for: .touchUpInside)
//        bgView.addSubview(btnOk)
        
        
        
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PickUpDetailsViewController.tappedOnBGView(_:)))
        tapped.numberOfTapsRequired = 1
        bgView.addGestureRecognizer(tapped)
        
    }
    func tappedOnBGView(_ sender: UITapGestureRecognizer)  {
        bgView.isHidden = true
        bgView.removeFromSuperview()
    }
    
    func toolBarDoneOnClick(){
        bgView.removeFromSuperview()
        self.RescheduleOrder()
    }
    func toolBarCancelOnClick(){
       bgView.removeFromSuperview()
    }
    
    func btnOkOnclick(_ button : UIButton)  {
       // self.updatePickupTime()
        bgView.removeFromSuperview()
        self.RescheduleOrder()
        
    }
    func barButtonBackClick(_ barButton : UIBarButtonItem)  {
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func addUnitToDate(_ unitType: NSCalendar.Unit, number: Int, date:Date) -> Date {
        
        return (Calendar.current as NSCalendar).date(
            byAdding: unitType,
            value: number,
            to: date,
            options: NSCalendar.Options(rawValue: 0))!
        
    }
    
    // MARK: CallWebservice
    func CancelOrder() {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let allParameters = ["customerId" : customerId , "orderId" : self.orderId]
            ServerConnectivity().callWebservice(allParameters , resulttagname: "CancelOrderResult" ,methodname: "CancelOrder", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    func RescheduleOrder() {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            let  newPickupTime = pickupTime.components(separatedBy: "-")
            let  todayDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if pickupDay == "Today " {
               pickupDay = dateFormatter.string(from: todayDate)
            }else if(pickupDay == "Tomorrow "){
                let tomorrowDate = self.addUnitToDate(.day, number: 1, date: todayDate)
                pickupDay = dateFormatter.string(from: tomorrowDate)
            }else{
                let dayAfterTomorrowDate = self.addUnitToDate(.day, number: 2, date: todayDate)
                pickupDay = dateFormatter.string(from: dayAfterTomorrowDate)
            }
            
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            
            let allParameters = ["customerId" : customerId ,"orderId" : self.orderId , "orderDate" : pickupDay  , "orderTime" : newPickupTime[0]]
            ServerConnectivity().callWebservice(allParameters , resulttagname: "RescheduleOrderResult" ,methodname: "RescheduleOrder", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
        
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
//        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if allResponse is String &&  allResponse as! String == "" {
                    self.present(BaseUIController().showAlertView("No Record"), animated: true, completion: nil)
                }else if (allResponse is String && allResponse as! String == "0" || allResponse is String && allResponse as! String == "error"){
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }else{
                    if(methodName == "RescheduleOrder"){
                        self.showAlertView("Your order reschedule successfully!")
                    }else{
                        self.showAlertView("Your order cancel successfully!")
                    }
                }
                
            });
        }//);
    }
    func showAlertView(_ msg : String)  {
        //Create the AlertController
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        if (msg == "Are you sure cancel this order?") {
            
            //Create and add the Yes action
            let YesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
                //Do some stuff
                self.CancelOrder()
            }
            actionSheetController.addAction(YesAction)
            
            //Create and add the Cancel action
            let noAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
                //Do some stuff
                let _ = self.navigationController?.popViewController(animated: true)
            }
             actionSheetController.addAction(noAction)

            
            
        }else{
            //Create and add the Yes action
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel) { action -> Void in
                //Do some stuff
                let _ = self.navigationController?.popViewController(animated: true)
            }
            actionSheetController.addAction(okAction)
        }
        
        
        
        
               //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
        
    }



}
