//
//  HomeWaterViewController.swift
//  Stetho Update
//
//  Created by HW-Anil on 7/20/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit


let waterGlassToDrink = 12
let totalWaterDrinkinLitre:Float = 3
class HomeWaterViewController: UIViewController  , UICollectionViewDelegate , UICollectionViewDataSource{

    @IBOutlet weak var btnGlass: UIButton!
    @IBOutlet weak var btnEnableDisable: UIButton!
    @IBOutlet weak var lblProgressPercentage: UILabel!
    @IBOutlet weak var lblTargetWithLitrenGlass: UILabel!
    @IBOutlet weak var waterProgressView: UIProgressView!
    @IBOutlet weak var lblTarget: UILabel!
    @IBOutlet weak var lblConsumed: UILabel!
    @IBOutlet weak var lblWaterDetails: UILabel!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var CalenderCollectionView: UICollectionView!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var GlassesCollectionView: UICollectionView!

    
    var selectedGlassCount : Float!
    var totalTargetInLeter: Float = 3
    var totalTargetInGlass : Int!
    var waterDayMOArr:[WaterDayMO] = []
    var selectedCollectionIndexpath:IndexPath? = IndexPath(row: 0, section: 0)
    
    
    //MARK: VIEWLIFECYCLEMETHOD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedGlassCount = 0
        totalTargetInGlass = Int((totalTargetInLeter / 250 ) * 1000)
        btnEnableDisable.isSelected = false
        btnEnableDisable.setImage(#imageLiteral(resourceName: "water_disable"), for: .normal)
        addRightBarButtonItems()

        
       

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = waterNavigationColor
        waterDayMOArr = WaterDayMO.fetchWaterData(ascending: true)
        checkDataExist()
        //waterDayMOArr.reverse()
        selectedCollectionIndexpath?.row = waterDayMOArr.index(of: waterDayMOArr.last!)!
        self.CalenderCollectionView.performBatchUpdates({}) { (finished) in
            self.CalenderCollectionView.scrollToItem(at: self.selectedCollectionIndexpath!, at: UICollectionViewScrollPosition.right, animated: true)
        }
        setWaterDetails()
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 630)
        
        btnMinus.layer.cornerRadius = (btnMinus.frame.width/2)
        btnPlus.layer.cornerRadius = (btnPlus.frame.width/2)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let lastSyncDate = UserDefaults.standard.string(forKey: KLASTSYNCDATE)
        
