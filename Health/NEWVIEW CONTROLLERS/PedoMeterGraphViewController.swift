//
//  PedoMeterGraphViewController.swift
//  Stetho Update
//
//  Created by HW-Anil on 7/15/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit


class PedoMeterGraphViewController: UIViewController ,SimpleBarChartDelegate ,SimpleBarChartDataSource   {
    
    @IBOutlet weak var lblSelectedCategory: UILabel!
    
    @IBOutlet weak var lblDailyAverage: UILabel!
    
    @IBOutlet weak var lblStep_KM_CaL_ActiveMin_Count: UILabel!
    @IBOutlet weak var lblCurrentTime: UILabel!
    
    @IBOutlet var mainScrollView: UIScrollView!

    @IBOutlet weak var btnSteps: UIButton!
    @IBOutlet weak var btnKMS: UIButton!
    @IBOutlet weak var btnCalories: UIButton!
    @IBOutlet weak var btnActiveMinutes: UIButton!
   @IBOutlet weak var barGraphView: UIView!
   @IBOutlet weak var barGraphScrollView : UIScrollView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var stepsArrvalues: Array<Int> = [0 ,1000, 2000 , 3000 , 4000 , 5000 , 6000 , 7000 , 8000, 9000, 10000]
    //var kmArrvalues: Array<Int> = [2 ,4, 6 , 8 , 10]
    var activeMinsValues: Array<Int> = [10, 20, 30, 40, 50, 60, 70]

    var barChart2: SimpleBarChart!
    var month_StepDayMOArr:[StepDayMO]!
    var week_StepDayMOArr:[StepDayMO]!

    var month_kmsDayMOArr:[KMsDayMO]!
    var week_kmsDayMOArr:[KMsDayMO]!
    var isComingFromList: Bool?
    var selectedBarIndex: Int? = nil
    var selectedCategoryGraphValue = "Steps"
    
 

    
//MARK: ViewLifeCycleDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        month_StepDayMOArr = DBManager.sharedDBManager.fetchStepsDatafromDB(ascending: false)
        self.title = "STEPS"
        week_StepDayMOArr = Array(month_StepDayMOArr.prefix(7))//month_StepDayMOArr[..<7]
        month_kmsDayMOArr = DBManager.sharedDBManager.fetchKMsDatafromDB(ascending: false)
        week_kmsDayMOArr = Array(month_kmsDayMOArr.prefix(7))
       btnSteps.isSelected = true
        self.setButtonProperties()
//        self.laodBarGraph2()
//        self.setContentSize()
//        barChart2.layoutIfNeeded()
        self.laodBarGraph2()
        setContentSize()
        
        
//        barChart2.reloadData()
        
      //  barChart2.layoutIfNeeded()


