//
//  HomePedoMeterViewController.swift
//  Stetho Update
//
//  Created by HW-Anil on 7/13/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

var averageSteps: Double = 10000
class HomePedoMeterViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , UITableViewDelegate , UITableViewDataSource {
    @IBOutlet weak var calenderCollectionView : UICollectionView!
    @IBOutlet weak var mainBGView: UIView!
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var lblTargate : UILabel!
    @IBOutlet weak var lblCompleted : UILabel!
    var padoMeterCircleChart: PNCircleChart!
    @IBOutlet weak var btnGraph : UIButton!
    
    @IBOutlet weak var btnEnableDisable: UIButton!
    
    
    @IBOutlet var padoMeterGraphView : UIView!
    var pedoMeterList : [String] = [KSTEPS , KDISTANCE ,KCALORIES,KACTIVEMINUTES]
    var pedoMeterListData : [String] = []
    var progressTintColor = [KSTEPSBGPROGRESSCOLOR ,KDISTANCEBGPROGRESSCOLOR, KCALORIESBGPROGRESSCOLOR,KACTIVEMINUTESPROGRESSCOLOR]
    var stepsDayMOArr:[StepDayMO] = []
    var kmsDayMOArr:[KMsDayMO] = []
    var selectedCollectionIndexpath:IndexPath? = IndexPath(row: 0, section: 0)
    
//MARK: VIEWLIFECYCLEDELEGATE
    override func viewDidLoad() {
        super.viewDidLoad()
        addRightBarButtonItems()
        // Do any additional setup after loading the view.
        btnEnableDisable.isSelected = false
        tableView.isScrollEnabled = false
        stepsDayMOArr = DBManager.sharedDBManager.fetchStepsDatafromDB(ascending: true)
        kmsDayMOArr = DBManager.sharedDBManager.fetchKMsDatafromDB(ascending: true)
        selectedCollectionIndexpath?.row = stepsDayMOArr.index(of: stepsDayMOArr.last!)!
        
        calenderCollectionView.reloadData()
        self.calenderCollectionView.performBatchUpdates({}) { (finished) in
            self.calenderCollectionView.scrollToItem(at: self.selectedCollectionIndexpath!, at: UICollectionViewScrollPosition.right, animated: true)
        }
        
        updatePedomterTargetValueforSelectedIndex(index: selectedCollectionIndexpath!.row)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        lblTargate.attributedText = self.changeFontAndColor(str1: "11111" + "\n", str2: "Target",font1: KROBOTO_MEDIUM_22! ,font2:KROBOTO_REGULAR_14!)
//       lblCompleted.attributedText = self.changeFontAndColor(str1: "3780" + "\n", str2: "Completed",font1: KROBOTO_MEDIUM_22! ,font2:KROBOTO_REGULAR_14!)
       
         self.navigationController?.navigationBar.isTranslucent = false
         self.navigationController?.navigationBar.barTintColor = KPEDOMETERNAVICOLOR
        self.navigationController?.navigationBar.topItem?.title = "Step Tracking"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         self.createpadoMeterCircleChart()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mainScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 623 + 44)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: COLLECTIONVIEWDELEGATE
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stepsDayMOArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let homePedometerCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePedometerCollectionViewCell", for: indexPath) as! HomePedometerCollectionViewCell
        homePedometerCollectionViewCell.layer.cornerRadius = 4
        homePedometerCollectionViewCell.layer.borderWidth = 0.5
        homePedometerCollectionViewCell.layer.borderColor = UIColor.lightGray.cgColor
        let stepsDayMO = stepsDayMOArr[indexPath.row]
//        let kmsDayMO = kmsDayMOArr[indexPath.row]
//        let date = sdateComp?[1]tepsDayMO.date?.components(separatedBy: "at")[0]
        
        let dateComp = stepsDayMO.date?.components(separatedBy: "-")
        homePedometerCollectionViewCell.lblDay.text = dateComp?[2]
        homePedometerCollectionViewCell.lblMonth.text = monthDict[dateComp![1]]
        homePedometerCollectionViewCell.lblRating.text = String(format: "%.1f", (((stepsDayMO.totalSteps/stepsDayMO.targetSteps)*100)*5)/100)
        
        homePedometerCollectionViewCell.backgroundColor = UIColor.white
        homePedometerCollectionViewCell.lblDay.textColor = dateMonthRatingColor
        homePedometerCollectionViewCell.lblMonth.textColor = dateMonthRatingColor
        homePedometerCollectionViewCell.lblRating.textColor = dateMonthRatingColor
        
