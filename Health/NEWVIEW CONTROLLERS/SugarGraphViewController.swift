//
//  SugarGraphViewController.swift
//  Stetho Update
//
//  Created by HW-Anil on 7/27/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class SugarGraphViewController: UIViewController , SimpleBarChartDelegate,SimpleBarChartDataSource {
    @IBOutlet weak var mainScrollView : UIScrollView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var barGraphView: UIView!
    @IBOutlet weak var barGraphScrollView : UIScrollView!
    
    
    var arrvalues: Array<Int> = [20 ,16 , 7 , 2 , 3 ,5 ,9 ,99 ,2 , 3 ,5 ,1000 ]
   // var arrMonthValue: Array<String> = ["Jan" ,"Feb" , "MAR" , "APR", "May" ,"Jun" ,"Jul" ,"Aug" ,"Sep" , "Oct" ,"Nov" ,"Dec"]
    var barChart: SimpleBarChart!
    var isComingFromList: Bool?
    var sugarMOArr: [SugarDayMO] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        sugarMOArr = SugarDayMO.fetchSugarData(ascending: false)
        self.title = "SUGAR TRACKING"
        laodBarGraph()

       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setContentSize()
        barChart.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.mainScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 500)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func laodBarGraph()  {
        
        barChart  = SimpleBarChart(frame: CGRect(x: 10, y: 10, width: barGraphView.frame.width + 200 , height: barGraphView.frame.height - 20))
        barChart.incrementValue = 5
        
        barChart.xLabelType = SimpleBarChartXLabelTypeHorizontal
        barGraphView.addSubview(barChart)
        barChart.delegate = self;
        barChart.dataSource	= self;
        barChart.xLabelFont = KCALIBRI_REGULAR_14
        barChart.yLabelFont = KCALIBRI_REGULAR_14
//        barChart.reloadData()
//        
//        
//        barGraphScrollView.contentSize = CGSize(width: barGraphView.frame.width + 200, height: barGraphView.frame.height)
    }

    //MARK: SimpleBarChartDataSource
    
    
    func numberOfBars(in barChart: SimpleBarChart!) -> UInt {
        if segmentedControl?.selectedSegmentIndex == SelectedSegment.week.rawValue{
            if sugarMOArr.count < 7{
                return UInt(sugarMOArr.count)
            }
            return 7
        }else{
            return UInt(sugarMOArr.count)
        }
    }
    
    func barChart(_ barChart: SimpleBarChart!, valueForBarAt index: UInt) -> CGFloat {
        let sugarMO = sugarMOArr[Int(index)]
//        if btnGlassInML.isSelected {
//            return CGFloat((waterMO.totalWaterDrink/250)*1000)
//        }else{
            return CGFloat(sugarMO.totalSugarIntake)
//        }
        
    }
    
    func barChart(_ barChart: SimpleBarChart!, textForBarAt index: UInt) -> String! {
        return String(index * 5)
    }
    
    func barChart(_ barChart: SimpleBarChart!, xLabelForBarAt index: UInt) -> String! {
        let sugerMO = sugarMOArr[Int(index)]
        let dateComponents = sugerMO.date?.components(separatedBy: "-")
        return (dateComponents![2] + "-" + monthDict[dateComponents![1]]!)
    }
    
    func barChart(_ barChart: SimpleBarChart!, colorForBarAt index: UInt) -> UIColor! {
        
        
        return  UIColor.white
    }
    
    //MARK: IBActions
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl){
        setContentSize()
        barChart.reloadData()
    }
    
    @IBAction func showAllDataBtnClicked(_ sender: AnyObject){
        if isComingFromList != nil && isComingFromList == true{
            self.navigationController?.popViewController(animated: true)
        }else{
            self.performSegue(withIdentifier: "SugarDataTableViewController", sender: self)
        }
    }
    
    @IBAction func remindersBtnClicked(_ sender: AnyObject){
         self.performSegue(withIdentifier: "SugarReminderViewController", sender: self)
    }
    
    //MARK: CUSTOM METHODS
    
    func setContentSize() {
        if segmentedControl?.selectedSegmentIndex == SelectedSegment.week.rawValue{
            if sugarMOArr.count < 7{
                barGraphScrollView.contentSize = CGSize(width: CGFloat(sugarMOArr.count*70), height: barGraphView.frame.height)
                
            }else{
                barGraphScrollView.contentSize = CGSize(width: CGFloat(7*70), height: barGraphView.frame.height)
            }
        }else{
            barGraphScrollView.contentSize = CGSize(width: CGFloat(sugarMOArr.count*70), height: barGraphView.frame.height)
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
        if segue.identifier == "SugarReminderViewController" {
            return
        }
        let sugarDataTableViewController = segue.destination as! SugarDataTableViewController
        sugarDataTableViewController.isComingfromGraph = true
    }


}

