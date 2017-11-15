//
//  ReminderViewController.swift
//  Stetho Update
//
//  Created by Administrator on 25/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIDatePicker!
    @IBOutlet weak var pickerBGView: UIView!
    
    var timeArr = ["6:00 AM", "4:00 PM", "9:00 PM"]
    var dateFormatterTime = DateFormatter()
    var selectedIndex: Int? = nil
    

    /*
     NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
     [outputFormatter setDateFormat:@"HH:mm"]; //24hr time format
     NSString *dateString = [outputFormatter stringFromDate:self.myDatePicker.date];
     [outputFormatter release];
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "REMINDERS"
        dateFormatterTime.dateFormat = "h:mm a"
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
        addBarButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickerBGView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeArr.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let reminderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ReminderTableViewCell", for: indexPath) as! ReminderTableViewCell
        reminderTableViewCell.lblTime.text = timeArr[indexPath.row]
        
        reminderTableViewCell.deleteBtn.addTarget(self, action: #selector(ReminderViewController.deleteBtnClicked(_:)), for: .touchUpInside)
        reminderTableViewCell.deleteBtn.tag = indexPath.row
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        pickerBGView.isHidden = false
    }
    
    //MARK: IBACTIONS
    
    @IBAction func cancelBtnClicked(_ sender: AnyObject){
        pickerBGView.isHidden = true
    }
    
    @IBAction func doneBtnClicked(_ sender: AnyObject){
        print(pickerView.date)
        if selectedIndex != nil{
            timeArr[selectedIndex!] = dateFormatterTime.string(from: pickerView.date)
            selectedIndex = nil
        }else{
            timeArr.append(dateFormatterTime.string(from: pickerView.date))
        }
        pickerBGView.isHidden = true
        tableView.reloadData()
    }
    
    //MARK: CUSTOM METHODS
    
    func addBarButtonItem() {
        let addBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(ReminderTableViewController.addReminderBtnClicked(_:)))
        addBarButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = addBarButton
    }
    
    func addReminderBtnClicked(_ sender: AnyObject){
        pickerBGView.isHidden = false
    }
    
    func deleteBtnClicked(_ sender: UIButton){
        timeArr.remove(at: sender.tag)
        tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
