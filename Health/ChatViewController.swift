//
//  ChatViewController.swift
//  JivoDemo
//
//  Created by Administrator on 25/02/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, JivoDelegate {
    @IBOutlet var webView: UIWebView!
    var jivoSDK: JivoSdk!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = AppDelegate.getAppDelegate().navigationTitalFontSize
        self.title = KCHAT
        jivoSDK = JivoSdk(webView, "en")
        jivoSDK.delegate = self
        jivoSDK.prepare()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        jivoSDK.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        jivoSDK.stop()
    }
    
    func onEvent(_ name: String!, _ data: String!) {
        print("\(name), \(data)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
