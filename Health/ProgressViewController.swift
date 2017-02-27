class ProgressViewController: UIView {
    
    var indicatorColor:UIColor
    var loadingViewColor:UIColor
    var loadingMessage:String
    var messageFrame = UIView()
    var activityIndicator = JTMaterialSpinner()//UIActivityIndicatorView()
    var bgView = UIView()
    var progressToAddonView: UIView!
    
    
    
    init(inview:UIView,loadingViewColor:UIColor,indicatorColor:UIColor,msg:String){
        //inview.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.indicatorColor = indicatorColor
        self.loadingViewColor = loadingViewColor
        self.loadingMessage = msg
        progressToAddonView = inview
//        super.init(frame: CGRect(x: inview.frame.midX-37.5, y: inview.frame.midY-37.5  , width: 75, height: 75))
        super.init(frame: CGRect(x: 0, y: 0  , width: inview.frame.size.width, height: inview.frame.size.height))
        print(inview.frame.midX)
        print(inview.frame.midY)
        print(inview.frame.width)
        print(inview.frame.height)

        //super.init(frame: CGRectMake(0, 0 , 320, 568))
        initalizeCustomIndicator()
    }
    
    init(inview:UIView,loadingViewColor:UIColor,indicatorColor:UIColor,msg:String, customHeight: CGFloat){
        //inview.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.indicatorColor = indicatorColor
        self.loadingViewColor = loadingViewColor
        self.loadingMessage = msg
        progressToAddonView = inview
        //        super.init(frame: CGRect(x: inview.frame.midX-37.5, y: inview.frame.midY-37.5  , width: 75, height: 75))
        super.init(frame: CGRect(x: 0, y: 0  , width: inview.frame.size.width, height: customHeight))
        print(inview.frame.midX)
        print(inview.frame.midY)
        print(inview.frame.width)
        print(inview.frame.height)
        
        //super.init(frame: CGRectMake(0, 0 , 320, 568))
        initalizeCustomIndicator()
    }
    
    convenience init(inview:UIView) {
        
        self.init(inview: inview,loadingViewColor: UIColor.brown,indicatorColor:UIColor.black, msg: "Loading..")
    }
    convenience init(inview:UIView,messsage:String) {
        
        self.init(inview: inview,loadingViewColor: UIColor.brown,indicatorColor:UIColor.black, msg: messsage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func initalizeCustomIndicator(){
        bgView.frame = UIScreen.main.bounds
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        //self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        messageFrame.frame = self.bounds
      //  bgView = UIView(frame: view.bounds)
      //  bgView!.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        //let spinnerView = JTMaterialSpinner()
     //   let imageView = UIImageView(frame: CGRect(x: ((UIScreen.main.bounds.size.width - 75.0) / 2.0) + 5, y: (UIScreen.main.bounds.size.height/2 - 37.5) + 5, width: 65, height: 65))
        let imageView = UIImageView(frame: CGRect(x: self.frame.midX-32.5, y: self.frame.midY-32.5  , width: 65, height: 65))

        imageView.image = #imageLiteral(resourceName: "Spinner-icon")
        
        activityIndicator.frame = CGRect(x: self.frame.midX-37.5, y: self.frame.midY-37.5  , width: 75, height: 75)
        
        
        
        activityIndicator.circleLayer.lineWidth = 5.0
        activityIndicator.circleLayer.strokeColor = UIColor.white.cgColor
        messageFrame.addSubview(imageView)
        messageFrame.addSubview(activityIndicator)
        
        
        
        
        
        
        
        
        
        
        
        
        /*
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        activityIndicator.tintColor = indicatorColor
        activityIndicator.hidesWhenStopped = true
       // activityIndicator.frame = CGRect(x: self.bounds.origin.x + 6, y: 0, width: 20, height: 50)
        activityIndicator.frame = CGRect(x: 10 , y: 10, width: 40, height: 40)
        print(activityIndicator.frame)
        let strLabel = UILabel(frame:CGRect(x: self.bounds.origin.x + 30, y: 0, width: self.bounds.width - (self.bounds.origin.x + 30) , height: 50))
        strLabel.text = loadingMessage
        strLabel.adjustsFontSizeToFitWidth = true
        strLabel.textColor = UIColor.white
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = loadingViewColor
        messageFrame.alpha = 0.8
        messageFrame.addSubview(activityIndicator)
        messageFrame.addSubview(strLabel)*/
    }
    
    func  start(){
        //check if view is already there or not..if again started
        if !self.subviews.contains(messageFrame){
            UIApplication.shared.beginIgnoringInteractionEvents()
            activityIndicator.beginRefreshing()//startAnimating()
            self.addSubview(bgView)
            self.addSubview(messageFrame)
            progressToAddonView.addSubview(self)
        }
    }
    
    func stop(){

        if self.subviews.contains(messageFrame){
            UIApplication.shared.endIgnoringInteractionEvents()
            activityIndicator.endRefreshing()//stopAnimating()
            bgView.removeFromSuperview()
            messageFrame.removeFromSuperview()
            self.removeFromSuperview()
            
        }
    }
}
