 //
//  NewHomeViewController.swift
//  Stetho Update
//
//  Created by Administrator on 12/05/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

 let KLASTSYNCDATE = "LastSyncDate"
 let totalKmsTarget: Float = 4

class NewHomeViewController: UIViewController, UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, AcitveMinsSyncedProtocol
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var reportCollectionView: UICollectionView!
    @IBOutlet weak var featuresCollectionView: UICollectionView!
    @IBOutlet weak var constraintHeightfeaturesCollectionView: NSLayoutConstraint!
    @IBOutlet weak var pedometerGraphView: UIView!
    @IBOutlet weak var sugarGraphView: UIView!
    @IBOutlet weak var waterGraphView: UIView!
    @IBOutlet weak var btnPedometerGraph: UIButton!
    @IBOutlet weak var btnSugarGraph: UIButton!
    @IBOutlet weak var btnWaterGraph: UIButton!

    @IBOutlet weak var lblSteps: UILabel!
    @IBOutlet weak var lblWaterIntake: UILabel!
    @IBOutlet weak var lblSugarIntake: UILabel!



    
    var padoMeterCircleChart: PNCircleChart?
    var waterCircleChart: PNCircleChart?
    var sugarCircleChart: PNCircleChart?



    var reportColotArr = [reportPinkColor, reportGreenColor, reportYellowColor, reportBlueColor]
    
    var featureArr:[String] = ["BOOK AN ORDER", "MY RECORDS", "CALL BACK", "REMINDER"]
    var subFeatureArr: [String] = ["Lets create history of your\nmedical records.", "Lets create history of your\nmedical records.", "Manage service via call back\noption for pick concerns.", "Medicine reminders &  test\nschedules."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        reportCollectionView.collectionViewLayout = layout
        constraintHeightfeaturesCollectionView.constant = 320
        fetchPadometerData()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.barTintColor = homeNavigationColor
        self.navigationItem.title = "Hament Miglani"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createWaterCircleChart()
        createSugarCircleChart()
       
    }
    
//
//    
//    //NOT IN USE
//    var runnerCircleChart: PNCircleChart!
//    @IBOutlet var runnerGraphView : UIView!
//    @IBOutlet var lblRunnerDetails : UILabel!
//    
//    var dietCircleChart: PNCircleChart!
//    @IBOutlet var dietGraphView : UIView!
//    @IBOutlet var lblDietDetails : UILabel!
//    
//    var waterCircleChart: PNCircleChart!
//    @IBOutlet var waterGraphView : UIView!
//    @IBOutlet var lblWaterDetails : UILabel!
//    
//    
//    
//    @IBOutlet weak var backScrollView: UIScrollView!
//    @IBOutlet weak var offerScrollBGView: UIView!
//    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var pageControl: UIPageControl!
//    
//    @IBOutlet var categoryCollectionView: UICollectionView!
//    @IBOutlet var constraintCollectionHeight: NSLayoutConstraint!
//            
//    //TEMPORARY
//    var noofCells = 5
//    let cellWidth = UIScreen.main.bounds.size.width/2 //self.view.frame.width/2
//    var collectionViewHeight: CGFloat?
//    
    var isStepsSynced: Bool? = false
    //var isKMsSynced: Bool? = false
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        
//        
//        categoryCollectionView.isScrollEnabled = false
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.isPagingEnabled = true
//        pageControl.numberOfPages = 5
//        pageControl.currentPage = 0
//        pageControl.pageIndicatorTintColor = UIColor.darkGray
//        pageControl.currentPageIndicatorTintColor = UIColor(red: 224/255.0, green: 34/255.0, blue: 45/255.0, alpha: 1.0)
//        addCustomView()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
////        self.createDietCircleChart()
////        self.createWaterCircleChart()
////        self.createRunnerCircleChart()
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//       // self.navigationController?.isNavigationBarHidden = true
//        authorizeHealthkit()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        scrollView.contentSize = CGSize(width: (KMAINSCREENWIDTH * CGFloat(pageControl.numberOfPages)), height: 0)
//        
//        //constraintCollectionHeight
//        if noofCells%2 == 0{
//            collectionViewHeight = cellWidth + (CGFloat(noofCells/2)*cellWidth)
//        }else{
//            collectionViewHeight = cellWidth + ((CGFloat(noofCells/2)+1)*cellWidth)
//        }
//        backScrollView.contentSize = CGSize(width: 0, height: collectionViewHeight! + 45) //45 is add button height
//        constraintCollectionHeight.constant = collectionViewHeight!
//        
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
    //MARK: HEALTHKIT AUTHORIZE
