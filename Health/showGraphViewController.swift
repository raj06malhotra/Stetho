//
//  showGraphViewController.swift
//  Stetho
//
//  Created by HW-Anil on 12/26/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class showGraphViewController: UIViewController ,serverTaskComplete ,LineChartDelegate {
    var activityIndicator : ProgressViewController?
    var graphView = UIView()
    var graphValueScrollView = UIScrollView()
    var graphScrollView = UIScrollView()
    var selectedTestName = ""
    var borderColor : UIColor = UIColor (red: (228/255), green: (228/255), blue: (228/255), alpha: 1)
    // y axis Value
    var arrGraphValue: [CGFloat] = []
    var arrGraphValueCopy: [CGFloat] = []
     var textColor : UIColor = UIColor.red
    //  x axis values
    var arrGraphDateCopy: [String] = []
    //  x axis values
    var arrGraphDate: [String] = []
    var tapIndex : Int = 0
    var label = UILabel()
    var lineChart: LineChart!
    
    var arrGetAllTestList = NSMutableArray()
    var arrTestList = NSMutableArray()
    
    var graph_width : CGFloat = 0
    var graph_value_width : CGFloat = 0
    var graph_Xpos: CGFloat = 0
    var graph_Value_Xpos: CGFloat = 0
    var arrSelectedTestListGraphValue = NSArray()
    var max_Value = CGFloat()
    var min_Value = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "HEALTH TRENDS"

        // Do any additional setup after loading the view.
        //set activity on view
        activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
        self.view.addSubview(activityIndicator!)
        
        // comment by anil for new
              if(UserDefaults.standard.value(forKey: "GetAllTests") == nil ){
                     activityIndicator?.start()
                    self.getAllTests()
         }else{
                
                
         arrGetAllTestList = NSMutableArray(array: UserDefaults.standard.value(forKey: "GetAllTests") as! NSArray)//UserDefaults.standard.value(forKey: "GetAllTests") as! NSMutableArray
                
                print(arrGetAllTestList.count)
         // Comment for new screen
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                    // do your background code here
                    DispatchQueue.main.sync(execute: {
                      self.loadTestData()
                        
                    });
                });
                
            self.getAllTests()
         }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.navigationBar.topItem!.title = "Back"
    }
    
    //MARK: GetAllTest 
    func getAllTests()  {
        
        if Reachability.isConnectedToNetwork() == true {
            let customerId = UserDefaults.standard.value(forKey: "loginCustomerId")as! String
            let allParameters = ["memberId":customerId ]
            ServerConnectivity().callWebservice(allParameters, resulttagname: "GetAllTestsResult" ,methodname: "GetAllTests", className: self)
        }
    }
    
    // comment for new Screen
      func loadTestData()  {
     
     for i in 0..<arrGetAllTestList.count {
     let testName = (arrGetAllTestList[i] as AnyObject).value(forKey: "test_name")as! String
     if !(arrTestList.contains(testName)) {
     arrTestList.add(testName)
     }
     }
        
        print(arrTestList.count)
     selectedTestName = arrTestList[0] as! String
     for view in self.view.subviews {
     
     view.removeFromSuperview()
     }
     self.createALayout()
//        if(NSUserDefaults.standardUserDefaults().valueForKey("showguideline") == nil && NSUserDefaults.standardUserDefaults().valueForKey("loginCustomerId") != nil ){
//            UIApplication.sharedApplication().endIgnoringInteractionEvents()
//           // self.showGuideLineView()
//            NSUserDefaults.standardUserDefaults().setValue("hide", forKey: "showguideline")
//        }

     }
    
    
  func createALayout()  {
    
     /// ***************************  I will change it latter of shwoing all test  ****************************************************
    
    
//    let lbldiseaseElement = BaseUIController().ALabelFrame(CGRectMake(5, self.view.frame.height/2 + 90, 200, 21), withString: "DISEASE ELEMENTS")as! UILabel
//    lbldiseaseElement.font = UIFont().regularMediumFont
//    lbldiseaseElement.textColor = UIColor (red: (72/255), green: (72/255), blue: (72/255), alpha: 1)
//    self.view.addSubview(lbldiseaseElement)
    
    let testListScrollView  = UIScrollView.init(frame: CGRect(x: 0, y: self.view.frame.height/2 + 100, width: self.view.frame.width, height: 130))
    testListScrollView.showsHorizontalScrollIndicator = false
    //testListScrollView.backgroundColor = UIColor.redColor()
    self.view.addSubview(testListScrollView)
    
    //let testListView = UIView.init(frame: CGRectMake(5, -62, self.view.frame.width - 10, 62))
    let testListView = UIView.init(frame: CGRect(x: 5, y: 2, width: self.view.frame.width - 10, height: 126))
    //testListView.backgroundColor = UIColor.blueColor()
    testListView.layer.masksToBounds = true
    testListView.layer.cornerRadius = 4
    testListView.layer.borderWidth = 1
    testListView.layer.borderColor = borderColor.cgColor
    testListScrollView.addSubview(testListView)
    //  let arrTestName = ["test 1 " , "test 2 ttttytttyty ", "test 5 fdasfasdfasf", "test - 6" , "test 5 fdasfasdfasf", "test - 6" , "test 5 ", "test - 6" ,"test 1 " , "test 2 ttttytttyty ", "test 5 fdasfasdfasf", "test - 6" , "test 5 fdasfasdfasf", "test - 6" , "test 5 ", "test - 6"]
    
    var xPos :CGFloat = 0
    var yPos : CGFloat = 0
    var heigherStringWidth : CGFloat = 0
    var lineWidth1 : CGFloat =  0
    var lineWidth2 : CGFloat =  0
    var lineWidth3 : CGFloat =  0

    
    for i in 0..<9{
    let testName = arrTestList[i]as! String
    
    
    let size: CGSize = testName.size(attributes: [NSFontAttributeName: UIFont().smallFont])
    heigherStringWidth = size.width
    
    let btnTest = BaseUIController().AButtonFrame(CGRect(x: xPos , y: yPos, width: heigherStringWidth + 30 , height: 42), withButtonTital: testName) as! UIButton //(self.view.frame.width - 10)/3
    btnTest.tag = 101 + i
    if btnTest.tag == 101 {
        btnTest.backgroundColor = UIColor (red: (227/255), green: (227/255), blue: (227/255), alpha: 1)
        btnTest.setTitleColor(UIColor.red, for: UIControlState())
    }
    else
    {
        btnTest.setTitleColor(UIColor (red: (72/255), green: (72/255), blue: (72/255), alpha: 1), for: UIControlState())
       
    }
    btnTest.addTarget(self, action: #selector(self.btnTestOnClick(_:)), for: .touchUpInside)
    btnTest.titleLabel?.font = UIFont().smallFont
    //btnTest.sizeToFit()
    testListView.addSubview(btnTest)
    xPos += heigherStringWidth + 30 //(self.view.frame.width - 10)/3
//    let lblVerticalLine = BaseUIController().ALabelFrame(CGRectMake(xPos, 0, 1, 126), withString: "") as! UILabel
//    lblVerticalLine.backgroundColor = borderColor // (line background color )
//    testListView.addSubview(lblVerticalLine)
        if (i == 0 || i == 3 || i == 6) {
            if (lineWidth1 < heigherStringWidth + 30 ){
                lineWidth1 = heigherStringWidth + 30
            }
           // btnTest.frame = CGRectMake(btnTest.frame.origin.x, btnTest.frame.origin.y, lineWidth1, 42)
            if i == 6{
                let btn0 = self.view.viewWithTag(101)
                btn0?.frame = CGRect(x: btnTest.frame.origin.x, y: 0, width: lineWidth1, height: 42)
                let btn3 = self.view.viewWithTag(104)
                btn3!.frame = CGRect(x: btnTest.frame.origin.x, y: 42, width: lineWidth1, height: 42)
                let btn6 = self.view.viewWithTag(107)
                btn6!.frame = CGRect(x: btnTest.frame.origin.x, y: 84, width: lineWidth1, height: 42)
            }
            
        }else if(i == 1 || i == 4 || i == 7){
        
            if (lineWidth2 < heigherStringWidth + 30 ){
                lineWidth2 = heigherStringWidth + 30
            }
            if i == 7{
                let btn1 = self.view.viewWithTag(102)
                btn1?.frame = CGRect(x: lineWidth1, y: 0, width: lineWidth2 , height: 42)
                let btn4 = self.view.viewWithTag(105)
                btn4!.frame = CGRect(x: lineWidth1, y: 42, width: lineWidth2 , height: 42)
                let btn7 = self.view.viewWithTag(108)
                btn7!.frame = CGRect(x: lineWidth1, y: 84, width: lineWidth2, height: 42)
            }

            
        }else if(i == 2 || i == 5 || i == 8){
            if (lineWidth3 < heigherStringWidth + 30 ){
                lineWidth3 = heigherStringWidth + 30
            }
            
            if i == 8 {
                lineWidth2 = lineWidth2 + lineWidth1
                let btn2 = self.view.viewWithTag(103)
                btn2?.frame = CGRect(x: lineWidth2 , y: 0, width: lineWidth3, height: 42)
                let btn5 = self.view.viewWithTag(106)
                btn5!.frame = CGRect(x: lineWidth2, y: 42, width: lineWidth3, height: 42)
                let btn8 = self.view.viewWithTag(109)
                btn8!.frame = CGRect(x: lineWidth2, y: 84, width: lineWidth3, height: 42)
            }
        
        }
        
        if i == 2 || i == 5 {
            xPos = 0
            yPos += 42
        }
        
        
    }
    let lblVerticalLine1 = BaseUIController().ALabelFrame(CGRect(x: lineWidth1, y: 0, width: 1, height: 126), withString: "") as! UILabel
    lblVerticalLine1.backgroundColor = borderColor // (line background color )
    testListView.addSubview(lblVerticalLine1)
    
    let lblVerticalLine2 = BaseUIController().ALabelFrame(CGRect(x: lineWidth2, y: 0, width: 1, height: 126), withString: "") as! UILabel
    lblVerticalLine2.backgroundColor = borderColor // (line background color )
    testListView.addSubview(lblVerticalLine2)
    
    let lblHorizontalLine1 = BaseUIController().ALabelFrame(CGRect(x: 0, y: 42, width: lineWidth2 + lineWidth3, height: 1), withString: "") as! UILabel
    lblHorizontalLine1.backgroundColor = borderColor // (line background color )
    testListView.addSubview(lblHorizontalLine1)
    
    let lblHorizontalLine2 = BaseUIController().ALabelFrame(CGRect(x: 0, y: 84, width: lineWidth2 + lineWidth3, height: 1), withString: "") as! UILabel
    lblHorizontalLine2.backgroundColor = borderColor // (line background color )
    testListView.addSubview(lblHorizontalLine2)
    
    testListView.frame =  CGRect(x: 5, y: 2, width: lineWidth2 + lineWidth3, height: 126)
    testListScrollView.contentSize = CGSize(width: (lineWidth2 + lineWidth3) + 10, height: 1)
    
    /// ***************************  I will change it latter ****************************************************
    
    // comment for new screen
   
    //load graph
  
     graphView = UIView.init(frame: CGRect(x: 5, y: 70, width: self.view.frame.width - 10,  height: self.view.frame.height/2))
     graphView.layer.masksToBounds = true
     graphView.layer.cornerRadius = 4
     graphView.layer.borderWidth = 1
     graphView.layer.borderColor = borderColor.cgColor
     self.view.addSubview(graphView)
     
     
    
    let btnNext = BaseUIController().AButtonFrame(CGRect(x: graphView.frame.width - 20, y: graphView.frame.height - 60, width: 20, height: 60), withButtonTital: ">")as! UIButton
    btnNext.setTitleColor(textColor, for: UIControlState())
    btnNext.addTarget(self, action: #selector(self.btnNextOnClick(_:)), for: .touchUpInside)
    graphView.addSubview(btnNext)
    
    let btnPrevious = BaseUIController().AButtonFrame(CGRect(x: 0, y: graphView.frame.height - 60, width: 20, height: 60), withButtonTital: "<")as! UIButton
    btnPrevious.setTitleColor(textColor, for: UIControlState())
    btnPrevious.addTarget(self, action: #selector(self.btnPrevious(_:)), for: .touchUpInside)
    graphView.addSubview(btnPrevious)

    
    
   
    
    var arrSelectedTestListGraphValue = NSArray()
    if  arrGetAllTestList.count != 0{
    
    let searchPredicate = NSPredicate(format: "test_name CONTAINS[c] %@", (arrGetAllTestList[0] as AnyObject).value(forKey: "test_name")as! String)
        arrSelectedTestListGraphValue = arrGetAllTestList.filtered(using: searchPredicate) as NSArray
   // arrSelectedTestListGraphValue = arrGetAllTestList.filter {searchPredicate.evaluate(with: $0)}
    arrGraphDate.removeAll()
    arrGraphValue.removeAll()
    for i in 0..<arrSelectedTestListGraphValue.count {
    let value  = ((arrSelectedTestListGraphValue[i] as AnyObject).value(forKey: "value")as! String)
    var cgFloat: CGFloat?
    if let doubleValue = Double(value) {
    cgFloat = CGFloat(doubleValue)
    }
    arrGraphDate.append((arrSelectedTestListGraphValue[i] as AnyObject).value(forKey: "o_date1")as! String)
    arrGraphValue.append(cgFloat!)
    }
   //  Comment for new screen only 2 line
                self.loadGraphData(arrSelectedTestListGraphValue)
                self.loadGraph("test")
    }
    
   
    }
    
    //MARK: - callWebservice
    
    
    // comment for new screen
    
     func loadGraphData(_ arrGraphValue : NSArray)  {
     
     graphValueScrollView.removeFromSuperview()
     graphValueScrollView  = UIScrollView.init(frame: CGRect(x: 20, y: graphView.frame.height - 60, width: graphView.frame.width - 40 , height: 60))
    // graphValueScrollView.delegate = self
     graphValueScrollView.showsHorizontalScrollIndicator = false
     graphView.addSubview(graphValueScrollView)
     //get max and min value
     //        max_Value = CGFloat(arrGraphValue[0].valueForKey("maxvalue"))
     //        min_Value = CGFloat(arrGraphValue[0].valueForKey("minvalue"))
     max_Value = CGFloat(Double((arrGraphValue[0] as AnyObject).value(forKey: "maxvalue")as! String)!)
     min_Value =  CGFloat(Double((arrGraphValue[0] as AnyObject).value(forKey: "minvalue")as! String)!)
     
     var xPos : CGFloat = 0
     let gv_width : CGFloat = (graphView.frame.width - 40)/3 - 2
     for i in 0..<arrGraphValue.count {
     
     let btnGraphValue = BaseUIController().AButtonFrame(CGRect(x: xPos, y: 0, width: gv_width, height: 60), withButtonTital: "")as! UIButton
     btnGraphValue.tag = 501 + i
     btnGraphValue.addTarget(self, action:#selector(self.btnGraphOnValueClick(_:)), for: .touchUpInside)
     
     graphValueScrollView.addSubview(btnGraphValue)
     
     let lblDate = BaseUIController().ALabelFrame(CGRect(x: 0, y: 10, width: gv_width, height: 15), withString: (arrGraphValue[i] as! NSDictionary).value(forKey: "o_date1")as! String)as! UILabel
     //  let lblDate = BaseUIController().ALabelFrame(CGRectMake(0, 10, gv_width, 10), withString: arrGraphValue[i] as! String)as! UILabel
     lblDate.tag = 601 + i
      lblDate.textColor = textColor
     lblDate.textAlignment = .center
     lblDate.font = UIFont().smallFont
     btnGraphValue.addSubview(lblDate)
     
     
     let testValue   = (arrGraphValue[i] as AnyObject).value(forKey: "value")as! String
     let testUnit =  (arrGraphValue[i] as AnyObject).value(forKey: "t_meas")as! String
     let attrs1      = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName:UIColor (red: (72/255), green: (72/255), blue: (72/255), alpha: 1)]
     let attrs2      = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 10), NSForegroundColorAttributeName: UIColor (red: (72/255), green: (72/255), blue: (72/255), alpha: 1)]
     let attributedText = NSMutableAttributedString()
     attributedText.append(NSAttributedString(string: testValue , attributes:  attrs1))
     attributedText.append(NSAttributedString(string: testUnit, attributes: attrs2))
     
     
     
     
     let lblTestValue = BaseUIController().ALabelFrame(CGRect(x: 0, y: 30, width: gv_width, height: 20), withString:"")as! UILabel
     // let lblTestValue = BaseUIController().ALabelFrame(CGRectMake(0, 30, gv_width, 20), withString: arrGraphValue[i]as! String)as! UILabel
     lblTestValue.tag = 701 + i
     lblTestValue.textAlignment = .center
     lblTestValue.attributedText = attributedText
     //lblTestValue.font = UIFont.systemFontOfSize(1)
     btnGraphValue.addSubview(lblTestValue)
     
     
     
     xPos += gv_width + 2
     
     let lblVerticalLine = BaseUIController().ALabelFrame(CGRect(x: xPos - 1  , y: 15, width: 1, height: 30), withString: "")as! UILabel
     lblVerticalLine.backgroundColor  = textColor
     graphValueScrollView.addSubview(lblVerticalLine)
     }
     graphValueScrollView.contentSize = CGSize(width: xPos, height: 1.0)
     graph_Xpos = xPos
     }
    
    
    
    // comment for new screen
      func loadGraph(_ clickOn : String)  {
     var views: [String: AnyObject] = [:]
     
     label.text = "..."
     label.translatesAutoresizingMaskIntoConstraints = false
     label.textAlignment = NSTextAlignment.center
     self.view.addSubview(label)
     views["label"] = label
     view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: views))
     view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[label]", options: [], metrics: nil, views: views))
     
     lineChart = LineChart()
     lineChart.animation.enabled = true
     lineChart.area = false
     lineChart.x.labels.visible = true
     lineChart.x.grid.count = 5
     lineChart.y.grid.count = 5
     lineChart.x.grid.visible = false
     // lineChart.y.grid.visible = false
     if clickOn == "test" {
     arrGraphDate.append("")
     lineChart.x.labels.values = arrGraphDate
     }else{
     arrGraphDateCopy.append("")
     lineChart.x.labels.values = arrGraphDateCopy
     
     }
     
     // lineChart.y.labels.visible = false
     //        lineChart.y.axis.visible = false
     //        lineChart.x.axis.visible = false
     
     graph_width = graphView.frame.width  //CGFloat(3 * Int(graphView.frame.width/3))
     print(graphView)
     //  graph_width = self.view.frame.width + 20
     //  graph_value_width = CGFloat(arrGraphValue.count * Int((graphView.frame.width - 20)/3))
     if clickOn == "test" {
     graph_width = graphView.frame.width + 40
     arrGraphValue.append(max_Value)
     lineChart.addLine(arrGraphValue, min_Value: min_Value, max_Value: max_Value, line_width: graph_width,testName: selectedTestName)
     // high light a dot after
     let triggerTime = (Int64(NSEC_PER_MSEC) * 50)
     DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
     self.higlightDot(0)
     })
     //            higlightDot(0)
     }else{
     graph_width = graphView.frame.width + 100
     arrGraphValueCopy.append(max_Value)
     lineChart.addLine(arrGraphValueCopy, min_Value: min_Value, max_Value: max_Value, line_width: graph_width,testName: selectedTestName)
     // high light a dot after
     if arrGraphDate.count - 1 == tapIndex {
     let triggerTime = (Int64(NSEC_PER_MSEC) * 50)
     DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
     self.higlightDot(2)
     })
     }else if(tapIndex == 0){
     let triggerTime = (Int64(NSEC_PER_MSEC) * 50)
     DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
     self.higlightDot(0)
     })
     }else{
     let triggerTime = (Int64(NSEC_PER_MSEC) * 50)
     DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
     self.higlightDot(1)
     })
     }
     
     }
     
     //   lineChart.addLine(data2)
     // try to drow line on graph
     lineChart.lineWidth = 3
     lineChart.colors = [UIColor.white]
     
     //  lineChart.drawMax_MinLine(2, min: 5)
     
     
     
     //        graph_width = CGFloat(arrGraphValue.count * Int(graphView.frame.width/3))
     graphScrollView.removeFromSuperview()
     graphScrollView  =  UIScrollView.init(frame: CGRect(x: 0, y: 0, width: graphView.frame.width , height: graphView.frame.height - 60))
   //  graphScrollView.delegate = self
     graphScrollView.isScrollEnabled = false
     graphScrollView.backgroundColor = UIColor(patternImage: UIImage(named: "graphbg_icon.png")!)
     
     
     graphScrollView.showsHorizontalScrollIndicator = false
     graphView.addSubview(graphScrollView)
     
     lineChart.frame = CGRect(x: 0, y: 0, width: graph_width , height: graphView.frame.height - 60)
     
     // lineChart.translatesAutoresizingMaskIntoConstraints = false
     lineChart.delegate = self
     
     graphScrollView.addSubview(lineChart)
     views["chart"] = lineChart
     view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chart]-|", options: [], metrics: nil, views: views))
     view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-[chart(==200)]", options: [], metrics: nil, views: views))
     }

   
    
    func getAllResponse(_ allResponse: AnyObject, methodName: String) {
//         print(methodName)
//         print(allResponse)
       // DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            // do your background code here
            DispatchQueue.main.sync(execute: {
                // stop the activity indicator (you are now on the main queue again)
                self.activityIndicator?.stop()
                if allResponse .isEqual("error") || allResponse.isEqual("") || allResponse.isEqual("Something went wrong. Please try again.")  {
                    
                }
                else{
                  
                     if (methodName == "GetAllTests"){
                        //set All test in NSUserDefault
                        self.arrGetAllTestList = NSMutableArray(array: allResponse as! NSArray)
                        if(UserDefaults.standard.value(forKey: "GetAllTests") == nil){
                        UserDefaults.standard.set(self.arrGetAllTestList, forKey: "GetAllTests")
                        // comment for new screen
                        
                           self.loadTestData()
                          
                        }
                    }
                    
                }
            });
        }//);
    }
    
    
    func higlightDot(_ selectedIndex : Int)  {
        
        
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        //            // do your background code here
        //            dispatch_sync(dispatch_get_main_queue(), {
        self.lineChart.highlightDataPoints(selectedIndex)
        //            });
        //        });
    }
    
    //MARK: - LineChartDelegate
    func didSelectDataPoint(_ x: CGFloat, yValues: Array<CGFloat>) {
        // label.text = "x: \(x)     y: \(yValues)"
        
        
        //        graphScrollView.setContentOffset(CGPointMake(x, 0), animated: true)
        //        graphValueScrollView.setContentOffset(CGPointMake(x - 40 , 0), animated: true)
        
        print(arrGraphValue)
        
        for i in 0..<arrGraphDate.count {
            let lblDate  = self.view.viewWithTag(601 + i)as? UILabel
            let lblvalue  = self.view.viewWithTag(701 + i)as? UILabel
            
            if lblDate != nil && lblvalue != nil{
                if 501 + Int(x) == i + 501 {
                    lblDate!.textColor = textColor
                    lblvalue!.textColor = textColor
                }else{
                    lblDate!.textColor = UIColor.black
                    lblvalue!.textColor = UIColor.black
                }
            }
        }
        
        
        
    }
    
    func btnNextOnClick(_ button : UIButton)  {
        
        //        if graph_Xpos < graph_width - 320 {
        //            graph_Xpos += graphView.frame.width
        //            graph_Value_Xpos += graphView.frame.width - 20
        //             graphScrollView.setContentOffset(CGPointMake(graph_Xpos, 0), animated: true)
        if arrGraphDate.count > 3 {
            graphValueScrollView.setContentOffset(CGPoint(x: graph_Xpos - (self.view.frame.width - 50) , y: 0), animated: true) // 10 + btnNext + btnPrevious
        }
        
        
        
        //        }
        //         print(graph_Xpos)
    }
    func btnPrevious(_ button : UIButton)  {
        //        if graph_Xpos != 0 {
        //            graph_Xpos -= graphView.frame.width
        //            graph_Value_Xpos -= graphView.frame.width - 20
        //            graphScrollView.setContentOffset(CGPointMake(graph_Xpos  , 0), animated: true)
        graphValueScrollView.setContentOffset(CGPoint(x: graph_Value_Xpos , y: 0), animated: true)
        
        //        }
        
        
    }
    func btnTestOnClick(_ button : UIButton)  {
        
        
        var arrSelectedTestListGraphValue = NSArray()
        let searchPredicate = NSPredicate(format: "test_name CONTAINS[c] %@",(button.titleLabel?.text)!)
        arrSelectedTestListGraphValue = arrGetAllTestList.filtered(using: searchPredicate) as NSArray
//        arrSelectedTestListGraphValue = arrGetAllTestList.filter {searchPredicate.evaluate(with: $0)}
       // for i in 0..<arrTestList.count {
        for i in 0..<9 {
            let btn = self.view.viewWithTag(101 + i)as! UIButton
            if button.tag == btn.tag{
                selectedTestName = arrTestList[btn.tag - 101] as! String
                print(selectedTestName)
                btn.backgroundColor = UIColor (red: (227/255), green: (227/255), blue: (227/255), alpha: 1)
                btn.setTitleColor(UIColor.red, for: UIControlState())
            }else{
                btn.backgroundColor = UIColor.clear
                btn.setTitleColor(UIColor (red: (72/255), green: (72/255), blue: (72/255), alpha: 1), for: UIControlState())
            }
        }
        arrGraphDate.removeAll()
        arrGraphValue.removeAll()
        for i in 0..<arrSelectedTestListGraphValue.count {
            let value  = ((arrSelectedTestListGraphValue[i] as AnyObject).value(forKey: "value")as! String)
            var cgFloat: CGFloat?
            if let doubleValue = Double(value) {
                cgFloat = CGFloat(doubleValue)
            }
            arrGraphDate.append((arrSelectedTestListGraphValue[i] as AnyObject).value(forKey: "o_date1")as! String)
            arrGraphValue.append(cgFloat!)
        }
        // comment for new screen 2 line
                self.loadGraphData(arrSelectedTestListGraphValue)
                self.loadGraph("test")
        
    }
    
    func btnGraphOnValueClick(_ button : UIButton)  {
        arrGraphValueCopy.removeAll()
        arrGraphDateCopy.removeAll()
        if arrGraphValue.count == arrGraphDate.count {
            arrGraphDate.removeLast()
        }
        for i in 0..<arrGraphDate.count {
            if button.tag == i + 501 {
                let lblDate  = self.view.viewWithTag(601 + i)as! UILabel
                lblDate.textColor = textColor
                let lblvalue  = self.view.viewWithTag(701 + i)as! UILabel
                lblvalue.textColor = textColor
                tapIndex = i
            }else{
                let lblDate  = self.view.viewWithTag(601 + i)as! UILabel
                lblDate.textColor = UIColor.black
                let lblvalue  = self.view.viewWithTag(701 + i)as! UILabel
                lblvalue.textColor = UIColor.init(red: (72.0/255.0), green: (72.0/255.0), blue: (72.0/255.0), alpha: 1) //UIColor.blackColor()
            }
        }
        lineChart.highlightDataPoints(button.tag - 501)
        if arrGraphDate.count > 3 {
            
            print(arrGraphDate.count)
            print(arrGraphValue.count)
            
            if(arrGraphDate.count == tapIndex + 1){
                arrGraphDateCopy.append(arrGraphDate[tapIndex - 2])
                arrGraphDateCopy.append(arrGraphDate[tapIndex - 1])
                arrGraphDateCopy.append(arrGraphDate[tapIndex])
                
                arrGraphValueCopy.append(arrGraphValue[tapIndex - 2])
                arrGraphValueCopy.append(arrGraphValue[tapIndex - 1])
                arrGraphValueCopy.append(arrGraphValue[tapIndex])
                
                //                arrSelectedTestListGraphValueCopy.addObject(arrSelectedTestListGraphValue.objectAtIndex(tapIndex - 2))
                //                arrSelectedTestListGraphValueCopy.addObject(arrSelectedTestListGraphValue.objectAtIndex(tapIndex - 1))
                //                arrSelectedTestListGraphValueCopy.addObject(arrSelectedTestListGraphValue.objectAtIndex(tapIndex))
                
            }else if (tapIndex == 0){
                
                arrGraphDateCopy.append(arrGraphDate[tapIndex])
                arrGraphDateCopy.append(arrGraphDate[tapIndex + 1])
                arrGraphDateCopy.append(arrGraphDate[tapIndex + 2])
                
                arrGraphValueCopy.append(arrGraphValue[tapIndex])
                arrGraphValueCopy.append(arrGraphValue[tapIndex + 1])
                arrGraphValueCopy.append(arrGraphValue[tapIndex + 2])
                
                
            }else{
                
                arrGraphDateCopy.append(arrGraphDate[tapIndex - 1])
                arrGraphDateCopy.append(arrGraphDate[tapIndex])
                arrGraphDateCopy.append(arrGraphDate[tapIndex + 1])
                
                arrGraphValueCopy.append(arrGraphValue[tapIndex - 1])
                arrGraphValueCopy.append(arrGraphValue[tapIndex])
                arrGraphValueCopy.append(arrGraphValue[tapIndex + 1])
                
                //                arrSelectedTestListGraphValueCopy.addObject(arrSelectedTestListGraphValue.objectAtIndex(tapIndex - 1))
                //                arrSelectedTestListGraphValueCopy.addObject(arrSelectedTestListGraphValue.objectAtIndex(tapIndex))
                //                arrSelectedTestListGraphValueCopy.addObject(arrSelectedTestListGraphValue.objectAtIndex(tapIndex + 1))
            }
            //  self.loadGraphData(arrSelectedTestListGraphValue)
            loadGraph("value")
            
        }
        print(String(format: "taped Index %d",tapIndex))
    }
    



    
    
    
}
