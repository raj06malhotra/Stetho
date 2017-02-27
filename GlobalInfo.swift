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
    private var paymentNavigation: UINavigationController?
    private var selectedTest: NSMutableArray?
    static let sharedInfo = GlobalInfo()
    var dateFormatter : DateFormatter!
    var todayDateString: String!
    
    private override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        let date = Date()
        todayDateString = dateFormatter.string(from: date)
    }
    
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
    
    func getPhotoSelectionAlertSheet() -> UIAlertController{
        let alertSheet = UIAlertController(title: KCHANGEPHOTO, message: nil, preferredStyle: .actionSheet)
        alertSheet.view.tintColor = KRED_COLOR
        return alertSheet
    }
    
    func setPaymentOptionsNavigation(navController: UINavigationController){
        paymentNavigation = navController
    }
    
    func getPaymentNavigation() -> UINavigationController{
        return paymentNavigation!
    }
    
    func setSelectedTest(data: NSMutableArray?){
        selectedTest = data
    }
    
    func getSelectedTest() -> NSMutableArray?{
        return selectedTest
    }
    
     func isPushEnabled() -> Bool {
        let rnTypes = UIApplication.shared.isRegisteredForRemoteNotifications
        return rnTypes
    }
    
     func isNeedToShowPushAlert() -> Bool{
        if !isPushEnabled() && AppDelegate.getAppDelegate().isComingfromLaunching {
            if let _ = UserDefaults.standard.object(forKey: KALERTDATE){
                if UserDefaults.standard.string(forKey: KALERTDATE) == todayDateString{
                    return false
                }else{
                    UserDefaults.standard.set(todayDateString, forKey: KALERTDATE)
                    return true
                }
            }else{
                //Coming very first time
                UserDefaults.standard.set(todayDateString, forKey: KALERTDATE)
                return true
            }
        }
        return false
    }
    
    func getTodayDateString() -> String {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        let date = Date()
        return dateFormatter.string(from: date)
    }
}