//
    func authorizeHealthkit(){
        
        let backgroundQueue = DispatchQueue.global(qos: .background)
        //        backgroundQueue.qos = .background
        if HealthManager.sharedHealthManger.isHealthkitAuthorize() == .sharingDenied {
            self.showAlert(title: nil, message: "Please provide permission to read Healthkit data from Settings")
            return
        }else{
            
            backgroundQueue.async {
                HealthManager.sharedHealthManger.authrizeHealthKit { (success, error) in
                    if success {
                        if let _ = UserDefaults.standard.object(forKey: KLASTSYNCDATE) {
                            let strDate = UserDefaults.standard.string(forKey: KLASTSYNCDATE)
                            self.isStepsSynced = false
                            //isKMsSynced = false
                            DispatchQueue.main.async {
                                self.showActivityIndicator(text:  "Syncing...")
                            }
                          //  backgroundQueue.async {
                                HealthManager.sharedHealthManger.readStatisticsStepsDataforPeriod(startDate: GlobalInfo.sharedGlobalInfo.dateFormatterWithGMT0.date(from: strDate!)!, completion: {
                                    print("Syncing Period")
                                    if HealthManager.sharedHealthManger.stepDayMOArr.count > 0{
                                        HealthManager.sharedHealthManger.delegateActiveMins = self
                                        HealthManager.sharedHealthManger.fetchActiveMins(fromIndex: 0)
                                        
                                    }
                                })
                           // }
                            //will read data of any time interval
                        }else{
                            backgroundQueue.async {
                                HealthManager.sharedHealthManger.authrizeHealthKit { (success, error) in
                                    if success {
                                        print("Syncing...")
                                        DispatchQueue.main.async {
                                            self.showActivityIndicator(text:  "Syncing...")
                                        }
                                        HealthManager.sharedHealthManger.readStaisticsData {
                                            HealthManager.sharedHealthManger.stepDayMOArr = DBManager.sharedDBManager.fetchStepsDatafromDB(ascending: true)
                                            
                                            if HealthManager.sharedHealthManger.stepDayMOArr.count > 0{
                                                HealthManager.sharedHealthManger.delegateActiveMins = self
                                                HealthManager.sharedHealthManger.fetchActiveMins(fromIndex: 0)
                                                
                                            }
                                            
                                        }
                                        //                                HealthManager.sharedHealthManger.readStaisticsKMsData {
                                        //                                    self.isKMsSynced = true
                                        //                                    self.checkSync()
                                        //                                }
                                    }else{
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                
                
//                if let _ = UserDefaults.standard.object(forKey: KLASTSYNCDATE) {
//                    let strDate = UserDefaults.standard.string(forKey: KLASTSYNCDATE)
//                    isStepsSynced = false
//                    //isKMsSynced = false
//                    self.showActivityIndicator(text:  "Syncing...")
//                    backgroundQueue.async {
//                        HealthManager.sharedHealthManger.readStatisticsStepsDataforPeriod(startDate: GlobalInfo.sharedGlobalInfo.dateFormatterWithGMT0.date(from: strDate!)!, completion: {
//                            print("Syncing Period")
//                            if HealthManager.sharedHealthManger.stepDayMOArr.count > 0{
//                                HealthManager.sharedHealthManger.delegateActiveMins = self
//                                HealthManager.sharedHealthManger.fetchActiveMins(fromIndex: 0)
//                            }
//                        })
//                    }
//                    //will read data of any time interval
//                }else{
//                    backgroundQueue.async {
//                        HealthManager.sharedHealthManger.authrizeHealthKit { (success, error) in
//                            if success {
//                                print("Syncing...")
//                                DispatchQueue.main.async {
//                                    self.showActivityIndicator(text:  "Syncing...")
//                                }
//                                HealthManager.sharedHealthManger.readStaisticsData {
//                                    HealthManager.sharedHealthManger.stepDayMOArr = DBManager.sharedDBManager.fetchStepsDatafromDB(ascending: true)
//                                    
//                                    if HealthManager.sharedHealthManger.stepDayMOArr.count > 0{
//                                        HealthManager.sharedHealthManger.delegateActiveMins = self
//                                        HealthManager.sharedHealthManger.fetchActiveMins(fromIndex: 0)
//                                        
//                                    }
//                                    
//                                }
//                                //                                HealthManager.sharedHealthManger.readStaisticsKMsData {
//                                //                                    self.isKMsSynced = true
//                                //                                    self.checkSync()
//                                //                                }
//                            }else{
//                                
//                            }
//                        }
//                    }
//                }
                
            }
            
        }
    }

    func checkSync(){
        if  isStepsSynced! { //isKMsSynced! &&
            let lastSyncDate = UserDefaults.standard.string(forKey: KLASTSYNCDATE)
            
            print(GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date()))
            UserDefaults.standard.set(GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date()), forKey: KLASTSYNCDATE)
            DispatchQueue.main.async {
                self.hideActivityIndicator()
                self.createpadoMeterCircleChart()
            }
            savePadometerdatatoServer(lastSyncDate: lastSyncDate)
            
        }
    }
    
    func savePadometerdatatoServer(lastSyncDate: String?) {
        var stepsDayMOArr:[StepDayMO] = []
        if lastSyncDate != nil {   
           stepsDayMOArr = HealthManager.sharedHealthManger.stepDayMOArr
        }else{
             stepsDayMOArr = DBManager.sharedDBManager.fetchStepsDatafromDB(ascending: false)
        }
        
            let jsonCompatibleArray = stepsDayMOArr.map { model in
                return [
                    "ACA_ID" : "57645",
                    "TARGET_STEP": model.targetSteps,
                    "COMPLETE_STEP":model.totalSteps,
                    "FORDATE":model.date!,
                    "Active_Min": String(format: "%g", round(Float(model.activeSeconds)/60.0))
                ]
            }
            do{
                let data = try JSONSerialization.data(withJSONObject: jsonCompatibleArray, options: JSONSerialization.WritingOptions.prettyPrinted)
                let jsonString = String(data: data, encoding: String.Encoding.utf8)
                
                DispatchQueue.main.async {
                    self.showActivityIndicator(text: "Loading")
                }
                let service = StethoUpdateService.sharedService
                service.hitService(dictInfo: ["jsonMaster": jsonString!], methodName: "SaveStepSummaryIOS")
                service.getSuccessResponse = { (responseInfoStr, responseInfoDict, methodName) in
                    self.hideActivityIndicator()
                    if responseInfoStr != nil && responseInfoStr!.isEmpty {
                        print(responseInfoStr!)
                        print("contains no data")
                        
                    }else if responseInfoStr != nil {
                        print("Data Saved")
                    }else{
                        print(responseInfoDict!)
                    }
                }
                
                service.getFailureResponse = { (responseStr, methodName) in
                    self.hideActivityIndicator()
                    self.showAlert(title: nil, message: responseStr)
                    
                }
                


            }catch {
                
            }
        }
//
//    //MARK: SCROLLVIEW DELEGATES
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView == self.backScrollView{
//           // categoryCollectionView.contentOffset = scrollView.contentOffset
//        }
//    }
//    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView == self.scrollView {
//            print("Decelerating called")
//            let page = scrollView.contentOffset.x/KMAINSCREENWIDTH
//            self.pageControl.currentPage = Int(round(page))
//            scrollView.contentOffset = CGPoint(x: CGFloat((round(page))*KMAINSCREENWIDTH), y: 0)
//        }
//    }
//    
//    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: 0, height: 640)
    }
    
    //MARK: COLLECTIONVIEW DELEGATES
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == featuresCollectionView {
          return 4
        }
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == reportCollectionView {
            let  reportCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReportCollectionViewCell", for: indexPath) as! ReportCollectionViewCell
            reportCollectionViewCell.lblDate.text = "MAR'15 24"
            let str = "MAR'15\n24"
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = .center
            
            let mutableString = NSMutableAttributedString(string: str)
           
            mutableString.addAttributes([NSFontAttributeName:KCALIBRI_REGULAR_12!, NSParagraphStyleAttributeName: titleParagraphStyle], range: NSRange(location:0,length:6))
            
            mutableString.addAttributes([NSFontAttributeName:KCALIBRI_REGULAR_30!, NSParagraphStyleAttributeName: titleParagraphStyle], range: NSRange(location:7,length:str.characters.count-7))
            mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 98/255.0, green: 98/255.0, blue: 97/255.0, alpha: 1.0), range: NSRange(location:0,length:str.characters.count))
            reportCollectionViewCell.lblDate.attributedText = mutableString
            reportCollectionViewCell.innerView.layer.borderColor = reportColotArr[indexPath.row%4].cgColor
            reportCollectionViewCell.outerView.layer.borderColor = reportColotArr[indexPath.row%4].cgColor
             return reportCollectionViewCell
        }else{
            let  homeFeatureCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeFeatureCollectionViewCell", for: indexPath) as! HomeFeatureCollectionViewCell
            homeFeatureCollectionViewCell.lblNameFeature.text = featureArr[indexPath.row]
            homeFeatureCollectionViewCell.lblSubheadingFeature?.text = subFeatureArr[indexPath.row]
            homeFeatureCollectionViewCell.imgFeature.image = UIImage(named: featureArr[indexPath.row])
            return homeFeatureCollectionViewCell
        }
    }
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAt indexPath:IndexPath) -> CGSize
    {
        //check your conditions here ex: device, iOS version then return
        if collectionView == reportCollectionView {
            return CGSize(width: 90, height: 90)
        }else{
            return CGSize(width: (featuresCollectionView.frame.size.width-14)/2, height: 155)
        }
       // return CGSize(width:
           // (reportCollectionView.frame.size.width-14/2), height: 146)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == reportCollectionView {
             return 10
        }
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        
//        let pedoMeterVC = KPEDOMETERSTORYBOARD.instantiateViewController(withIdentifier: "HomePedoMeterViewController") as! HomePedoMeterViewController
//        self.navigationController?.pushViewController(pedoMeterVC, animated: true)
        
