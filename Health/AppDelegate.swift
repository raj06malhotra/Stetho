//
//  AppDelegate.swift
//  Health
//
//  Created by HW-Anil on 6/15/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit
import ZDCChat
import AVFoundation
import GoogleMaps
import Fabric
import Crashlytics

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let appVersion = "1.0"
    
   // var mobileNo = ""
    var morningAlarmTime = "08:00 AM"
    var afternoonAlarmTime = "02:00 PM"
    var eveningAlarmTime = "08:00 PM"
    var isOldReminder = Bool()
    var isReminderValueChange = Bool()
    let navigationTitalFontSize = [NSFontAttributeName : UIFont(name: KROBOTO_REGULAR, size: 16.0), NSForegroundColorAttributeName : UIColor(red: 196/255.0, green: 35/255.0, blue: 24/255.0, alpha: 1)]
    var audioPlayer = AVAudioPlayer()
    let  NotificationCategoryIdent  = "ACTIONABLE";
    let  NotificationActionOneIdent  = "ACTION_ONE";
    let  NotificationActionTwoIdent  = "ACTION_TWO";
    let timerArray = NSMutableArray()
    var notificatinOnBackground = "forground"
    var notification_type = ""
    var notificationPayload = NSDictionary()
   // var device_Token = ""
    var forceUpdate = false
    var referralCode = ""
    var walletBalance = ""
    var corporateAllDetailsDict = NSMutableDictionary()
    var bookedOrderId = NSMutableString()
    var isComingfromLaunching = false
    
    
    

    
    
   

    
    
    func loadMainview()  {
        // Override point for customization after application launch.
        //set Chat account key
         ZDCChat.initialize(withAccountKey: "4DOEOlzBLx38oYLT2nN91i43KkQEuP6O")
        let mainViewController = HomeViewController()
        let drawerViewController = DrawerViewController()
        let drawerController     = KYDrawerController()
        drawerController.mainViewController = UINavigationController(
            rootViewController: mainViewController
        )
        drawerController.drawerViewController = drawerViewController
        /* Customize */
        drawerController.drawerDirection = .left
        drawerController.drawerWidth     = (UIScreen.main.bounds.width-50)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = drawerController
        window?.makeKeyAndVisible()
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        isComingfromLaunching = true
        // Override point for customization after application launch.
        DBModel().createDataBase()
        
        let isLogin = UserDefaults.standard.bool(forKey: "loginstatus")
        if isLogin  {
            
            let isCorporate = UserDefaults.standard.bool(forKey: "iscorporate")
            
            if isCorporate  {
                // open corporate page 
            }else{
            self.loadMainview()
            }
            loadRecordfromBackground()
        }
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
        // setting of local notification 
        
        let  action1 = UIMutableUserNotificationAction()
        action1.title = "Snooze"
        action1.identifier = NotificationActionOneIdent
        action1.isDestructive = false
        action1.isAuthenticationRequired = false
        action1.activationMode = UIUserNotificationActivationMode.background
        
        let  action2 = UIMutableUserNotificationAction()
        action2.title = "Stop"
        action2.identifier = NotificationActionTwoIdent
        action2.isDestructive = false
        action2.isAuthenticationRequired = false
        action2.activationMode = UIUserNotificationActivationMode.background
        
        let actionCategory = UIMutableUserNotificationCategory()
        actionCategory.identifier = NotificationCategoryIdent
        actionCategory.setActions([action1 , action2], for: .default)
        let categories = NSSet(objects: actionCategory)
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories as? Set<UIUserNotificationCategory>)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        
        // setting for Server Notifications 
        self.initializeNotificationServices()
        application.applicationIconBadgeNumber = 0
        
        // For remote Notification
        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil {
            notificatinOnBackground = "close"
        }
         UserDefaults.standard.set(true, forKey: "forceupdate")
         UserDefaults.standard.set(false, forKey: "shworeportspopup")
        
        // Configure tracker from GoogleService-Info.plist.
        let configureError:NSError?
//        GGLContext.sharedInstance().configureWithError(&configureError)
//        if configureError == nil{
//        assert(configureError! == nil, "Error configuring Google services: \(configureError)")
//        }
//        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        gai?.logger.logLevel = GAILogLevel.verbose  // remove before app release
        
        // google api key for map
         GMSServices.provideAPIKey("AIzaSyCka19t3_FUu9vIDAQnutK0goxqXIJEqMg")
