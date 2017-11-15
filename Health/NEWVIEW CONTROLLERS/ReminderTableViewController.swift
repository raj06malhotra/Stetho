//
//  ReminderTableViewController.swift
//  Stetho Update
//
//  Created by Administrator on 24/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class ReminderTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIDatePicker!
    @IBOutlet weak var pickerBGView: UIView!
    
    var isComingfromGraph: Bool?
    var timeArr = ["6:00 AM", "4:00 PM", "9:00 PM"]
            
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "REMINDERS"

        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickerBGView.isHidden = true
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeArr.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let reminderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ReminderTableViewCell", for: indexPath) as! ReminderTableViewCell
       reminderTableViewCell.lblTime.text = timeArr[indexPath.row]
        return reminderTableViewCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let reminderHeaderCell = tableView.dequeueReusableCell(withIdentifier: "ReminderHeaderCell") as! ReminderHeaderCell
        return reminderHeaderCell
    }
    
    //MARK: IBACTIONS
    
    @IBAction func cancelBtnClicked(_ sender: AnyObject){
        pickerBGView.isHidden = true
    }
    
    @IBAction func doneBtnClicked(_ sender: AnyObject){
        print(pickerView.date)
        pickerBGView.isHidden = true
    }
    
    //MARK: CUSTOM METHODS
    
    func addBarButtonItem() {
      let addBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(ReminderTableViewController.addReminderBtnClicked(_:)))
        self.navigationItem.rightBarButtonItem = addBarButton
    }
    
    func addReminderBtnClicked(_ sender: AnyObject){
        pickerBGView.isHidden = false
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
