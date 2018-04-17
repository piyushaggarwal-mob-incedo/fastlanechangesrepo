//
//  SettingView_tvOS.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 16/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//


@objc protocol SettingViewDelegate: NSObjectProtocol {
    @objc optional func logoutButtonTapped() -> Void
}


import UIKit

class SettingView_tvOS: UIViewController , SFButtonDelegate {
    
    var userDetails: SFUserDetails?
    var relativeViewFrame:CGRect?
    var modulesArray:Array<AnyObject> = []
    var pageObject: Page?
    private  var acitivityIndicator : UIActivityIndicatorView?
    
    weak var delegate: SettingViewDelegate?
    
    init(frame: CGRect, settingObject: SettingViewObject_tvOS,pageObject: Page) {
        super.init(nibName: nil, bundle: nil)
        self.pageObject = pageObject
        self.relativeViewFrame = frame
        let loginLayout = Utility.fetchSettingsViewLayoutDetails(settingViewObject: settingObject)
        self.view.frame = Utility.initialiseViewLayout(viewLayout: loginLayout, relativeViewFrame: relativeViewFrame!)
        self.modulesArray = settingObject.components
        createView(containerView: self.view, itemIndex: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserDetailModuleContent()
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            fetchSubscriptionDetails()
        }
    }
    
    private func fetchSubscriptionDetails() {
        
        guard let isSubscribed = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool)  else {
            return
        }
        if isSubscribed {
            var apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/pages?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&includeContent=true"
            
            if self.pageObject?.pageId != nil {
                apiEndPoint = "\(apiEndPoint)&pageId=\(self.pageObject?.pageId ?? "")"
            }
            
            DataManger.sharedInstance.apiToGetUserSubscriptionStatus(success: { [weak self] (userSubscriptionStatus, isSuccess) in
                
                guard let checkedSelf = self else {
                    return
                }
                
                if checkedSelf.userDetails == nil {
                    checkedSelf.userDetails = SFUserDetails()
                }
                
                if userSubscriptionStatus != nil {
                    
                    if isSuccess {
                        if isSubscribed {
                            
                            let paymentPlatform:String? = userSubscriptionStatus?["platform"] as? String ?? ""
                            let planId:String? = userSubscriptionStatus?["name"] as? String ?? "-"
                            checkedSelf.userDetails?.paymentProcessor = paymentPlatform
                            checkedSelf.userDetails?.subscriptionPlan = planId
                            checkedSelf.userDetails?.isSubscribed = true
                            checkedSelf.userDetails?.paymentMethod =  userSubscriptionStatus?["paymentHandlerDisplayName"] as? String ?? ""
                        }
                        else {
                            checkedSelf.userDetails?.subscriptionPlan = "Not Subscribed"
                        }
                        checkedSelf.updateViewAfterSubscriptionCheck()
                    }
                }
                else {
                    checkedSelf.userDetails?.subscriptionPlan = "Failed to fetch status"
                    checkedSelf.updateViewAfterSubscriptionCheck()
                }
            })
        } else {
            if let label = self.getTheSubscriptionLabel() {
                label.text = "Not Subscribed"
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Creation of View Components
    func createView(containerView: UIView, itemIndex:Int) {
        
        for component:AnyObject in self.modulesArray {
            if component is SFButtonObject {
                let buttonObject:SFButtonObject = component as! SFButtonObject
                createButtonView(buttonObject: buttonObject, containerView: self.view, itemIndex: itemIndex, type: component.key!!)
            }
            else if component is SFSeparatorViewObject {
                createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
            }
            else if component is SFLabelObject {
                createLabelView(labelObject: component as! SFLabelObject)
            }
            else if component is SFSwitchViewObject {
                createSwitchView(viewObject: component as! SFSwitchViewObject)
            }
        }
    }
    
    private func createSwitchView(viewObject: SFSwitchViewObject) {

        let viewLayout = Utility.fetchSwitchViewLayoutDetails(switchViewObject: viewObject)
        let switchView = SFSwitchView_tvOS.getloadedViewFromNib()
        switchView.viewLayout = viewLayout
        switchView.relativeViewFrame = self.view.frame
        switchView.viewObject = viewObject
        switchView.initialiseViewFromLayout(viewLayout: viewLayout)
        
        if switchView.viewObject?.key == "autoPlaySwitch" {
            if let autoPlay = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) as? Bool {
                switchView.enabled = autoPlay
            } else {
                switchView.enabled = false
            }
        }
        if switchView.viewObject?.key == "closedCaptionSwitch" {
            if let ccEnabled = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsCCEnabled) as? Bool {
                switchView.enabled = ccEnabled
            } else {
                switchView.enabled = false
            }
        }
        
        switchView.valueUpdatedHandler = { (state,viewObject) in
            if viewObject.key == "autoPlaySwitch" {
                Constants.kSTANDARDUSERDEFAULTS.set(state, forKey: Constants.kAutoPlay)
            }
            if viewObject.key == "closedCaptionSwitch" {
                Constants.kSTANDARDUSERDEFAULTS.set(state, forKey: Constants.kIsCCEnabled)
            }
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
        }
        self.view.addSubview(switchView)
    }
    
