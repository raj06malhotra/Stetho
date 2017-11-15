//
//  CustomView.swift
//  Stetho Update
//
//  Created by Administrator on 15/05/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class CustomView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "View1", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