//        Intialize Crashylytics
              Fabric.with([Crashlytics.self])
        
        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if GlobalInfo.sharedInfo.isNeedToShowPushAlert() {
            let homeVC = HomeViewController()            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                homeVC.showPushNotificationAlert()
            }
        }
        notificatinOnBackground = "background"
        if forceUpdate == true {
            let homeVC = HomeViewController()
            homeVC.registerDeviceTone()
        }
        
    }
    
    

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
         UserDefaults.standard.set(true, forKey: "forceupdate")
    }
    
    //MARK: CUSTOM METHOD
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    //MARK: Local-NotificationDelegate
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let userInfo = notification.userInfo
        let fireDate = userInfo!["alarmTime"] as! Date
        let medicineName = userInfo!["medicineName"] as! String
        let msg = String(format: "Time to take (%@) Medicine",medicineName)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
         self.playSound()
        
        let actionSheetController: UIAlertController = UIAlertController(title: "REMINDER", message: msg , preferredStyle: .alert)
        
            //Create and add the Yes action
            let snoozeAction: UIAlertAction = UIAlertAction(title: "Snooze", style: .default) { action -> Void in
                //Do some stuff
                self.audioPlayer.stop()
                self.scheduleSnoozeReminder(fireDate , medicine_Name: medicineName)
            }
            //Create and add the Cancel action
            let stopAction: UIAlertAction = UIAlertAction(title: "Stop", style: .cancel) { action -> Void in
                //Do some stuff
                self.audioPlayer.stop()
            }
            actionSheetController.addAction(snoozeAction)
            actionSheetController.addAction(stopAction)
            self.window?.rootViewController?.present(actionSheetController, animated: true, completion: nil)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        let userInfo = notification.userInfo
        let fireDate = userInfo!["alarmTime"] as! Date
        let medicineName = userInfo!["medicineName"] as! String
        if identifier == NotificationActionOneIdent {
            self.scheduleSnoozeReminder(fireDate , medicine_Name: medicineName)
        } else if identifier == NotificationActionTwoIdent {
//            let volume = AVAudioSession.sharedInstance().outputVolume
        }
        completionHandler()
    }
    
    func openDataBase() -> FMDatabase {
        
        let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documents.appendingPathComponent("HealthDatabase.db")
        let database = FMDatabase(path: fileURL.path)
        if !(database?.open())! {
        }
        return database!
    }
    func scheduleSnoozeReminder(_ reminderDate : Date , medicine_Name : String)  {
//        let fireDate = reminderDate
        // Create reminder by setting a local notification
        let localNotification = UILocalNotification() // Creating an instance of the notification.
        if #available(iOS 8.2, *) {
            localNotification.alertTitle = "REMINDER"
        } else {
            // Fallback on earlier versions
        }
        localNotification.alertBody = String(format: "Time to take (%@) Medicine",medicine_Name)
        localNotification.alertAction = "ShowDetails"
        localNotification.fireDate =  Date().addingTimeInterval(60*1) // 5 minutes(60 sec * 5) from now
        localNotification.repeatInterval = NSCalendar.Unit.day
        localNotification.timeZone = TimeZone.current
        localNotification.userInfo = ["alarmTime" : Date() , "medicineName" : medicine_Name]
        localNotification.soundName =  "alarmtone.mp3" //UILocalNotificationDefaultSoundName // Use the default notification tone/ specify a file in the application bundle
        //localNotification.applicationIconBadgeNumber = 1 // Badge number to set on the application Icon.
        localNotification.category = "ACTIONABLE" // Category to use the specified actions
        UIApplication.shared.scheduleLocalNotification(localNotification) // Scheduling the
    }
    func playSound() {
                let badumSound = URL(fileURLWithPath: Bundle.main.path(forResource: "alarmtone", ofType: "mp3")!)
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: badumSound)
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                } catch {
                    print("No sound found by URL:\(badumSound)")
                }

    }
    
    //MARK: - Push-NotificationDelegate
    func initializeNotificationServices() -> Void {
        let settings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        // This is an asynchronous method to retrieve a Device Token
        // Callbacks are in AppDelegate.swift
        // Success = didRegisterForRemoteNotificationsWithDeviceToken
        // Fail = didFailToRegisterForRemoteNotificationsWithError
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //  let deviceTokenStr = convertDeviceTokenToString(deviceToken)
        // ...register device token with our Time Entry API server via REST
        
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        print("Device Token:", tokenString)
        UserDefaults.standard.setValue(tokenString, forKey: "device_token")
//        GlobalInfo.isPushEnabled()
         let isLogin = UserDefaults.standard.bool(forKey: "loginstatus")
        if isLogin {
            let homeVC = HomeViewController()
            homeVC.registerDeviceTone()
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Device token for push notifications: FAIL -- ")
        print(error.localizedDescription)
    }
    // Called when a notification is received and the app is in the
    // foreground (or if the app was in the background and the user clicks on the notification).
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let isLogin = UserDefaults.standard.bool(forKey: "loginstatus")
        if  !isLogin  { return }
        print("Message received")
        print(userInfo)
        
        let notification = userInfo["aps"] as? NSDictionary
        let alert = notification!["alert"] as? String
        notification_type = notification!["type"] as! String
        notificationPayload = notification!
   
        
        
        // Coming form backgorund 
        
        if notificatinOnBackground == "background" {
            let homeVC = HomeViewController()
            //homeVC.notificatinType = notification_type
            homeVC.isComingFromClass = "remoteNotifications"
            let drawerViewController = DrawerViewController()
            let drawerController     = KYDrawerController()
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
            notificatinOnBackground = "forground"
        }else if (notificatinOnBackground == "forground"){

            AGPushNoteView.show(withNotificationMessage: alert)
            let triggerTime = (Int64(NSEC_PER_SEC) * 5)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                AGPushNoteView.close()
            })
            notificatinOnBackground = "forground"

        }else if(notificatinOnBackground == "close"){
            
            let homeVC = HomeViewController()
            //homeVC.notificatinType = notification_type
            homeVC.isComingFromClass = "remoteNotifications"
            let drawerViewController = DrawerViewController()
            let drawerController     = KYDrawerController()
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
            notificatinOnBackground = "forground"
        
        }
        
    }
    
    func clickOnForgroundNotifications(){
        
        print("forground notifications")
        let homeVC = HomeViewController()
       // homeVC.notificatinType = notification_type
        homeVC.isComingFromClass = "remoteNotifications"
        let drawerViewController = DrawerViewController()
        let drawerController     = KYDrawerController()
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
        notificatinOnBackground = "forground"
        
    }