        // Do any additional setup after loading the view.
        self.FillTotalDetailOnTopView(selectedCategory: "Steps")
       
    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.laodBarGraph2()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // self.loadBarGraph()
        
        
        addTapGesture()
        mainScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 585 + 44 )
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: LoadGraph
    func laodBarGraph2()  {
        
        barChart2  = SimpleBarChart(frame: CGRect(x: 10, y: 10, width: barGraphView.frame.width + 200 , height: barGraphView.frame.height - 20))
        barChart2.incrementValue = 200
        barChart2.xLabelType = SimpleBarChartXLabelTypeHorizontal
        barGraphView.addSubview(barChart2)
        barChart2.delegate					= self;
        barChart2.dataSource				= self;
        barChart2.xLabelFont = KCALIBRI_REGULAR_14
        barChart2.yLabelFont = KCALIBRI_REGULAR_14
        
       //      self.view.layoutIfNeeded()

        barGraphScrollView.contentSize = CGSize(width: barGraphView.frame.width + 200, height: barGraphView.frame.height)
    }
    
    //MARK: SEGMENT DELEGATES
    
    @IBAction func segmentClicked(_ sender: UISegmentedControl){
//        if sender.selectedSegmentIndex == 0 {
//            barChart2.frame = CGRect(x: 10, y: 10, width: barGraphView.frame.width + 200 , height: barGraphView.frame.height - 20)
//            barGraphScrollView.contentSize = CGSize(width: barGraphView.frame.width + 200, height: barGraphView.frame.height)
//        }else{
//            barChart2.frame = CGRect(x: 10, y: 10, width: barGraphView.frame.width + 1000 , height: barGraphView.frame.height - 20)
//            barGraphScrollView.contentSize = CGSize(width: barGraphView.frame.width + 1000, height: barGraphView.frame.height)
//        }
//        setContentSize()
//       barChart2.reloadData()
        
        setContentSize()
       // barChart2.reloadData()
     //   barChart2.layoutIfNeeded()
        
        self.FillTotalDetailOnTopView(selectedCategory: selectedCategoryGraphValue)
    }
    
    //MARK: SimpleBarChartDataSource
    
    
    func numberOfBars(in barChart: SimpleBarChart!) -> UInt {
        if btnSteps.isSelected == true || btnActiveMinutes.isSelected == true || btnCalories.isSelected == true {
            if segmentedControl.selectedSegmentIndex == 0{
                return UInt(week_StepDayMOArr.count)
            }
            return UInt(month_StepDayMOArr.count)
        }else if btnKMS.isSelected == true {
            if segmentedControl.selectedSegmentIndex == 0{
                return UInt(week_StepDayMOArr.count)
            }
            return UInt(month_StepDayMOArr.count)
        }else{
           return 0 // Calories
        }
      
    }
    
    func barChart(_ barChart: SimpleBarChart!, valueForBarAt index: UInt) -> CGFloat {
        if btnSteps.isSelected == true {
            if segmentedControl.selectedSegmentIndex == 0{
                return CGFloat(week_StepDayMOArr[Int(index)].totalSteps)
            }
            return CGFloat(month_StepDayMOArr[Int(index)].totalSteps)
        }else if btnActiveMinutes.isSelected == true {
            if segmentedControl.selectedSegmentIndex == 0{
                return CGFloat(week_StepDayMOArr[Int(index)].activeSeconds/60)
            }
            return CGFloat(month_StepDayMOArr[Int(index)].totalSteps/60)
        }else if btnKMS.isSelected == true {
            if segmentedControl.selectedSegmentIndex == 0{
                return CGFloat((week_StepDayMOArr[Int(index)].totalSteps)/stepsinKMS)
            }
            return CGFloat((month_StepDayMOArr[Int(index)].totalSteps)/stepsinKMS)
        }else if btnCalories.isSelected == true {
            if segmentedControl.selectedSegmentIndex == 0{
                return CGFloat(week_StepDayMOArr[Int(index)].totalSteps/20.0)
            }
            return CGFloat(month_StepDayMOArr[Int(index)].totalSteps/20.0)
        }else{
            return 0 //Calories
        }
        
       
    }
    
//    func barChart(_ barChart: SimpleBarChart!, textForBarAt index: UInt) -> String! {
//         if btnSteps.isSelected == true || btnActiveMinutes.isSelected == true {
//            return String(format: "%d", stepsArrvalues[Int(index)])
//         }else if btnActiveMinutes.isSelected == true {
//            return String(format: "%d", activeMinsValues[Int(index)])
//         }else if btnKMS.isSelected == true {
//            return String(format: "%d", kmArrvalues[Int(index)])
//         }else{
//            return "0"
//        }
//    }
    
    func barChart(_ barChart: SimpleBarChart!, xLabelForBarAt index: UInt) -> String! {
        if btnSteps.isSelected == true || btnActiveMinutes.isSelected == true || btnCalories.isSelected == true {
            if segmentedControl.selectedSegmentIndex == 0{
                let arr = (week_StepDayMOArr[Int(index)].date)?.components(separatedBy: "-")
                return arr![2] + " " + monthDict[arr![1]]!
            }
            let arr = (month_StepDayMOArr[Int(index)].date)?.components(separatedBy: "-")
            return arr![2] + " " + monthDict[arr![1]]!
        }else if btnKMS.isSelected == true {
            if segmentedControl.selectedSegmentIndex == 0{
                let arr = (week_StepDayMOArr[Int(index)].date)?.components(separatedBy: "-")
                return arr![2] + " " + monthDict[arr![1]]!
            }
            let arr = (month_StepDayMOArr[Int(index)].date)?.components(separatedBy: "-")
            return arr![2] + " " + monthDict[arr![1]]!
        }else{
            return "0" //Calories
        }
    }
    
    func barChart(_ barChart: SimpleBarChart!, colorForBarAt index: UInt) -> UIColor! {
        if selectedBarIndex != nil && Int(index) == selectedBarIndex {
            return UIColor.white
        }else{
            return  UIColor.white
        }
    }
    
