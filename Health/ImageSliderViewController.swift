//
//  ImageSliderViewController.swift
//  Health
//
//  Created by HW-Anil on 9/3/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class ImageSliderViewController: UIViewController {
    //MARK: VariableDeclaration
    var imageSlider = UIImageView()
    var arrImages = NSMutableArray()
    var selectedCount = Int()
    var lblImageCount = UILabel()
    var scrollView = UIScrollView()
    
    
    //MARK: viewLifeCycleMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        // Do any additional setup after loading the view.
        scrollView.frame = self.view.bounds
        self.view.addSubview(scrollView)
        imageSlider.frame = self.view.bounds
        imageSlider.isUserInteractionEnabled = true
        imageSlider.image = arrImages[selectedCount] as? UIImage
        scrollView.addSubview(imageSlider)
        
        lblImageCount = BaseUIController().ALabelFrame(CGRect(x: self.view.frame.width -  100 , y: 70, width: 80, height: 21), withString: "")as! UILabel
        lblImageCount.textAlignment = .center
        lblImageCount.text = String(format: "%@/%@", String(selectedCount + 1), String(arrImages.count))
        lblImageCount.textColor = UIColor.white
        self.view.addSubview(lblImageCount)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action:#selector(self.rightGestureScroll(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action:#selector(self.leftGestureScroll(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let doubleTap = UITapGestureRecognizer(target: self, action:#selector(self.doubleTapgestureOnClick(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //
    //MARK: gestureRecognizer
    func leftGestureScroll(_ gesture:UITapGestureRecognizer)  {
        
        if selectedCount < arrImages.count - 1 {
            selectedCount = selectedCount + 1
            imageSlider.image = arrImages[selectedCount]as? UIImage
            lblImageCount.text = String(format: "%@/%@", String(selectedCount + 1), String(arrImages.count))
        }
        
    }
    func rightGestureScroll(_ gesture:UITapGestureRecognizer)  {
        if selectedCount > 0 {
            selectedCount = selectedCount - 1
            imageSlider.image = arrImages[selectedCount]as? UIImage
            lblImageCount.text = String(format: "%@/%@", String(selectedCount + 1), String(arrImages.count))
        }
    }
    func doubleTapgestureOnClick(_ gestuer : UITapGestureRecognizer)  {
      
       // scrollView.contentSize = CGSizeMake(500, 600)
        
    }
}
