//
//  BarCodeViewController.swift
//  Stetho
//
//  Created by HW-Anil on 12/30/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
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


class BarCodeViewController : UIViewController , AVCaptureMetadataOutputObjectsDelegate ,serverTaskComplete {
    let session         : AVCaptureSession = AVCaptureSession()
    var previewLayer    : AVCaptureVideoPreviewLayer!
    var highlightView   : UIView = UIView()
    var activityIndicator : ProgressViewController?

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
            session.addInput(input)
            // moved the rest of the image capture into the do{} scope.
        } catch let error as NSError {
            print(error)
        }
        
        // If our input is not nil then add it to the session, otherwise we're kind of done!
        
        
        
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        session.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        
        // previewLayer = AVCaptureVideoPreviewLayer.layerWithSession(session) as AVCaptureVideoPreviewLayer
        
        //   previewLayer = AVCaptureVideoPreviewLayer.init(layer: session)
        previewLayer = AVCaptureVideoPreviewLayer.init(session: session)
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        
        // Start the scanner. You'll have to end it yourself later.
        session.startRunning()
      //  self.highlightView.frame = CGRectMake(10, (self.view.frame.width/2)-100, self.view.frame.width - 20, 200)
        
        // add progress on View
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        self.view.addSubview(activityIndicator!)
        
    }
    override func viewWillAppear(_ animated: Bool) {

        self.navigationController!.navigationBar.topItem!.title = "Back"
        self.title = "SCAN BARCODE"
    }

    
    // This is called when we find a known barcode type with the camera.
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        var highlightViewRect = CGRect(x: 10, y: 200, width: 300, height: 200) //CGRectZero
        
        var barCodeObject : AVMetadataObject!
        
        var detectionString : String!
        
        let barCodeTypes = [AVMetadataObjectTypeUPCECode,
                            AVMetadataObjectTypeCode39Code,
                            AVMetadataObjectTypeCode39Mod43Code,
                            AVMetadataObjectTypeEAN13Code,
                            AVMetadataObjectTypeEAN8Code,
                            AVMetadataObjectTypeCode93Code,
                            AVMetadataObjectTypeCode128Code,
                            AVMetadataObjectTypePDF417Code,
                            AVMetadataObjectTypeQRCode,
                            AVMetadataObjectTypeAztecCode
        ]
        
        
        // The scanner is capable of capturing multiple 2-dimensional barcodes in one scan.
        for metadata in metadataObjects {
            
            for barcodeType in barCodeTypes {
                
                if (metadata as AnyObject).type == barcodeType {
                    barCodeObject = self.previewLayer.transformedMetadataObject(for: metadata as! AVMetadataMachineReadableCodeObject)
                    
                    highlightViewRect = barCodeObject.bounds
                    
                    detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    
                    self.session.stopRunning()
                    break
                }
                
            }
        }
        
        print(detectionString)
        self.highlightView.frame = highlightViewRect
        self.view.bringSubview(toFront: self.highlightView)
        self.bookOrderByBarCode(detectionString)
        
    }
    
    func bookOrderByBarCode(_ barCode : String)  {
        if Reachability.isConnectedToNetwork() == true {
            activityIndicator?.start()
            
            let allParameters = ["barcode" : barCode ]
            ServerConnectivity().callWebservice(allParameters , resulttagname: "Get_packagedetailfrombarcodeResult" ,methodname: "Get_packagedetailfrombarcode", className: self)
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
                if allResponse is String &&  allResponse as! String == "error" {
                    self.present(BaseUIController().showAlertView("No Order"), animated: true, completion: nil)
                }else if (allResponse is String &&  allResponse as! String == ""){
                    
                    self.present(BaseUIController().showAlertView("Something went wrong. Please try again."), animated: true, completion: nil)
                }
                else{
                    self.pushOnCheckOutView(allResponse as! NSArray)
                
                }
            });
        });
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
