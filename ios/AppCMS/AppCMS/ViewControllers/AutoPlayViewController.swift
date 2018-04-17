//
//  AutoPlayViewController.swift
//  AppCMS
//
//  Created by  Diksha Goyal on 11/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import Firebase

class AutoPlayViewController: UIViewController,SFAutoPlayDelegate {
   

    var modulesListArray:Array<AnyObject> = []
    var filmObject :SFFilm!
    var autoPlayObject : SFAutoplayObject!
    var autoPlayView : SFAutoplayView?
    var backgroundImageView :SFImageView = SFImageView()
    var networkUnavailableAlert:UIAlertController?
    var videoDetailDescriptionViewController:VideoDetailDescriptionViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createModuleListForAutoplay()
        self.createNavigationBar()
        // Do any additional setup after loading the view.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            FIRAnalytics.setScreenName("AutoPlay Screen", screenClass: nil)
        }

        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.allowIDFACollection = true
        tracker.set(kGAIScreenName, value: "AutoPlay Screen")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    init () {
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createNavigationBar() -> Void {
        self.navigationController?.navigationBar.barTintColor=UIColor.clear

        self.navigationItem.leftBarButtonItems = nil
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15

        let backButton = UIButton(type: .custom)
        backButton.setTitle("BACK", for: UIControlState.normal)
        let backButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "Back.png"))
        
        backButton.setImage(backButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        backButton.titleLabel?.textColor = Utility.hexStringToUIColor(hex: "ffffff")
        backButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (backButtonImageView.image?.size.height)!/2)

        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(backButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItems = [negativeSpacer, backButtonItem]
    }
    
    
    func backButtonTapped(sender: UIButton) -> Void {
      
        autoPlayView?.timer.invalidate()
        NotificationCenter.default.post(name: Notification.Name("dismissAutoplayView"), object: autoPlayButtonAction.cancel)
    }

    func createModuleListForAutoplay() {

        var filePath:String!
        
        guard let pageID: String = Utility.sharedUtility.getPageIdFromPagesArray(pageName: "AutoPlay Screen") else { return }
        filePath = AppSandboxManager.getpageFilePath(fileName: pageID)
        
        if FileManager.default.fileExists(atPath: filePath)
        {
            let jsonData:Data = FileManager.default.contents(atPath: filePath)!
            
            let responseStarJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, Any>
            let responseJson:Array<Dictionary<String, AnyObject>> = responseStarJson["moduleList"] as! Array<Dictionary<String, AnyObject>>
            
            let moduleUIParser = ModuleUIParser()
            
            modulesListArray = moduleUIParser.parseModuleConfigurationJson(modulesConfigurationArray: responseJson) as Array<AnyObject>
            
            createModules()
       }
    }
    
    
    func createModules() -> Void {
        for module:AnyObject in self.modulesListArray {
            
            if module is SFAutoplayObject {
                
                let carouselLayout = Utility.fetchAutoPlayDetailLayoutDetails(autoPlayViewObject:module as! SFAutoplayObject)
                let frame: CGRect = CGRect(x: CGFloat(carouselLayout.xAxis!), y: CGFloat(carouselLayout.yAxis!), width: CGFloat(carouselLayout.width!)*Utility.getBaseScreenWidthMultiplier(), height: self.view.frame.size.height-64)
                let autoPlayView: SFAutoplayView = SFAutoplayView.init(frame: frame, autoplayObject: module as! SFAutoplayObject, filmObject: filmObject!)
                
                self.autoPlayView?.updateView()
                autoPlayObject = module as! SFAutoplayObject
                
                self.addImageView()
                // autoPlayView.center = CGPoint(x: self.view.center.x, y:self.view.center.y)
                self.view.addSubview(autoPlayView)
                autoPlayView.autoPlayDelegate=self
                
                if self.autoPlayView != nil {
                    
                    self.autoPlayView = nil
                }
                
                self.autoPlayView=autoPlayView
                self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "FFFFFF")
                //self.view.alpha = autoPlayObject.viewAlpha!
            }
        }
    }
    
    
    func addImageView()
    {
        var imagePathString: String?
        for image in filmObject.images {
            let imageObj: SFImage = image as! SFImage
            if imageObj.imageType == nil{
                if imageObj.imageSource != nil {
                    imagePathString = imageObj.imageSource
                    break
                }
            }
            else{
                if imageObj.imageType == Constants.kSTRING_IMAGETYPE_POSTER || imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO
                {
                    imagePathString = imageObj.imageSource
                    break
                }
            }
        }
        if imagePathString != nil
        {
            
            imagePathString = imagePathString?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: backgroundImageView.frame.size.width))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: backgroundImageView.frame.size.height))")
            imagePathString = imagePathString?.trimmingCharacters(in: .whitespaces)
            
            if let imageUrl = URL(string:imagePathString!) {
                
                backgroundImageView.af_setImage(
                    withURL: imageUrl,
                    placeholderImage: UIImage(named: Constants.kVideoImagePlaceholder),
                    filter: nil,
                    imageTransition: .noTransition
                )
            }
            else {
                
                backgroundImageView.image = UIImage(named: Constants.kVideoImagePlaceholder)
            }
            
        }
        else
        {
            backgroundImageView.image = UIImage(named: Constants.kVideoImagePlaceholder)
        }
        backgroundImageView.frame = self.view.bounds
        backgroundImageView.addBlurEffect()
        view.addSubview(backgroundImageView)
    }
    
    //MARK: Orientation Method
    override func viewDidLayoutSubviews() {
        
//        if !Constants.IPHONE {
            UIView.performWithoutAnimation {
                if autoPlayView != nil {
                    
                    var moduleWidth: CGFloat = CGFloat(Utility.fetchAutoPlayDetailLayoutDetails(autoPlayViewObject:(self.autoPlayView?.autoPlayObject)!).width!)
                    moduleWidth = moduleWidth * Utility.getBaseScreenWidthMultiplier()
                    self.autoPlayView?.changeFrameWidth(width: moduleWidth)
                    backgroundImageView.frame = self.view.bounds
                    self.autoPlayView?.changeFrameHeight(height: self.view.frame.size.height-64)
                    self.autoPlayView?.center = CGPoint(x: self.view.center.x, y:self.view.center.y)
                    self.autoPlayView?.updateView()
                }
            }
//        }
    }
    
    
    //MARK: Display Network Error Alert
    func showAlertForAlertType(alertType: AlertType) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isStatusBarHidden = false
                self.dismiss(animated: true) {
                }
            }
        }
        
        var alertTitleString:String?
        var alertMessage:String?
        
        if alertType == .AlertTypeNoInternetFound {
            alertTitleString = Constants.kInternetConnection
            alertMessage = Constants.kInternetConntectionRefresh
        }
        
        networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction])
        
        self.present(networkUnavailableAlert!, animated: true, completion: nil)
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    // To Do:- 
    
    //MARK: method to view more description
    func moreButtonTapped(filmObject: SFFilm) {
        /* NotificationCenter.default.addObserver(self, selector: #selector(dismissVideoDetailDesrptionView), name: NSNotification.Name(rawValue: "dismissAutoplayView"), object: nil)
         self.videoDetailDescriptionViewController = VideoDetailDescriptionViewController.init(film: filmObject)
        videoDetailDescriptionViewController?.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000").withAlphaComponent(0.90)
        videoDetailDescriptionViewController?.modalPresentationStyle = .overCurrentContext
        self.present(videoDetailDescriptionViewController!, animated: true, completion: nil)*/
    }
    func dismissVideoDetailDesrptionView(_ notification: Notification) 
    {
        /*NotificationCenter.default.removeObserver(self, name : NSNotification.Name(rawValue: "dismissAutoplayView"), object:nil)
        if let buttonTapped = notification.object as? autoPlayButtonAction {
        if (buttonTapped==autoPlayButtonAction.play && (self.videoDetailDescriptionViewController?.presentedViewController))    {
        
        self.videoDetailDescriptionViewController?.dismiss(animated: false, completion:nil)
        
    }
    
        }*/
        
    }

}
extension UIImageView
{
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}
