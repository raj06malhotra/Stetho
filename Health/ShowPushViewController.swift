//
//  ShowPushViewController.swift
//  Stetho
//
//  Created by Administrator on 24/02/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit

class ShowPushViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        //"We'll only send alerts when there are Amazing Discounts, Great Health Offers, Useful Health Tips"
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enableBtnClicked(_ sender: AnyObject){
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func dontEnableBtnClicked(_ sender: AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
