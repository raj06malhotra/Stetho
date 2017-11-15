//
//  ReportCollectionViewCell.swift
//  Stetho Update
//
//  Created by Administrator on 26/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class ReportCollectionViewCell: UICollectionViewCell {
    
//    @IBOutlet weak var lblDate: UILabel!
//    @IBOutlet weak var lblMonth_Year: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var lblDate: UILabel!


    
    override func awakeFromNib() {
        super.awakeFromNib()
        innerView.layer.cornerRadius = innerView.frame.size.width/2
        outerView.layer.cornerRadius = outerView.frame.size.width/2
        
        innerView.layer.borderWidth = 1
        outerView.layer.borderWidth = 4
//        innerView.layer.borderColor = getRandomColor().cgColor
//        outerView.layer.borderColor = innerView.layer.borderColor

        // Initialization code
    }
    
    func getRandomColor() -> UIColor{
        //Generate between 0 to 1
        let red:CGFloat = CGFloat(drand48())
        let green:CGFloat = CGFloat(drand48())
        let blue:CGFloat = CGFloat(drand48())
        
        return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
    }


    
}