//
//    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller: ResponseViewController = (storyboard.instantiateViewControllerWithIdentifier("ResponseViewController") as? ResponseViewController)!
//        var parameterArray: [AnyObject] = url.absoluteString.componentsSeparatedByString("?")
//        let trans_id: String = parameterArray[1] as! String
//        controller.transaction_id=trans_id
//        print("id value \(parameterArray[1])")
//        let navigationController: UINavigationController = (self.window!.rootViewController as?
//            UINavigationController)!
//        navigationController.pushViewController(controller, animated: true)
//        return true
//        
//    }
//    
//    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
//        //var url: NSURL?
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller: ResponseViewController = (storyboard.instantiateViewControllerWithIdentifier("ResponseViewController") as? ResponseViewController)!
//        var parameterArray: [AnyObject] = url.absoluteString.componentsSeparatedByString("?")
//        let trans_id: String = parameterArray[1] as! String
//        controller.transaction_id=trans_id
//        let navigationController: UINavigationController = (self.window!.rootViewController as?
//            UINavigationController)!
//        navigationController.pushViewController(controller, animated: true)
//        return true
//        
//    }
    
    //MARK: paymentGetway
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        DispatchQueue.main.async {
            // Do stuff to UI
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller: ResponseViewController = (storyboard.instantiateViewController(withIdentifier: "ResponseViewController") as? ResponseViewController)!
            var parameterArray: [String] = url.absoluteString.components(separatedBy: "?")
            let trans_id: String = parameterArray[1]
            controller.transaction_id=trans_id
            print("id value \(parameterArray[1])")
            let navigationController: UINavigationController = (self.window!.rootViewController as?
                UINavigationController)!
            navigationController.pushViewController(controller, animated: true)
        }
        return true
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        //var url: NSURL?
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ResponseViewController")as! ResponseViewController
        var parameterArray = url.absoluteString.components(separatedBy: "?")
//        var parameterArray: [String] = url.absoluteString.components(separatedBy: "?")
        
        let trans_id: String = parameterArray[1] 
        controller.transaction_id=trans_id
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.tintColor = KRED_COLOR
        appdelegate.window!.rootViewController = nav
        
        
        return true
    }
    
    //MARK: tackGoogleAnalytics
    
    func trackViewOnGoogleAnalytics(_ pageName : String)  {
        
        let googleAnalytics : GAITracker = GAI.sharedInstance().tracker(withTrackingId: "UA-62986228-6")
       // GAI.sharedInstance().trackUncaughtExceptions = true
        googleAnalytics.allowIDFACollection = true
        googleAnalytics.set(kGAIScreenName, value: pageName)
        let builder = GAIDictionaryBuilder.createScreenView()
        googleAnalytics.send(((builder?.build())! as NSDictionary) as! [AnyHashable: Any])
    }
    
    //MARK: BACKGROUND SYNC
    
    func loadRecordfromBackground(){
        DispatchQueue.global(qos: .background).async {
            SyncReportData.shareReportData.loadDataFromDataBase()
            SyncReportData.shareReportData.getNonSyncDataFromDtabase()
            SyncReportData.shareReportData.getListofDeletedReport()
            SyncMyFamilyData.shareMyFamilyData.getNonSyncDataFromMyFamilyTable()
            SyncReminderData.shareReminderData.getRemindersFromSever()
            SyncReminderData.shareReminderData.syncReminderFromDataBasetoServer()
            SyncReminderData.shareReminderData.getListofDeletedReminder()
        }
    }
}

