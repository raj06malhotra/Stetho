//
//  CameraViewController.swift
//  Health
//
//  Created by HW-Anil on 9/1/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController ,UIImagePickerControllerDelegate,
UINavigationControllerDelegate , ELCImagePickerControllerDelegate , UICollectionViewDelegate, UICollectionViewDataSource {
     //MARK: VariableDeclaration
    let imageCartView = UIView()
    var imgView = UIImageView()
   // let imagePicker = UIImagePickerController()
    var isComingFrom = ""
    var arrImages = NSMutableArray()
    var yPos : CGFloat = 5
    var btnDone = UIButton()
    var btnTakePhoto = UIButton()
    var btnGallery = UIButton()
    var previewView =  UIView()
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    let elcPicker = ELCImagePickerController(imagePicker: ())
    var collectionView: UICollectionView!
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    var selectedTag = 0   // (report = 0 , Prescription = 1 , Invoice = 2 , DietChart = 4)
    
    //MARK: viewLifeCycleMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        //Create a image cart on left side on camera view
        arrImages = NSMutableArray()
      //  self.openCamera()
        previewView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(previewView)
        self.createALayout()
        self.createImageCart()
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //translucent issue from home view and report view
        if isComingFrom == "reportView" {
            
            self.navigationController?.navigationBar.isTranslucent = true
        }
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                previewView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = previewView.bounds
    }
    override func viewWillDisappear(_ animated: Bool) {
        if isComingFrom == "reportView" {
            self.navigationController?.navigationBar.isTranslucent = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: ELCImagePickerControllerDelegate
    
    func elcImagePickerController(_ picker: ELCImagePickerController!, didFinishPickingMediaWithInfo info: [Any]!) {

       arrImages.removeAllObjects()
        for any in info {
            let dict = any as! NSMutableDictionary
            let image = dict.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
            arrImages.add(image)
        }
        let addRecordsVC = AddRecordsViewController()
        addRecordsVC.arrTotalImages = arrImages
        addRecordsVC.isComingFrom = isComingFrom
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.pushViewController(addRecordsVC, animated: true)
        self.dismiss(animated: true, completion: nil)
        elcPicker?.cancelImagePicker()
    }
    
    func elcImagePickerControllerDidCancel(_ picker: ELCImagePickerController!){
        self.dismiss(animated: true, completion: nil)
    }
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            if #available(iOS 9.0, *) {
                collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            } else {
                // Fallback on earlier versions
            }
        case UIGestureRecognizerState.changed:
            if #available(iOS 9.0, *) {
                collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            } else {
                // Fallback on earlier versions
            }
        case UIGestureRecognizerState.ended:
            if #available(iOS 9.0, *) {
                collectionView.endInteractiveMovement()
            } else {
                // Fallback on earlier versions
            }
        default:
            if #available(iOS 9.0, *) {
                collectionView.cancelInteractiveMovement()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    //MARK: CollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        imgView = BaseUIController().AImageViewFrame(CGRect(x: 0, y: 0, width: 50, height: 50), withImageName: "")as! UIImageView
        imgView.isUserInteractionEnabled = true
        imgView.image = arrImages[(indexPath as NSIndexPath).row]as? UIImage
        cell.addSubview(imgView)
        let label = BaseUIController().ALabelFrame(CGRect(x: 0, y: 30, width: 20, height: 20), withString: String((indexPath as NSIndexPath).row + 1))as! UILabel
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.red
        cell.addSubview(label)
        
        return cell
    }
   func collectionView(_ collectionView: UICollectionView,
                                 moveItemAt sourceIndexPath: IndexPath,
                                                     to destinationIndexPath: IndexPath) {
    
    let sImages = arrImages[(sourceIndexPath as NSIndexPath).item]
    
    arrImages.replaceObject(at: (sourceIndexPath as NSIndexPath).item, with: arrImages[(destinationIndexPath as NSIndexPath).item])
    arrImages.replaceObject(at: (destinationIndexPath as NSIndexPath).item, with: sImages)
    collectionView.reloadData()
    
        // move your data order
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if isComingFrom == "reportView" {
            self.navigationController?.navigationBar.isTranslucent = false
        }else{
             self.navigationController?.navigationBar.isTranslucent = true
        }
       
        let imageSliderVC = ImageSliderViewController()
        imageSliderVC.arrImages = arrImages
        imageSliderVC.selectedCount = (indexPath as NSIndexPath).row
        self.navigationController?.pushViewController(imageSliderVC, animated: true)
    }

    //MARK: createALayoutDesign
    func createALayout()  {
        
        
        btnDone = BaseUIController().AButtonFrame(CGRect(x: 0, y: 0, width: 60, height: 44), withButtonTital: "Done")as! UIButton
        btnDone.setTitleColor(UIColor.red, for: UIControlState())
        btnDone.addTarget(self, action: #selector(self.btnDoneOnClick(_:)), for: .touchUpInside)
        self.view.addSubview(btnDone)
        btnDone.isHidden = true
        let rightBarButton = UIBarButtonItem(customView: btnDone)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        btnTakePhoto = BaseUIController().AButtonFrame(CGRect(x: (self.view.frame.width)/2 - 30, y: self.view.frame.height - 70, width: 60, height: 60), withButtonTital: "")as! UIButton
        btnTakePhoto.setImage(UIImage(named: "takepicture.png"), for: UIControlState())
       // btnTakePhoto.setTitleColor(UIColor.blackColor(), forState: .Normal)
        btnTakePhoto.addTarget(self, action: #selector(CameraViewController.btnTakePhotoOnClick(_:)), for: .touchUpInside)
        self.view.addSubview(btnTakePhoto)
        
        btnGallery = BaseUIController().AButtonFrame(CGRect(x: 10 , y: self.view.frame.height - 50, width: 100, height: 30), withButtonTital: "")as! UIButton
        btnGallery.setImage(UIImage(named: "gallery.png"), for: UIControlState())
        btnGallery.addTarget(self, action: #selector(self.btnGalleryOnClick(_:)), for: .touchUpInside)
        self.view.addSubview(btnGallery)

    }
    func createImageCart()  {
        imageCartView.removeFromSuperview()
        imageCartView.frame = CGRect(x: self.view.frame.width - 120 , y: 70, width: 115, height: 300)
        // 50 X 2 + 5 space X 3 + 5 backspace = 120
        // 50 x 5 + 5 *6 = 280
        // 50 * 2 + 5 * 3 = 115 (5 space , 50 width)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        collectionView = UICollectionView(frame: CGRect(x: 0 , y: 0, width: 115, height: 300), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.clear
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(CameraViewController.handleLongGesture(_:)))
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        imageCartView.addSubview(collectionView)
        self.view.addSubview(imageCartView)
        
        
        
      /*  var xPos :CGFloat = 60
        self.view.addSubview(imageCartView)
        imgView.removeFromSuperview()
        for i in 0..<arrImages.count {
            //imgView = UIImageView.init(frame: CGRectMake(xPos, yPos, 50, 50))
            imgView = BaseUIController().AImageViewFrame(CGRectMake(xPos, yPos, 50, 50), withImageName: "")as! UIImageView
            imgView.userInteractionEnabled = true
            imageCartView.addSubview(imgView)
            imgView.image = arrImages[i]as? UIImage
            imgView.tag = 5001 + i
            // Add tap Gesture on ImageViw
            let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.didTapOnPickedImageView(_:)))
            tapped.numberOfTapsRequired = 1
            imgView.addGestureRecognizer(tapped)
            
            let label = BaseUIController().ALabelFrame(CGRectMake(0, 30, 20, 20), withString: String(i+1))as! UILabel
            label.textColor = UIColor.whiteColor()
            label.backgroundColor = UIColor.redColor()
            imgView.addSubview(label)
            yPos += 55
            if i == 4 {
                xPos = 5
                yPos = 5
            }
        } */
        
        
    }

        //MARK: buttonOnClick

    func btnTakePhotoOnClick(_ button : UIButton)  {
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData as! CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    self.arrImages.add(image)
                    self.yPos = 5
                    self.btnDone.isHidden = false
                    if (self.arrImages.count == 7){
                        self.btnTakePhoto.isHidden = true
                    }
                        self.collectionView.reloadData()
                }
            })
        }
    }
    func btnGalleryOnClick(_ button : UIButton) {
        elcPicker?.maximumImagesCount = 7; //Set the maximum number of images to select to 100
        elcPicker?.returnsOriginalImage = true; //Only return the fullScreenImage, not the fullResolutionImage
        elcPicker?.returnsImage = true; //Return UIimage if YES. If NO, only return asset location information
        elcPicker?.onOrder = true; //For multiple image selection, display and return order of selected images
        // elcPicker.mediaTypes = [(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie]; //Supports image and movie types
        elcPicker?.imagePickerDelegate = self
        //  self.presentViewController:elcPicker animated:YES completion:nil;
        
        self.present(elcPicker!, animated: true) {
            
        }
    }
    func btnDoneOnClick(_ button : UIButton)  {
        let addRecordsVC = AddRecordsViewController()
        addRecordsVC.isComingFrom = isComingFrom
        addRecordsVC.selectedTag = self.selectedTag
        addRecordsVC.arrTotalImages = arrImages
        self.navigationController?.pushViewController(addRecordsVC, animated: true)
        
        
    }
    func didTapOnPickedImageView(_ gesture : UITapGestureRecognizer)  {
       
        let imageView = gesture.view as! UIImageView
        
        let imageSliderVC = ImageSliderViewController()
        imageSliderVC.arrImages = arrImages
        imageSliderVC.selectedCount = imageView.tag - 5001 
        self.navigationController?.pushViewController(imageSliderVC, animated: true)
    }
    
    func barButtonBackClick(_ barButton : UIBarButtonItem)  {
        
        let _ = self.navigationController?.popViewController(animated: true)
    
    }
}



