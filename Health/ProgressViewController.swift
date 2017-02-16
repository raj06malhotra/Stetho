class ProgressViewController: UIView {
    
    var indicatorColor:UIColor
    var loadingViewColor:UIColor
    var loadingMessage:String
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    init(inview:UIView,loadingViewColor:UIColor,indicatorColor:UIColor,msg:String){
        
        self.indicatorColor = indicatorColor
        self.loadingViewColor = loadingViewColor
        self.loadingMessage = msg
        super.init(frame: CGRect(x: inview.frame.midX-30, y: inview.frame.midY-30  , width: 60, height: 60))
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
        
        messageFrame.frame = self.bounds
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
        messageFrame.addSubview(strLabel)
    }
    
    func  start(){
        //check if view is already there or not..if again started
        if !self.subviews.contains(messageFrame){
            UIApplication.shared.beginIgnoringInteractionEvents()
            activityIndicator.startAnimating()
            self.addSubview(messageFrame)
        }
    }
    
    func stop(){

        if self.subviews.contains(messageFrame){
            UIApplication.shared.endIgnoringInteractionEvents()
            activityIndicator.stopAnimating()
            messageFrame.removeFromSuperview()
            
        }
    }
}
