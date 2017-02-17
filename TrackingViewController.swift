//
//  TrackingViewController.swift
//  Stetho
//
//  Created by HW-Anil on 12/23/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit
import GoogleMaps

class TrackingViewController: UIViewController , serverTaskComplete {
    // MARK: variableDecelration
    
    let marker = GMSMarker()
    let arrLocation = NSMutableArray()
    var mapView: GMSMapView!
    var camera: GMSCameraPosition!
    var count = 0
    var orderId = ""
    var bottomView = UIView()
    var orderTrakingView = UIView()
    let darkGray = UIColor (red: (91.0/255.0), green: (91.0/255.0), blue: (91.0/255.0), alpha: 1)
    let lightGray = UIColor (red: (137.0/255.0), green: (137.0/255.0), blue: (137.0/255.0), alpha: 1)
    var trackPhleboDetailsArray : NSArray!
    var phleboStatusArray : NSArray!
    var activityIndicator: ProgressViewController?
    var phleboLocationArray : NSArray!
    var sourceLocation : CLLocation! = nil
    var destinationLocation : CLLocation! = nil
    var phleboMobileNo  = ""
    var orderStatus = 2
    var phleboId = ""
    var timerTrackPhleboLocation : Timer!
    var timerGetPhlebo_CustomerDist : Timer!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "TRACK"
     
