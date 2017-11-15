//
//  ActivityIndicator.swift
//  Stetho Update
//
//  Created by Administrator on 20/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class ActivityIndicator: UIActivityIndicatorView {
    
    static let sharedAcitvityIndicator = ActivityIndicator(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var loadingView = UIView(frame: CGRect(x: (UIScreen.main.bounds.maxX)/2 - 40, y: (UIScreen.main.bounds.height - 64 - 44)/2 - 40, width: 80, height: 80))
    let labelLoading = UILabel(frame: CGRect(x: 0, y: 48, width: 80, height: 30))

    
    private override init(activityIndicatorStyle style: UIActivityIndicatorViewStyle) {
        super.init(activityIndicatorStyle: style)
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        loadingView.layer.cornerRadius = 8
        self.center = CGPoint(x: loadingView.frame.size.width / 2.0, y: 35)
        loadingView.addSubview(self)
        
        //let labelLoading = UILabel(frame: CGRect(x: 0, y: 48, width: 80, height: 30))
        labelLoading.textColor = UIColor.white
        labelLoading.font = UIFont(name: labelLoading.font.fontName, size: 15.0)
        labelLoading.textAlignment = .center
        loadingView.addSubview(labelLoading)
    }
    
    
    
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
