//
//  MyOrdersTableViewCell.swift
//  Health
//
//  Created by HW-Anil on 8/12/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class MyOrdersTableViewCell: UITableViewCell {
    @IBOutlet weak var btnDetails: UIButton!
    @IBOutlet weak var btnTrackOrder: UIButton!
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblPickupTime: UILabel!
    @IBOutlet weak var lblPackageName: UILabel!
    @IBOutlet weak var lblSubPackageName: UILabel!
    
    @IBOutlet var btnPayNow: UIButton!
    @IBOutlet var btnTrackFhlebo: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnDetails.layer.cornerRadius = 4
        btnDetails.layer.masksToBounds = true
        btnDetails.layer.borderWidth = 1
        btnDetails.layer.borderColor = KRED_COLOR.cgColor//KRED_COLOR.cgColor
        
        btnTrackOrder.layer.cornerRadius = 4
        btnTrackOrder.layer.masksToBounds = true
        btnTrackOrder.layer.borderWidth = 1
        btnTrackOrder.layer.borderColor = KRED_COLOR.cgColor//KRED_COLOR.cgColor
        
//        btnTrackFhlebo.layer.cornerRadius = 4
//        btnTrackFhlebo.layer.masksToBounds = true
//        btnTrackFhlebo.layer.borderWidth = 1
//        btnTrackFhlebo.layer.borderColor = KRED_COLORColor().CGColor
        
        btnPayNow.layer.cornerRadius = 4
        btnPayNow.layer.masksToBounds = true
        btnPayNow.layer.borderWidth = 1
        btnPayNow.layer.borderColor = KRED_COLOR.cgColor//KRED_COLOR.cgColor
        

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
