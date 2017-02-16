//
//  CustomDelegate.swift
//  Health
//
//  Created by HW-Anil on 7/18/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

@objc protocol  CustomDelegate {
    
    @objc optional func filterData(_ memberId : String)
    @objc optional func btnAddNewOnClick()             //   btnAddNewOnClick
    
     @objc optional  func btnShareOnClick()
    @objc optional    func btnDeleteOnClick()
    @objc optional func reloadLocalDataAferbackfFromView()
    @objc optional func dissableTapSegmentController(_ searchStatus : String)

}
