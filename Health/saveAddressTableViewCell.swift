//
//  saveAddressTableViewCell.swift
//  Stetho
//
//  Created by HW-Anil on 9/24/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class saveAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     //   lblAddress.backgroundColor = UIColor.redColor()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
