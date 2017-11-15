//
//  ReminderTableViewCell.swift
//  Stetho Update
//
//  Created by Administrator on 24/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var lblTime: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
