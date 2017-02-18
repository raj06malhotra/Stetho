//
//  SavedAddressViewController.swift
//  Stetho
//
//  Created by Administrator on 17/02/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit

class SavedAddressTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var savedAddressTableView: UITableView!
    
    var activityIndicator : ProgressViewController?
    var arrOldPickupAddress:NSArray = []
    
    var selectedAddress :((NSDictionary) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = KSAVEDADDRESSES
        savedAddressTableView.tableFooterView = UIView()
        self.navigationController!.navigationBar.titleTextAttributes = AppDelegate().navigationTitalFontSize
        let rightBarButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(SavedAddressTableViewController.cancelButtonClicked(_:)))
        rightBarButton.tintColor = KRED_COLOR
        self.navigationItem.rightBarButtonItem = rightBarButton

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelButtonClicked(_  sender: AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: TABLEVIEW DELEGATES
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
            return arrOldPickupAddress.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedAddressTableViewCell", for: indexPath) as! SavedAddressTableViewCell
        cell.selectionStyle = .none
        var strFormat = ""
            let address_line1 = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "a_address_line_1")as! String
        if address_line1.isEmpty == false{
            strFormat.append("\(address_line1), ")
        }
        
            let address_line2 = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "a_address_line_2")as! String
        if address_line2.isEmpty == false{
            strFormat.append("\(address_line2), ")
        }
            let landmark = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "a_landmark")as! String
        if landmark.isEmpty == false{
            strFormat.append("\(landmark), ")
        }
        
        let geo_address = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "geo_address")as! String
        if geo_address.isEmpty == false{
            strFormat.append("\(geo_address), ")
        }
        
        let cityName = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "city_name")as! String
        if cityName.isEmpty == false{
            strFormat.append("\(cityName), ")
        }
        
            let pincode = (arrOldPickupAddress.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "a_pincode")as! String
        if pincode.isEmpty == false{
            strFormat.append("\(pincode), ")
        }
        
        
        /*
            let fullAddress = String(format: "%@, %@, %@, %@, %@ %@", address_line1! ,address_line2! , landmark! ,geo_address! ,cityName! , pincode!)
        
        let fullAddress = String(format: "%@, %@, %@, %@, %@ %@", address_line1! ,address_line2! , landmark! ,geo_address! ,cityName! , pincode!)*/
         cell.lblSavedAddress.text = strFormat
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedAddress!(arrOldPickupAddress[indexPath.row] as! NSDictionary)
        self.dismiss(animated: true, completion: nil)
    }
    
}
