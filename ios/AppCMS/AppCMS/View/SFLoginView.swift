//
//  SFLoginView.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 23/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import AppsFlyerLib
import AdSupport
import Firebase

@objc protocol LoginViewDelegate: NSObjectProtocol {
    @objc optional func userLoginDone() -> Void
    @objc optional func segmentSelectionChanged() -> Void
    @objc optional func forgotPasswordTapped() -> Void
    @objc optional func resetPasswordTapped() -> Void
    @objc optional func privacyPolicyTapped() -> Void
    @objc optional func termsOfUseTapped() -> Void

}

let resetPasswordMessage: String = "Follow the instructions in the email we just sent you to reset your password."
class SFLoginView: UIView, SFButtonDelegate, SFSegmentViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, dropDownProtocol, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var loginViewDelegate: LoginViewDelegate?
    var loginComponentObject: LoginComponent!
    var viewTag: Int?
    var progressIndicator:MBProgressHUD?
    var paymentModelObject:PaymentModel?
    var signUpCompletionHandlerCopy : ((Bool) -> Void)? = nil
    var fbSignUpCompletionHandlerCopy : ((Bool) -> Void)? = nil
    var googleSignUpCompletionHandlerCopy : ((Bool) -> Void)? = nil
    var countryPicker: UIPickerView!
    var selectedCountry: SFCountryDialModel!
    private var subscriptionReceiptData:NSData?
    private var emailId:String?, productIdentifier:String?, transactionIdentifier:String?
    
    init(frame: CGRect, loginObject: LoginComponent, viewTag: Int) {
        super.init(frame: frame)
        self.loginComponentObject = loginObject
        self.viewTag = viewTag
        countryPicker = UIPickerView()
        countryPicker.dataSource = self
        countryPicker.delegate = self
        
        createView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createView() -> Void {
        createLoginView(containerView: self, itemIndex: 0)
    }
    
    
    func updateView() -> Void
    {
        for component: AnyObject in self.subviews {
            
            if component is SFButton {
                
                updateButtonViewFrame(button: component as! SFButton, containerView: self)
            }
            else if component is SFLabel {
                
                updateLabelViewFrame(label: component as! SFLabel, containerView: self)
            }
            else if component is SFTextField {
                
                updateTextFieldFrame(textField: component as! SFTextField, containerView: self)
            }
            else if component is SFDropDown
            {
                updateDropDownFrame(dropDown: component as! SFDropDown, containerView: self)
            }
            else if component is SFSeparatorView
            {
                updateSeparatorViewFrame(separatorView: component as! SFSeparatorView, containerView: self)
            }
            else if component is SFSegmentView
            {
                updateSegmentViewFrame(segmentView: component as! SFSegmentView, containerView: self)
            }
        }
    }
    
    
    //MARK: Creation of View Components
    func createLoginView(containerView: UIView, itemIndex:Int) {
        
        for component:AnyObject in self.loginComponentObject.components {
            
            if component is SFButtonObject {
                
                let buttonObject:SFButtonObject = component as! SFButtonObject
                
                    createButtonView(buttonObject: buttonObject, containerView: self, itemIndex: itemIndex, type: component.key!!)
            }
            else if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject, containerView: containerView, type: component.key!!)
            }
            else if component is SFTextFieldObject
            {
                createTextField(textFieldObject: component as! SFTextFieldObject, containerView: containerView, itemIndex: 0)
            }
            else if component is SFDropDownObject
            {
                createDropDown(dropDownObject: component as! SFDropDownObject, containerView: containerView, itemIndex: 0)
            }
            else if component is SFSeparatorViewObject
            {
                createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
            }
            else if component is SFSegmentObject
            {
                if (AppConfiguration.sharedAppConfiguration.serviceType == serviceType.AVOD) && component.value == "AVOD"
                {
                    createSegmentedView(segmentViewObject: component as! SFSegmentObject)
                }
                else if (AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD) && component.value == "SVOD"
                {
                    createSegmentedView(segmentViewObject: component as! SFSegmentObject)
                }
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

        label.changeFrameXAxis(xAxis: label.frame.minX * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameYAxis(yAxis: getPosition(position: label.frame.minY) * Utility.getBaseScreenHeightMultiplier())
        label.changeFrameWidth(width: label.frame.width * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameHeight(height: label.frame.height * Utility.getBaseScreenHeightMultiplier())
        label.font = UIFont(name: label.font.fontName, size: label.font.pointSize * Utility.getBaseScreenHeightMultiplier())
        label.text = labelObject.text
        containerView.addSubview(label)
        containerView.bringSubview(toFront: label)
        
        if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
            
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
        }
        
        if labelObject.action != nil
        {
            if labelObject.action == "privacyPolicy"
            {
                let selectorTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyHandler(tapGesture:)))
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(selectorTapGesture)
            }
            else if labelObject.action == "termsOfUse"
            {
                let selectorTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touHandler(tapGesture:)))
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(selectorTapGesture)
            }
            if AppConfiguration.sharedAppConfiguration.linkColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.linkColor!)
            }
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
        
        button.changeFrameXAxis(xAxis: button.frame.minX * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameYAxis(yAxis: getPosition(position: button.frame.minY) * Utility.getBaseScreenHeightMultiplier())
        button.changeFrameWidth(width: button.frame.width * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameHeight(height: button.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!, size: (button.titleLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
        
        containerView.addSubview(button)
        containerView.bringSubview(toFront: button)
        
        if buttonObject.key == "login button" || buttonObject.key == "signup button" || buttonObject.key == "reset password button" || buttonObject.key == "create login button" {
            
            button.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000")
            button.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor ?? AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        }
        
        if buttonObject.key == "login google button" || buttonObject.key == "signup google button" || buttonObject.key == "create login google button"{
            
            if AppConfiguration.sharedAppConfiguration.isGoogleSignEnabled {
                
                button.isHidden = false
                button.isEnabled = true
            }
            else {
                
                button.isHidden = true
                button.isEnabled = false
            }
        }
    }
    
    func createTextField(textFieldObject:SFTextFieldObject, containerView:UIView, itemIndex:Int) -> Void {
        
        let textFieldLayout = Utility.fetchTextFieldLayoutDetails(textFieldObject: textFieldObject)
        let textField:SFTextField = SFTextField()
        textField.relativeViewFrame = self.frame
        textField.delegate = self
        textField.initialiseTextViewFrameFromLayout(textFieldLayout: textFieldLayout)
        textField.textFieldLayout = textFieldLayout
        textField.textFieldObject = textFieldObject
        textField.updateView()
        
        textField.changeFrameXAxis(xAxis: textField.frame.minX * Utility.getBaseScreenWidthMultiplier())
        textField.changeFrameYAxis(yAxis: getPosition(position: textField.frame.minY) * Utility.getBaseScreenHeightMultiplier())
        textField.changeFrameWidth(width: textField.frame.width * Utility.getBaseScreenWidthMultiplier())
        textField.changeFrameHeight(height: textField.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        textField.font = UIFont(name: (textField.font?.fontName)!, size: (textField.font?.pointSize)! * Utility.getBaseScreenHeightMultiplier())
        
        self.addSubview(textField)
    }
    
    func createDropDown(dropDownObject:SFDropDownObject, containerView:UIView, itemIndex:Int) -> Void {
        
        let dropDownLayout = Utility.fetchDropDownLayoutDetails(dropDownObject: dropDownObject)
        let dropDown:SFDropDown = SFDropDown()
        dropDown.relativeViewFrame = self.frame
        dropDown.dropDownDelegate = self
        dropDown.initialiseDropDownFrameFromLayout(dropDownLayout: dropDownLayout)
        dropDown.dropDownLayout = dropDownLayout
        dropDown.dropDownObject = dropDownObject
        dropDown.updateView()
        
        dropDown.changeFrameXAxis(xAxis: dropDown.frame.minX * Utility.getBaseScreenWidthMultiplier())
        dropDown.changeFrameYAxis(yAxis: getPosition(position: dropDown.frame.minY) * Utility.getBaseScreenHeightMultiplier())
        dropDown.changeFrameWidth(width: dropDown.frame.width * Utility.getBaseScreenWidthMultiplier())
        dropDown.changeFrameHeight(height: dropDown.frame.height * Utility.getBaseScreenHeightMultiplier())
        dropDown.inputView = countryPicker
        
        dropDown.font = UIFont(name: (dropDown.font?.fontName)!, size: (dropDown.font?.pointSize)! * Utility.getBaseScreenHeightMultiplier())
        
        self.addSubview(dropDown)
    }
    
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        let separatorViewLayout = Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject)
        let separatorView: SFSeparatorView = SFSeparatorView()
        separatorView.separtorViewObject = separatorViewObject
        separatorView.isHidden = false
        separatorView.relativeViewFrame = self.frame
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: separatorViewLayout)
        separatorView.changeFrameXAxis(xAxis: separatorView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        separatorView.changeFrameYAxis(yAxis: getPosition(position: separatorView.frame.minY) * Utility.getBaseScreenHeightMultiplier())
        separatorView.changeFrameWidth(width: separatorView.frame.width * Utility.getBaseScreenWidthMultiplier())
        separatorView.changeFrameHeight(height: separatorView.frame.height * Utility.getBaseScreenHeightMultiplier())

        self.addSubview(separatorView)
    }
    
    func createSegmentedView(segmentViewObject:SFSegmentObject) {
        let segmentView: SFSegmentView = SFSegmentView.init(segmentComponentObject: segmentViewObject)
        segmentView.isHidden = false
        segmentView.changeFrameXAxis(xAxis: segmentView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        segmentView.changeFrameYAxis(yAxis: getPosition(position: segmentView.frame.minY) * Utility.getBaseScreenHeightMultiplier())
        segmentView.changeFrameWidth(width: segmentView.frame.width * Utility.getBaseScreenWidthMultiplier())
        segmentView.changeFrameHeight(height: segmentView.frame.height * Utility.getBaseScreenHeightMultiplier())
        segmentView.segmentDelegate = self
        self.addSubview(segmentView)
    }
    
    
    //MARK: Update Video Description Subviews
    func updateLabelViewFrame(label:SFLabel, containerView:UIView) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!)
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.changeFrameXAxis(xAxis: label.frame.minX * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameYAxis(yAxis: getPosition(position: label.frame.minY) * Utility.getBaseScreenHeightMultiplier())
        label.changeFrameWidth(width: label.frame.width * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameHeight(height: label.frame.height * Utility.getBaseScreenHeightMultiplier())
    }
    
    func updateButtonViewFrame(button:SFButton, containerView:UIView) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: button.buttonObject!)
        
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        
        button.changeFrameXAxis(xAxis: button.frame.minX * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameYAxis(yAxis: getPosition(position: button.frame.minY) * Utility.getBaseScreenHeightMultiplier())
        button.changeFrameWidth(width: button.frame.width * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameHeight(height: button.frame.height * Utility.getBaseScreenHeightMultiplier())
    }
    
    func updateTextFieldFrame(textField:SFTextField, containerView:UIView) -> Void {
        
        let textFieldLayout = Utility.fetchTextFieldLayoutDetails(textFieldObject: textField.textFieldObject!)
        textField.relativeViewFrame = containerView.frame
        textField.initialiseTextViewFrameFromLayout(textFieldLayout: textFieldLayout)
        textField.textFieldLayout = textFieldLayout
        
        textField.changeFrameXAxis(xAxis: textField.frame.minX * Utility.getBaseScreenWidthMultiplier())
        textField.changeFrameYAxis(yAxis: getPosition(position: textField.frame.minY) * Utility.getBaseScreenHeightMultiplier())
        textField.changeFrameWidth(width: textField.frame.width * Utility.getBaseScreenWidthMultiplier())
        textField.changeFrameHeight(height: textField.frame.height * Utility.getBaseScreenHeightMultiplier())
    }
    
    func updateDropDownFrame(dropDown:SFDropDown, containerView:UIView) -> Void {
        
        let dropDownLayout = Utility.fetchDropDownLayoutDetails(dropDownObject: dropDown.dropDownObject!)
        dropDown.relativeViewFrame = containerView.frame
        dropDown.initialiseDropDownFrameFromLayout(dropDownLayout: dropDownLayout)
        dropDown.dropDownLayout = dropDownLayout
        
        dropDown.changeFrameXAxis(xAxis: dropDown.frame.minX * Utility.getBaseScreenWidthMultiplier())
        dropDown.changeFrameYAxis(yAxis: getPosition(position: dropDown.frame.minY) * Utility.getBaseScreenHeightMultiplier())
        dropDown.changeFrameWidth(width: dropDown.frame.width * Utility.getBaseScreenWidthMultiplier())
        dropDown.changeFrameHeight(height: dropDown.frame.height * Utility.getBaseScreenHeightMultiplier())
    }
    
    func updateSeparatorViewFrame(separatorView: SFSeparatorView, containerView: UIView) -> Void {
        let separatorViewLayout = Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorView.separtorViewObject!)
        separatorView.relativeViewFrame = containerView.frame
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: separatorViewLayout)
        
        separatorView.changeFrameXAxis(xAxis: separatorView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        separatorView.changeFrameYAxis(yAxis: getPosition(position: separatorView.frame.minY) * Utility.getBaseScreenHeightMultiplier())
        separatorView.changeFrameWidth(width: separatorView.frame.width * Utility.getBaseScreenWidthMultiplier())
        separatorView.changeFrameHeight(height: separatorView.frame.height * Utility.getBaseScreenHeightMultiplier())
    }
    
    func updateSegmentViewFrame(segmentView: SFSegmentView, containerView: UIView) -> Void {
        let segmentViewLayout = Utility.fetchSegmentViewLayoutDetails(segmentViewObject: segmentView.segmentObject!)
        segmentView.initialiseSegmentFrameFromLayout(segmentViewLayout: segmentViewLayout, relativeViewFrame: self.frame)
        
        segmentView.changeFrameXAxis(xAxis: segmentView.frame.minX * Utility.getBaseScreenHeightMultiplier())
        segmentView.changeFrameYAxis(yAxis: getPosition(position: segmentView.frame.minY) * Utility.getBaseScreenHeightMultiplier())
        segmentView.changeFrameWidth(width: segmentView.frame.width * Utility.getBaseScreenHeightMultiplier())
        segmentView.changeFrameHeight(height: segmentView.frame.height * Utility.getBaseScreenHeightMultiplier())
        segmentView.updateSegmentView()
    }
    
    
    //MARK: LABEL ACTION TAP HANDLER
    func privacyPolicyHandler(tapGesture: UITapGestureRecognizer) -> Void
    {
        if (self.loginViewDelegate != nil) && (self.loginViewDelegate?.responds(to: #selector(self.loginViewDelegate?.privacyPolicyTapped)))!
        {
            self.loginViewDelegate?.privacyPolicyTapped!()
        }
    }
    
    func touHandler(tapGesture: UITapGestureRecognizer) -> Void
    {
        if (self.loginViewDelegate != nil) && (self.loginViewDelegate?.responds(to: #selector(self.loginViewDelegate?.termsOfUseTapped)))!
        {
            self.loginViewDelegate?.termsOfUseTapped!()
        }
    }
    
    
    //MARK: Button Delegate Events
    func buttonClicked(button: SFButton) {
        
        if button.buttonObject?.action == "login"
        {
            logIn(loginDone: { (loginStatus: Bool) in
                if loginStatus == true
                {
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                    {
                        FIRAnalytics.logEvent(withName: Constants.kGTMLoginEvent, parameters: [Constants.kGTMLoginMethodAttribute : Constants.kGTMEmailLoginMethod])
                    }
                    if (self.loginViewDelegate != nil) && (self.loginViewDelegate?.responds(to: #selector(self.loginViewDelegate?.userLoginDone)))!
                    {
                        self.loginViewDelegate?.userLoginDone!()
                    }
                }
            })
        }
        else if button.buttonObject?.action == "forgotPassword"
        {
            if (self.loginViewDelegate != nil) && (self.loginViewDelegate?.responds(to: #selector(self.loginViewDelegate?.forgotPasswordTapped)))!
            {
                self.loginViewDelegate?.forgotPasswordTapped!()
            }
        }
        else if button.buttonObject?.action == "loginFacebook"
        {
            fbLogin(shouldUpdateSubscriptionStatus:false, isUserSignIn: true, fbLoginDone: { (fbSignInDone: Bool) in
                if fbSignInDone == true
                {
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                    {
                        FIRAnalytics.logEvent(withName: Constants.kGTMLoginEvent, parameters: [Constants.kGTMLoginMethodAttribute : Constants.kGTMFacebookLoginMethod])
                    }
                    if (self.loginViewDelegate != nil) && (self.loginViewDelegate?.responds(to: #selector(self.loginViewDelegate?.userLoginDone)))!
                    {
                        self.loginViewDelegate?.userLoginDone!()
                    }
                }
            })
        }
        else if button.buttonObject?.action == "signup" || button.buttonObject?.action == "createLogin"
        {
            signUp(signUpDone: { (signUpStatus: Bool) in
                if signUpStatus == true
                {
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                    {
                        FIRAnalytics.logEvent(withName: Constants.kGTMSignUpEvent, parameters: [Constants.kGTMSignUpMethodAttribute : Constants.kGTMEmailLoginMethod])
                    }
                    if (self.loginViewDelegate != nil) && (self.loginViewDelegate?.responds(to: #selector(self.loginViewDelegate?.userLoginDone)))!
                    {
                        self.loginViewDelegate?.userLoginDone!()
                    }
                }
            })
        }
        else if button.buttonObject?.action == "signupfacebook" || button.buttonObject?.action == "createLoginfacebook"
        {
            fbLogin(shouldUpdateSubscriptionStatus:true, isUserSignIn: false, fbLoginDone: { (fbSignInDone: Bool) in
                if fbSignInDone == true
                {
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                    {
                        FIRAnalytics.logEvent(withName: Constants.kGTMSignUpEvent, parameters: [Constants.kGTMSignUpMethodAttribute : Constants.kGTMFacebookLoginMethod])
                    }
                    if (self.loginViewDelegate != nil) && (self.loginViewDelegate?.responds(to: #selector(self.loginViewDelegate?.userLoginDone)))!
                    {
                        self.loginViewDelegate?.userLoginDone!()
                    }
                }
            })
        }
        else if button.buttonObject?.action == "resetPassword"
        {
            resetPassword()
//            if (self.loginViewDelegate != nil) && (self.loginViewDelegate?.responds(to: #selector(self.loginViewDelegate?.resetPasswordTapped)))!
//            {
//                self.loginViewDelegate?.resetPasswordTapped!()
//            }
        }
        else if button.buttonObject?.action == "logingoogle" {
            
            googleLogin(shouldUpdateSubscriptionStatus: false, isUserSignIn: true, googleLoginDone: { (googleSignInDone) in
                
                if googleSignInDone
                {
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                    {
                        FIRAnalytics.logEvent(withName: Constants.kGTMLoginEvent, parameters: [Constants.kGTMLoginMethodAttribute : Constants.kGTMGmailLoginMethod])
                    }
                    
                    if (self.loginViewDelegate != nil) && (self.loginViewDelegate?.responds(to: #selector(self.loginViewDelegate?.userLoginDone)))!
                    {
                        self.loginViewDelegate?.userLoginDone!()
                    }
                }
            })
        }
        else if button.buttonObject?.action == "signupgoogle" || button.buttonObject?.action == "createLogingoogle"
        {
            googleLogin(shouldUpdateSubscriptionStatus: true, isUserSignIn: false, googleLoginDone: { (googleSignInDone) in
                
                if googleSignInDone {
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                    {
                        FIRAnalytics.logEvent(withName: Constants.kGTMSignUpEvent, parameters: [Constants.kGTMSignUpMethodAttribute : Constants.kGTMGmailLoginMethod])
                    }
                    if (self.loginViewDelegate != nil) && (self.loginViewDelegate?.responds(to: #selector(self.loginViewDelegate?.userLoginDone)))!
                    {
                        self.loginViewDelegate?.userLoginDone!()
                    }
                }
            })
        }
    }
    
    func segmentSelectionChangedWith(selectedSection: Int) -> Void
    {
        if (self.loginViewDelegate != nil) && (self.loginViewDelegate?.responds(to: #selector(self.loginViewDelegate?.segmentSelectionChanged)))!
        {
            self.loginViewDelegate?.segmentSelectionChanged!()
        }
    }
    
    
    //MARK: Google Sign In/Sign up method
    func googleLogin(shouldUpdateSubscriptionStatus:Bool, isUserSignIn:Bool, googleLoginDone: @escaping ((_ loginStatus: Bool) -> Void)) -> Void {
        
        GoogleManager.sharedInstance.loginWithGoogle(googleLoginDone: { (loginDone, googleToken, name, email, googleId) in
            
            if loginDone {
                
                var googleUserDetailDict = ["googleToken": googleToken!]
                
                self.showActivityIndicator(loaderText: nil)
                
                if Utility.sharedUtility.checkIfUserIsSubscribedGuest() && AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && shouldUpdateSubscriptionStatus {
                    
                    if DataManger.sharedInstance.checkIfAuthroizationTokenIsExpired() {
                        
                        DataManger.sharedInstance.apiToGetUpdatedAuthorizationToken(success: { (authenticationResponse, isSuccess) in
                            
                            if authenticationResponse != nil && isSuccess == true {
                                
                                if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) != nil {
                                    
                                    googleUserDetailDict["accessToken"] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken)! as? String
                                    
                                    self.net_googleLogin(shouldUpdateSubscriptionStatus: shouldUpdateSubscriptionStatus, isUserSignIn: isUserSignIn, email: email, googleUserDetailDict: googleUserDetailDict, googleLoginDone: googleLoginDone)
                                }
                                else {
                                    
                                    GIDSignIn.sharedInstance().disconnect()
                                    self.hideActivityIndicator()
                                    googleLoginDone(false)
                                }
                            }
                            else {
                                
                                GIDSignIn.sharedInstance().disconnect()
                                self.hideActivityIndicator()
                                googleLoginDone(false)
                            }
                        })
                    }
                    else {
                        
                        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) != nil {
                            
                            googleUserDetailDict["accessToken"] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken)! as? String
                            self.net_googleLogin(shouldUpdateSubscriptionStatus: shouldUpdateSubscriptionStatus, isUserSignIn: isUserSignIn, email: email, googleUserDetailDict: googleUserDetailDict, googleLoginDone: googleLoginDone)
                        }
                        else {
                            
                            GIDSignIn.sharedInstance().disconnect()
                            self.hideActivityIndicator()
                            googleLoginDone(false)
                        }
                    }
                }
                else {
                    
                    self.net_googleLogin(shouldUpdateSubscriptionStatus: shouldUpdateSubscriptionStatus, isUserSignIn: isUserSignIn, email: email, googleUserDetailDict: googleUserDetailDict, googleLoginDone: googleLoginDone)
                }
            }
            else {
                
                googleLoginDone(false)
            }
            
        }, viewController: self.loginViewDelegate as! UIViewController)
        
    }
    
    
    func net_googleLogin(shouldUpdateSubscriptionStatus:Bool, isUserSignIn:Bool, email:String?, googleUserDetailDict: Dictionary<String, Any>, googleLoginDone: @escaping ((_ loginStatus: Bool) -> Void)) -> Void {
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/signin/google?device=ios_phone&site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        DataManger.sharedInstance.userSignInFromFacebook(apiEndPoint: apiEndPoint, requestType: .post, requestParameters: googleUserDetailDict, success: { (userResponse, isSuccess) in
            
            GIDSignIn.sharedInstance().disconnect()

            if userResponse != nil {
                
                if isSuccess {
                    
                    let refreshToken:String? = userResponse?["refreshToken"] as? String
                    let authorizationToken: String? = userResponse?["authorizationToken"] as? String
                    let id:String? = userResponse?["userId"] as? String
                    
                    if authorizationToken != nil && refreshToken != nil
                    {
                        Constants.kSTANDARDUSERDEFAULTS.setValue(refreshToken, forKey: Constants.kRefreshToken)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(authorizationToken!, forKey: Constants.kAuthorizationToken)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kAuthorizationTokenTimeStamp)
                    }
                    
                    if id != nil {
                        
                        Constants.kSTANDARDUSERDEFAULTS.setValue(id, forKey: Constants.kUSERID)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                         AppsFlyerTracker.shared().customerUserID = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as? String ?? ""
                    }
                    
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                        
                        FIRAnalytics.setUserID(id)
                        Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMLoggedInPropertyValue, userPropertyKeyName: Constants.kGTMLoggedInProperty)
                    }
             
                    Constants.kAPPDELEGATE.fetchDownloadItemsAndUpdateThePaths()
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    
                    let isUserSubscribed:Bool? = userResponse?["isSubscribed"] as? Bool
                    
                    if isUserSubscribed != nil {
                        
                        Constants.kSTANDARDUSERDEFAULTS.set(isUserSubscribed!, forKey: Constants.kIsSubscribedKey)
                        
                        if isUserSignIn {
                            
                            AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_LOGIN, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "true"])
                        }
                        else {
                            
                            AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_REGISTRATION, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "",Constants.APPSFLYER_KEY_DEVICEID : ASIdentifierManager.shared().advertisingIdentifier.uuidString , Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "true"])
                        }
                    }
                    else
                    {
                        if isUserSignIn {
                            
                            AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_LOGIN, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "false"])
                        }
                        else {
                            
                            AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_REGISTRATION, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "",Constants.APPSFLYER_KEY_DEVICEID : ASIdentifierManager.shared().advertisingIdentifier.uuidString , Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "false"])
                        }
                    }
                    
                    if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) != nil && AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && shouldUpdateSubscriptionStatus {
                        
                        let userInfo:Dictionary<String, Any> = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as! Dictionary<String, Any>
                        
                        self.googleSignUpCompletionHandlerCopy = googleLoginDone
                        
                        if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                            
                            Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Gmail.rawValue, forKey: Constants.kLoginType)
                            Constants.kSTANDARDUSERDEFAULTS.synchronize()
                            self.updateSubscriptionInfoWithReceiptdata(receipt: userInfo["receiptData"] as? NSData, emailId: email, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String)
                        }
                        else {
                            
                            Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Gmail.rawValue, forKey: Constants.kLoginType)
                            Constants.kSTANDARDUSERDEFAULTS.synchronize()
                            self.isUserInteractionEnabled = true
                            self.hideActivityIndicator()
                            self.endEditing(true)
                            self.displayAlertOnSuccess()
                        }
                    }
                    else {
                        
                        Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Gmail.rawValue, forKey: Constants.kLoginType)
                        Constants.kSTANDARDUSERDEFAULTS.synchronize()
                        
                        Constants.kAPPDELEGATE.fetchUserSubscriptionStatusFromServer(shouldUpdateIAPReceipt: false)
                        self.hideActivityIndicator()
                        self.endEditing(true)
                        googleLoginDone(true)
                    }
                }
                else {
                    
                    self.hideActivityIndicator()
                    let errorMessage:String = userResponse?["error"] as? String ?? userResponse?["message"] as? String ?? "Server error"
                    
                    let alertView: UIAlertView = UIAlertView.init(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                    self.endEditing(true)
                    googleLoginDone(false)
                }
            }
            else {
                
                self.hideActivityIndicator()
                let errorMessage:String = userResponse?["error"] as? String ?? "Server error"
                
                let alertView: UIAlertView = UIAlertView.init(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
                self.endEditing(true)
                googleLoginDone(false)
            }
        })
    }


    //MARK: Facebook Sign In/Sign Up method
    func fbLogin(shouldUpdateSubscriptionStatus:Bool, isUserSignIn:Bool,fbLoginDone: @escaping ((_ loginStatus: Bool) -> Void)) -> Void {
        
        FacebookManager.loginWithFacebook(facebookLoginDone: { (loginDone, facebookToken, name, email, facebookID) in
            
            let fbTokenString = "\(facebookToken)"
            let fbIDString = "\(facebookID ?? "")"
            
            var fbUserDetailDict = ["facebookToken": fbTokenString, "userId": fbIDString]
            
            self.showActivityIndicator(loaderText: nil)
            
            if Utility.sharedUtility.checkIfUserIsSubscribedGuest() && AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && shouldUpdateSubscriptionStatus {
                
                if DataManger.sharedInstance.checkIfAuthroizationTokenIsExpired() {
                    
                    DataManger.sharedInstance.apiToGetUpdatedAuthorizationToken(success: { (authenticationResponse, isSuccess) in
                        
                        if authenticationResponse != nil && isSuccess == true {
                            
                            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) != nil {
                                
                                fbUserDetailDict["accessToken"] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken)! as? String
                                
                                self.net_fbLogin(shouldUpdateSubscriptionStatus: shouldUpdateSubscriptionStatus, isUserSignIn: isUserSignIn, email: email, fbUserDetailDict: fbUserDetailDict, fbLoginDone: fbLoginDone)
                            }
                            else {
                                
                                self.hideActivityIndicator()
                                self.endEditing(true)
                                fbLoginDone(false)
                            }
                        }
                        else {
                            
                            self.hideActivityIndicator()
                            self.endEditing(true)
                            fbLoginDone(false)
                        }
                    })
                }
                else {
                    
                    if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) != nil {
                        
                        fbUserDetailDict["accessToken"] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken)! as? String
                        self.net_fbLogin(shouldUpdateSubscriptionStatus: shouldUpdateSubscriptionStatus, isUserSignIn: isUserSignIn, email: email, fbUserDetailDict: fbUserDetailDict, fbLoginDone: fbLoginDone)
                    }
                    else {
                        
                        self.hideActivityIndicator()
                        self.endEditing(true)
                        fbLoginDone(false)
                    }
                }
            }
            else {
                
                self.net_fbLogin(shouldUpdateSubscriptionStatus: shouldUpdateSubscriptionStatus, isUserSignIn: isUserSignIn, email: email, fbUserDetailDict: fbUserDetailDict, fbLoginDone: fbLoginDone)
            }
            
            //fbLoginDone(loginDone)
        }, viewController: self.loginViewDelegate as! UIViewController)
        
    }
    
    
    func net_fbLogin(shouldUpdateSubscriptionStatus:Bool, isUserSignIn:Bool, email:String?, fbUserDetailDict: Dictionary<String, Any>, fbLoginDone: @escaping ((_ loginStatus: Bool) -> Void)) -> Void {
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/signin/facebook?device=ios_phone&site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        DataManger.sharedInstance.userSignInFromFacebook(apiEndPoint: apiEndPoint, requestType: .post, requestParameters: fbUserDetailDict, success: { (userResponse, isSuccess) in
            if userResponse != nil {
                
                if isSuccess {
                    
                    let refreshToken:String? = userResponse?["refreshToken"] as? String
                    let authorizationToken: String? = userResponse?["authorizationToken"] as? String
                    let id:String? = userResponse?["userId"] as? String
                    
                    if authorizationToken != nil && refreshToken != nil
                    {
                        Constants.kSTANDARDUSERDEFAULTS.setValue(refreshToken, forKey: Constants.kRefreshToken)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(authorizationToken!, forKey: Constants.kAuthorizationToken)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kAuthorizationTokenTimeStamp)
                    }
                    
                    if id != nil {
                        
                        Constants.kSTANDARDUSERDEFAULTS.setValue(id, forKey: Constants.kUSERID)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                        AppsFlyerTracker.shared().customerUserID = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as? String ?? ""
                    }
                    
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                        
                        FIRAnalytics.setUserID(id)
                        Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMLoggedInPropertyValue, userPropertyKeyName: Constants.kGTMLoggedInProperty)
                    }
                    
                    Constants.kAPPDELEGATE.fetchDownloadItemsAndUpdateThePaths()
                    let isUserSubscribed:Bool? = userResponse?["isSubscribed"] as? Bool
                    
                    if isUserSubscribed != nil {
                        
                        Constants.kSTANDARDUSERDEFAULTS.set(isUserSubscribed!, forKey: Constants.kIsSubscribedKey)
                        
                        if isUserSignIn {
                            
                            AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_LOGIN, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "true"])
                        }
                        else {
                            
                            AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_REGISTRATION, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "",Constants.APPSFLYER_KEY_DEVICEID : ASIdentifierManager.shared().advertisingIdentifier.uuidString , Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "true"])
                        }
                        
                    }
                    else
                    {
                        if isUserSignIn {
                            
                            AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_LOGIN, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "false"])
                        }
                        else {
                            
                            AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_REGISTRATION, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "",Constants.APPSFLYER_KEY_DEVICEID : ASIdentifierManager.shared().advertisingIdentifier.uuidString , Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "false"])
                        }
                    }
                    
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    
                    if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) != nil && AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && shouldUpdateSubscriptionStatus {
                        
                        let userInfo:Dictionary<String, Any> = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as! Dictionary<String, Any>
                        
                        self.fbSignUpCompletionHandlerCopy = fbLoginDone
                        
                        if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                            
                            Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Facebook.rawValue, forKey: Constants.kLoginType)
                            Constants.kSTANDARDUSERDEFAULTS.synchronize()
                            self.updateSubscriptionInfoWithReceiptdata(receipt: userInfo["receiptData"] as? NSData, emailId: email, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String)
                        }
                        else {
                            
                            Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Facebook.rawValue, forKey: Constants.kLoginType)
                            Constants.kSTANDARDUSERDEFAULTS.synchronize()
                            self.isUserInteractionEnabled = true
                            self.hideActivityIndicator()
                            self.endEditing(true)
                            self.displayAlertOnSuccess()
                        }
                    }
                    else {
                        
                        Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Facebook.rawValue, forKey: Constants.kLoginType)
                        Constants.kSTANDARDUSERDEFAULTS.synchronize()
                        Constants.kAPPDELEGATE.fetchUserSubscriptionStatusFromServer(shouldUpdateIAPReceipt: false)

                        self.hideActivityIndicator()
                        self.endEditing(true)
                        fbLoginDone(true)
                    }
                }
                else {
                    
                    self.hideActivityIndicator()
                    let errorMessage:String = userResponse?["error"] as? String ?? userResponse?["message"] as? String ?? "Server error"
                    
                    let alertView: UIAlertView = UIAlertView.init(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                    self.endEditing(true)
                    fbLoginDone(false)
                }
            }
            else {
                
                self.hideActivityIndicator()
                let errorMessage:String = userResponse?["error"] as? String ?? "Server error"
                
                let alertView: UIAlertView = UIAlertView.init(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
                self.endEditing(true)
                fbLoginDone(false)
            }
        })
    }
    
    
    //MARK: Email Sign Up method
    func signUp(signUpDone: @escaping ((_ loginStatus: Bool) -> Void)) -> Void {
        
        var email: String = ""
        var password: String = ""
        var phone: String = ""
        var country: String = ""
        
        for component: AnyObject in self.subviews {
            
            if component is SFTextField {
                
                if (component as! SFTextField).textFieldObject?.key == "emailTextField"
                {
                    email = (component as! SFTextField).text!
                }
                else if (component as! SFTextField).textFieldObject?.key == "passwordTextField"
                {
                    password = (component as! SFTextField).text!
                }
                else if (component as! SFTextField).textFieldObject?.key == "mobile text field"
                {
                    phone = (component as! SFTextField).text!
                }
            }
            else if component is SFDropDown
            {
                if (component as! SFDropDown).dropDownObject?.key == "dialingCodeField"
                {
                    country = (component as! SFDropDown).text!
                }
            }
        }
        
        if email.characters.count == 0
        {
            let alertView: UIAlertView = UIAlertView.init(title: "Sign Up", message: "Please enter email to continue.", delegate: nil, cancelButtonTitle: Constants.kStrOk)
            alertView.show()
            return
        }
        else if !isValidEmailAddress(emailAddressString: email)
        {
            let alertView: UIAlertView = UIAlertView.init(title: "Sign Up", message: "Please enter a valid email.", delegate: nil, cancelButtonTitle: Constants.kStrOk)
            alertView.show()
            return
        }
        
        
        if password.characters.count == 0
        {
            let alertView: UIAlertView = UIAlertView.init(title: "Sign Up", message: "Please enter password to continue.", delegate: nil, cancelButtonTitle: Constants.kStrOk)
            alertView.show()
            return
        }
        else if Utility.isValidPassword(passwordString: password, emailAddress: email) != nil {
            
            let alertView: UIAlertView = UIAlertView.init(title: "Sign Up", message: Utility.isValidPassword(passwordString: password, emailAddress: email), delegate: nil, cancelButtonTitle: Constants.kStrOk)
            alertView.show()
            return
        }
        
        var userDetailDict:[String: Any] = [:]
        userDetailDict["email"] = email
        userDetailDict["password"] = password
            
        
        if phone.characters.count > 0 {
            if country.characters.count <= 0 || country == "Country"
            {
                let alertView: UIAlertView = UIAlertView.init(title: "Sign Up", message: Constants.kCoutryDialCodeError, delegate: nil, cancelButtonTitle: Constants.kStrOk)
                alertView.show()
                return
            }
            else
            {
                let mobileDict = ["country": self.selectedCountry.countryCode, "number": phone]
                userDetailDict["phone"] = mobileDict
            }
        }
        
        showActivityIndicator(loaderText: nil)
        
        if Utility.sharedUtility.checkIfUserIsSubscribedGuest() && AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            
            if DataManger.sharedInstance.checkIfAuthroizationTokenIsExpired() {
                
                DataManger.sharedInstance.apiToGetUpdatedAuthorizationToken(success: { (authenticationResponse, isSuccess) in
                    
                    if authenticationResponse != nil && isSuccess == true {
                        
                        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) != nil {
                            
                            userDetailDict["accessToken"] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken)! as? String
                            
                            self.net_signUp(email: email, userDetailDict: userDetailDict, signUpDone: signUpDone)
                        }
                        else {
                            
                            self.hideActivityIndicator()
                            self.endEditing(true)
                            signUpDone(false)
                        }
                    }
                    else {
                        
                        self.hideActivityIndicator()
                        self.endEditing(true)
                        signUpDone(false)
                    }
                })
            }
            else {
                
                if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) != nil {
                    
                    userDetailDict["accessToken"] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken)! as? String
                    self.net_signUp(email: email, userDetailDict: userDetailDict, signUpDone: signUpDone)
                }
                else {
                    
                    self.hideActivityIndicator()
                    self.endEditing(true)
                    signUpDone(false)
                }
            }
        }
        else {
            
            self.net_signUp(email: email, userDetailDict: userDetailDict, signUpDone: signUpDone)
        }
    }
    
    
    func net_signUp(email:String?, userDetailDict:Dictionary<String, Any>, signUpDone: @escaping ((_ loginStatus: Bool) -> Void)) -> Void {
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/signup?device=ios_phone&site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        DataManger.sharedInstance.userSignUp(apiEndPoint: apiEndPoint, requestType: .post, requestParameters: userDetailDict, success: { (userResponse, isSuccess) in
            
            if userResponse != nil {
                
                if isSuccess {
                    
                    let refreshToken:String? = userResponse?["refreshToken"] as? String
                    let authorizationToken: String? = userResponse?["authorizationToken"] as? String
                    let id:String? = userResponse?["userId"] as? String
                    
                    if authorizationToken != nil && refreshToken != nil
                    {
                        Constants.kSTANDARDUSERDEFAULTS.setValue(refreshToken, forKey: Constants.kRefreshToken)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(authorizationToken!, forKey: Constants.kAuthorizationToken)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kAuthorizationTokenTimeStamp)
                    }
                    
                    if id != nil {
                        Constants.kSTANDARDUSERDEFAULTS.setValue(id, forKey: Constants.kUSERID)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                         AppsFlyerTracker.shared().customerUserID = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as? String ?? ""
                    }
                    
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                        
                        FIRAnalytics.setUserID(id)
                        Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMLoggedInPropertyValue, userPropertyKeyName: Constants.kGTMLoggedInProperty)
                    }
                    
                    Constants.kAPPDELEGATE.fetchDownloadItemsAndUpdateThePaths()
                    let isUserSubscribed:Bool? = userResponse?["isSubscribed"] as? Bool
                    
                    if isUserSubscribed != nil {
                        
                        Constants.kSTANDARDUSERDEFAULTS.set(isUserSubscribed!, forKey: Constants.kIsSubscribedKey)
                         AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_REGISTRATION, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "",Constants.APPSFLYER_KEY_DEVICEID : ASIdentifierManager.shared().advertisingIdentifier.uuidString , Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "true"])
                    }
                    else
                    {
                         AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_REGISTRATION, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "",Constants.APPSFLYER_KEY_DEVICEID : ASIdentifierManager.shared().advertisingIdentifier.uuidString , Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "false"])
                    }

                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    
                    if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) != nil && AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                        
                        let userInfo:Dictionary<String, Any> = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as! Dictionary<String, Any>
                        
                        self.signUpCompletionHandlerCopy = signUpDone
                        
                        if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                            
                            Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Email.rawValue, forKey: Constants.kLoginType)
                            DownloadManager.sharedInstance.downloadQuality = ""
                            Constants.kSTANDARDUSERDEFAULTS.set(DownloadManager.sharedInstance.downloadQuality, forKey: Constants.kDownloadQualitySelectionkey)
                            Constants.kSTANDARDUSERDEFAULTS.synchronize()
                            self.updateSubscriptionInfoWithReceiptdata(receipt: userInfo["receiptData"] as? NSData, emailId: email, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String)
                        }
                        else {
                            
                            Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Email.rawValue, forKey: Constants.kLoginType)
                            Constants.kSTANDARDUSERDEFAULTS.synchronize()
                            
                            Constants.kAPPDELEGATE.fetchUserSubscriptionStatusFromServer(shouldUpdateIAPReceipt: false)
                            self.isUserInteractionEnabled = true
                            self.hideActivityIndicator()
                            self.endEditing(true)
                            self.displayAlertOnSuccess()
                        }
                    }
                    else {
                        
                        Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Email.rawValue, forKey: Constants.kLoginType)
                        Constants.kSTANDARDUSERDEFAULTS.synchronize()
                        
                        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                            
                            Constants.kAPPDELEGATE.fetchUserSubscriptionStatusFromServer(shouldUpdateIAPReceipt: false)
                        }
                        
                        self.hideActivityIndicator()
                        self.endEditing(true)
                        signUpDone(true)
                    }
                }
                else {
                    
                    self.hideActivityIndicator()
                    let errorMessage:String = userResponse?["error"] as? String ?? userResponse?["message"] as? String ?? "Server error"
                    
                    let alertView: UIAlertView = UIAlertView.init(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                    self.endEditing(true)
                    signUpDone(false)
                }
            }
            else {
                
                self.hideActivityIndicator()
                let errorMessage:String = userResponse?["error"] as? String ?? "Server error"
                
                let alertView: UIAlertView = UIAlertView.init(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
                self.endEditing(true)
                signUpDone(false)
            }
        })
    }
    
    
    //MARK: Email Sign In method
    func logIn(loginDone: @escaping ((_ loginStatus: Bool) -> Void)) -> Void {
        
        var email: String = ""
        var password: String = ""
        
        for component: AnyObject in self.subviews {
            
            if component is SFTextField {
                
                if (component as! SFTextField).textFieldObject?.key == "emailTextField"
                {
                    email = (component as! SFTextField).text!
                }
                else if (component as! SFTextField).textFieldObject?.key == "passwordTextField"
                {
                    password = (component as! SFTextField).text!
                }
            }
        }
        
        if email.characters.count == 0
        {
            let alertView: UIAlertView = UIAlertView.init(title: "Log In", message: "Please enter email to continue.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
        else if !isValidEmailAddress(emailAddressString: email)
        {
            let alertView: UIAlertView = UIAlertView.init(title: "Log In", message: "Please enter a valid email.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
        
        
        if password.characters.count == 0
        {
            let alertView: UIAlertView = UIAlertView.init(title: "Log In", message: "Please enter password to continue.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/signin?device=ios_phone&site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"

        let userDetailDict = ["email":email, "password":password]

        showActivityIndicator(loaderText: nil)
        
        DataManger.sharedInstance.userSignIn(apiEndPoint: apiEndPoint, requestType: .get, requestParameters: userDetailDict, success: { (userResponse, isSuccess) in
            
            if userResponse != nil {
                
                if isSuccess {
                    
                    let refreshToken:String? = userResponse?["refreshToken"] as? String
                    let authorizationToken: String? = userResponse?["authorizationToken"] as? String
                    let id:String? = userResponse?["userId"] as? String

                    if authorizationToken != nil && refreshToken != nil
                    {
                        Constants.kSTANDARDUSERDEFAULTS.setValue(refreshToken, forKey: Constants.kRefreshToken)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(authorizationToken!, forKey: Constants.kAuthorizationToken)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Email.rawValue, forKey: Constants.kLoginType)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kAuthorizationTokenTimeStamp)
                    }
                    
                    if id != nil {
                        Constants.kSTANDARDUSERDEFAULTS.setValue(id, forKey: Constants.kUSERID)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                        AppsFlyerTracker.shared().customerUserID = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as? String ?? ""
                        Constants.kAPPDELEGATE.fetchDownloadItemsAndUpdateThePaths()
                    }
                    
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                        
                        FIRAnalytics.setUserID(id)
                        Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMLoggedInPropertyValue, userPropertyKeyName: Constants.kGTMLoggedInProperty)
                    }

                    DispatchQueue.global(qos: .userInitiated).async {
                        DataManger.sharedInstance.apiToGetUserEntitledStatus(success: { (isSubscribed) in
                            DispatchQueue.main.async {
                                if isSubscribed != nil {
                                    if isSubscribed! {
                                        Constants.kSTANDARDUSERDEFAULTS.set(isSubscribed!, forKey: Constants.kIsSubscribedKey)

                                        AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_LOGIN, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "true"])
                                    }
                                    else{
                                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)

                                        AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_LOGIN, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "false"])
                                    }
                                }
                                else{
                                    Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)

                                    AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_LOGIN, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "false"])
                                }
                                Constants.kSTANDARDUSERDEFAULTS.synchronize()
                                Constants.kAPPDELEGATE.fetchUserSubscriptionStatusFromServer(shouldUpdateIAPReceipt: false)
                                self.hideActivityIndicator()
                                self.endEditing(true)
                                loginDone(true)
                            }
                        })
                    }
                }
                else {
                    
                    self.hideActivityIndicator()
                    let errorMessage:String = userResponse?["error"] as? String ?? userResponse?["message"] as? String ?? "Server error"
                    
                    let alertView: UIAlertView = UIAlertView.init(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                    
                    self.endEditing(true)
                    loginDone(false)
                }
            }
            else {
                
                self.hideActivityIndicator()
                let errorMessage:String = userResponse?["error"] as? String ?? "Server error"
                
                let alertView: UIAlertView = UIAlertView.init(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
                
                self.endEditing(true)
                loginDone(false)
            }
        })
    }
    
    
    func resetPassword() -> Void {
        var email: String = ""
        
        for component: AnyObject in self.subviews {
            
            if component is SFTextField {
                
                if (component as! SFTextField).textFieldObject?.key == "emailTextField"
                {
                    email = (component as! SFTextField).text!
                }
            }
        }
        
        if email.characters.count == 0
        {
            let alertView: UIAlertView = UIAlertView.init(title: "Log In", message: "Please enter email to continue.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
        else if !isValidEmailAddress(emailAddressString: email)
        {
            let alertView: UIAlertView = UIAlertView.init(title: "Log In", message: "Please enter a valid email.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/password/forgot?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        let userDetailDict = ["email":email.lowercased()]
        
        showActivityIndicator(loaderText: nil)
        
        DataManger.sharedInstance.userSignIn(apiEndPoint: apiEndPoint, requestType: .get, requestParameters: userDetailDict, success: { (userResponse, isSuccess) in
            
            self.hideActivityIndicator()
            if userResponse != nil {
                
                if isSuccess
                {
                    let alertView: UIAlertView = UIAlertView.init(title: "Reset Password", message: resetPasswordMessage, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                }
                else
                {
                    
                    let errorMessage:String = userResponse?["error"] as? String ?? "Server error"
                    
                    let alertView: UIAlertView = UIAlertView.init(title: "Log In", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                }
            }
        })
        
    }
    
    
    //MARK: Validation for email address
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    
    //MARK: Validation for phone number
    func isPhoneNumberValid(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result: Bool =  phoneTest.evaluate(with: value)
        return result
    }

    
    //MARK: Validation for password
    

    //MARK: Subscription Method
    /**
     Method to update subscription info with user
     @param receipt transaction receipt
     */
    func updateSubscriptionInfoWithReceiptdata(receipt: NSData?, emailId:String?, productIdentifier:String?, transactionIdentifier:String?)
    {
        self.isUserInteractionEnabled = false
        let requestParameters:Dictionary<String, Any> = Utility.sharedUtility.getRequestParametersForSubscription(receiptData: receipt, emailId: emailId, paymentModelObject: paymentModelObject, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
        DataManger.sharedInstance.apiToUpdateSubscriptionStatus(requestParameter: requestParameters, requestType: .post) { (subscriptionResponse, isSuccess) in
            
            self.subscriptionReceiptData = nil
            self.emailId = nil
            self.transactionIdentifier = nil
            self.productIdentifier = nil
            
            self.isUserInteractionEnabled = true
            self.hideActivityIndicator()
            
            if subscriptionResponse != nil {
                
                if isSuccess {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                    Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kTransactionInfo)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    Constants.kAPPDELEGATE.removePlistFromDocumentDirectory(plistName: Constants.kTransactionDetailPlistName)
                    
                    self.endEditing(true)
                    self.displayAlertOnSuccess()
                }
                else {
                    Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                    Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kUpdateSubscriptionStatusToServer)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    self.endEditing(true)
                    
                    let errorCode:String? = subscriptionResponse?["code"] as? String
                    
                    if errorCode != nil {
                        
                        self.showAlertWithMessage(message: ["code": errorCode!], receipt: receipt, emailId: emailId, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
                    }
                    else {
                        
                        self.dismissAlertViewWithSignUpSuccess(isSignUpSuccessfully: true)
                    }
                }
            }
            else {

                Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kUpdateSubscriptionStatusToServer)
                Constants.kSTANDARDUSERDEFAULTS.synchronize()
                self.showAlertWithMessage(message: [:], receipt: receipt, emailId: emailId, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
            }
        }
    }
    
    
    private func dismissAlertViewWithSignUpSuccess(isSignUpSuccessfully:Bool) {
    
        if self.signUpCompletionHandlerCopy != nil {
            
            self.signUpCompletionHandlerCopy!(isSignUpSuccessfully)
        }
        else if self.fbSignUpCompletionHandlerCopy != nil {
            
            self.fbSignUpCompletionHandlerCopy!(isSignUpSuccessfully)
        }
        else if self.googleSignUpCompletionHandlerCopy != nil {
            
            self.googleSignUpCompletionHandlerCopy!(isSignUpSuccessfully)
        }
    }
    
    //MARK: Purchase handle methods
    /**
     Method to show the popup
     
     @param message popUp informations
     */
    private func showAlertWithMessage(message: Dictionary<String, Any>?, receipt: NSData?, emailId:String?, productIdentifier:String?, transactionIdentifier:String?)
    {
        let errorCode:String? = message?[Constants.PAYMENT_NOTIFICATION_CODE_KEY] as? String
        
        if errorCode != nil {
            
            if (errorCode?.lowercased() == Constants.kPaymentFailedCode.lowercased() || errorCode?.lowercased() == Constants.kSubscriptionServiceFailedErrorCode.lowercased()) {
                
                self.subscriptionReceiptData = receipt
                self.emailId = emailId
                self.transactionIdentifier = transactionIdentifier
                self.productIdentifier = productIdentifier
                
                let alertView:UIAlertView = UIAlertView(title: "Payment Failed!", message: "The payment process did not complete/failed.\nTap OK to continue.\nTap Try Again to try again!", delegate: self, cancelButtonTitle: Constants.kStrOk, otherButtonTitles: Constants.kStrRetry)
                alertView.tag = 101
                alertView.show()
                
            } else if (errorCode?.lowercased() == Constants.kDuplicateUserErrorCode.lowercased()) {
                
                self.subscriptionReceiptData = receipt
                self.emailId = emailId
                self.transactionIdentifier = transactionIdentifier
                self.productIdentifier = productIdentifier
                
                let alertView:UIAlertView = UIAlertView(title: "Payment Failed!", message: "You may have another account associated with the entered Apple Id. Kindly log in with that \(Bundle.main.infoDictionary?["CFBundleDisplayName"] ?? "") account.", delegate: self, cancelButtonTitle: Constants.kStrOk)
                alertView.tag = 102
                alertView.show()
            }
            else if errorCode?.lowercased() == Constants.kUserNotFoundInSubscripionFailedErrorCode.lowercased() {
                
                self.dismissAlertViewWithSignUpSuccess(isSignUpSuccessfully: true)
            }
            else if errorCode?.lowercased() == Constants.kIllegalArugmentExceptionFailedErrorCode.lowercased(){
                
                self.dismissAlertViewWithSignUpSuccess(isSignUpSuccessfully: true)
            }
            else {
                
                self.subscriptionReceiptData = receipt
                self.emailId = emailId
                self.transactionIdentifier = transactionIdentifier
                self.productIdentifier = productIdentifier
                
                let alertView:UIAlertView = UIAlertView(title: "Payment Failed!", message: "The payment process got failed.\nTap OK to continue.\nTap Retry to try again!", delegate: self, cancelButtonTitle: Constants.kStrOk, otherButtonTitles: Constants.kStrRetry)
                alertView.tag = 103
                alertView.show()
            }
        }
        else {
            
            self.subscriptionReceiptData = receipt
            self.emailId = emailId
            self.transactionIdentifier = transactionIdentifier
            self.productIdentifier = productIdentifier
            
            let alertView:UIAlertView = UIAlertView(title: "Payment Failed!", message: "The payment process got failed.\nTap OK to continue.\nTap Retry to try again!", delegate: self, cancelButtonTitle: Constants.kStrOk, otherButtonTitles: Constants.kStrRetry)
            alertView.tag = 103
            alertView.show()
        }
    }
    
    
    func displayAlertOnSuccess() {
        
        let alertView: UIAlertView = UIAlertView.init(title: Constants.kSuccess, message: Constants.kCreateLoginSuccessMessage, delegate: self, cancelButtonTitle: Constants.kStrOk)
        alertView.tag = 100
        alertView.show()
    }
    
    
    //MARK: Alert View Delegates
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        
        switch alertView.tag {
        case 100:
            
            self.nextStepAfterSuccess()
            break
        case 101:
            
            if buttonIndex == 0 {
                
                self.subscriptionReceiptData = nil
                self.emailId = nil
                self.transactionIdentifier = nil
                self.productIdentifier = nil
                
                self.dismissAlertViewWithSignUpSuccess(isSignUpSuccessfully: true)
            }
            else if buttonIndex == 1 {
                
                self.showActivityIndicator(loaderText: nil)
                self.updateSubscriptionInfoWithReceiptdata(receipt: self.subscriptionReceiptData, emailId: self.emailId, productIdentifier: self.productIdentifier, transactionIdentifier: self.transactionIdentifier)
            }
            break
        case 102:
            
            self.subscriptionReceiptData = nil
            self.emailId = nil
            self.transactionIdentifier = nil
            self.productIdentifier = nil
            self.clearUserSettingsIfPaymentFails()
            self.dismissAlertViewWithSignUpSuccess(isSignUpSuccessfully: false)
            break
        case 103:
            
            if buttonIndex == 0 {
                
                self.subscriptionReceiptData = nil
                self.emailId = nil
                self.transactionIdentifier = nil
                self.productIdentifier = nil
                self.dismissAlertViewWithSignUpSuccess(isSignUpSuccessfully: true)
            }
            else if buttonIndex == 1 {
                
                self.showActivityIndicator(loaderText: nil)
                self.updateSubscriptionInfoWithReceiptdata(receipt: self.subscriptionReceiptData, emailId: self.emailId, productIdentifier: self.productIdentifier, transactionIdentifier: self.transactionIdentifier)
            }
            
            break
        default:
            break
        }
    }
    
    func clearUserSettingsIfPaymentFails() {
        
        Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kRefreshToken)
        Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kAuthorizationToken)
        Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kUSERID)
        Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.none.rawValue, forKey: Constants.kLoginType)
    }
    
    func nextStepAfterSuccess() {
        
        self.endEditing(true)
        if signUpCompletionHandlerCopy != nil {
            
            self.signUpCompletionHandlerCopy!(true)
        }
        else if fbSignUpCompletionHandlerCopy != nil {
            
            self.fbSignUpCompletionHandlerCopy!(true)
        }
        else if self.googleSignUpCompletionHandlerCopy != nil {
            
            self.googleSignUpCompletionHandlerCopy!(true)
        }
    }
    
    //MARK: Show/Hide Activity Indicator
    func showActivityIndicator(loaderText:String?) {
        
        progressIndicator = MBProgressHUD.showAdded(to: self, animated: true)
        if loaderText != nil {
            
            progressIndicator?.label.text = loaderText!
        }
    }
    
    func hideActivityIndicator() {
        
        progressIndicator?.hide(animated: true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func dropDownTapped() {
        
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return AppConfiguration.sharedAppConfiguration.countryDialCodesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (AppConfiguration.sharedAppConfiguration.countryDialCodesArray[row].countryName! + "  \(AppConfiguration.sharedAppConfiguration.countryDialCodesArray[row].countryDialCode ?? "" )")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        for component: AnyObject in self.subviews {
            
            if component is SFDropDown
            {
                (component as! SFDropDown).text = AppConfiguration.sharedAppConfiguration.countryDialCodesArray[row].countryDialCode
                self.selectedCountry = AppConfiguration.sharedAppConfiguration.countryDialCodesArray[row]
                break
            }
        }
        self.endEditing(true)
    }

    func getPosition(position:CGFloat) -> CGFloat {
        var value = position
        if (Constants.IPHONE && Utility.sharedUtility.isIphoneX()) {
             value = value + 24;
        }
        return value;
    }
}
