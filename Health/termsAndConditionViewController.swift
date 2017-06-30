//
//  termsAndConditionViewController.swift
//  Stetho
//
//  Created by HW-Anil on 9/27/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class termsAndConditionViewController: UIViewController {
    var webView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FBEventClass.logEvent("Terms And Conditions")

        // Do any additional setup after loading the view.
        webView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(webView)
        let htmlFile = Bundle.main.path(forResource: "terms", ofType: "html")
        let htmlString = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(htmlString!, baseURL: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "TERMS & CONDITIONS"
        self.navigationController!.navigationBar.topItem!.title = "Back";
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    

   

}