//    func animationDidEnd(for barChart: SimpleBarChart!) {
//        
//    }
   //MARK: ButtonAction
    @IBAction func btnStepsOnClick(_ sender: UIButton) {
         barChart2.incrementValue = 200
        btnSteps.backgroundColor = KSELECTEDBUTTONCOLOR
        btnKMS.backgroundColor = UIColor.white
        btnCalories.backgroundColor = UIColor.white
        btnActiveMinutes.backgroundColor = UIColor.white
        
        btnSteps.setImage(#imageLiteral(resourceName: "steps_selected"), for: .normal)
        btnKMS.setImage(#imageLiteral(resourceName: "Distance(km)_unselected"), for: .normal)
        btnCalories.setImage(#imageLiteral(resourceName: "Calories_unselected"), for: .normal)
        btnActiveMinutes.setImage(#imageLiteral(resourceName: "Active Minutes_unselected"), for: .normal)
        
        btnSteps.setTitleColor(UIColor.white, for: .normal)
        btnKMS.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnCalories.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnActiveMinutes.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnSteps.isSelected = true
        btnKMS.isSelected = false
        btnCalories.isSelected = false
        btnActiveMinutes.isSelected = false
        setContentSize()
      //  barChart2.reloadData()
      //  barChart2.layoutIfNeeded()
         selectedCategoryGraphValue = "Steps"
         self.FillTotalDetailOnTopView(selectedCategory:selectedCategoryGraphValue )
    }
    
    @IBAction func btnKmsOnClick(_ sender: UIButton) {
        barChart2.incrementValue = 1
        btnSteps.backgroundColor = UIColor.white
        btnKMS.backgroundColor = KSELECTEDBUTTONCOLOR
        btnCalories.backgroundColor = UIColor.white
        btnActiveMinutes.backgroundColor = UIColor.white
        
        btnSteps.setImage(#imageLiteral(resourceName: "Steps_unselected"), for: .normal)
        btnKMS.setImage(#imageLiteral(resourceName: "kms_selected"), for: .normal)
        btnCalories.setImage(#imageLiteral(resourceName: "Calories_unselected"), for: .normal)
        btnActiveMinutes.setImage(#imageLiteral(resourceName: "Active Minutes_unselected"), for: .normal)
        
        btnSteps.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnKMS.setTitleColor(UIColor.white, for: .normal)
        btnCalories.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnActiveMinutes.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnSteps.isSelected = false
        btnKMS.isSelected = true
        btnCalories.isSelected = false
        btnActiveMinutes.isSelected = false
        setContentSize()
       // barChart2.reloadData()
     //   barChart2.layoutIfNeeded()
         selectedCategoryGraphValue = "KM"
         self.FillTotalDetailOnTopView(selectedCategory: selectedCategoryGraphValue)
    }

    @IBAction func btnCaloriesOnClick(_ sender: UIButton) {
        barChart2.incrementValue = 10
        btnSteps.backgroundColor = UIColor.white
        btnKMS.backgroundColor = UIColor.white
        btnCalories.backgroundColor = KSELECTEDBUTTONCOLOR
        btnActiveMinutes.backgroundColor = UIColor.white
        
        btnSteps.setImage(#imageLiteral(resourceName: "Steps_unselected"), for: .normal)
        btnKMS.setImage(#imageLiteral(resourceName: "Distance(km)_unselected"), for: .normal)
        btnCalories.setImage(#imageLiteral(resourceName: "calories_selected"), for: .normal)
        btnActiveMinutes.setImage(#imageLiteral(resourceName: "Active Minutes_unselected"), for: .normal)
        
        btnSteps.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnKMS.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnCalories.setTitleColor(UIColor.white, for: .normal)
        btnActiveMinutes.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnSteps.isSelected = false
        btnKMS.isSelected = false
        btnCalories.isSelected = true
        btnActiveMinutes.isSelected = false
        setContentSize()
       // barChart2.reloadData()
       // barChart2.layoutIfNeeded()
        selectedCategoryGraphValue = "Calorie"
         self.FillTotalDetailOnTopView(selectedCategory: selectedCategoryGraphValue)
    }
    
    @IBAction func btnActiveMinutesOnCllick(_ sender: UIButton) {
         barChart2.incrementValue = 20
        btnSteps.backgroundColor = UIColor.white
        btnKMS.backgroundColor = UIColor.white
        btnCalories.backgroundColor = UIColor.white
        btnActiveMinutes.backgroundColor = KSELECTEDBUTTONCOLOR
        
        btnSteps.setImage(#imageLiteral(resourceName: "Steps_unselected"), for: .normal)
        btnKMS.setImage(#imageLiteral(resourceName: "Distance(km)_unselected"), for: .normal)
        btnCalories.setImage(#imageLiteral(resourceName: "Calories_unselected"), for: .normal)
        btnActiveMinutes.setImage(#imageLiteral(resourceName: "active_min_selected"), for: .normal)
        
        btnSteps.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnKMS.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnCalories.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnActiveMinutes.setTitleColor(UIColor.white, for: .normal)
        btnSteps.isSelected = false
        btnKMS.isSelected = false
        btnCalories.isSelected = false
        btnActiveMinutes.isSelected = true
        setContentSize()
       // barChart2.reloadData()
       // barChart2.layoutIfNeeded()
        selectedCategoryGraphValue = "Active"
         self.FillTotalDetailOnTopView(selectedCategory: selectedCategoryGraphValue)
    }
    
    @IBAction func showAllDataBtnClicked(_ sender: AnyObject){
        if isComingFromList != nil && isComingFromList == true{
            self.navigationController?.popViewController(animated: true)
        }else{
            if btnSteps.isSelected == true{
                self.performSegue(withIdentifier: "PedometerStepsTableViewController", sender: self)
            }else if btnActiveMinutes.isSelected == true {
                self.performSegue(withIdentifier: "PedometerCaloriesTableViewController", sender: self)
            }else if btnKMS.isSelected == true{
                self.performSegue(withIdentifier: "PedometerKMsTableViewController", sender: self)
            }else{
                self.performSegue(withIdentifier: "PedometerKMsTableViewController", sender: self)
            }

        }
    }
    
    @IBAction func showReminderBtnClicked(_ sender: AnyObject){
        self.performSegue(withIdentifier: "ReminderViewController", sender: self)
    }
    
    func setButtonProperties()  {
        btnSteps.backgroundColor = KSELECTEDBUTTONCOLOR
        btnSteps.setImage(#imageLiteral(resourceName: "steps_selected"), for: .normal)
        btnKMS.setImage(#imageLiteral(resourceName: "Distance(km)_unselected"), for: .normal)
        btnCalories.setImage(#imageLiteral(resourceName: "Calories_unselected"), for: .normal)
        btnActiveMinutes.setImage(#imageLiteral(resourceName: "Active Minutes_unselected"), for: .normal)
        
        btnSteps.setTitleColor(UIColor.white, for: .normal)
        btnKMS.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnCalories.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        btnActiveMinutes.setTitleColor(KCUSTOMBLACKCOLOR, for: .normal)
        
        btnSteps.dropShadow()
        btnActiveMinutes.dropShadow()
        btnKMS.dropShadow()
        btnCalories.dropShadow()
    }
    
    //MARK: SEGUE METHODS
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "PedometerStepsTableViewController" {
            let controller = segue.destination as! PedometerStepsTableViewController
            controller.isComingfromGraph = true
        }else if segue.identifier == "PedometerKMsTableViewController" {
            let controller = segue.destination as! PedometerKMsTableViewController
            controller.isComingfromGraph = true
        }else if segue.identifier == "PedometerCaloriesTableViewController" {
            let controller = segue.destination as! PedometerCaloriesTableViewController
            controller.isComingfromGraph = true
        }else if segue.identifier == "PedometerCaloriesTableViewController"{
            let controller = segue.destination as! PedometerCaloriesTableViewController
            controller.isComingfromGraph = true
        }else{
            
        }
    }
    
    //MARK: CUSTOM METHODS
    
    func FillTotalDetailOnTopView(selectedCategory : String){
        let todayDate = NSDate()
        let  dateFormater = DateFormatter()
        dateFormater.dateFormat = "h:mm:a"
        lblCurrentTime.text = dateFormater.string(from: todayDate as Date)
        lblSelectedCategory.text = selectedCategory
        if segmentedControl.selectedSegmentIndex == 0 {
            var weekTotalStep = 0.0
            var weekTotalKM = 0.0
            var weekTotalActiveMin = 0.0
            var weekTotalCalories = 0.0
            
            switch selectedCategory {
            case "Steps":
                for item in week_StepDayMOArr {
                    weekTotalStep +=  item.totalSteps
                    lblDailyAverage.text = "Daily Average " + String((weekTotalStep/7).rounded())
                    lblStep_KM_CaL_ActiveMin_Count.text = String(weekTotalStep.rounded()) + " " + selectedCategory
                }
                break
                
            case "KM":
                for item in week_StepDayMOArr {
                    
                    weekTotalKM +=  item.totalSteps/stepsinKMS
                    let avgKm = (weekTotalKM/7)
                    
                    
                    lblDailyAverage.text = "Daily Average " + avgKm.dollarString
                    lblStep_KM_CaL_ActiveMin_Count.text = String(weekTotalKM.rounded()) + " " + selectedCategory
                }
                break
                
            case "Calorie":
                for item in week_StepDayMOArr {
                    weekTotalCalories +=  item.totalSteps/20
                    lblDailyAverage.text = "Daily Average " + String((weekTotalCalories/7).rounded())
                    lblStep_KM_CaL_ActiveMin_Count.text = String(weekTotalCalories.rounded()) + " " + selectedCategory
                }
                break
                
            case "Active":
                for item in week_StepDayMOArr {
                    weekTotalActiveMin +=  Double(item.activeSeconds/60)
                    lblDailyAverage.text = "Daily Average " + String((weekTotalActiveMin/7).rounded())
                    lblStep_KM_CaL_ActiveMin_Count.text = String(weekTotalActiveMin.rounded()) + " " + selectedCategory
                }
                break
            default:
                break
            }
        
        }else{
            
            var weekTotalStep = 0.0
            var weekTotalKM = 0.0
            var weekTotalActiveMin = 0.0
            var weekTotalCalories = 0.0
            
            switch selectedCategory {
            case "Steps":
                for item in month_StepDayMOArr {
                    weekTotalStep +=  item.totalSteps
                    lblDailyAverage.text = "Daily Average " + String((weekTotalStep/7).rounded())
                    lblStep_KM_CaL_ActiveMin_Count.text = String(weekTotalStep.rounded()) + " " + selectedCategory
                }
                break
                
            case "KM":
                for item in month_StepDayMOArr {
                    
                    weekTotalKM +=  item.totalSteps/stepsinKMS
                    let avgKm = (weekTotalKM/Double(month_StepDayMOArr.count))
                    
                    
                    lblDailyAverage.text = "Daily Average " + avgKm.dollarString
                    lblStep_KM_CaL_ActiveMin_Count.text = String(weekTotalKM.rounded()) + " " + selectedCategory
                }
                break
                
            case "Calorie":
                for item in month_StepDayMOArr {
                    weekTotalCalories +=  item.totalSteps/20
                    lblDailyAverage.text = "Daily Average " + String((weekTotalCalories/Double(month_StepDayMOArr.count)).rounded())
                    lblStep_KM_CaL_ActiveMin_Count.text = String(weekTotalCalories.rounded()) + " " + selectedCategory
                }
                break
                
            case "Active":
                for item in month_StepDayMOArr {
                    weekTotalActiveMin +=  Double(item.activeSeconds/60)
                    lblDailyAverage.text = "Daily Average " + String((weekTotalActiveMin/Double(month_StepDayMOArr.count)).rounded())
                    lblStep_KM_CaL_ActiveMin_Count.text = String(weekTotalActiveMin.rounded()) + " " + selectedCategory
                }
                break
            default:
                break
            }
        
        }
        
        
    }
    
    func setContentSize() {
        
        DispatchQueue.main.async {
            if self.segmentedControl?.selectedSegmentIndex == SelectedSegment.week.rawValue{
//                if self.stepsArrvalues.count < 7{
//                    self.barGraphScrollView.contentSize = CGSize(width: CGFloat(self.ste psArrvalues.count*70), height: self.barGraphView.frame.height)
//                    
//                }else{
                
                    self.barGraphScrollView.contentSize = CGSize(width: CGFloat( self.week_StepDayMOArr.count*70), height: self.barGraphView.frame.height)
//                 }
            }else{
                self.barGraphScrollView.contentSize = CGSize(width: CGFloat(self.month_StepDayMOArr.count*70), height: self.barGraphView.frame.height)
            }
            if self.barGraphScrollView.contentSize.width < self.view.frame.size.width {
                self.barChart2.frame.size.width = self.view.frame.size.width
            }else{
                self.barChart2.frame.size.width = self.barGraphScrollView.contentSize.width
            }
            self.barChart2.reloadData()
            self.barChart2.layoutIfNeeded()
        }
        
    }
   
    /*
     UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
     [scrollView addGestureRecognizer:singleTap];
     */
    
    func addTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PedoMeterGraphViewController.tapGestureCaptured(_:)))
        gesture.numberOfTapsRequired = 1
        gesture.cancelsTouchesInView = false
       // gesture.numberOfTouchesRequired = 1
        self.barChart2.addGestureRecognizer(gesture)
        gesture.addTarget(self, action: #selector(PedoMeterGraphViewController.tapGestureCaptured(_:)))
        barGraphScrollView.addGestureRecognizer(gesture)
        
    }
    
    func tapGestureCaptured(_ sender: UITapGestureRecognizer){
        let touchPoint = sender.location(in: self.barGraphScrollView);
        if touchPoint.y >= 220 || touchPoint.x <= 10{
            return  // touch outside graph
        }
        let layer = self.barChart2.layer.sublayers![1]
        for (index, sublyr) in layer.sublayers!.enumerated() {
            let sublayer = sublyr as! CAShapeLayer
            print(sublayer.path!.currentPoint)
            if  touchPoint.x + 20 < (sublayer.path?.currentPoint.x)! {
                if touchPoint.y > 10 && (touchPoint.y-250) < (sublayer.path?.currentPoint.y)! {
                    print(index)
                    selectedBarIndex = index
//                    barChart2.reloadInputViews()
                    barChart2.animationDuration = 0
                    barChart2.reloadData()
                    barChart2.reloadInputViews()
                    barChart2.layoutSubviews()
                   break
                }
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: barChart2)
            for sublayer in self.view.layer.sublayers! {
                if sublayer.isKind(of: CAShapeLayer.self) {
                    let shapeLayer = sublayer as! CAShapeLayer
                    if (shapeLayer.path?.contains(location))! {
                        print("touch in layer")
                    }
//                    if shapeLayer.pat
                }
            }
        }
    }
    /*
     - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
     {
     for (UITouch *touch in touches) {
     CGPoint touchLocation = [touch locationInView:self.view];
     for (id sublayer in self.view.layer.sublayers) {
     BOOL touchInLayer = NO;
     if ([sublayer isKindOfClass:[CAShapeLayer class]]) {
     CAShapeLayer *shapeLayer = sublayer;
     if (CGPathContainsPoint(shapeLayer.path, 0, touchLocation, YES)) {
     // This touch is in this shape layer
     touchInLayer = YES;
     }
     } else {
     CALayer *layer = sublayer;
     if (CGRectContainsPoint(layer.frame, touchLocation)) {
     // Touch is in this rectangular layer
     touchInLayer = YES;
     }
     }
     }
     }
     }
     */
    
    

}

extension UIButton {
    
    func dropShadow(scale: Bool = true) {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        self.layer.cornerRadius = 2
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
}
}

extension Double {
    var dollarString:String {
        return String(format: "%.2f", self)
    }
}
