//
//  WaterGraphViewController.swift
//  Stetho Update
//
//  Created by HW-Anil on 7/21/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

enum SelectedSegment: Int {
    case week = 0, month
}

enum WaterQuantityType: Int {
    case glass = 0, litre
}

class WaterGraphViewController: UIViewController , SimpleBarChartDelegate , SimpleBarChartDataSource {

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var btnGlassINLiter: UIButton!
    @IBOutlet weak var btnGlassInML: UIButton!
    
    @IBOutlet weak var barGraphView: UIView!
    @IBOutlet weak var barGraphScrollView : UIScrollView!
    @IBOutlet weak var segmentedControl: UISegmentedControl?
    
    var arrvalues: Array<Int> = [20 ,16 , 7 , 2 , 3 ,5 ,9 ,99 ,2 , 3 ,5 ,1000 ]
    var isComingFromList: Bool?

    
   // var arrMonthValue: Array<String> = ["Jan" ,"Feb" , "MAR" , "APR", "May" ,"Jun" ,"Jul" ,"Aug" ,"Sep" , "Oct" ,"Nov" ,"Dec"]
    var waterMOArr: [WaterDayMO] = []
    var barChart: SimpleBarChart!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tabBarController?.navigationItem.title = "WATER TRACKING"
//        self.title = "WATER TRACKING"
        
        waterMOArr = WaterDayMO.fetchWaterData(ascending: false)
//        btnGlassInML.isSelected = true
        self.navigationItem.title = "Water Tracking"
         self.laodBarGraph()

        // Do any additional setup after loading the view.
       
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        btnGlassInML.dropShadow()
        btnGlassINLiter.dropShadow()
        btnGlassInML.backgroundColor = KWATERSELECTEDBUTTONBGCOLOR
        btnGlassInML.setTitleColor(UIColor.white, for: .normal)
        
        self.btnGlassInMLOnClick(btnGlassInML)
        mainScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 585 + 44 )
        
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view disapper now ")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
           }
    
    func laodBarGraph()  {
        
        barChart  = SimpleBarChart(frame: CGRect(x: 10, y: 10, width: barGraphView.frame.width + 200 , height: barGraphView.frame.height - 20))
       // barChart.incrementValue = 12
        
        barChart.xLabelType = SimpleBarChartXLabelTypeHorizontal
        barGraphView.addSubview(barChart)
        barChart.delegate					= self;
        barChart.dataSource				= self;
        barChart.xLabelFont = KCALIBRI_REGULAR_14
        barChart.yLabelFont = KCALIBRI_REGULAR_14
       // barChart.reloadData()
        
//        barGraphScrollView.contentSize = CGSize(width: barGraphView.frame.width + 200, height: barGraphView.frame.height)
    }
    
    
    //MARK: SimpleBarChartDataSource
    
    
    func numberOfBars(in barChart: SimpleBarChart!) -> UInt {
        if segmentedControl?.selectedSegmentIndex == SelectedSegment.week.rawValue{
            if waterMOArr.count < 7{
                return UInt(waterMOArr.count)
            }
            return 7
        }else{
            return UInt(waterMOArr.count)
        }
    }
    
    func barChart(_ barChart: SimpleBarChart!, valueForBarAt index: UInt) -> CGFloat {
        let waterMO = waterMOArr[Int(index)]
        if btnGlassInML.isSelected {
            return CGFloat((waterMO.totalWaterDrink/250)*1000)
        }else{
            return CGFloat(waterMO.totalWaterDrink)
        }
        
    }
    
    func barChart(_ barChart: SimpleBarChart!, textForBarAt index: UInt) -> String! {
        if btnGlassInML.isSelected{
        return String(index * 2)
        }else{
            return String(index)
        }
    }
    
    
    func barChart(_ barChart: SimpleBarChart!, xLabelForBarAt index: UInt) -> String! {
        let waterMO = waterMOArr[Int(index)]
        let dateComponents = waterMO.date?.components(separatedBy: "-")
        

        return (dateComponents![2] + "-" + monthDict[dateComponents![1]]!)
    }
    func barChart(_ barChart: SimpleBarChart!, colorForBarAt index: UInt) -> UIColor! {
        
        
        return  UIColor.white
    }
    
    

    //MARK: BUTTONACTTION
    
    @IBAction func btnGlassInMLOnClick(_ sender: UIButton) {
        btnGlassINLiter.backgroundColor = UIColor.white
        btnGlassInML.backgroundColor = KWATERSELECTEDBUTTONBGCOLOR
        btnGlassInML.setTitleColor(UIColor.white, for: .normal)
        btnGlassINLiter.setTitleColor(UIColor.black, for: .normal)
        //if segmentedControl?.selectedSegmentIndex == 0 {
        barChart.incrementValue = 2
        btnGlassInML.isSelected = true
        btnGlassINLiter.isSelected = false
        setContentSize()
        barChart.reloadData()
        barChart.layoutIfNeeded()
    }

    @IBAction func btnGlassLiterOnClick(_ sender: UIButton) {
        btnGlassINLiter.backgroundColor = KWATERSELECTEDBUTTONBGCOLOR
        btnGlassInML.backgroundColor = UIColor.white
        btnGlassINLiter.setTitleColor(UIColor.white, for: .normal)
        btnGlassInML.setTitleColor(UIColor.black, for: .normal)
        barChart.incrementValue = 1
        btnGlassInML.isSelected = false
        btnGlassINLiter.isSelected = true
        setContentSize()
        
        barChart.reloadData()
        barChart.layoutIfNeeded()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl){
        setContentSize()
       barChart.reloadData()
    }
    
    @IBAction func showAllDataBtnClicked(_ sender: AnyObject){
        if isComingFromList != nil && isComingFromList == true{
            self.navigationController?.popViewController(animated: true)
        }else{
          self.performSegue(withIdentifier: "WaterDataTableViewController", sender: self)
        }
    }
    
    @IBAction func remindersBtnClicked(_ sender: AnyObject){
        self.performSegue(withIdentifier: "WaterReminderViewController", sender: self)
    }
    
    //MARK: CUSTOM METHODS
    
    func setContentSize() {
        if segmentedControl?.selectedSegmentIndex == SelectedSegment.week.rawValue{
            if waterMOArr.count < 7{
                barGraphScrollView.contentSize = CGSize(width: CGFloat(waterMOArr.count*70), height: barGraphView.frame.height)
                
            }else{
                barGraphScrollView.contentSize = CGSize(width: CGFloat(7*70), height: barGraphView.frame.height)
            }
        }else{
            barGraphScrollView.contentSize = CGSize(width: CGFloat(waterMOArr.count*70), height: barGraphView.frame.height)
        }
        if barGraphScrollView.contentSize.width < self.view.frame.size.width {
            barChart.frame.size.width = self.view.frame.size.width
        }else{
            barChart.frame.size.width = barGraphScrollView.contentSize.width
        }
    }
    
    //MARK: SEGUE DELEGATES
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WaterReminderViewController" {
            return
        }
        let waterDataTableViewController = segue.destination as! WaterDataTableViewController
        waterDataTableViewController.isComingfromGraph = true
        if self.btnGlassInML.isSelected {
            waterDataTableViewController.qunatityType = WaterQuantityType.glass
        }else{
            waterDataTableViewController.qunatityType = WaterQuantityType.litre
        }
        
    }
    
    
    
}
