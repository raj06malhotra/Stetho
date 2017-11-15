//
//  pedoMeterTableViewCell.swift
//  Stetho Update
//
//  Created by HW-Anil on 7/14/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class pedoMeterTableViewCell: UITableViewCell {
    @IBOutlet  var lblData : UILabel!
    @IBOutlet var imgViewIcon: UIImageView!
    @IBOutlet var progressView : UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