        if selectedCollectionIndexpath == indexPath {
            homePedometerCollectionViewCell.backgroundColor = KPEDOMETERNAVICOLOR
            homePedometerCollectionViewCell.lblDay.textColor = UIColor.white
            homePedometerCollectionViewCell.lblMonth.textColor = UIColor.white
            homePedometerCollectionViewCell.lblRating.textColor = UIColor.white
           // homePedometerCollectionViewCell.layer.borderWidth = 2.0
          //  homePedometerCollectionViewCell.layer.borderColor = UIColor(red: 140/255.0, green: 185/255.0, blue: 61/255.0, alpha: 1.0).cgColor
        }
        return homePedometerCollectionViewCell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCollectionIndexpath = indexPath
        createpadoMeterCircleChart()
        collectionView.reloadData()
        self.updatePedomterTargetValueforSelectedIndex(index: indexPath.row)
        /*
         let cell = collectionView.cellForItem(at: indexPath)
         cell?.layer.borderWidth = 2.0
         cell?.layer.borderColor = UIColor.gray.cgColor
         */
    }
    
    //MARK: SEGUE DELEGATES
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    //MARK: TABLEVIEWDELEGATE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pedoMeterList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell   = tableView.dequeueReusableCell(withIdentifier: "tblCell") as! pedoMeterTableViewCell
        cell.lblData.attributedText = self.changeFontAndColor(str1: pedoMeterListData[indexPath.row], str2: pedoMeterList[indexPath.row], font1: KROBOTO_MEDIUM_22!,font2:KROBOTO_REGULAR_17!, color1: KCUSTOMBLACKCOLOR, color2: KGREYCOLOR)
        cell.imgViewIcon.image = UIImage(named: pedoMeterList[indexPath.row])
        cell.progressView.progressTintColor = progressTintColor[indexPath.row]
        
        let stepsMO = stepsDayMOArr[selectedCollectionIndexpath!.row]
        cell.progressView.progress = Float(stepsMO.totalSteps / averageSteps)
      //  cell.progressView.setProgress(40, animated: true)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none

        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let _ = performSegue(withIdentifier: "PedometerStepsTableViewController", sender: self)
        case 1:
            let _ = performSegue(withIdentifier: "PedometerKMsTableViewController", sender: self)
        case 2:
            let _ = performSegue(withIdentifier: "PedometerCaloriesOrignalViewController", sender: self)

        case 3:
            let _ = performSegue(withIdentifier: "PedometerCaloriesTableViewController", sender: self)
            
            
        default:
            print("Default")
        }
    }
    
    
    //MARK: CUSTOM METHODS 
    func createpadoMeterCircleChart(){
        let pedometerDayData: StepDayMO? = stepsDayMOArr[selectedCollectionIndexpath!.row]//DBManager.sharedDBManager.fetchStepDataforDay(date: GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date()))
        //        let kmDayData: KMsDayMO? = kmsDayMOArr[selectedCollectionIndexpath!.row]//DBManager.sharedDBManager.fetchStepDataforDay(date: GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date()))
        
        if padoMeterCircleChart == nil{
            //            padoMeterCircleChart = PNCircleChart(frame: CGRect(x: 10, y: 10, width: padoMeterGraphView.frame.width - 20 , height: padoMeterGraphView.frame.height - 20), total: NSNumber(floatLiteral: (kmDayData?.totalKMsTraget)!), current: NSNumber(floatLiteral: (kmDayData?.totalKMs)!), clockwise: true, shadow: false, shadowColor: UIColor.lightGray.withAlphaComponent(0.2))
            padoMeterCircleChart = PNCircleChart(frame: CGRect(x: 10, y: 10, width: padoMeterGraphView.frame.width - 20 , height: padoMeterGraphView.frame.height - 20), total: NSNumber(floatLiteral: (pedometerDayData?.targetSteps)!), current: NSNumber(floatLiteral: (pedometerDayData?.totalSteps)!), clockwise: true, shadow: false, shadowColor: UIColor.lightGray.withAlphaComponent(0.2))
            
            padoMeterCircleChart!.backgroundColor = UIColor.clear
            padoMeterCircleChart!.strokeColor = KPEDOMETERNAVICOLOR
            padoMeterCircleChart.displayCountingLabel = false
            padoMeterGraphView.addSubview(padoMeterCircleChart!)
        }
        if pedometerDayData != nil{
            //VIA KMs Table
            //            padoMeterCircleChart.total = NSNumber(floatLiteral: (kmDayData!.totalKMsTraget))
            //            padoMeterCircleChart.current = NSNumber(floatLiteral: (kmDayData?.totalKMs)!)
            
            //VIA Steps Table
            
            padoMeterCircleChart.total = NSNumber(floatLiteral: (pedometerDayData?.targetSteps)!)
            padoMeterCircleChart.current = NSNumber(floatLiteral: (pedometerDayData?.totalSteps)!)
        }
        
        let percentage = (pedometerDayData!.totalSteps/pedometerDayData!.targetSteps)*100
        if percentage < 50 {
            padoMeterCircleChart!.strokeColor = UIColor.red
        }else if percentage > 50 && percentage < 80 {
            padoMeterCircleChart!.strokeColor = UIColor(red: 239/255.0, green: 144/255.0, blue: 143/255.0, alpha: 1.0)
        }else{
            padoMeterCircleChart!.strokeColor = KPEDOMETERNAVICOLOR
        }
        padoMeterGraphView.bringSubview(toFront: btnGraph)
        padoMeterCircleChart.stroke()
        
        
    }
    
    
    
    func changeFontAndColor(str1 : String , str2 : String,font1 : UIFont , font2 : UIFont, color1: UIColor, color2: UIColor) -> NSMutableAttributedString {
        
        let str1Lenght = str1.characters.count
        let str2Length = str2.characters.count
        
        
        let finalString = str1 + " " + str2
        
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: finalString as String, attributes: [NSFontAttributeName:font1])
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: color1, range: NSRange(location:0,length:str1Lenght))
        myMutableString.addAttribute(NSFontAttributeName, value: font2, range: NSRange(location:str1Lenght + 1,length: str2Length))
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: color2, range: NSRange(location:str1Lenght + 1,length:str2Length))
        return myMutableString
    }

    func updatePedomterTargetValueforSelectedIndex(index: Int) {
        let stepsDayMO = stepsDayMOArr[index]
        //let kmDayMO = kmsDayMOArr[index]
        
        pedoMeterListData.removeAll()
        
        lblTargate.attributedText = self.changeFontAndColor(str1: String(format: "%g KM", stepsDayMO.targetSteps/1250) + "\n", str2: "Target",font1: KCALIBRI_REGULAR_28! ,font2:KCALIBRI_REGULAR_14!, color1: labelTargetCompletedTextColor, color2: KGREYCOLOR)
        
        lblCompleted.attributedText = self.changeFontAndColor(str1: String(format: "%.2g KM", stepsDayMO.totalSteps/1250.roundToPlaces(places: 2)) + "\n", str2: "Completed",font1: KCALIBRI_REGULAR_28! ,font2:KCALIBRI_REGULAR_14!, color1: labelTargetCompletedTextColor, color2: KGREYCOLOR)
        
        pedoMeterListData.append(String(format: "%d", Int(stepsDayMO.totalSteps)))
        pedoMeterListData.append(String(format: "%.2g", stepsDayMO.totalSteps/stepsinKMS.roundToPlaces(places: 2)))
        pedoMeterListData.append(String(format:"%.2g", (stepsDayMO.totalSteps/20.0).roundToPlaces(places: 2)))
        
        pedoMeterListData.append(String(format: "%g", round(Float(stepsDayMO.activeSeconds)/60.0)))
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    func addRightBarButtonItems() {
        let cartButton = UIBarButtonItem(image: #imageLiteral(resourceName: "cart_icon"), style: .done, target: self, action: #selector(HomeWaterViewController.cartButtonClicked(_:)))
        cartButton.tintColor = UIColor.white
        let reportButton = UIBarButtonItem(image: #imageLiteral(resourceName: "report_icon"), style: .done, target: self, action: #selector(HomeWaterViewController.reportBtnClicked(_:)))
        reportButton.tintColor = UIColor.white
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        reportButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -30)
        self.navigationItem.rightBarButtonItems = [cartButton, fixedSpace, reportButton]
        //        [barbuttonitem setImageInsets:UIEdgeInsetsMake(0, -30, 0, -70)];
        
    }
    //MARK: ACtIONBUTTONONCLICK
    @IBAction func btnEnableDisableOnClick(_ sender: UIButton) {
        
        if (btnEnableDisable.isSelected) {
            btnEnableDisable.setImage(UIImage(named: "pedometer_disable"), for: .normal)
            btnEnableDisable.isSelected = false
        }else{
            btnEnableDisable.setImage(UIImage(named: "pedometer_enable"), for: .normal)
            btnEnableDisable.isSelected = true
            
        }
        
        
    }
    
    @IBAction func btnPedoMeterOnClick(_ sender: UIButton) {
        let pedoMeterGraphVC = KPEDOMETERSTORYBOARD.instantiateViewController(withIdentifier: "PedoMeterGraphViewController") as! PedoMeterGraphViewController
        self.navigationController?.pushViewController(pedoMeterGraphVC, animated: true)
        
    }

    func cartButtonClicked(_ sender: AnyObject){
        print("Cart Button Clicked")
    }
    
    func reportBtnClicked(_ sender: AnyObject){
        print("Report Button Clicked")
    }


    
    }

extension Double {
    
    func roundToPlaces(places:Int) -> Double {
        
        let divisor = pow(10.0, Double(places))
        
        return (self * divisor).rounded() / divisor
        
    }
    
}
