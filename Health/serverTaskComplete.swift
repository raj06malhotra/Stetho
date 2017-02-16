//
//  serverTaskComplete.swift
//  Health
//
//  Created by HW-Anil on 7/6/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

@objc protocol  serverTaskComplete {
    
    
    func getAllResponse(_ allResponse : AnyObject, methodName : String)

}