//        let homeWaterVC = KWATERSTORYBOARD.instantiateViewController(withIdentifier: "HomeWaterViewController") as! HomeWaterViewController
//        self.navigationController?.pushViewController(homeWaterVC, animated: true)
        
        

//        if indexPath.row == 1 {
//            let stepsTableViewController = KPEDOMETERSTORYBOARD.instantiateViewController(withIdentifier: "PedometerStepsTableViewController") as! PedometerStepsTableViewController
//            self.navigationController?.pushViewController(stepsTableViewController, animated: true)
//
//        }else{
//            let pedoMeterVC = KPEDOMETERSTORYBOARD.instantiateViewController(withIdentifier: "HomePedoMeterViewController") as! HomePedoMeterViewController
//            self.navigationController?.pushViewController(pedoMeterVC, animated: true)
//        }

    }
//
    //MARK: IBACTIONS

    @IBAction func pedometerBtnClicked(_ sender: AnyObject){
      self.performSegue(withIdentifier: "HomePedoMeterViewController", sender: self)
    }
    
    @IBAction func waterBtnClicked(_ sender: AnyObject){
        self.performSegue(withIdentifier: "HomeWaterViewController", sender: self)
    }
    
    @IBAction func sugarBtnClicked(_ sender: AnyObject){
        self.performSegue(withIdentifier: "HomeSugarViewController", sender: self)
    }
    
    //MARK: SERVICE AND DELEGATES
    
    func fetchPadometerData() {
        self.showActivityIndicator(text: "Loading...")
        let service = StethoUpdateService.sharedService
        service.hitService(dictInfo: ["ACA_ID": "57645"], methodName: "FetchStepSummaryIOS")
        service.getSuccessResponse = { (responseInfoStr, responseInfoArr, methodName) in
           self.hideActivityIndicator()
            
            
            if responseInfoStr != nil && responseInfoStr!.isEmpty == true {
                print(responseInfoStr!)
                self.setHealthData()
                print("contains no data")

            }else{
                print(responseInfoArr!)
                let dictArray = self.makeDictionariesofWater_Steps_Sugar(infoArr: responseInfoArr!)
                print(dictArray.stepsArr)
                print(dictArray.waterArr)
                print(dictArray.sugarArr)

                SugarDayMO.saveSugarMOArr(arr: dictArray.sugarArr.reversed(), completion: {
                    print("Suger data Saved to DB")
                    self.createSugarCircleChart()
                })
                
                WaterDayMO.saveWaterMOArr(arr: dictArray.waterArr.reversed(), completion: {
                    print("Water data Saved to DB")
                    self.createWaterCircleChart()
                })
                
                if UserDefaults.standard.string(forKey: KLASTSYNCDATE) == nil{
                    
                    StepDayMO.saveStepMOArr(arr: responseInfoArr!.reversed(), completion: { _ in
                        print("Data Synced")
                        self.setHealthData()
                        
                    })
                    // will save it to our db
                }else{
                    self.setHealthData()
                }
            }
        }
    }
    
    

    //MARK: CUSTOM METHODS
    
    func activeMinsSyncedSuccessfully() {
        self.isStepsSynced = true
        self.checkSync()
        print("Synced")
    }
    
    func makeDictionariesofWater_Steps_Sugar(infoArr: Array<Dictionary<String, Any>>)->(waterArr:Array<Dictionary<String, Any>>, sugarArr: Array<Dictionary<String, Any>>, stepsArr: Array<Dictionary<String, Any>>) {
        let stepArr: [Dictionary<String, Any>]!
        let sugarArr: [Dictionary<String, Any>]!
        let waterArr: [Dictionary<String, Any>]!

        stepArr = infoArr.filter { model in
            model["Type"] as! String == "P"
        }
        
        sugarArr = infoArr.filter { model in
            model["Type"] as! String == "S"
        }
        
        waterArr = infoArr.filter { model in
            model["Type"] as! String == "W"
        }
        return (waterArr, sugarArr, stepArr)
    }
    
    func setHealthData() {
        
        authorizeHealthkit()
    }
    
        func createpadoMeterCircleChart(){
            let stepDayMO = DBManager.sharedDBManager.fetchStepDataforDay(date: GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date()))