        print(GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date()))
        UserDefaults.standard.set(GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date()), forKey: KLASTSYNCDATE)
        
        saveWaterdataLocattoServer(lastSyncDate: lastSyncDate)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK: UICOLLECTIONVIEWDELEGATE
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if GlassesCollectionView == collectionView {
            return Int(totalTargetInGlass)
        }else{
        return waterDayMOArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == CalenderCollectionView {
            let  waterCalenderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "WaterCalenderCollectionViewCell", for: indexPath) as! WaterCalenderCollectionViewCell
            let waterDayMO = waterDayMOArr[indexPath.row]
            let dateComp = waterDayMO.date?.components(separatedBy: "-")
            
            waterCalenderCollectionViewCell.layer.cornerRadius = 4
            waterCalenderCollectionViewCell.layer.borderWidth = 0.5
            waterCalenderCollectionViewCell.layer.borderColor = UIColor.lightGray.cgColor
            waterCalenderCollectionViewCell.lblDate.text = dateComp?[2]
            waterCalenderCollectionViewCell.lblMonth.text = monthDict[dateComp?[1] ?? "01"]
            waterCalenderCollectionViewCell.lblRating.text = String(format: "%.1f", (((waterDayMO.totalWaterDrink/totalTargetInLeter)*100)*5)/100)
            
            
            waterCalenderCollectionViewCell.backgroundColor = UIColor.white
            waterCalenderCollectionViewCell.lblDate.textColor = dateMonthRatingColor
            waterCalenderCollectionViewCell.lblMonth.textColor = dateMonthRatingColor
            waterCalenderCollectionViewCell.lblRating.textColor = dateMonthRatingColor
            if indexPath.row == selectedCollectionIndexpath?.row {
                waterCalenderCollectionViewCell.backgroundColor = waterNavigationColor
                waterCalenderCollectionViewCell.lblDate.textColor = UIColor.white
                waterCalenderCollectionViewCell.lblMonth.textColor = UIColor.white
                waterCalenderCollectionViewCell.lblRating.textColor = UIColor.white
//                waterCalenderCollectionViewCell.layer.borderWidth = 2.0
//                waterCalenderCollectionViewCell.layer.borderColor = waterNavigationColor.cgColor
            }
            
            return waterCalenderCollectionViewCell

        }else{
            let  collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GlassesCell", for: indexPath) as! GlassesCollectionViewCell
            if Int(selectedGlassCount) > indexPath.row {
                 collectionViewCell.GlassesImageView.image = #imageLiteral(resourceName: "fill_glass")
            }else if indexPath.row == Int(selectedGlassCount) {
                collectionViewCell.GlassesImageView.image = #imageLiteral(resourceName: "emptyAdd")
            }else{
                 collectionViewCell.GlassesImageView.image = #imageLiteral(resourceName: "empty_glass")
            }
            return collectionViewCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == CalenderCollectionView {
            selectedCollectionIndexpath = indexPath
            CalenderCollectionView.reloadData()
            setWaterDetails()
            GlassesCollectionView.reloadData()
        }else{
            self.btnPlusOnClick(btnPlus)
        }
    }
    
    //MARK: BUTTONACTION
    
    @IBAction func btnEnableDisableOnClick(_ sender: UIButton) {
        if sender.isSelected {
            btnEnableDisable.isSelected = false
            btnEnableDisable.setImage(#imageLiteral(resourceName: "water_disable"), for: .normal)
        }else{
            btnEnableDisable.isSelected = true
            btnEnableDisable.setImage(#imageLiteral(resourceName: "water_enable"), for: .normal)
        }
        
    }
    
    @IBAction func btnPlusOnClick(_ sender: UIButton) {
        if totalTargetInGlass > Int(selectedGlassCount) {
            selectedGlassCount =  selectedGlassCount + 1
            GlassesCollectionView.reloadData()
            updateWaterDetails()
        }
    }
    
    @IBAction func btnMinusOnClick(_ sender: UIButton) {
        if selectedGlassCount != 0 {
              selectedGlassCount = selectedGlassCount - 1
            GlassesCollectionView.reloadData()
            updateWaterDetails()
        }
    }
    
    @IBAction func btnGlassOnClick(_ sender: UIButton) {
        
//        self.performSegue(withIdentifier: "WaterGraphViewController", sender: self)

        let waterGraphViewController = KWATERSTORYBOARD.instantiateViewController(withIdentifier: "WaterGraphViewController") as! WaterGraphViewController
        self.navigationController?.pushViewController(waterGraphViewController, animated: true)
        
    }
    
    @IBAction func btnProgressbarOnClick(_ sender: AnyObject){
        self.performSegue(withIdentifier: "WaterDataTableViewController", sender: self)
    }
    func cartButtonClicked(_ sender: AnyObject){
        print("Cart Button Clicked")
    }
    
    func reportBtnClicked(_ sender: AnyObject){
        print("Report Button Clicked")
    }

    
    //MARK: DB Update 
    func updateDB(target: Float, consumed: Float){
        let waterDayMO = waterDayMOArr[selectedCollectionIndexpath!.row]
       // waterDayMO.creationDate = Date()
        waterDayMO.totalWaterDrink = consumed
        waterDayMO.totalWaterTarget = target
        DBManager.sharedDBManager.saveContext()
        
    }
    
    //MARK: CUSTOMMETHOD
    func setWaterDetails() {
        let waterDayMo = waterDayMOArr[selectedCollectionIndexpath!.row]
        selectedGlassCount = (waterDayMo.totalWaterDrink/250)*1000
        
        
        var percentage = Float(selectedGlassCount/(Float((waterDayMo.totalWaterTarget)/250)*1000))*100
        if percentage > 100{
            percentage = 100
        }
        lblTargetWithLitrenGlass.text = String(format: "Target = %g L (%g glasses)", waterDayMo.totalWaterTarget, (waterDayMo.totalWaterTarget/250)*1000)
        setProgressColor(percentage: percentage)
        lblWaterDetails.text = String(Int(selectedGlassCount)) + "/" + String(totalTargetInGlass)
        lblTarget.text = String(waterDayMo.totalWaterTarget) + "L"
        let c = (selectedGlassCount * 250)/1000
        lblConsumed.text = String(c) + "L"
        lblProgressPercentage.text = String (Int(percentage)) + "%"
    }
    
    func setProgressColor(percentage: Float) {
        waterProgressView.progress = percentage/100
        switch percentage {
        case let x where x<60:
            waterProgressView.progressTintColor = UIColor.red
        case 60..<90:
            waterProgressView.progressTintColor = UIColor.red.withAlphaComponent(0.5)
        case let x where x>90:
            waterProgressView.progressTintColor = UIColor.green
        default:
            break
        }
        
    }
    
    func updateWaterDetails()  {
        let waterDayMo = waterDayMOArr[selectedCollectionIndexpath!.row]
      //  selectedGlassCount = waterDayMo.totalWaterDrink/250
        
        
        var percentage = Float(selectedGlassCount/Float(totalTargetInGlass))*100
        if percentage > 100{
            percentage = 100
        }
        setProgressColor(percentage: percentage)
        lblWaterDetails.text = String(Int(selectedGlassCount)) + "/" + String(totalTargetInGlass)
        lblTarget.text = String(waterDayMo.totalWaterTarget) + "L"
        let c = (selectedGlassCount * 250)/1000
        lblConsumed.text = String(c) + "L"
        lblProgressPercentage.text = String (Int(percentage)) + "%"
        updateDB(target: totalTargetInLeter, consumed: c)
    }
    
    func checkDataExist(){
      
        let filteredArr = waterDayMOArr.filter { $0.date ==  GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date())}
        if waterDayMOArr.isEmpty ||  filteredArr.count == 0 {
            let waterMO = WaterDayMO.createWaterDayModel()
            waterMO.creationDate = Date() as NSDate
            waterMO.date = GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date())
            waterMO.totalWaterDrink = 0
            waterMO.totalWaterTarget = totalWaterDrinkinLitre
            DBManager.sharedDBManager.saveContext()
            waterDayMOArr = WaterDayMO.fetchWaterData(ascending: true)
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
    
    //MARK: SERVER DELEGATE
    func saveWaterdataLocattoServer(lastSyncDate: String?) {
      //  var stepsDayMOArr:[StepDayMO] = []
//        if lastSyncDate != nil {
//            stepsDayMOArr = HealthManager.sharedHealthManger.stepDayMOArr
//        }else{
//            stepsDayMOArr = DBManager.sharedDBManager.fetchStepsDatafromDB(ascending: false)
//        }
//        
        
        
        let jsonCompatibleArray = waterDayMOArr.map { model in
            return [
                
                "ACA_ID" : "57645",
                "TARGET": model.totalWaterTarget,
                "INTAKE":model.totalWaterDrink,
                "INTAKEDATE":model.date!,
               

            ]
        }
        do{
            let data = try JSONSerialization.data(withJSONObject: jsonCompatibleArray, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = String(data: data, encoding: String.Encoding.utf8)
            
            DispatchQueue.main.async {
                self.showActivityIndicator(text: "Loading")
            }
            let service = StethoUpdateService.sharedService
            service.hitService(dictInfo: ["jsonMaster": jsonString!], methodName: "SaveWaterSummaryIOS")
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

    
    //MARK: SEGUE DELEGATES
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WaterDataTableViewController" {
            let waterDataTableViewController = segue.destination as! WaterDataTableViewController
            
            waterDataTableViewController.qunatityType = WaterQuantityType.glass
        }
       
       
        
    }
}
