//
//  HomeOfferView.swift
//  Stetho Update
//
//  Created by HW-Anil on 5/25/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class HomeOfferView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "HomeOfferView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    

}
