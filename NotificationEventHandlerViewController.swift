//
//  NotificationEventHandlerViewController.swift
//  Stetho
//
//  Created by HW-Anil on 11/4/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class NotificationEventHandlerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        DispatchQueue.main.async(execute: {
            let homeVC = HomeViewController()
            let drawerViewController = DrawerViewController()
            let drawerController     = KYDrawerController()
            self.view.window?.backgroundColor = UIColor.white
            drawerController.mainViewController = UINavigationController(
                rootViewController: homeVC
            )
            drawerController.drawerViewController = drawerViewController
            /* Customize */
            drawerController.drawerDirection = .left
            drawerController.drawerWidth     = (UIScreen.main.bounds.width-50)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
            appDelegate.window!.rootViewController = drawerController
            appDelegate.window!.makeKeyAndVisible()
            
        });

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
