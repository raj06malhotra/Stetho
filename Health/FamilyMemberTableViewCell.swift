//
//  FamilyMemberTableViewCell.swift
//  Stetho
//
//  Created by Administrator on 15/02/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit

class FamilyMemberTableViewCell: UITableViewCell {
    @IBOutlet var imgMember: UIImageView!
    @IBOutlet var lblMemberName: UILabel!

    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
