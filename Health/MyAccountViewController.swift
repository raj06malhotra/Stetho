//
//  MyAccountViewController.swift
//  Health
//
//  Created by HW-Anil on 7/26/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class MyAccountViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    var tableView = UITableView()
    var arrMyAccountItemList = NSArray()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //MARK: - lifeCycleDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        FBEventClass.logEvent("My Account")
        arrMyAccountItemList = ["My Profile" , "Save Addresses","Terms & Condition", "Log out"]
        self.view.backgroundColor = UIColor.white//UIColor.init(red: (236.0/255.0), green: (236.0/255.0), blue: (236.0/255.0), alpha: 1)
        // add back butotn on Navigaiton
        let barButtonBack  = UIBarButtonItem(image: UIImage(named: "back_icon3.png"),style: .done,target: self, action: #selector(self.barButtonBackClick(_:)))
        self.navigationItem.leftBarButtonItem = barButtonBack;
        
        self.CreateALayout()
//        let menuBarButton = UIBarButtonItem(image: UIImage(named: "menu_icon.png"), landscapeImagePhone: nil, style: .Done, target: self, action: #selector(MyAccountViewController.didTapMenuBarButton(_:)))
//        self.navigationItem.leftBarButtonItem = menuBarButton
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "MY ACCOUNT"
        self.navigationController?.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
        
        // call google analytics for screen tracking
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.trackViewOnGoogleAnalytics("MyProfile Screen")
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
//    func didTapMenuBarButton(sender: AnyObject){
//        if let drawerController = navigationController?.parentViewController as? KYDrawerController {
//            drawerController.setDrawerState(.Opened, animated: true)
//        }
//        
//    }
    //MARK: - CreateLayout
    func CreateALayout()  {
        
        // create A tableView
        tableView = UITableView(frame:CGRect(x: 10, y: 10,width: (UIScreen.main.bounds.width) - 20, height: (UIScreen.main.bounds.height-184)))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
    }
     //MARK: - backButtonOnClicl
    func barButtonBackClick(_ barButton : UIBarButtonItem)  {
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    //MARK: - TableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (arrMyAccountItemList.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        let label = BaseUIController().ALabelFrame(CGRect(x: 20 , y: 0 , width: tableView.frame.width , height: 44), withString: (arrMyAccountItemList[(indexPath as NSIndexPath).section]as? String)!)as! UILabel
        label.font = UIFont(name: KROBOTO_LIGHT, size: 17)
        label.textAlignment = .left
        cell.addSubview(label)
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 4
        cell.layer.borderColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1).cgColor
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (indexPath as NSIndexPath).section == 0 {
            let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
            //var navController:UINavigationController = UINavigationController()
            let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
            homeTapSwipeVC.identifires = "MyAccount"
          //  navController = UINavigationController(rootViewController:homeTapSwipeVC)
            self.navigationController?.pushViewController(homeTapSwipeVC, animated: true)
            
        }else if ((indexPath as NSIndexPath).section == 1){
            let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
            let homeTapSwipeVC = storyboard1.instantiateViewController(withIdentifier: "HomeTabSwipeViewController") as! HomeTabSwipeViewController
            homeTapSwipeVC.currentSelectedTapIndex = 1
            homeTapSwipeVC.identifires = "MyAccount"
           
            self.navigationController?.pushViewController(homeTapSwipeVC, animated: true)
            
        }else if((indexPath as NSIndexPath).section == 2){
            let terms_condition = termsAndConditionViewController()
            self.navigationController?.pushViewController(terms_condition, animated: true)
            
        }else if((indexPath as NSIndexPath).section == 3){
            // stop all timer 
            FBEventClass.logEvent("Logout")
            for timer in appDelegate.timerArray {
                
                (timer as AnyObject).invalidate()
            }
            // remove all key from Dictionary
            for key in Array(UserDefaults.standard.dictionaryRepresentation().keys) {
                if (key != "device_token" ){
                    
                    print(key)
                    
                    
                    
                   UserDefaults.standard.removeObject(forKey: key)
                }else{
                
                   print(key)
                
                }
               
            }
            // app instruction view 
            UserDefaults.standard.set("viewd", forKey: "into_screen_viewed")
           
            let database = appDelegate.openDataBase()
            
            do {
                
                try database.executeUpdate("delete from RecordDetails", values: nil)
                try database.executeUpdate("delete from MyFamily", values: nil)
                try database.executeUpdate("delete from PickupAddress", values: nil)
                try database.executeUpdate("delete from Order_Package_Purchased", values: nil)
                try database.executeUpdate("delete from Reminder", values: nil)
                try database.executeUpdate("delete from Notifications ", values: nil)
                try database.executeUpdate("delete from OrderDetails ", values: nil)
                
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            database.close()
            
           let storyboard1 = UIStoryboard(name: "Main", bundle: nil)
            
           let loginNavVC = storyboard1.instantiateViewController(withIdentifier: "LoginNavigationController") as! LoginNavigationController
            AppDelegate.getAppDelegate().window?.rootViewController = loginNavVC
//            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  44;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 10;
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 1, width: tableView.bounds.size.width, height: 8))
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}
