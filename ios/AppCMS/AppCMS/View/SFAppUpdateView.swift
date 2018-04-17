//
//  SFAppUpdateView.swift
//  AppCMS
//
//  Created by Gaurav Vig on 02/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFAppUpdateView: UIView {

    var appUpdateViewLabel:UILabel?
    var appLogo:UIImageView?
    var updateButton:UIButton?
    var isForceUpdate:Bool?
    var appUpdateSeparatorView:UIView?
    let appUpdateText:String = "There is some optimisation done in application.\nKindly update to newer app version."

    let appVersion:String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let appBuild:String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

    init(frame:CGRect, isForceUpdate:Bool ) {
        
        self.isForceUpdate = isForceUpdate
        
        super.init(frame: frame)
        
        if !isForceUpdate {
            
            self.createSoftAppUpdateAlert()
        }
        else {
            
            self.createForceAppUpdateView()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSoftAppUpdateAlert() {
        
        appUpdateViewLabel = UILabel(frame: CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width - 20, height: 60))
        appUpdateViewLabel?.text = "Your app's version \(self.appVersion).\(self.appBuild) is out of date. The current version \(AppConfiguration.sharedAppConfiguration.appAppStoreVersionNumber ?? "") is available in the App Store for upgrade."
        appUpdateViewLabel?.numberOfLines = 0
        appUpdateViewLabel?.textColor = UIColor.white
        appUpdateViewLabel?.textAlignment = .center
        appUpdateViewLabel?.adjustsFontSizeToFitWidth = true
        appUpdateViewLabel?.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 10)
        self.addSubview(appUpdateViewLabel!)

        appUpdateSeparatorView = UIView(frame: CGRect(x: (Constants.kAPPDELEGATE.window?.center.x)! - 50/2, y: self.frame.size.height - 5, width: 50, height: 5))
        appUpdateSeparatorView?.backgroundColor = UIColor.white
        appUpdateSeparatorView?.layer.cornerRadius = 2
        self.addSubview(appUpdateSeparatorView!)
        
        self.alpha = 0
    }
    
    
    //MARK: Method to present Force app update view
    func presentForcedAppUpdateView() {
        
        self.createForceAppUpdateView()
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.alpha = 1
        })
    }
    
    
    //MARK: Method to create Force app update view
    private func createForceAppUpdateView() {
        
        appUpdateViewLabel = UILabel(frame: CGRect(x: (Constants.kAPPDELEGATE.window?.center.x)! - (UIScreen.main.bounds.width - 40)/2, y: (Constants.kAPPDELEGATE.window?.center.y)! - 80, width: UIScreen.main.bounds.width - 40, height: 160))
        appUpdateViewLabel?.text = "Your app's version \(self.appVersion).\(self.appBuild) is out of date and no longer supported. The current version \(AppConfiguration.sharedAppConfiguration.appAppStoreVersionNumber ?? "") is available in the App Store for upgrade."
        appUpdateViewLabel?.textColor = UIColor.white
        appUpdateViewLabel?.numberOfLines = 0
        appUpdateViewLabel?.textAlignment = .center
        appUpdateViewLabel?.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 12)
        self.addSubview(appUpdateViewLabel!)
        
        let appLogoImage:UIImage = #imageLiteral(resourceName: "clientnavlogo.png")
        appLogo = UIImageView(frame: CGRect(x: (Constants.kAPPDELEGATE.window?.center.x)! - appLogoImage.size.width/2, y: (appUpdateViewLabel?.frame.minY)! - appLogoImage.size.height - 20, width: appLogoImage.size.width, height: appLogoImage.size.height))
        appLogo?.image = appLogoImage
        self.addSubview(appLogo!)
        
        updateButton = UIButton(frame: CGRect(x: (Constants.kAPPDELEGATE.window?.center.x)! - 180/2, y: (appUpdateViewLabel?.frame.maxY)! + 20, width: 180, height: 40))
        updateButton?.setTitle("UPDATE APPLICATION", for: .normal)
        updateButton?.titleLabel?.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Semibold", size: 12)
        updateButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000")
        updateButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor ?? AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        updateButton?.addTarget(self, action: #selector(navigateToAppStore), for: .touchUpInside)
        self.addSubview(updateButton!)
    }
    
    //MARK: Method to navigate to app store
    func navigateToAppStore() {
        
        if AppConfiguration.sharedAppConfiguration.appStoreUrl != nil {
            
            guard let appStoreURL = URL(string: AppConfiguration.sharedAppConfiguration.appStoreUrl!) else { return }
            
            UIApplication.shared.openURL(appStoreURL)
        }
    }
    
    //MARK: Method to update frames on orientation change
    func updateAppUpdateSubViewsFrames() {
        
        if appUpdateViewLabel != nil {
            if !(self.isForceUpdate)! {
                
                appUpdateViewLabel?.changeFrameWidth(width: UIScreen.main.bounds.width - (appUpdateViewLabel?.frame.minX)!)
            }
            else {
                
                appUpdateViewLabel?.frame = CGRect(x: 40, y: (Constants.kAPPDELEGATE.window?.center.y)! - 80, width: UIScreen.main.bounds.width - 40, height: 160)
            }
        }
        
        if appLogo != nil {
            
            appLogo?.changeFrameXAxis(xAxis: (Constants.kAPPDELEGATE.window?.center.x)! - (appLogo?.frame.size.width)!/2)
            appLogo?.changeFrameYAxis(yAxis: (appUpdateViewLabel?.frame.minY)! - (appLogo?.frame.size.height)! - 20)
        }
        
        if updateButton != nil {
            
            updateButton?.changeFrameXAxis(xAxis: (Constants.kAPPDELEGATE.window?.center.x)! - 180/2)
            updateButton?.changeFrameYAxis(yAxis: (appUpdateViewLabel?.frame.maxY)! + 20)
        }
        
        if appUpdateSeparatorView != nil {
            
            appUpdateSeparatorView?.changeFrameXAxis(xAxis: (Constants.kAPPDELEGATE.window?.center.x)! - 50/2)
        }
    }
    
    
    deinit {
        
        self.updateButton = nil
        self.appLogo = nil
        self.appUpdateViewLabel = nil
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