         timerTrackPhleboLocation = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.trackPhleboLocation), userInfo: nil, repeats: true)
        print(timerTrackPhleboLocation)
        
         timerGetPhlebo_CustomerDist = Timer.scheduledTimer(timeInterval: 180, target: self, selector: #selector(self.getDistanseBetweenPhleboAndCustomer), userInfo: nil, repeats: true)
        print(timerGetPhlebo_CustomerDist)
        
        self.addRightBarButtonOnNavigation()
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        self.view.addSubview(activityIndicator!)
        activityIndicator?.start()

        self.getPhleboDetails()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        timerTrackPhleboLocation.invalidate()
        timerGetPhlebo_CustomerDist.invalidate()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - addMenuButton
    func addRightBarButtonOnNavigation()  {
        let callBarButton = UIBarButtonItem(image: UIImage(named: "phlebo_call_icon.png"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(self.didTapCallBarButton(_:)))
        self.navigationItem.rightBarButtonItem = callBarButton
        
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack
    }

    // MARK: - loadMapView
    func loadMapView() {
       
        
        
        let phlebo_lat = ((trackPhleboDetailsArray[0] as AnyObject).value(forKey: "phlebolat") as AnyObject).doubleValue
        let phlebo_long = ((trackPhleboDetailsArray[0] as AnyObject).value(forKey: "phlebolong") as AnyObject).doubleValue
        let dist_lat = ((trackPhleboDetailsArray[0] as AnyObject).value(forKey: "lat") as AnyObject).doubleValue
        let dist_long = ((trackPhleboDetailsArray[0] as AnyObject).value(forKey: "long") as AnyObject).doubleValue
        
        sourceLocation = CLLocation(latitude: phlebo_lat!, longitude: phlebo_long!)
        destinationLocation = CLLocation(latitude: dist_lat!, longitude: dist_long!)
        self.getDistanseBetweenPhleboAndCustomer()
        
        camera = GMSCameraPosition.camera(withLatitude: phlebo_lat!, longitude: phlebo_long!, zoom: 10.0)
        
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        view = mapView
        
        marker.position = CLLocationCoordinate2D(latitude: phlebo_lat!, longitude: phlebo_long!)
        marker.title = "PHLEBO"
        marker.snippet = "LOCATION"
        marker.map = mapView
        self.marker.icon = UIImage(named: "bike.png")
      //  marker.icon = UIImage(named: "bike.png")
    
        // Creates a Destnation marker in the center of the map.
        let marker2 = GMSMarker()
        marker2.position =  CLLocationCoordinate2D(latitude: dist_lat!, longitude: dist_long!)
        marker2.title = "MY"
        marker2.snippet = "LOCATION"
        marker2.map = mapView
        
//       let path = GMSMutablePath()
//       path.addCoordinate(CLLocationCoordinate2DMake(28.4089, 77.3178))
//       path.addCoordinate(CLLocationCoordinate2DMake(phlebo_lat!, phlebo_long!))
//       let bounds = GMSCoordinateBounds(path: path)
//       mapView!.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds, withPadding: 0.0))
      // mapView.frame = CGRectMake(0, 0, self.view.frame.width, 300)
        
    }
    // MARK: - updateCurrentLocation
    
    func updatePhleboLocation(_ locaitonData : NSArray)  {
        let dict = locaitonData[0] as! NSDictionary
        let lat = (dict.value(forKey: "lat") as AnyObject).doubleValue
        let long = (dict.value(forKey: "long") as AnyObject).doubleValue
        
        let latitude = lat
        let longitude = long
        sourceLocation = CLLocation(latitude: latitude!, longitude: longitude!)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(4.0)
        self.marker.position = CLLocationCoordinate2DMake(latitude!, longitude!)
        self.camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 10.0)
        self.mapView.animate(to: self.camera)
        CATransaction.commit()
        self.marker.icon = UIImage(named: "bike.png")
        
    }

    // MARK: - createSubLayout
    
    func createPhleboDetailsView(_ phleboDetailsArray : NSArray)  {
       
        self.loadMapView()
        phleboId = ((phleboDetailsArray[0] as AnyObject).value(forKey: "phleboId")) as! String
        print(phleboId)
        
        var yPos : CGFloat = 30;
        
        bottomView = UIView.init(frame: CGRect(x: 10, y: (UIScreen.main.bounds.height) - 200, width: UIScreen.main.bounds.width - 20, height: 190))
        bottomView.backgroundColor = UIColor.white
        bottomView.layer.cornerRadius = 4
        self.view.addSubview(bottomView)
        
        let btnOpen = BaseUIController().AButtonFrame(CGRect(x: bottomView.frame.width - 60, y: 00, width: 60, height: 30), withButtonTital: "")as! UIButton
        //btnOpen.backgroundColor = UIColor.yellowColor()
       // btnOpen.imageEdgeInsets = UIEdgeInsetsMake(12, 30, 12, 5)
        btnOpen.imageEdgeInsets = UIEdgeInsetsMake(6, 30, 7, 10)
        
        btnOpen.setImage(UIImage(named: "expand.png"), for: UIControlState())
        btnOpen.addTarget(self, action: #selector(self.btnOpenOnClick), for: .touchUpInside)
        bottomView.addSubview(btnOpen)
        
        
        let phleboImageView  = BaseUIController().AImageViewFrame(CGRect(x: (UIScreen.main.bounds.width)/2 - 30, y: (UIScreen.main.bounds.height) - 230, width: 60, height: 60), withImageName: "phlebo_icon_2.png")as! UIImageView
        self.view.addSubview(phleboImageView)
        
        let lblText = BaseUIController().ALabelFrame(CGRect(x: 10, y: yPos, width: bottomView.frame.width - 20 , height: 60), withString: "MR. Maninder Tyagi has been assigned for you to pick up the sample.")as! UILabel
        lblText.font = UIFont().regularMediumFont
        lblText.textAlignment = .center
        lblText.textColor = darkGray
        lblText.text = String(format: "Mr. %@ has been assigned for you to pick up the sample.",((phleboDetailsArray[0] as AnyObject).value(forKey: "u_name") as! String))
        bottomView.addSubview(lblText)
        yPos += 60 + 30
        
        let lblLine = BaseUIController().ALabelFrame(CGRect(x: 0, y: yPos, width: bottomView.frame.width, height: 1), withString: "")as! UILabel
        lblLine.backgroundColor = lightGray
        bottomView.addSubview(lblLine)
        yPos -= 20
        

        
        let btnNeedHelp = BaseUIController().AButtonFrame(CGRect(x: (bottomView.frame.width)/2 - 50, y: yPos, width: 100, height: 35), withButtonTital: "NEED HELP?")as! UIButton
        btnNeedHelp.layer.cornerRadius = 4
        btnNeedHelp.layer.borderWidth = 1
        btnNeedHelp.titleLabel?.font = UIFont().regularMediumFont
        btnNeedHelp.backgroundColor = UIColor.white
        btnNeedHelp.setTitleColor(KRED_COLOR, for: UIControlState())
        btnNeedHelp.layer.borderColor = UIColor.gray.cgColor
        btnNeedHelp.addTarget(self, action: #selector(self.btnNeedHeapOnclick), for: .touchUpInside)
        bottomView.addSubview(btnNeedHelp)
        
        
        yPos += 50
        
        let lblAmount = BaseUIController().ALabelFrame(CGRect(x: 0, y: yPos, width: bottomView.frame.width, height: 30), withString: "")as! UILabel
        
        let payableAmount = "TOTAL PAYBLE AMOUNT : Rs." + ((phleboDetailsArray[0] as AnyObject).value(forKey: "o_net_payable")as! String)
        print(payableAmount)
        phleboMobileNo = (phleboDetailsArray[0] as AnyObject).value(forKey: "mobileno")as! String
        
        lblAmount.font = UIFont().regularMediumFont
        lblAmount.text = payableAmount
        lblAmount.textColor = KRED_COLOR
        lblAmount.textAlignment = .center
        bottomView.addSubview(lblAmount)
        
        // set multiple color in Label
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: payableAmount, attributes: [NSFontAttributeName:UIFont().regularMediumFont])
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: lightGray, range: NSRange(location:0,length:21))
        lblAmount.attributedText = myMutableString

    }
    
    
    func createOrderTrackingView()  {
        
        
        orderTrakingView = UIView.init(frame: CGRect(x: 10, y: (UIScreen.main.bounds.height) - 400, width: UIScreen.main.bounds.width - 20, height: 390))
        orderTrakingView.backgroundColor = UIColor.white
        orderTrakingView.layer.cornerRadius = 4
        self.view.addSubview(orderTrakingView)
        
        let btnclose = BaseUIController().AButtonFrame(CGRect(x: orderTrakingView.frame.width - 70, y: 5, width: 60, height: 30), withButtonTital: "")as! UIButton
        btnclose.imageEdgeInsets = UIEdgeInsetsMake(6, 35, 7, 5)
       
        btnclose.setImage(UIImage(named: "closed.png"), for: UIControlState())
        btnclose.addTarget(self, action: #selector(self.btnCloseOnClick), for: .touchUpInside)
        orderTrakingView.addSubview(btnclose)
        
        
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 30, width: (UIScreen.main.bounds.width) - 20 , height: 250))
       // scrollView.backgroundColor = UIColor.yellowColor()
        orderTrakingView.addSubview(scrollView)
        
       var yPos : CGFloat = 10
        
        
        let heading = ["Order Booked" , "Order Confirmed","Phlebo on his way to your place","Phlebotomist Reached"]
        let subHeading = ["1 : 31 PM" , "Your order has been confirmed. Our phlebotomist executive will be assigned shortly.","Live tracking",""]
        let redTrackingOrderIcon = ["red_orderbooked_icon.png" , "red_orderconfirmed.png","red_phlebo_tracking.png","red_phlebo_reached_icon.png"]
        let grayTrackingOrederIcon = ["gray_orderbooked_icon.png","gray_orderconfirmed.png","gray_phlebo_tracking.png","gray_phlebo_reached_icon.png"]
        
        for i in 0..<4 {

            if i < 3 {
                
                var lblRightSideSepratorLine = UILabel()
                lblRightSideSepratorLine = BaseUIController().ALabelFrame(CGRect(x: 27, y: yPos + 28, width: 1, height: 40), withString: "")as! UILabel
                lblRightSideSepratorLine.backgroundColor = lightGray
                scrollView.addSubview(lblRightSideSepratorLine)
            }
            

            
            let imageView = BaseUIController().AImageViewFrame(CGRect(x: 15, y: yPos, width: 25, height: 25), withImageName: "red_orderconfirmed.png")as! UIImageView
            scrollView.addSubview(imageView)

            let lblTrackTital = BaseUIController().ALabelFrame(CGRect(x: 50, y: yPos, width: orderTrakingView.frame.width - 60, height: 20), withString: "HEALTH MANAGER")as! UILabel
            lblTrackTital.font = UIFont().regularMediumFont
            lblTrackTital.textColor = darkGray
            scrollView.addSubview(lblTrackTital)
            
            yPos += 20
            
            let lblTrackSubTital = BaseUIController().ALabelFrame(CGRect(x: 50, y: yPos, width: orderTrakingView.frame.width - 60, height: 60), withString: "Your health manager is Gaurav Sharma. you can reach him at 9810981083")as! UILabel
            lblTrackSubTital.font = UIFont().mediumFont
            lblTrackSubTital.textColor = lightGray
            scrollView.addSubview(lblTrackSubTital)
//            //set text on lable
            lblTrackTital.text = heading[i]
            lblTrackSubTital.text = subHeading[i]
            lblTrackSubTital.sizeToFit()
            if (i == 0) {
                lblTrackSubTital.text = (trackPhleboDetailsArray[0] as AnyObject).value(forKey: "o_time") as? String
            }else if(i == 1){
            
            }else if(i == 2){
            
            }else if (i == 3){
            
            }
            
            
            if i == 1 {
                yPos += 55
            }else{
                yPos += 50
            
            }
            
            // set tarcking status
           // let  status = phleboStatusArray[0].valueForKey("o_status")
            
            if i == orderStatus {
                imageView.image = UIImage(named: redTrackingOrderIcon[i])
                lblTrackTital.textColor = KRED_COLOR
                
            }else{
                imageView.image = UIImage(named: grayTrackingOrederIcon[i])
                lblTrackTital.textColor = darkGray
               
            }
            
           
            
        }
        // yPos += scrollView.frame.height + 10 // 110
        
        yPos += 30
        
        
        let lblLine = BaseUIController().ALabelFrame(CGRect(x: 0, y: yPos, width: orderTrakingView.frame.width, height: 1), withString: "")as! UILabel
        lblLine.backgroundColor = lightGray
        orderTrakingView.addSubview(lblLine)
        yPos -= 20
        
        let btnNeedHelp = BaseUIController().AButtonFrame(CGRect(x: (orderTrakingView.frame.width)/2 - 50, y: yPos, width: 100, height: 35), withButtonTital: "NEED HELP?")as! UIButton
        btnNeedHelp.layer.cornerRadius = 4
        btnNeedHelp.layer.borderWidth = 1
        btnNeedHelp.titleLabel?.font = UIFont().regularMediumFont
        btnNeedHelp.backgroundColor = UIColor.white
        btnNeedHelp.layer.borderColor = lightGray.cgColor
        btnNeedHelp.setTitleColor(KRED_COLOR, for: UIControlState())
        btnNeedHelp.addTarget(self, action: #selector(self.btnNeedHeapOnclick), for: .touchUpInside)
        orderTrakingView.addSubview(btnNeedHelp)
        
        
        yPos += 50
        
        let lblAmount = BaseUIController().ALabelFrame(CGRect(x: 0, y: yPos, width: orderTrakingView.frame.width, height: 30), withString: "")as! UILabel
        lblAmount.font = UIFont().regularMediumFont
        let payableAmount = (trackPhleboDetailsArray[0] as AnyObject).value(forKey: "o_net_payable")as! String
        lblAmount.text = "TOTAL PAYBLE AMOUNT : Rs." + payableAmount
        lblAmount.textAlignment = .center
        lblAmount.textColor = KRED_COLOR
        orderTrakingView.addSubview(lblAmount)
        
        // set multiple color in Label
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: String(format: "TOTAL PAYBLE AMOUNT : Rs.%@", String(payableAmount)), attributes: [NSFontAttributeName:UIFont().regularMediumFont])
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: lightGray, range: NSRange(location:0,length:21))
        lblAmount.attributedText = myMutableString

        
        
    }
    
    func getDistanseBetweenPhleboAndCustomer() {
       
        
        let distance = self.distanceBetweenTwoLocations(sourceLocation, destination: destinationLocation)
        if (distance <= 0.1) {
            
             self.present(BaseUIController().showAlertView("Phlebo arrived at your Location."), animated: true, completion: nil)
            timerTrackPhleboLocation.invalidate()
            timerGetPhlebo_CustomerDist.invalidate()
        }
        
    }
    
    // MARK: callWebServices
    
    func getPhleboStatus()  {
        
        if Reachability.isConnectedToNetwork() == true {
            self.activityIndicator?.start()
            if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
               // let order_Id = AESEncryptionDecryption().EncryptAstring("76413")
                
                let allParameters = ["orderId": orderId]
                ServerConnectivity().callWebservice(allParameters, resulttagname: "GetOrderStatusResult" ,methodname: "GetOrderStatus", className: self)
            }
            
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }

    
    func getPhleboDetails()  {
        
        if Reachability.isConnectedToNetwork() == true {
             self.activityIndicator?.start()
            
            if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
              
                print(orderId)
                
              //  let order_Id = AESEncryptionDecryption().EncryptAstring("76413")
                
                let allParameters = ["orderId":orderId]
                ServerConnectivity().callWebservice(allParameters, resulttagname: "TrackPhleboResult" ,methodname: "TrackPhlebo", className: self)
            }
            
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }

    func trackPhleboLocation()  {
       
            if Reachability.isConnectedToNetwork() == true {
                
                if (UserDefaults.standard.value(forKey: "loginCustomerId") != nil){
                    let p_Id = phleboId
                    
                    let allParameters = ["phleboId":p_Id]
                    ServerConnectivity().callWebservice(allParameters, resulttagname: "GetPhleboLocationResult" ,methodname: "GetPhleboLocation", className: self)
                }
                
            }else{
                 self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
            }
    }
    
    //MARK: - getServerResponse
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
       
        // print(methodName)
        // print(allResponse)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if allResponse .isEqual("error") || allResponse.isEqual("Something went wrong. Please try again.") || allResponse .isEqual("")  {
                    
                 //   self.presentViewController(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }else{
                    if(methodName == "GetPhleboLocation"){
                         self.phleboLocationArray = allResponse as! NSArray
                        self.updatePhleboLocation(self.phleboLocationArray)
                    }else if (methodName == "TrackPhlebo"){
                        self.trackPhleboDetailsArray = allResponse as! NSArray
                        self.orderTrakingView.removeFromSuperview()
                        self.createPhleboDetailsView(self.trackPhleboDetailsArray)
                    
                    }else if(methodName == "GetOrderStatus"){
                        
                        self.phleboStatusArray = allResponse as! NSArray
//                        self.bottomView.removeFromSuperview()
//                        self.createOrderTrackingView()
                        
                    }
                }
            });
        });
    }
    
    
    func distanceBetweenTwoLocations(_ source:CLLocation,destination:CLLocation) -> Double{
        
        let distanceMeters = source.distance(from: destination)
        print(distanceMeters)
        let distanceKM = distanceMeters / 1000
        let roundedTwoDigit = distanceKM.roundedTwoDigit
        print(roundedTwoDigit)
        return roundedTwoDigit
    }
    
    // MARK: - buttonOnClick
    func btnOpenOnClick()  {
        bottomView.removeFromSuperview()
        self.createOrderTrackingView()
       // self.getPhleboStatus()
    }
    
    func btnCloseOnClick()  {
        orderTrakingView.removeFromSuperview()
        self.createPhleboDetailsView(trackPhleboDetailsArray)
    }
    
    func didTapCallBarButton(_ sender: AnyObject) {
        //call support
        let phone = "tel://" + phleboMobileNo
        let url:URL = URL(string:phone)!
        UIApplication.shared.openURL(url)
    }
    func barButtonBackClick(_ barButton : UIBarButtonItem)  {
        
        self.navigationController?.popViewController(animated: true)
    }
    func btnNeedHeapOnclick()  {
        //call support
        let phone = "tel://" + phleboMobileNo
        let url:URL = URL(string:phone)!
        UIApplication.shared.openURL(url)
        
    }

    


}

extension Double{
    
     var roundedTwoDigit:Double {
//        return Double(round(100*self)/100)
        return (self * 100).rounded() / 100

    }
}
