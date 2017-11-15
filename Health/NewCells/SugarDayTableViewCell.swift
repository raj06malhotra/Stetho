//
//  SugarDayTableViewCell.swift
//  Stetho Update
//
//  Created by Administrator on 28/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class SugarDayTableViewCell: UITableViewCell {
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMonth_Year: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblRating: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
