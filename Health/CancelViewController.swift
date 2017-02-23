//
//  CancelViewController.swift
//  Stetho
//
//  Created by HW-Anil on 12/6/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class CancelViewController: UIViewController {
  var jsondict=NSMutableDictionary()  //Global variable	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(CancelViewController.ResponseNew(_:)), name: NSNotification.Name(rawValue: "JSON_NEW"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "JSON_DICT"), object: nil, userInfo: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //Add below method to get Transaction details
    func ResponseNew(_ message:Notification)
    {
        
        
        if message.name.rawValue == "JSON_NEW" {
            
            
            print("Response = \(message.object!)")
            jsondict = NSMutableDictionary(dictionary: message.object as! NSDictionary) //message.object as! NSMutableDictionary
        } } 


}
