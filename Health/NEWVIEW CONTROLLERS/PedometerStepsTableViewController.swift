//
//  PedometerDataTableViewController.swift
//  Stetho Update
//
//  Created by Administrator on 18/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import CoreData

class PedometerStepsTableViewController: UITableViewController {
    var isComingfromGraph: Bool?
   
    var stepsDayMOArr: [StepDayMO] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "RECORDED DATA"
        addBarButtonItem()
        stepsDayMOArr = DBManager.sharedDBManager.fetchStepsDatafromDB(ascending: false)
       self.tableView.separatorStyle = .none
        self.tableView.reloadData()
        


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//       return
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let _ = stepsDayMOArr[section].stepTimeInterval  else {
//            return 0
//        }
//        print(stepsDayMOArr[section].stepTimeInterval!.count)
        return stepsDayMOArr.count//stepsDayMOArr[section].stepTimeInterval!.count
    }


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
         let pedometerDataTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PedometerDataTableViewCell", for: indexPath) as! PedometerDataTableViewCell
        let stepDayMO = stepsDayMOArr[indexPath.row]
//        let dateStr = stepDayMO.date?.components(separatedBy: "at")[0]
        let dateComponents: [String] = stepDayMO.date!.components(separatedBy: "-")
        pedometerDataTableViewCell.lblDay.text = dateComponents[2]
        
        pedometerDataTableViewCell.lblMonth_Year.text = monthDict[dateComponents[1]]! + "'" + dateComponents[0]
        pedometerDataTableViewCell.lblMonth_Year.adjustsFontSizeToFitWidth = true
        pedometerDataTableViewCell.lblTotalSteps.text = String(format: "%d Steps", Int(stepDayMO.totalSteps))//"\(stepDayMO.totalSteps)"
        pedometerDataTableViewCell.lblRating.text = String(format: "%.1f", (((stepDayMO.totalSteps/averageSteps)*100)*5)/100)
        pedometerDataTableViewCell.selectionStyle = .none
        return pedometerDataTableViewCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    //MARK: SEGUE METHODS
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let pedoMeterGraphViewController = segue.destination as! PedoMeterGraphViewController
        pedoMeterGraphViewController.isComingFromList = true
    }
    
    //MARK: CUSTOM METHODS
    
    func addBarButtonItem() {
        let graphBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "graph"), style: .done, target: self, action: #selector(PedometerStepsTableViewController.graphButtonClicked(_:)))
        self.navigationItem.rightBarButtonItem = graphBarButton
    }
    
    func graphButtonClicked(_ sender: AnyObject){
        if isComingfromGraph != nil && isComingfromGraph == true{
            self.navigationController?.popViewController(animated: true)
        }else{
        self.performSegue(withIdentifier: "PedoMeterGraphViewController", sender: self)
        }
    }
    
//    override func tableView(_ tableView: UITableView,
//                            viewForHeaderInSection section: Int) -> UIView? {
//        let pedometerHeaderCell = tableView.dequeueReusableCell(withIdentifier: "PedometerHeaderCell") as! PedometerHeaderCell
//        let stepDayMO = stepsDayMOArr[section]
//        pedometerHeaderCell.lblDate.text = stepDayMO.date
//        pedometerHeaderCell.lblTotalSteps.text = "\(stepDayMO.totalSteps)"
//        
//        return pedometerHeaderCell
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

/*
 {
 let context = DBManager.sharedDBManager.privateContext
 var fetchedResultController: NSFetchedResultsController<StepsPedometerEntity>?
 
 
 override func viewDidLoad() {
 super.viewDidLoad()
 let fetchRequest = NSFetchRequest<StepsPedometerEntity>(entityName: "StepsPedometerEntity")
 //   fetchRequest.fetchBatchSize = 20
 
 fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
 fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
 do{
 try fetchedResultController?.performFetch()
 } catch{
 fatalError("Failed to fetch entities: \(error)")
 }
 
 
 
 // Uncomment the following line to preserve selection between presentations
 // self.clearsSelectionOnViewWillAppear = false
 
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem()
 }
 
 override func didReceiveMemoryWarning() {
 super.didReceiveMemoryWarning()
 // Dispose of any resources that can be recreated.
 }
 
 
 // MARK: - Table view data source
 
 override func numberOfSections(in tableView: UITableView) -> Int {
 // #warning Incomplete implementation, return the number of sections
 if let frc = fetchedResultController {
 return frc.sections!.count
 }
 return 0
 }
 
 override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 guard let sections = self.fetchedResultController?.sections  else {
 fatalError("No sections in fetchedResultsController")
 }
 let sectionInfo = sections[section]
 return sectionInfo.numberOfObjects
 // #warning Incomplete implementation, return the number of rows
 //  return 0
 }
 
 
 override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 let stepsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "StepsTableViewCell", for: indexPath) as! StepsTableViewCell
 guard let object = self.fetchedResultController?.object(at: indexPath) else {
 fatalError("Attempt to configure cell without a managed object")
 }
 
 stepsTableViewCell.lblStartDate.text = object.startDate
 stepsTableViewCell.lblEndDate.text = object.endDate
 stepsTableViewCell.lblSteps.text = "\(String(describing: object.steps))"
 stepsTableViewCell.activeMinutes.text = String(format: "%.2g", (Float(object.activeSeconds)/60.0))
 
 // Configure the cell...
 
 return stepsTableViewCell
 }
 
 
 /*
 // Override to support conditional editing of the table view.
 override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the specified item to be editable.
 return true
 }
 */
 
 /*
 // Override to support editing the table view.
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
 if editingStyle == .delete {
 // Delete the row from the data source
 tableView.deleteRows(at: [indexPath], with: .fade)
 } else if editingStyle == .insert {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */
 
 /*
 // Override to support rearranging the table view.
 override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
 
 }
 */
 
 /*
 // Override to support conditional rearranging of the table view.
 override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the item to be re-orderable.
 return true
 }
 */
 
 /*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */
 
 }
 
 
 
 //MARK: FETCH CONTROLLER NOT USING
 fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
 fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "date", cacheName: nil)
 do{
 try fetchedResultController?.performFetch()
 } catch{
 fatalError("Failed to fetch entities: \(error)")
 }
 */
