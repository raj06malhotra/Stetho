//
//  GlobalInfo.swift
//  Stetho
//
//  Created by HW-Anil on 1/31/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit

class GlobalInfo: NSObject {
    let dafaults = UserDefaults.standard
    static let sharedInfo = GlobalInfo()
    
    func setValueInDefault(_ value:AnyObject, forKey:String){
        dafaults.set(value, forKey:forKey)
    }
    
    func getValuefromDefault(_ forKey:String) -> AnyObject?{
        return dafaults.object(forKey: forKey) as AnyObject?
    }
    
    func phoneNumberValidation(_ value: String) -> Bool {
        let mobileNumberPattern: String = "[789][0-9]{9}"
        let mobileNumberPred: NSPredicate = NSPredicate(format: "SELF MATCHES %@", mobileNumberPattern)
        let matched: Bool = mobileNumberPred.evaluate(with: value)
        return matched
    }
    func getTitleView(title : String) -> UILabel {
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        lbl.text = title
        lbl.textColor = UIColor(red: 196/255.0, green: 35/255.0, blue: 24/255.0, alpha: 1)
        lbl.font = UIFont(name: KROBOTO_REGULAR, size: 16)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.backgroundColor = UIColor.clear
        return lbl
        
    }
}
