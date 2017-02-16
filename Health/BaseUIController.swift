//
//  BaseUIController.swift
//  Health
//
//  Created by HW-Anil on 6/22/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class BaseUIController: NSObject {
    
    let activityIndicator = UIActivityIndicatorView()

    internal  func ALabelFrame(_ frame : CGRect, withString : String) -> AnyObject {
    let label = UILabel(frame: frame)
    label.text = withString
    label.numberOfLines = 0
   
   // label.textAlignment = .Center
//  label.font = UIFont(name: label.font.fontName, size: 20)
    label.font = UIFont().mediumFont //label.font.fontWithSize(14)
    label.adjustsFontSizeToFitWidth = true
    return label
    }
    
    internal  func ATextFiedlFrame(_ frame : CGRect, withPlaceHolder : String) -> AnyObject {
        let textFiedl = UITextField(frame: frame)
        textFiedl.placeholder = withPlaceHolder
        textFiedl.textAlignment = .center
        textFiedl.font = UIFont().mediumFont
       
        return textFiedl
    }
   
    internal  func AButtonFrame(_ frame : CGRect, withButtonTital : String) -> AnyObject {
        let button = UIButton(frame: frame)
        button.setTitle(withButtonTital, for: UIControlState())
        button.setTitleColor(UIColor.black, for: UIControlState())
       // button.layer.borderWidth = 2
        //button.layer.borderColor = UIColor .redColor().CGColor
        
        return button
    }
    
    internal  func AImageViewFrame(_ frame : CGRect, withImageName : String) -> AnyObject {
        let imageView = UIImageView(frame: frame)
       
       // imageView.image = UIImage.animatedImageNamed(withImageName, duration: 0.5)
        imageView.image = UIImage(named: withImageName)
        
        return imageView
    }
    internal   func showActivityIndicatory(_ uiView: UIView) {
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 568.0);
        actInd.center = uiView.center
        // actInd.activityIndicatorViewStyle = UIColor .redColor()
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.gray
        uiView.addSubview(actInd)
        actInd.startAnimating()
    }
    internal func showAlertView(_ message: String) ->  UIAlertController {
    
    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
    
   // self.presentViewController(alert, animated: true, completion: nil)
        return alert
    }
    
       
    
    


}
