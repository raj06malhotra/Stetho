//
//  CheckinBarcodeViewController.swift
//  Stetho
//
//  Created by HW-Anil on 2/2/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit
import AVFoundation

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

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class CheckinBarcodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate ,serverTaskComplete {
    var session         : AVCaptureSession? = AVCaptureSession()
    var previewLayer    : AVCaptureVideoPreviewLayer!
    var highlightView   : UIView = UIView()
    var activityIndicator : ProgressViewController?
    var barCode : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Allow the view to resize freely
        self.highlightView.autoresizingMask =   [UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
        
        // Select the color you want for the completed scan reticle
        self.highlightView.layer.borderColor = UIColor.green.cgColor
        self.highlightView.layer.borderWidth = 3
        
        // Add it to our controller's view as a subview.
        self.view.addSubview(self.highlightView)
        
        
        // For the sake of discussion this is the camera
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Create a nilable NSError to hand off to the next method.
        // Make sure to use the "var" keyword and not "let"
        let error : NSError? = nil
        
        
        // let input : AVCaptureDeviceInput? = AVCaptureDeviceInput.deviceInputWithDevice(device) as? AVCaptureDeviceInput
        let input : AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: device) as AVCaptureDeviceInput
            session!.addInput(input)
            // moved the rest of the image capture into the do{} scope.
        } catch let error as NSError {
            print(error)
        }
        
        // If our input is not nil then add it to the session, otherwise we're kind of done!
        
        
        
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        session!.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        
        // previewLayer = AVCaptureVideoPreviewLayer.layerWithSession(session) as AVCaptureVideoPreviewLayer
        
        //   previewLayer = AVCaptureVideoPreviewLayer.init(layer: session)
        previewLayer = AVCaptureVideoPreviewLayer.init(session: session)
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        
        // Start the scanner. You'll have to end it yourself later.
        session!.startRunning()
        //  self.highlightView.frame = CGRectMake(10, (self.view.frame.width/2)-100, self.view.frame.width - 20, 200)
        
        // add progress on View
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        // self.view.addSubview(activityIndicator!) Comment Progress
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController!.navigationBar.topItem!.title = "Back"
        self.title = "SCAN BARCODE"
    }
    
    
    // This is called when we find a known barcode type with the camera.
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        print("In Delegate method of avcrash")
        var highlightViewRect = CGRect(x: 10, y: 200, width: 300, height: 200) //CGRectZero
        
        var barCodeObject : AVMetadataObject!
        
        var detectionString = ""
     
        let barCodeTypes = [
                            AVMetadataObjectTypeCode39Code,
//                            AVMetadataObjectTypeCode39Mod43Code,
//                            AVMetadataObjectTypeEAN13Code,
//                            AVMetadataObjectTypeEAN8Code,
                            AVMetadataObjectTypeCode93Code,
                            AVMetadataObjectTypeCode128Code
//                            AVMetadataObjectTypePDF417Code,
//                            AVMetadataObjectTypeQRCode,
//                            AVMetadataObjectTypeAztecCode
        ]
        
        // The scanner is capable of capturing multiple 2-dimensional barcodes in one scan.
        for metadata in metadataObjects {
            print("metaData = %@", metadata.self)
            print("metaData = %@", metadata)
            
            if metadata is AVMetadataFaceObject{
                print("In if face objec")
                continue
            }
//            if (metadata as AnyObject).isKind(of: AVMetadataFaceObject.self) == true {
//                print("In if face objec")
//                continue
//            }

            for barcodeType in barCodeTypes {
                
                if (metadata as AnyObject).type == barcodeType {
                    barCodeObject = self.previewLayer.transformedMetadataObject(for: metadata as! AVMetadataMachineReadableCodeObject)
                    
                    highlightViewRect = barCodeObject.bounds
                    
                    detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    
                    self.session!.stopRunning()
                    self.session = nil
                    break
                }
                
            }
        }
        if detectionString.isEmpty == true{
            print("unable to capture bar code")
             self.session!.stopRunning()
             self.session!.startRunning()
            self.present(BaseUIController().showAlertView("Something went wrong, please try again."), animated: true, completion: nil)
            
        }
        
        print(detectionString)
        self.highlightView.frame = highlightViewRect
        self.view.bringSubview(toFront: self.highlightView)
        self.getCorporateDetailsbyBarcode(detectionString)
        
    }
    
    func getCorporateDetailsbyBarcode(_ barCode:String){
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            self.barCode = barCode
            let allParameters = ["barcode" : barCode]
            print(allParameters)
            ServerConnectivity().callWebservice(allParameters , resulttagname: "get_corporatedetailfrombarcodeResult" ,methodname: "get_corporatedetailfrombarcode", className: self)
        }else{
            self.present(BaseUIController().showAlertView("Please check the internet connection and try again."), animated: true, completion: nil)
        }
    }
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
        // print(allResponse)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if allResponse is String &&  (allResponse as! String == "0" || allResponse as! String == "error"){
                    self.present(BaseUIController().showAlertView("Something Went Wrong."), animated: true, completion: nil)
                }else if (allResponse is String &&  allResponse as! String == "2"){
                    self.present(BaseUIController().showAlertView(KERROR_RETRY), animated: true, completion: nil)
                }
                else{
                    
                    //self.pushOnCheckOutView(allResponse as! NSArray)
                    let isValid =  self.parseCorporateCheckinDetails(allResponse as! NSArray)
                    if isValid == true{
                        let viewController =  CorporateViewController()
                        viewController.isComingfromCheckinBarCode = true
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }else{
                        self.present(BaseUIController().showAlertView(KERROR_RETRY), animated: true, completion: nil)
                    }
                   
                    
                }
            });
        });
    }
    
    func parseCorporateCheckinDetails(_ responseArray : NSArray) -> Bool {
       // let companyInfo = CompanyDetailsInfo()
        let arrDepartment = NSMutableArray()
        for (index, _) in responseArray.enumerated() {
            let dictResp = responseArray[index] as! NSDictionary
            if index == 0 {
                if dictResp.object(forKey: "company_id") as! String == "0"{
                    //Wrong Bar code entered
                    self.present(BaseUIController().showAlertView("Please Enter right Barcode"), animated: true, completion: nil)
                    return false
                }
                UserDefaults.standard.setValue((responseArray[index] as AnyObject).object(forKey: "pkg_name") as! String, forKey: "PACK_NAME")
                UserDefaults.standard.setValue((responseArray[index] as! NSDictionary).object(forKey: "company_id"), forKey: "company_id")
                GlobalInfo.sharedInfo.setValueInDefault((dictResp.object(forKey: "company_name")) as AnyObject, forKey: KCOPERATE_NAME)
                GlobalInfo.sharedInfo.setValueInDefault(dictResp.object(forKey: "company_image") as AnyObject, forKey: KCOPERATE_URL)
                GlobalInfo.sharedInfo.setValueInDefault(barCode as AnyObject, forKey: KCHECKIN_CODE)
            }
            let dictDepartment = NSMutableDictionary()
            dictDepartment.setValue((responseArray[index] as AnyObject).value(forKey: "department_name")as! String, forKey: "departmentName")
            dictDepartment.setValue((responseArray[index] as AnyObject).value(forKey: "cwd_id")as! String, forKey: "department_id")
            arrDepartment.add(dictDepartment)
        }
        print(arrDepartment)
        UserDefaults.standard.setValue(arrDepartment, forKey: "department")
        return true
    }
    
    func pushOnCheckOutView(_ responseArray : NSArray) {
        
        let packgeOrderInfo = PackgeOrederInfo()
        packgeOrderInfo.orderId = UserDefaults.standard.value(forKey: "loginCustomerId") as! String
        packgeOrderInfo.packageId = (responseArray[0] as AnyObject).value(forKey: "packageId") as! String
        packgeOrderInfo.packageName = (responseArray[0] as AnyObject).value(forKey: "packageName") as! String
        packgeOrderInfo.packagePrice = (responseArray[0] as AnyObject).value(forKey: "packagePrice") as! String
        packgeOrderInfo.packageType = (responseArray[0] as AnyObject).value(forKey: "packageType") as! String
        packgeOrderInfo.barCode_couponCode = (responseArray[0] as AnyObject).value(forKey: "couponCode") as! String
        packgeOrderInfo.barCode_couponMinAmount = (responseArray[0] as AnyObject).value(forKey: "couponMinAmount") as! String
        packgeOrderInfo.barCode_couponPackageType = (responseArray[0] as AnyObject).value(forKey: "couponPackageType") as! String
        packgeOrderInfo.barCode_couponType = (responseArray[0] as AnyObject).value(forKey: "couponType") as! String
        packgeOrderInfo.barCode_coupondisPercent = (responseArray[0] as AnyObject).value(forKey: "couponValue") as! String
        
        let bookedPackageOrder = NSMutableArray()
        bookedPackageOrder.add(packgeOrderInfo)
        
        
        
        
        let checkOutVC = CheckOutViewController()
        
        let couponVlaue = packgeOrderInfo.barCode_coupondisPercent
        if couponVlaue != "0" {
            if (packgeOrderInfo.barCode_couponType == "A") {
                
                let minAmount = packgeOrderInfo.barCode_couponMinAmount
                if (Int(packgeOrderInfo.packagePrice) >= Int(minAmount)) {
                    checkOutVC.discountPercentage = Int(packgeOrderInfo.barCode_coupondisPercent)!
                    //                    self.isCouponCodeApply = true
                    //                    self.afterDiscoutTotalPrice = 0
                    //                    self.totalDiscout = 0
                    //                    self.scrollView.removeFromSuperview()
                    //                    self.createALayout()
                }else{
                    self.present(BaseUIController().showAlertView("Coupon not apply less then total amount of  " + minAmount), animated: true, completion: nil)
                }
            }else{
                checkOutVC.discountPercentage = Int(packgeOrderInfo.barCode_coupondisPercent)!
                checkOutVC.pkg_type = packgeOrderInfo.barCode_couponPackageType
                //                // pkg_type = "P"
                //                self.isCouponCodeApply = true
                //                self.afterDiscoutTotalPrice = 0
                //                self.totalDiscout = 0
                //                self.scrollView.removeFromSuperview()
                //                self.createALayout()
            }
        }else{
            self.present(BaseUIController().showAlertView("Coupon not vailid"), animated: true, completion: nil)
        }
        
        
        
        
        
        
        
        checkOutVC.packageIdFromBarCode = packgeOrderInfo.packageId
        checkOutVC.arrPackageOrderData = bookedPackageOrder
        checkOutVC.isCouponCodeApply = true
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController?.pushViewController(checkOutVC, animated: true)
        
    }
    
    
}