//            let kmDayMO = DBManager.sharedDBManager.fetchKMsDataforDay(date: GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date()))

            if padoMeterCircleChart == nil{
                padoMeterCircleChart = PNCircleChart(frame: CGRect(x: 10, y: 5, width: pedometerGraphView.frame.width - 20 , height: pedometerGraphView.frame.height - 45), total: NSNumber(value: (stepDayMO!.targetSteps/1250)), current: NSNumber(floatLiteral: (stepDayMO!.totalSteps/1250)), clockwise: true, shadow: false, shadowColor: UIColor.lightGray.withAlphaComponent(0.2))
                padoMeterCircleChart?.backgroundColor = UIColor.clear
                padoMeterCircleChart?.strokeColor = KPEDOMETERNAVICOLOR
                padoMeterCircleChart?.displayCountingLabel = false
                padoMeterCircleChart?.displayAnimated = true
                pedometerGraphView.addSubview(padoMeterCircleChart!)
                
                lblSteps.text = String(format: "%@ / %g", String(format: "%.2g", ((stepDayMO!.totalSteps/1250).roundToPlaces(places: 2))), (stepDayMO!.targetSteps/1250))
            }else{
                padoMeterCircleChart?.total = NSNumber(value: (stepDayMO!.targetSteps/1250))
                padoMeterCircleChart?.current = NSNumber(floatLiteral: (stepDayMO!.totalSteps/1250))
            }
            padoMeterCircleChart?.stroke()
            pedometerGraphView.bringSubview(toFront: btnPedometerGraph)
        }
    
    func createWaterCircleChart(){
        var waterDayMO = DBManager.sharedDBManager.fetchWaterDataforDay(date: GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date()))
        if waterDayMO == nil {
            let waterDayMO = WaterDayMO.createWaterDayModel()
            waterDayMO.creationDate = Date() as NSDate
            waterDayMO.date = GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date())
            waterDayMO.totalWaterDrink = 0
            waterDayMO.totalWaterTarget = totalWaterDrinkinLitre
            DBManager.sharedDBManager.saveContext()
        }
        waterDayMO = DBManager.sharedDBManager.fetchWaterDataforDay(date: GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date()))
        
        lblWaterIntake.text = String(format: "%g / %g",  (waterDayMO?.totalWaterDrink)!, (waterDayMO?.totalWaterTarget)!)
        
        if waterCircleChart == nil{
            waterCircleChart = PNCircleChart(frame: CGRect(x: 10, y: 20, width: waterGraphView.frame.width - 20 , height: 80), total: NSNumber(floatLiteral: Double((waterDayMO?.totalWaterTarget)!)), current:  NSNumber(floatLiteral: Double((waterDayMO?.totalWaterDrink)!)), clockwise: true, shadow: false, shadowColor:  UIColor.lightGray.withAlphaComponent(0.2))
            waterCircleChart?.backgroundColor = UIColor.clear
            waterCircleChart?.strokeColor = waterNavigationColor
            waterCircleChart?.displayCountingLabel = false
            waterCircleChart?.displayAnimated = true
            waterCircleChart?.stroke()
            waterGraphView.addSubview(waterCircleChart!)
            
            //  pedometerGraphView.bringSubview(toFront: btnGraph)
        }else{
            waterCircleChart?.total = NSNumber(floatLiteral: Double((waterDayMO?.totalWaterTarget)!))
            waterCircleChart?.current = NSNumber(floatLiteral: Double((waterDayMO?.totalWaterDrink)!))
        }
         waterCircleChart?.stroke()
        waterGraphView.bringSubview(toFront: btnWaterGraph)
    }
    
    func createSugarCircleChart(){
        var sugarDayMO = DBManager.sharedDBManager.fetchSugarDataforDay(date: GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date()))
        if sugarDayMO == nil {
            let sugarDayMO = SugarDayMO.createSugarDayModel()
            sugarDayMO.creationDate = Date() as NSDate
            sugarDayMO.date = GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date())
            sugarDayMO.totalSugarIntake = 0
            sugarDayMO.totalSugarTarget = totalSugarIntakeinGram
            DBManager.sharedDBManager.saveContext()
        }
        sugarDayMO = DBManager.sharedDBManager.fetchSugarDataforDay(date: GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date()))
        
        lblSugarIntake.text = String(format: "%g / %g",  (sugarDayMO?.totalSugarIntake)!, (sugarDayMO?.totalSugarTarget)!)
        
        
        
        if sugarCircleChart == nil{
            
            sugarCircleChart = PNCircleChart(frame: CGRect(x: 10, y: 20, width: waterGraphView.frame.width - 20 , height: 80), total:  NSNumber(floatLiteral: Double((sugarDayMO?.totalSugarTarget)!)), current:  NSNumber(floatLiteral: Double((sugarDayMO?.totalSugarIntake)!)), clockwise: true, shadow: false, shadowColor: UIColor.lightGray.withAlphaComponent(0.2))
            
            sugarCircleChart?.backgroundColor = UIColor.clear
            sugarCircleChart?.strokeColor = sugarNavigationColor
            sugarCircleChart?.displayCountingLabel = false
            sugarCircleChart?.displayAnimated = true
            sugarGraphView.addSubview(sugarCircleChart!)
        }else{
            sugarCircleChart?.current = NSNumber(floatLiteral: Double((sugarDayMO?.totalSugarIntake)!))
            sugarCircleChart?.total = NSNumber(floatLiteral: Double((sugarDayMO?.totalSugarTarget)!))
        }
        sugarCircleChart?.stroke()
        sugarGraphView.bringSubview(toFront: btnSugarGraph)

        
    }
