//
//  PackgeOrederInfo.swift
//  Health
//
//  Created by HW-Anil on 8/4/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class PackgeOrederInfo: NSObject {
    var orderId: String = String()
    var packageId: String = String()
    var packageName: String = String()
    var packagePrice: String = String()
    var packageType: String = String()
    
    // for bar code scanning 
   var barCode_couponCode = String()
   var barCode_couponMinAmount = String()
   var barCode_couponPackageType = String()
   var barCode_couponType = String()
   var barCode_coupondisPercent = String()
    
}
