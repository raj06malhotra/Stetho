//
//  HomeTableViewCell.swift
//  Stetho
//
//  Created by HW-Anil on 11/10/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var lbltestName: UILabel!
    @IBOutlet weak var lblTestValue: UILabel!
    @IBOutlet weak var lblTestUnit: UILabel!
    
    @IBOutlet weak var lblGeneralTestRange: UILabel!
    
    @IBOutlet weak var lblIntensity: UILabel!
    
    @IBOutlet weak var intensityImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
