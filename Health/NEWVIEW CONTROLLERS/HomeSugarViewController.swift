//
//  HomeSugarViewController.swift
//  Stetho Update
//
//  Created by HW-Anil on 7/25/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

let totalSugarIntakeinGram: Float = 40
class HomeSugarViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var sugarCollectionView : UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnMinus5g : UIButton!
    @IBOutlet weak var btnPlus5g : UIButton!
    @IBOutlet weak var btnMinus10g : UIButton!
    @IBOutlet weak var btnPlus10g : UIButton!
    @IBOutlet weak var btnEnableDisable : UIButton!
    @IBOutlet weak var lblConsumeSugar: UILabel!
    @IBOutlet weak var lblTargateSugar: UILabel!
    @IBOutlet weak var spoonCollectionView: UICollectionView!

    
    var totalSugarConsume = 0
    var sugarDayMOArr:[SugarDayMO] = []
    var selectedCollectionIndexpath:IndexPath? = IndexPath(row: 0, section: 0)

    
    
// MARK: VIEWLIFECYCLEMETHOD
    override func viewDidLoad() {
        super.viewDidLoad()
        addRightBarButtonItems()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        spoonCollectionView.collectionViewLayout = flowLayout
        // Do any additional setup after loading the view.
        btnEnableDisable.isSelected = false
        sugarDayMOArr = SugarDayMO.fetchSugarData(ascending: true)
        checkDataExist()
        //sugarDayMOArr.reverse()
        selectedCollectionIndexpath?.row = sugarDayMOArr.index(of: sugarDayMOArr.last!)!
        self.sugarCollectionView.performBatchUpdates({}) { (finished) in
            self.sugarCollectionView.scrollToItem(at: self.selectedCollectionIndexpath!, at: UICollectionViewScrollPosition.right, animated: true)
        }
        
       // self.butCoustomDesing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = sugarNavigationColor
       // self.title = "Sugar Tracking"
        setSugarDetails()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.barTintColor = waterNavigationColor
//        waterDayMOArr = WaterDayMO.fetchWaterData()
//        checkDataExist()
//        waterDayMOArr.reverse()
//        selectedCollectionIndexpath?.row = waterDayMOArr.index(of: waterDayMOArr.last!)!
//        self.CalenderCollectionView.performBatchUpdates({}) { (finished) in
//            self.CalenderCollectionView.scrollToItem(at: self.selectedCollectionIndexpath!, at: UICollectionViewScrollPosition.right, animated: true)
//        }
//        setWaterDetails()
//        //updateWaterDetails()
//        
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = CGSize(width: 0, height: 610)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: COLLECTIONVIEWDELEGATE
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == spoonCollectionView{
            return Int(sugarDayMOArr[section].totalSugarTarget)/4
        }
        return sugarDayMOArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == spoonCollectionView {
            let spoonSugarCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpoonSugarCollectionViewCell", for: indexPath) as! SpoonSugarCollectionViewCell
            if indexPath.row < totalSugarConsume/4 {
                switch indexPath.row {
                case let x where x<4 :
                    spoonSugarCollectionViewCell.spoonImage.image = #imageLiteral(resourceName: "spoon-green")
                case 4..<6:
                    spoonSugarCollectionViewCell.spoonImage.image = #imageLiteral(resourceName: "spoon-mildred")
                case let x where x>=6:
                    spoonSugarCollectionViewCell.spoonImage.image = #imageLiteral(resourceName: "spoon-red")
                default:
                    break
                }
                
            }else{
                 spoonSugarCollectionViewCell.spoonImage.image = #imageLiteral(resourceName: "spoon-unselected")
            }
            
        //    spoonSugarCollectionViewCell.spoonImage.image = #imageLiteral(resourceName: "spoon-unselected")
            return spoonSugarCollectionViewCell
        }
        let homePedometerCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePedometerCollectionViewCell", for: indexPath) as! HomePedometerCollectionViewCell
        let sugarDayMO = sugarDayMOArr[indexPath.row]
        let dateComp = sugarDayMO.date?.components(separatedBy: "-")
         homePedometerCollectionViewCell.layer.cornerRadius = 4
         homePedometerCollectionViewCell.layer.borderWidth = 0.5
         homePedometerCollectionViewCell.layer.borderColor = UIColor.lightGray.cgColor
        
        
        homePedometerCollectionViewCell.lblDay.text = dateComp?[2] 
        homePedometerCollectionViewCell.lblMonth.text = monthDict[dateComp![1]]
        homePedometerCollectionViewCell.lblRating.text = String(format: "%.1f", (((sugarDayMO.totalSugarIntake/sugarDayMO.totalSugarTarget)*100)*5)/100)
        
        
        homePedometerCollectionViewCell.backgroundColor = UIColor.white
        homePedometerCollectionViewCell.lblDay.textColor = dateMonthRatingColor
        homePedometerCollectionViewCell.lblMonth.textColor = dateMonthRatingColor
        homePedometerCollectionViewCell.lblRating.textColor = dateMonthRatingColor
        
        if indexPath.row == selectedCollectionIndexpath?.row {
            homePedometerCollectionViewCell.backgroundColor = sugarNavigationColor
            homePedometerCollectionViewCell.lblDay.textColor = UIColor.white
            homePedometerCollectionViewCell.lblMonth.textColor = UIColor.white
            homePedometerCollectionViewCell.lblRating.textColor = UIColor.white
//            homePedometerCollectionViewCell.layer.borderWidth = 2.0
//            homePedometerCollectionViewCell.layer.borderColor = sugarNavigationColor.cgColor
        }
        return homePedometerCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == spoonCollectionView {
            self.btnPlusCunsomeOnClick(btnPlus5g)
            return
        }
            selectedCollectionIndexpath = indexPath
            //sugarCollectionView.reloadData()
            setSugarDetails()
            sugarCollectionView.reloadData()
        spoonCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 100)
    }

    
    // MARK: UIBUTTONACTION
    @IBAction func btnEnable_DisableOnClick(_ sender: UIButton) {
   
        if btnEnableDisable.isSelected {
           btnEnableDisable.isSelected = false
           btnEnableDisable.setImage(#imageLiteral(resourceName: "sugar_disable"), for: .normal)
        }else{
            btnEnableDisable.isSelected = true
            btnEnableDisable.setImage(#imageLiteral(resourceName: "sugar_enable"), for: .normal)
        }
    }
    
   @IBAction  func btnMinusConsumeOnClick(_ sender : UIButton){
    
    if totalSugarConsume >= 4 {
        totalSugarConsume -= 4
    }
        // lblConsumeSugar.text = String(totalSugarConsume) + " grams"
    updateSugarDetails()
    }
    
    @IBAction func btnPlusCunsomeOnClick(_ sender : UIButton){
        totalSugarConsume += 4
         //lblConsumeSugar.text = String(totalSugarConsume) + " grams"
        updateSugarDetails() 
    }
    
    @IBAction func btnPlusTargetOnClick(_ sender : UIButton){
         totalSugarConsume += 10
         //lblConsumeSugar.text = String(totalSugarConsume) + " grams"
        updateSugarDetails()
    }
    
    @IBAction func btnMinusTargetOnClick(_ sender : UIButton){
        if totalSugarConsume >= 4 {
            totalSugarConsume -= 4
        }
         //lblConsumeSugar.text = String(totalSugarConsume) + " grams"
        updateSugarDetails()
    }
    
    @IBAction func btnSugarCupOnClick(_ sender : UIButton){
        let sugarGraphViewController = KSUGARSTORYBOARD.instantiateViewController(withIdentifier: "SugarGraphViewController")as! SugarGraphViewController
        self.navigationController?.pushViewController(sugarGraphViewController, animated: true)
    }
    
    @IBAction func btnShowSugarDataClicked(_ sender: AnyObject){
        self.performSegue(withIdentifier: "SugarDataTableViewController", sender: self)
    }
    //MARK: BUTTONLAYOUTDESIGN
    
//    func butCoustomDesing()  {
//        btnPlus5g.layer.masksToBounds = true
//        btnMinus5g.layer.masksToBounds = true
//        btnPlus10g.layer.masksToBounds = true
//        btnMinus10g.layer.masksToBounds = true
//        btnPlus5g.layer.cornerRadius = 15
//        btnMinus5g.layer.cornerRadius = 15
//        btnPlus10g.layer.cornerRadius = 15
//        btnMinus10g.layer.cornerRadius = 15
//    }
    
    //MARK: CUSTOM METHODS
    
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
    
    func cartButtonClicked(_ sender: AnyObject){
        print("Cart Button Clicked")
    }
    
    func reportBtnClicked(_ sender: AnyObject){
        print("Report Button Clicked")
    }
    
    func checkDataExist(){
        let filteredArr = sugarDayMOArr.filter { $0.date ==  GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date())}
        if sugarDayMOArr.isEmpty ||  filteredArr.count == 0 {
            let sugarMO = SugarDayMO.createSugarDayModel()
            sugarMO.creationDate = Date() as NSDate
            sugarMO.date = GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: Date())
            sugarMO.totalSugarIntake = 0
            sugarMO.totalSugarTarget = totalSugarIntakeinGram
            DBManager.sharedDBManager.saveContext()
            sugarDayMOArr = SugarDayMO.fetchSugarData(ascending: true)
        }
    }
    
    func setSugarDetails() {
        let sugarDayMO = sugarDayMOArr[selectedCollectionIndexpath!.row]
        //selectedGlassCount = (waterDayMo.totalWaterDrink/250)*1000
        totalSugarConsume = Int(sugarDayMO.totalSugarIntake)
        lblConsumeSugar.text = String(format: "%g grams", sugarDayMO.totalSugarIntake)
        lblTargateSugar.text = String(format: "%g grams", sugarDayMO.totalSugarTarget)
        
        
//        var percentage = Float(selectedGlassCount/(Float((waterDayMo.totalWaterTarget)/250)*1000))*100
//        if percentage > 100{
//            percentage = 100
//        }
//        waterProgressView.progress = percentage/100
//        lblWaterDetails.text = String(Int(selectedGlassCount)) + "/" + String(totalTargetInGlass)
//        lblTarget.text = String(waterDayMo.totalWaterTarget) + "L"
//        let c = (selectedGlassCount * 250)/1000
//        lblConsumed.text = String(c) + "L"
//        lblProgressPercentage.text = String (Int(percentage)) + "%"
    }
    
    func updateSugarDetails()  {
        let sugarDayMO = sugarDayMOArr[selectedCollectionIndexpath!.row]
        //  selectedGlassCount = waterDayMo.totalWaterDrink/250
        
        lblConsumeSugar.text = String(format: "%d grams", totalSugarConsume)
        lblTargateSugar.text = String(format: "%g grams", sugarDayMO.totalSugarTarget)
        
        spoonCollectionView.reloadData()
        
//        var percentage = Float(selectedGlassCount/Float(totalTargetInGlass))*100
//        if percentage > 100{
//            percentage = 100
//        }
//        waterProgressView.progress = percentage/100
//        lblWaterDetails.text = String(Int(selectedGlassCount)) + "/" + String(totalTargetInGlass)
//        lblTarget.text = String(waterDayMo.totalWaterTarget) + "L"
//        let c = (selectedGlassCount * 250)/1000
//        lblConsumed.text = String(c) + "L"
//        lblProgressPercentage.text = String (Int(percentage)) + "%"
        updateDB(target: totalSugarIntakeinGram, consumed: Float(totalSugarConsume))
    }

    
    //MARK: DB Update
    func updateDB(target: Float, consumed: Float){
        let sugarDayMO = sugarDayMOArr[selectedCollectionIndexpath!.row]
        // waterDayMO.creationDate = Date()
        sugarDayMO.totalSugarIntake = consumed
        sugarDayMO.totalSugarTarget = target
        DBManager.sharedDBManager.saveContext()
        
    }


    

   

}

