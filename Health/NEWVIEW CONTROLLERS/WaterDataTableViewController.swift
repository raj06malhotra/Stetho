//
//  WaterDataTableViewController.swift
//  Stetho Update
//
//  Created by Administrator on 25/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class WaterDataTableViewController: UITableViewController {
    
    var waterDayMOArr:[WaterDayMO] = []
    var qunatityType: WaterQuantityType?
    
     var isComingfromGraph: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        waterDayMOArr = WaterDayMO.fetchWaterData(ascending: false)
        self.tableView.separatorStyle = .none
        addBarButtonItem()

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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return waterDayMOArr.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let waterHeaderCell = tableView.dequeueReusableCell(withIdentifier: "WaterHeaderCell") as! WaterHeaderCell

        if qunatityType == WaterQuantityType.glass {
            waterHeaderCell.lblGlassType.text = "Glass (250 ml)"
        }else{
            waterHeaderCell.lblGlassType.text = "Litre (1000 ml)"
        }
        return waterHeaderCell
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let waterDataTableViewCell = tableView.dequeueReusableCell(withIdentifier: "WaterDataTableViewCell", for: indexPath) as! WaterDataTableViewCell
        let waterDayMO = waterDayMOArr[indexPath.row]
        let dateComponents = waterDayMO.date?.components(separatedBy: "-")
        
        waterDataTableViewCell.lblDate.text = dateComponents?[2]
        
        waterDataTableViewCell.lblMonth_Year.text = monthDict[dateComponents![1]]! + "'" + dateComponents![0]
        if qunatityType == WaterQuantityType.glass {
            waterDataTableViewCell.lblQuantity.text = String(format: "%g Glass", (waterDayMO.totalWaterDrink/250)*1000)
        }else{
            waterDataTableViewCell.lblQuantity.text = String(format: "%g Litre", waterDayMO.totalWaterDrink)
        }
        waterDataTableViewCell.lblRating.text = String(format: "%.1f", (((waterDayMO.totalWaterDrink/waterDayMO.totalWaterTarget)*100)*5)/100)

        // Configure the cell...

        return waterDataTableViewCell
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
            self.performSegue(withIdentifier: "WaterGraphViewController", sender: self)
        }
    }
    
    //MARK: SEGUE METHODS
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WaterGraphViewController"{
            let vc = segue.destination as! WaterGraphViewController
            vc.isComingFromList = true
        }
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