//
//  /*  func makePieChart(totalValue: Int, currentValue: Int){
//        pieChart.current =  NSNumber(integerLiteral: 0)
//        pieChart.total = NSNumber(integerLiteral: 0)
//        pieChart!.stroke()
//       // lblPercentage.text = String(format: "%d\nout of \n%d", currentValue, totalValue)
//        
//    } */
//    
//    func addCustomView(){
//        for i in 0..<pageControl.numberOfPages {
//            let homeOfferView = HomeOfferView.instanceFromNib() as! HomeOfferView //CustomView(uid: "") //CustomView(frame: "")
//            homeOfferView.frame = CGRect(x: CGFloat(i*Int(KMAINSCREENWIDTH)), y: scrollView.frame.origin.y, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
//            homeOfferView.imageView.image = UIImage(named: String(format: "image%d",i+1))
////            homeOfferView.lblTitle.text = titleArr[i]
////            homeOfferView.subTitle.text = subTitleArr[i]
//            self.scrollView.addSubview(homeOfferView)
//        }
//    }
//    
//    //MARK: TODO NOT IN USE
//    func createRunnerCircleChart(){
//        if runnerCircleChart == nil{
//            runnerCircleChart = PNCircleChart(frame: runnerGraphView.bounds, total: 0, current: 0, clockwise: false, shadow: false, shadowColor: UIColor(red: 250/255.0, green: 200/255.0, blue: 46/255.0, alpha: 1.0))
//          //  pieChart = PNCircleChart(frame: CGRect(x: 5, y: 5, width: runnerGraphView.frame.size.width - 10, height: runnerGraphView.frame.size.height - 10), total: 0, current: 0, clockwise: false, shadow: false, shadowColor: UIColor.red)
//            runnerCircleChart!.backgroundColor = UIColor.clear
//            runnerCircleChart!.strokeColor = UIColor.white
//            runnerCircleChart.displayCountingLabel = false
//            runnerCircleChart?.lineWidth = 0.5
//            runnerGraphView.addSubview(runnerCircleChart!)
//            lblRunnerDetails.text = String(format: "%d\n steps \n%d \n target", 10, 0)
//            
//            let aa = "10"
//            let bb = "0"
//            // set label Attribute
//            let fRange = NSRange(location: 0, length: aa.characters.count)
//            let sRange = NSRange(location: fRange.length + "steps".characters.count + 4 , length: bb.characters.count) //  4  & \n space
//            
//            lblRunnerDetails.attributedText = GetAttributedText(inputText: lblRunnerDetails.text!, firstRange: fRange, secondRange: sRange, staticText_1: 5, staticText_2: 6 , textColor: UIColor(red: 250/255.0, green: 200/255.0, blue: 46/255.0, alpha: 1.0))
//        }
//        
//    }
//    
//    
//    func createDietCircleChart(){
//        if dietCircleChart == nil{
//            dietCircleChart = PNCircleChart(frame: dietGraphView.bounds, total: 0, current: 0, clockwise: false, shadow: false, shadowColor: UIColor(red: 153/255.0, green: 191/255.0, blue: 81/255.0, alpha: 1.0))
//            //  pieChart = PNCircleChart(frame: CGRect(x: 5, y: 5, width: runnerGraphView.frame.size.width - 10, height: runnerGraphView.frame.size.height - 10), total: 0, current: 0, clockwise: false, shadow: false, shadowColor: UIColor.red)
//            dietCircleChart!.backgroundColor = UIColor.clear
//            dietCircleChart!.strokeColor = UIColor.white
//            dietCircleChart.displayCountingLabel = false
//            dietCircleChart?.lineWidth = 2.0
//            dietGraphView.addSubview(dietCircleChart!)
//            lblDietDetails.text = String(format: "%d\n steps \n%d \n target", 1233, 6555)
//            
//            
//            let aa = "1233"
//            let bb = "6555"
//            // set label Attribute
//            let fRange = NSRange(location: 0, length: aa.characters.count)
//            let sRange = NSRange(location: fRange.length + "steps".characters.count + 4 , length: bb.characters.count)
//            
//            lblDietDetails.attributedText = GetAttributedText(inputText: lblDietDetails.text!, firstRange: fRange, secondRange: sRange, staticText_1: 5, staticText_2: 6 ,textColor:  UIColor(red: 153/255.0, green: 191/255.0, blue: 81/255.0, alpha: 1.0))
//        }
//        
//    }
//    
//    
//    func createWaterCircleChart(){
//        if waterCircleChart == nil{
//            waterCircleChart = PNCircleChart(frame: waterGraphView.bounds, total: 0, current: 0, clockwise: false, shadow: false, shadowColor: UIColor.init(colorLiteralRed: 36/255.0, green: 210/255.0, blue: 235/255.0, alpha: 1))
//            //  pieChart = PNCircleChart(frame: CGRect(x: 5, y: 5, width: runnerGraphView.frame.size.width - 10, height: runnerGraphView.frame.size.height - 10), total: 0, current: 0, clockwise: false, shadow: false, shadowColor: UIColor.red)
//            waterCircleChart!.backgroundColor = UIColor.clear
//            waterCircleChart!.strokeColor = UIColor.white
//            waterCircleChart.displayCountingLabel = false
//            waterCircleChart?.lineWidth = 2.0
//            waterGraphView.addSubview(waterCircleChart!)
//            lblWaterDetails.text =  String(format: "%d\n Consumed \n%d \n target", 12333, 6559995)
//            
//          
//          
//           
//          
//            let aa = "12333"
//            let bb = "6559995"
//            
//         
//            // set label Attribute
//            let fRange = NSRange(location: 0, length: aa.characters.count)
//            let sRange = NSRange(location: fRange.length + "Consumed".characters.count + 4, length: bb.characters.count)
//            
//            lblWaterDetails.attributedText = GetAttributedText(inputText: lblWaterDetails.text!, firstRange: fRange, secondRange: sRange, staticText_1: 8, staticText_2: 6 , textColor: UIColor(red:  36/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1.0))
//        }
//        
//    }
//    
//    func GetAttributedText(inputText:String, firstRange : NSRange , secondRange : NSRange , staticText_1 : Int , staticText_2 : Int , textColor : UIColor) -> NSMutableAttributedString {
//        
//        let myMutableString = NSMutableAttributedString(string: inputText, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 16.0)!])
//       
//        
//        myMutableString.addAttribute(NSForegroundColorAttributeName, value: textColor, range: firstRange)
//        
//        myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "Georgia", size: 10.0)!, range: NSRange(location: firstRange.length + 2 , length: staticText_1))
//        
//         myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.gray, range:  NSRange(location: firstRange.length + 2 , length: staticText_1))
//        
//        
//        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: secondRange)
//        
//        myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "Georgia", size: 10.0)!, range: NSRange(location: secondRange.location + secondRange.length + 3 , length: staticText_2))
//        
//         myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.gray, range: NSRange(location: secondRange.location + secondRange.length + 3 , length: staticText_2))
//        return myMutableString
//        
//    }
}


extension UIViewController {
    
    func showAlert(title: String?, message: String?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style:
            .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    func showActivityIndicator(text: String?) {
        var text = text
        if text == nil{
            text = "Loading"
        }
        ActivityIndicator.sharedAcitvityIndicator.labelLoading.text = text
        self.view.addSubview(ActivityIndicator.sharedAcitvityIndicator.loadingView)
        ActivityIndicator.sharedAcitvityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    func hideActivityIndicator() {
       ActivityIndicator.sharedAcitvityIndicator.loadingView.removeFromSuperview()
        ActivityIndicator.sharedAcitvityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
   
}
 
 