    //method to create separator view
    private func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        let separatorView:SFSeparatorView = SFSeparatorView(frame: CGRect.zero)
        separatorView.separtorViewObject = separatorViewObject
        separatorView.relativeViewFrame = relativeViewFrame!
        self.view.addSubview(separatorView)
        updateSeparatorView(separatorView: separatorView)
        
        separatorView.isHidden = false
    }
    
    
    private func createLabelView(labelObject:SFLabelObject){
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = self.view.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        self.view.addSubview(label)
        self.view.bringSubview(toFront: label)
        label.createLabelView()
        
        if labelObject.key == "userEmailIdLabel"{
               label.isHidden = true
        } else {
            label.text = labelObject.text
        }
        
        if labelObject.key == "title"{
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor!)
        } else {
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
        
        if AppConfiguration.sharedAppConfiguration.serviceType != serviceType.SVOD {
            if labelObject.key == "subscriptionLabel" || labelObject.key == "subscriptionDurationLabel" {
                label.isHidden = true
            }
        }
    }
    
    private func getTheSubscriptionLabel() -> SFLabel? {
        var subscriptionLabel: SFLabel?
        for view in self.view.subviews {
            if view is SFLabel {
                let labelView = view as! SFLabel
                if labelView.labelObject?.key == "subscriptionDurationLabel" {
                    subscriptionLabel = labelView
                    break
                }
            }
        }
        return subscriptionLabel
    }
    
    private func getTheUserEmailIdLabel() -> SFLabel? {
        var emailIdLabel: SFLabel?
        for view in self.view.subviews {
            if view is SFLabel {
                let labelView = view as! SFLabel
                if labelView.labelObject?.key == "userEmailIdLabel" {
                    emailIdLabel = labelView
                    break
                }
            }
        }
        return emailIdLabel
    }
    
    
    private func getCreateAccountButton() -> SFButton? {
        var subscriptionButton: SFButton?
        for view in self.view.subviews {
            if view is SFButton {
                let button = view as! SFButton
                if button.buttonObject?.key == "createAccountButton" {
                    subscriptionButton = button
                    break
                }
            }
        }
        return subscriptionButton
    }
    
    private func getTheSubscriptionButton() -> SFButton? {
        var subscriptionButton: SFButton?
        for view in self.view.subviews {
            if view is SFButton {
                let button = view as! SFButton
                if button.buttonObject?.key == "manageSubscriptionButton" {
                    subscriptionButton = button
                    break
                }
            }
        }
        return subscriptionButton
    }
    
    
    private func getTheLogoutButton() -> SFButton? {
        var logoutButton: SFButton?
        for view in self.view.subviews {
            if view is SFButton {
                let button = view as! SFButton
                if button.buttonObject?.key == "logoutButton" {
                    logoutButton = button
                    break
                }
            }
        }
        return logoutButton
    }
    
    
    private func updateViewAfterSubscriptionCheck() {
        DispatchQueue.main.async {
            if let label = self.getTheSubscriptionLabel() {
                label.text = self.userDetails?.subscriptionPlan!
            }
            if let button = self.getTheSubscriptionButton() {
                if let _ = self.userDetails?.subscriptionPlan {
                    button.isHidden = false
                } else {
                    button.isHidden = true
                }
            }
            if let button = self.getCreateAccountButton() {
                if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                    if Utility.sharedUtility.checkIfUserIsSubscribedGuest() == true {
                        button.isHidden = false
                    } else {
                        button.isHidden = true
                    }
                } else {
                    button.isHidden = true
                }
            }
            if let button = self.getTheLogoutButton() {
                if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                    if Utility.sharedUtility.checkIfUserIsSubscribedGuest() == true {
                        button.isHidden = true
                    } else {
                        button.isHidden = false
                    }
                } else {
                    button.isHidden = false
                }
            }
        }
    }
    
    func fetchUserDetailModuleContent() {
        
        let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/user?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        self.addActivityIndicator()
        DispatchQueue.global(qos: .userInitiated).async {
            DataManger.sharedInstance.fetchUserPageDetails(apiEndPoint: apiRequest) {  [weak self] (userResult, isSuccess) in
                guard let checkedSelf = self else {
                    return
                }
                checkedSelf.removeActivityIndicator()
                if userResult != nil && isSuccess {
                    if let label = checkedSelf.getTheUserEmailIdLabel() {
                        if let emailId = userResult?.emailID{
                            label.isHidden = false
                            label.text = "Logged in as"+" \(emailId)"
                        }
                        else{
                            label.isHidden = true
                        }
                    }
                }
            }
        }
    }

    
    
    //method to update separator view frames
    private func updateSeparatorView(separatorView:SFSeparatorView) {
        
        separatorView.relativeViewFrame = relativeViewFrame!
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorView.separtorViewObject!))
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
        
        if buttonObject.key == "manageSubscriptionButton" {
            if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                if let isSubscribed = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool) {
                    button.isSelected = !isSubscribed
                }
            } else {
                button.isHidden = true
            }
            
        } else if buttonObject.key == "createAccountButton" {
            if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                if Utility.sharedUtility.checkIfUserIsSubscribedGuest() == true {
                    button.isHidden = false
                } else {
                    button.isHidden = true
                }
            } else {
                button.isHidden = true
            }
        } else if buttonObject.key == "logoutButton" {
            if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                if Utility.sharedUtility.checkIfUserIsSubscribedGuest() == true {
                    button.isHidden = true
                } else {
                    button.isHidden = false
                }
            } else {
                button.isHidden = false
            }
        }
        containerView.addSubview(button)
        containerView.bringSubview(toFront: button)
    }
    
    //MARK: - Activity Indicator Methods
    func addActivityIndicator(){
        if acitivityIndicator == nil {
            self.acitivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        }
        self.acitivityIndicator?.showIndicatorOnWindow()
    }
    
    func removeActivityIndicator(){
        if let tempActivityIndicatorView = self.acitivityIndicator
        {
            tempActivityIndicatorView.removeFromSuperview()
            tempActivityIndicatorView.stopAnimating();
        }
    }
    

    //MARK: - Button Delegate
    func buttonClicked(button: SFButton) {
        if button.buttonObject?.action == "logout"{
            if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.logoutButtonTapped)))!
            {
                self.delegate?.logoutButtonTapped!()
            }
        } else if button.buttonObject?.action == "manageSubcription" {
            if let isSubscribed = userDetails?.isSubscribed {
                if isSubscribed == true {
                    if let paymentProcessor = userDetails?.paymentProcessor {
                        // Show Alert
                        showManageSubscriptionAlertWith(subscriptionPlatform: paymentProcessor)
                    }
                } else {
                    Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView(contentToLoad: .loadPlansPage,{ [weak self] () in
                        guard let checkedSelf = self else {return}
                        checkedSelf.fetchSubscriptionDetails()
                    })
                }
            } else {
                if let _ = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool) {
                    // Show Alert
                    showManageSubscriptionAlertWith(subscriptionPlatform: "ios_apple_tv")
                } else {
                    if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                        Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView(contentToLoad: .loadPlansPage,{ [weak self] () in
                            guard let checkedSelf = self else {return}
                            checkedSelf.fetchSubscriptionDetails()
                        })
                    }
                }
            }
        } else if button.buttonObject?.action == "createAccount" {
            if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView(contentToLoad: .loadSignUpPage,{ [weak self] () in
                    guard let checkedSelf = self else {return}
                    checkedSelf.updateViewAfterSubscriptionCheck()
                })
            }
        }
    }
    
    func showManageSubscriptionAlertWith(subscriptionPlatform: String) -> Void
    {
        let alertTitleString: String = Constants.kManageSubscription
        let alertController: UIAlertController?
        let okAction: UIAlertAction = UIAlertAction.init(title: Constants.kStrOk, style: .default) { (UIAlertAction) in /*Do nothing*/}
        
        if subscriptionPlatform.lowercased() == "ios" || subscriptionPlatform.lowercased() == "ios_phone" || subscriptionPlatform.lowercased() == "ios_ipad" || subscriptionPlatform.lowercased() == "ios_apple_tv" || subscriptionPlatform.lowercased() == "ios_apple_watch" || subscriptionPlatform.lowercased() == "ios_iphone" {
            alertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString, alertMessage: "In order to Manage your subscriptions you need to go to Settings > Accounts > Manage Subscriptions", alertActions: [okAction])
        }
        else {
            let msgString: String = Utility.getPlatformNameFromPaymentProcessorString(subscriptionPlatform)
            alertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString, alertMessage: "This is \(getCorrectArticleTPrecedeTheWordFor(wordThatFollows: msgString)) \(msgString) subscription. Management is only possible with the device used for purchase.", alertActions: [okAction])
        }
        self.present(alertController!, animated: true)
    }
    
    func getCorrectArticleTPrecedeTheWordFor(wordThatFollows: String) -> String
    {
        var stringToReturn: String = "a"
        if wordThatFollows.characters.count > 0
        {
            let index = wordThatFollows.index(wordThatFollows.startIndex, offsetBy: 1)
            var firstLetter: String = wordThatFollows.substring(to: index)
            firstLetter = firstLetter.lowercased()
            let vowels: Array = ["a", "e", "i", "o", "u"]
            if vowels.contains(firstLetter)
            {
                stringToReturn = "an"
            }
        }
        return stringToReturn
    }

}
