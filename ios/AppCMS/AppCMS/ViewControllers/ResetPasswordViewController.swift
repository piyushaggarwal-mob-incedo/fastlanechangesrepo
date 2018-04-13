//
//  ResetPasswordViewController.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 30/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import Firebase
class ResetPasswordViewController: UIViewController, LoginViewDelegate {

    var modulesListArray:Array<AnyObject> = []
    var modulesArray:Array<AnyObject> = []
    var loginPageSelection: Int = 0
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        fetchLoginPageUI()
        createNavigationBar()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            FIRAnalytics.setScreenName("Reset Password", screenClass: nil)
        }
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.allowIDFACollection = true
        tracker.set(kGAIScreenName, value: "Reset Password")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchLoginPageUI() -> Void {
        
        let pageID: String? = Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Reset Password")
        
        if pageID != nil {
            
            let filePath:String? = AppSandboxManager.getpageFilePath(fileName: pageID!)
            
            if filePath != nil {
                
                if FileManager.default.fileExists(atPath: filePath!){
                    let jsonData:Data? = FileManager.default.contents(atPath: filePath!)
                    
                    if jsonData != nil {
                        
                        let responseStarJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData!) as! Dictionary<String, Any>
                        let responseJson:Array<Dictionary<String, AnyObject>> = responseStarJson["moduleList"] as! Array<Dictionary<String, AnyObject>>
                        
                        let moduleUIParser = ModuleUIParser()
                        modulesListArray = moduleUIParser.parseModuleConfigurationJson(modulesConfigurationArray: responseJson) as Array<AnyObject>
                        createModules()
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        if !Constants.IPHONE {
            
            UIView.performWithoutAnimation {
                
                for module:AnyObject in self.modulesArray {
                    
                    if module is SFLoginView {
                        let moduleHeight: CGFloat = self.view.frame.height - 64
                        let moduleWidth: CGFloat = self.view.frame.width
                        
                        (module as! SFLoginView).changeFrameHeight(height: moduleHeight)
                        (module as! SFLoginView).changeFrameWidth(width: moduleWidth)
                        
                        (module as! SFLoginView).updateView()
                    }
                }
            }
        }
    }
    
    func createNavigationBar() -> Void {
        self.navigationItem.leftBarButtonItems = nil
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15
        
        let backButton = UIButton(type: .custom)
        backButton.sizeToFit()
        let backButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "Back.png"))
        
        backButton.setImage(backButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        
        backButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (backButtonImageView.image?.size.height)!/2)
        backButton.addTarget(self, action: #selector(backButtonTapped(sender:)), for: UIControlEvents.touchUpInside)

        let backButtonItem = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItems = [negativeSpacer, backButtonItem]

        self.navigationController?.navigationBar.barTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        self.navigationItem.titleView = Utility.createNavigationTitleView(navBarHeight: (self.navigationController?.navigationBar.frame.size.height)!)


    }
    
    func backButtonTapped(sender: UIButton) -> Void {
        self.navigationController?.popViewController(animated: true)
    }

    func getPosition(position:CGFloat) -> CGFloat {
        var value = position
        if (Constants.IPHONE && Utility.sharedUtility.isIphoneX()) {
            value = value + 24;
        }
        return value;
    }

    func createModules() -> Void {
        for module:AnyObject in self.modulesListArray {
            
            if module is LoginObject {
                var ii: Int = 0
                for component in (module as! LoginObject).components
                {
                    if component is LoginComponent
                    {
                        let loginFrame: CGRect = CGRect.init(x: 0, y: getPosition(position: 64), width: self.view.frame.width, height: self.view.frame.height - getPosition(position: 64))
                        let loginView: SFLoginView = SFLoginView.init(frame: loginFrame, loginObject: component as! LoginComponent, viewTag: ii)
                        loginView.loginViewDelegate = self
                        self.modulesArray.append(loginView)
                        self.view.addSubview(loginView)
                    }
                    ii = ii+1
                }
            }
        }
    }
    
    func forgotPasswordTapped() -> Void
    {
        
    }


}
