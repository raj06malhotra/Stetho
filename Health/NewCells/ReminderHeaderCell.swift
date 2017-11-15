//
//  ReminderHeaderCell.swift
//  Stetho Update
//
//  Created by Administrator on 24/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class ReminderHeaderCell: UITableViewCell {
    @IBOutlet weak var switchReminder: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
