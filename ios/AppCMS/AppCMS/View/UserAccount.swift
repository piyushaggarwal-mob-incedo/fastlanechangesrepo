//
//  UserAccount.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 05/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol UserDetailsViewDelegate: NSObjectProtocol {
    @objc optional func buttonTapped(sender: SFButton) -> Void
}

class UserAccount: UIView, SFButtonDelegate, SFToggleDelegate {

    weak var userDetailViewDelegate: UserDetailsViewDelegate?
    var userAccountModule: UserAccountModuleObject!
    var viewTag: Int?
    var progressIndicator:MBProgressHUD?
    var userDetails:SFUserDetails?
    var userAccountViewLayout:LayoutObject?
    var userAccountViewObject:UserAccountComponentObject?
    var relativeViewFrame:CGRect?
    
    init(frame: CGRect, userAccountObject: UserAccountModuleObject, userAccountViewObject:UserAccountComponentObject, viewTag: Int) {
        super.init(frame: frame)
        self.userAccountModule = userAccountObject
        self.userAccountViewObject = userAccountViewObject
        self.viewTag = viewTag
        
        self.changeFrameHeight(height: self.frame.size.height * Utility.getBaseScreenHeightMultiplier())
        if self.userAccountViewObject != nil {
            
            createView()
        }
    }
    
    func initialiseUserAccountViewFrameFromLayout(userAccountViewLayout:LayoutObject) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: userAccountViewLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createView() -> Void {
        createUserDetailsView(containerView: self, itemIndex: 0)
    }
    
    
    //MARK: Creation of View Components
    func createUserDetailsView(containerView: UIView, itemIndex:Int) {
        
        for component:AnyObject in (self.userAccountViewObject?.components)! {
            
            if component is SFButtonObject {
                
                let buttonObject:SFButtonObject = component as! SFButtonObject
                if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) as! String == UserLoginType.Facebook.rawValue || Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) as! String == UserLoginType.Gmail.rawValue
                {
                    if buttonObject.action == "editProfile" || buttonObject.action == "changePassword"
                    {
                        continue
                    }
                    else
                    {
                        createButtonView(buttonObject: buttonObject, containerView: self, itemIndex: itemIndex, type: component.key!!)
                    }
                }
                else
                {
                    createButtonView(buttonObject: buttonObject, containerView: self, itemIndex: itemIndex, type: component.key!!)
                }
            }
            else if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject, containerView: containerView, type: component.key!!)
            }
            else if component is SFSeparatorViewObject
            {
                createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
            }
            else if component is SFToggleObject
            {
                createToggleView(toggleObject: component as! SFToggleObject, containerView: self)
            }
        }
    }
    
    
    func createLabelView(labelObject:SFLabelObject, containerView:UIView, type: String) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        
        label.createLabelView()
        label.font = UIFont(name: label.font.fontName, size: label.font.pointSize * Utility.getBaseScreenHeightMultiplier())
        containerView.addSubview(label)
        containerView.bringSubview(toFront: label)
        
        if label.labelObject?.key == "settingsTitle" {
            
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff")
        }
    }
    
    func createButtonView(buttonObject:SFButtonObject, containerView:UIView, itemIndex:Int, type: String) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        
        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.buttonLayout = buttonLayout
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.buttonDelegate = self
        button.tag = itemIndex
        button.createButtonView()
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!, size: (button.titleLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
        button.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        // MSEIOS-1512
        button.titleLabel?.lineBreakMode = .byClipping
        button.contentHorizontalAlignment = .right
        containerView.addSubview(button)
        containerView.bringSubview(toFront: button)
    }
    
    func createToggleView(toggleObject:SFToggleObject, containerView:UIView) -> Void {
        
        let toggleLayout = Utility.fetchToggleLayoutDetails(toggleObject: toggleObject)
        
        let toggle:SFToggle = SFToggle(frame: CGRect.zero)
        toggle.toggleObject = toggleObject
        toggle.toggleLayout = toggleLayout
        toggle.relativeViewFrame = containerView.frame
        toggle.initialiseToggleFrameFromLayout(toggleLayout: toggleLayout)
        toggle.toggleDelegate = self
        toggle.createToggleView()
        if toggleObject.key == "Manage Autoplay"
        {
            let currentAutoPlayState: Bool? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) as? Bool
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) != nil
            {
                toggle.setOn(currentAutoPlayState!, animated: false)
            }
            else
            {
                toggle.setOn(true, animated: false)
                Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kAutoPlay)
            }
        }
        else
        {
            let currentCellularDownloadState: Bool? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kCellularDownload) as? Bool
            toggle.setOn(currentCellularDownloadState!, animated: false)
        }
        
        
        containerView.addSubview(toggle)
        containerView.bringSubview(toFront: toggle)
    }
    
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        let separatorViewLayout = Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject)
        let separatorView: SFSeparatorView = SFSeparatorView()
        separatorView.separtorViewObject = separatorViewObject
        separatorView.isHidden = false
        separatorView.relativeViewFrame = self.frame
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: separatorViewLayout)
        
