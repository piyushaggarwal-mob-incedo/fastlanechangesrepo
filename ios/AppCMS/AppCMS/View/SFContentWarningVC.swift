//
//  CRWViewController.swift
//  AppCMS
//
//  Created by Suraj Gupta on 18/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//


@objc protocol SFContentWarningVCDelegate:NSObjectProtocol {
    @objc func timmerCompleted() -> Void
}

class SFContentWarningVC: UIViewController {
    
    var APP_THEME_COLOR:UIColor! = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff")
    
    var progressView:UIProgressView!
    var backButton:UIButton!
    var outerContainer:UIView!
    var innerContainer:UIView!
    var warningLbl:UILabel!
    var viewerDescLbl:UILabel!
    var viewerGradeLbl:UILabel!
    var contentGradeLbl:UILabel!
    var backBtnUnderLineView:UIView!
    var contentCateg:String!
    weak var sfContentWarningVCDelegate:SFContentWarningVCDelegate?
    
    init (contentCategory: String) {
        self.contentCateg = contentCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")

        let multiplier:CGFloat = Constants.IPHONE ? 1.3:2.0
        
        self.progressView = UIProgressView(progressViewStyle: .bar);
        self.progressView.tintColor = APP_THEME_COLOR
        self.progressView.trackTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        self.progressView.progress  = 0.0
        self.progressView.frame = CGRect(x:(self.view.frame.size.width-self.view.frame.width*0.92)/2,y:self.view.frame.size.height*0.92,width:self.view.frame.width*0.92,height:2*multiplier)
        self.view.addSubview(self.progressView);
        
        self.backButton = UIButton.init(type: .custom)
        self.backButton.addTarget(self, action: #selector(backButtonTapped(sender:)), for: .touchUpInside)
        self.backButton.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        self.backButton.setTitle("Back", for: .normal)
        self.backButton.contentHorizontalAlignment = .left
        self.view.addSubview(self.backButton)
        
        self.backBtnUnderLineView = UIView.init()
        backBtnUnderLineView.backgroundColor = APP_THEME_COLOR
        self.view.addSubview(backBtnUnderLineView)
        
        self.outerContainer = UIView.init()
        self.view.addSubview(self.outerContainer)
        
        self.innerContainer = UIView.init()
        self.innerContainer.layer.borderColor = APP_THEME_COLOR.cgColor
        self.innerContainer.layer.borderWidth = 2.0
        var boxWidth:CGFloat;
        self.view.addSubview(self.innerContainer)
        if self.view.frame.size.width / self.view.frame.size.height > 1 {
           boxWidth = UIScreen.main.bounds.size.height
        } else {
            boxWidth = UIScreen.main.bounds.size.width
        }
        self.outerContainer.frame = CGRect(x:0,y:0,width:boxWidth*0.92,height:62*multiplier)
        self.innerContainer.frame = CGRect(x:0,y:0,width:boxWidth*0.92,height:30*multiplier)
        
        self.warningLbl = UILabel.init()
        self.warningLbl.text = "WARNING"
        self.warningLbl.textColor = APP_THEME_COLOR
        self.outerContainer.addSubview(self.warningLbl)
        
        self.viewerGradeLbl = UILabel.init()
        self.viewerGradeLbl.text = "Viewer Discretion Is Advised"
        self.viewerGradeLbl.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        self.viewerGradeLbl.frame = CGRect(x:0,y:0,width:150*multiplier,height:12*multiplier)
        self.viewerGradeLbl.textAlignment = .center
        self.outerContainer.addSubview(self.viewerGradeLbl)
        
        self.contentGradeLbl = UILabel.init()
        let statictextAttribute   = [ NSFontAttributeName: UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-BoldItalic", size: 10 * multiplier)]
        let statictextStr   = NSMutableAttributedString(string: "The following content is rated: ", attributes: statictextAttribute )
        let contentAttribute   = [ NSFontAttributeName: UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 12 * multiplier)]
        let contetentStr       = NSAttributedString(string: self.contentCateg!, attributes: contentAttribute)
        
        statictextStr.append(contetentStr)
        
        self.contentGradeLbl.attributedText = statictextStr
        self.contentGradeLbl.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        self.contentGradeLbl.frame = CGRect(x:0,y:0,width:self.innerContainer.frame.size.width*0.80,height:43*multiplier)
        self.contentGradeLbl.textAlignment   = .center
        self.innerContainer.addSubview(self.contentGradeLbl)
        
        //Font setup
        self.warningLbl.font =  UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 10 * multiplier)
        self.backButton.titleLabel!.font =  UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 10 * multiplier)
        self.viewerGradeLbl.font =  UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 10 * multiplier)
        
        //Frame Setup
        self.warningLbl.frame = CGRect(x:(self.outerContainer.frame.size.width-62*multiplier)/2,y:0,width:70*multiplier,height:16*multiplier)
        self.backButton.frame = CGRect(x:self.progressView.frame.origin.x,y:14,width:48*multiplier,height:12*multiplier)
        self.viewerGradeLbl.frame = CGRect(x:(self.outerContainer.frame.size.width-self.viewerGradeLbl.frame.size.width)/2,y:self.outerContainer.frame.origin.y+self.outerContainer.frame.size.height-12*multiplier,width:self.viewerGradeLbl.frame.size.width,height:12*multiplier)
        self.contentGradeLbl.frame = CGRect(x:self.innerContainer.frame.origin.x+self.innerContainer.frame.width*0.20,y:(self.innerContainer.frame.size.height-self.contentGradeLbl.frame.size.height)/2,width:self.contentGradeLbl.frame.size.width, height:self.contentGradeLbl.frame.size.height)
        
        //Underline Back button
        let backBtnfontAttributes = [NSFontAttributeName: self.backButton.titleLabel?.font]
        let titleSize = self.backButton.title(for: .normal)?.size(attributes: backBtnfontAttributes)
        self.backBtnUnderLineView.frame = CGRect(x:self.backButton.frame.origin.x,y:self.backButton.frame.height+self.backButton.frame.origin.y,width:(titleSize?.width)!,height:2)
        
        self.warningLbl.alpha = 0.0
        self.contentGradeLbl.alpha = 0.0
        self.innerContainer.alpha = 0.0
        self.viewerGradeLbl.alpha = 0.0
    }
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration:3.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            
            self.progressView.setProgress(1.0, animated: true)
            // Animations
            
        }, completion: { finished in
            
            // remove the views
            if finished {
                
            }
        })
        self.glowAnimation(view: self.warningLbl,animationDurtion: 0.6, delay:0.2)
        self.glowAnimation(view: innerContainer,animationDurtion: 0.6, delay:0.2)
        self.applyfadeInMoveViewToPosx(view:self.contentGradeLbl,xPos: (self.innerContainer.frame.size.width-self.contentGradeLbl.frame.size.width)/2, animationDurtion:1.0, delay: 0.6)
        self.glowAnimation(view: self.viewerGradeLbl,animationDurtion: 2.0, delay:1.0)
        
        self.perform(#selector(dismissVC), with: nil, afterDelay: 3.0)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func dismissVC(){
        if Constants.IPHONE
        {
            print("11111 >>>>>>>>")
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
        if self.sfContentWarningVCDelegate != nil && (self.sfContentWarningVCDelegate!.responds(to: #selector(self.sfContentWarningVCDelegate!.timmerCompleted))) {
            
            Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: "isContentWarningForcefullyDismissed")
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
            self.sfContentWarningVCDelegate?.timmerCompleted()
            self.dismiss(animated: true, completion: {
                
                
            })
        }
        
    }
    
    func backButtonTapped(sender: UIButton) -> Void {
        UIApplication.shared.isStatusBarHidden = false
        self.sfContentWarningVCDelegate = nil
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector:#selector(dismissVC) , object: nil)//Cancel perform selector
        self.view.layer.removeAllAnimations()//Remove all animation
        if Constants.IPHONE{
            
            Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: "isContentWarningForcefullyDismissed")
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
            Constants.kAPPDELEGATE.isBackgroundImageVisible = true
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
        self.presentingViewController!.presentingViewController!.dismiss(animated: false) {
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.outerContainer.center = self.view.center
        self.innerContainer.center = self.view.center
        self.perform(#selector(setFrameOfProgressOnRotationChange), with: nil, afterDelay: 0.2)
        }
    
    func setFrameOfProgressOnRotationChange(){
        self.progressView.frame = CGRect(x:(self.view.frame.size.width-self.view.frame.width*0.92)/2,y:self.view.frame.size.height*0.92,width:self.view.frame.width*0.92,height:self.progressView.frame.height)
        self.backButton.frame = CGRect(x:self.progressView.frame.origin.x,y:14,width:self.backButton.frame.width,height:self.backButton.frame.height)
        self.backBtnUnderLineView.frame = CGRect(x:self.backButton.frame.origin.x,y:self.backButton.frame.height+self.backButton.frame.origin.y,width:(self.backBtnUnderLineView.frame.size.width),height:2)
        self.progressView.transform = self.progressView.transform.scaledBy(x: 1, y: Constants.IPHONE ? 2:4)
    }
    
    func applyfadeInMoveViewToPosx (view:UIView,xPos:CGFloat,animationDurtion:TimeInterval,delay:TimeInterval)  {
        
        UIView.animate(withDuration: animationDurtion, delay: delay, options: .curveEaseIn, animations: {
            view.alpha = 1.0
            view.frame = CGRect(x:xPos, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
        }, completion: nil)
    }
    
    func glowAnimation(view:UIView,animationDurtion:TimeInterval,delay:TimeInterval) {
        UIView.animate(withDuration: animationDurtion, delay: delay, options: .curveEaseOut, animations: {
            view.alpha = 1.0
        }, completion: {
            finished in
        })
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