//        separatorView.changeFrameXAxis(xAxis: separatorView.frame.minX * Utility.getBaseScreenWidthMultiplier())
//        separatorView.changeFrameHeight(height: separatorView.frame.height * Utility.getBaseScreenHeightMultiplier())
        
//        if separatorViewLayout.height != nil {
//            
//            separatorView.changeFrameYAxis(yAxis: ceil(separatorView.frame.origin.y - (separatorView.frame.size.height - CGFloat(separatorViewLayout.height!))))
//        }
        
        self.addSubview(separatorView)
    }
    
    
    //MARK: updation of view frame components
    func updateView() -> Void
    {
        for component: AnyObject in self.subviews {
            
            if component is SFButton {
                
                updateButtonViewFrame(button: component as! SFButton, containerView: self)
            }
            else if component is SFLabel {
                
                updateLabelViewFrame(label: component as! SFLabel, containerView: self)
            }
            else if component is SFSeparatorView
            {
                updateSeparatorViewFrame(separatorView: component as! SFSeparatorView, containerView: self)
            }
            else if component is SFToggle
            {
                updateToggleViewFrame(toggle: component as! SFToggle, containerView: self)
            }
        }
    }
    
    //MARK: Update Video Description Subviews
    func updateLabelViewFrame(label:SFLabel, containerView:UIView) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!)
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)

        label.changeFrameWidth(width: label.frame.width * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameHeight(height: label.frame.height * Utility.getBaseScreenHeightMultiplier())

        if labelLayout.height != nil {
            
            label.changeFrameYAxis(yAxis: ceil(label.frame.origin.y + (label.frame.size.height - CGFloat(labelLayout.height!))))
        }
        
        if label.labelObject?.key == "AppVersionValue" {
            
            if labelLayout.width != nil {
                
                label.changeFrameXAxis(xAxis: ceil(label.frame.origin.x - (label.frame.size.width - CGFloat(labelLayout.width!))))
            }
        }
    }
    
    func updateButtonViewFrame(button:SFButton, containerView:UIView) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: button.buttonObject!)
        
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        
        button.changeFrameWidth(width: button.frame.width * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameHeight(height: button.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        if buttonLayout.width != nil {
            
            button.changeFrameXAxis(xAxis: ceil(button.frame.origin.x - (button.frame.size.width - CGFloat(buttonLayout.width!))))
        }
        
        if buttonLayout.height != nil {
            
            button.changeFrameYAxis(yAxis: ceil(button.frame.origin.y + (button.frame.size.height - CGFloat(buttonLayout.height!))))
        }
    }
    
    func updateToggleViewFrame(toggle:SFToggle, containerView:UIView) -> Void {
        
        let toggleLayout = Utility.fetchToggleLayoutDetails(toggleObject: toggle.toggleObject!)
        
        toggle.relativeViewFrame = containerView.frame
        toggle.initialiseToggleFrameFromLayout(toggleLayout: toggleLayout)
        
        toggle.changeFrameWidth(width: toggle.frame.width * Utility.getBaseScreenWidthMultiplier())
        toggle.changeFrameHeight(height: toggle.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        if toggleLayout.width != nil {
            
            toggle.changeFrameXAxis(xAxis: ceil(toggle.frame.origin.x - (toggle.frame.size.width - CGFloat(toggleLayout.width!))))
        }
        
        if toggleLayout.height != nil {
            
            toggle.changeFrameYAxis(yAxis: ceil(toggle.frame.origin.y * Utility.getBaseScreenHeightMultiplier() - (toggle.frame.size.height - CGFloat(toggleLayout.height!))))
        }
    }
    
    func updateSeparatorViewFrame(separatorView: SFSeparatorView, containerView: UIView) -> Void {
        let separatorViewLayout = Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorView.separtorViewObject!)
        separatorView.relativeViewFrame = containerView.frame
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: separatorViewLayout)
        
//        separatorView.changeFrameXAxis(xAxis: separatorView.frame.minX * Utility.getBaseScreenWidthMultiplier())
//        separatorView.changeFrameHeight(height: separatorView.frame.height * Utility.getBaseScreenHeightMultiplier())
//        
//        if separatorViewLayout.height != nil {
//            
//            separatorView.changeFrameYAxis(yAxis: ceil(separatorView.frame.origin.y - (separatorView.frame.size.height - CGFloat(separatorViewLayout.height!))))
//        }
    }
    
    
    //MARK: updation of user details on view components
    func updateUserDetailsOnView() -> Void {
        
        for component: AnyObject in self.subviews {
            
            if component is SFLabel {
                
                updateLabelViewDetails(label: component as! SFLabel, containerView: self)
            }
            else if component is SFButton {
                
                updateButtonViewDetails(button: component as! SFButton, containerView: self)
            }
        }
    }
    
    
    //MARK: Update Video Description Subviews
    func updateLabelViewDetails(label:SFLabel, containerView:UIView) {
        
        //update label text
        if label.labelObject?.key == "settingsTitle" {
            
            label.text = label.labelObject?.text
        }
        else if label.labelObject?.key == "name" {
            
            label.text = label.labelObject?.text
        }
        else if label.labelObject?.key == "nameValue" {
            
            label.text = self.userDetails?.name
        }
        else if label.labelObject?.key == "email" {
            
            label.text = label.labelObject?.text
        }
        else if label.labelObject?.key == "emailValue" {
            
            label.text = self.userDetails?.emailID
        }
        else if label.labelObject?.key == "mobileValue"
        {
            var countryCodeSting: String = ""
            for countryVal in AppConfiguration.sharedAppConfiguration.countryDialCodesArray
            {
                let localCountry: SFCountryDialModel = countryVal
                if self.userDetails?.mobileCountryCode == localCountry.countryCode!
                {
                    countryCodeSting = localCountry.countryDialCode!
                    break
                }
            }

            label.text = "\(countryCodeSting)-\(self.userDetails?.mobile ?? "")"
        }
        else if label.labelObject?.key == "mobile" {
            
            label.text = label.labelObject?.text
        }
        else if label.labelObject?.key == "paymentProcessorValue" {
            
            label.text = self.userDetails?.paymentMethod
        }
        else if label.labelObject?.key == "plan" {
            
            label.text = label.labelObject?.text
        }
        else if label.labelObject?.key == "planValue" {
            
            label.text = self.userDetails?.subscriptionPlan
        }
        else if label.labelObject?.key == "download Quality" {
            
            label.text = label.labelObject?.text
        }
        else if label.labelObject?.key == "Autoplay" {
            
            label.text = label.labelObject?.text
        }
        else if label.labelObject?.key == "downloadQualityValue" {
            if DownloadManager.sharedInstance.downloadQuality == ""{
                label.text = "720p"
            }
            else{
                label.text = DownloadManager.sharedInstance.downloadQuality
            }
        }
        else if label.labelObject?.key == "paymentProcess"{
            label.text = label.labelObject?.text
        }
        else if label.labelObject?.key == "cellularDataTitle"{
            label.text = label.labelObject?.text
        }
        else if label.labelObject?.key == "AppVersionTitle"{
            label.text = label.labelObject?.text
        }
        else if label.labelObject?.key == "AppVersionValue"{
            let version:String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let build:String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            
            let appVersion: String = "\(version).\(build)"
            label.text = appVersion
        }
    }
    
    
    func updateButtonViewDetails(button:SFButton, containerView:UIView) {
        
        if button.buttonObject?.action == "manageSubscription" && self.userDetails?.isSubscribed == nil {
            
            button.setTitle("SUBSCRIBE", for: .normal)
        }
        else if button.buttonObject?.action == "manageSubscription" && self.userDetails?.isSubscribed != nil {
            
            if (self.userDetails?.isSubscribed)! {
                
                button.setTitle("MANAGE", for: .normal)
            }
            else {
                
                button.setTitle("SUBSCRIBE", for: .normal)
            }
        }
    }
    
    //MARK: Button Delegate Events
    func buttonClicked(button: SFButton) {
        if (self.userDetailViewDelegate != nil) && (self.userDetailViewDelegate?.responds(to: #selector(self.userDetailViewDelegate?.buttonTapped(sender:))))!
        {
            self.userDetailViewDelegate?.buttonTapped!(sender: button)
        }
    }
    
    func toggleValueDidChange(sender: SFToggle) {
        
        if sender.toggleObject?.key == "Manage Autoplay"
        {
            let currentAutoPlayState: Bool? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) as? Bool
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) != nil
            {
                Constants.kSTANDARDUSERDEFAULTS.set(!currentAutoPlayState!, forKey: Constants.kAutoPlay)
            }
            else
            {
                Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kAutoPlay)
            }
        }
        else if sender.toggleObject?.key == "cellularDataToggle"
        {
            let currentCellularDownloadState: Bool? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kCellularDownload) as? Bool
            
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kCellularDownload) != nil
            {
                Constants.kSTANDARDUSERDEFAULTS.set(!currentCellularDownloadState!, forKey: Constants.kCellularDownload)
                let reachability:Reachability = Reachability.forInternetConnection()
                if reachability.currentReachabilityStatus() != NotReachable {
                    if  reachability.currentReachabilityStatus() != ReachableViaWiFi {
                        
                        DownloadManager.sharedInstance.pauseDownloadingObject(isForcePaused: false)
                    }
                }

                
            }
            else
            {
                 Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kCellularDownload)
             }
    }
}

}
