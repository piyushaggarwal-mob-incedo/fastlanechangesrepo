//
//  LoginView.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 02/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
enum RetryAfterFailureAlert {
    case RetryLogin
    case RetrySignUP
    case RetryResetPassword
}

@objc protocol LoginViewDelegate: NSObjectProtocol {
    @objc optional func userLoginDone() -> Void
    @objc optional func forgotPasswordTapped() -> Void
    @objc optional func cancelButtonTapped() -> Void
    @objc optional func showAlertControllerForError(title: String, message : String) -> Void
    @objc optional func loadAncillaryPage(_ Type : String) -> Void
}

class LoginView_tvOS: UIViewController , SFButtonDelegate , signUpFooterViewDelegate {
    /// Network unavailanble alert.
    var networkUnavailableAlert:UIAlertController?
    /// Alert type.
    var failureAlertType:RetryAfterFailureAlert?
    var paymentModelObject:PaymentModel?
    var modulesArray:Array<AnyObject> = []
    weak var delegate: LoginViewDelegate?
    var relativeViewFrame:CGRect?
    private  var acitivityIndicator : UIActivityIndicatorView?
    private var viewAlreadyCreated: Bool = false
    private var loginObject: LoginViewObject_tvOS?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, loginObject: LoginViewObject_tvOS, viewTag: Int, relativeFrame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        self.relativeViewFrame = relativeFrame
        self.loginObject = loginObject
//        let loginLayout = Utility.fetchLoginViewLayoutDetails(loginViewObject: loginObject)
//        self.view.frame = Utility.initialiseViewLayout(viewLayout: loginLayout, relativeViewFrame: relativeViewFrame!)
        self.view.changeFrameHeight(height: 940)
        self.modulesArray = loginObject.components
        self.view.backgroundColor = UIColor.clear
    }
   
    
    override func viewDidAppear(_ animated: Bool) {
        if viewAlreadyCreated == false {
            createView()
            viewAlreadyCreated = true
        }
        NotificationCenter.default.addObserver(self, selector:#selector(LoginView_tvOS.CheckNetworkStatus), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        if let pageType = loginObject?.moduleType {
            if pageType == "AC ResetPassword 01" {
                self.perform(#selector(setNeedsFocusUpdate), with: nil, afterDelay: 0.2)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeActivityIndicator()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)

    }
    
    func createView() -> Void {
        createLoginView(containerView: self.view, itemIndex: 0)
    }
    
    
    //MARK: Creation of View Components
    func createLoginView(containerView: UIView, itemIndex:Int) {
        
        for component:AnyObject in self.modulesArray {
            
            if component is SFButtonObject {
                
                let buttonObject:SFButtonObject = component as! SFButtonObject
                
                createButtonView(buttonObject: buttonObject, containerView: self.view, itemIndex: itemIndex, type: component.key!!)
            }
            else if component is SFTextFieldObject{
                createTextField(textFieldObject: component as! SFTextFieldObject, containerView: containerView, itemIndex: 0)
            }
            else if component is SFLabelObject {
                createLabelView(labelObject: component as! SFLabelObject, containerView: containerView, type: component.key!!)
            }
            else if component is SFSeparatorViewObject
            {
                createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
            }
            
        }
    }
    
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        let separatorViewLayout = Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject)
        let separatorView: SFSeparatorView = SFSeparatorView()
        separatorView.separtorViewObject = separatorViewObject
        separatorView.isHidden = false
        separatorView.relativeViewFrame = self.view.frame
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: separatorViewLayout)
        
        self.view.addSubview(separatorView)
    }
    
    func createLabelView(labelObject:SFLabelObject, containerView:UIView, type: String) {
        
        if labelObject.key == "signupfooterview" {
            let signUpFooterView = SignUpFooterView.instanceFromNib() as! SignUpFooterView
            signUpFooterView.frame = CGRect(x: 680, y: 600, width: 600, height: 120)
            signUpFooterView.delegate = self
            self.view.addSubview(signUpFooterView)
        }
        else
        {
            let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
            
            let label:SFLabel = SFLabel(frame: CGRect.zero)
            label.labelObject = labelObject
            label.labelLayout = labelLayout
            label.relativeViewFrame = containerView.frame
            label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            label.text = labelObject.text
            containerView.addSubview(label)
            containerView.bringSubview(toFront: label)
            label.createLabelView()
            
            if labelObject.key == "forgotPasswordTitle" {
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor!)
            } else {
                if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                    label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
                }
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
        if buttonObject.key == "skip button" {
//            if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD{
//                if Utility.sharedUtility.checkIfUserIsSubscribedGuest() == false {
                    button.tag = 929
                    containerView.addSubview(button)
                    containerView.bringSubview(toFront: button)
//                }
//            }
        } else {
            containerView.addSubview(button)
            containerView.bringSubview(toFront: button)
        }
    }
    
    func createTextField(textFieldObject:SFTextFieldObject, containerView:UIView, itemIndex:Int) -> Void {
        
        let textFieldLayout = Utility.fetchTextFieldLayoutDetails(textFieldObject: textFieldObject)
        let textField:SFTextField = SFTextField()
        textField.relativeViewFrame = self.view.frame
        //        textField.delegate = self
        textField.initialiseTextViewFrameFromLayout(textFieldLayout: textFieldLayout)
        textField.textFieldLayout = textFieldLayout
        textField.textFieldObject = textFieldObject
        textField.updateView()
        //Ugly hack to handle focus issue on login page.
//        textField.isUserInteractionEnabled = false
//        self.perform(#selector(activateTextField), with: textField, afterDelay: 1.5)
        self.view.addSubview(textField)
    }
    
    @objc private func activateTextField(textField: UITextField) {
        textField.isUserInteractionEnabled = true
    }
    
    func CheckNetworkStatus(){
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() != NotReachable {
            if let networkAlert = networkUnavailableAlert {
                if networkAlert.isShowing() {
                    networkAlert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    //MARK: - Button Delegate
    func buttonClicked(button: SFButton) {
        
        if button.buttonObject?.action == "login"
        {
                loginClicked()
        }
        else if button.buttonObject?.action == "forgotPassword"
        {
            if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.forgotPasswordTapped)))!
            {
                self.delegate?.forgotPasswordTapped!()
            }
        }
        else if button.buttonObject?.action == "cancel"
        {
            if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.cancelButtonTapped)))!
            {
                self.delegate?.cancelButtonTapped!()
            }
        }
        else if button.buttonObject?.action == "resetPassword"
        {
            resetPasswordClicked()
        }
        else if button.buttonObject?.action == "signup"
        {
            signUpClicked()
        }
        else if button.buttonObject?.action == "skip"{
            skipButtonTapped()
        }
    }
    
    
    private func loginClicked(){
        
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() == NotReachable {
            self.failureAlertType = .RetryLogin
            self.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
        }
        else {
            logIn(loginDone: { [weak self] (loginStatus: Bool) in
                if loginStatus == true
                {
                    if (self?.delegate != nil) && (self?.delegate?.responds(to: #selector(self?.delegate?.userLoginDone)))!
                    {
                        self?.delegate?.userLoginDone!()
                        
                    }
                }
            })
        }
        
    }
    
    private func signUpClicked(){
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() == NotReachable {
            self.failureAlertType = .RetrySignUP
            self.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
        }
        else {
            signUp(signUpDone: { [weak self] (signUpStatus: Bool) in
                if signUpStatus == true
                {
                    if (self?.delegate != nil) && (self?.delegate?.responds(to: #selector(self?.delegate?.userLoginDone)))!
                    {
                        self?.delegate?.userLoginDone!()
                    }
                }
            })
        }
        
        
    }
    
    private func resetPasswordClicked(){
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() == NotReachable {
            self.failureAlertType = .RetryResetPassword
            self.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
        }
        else {
            resetPassword()
        }
    }
    
    
    //MARK: Email Sign In method
    func logIn(loginDone: @escaping ((_ loginStatus: Bool) -> Void)) -> Void {
        
        var email: String = ""
        var password: String = ""
        
        for component: AnyObject in self.view.subviews {
            
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
            if delegate != nil && (delegate?.responds(to: #selector(LoginViewDelegate.showAlertControllerForError(title:message:))))! {
                delegate?.showAlertControllerForError!(title: "Log In", message: "Please enter email to continue.")
            }
            return
        }
        else if !isValidEmailAddress(emailAddressString: email)
        {
            if delegate != nil && (delegate?.responds(to: #selector(LoginViewDelegate.showAlertControllerForError(title:message:))))! {
                delegate?.showAlertControllerForError!(title: "Log In", message: "Please enter a valid email.")
            }
            return
        }
        
        
        if password.characters.count == 0
        {
            if delegate != nil && (delegate?.responds(to: #selector(LoginViewDelegate.showAlertControllerForError(title:message:))))! {
                delegate?.showAlertControllerForError!(title: "Log In", message: "Please enter password to continue.")
            }
            return
        }
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/signin?device=ios_apple_tv&site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        let userDetailDict = ["email":email, "password":password]
        
        addActivityIndicator()
        
        DataManger.sharedInstance.userSignIn(apiEndPoint: apiEndPoint, requestType: .get, requestParameters: userDetailDict, success: { [weak self] (userResponse, isSuccess)  in
            
            if userResponse != nil {
                self?.removeActivityIndicator()
                self?.view.endEditing(true)
                
                if isSuccess {
                    
                    let refreshToken:String? = userResponse?["refreshToken"] as? String
                    let authorizationToken: String? = userResponse?["authorizationToken"] as? String
                    let id:String? = userResponse?["userId"] as? String
                    let isUserSubscribedString:String? = userResponse?["isSubscribed"] as? String
                    let isUserSubscribed : Bool?
                    if let isUserSubscribedString = isUserSubscribedString {
                        if isUserSubscribedString == "true" {
                            isUserSubscribed = true
                        } else {
                            isUserSubscribed = false
                        }
                    } else if let userSubscribed = userResponse?["isSubscribed"] as! Bool? {
                        if userSubscribed {
                            isUserSubscribed = true
                        } else {
                            isUserSubscribed = false
                        }
                    } else {
                        isUserSubscribed = false
                    }
                    

                    if let isUserSubscribed = isUserSubscribed {
                        Constants.kSTANDARDUSERDEFAULTS.setValue(isUserSubscribed, forKey: Constants.kIsSubscribedKey)
                    }
                    if authorizationToken != nil && refreshToken != nil
                    {
                        Constants.kSTANDARDUSERDEFAULTS.setValue(refreshToken, forKey: Constants.kRefreshToken)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(authorizationToken!, forKey: Constants.kAuthorizationToken)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kAuthorizationTokenTimeStamp)
                        
                    }
                    if id != nil {
                        
                        Constants.kSTANDARDUSERDEFAULTS.setValue(id, forKey: Constants.kUSERID)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Email.rawValue, forKey: Constants.kLoginType)
                    }
                    Constants.kSTANDARDUSERDEFAULTS.removeObject(forKey: "PREVIOUS_SERACH_TERMS")

                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    loginDone(isSuccess)
                }
                else
                {
                    
                    let reachability:Reachability = Reachability.forInternetConnection()
                    if reachability.currentReachabilityStatus() == NotReachable {
                        self?.failureAlertType = .RetryLogin
                        self?.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
                    }
                    else{
                        let errorMessage:String = userResponse?["error"] as? String ?? "Server error"
                        print(errorMessage)
                        
                        if self?.delegate != nil && (self?.delegate?.responds(to: #selector(LoginViewDelegate.showAlertControllerForError(title:message:))))! {
                            self?.delegate?.showAlertControllerForError!(title: "Log In", message: errorMessage)
                        }
                    }
                    
                }
            }
            }
        )
    }
    
    
    private func resetPassword() -> Void {
        var email: String = ""
        
        for component: AnyObject in self.view.subviews {
            
            if component is SFTextField {
                
                if (component as! SFTextField).textFieldObject?.key == "emailTextField"
                {
                    email = (component as! SFTextField).text!
                }
            }
        }
        
        if email.characters.count == 0{
            if delegate != nil && (delegate?.responds(to: #selector(LoginViewDelegate.showAlertControllerForError(title:message:))))! {
                delegate?.showAlertControllerForError!(title: "Forgot Password", message: "Please enter a valid email.")
            }
            return
        }
        else if !isValidEmailAddress(emailAddressString: email){
            
            if delegate != nil && (delegate?.responds(to: #selector(LoginViewDelegate.showAlertControllerForError(title:message:))))! {
                delegate?.showAlertControllerForError!(title: "Forgot Password", message: "Please enter a valid email.")
            }
            return
        }
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/password/forgot?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        let userDetailDict = ["email":email]
        
        addActivityIndicator()
        
        DataManger.sharedInstance.userSignIn(apiEndPoint: apiEndPoint, requestType: .get, requestParameters: userDetailDict, success: { [weak self] (userResponse, isSuccess) in
            
            self?.removeActivityIndicator()
            if userResponse != nil {
                if isSuccess {
                    if let errorString = userResponse?["error"] {
                        if self?.delegate != nil && (self?.delegate?.responds(to: #selector(LoginViewDelegate.showAlertControllerForError(title:message:))))! {
                            self?.delegate?.showAlertControllerForError!(title: "Reset Password", message: errorString as! String)
                        }
                        return
                    }
                    let resetPasswordMessage: String = "Follow the instructions in the email we just sent you to reset your password."
                    if self?.delegate != nil && (self?.delegate?.responds(to: #selector(LoginViewDelegate.showAlertControllerForError(title:message:))))! {
                        self?.delegate?.showAlertControllerForError!(title: "Reset Password", message: resetPasswordMessage)
                    }
                }
                else{
                    let reachability:Reachability = Reachability.forInternetConnection()
                    if reachability.currentReachabilityStatus() == NotReachable {
                        self?.failureAlertType = .RetryResetPassword
                        self?.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
                    }
                    else{
                        let errorMessage:String = userResponse?["error"] as? String ?? "Server error"
                        print(errorMessage)
                        
                        if self?.delegate != nil && (self?.delegate?.responds(to: #selector(LoginViewDelegate.showAlertControllerForError(title:message:))))! {
                            self?.delegate?.showAlertControllerForError!(title: "Forgot Password", message: errorMessage)
                        }
                    }
                }
            }
        })
    }
    
    
    //MARK: Email Sign Up method
    private func signUp(signUpDone: @escaping ((_ loginStatus: Bool) -> Void)) -> Void {
        
        var email: String = ""
        var password: String = ""
        //        var phone: String = ""
        
        for component: AnyObject in self.view.subviews {
            
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
            if delegate != nil && (self.delegate?.responds(to: #selector(LoginViewDelegate.showAlertControllerForError(title:message:))))! {
                delegate?.showAlertControllerForError!(title: "Sign Up", message: "Please enter email to continue.")
            }
            return
        }
        else if !isValidEmailAddress(emailAddressString: email)
        {
            if delegate != nil && (self.delegate?.responds(to: #selector(LoginViewDelegate.showAlertControllerForError(title:message:))))! {
                delegate?.showAlertControllerForError!(title: "Sign Up", message: "Please enter a valid email.")
            }
            return
        }
        
        
        if password.characters.count == 0
        {
            if delegate != nil && (self.delegate?.responds(to: #selector(LoginViewDelegate.showAlertControllerForError(title:message:))))! {
                delegate?.showAlertControllerForError!(title: "Sign Up", message: "Please enter password to continue.")
            }
            return
        }
        
        var userDetailDict = ["email": email, "password":password]
        
        addActivityIndicator()
        if Utility.sharedUtility.checkIfUserIsSubscribedGuest() && AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            
            if DataManger.sharedInstance.checkIfAuthroizationTokenIsExpired() {
                
                DataManger.sharedInstance.apiToGetUpdatedAuthorizationToken(success: { (authenticationResponse, isSuccess) in
                    
                    if authenticationResponse != nil && isSuccess == true {
                        
                        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) != nil {
                            
                            userDetailDict["accessToken"] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken)! as? String
                            
                            self.net_signUp(email: email, userDetailDict: userDetailDict, signUpDone: signUpDone)
                        }
                        else {
                            self.removeActivityIndicator()
                            signUpDone(false)
                        }
                    }
                    else {
                        
                        self.removeActivityIndicator()
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
                    
                    self.removeActivityIndicator()
                    signUpDone(false)
                }
            }
        }
        else {
            
            self.net_signUp(email: email, userDetailDict: userDetailDict, signUpDone: signUpDone)
        }
    }
    
    
    private func net_signUp(email:String?, userDetailDict:Dictionary<String, Any>, signUpDone: @escaping ((_ loginStatus: Bool) -> Void)) -> Void {
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/signup?device=ios_apple_tv&site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        DataManger.sharedInstance.userSignUp(apiEndPoint: apiEndPoint, requestType: .post, requestParameters: userDetailDict, success: { [weak self] (userResponse, isSuccess) in
            guard let checkedSelf = self else {
                return
            }
            
            if isSuccess {
                
                let refreshToken:String? = userResponse?["refreshToken"] as? String
                let authorizationToken: String? = userResponse?["authorizationToken"] as? String
                let id:String? = userResponse?["userId"] as? String
                let email:String? = userResponse?["email"] as? String
                let isUserSubscribedString:String? = userResponse?["isSubscribed"] as? String
                let isUserSubscribed : Bool?
                if let isUserSubscribedString = isUserSubscribedString {
                    if isUserSubscribedString == "true" {
                        isUserSubscribed = true
                    } else {
                        isUserSubscribed = false
                    }
                } else if let userSubscribed = userResponse?["isSubscribed"] as! Bool? {
                    if userSubscribed {
                        isUserSubscribed = true
                    } else {
                        isUserSubscribed = false
                    }
                } else {
                    isUserSubscribed = false
                }
                
                if let isUserSubscribed = isUserSubscribed {
                    Constants.kSTANDARDUSERDEFAULTS.setValue(isUserSubscribed, forKey: Constants.kIsSubscribedKey)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                }
                
                if authorizationToken != nil && refreshToken != nil
                {
                    Constants.kSTANDARDUSERDEFAULTS.setValue(refreshToken, forKey: Constants.kRefreshToken)
                    Constants.kSTANDARDUSERDEFAULTS.setValue(authorizationToken!, forKey: Constants.kAuthorizationToken)
                    Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kAuthorizationTokenTimeStamp)
                    if email != nil && email != "" {
                        Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Email.rawValue, forKey: Constants.kLoginType)
                    } else if isUserSubscribed == true {
                        Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.SubscribedGuest.rawValue, forKey: Constants.kLoginType)
                    }
                }
                
                if id != nil {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(id, forKey: Constants.kUSERID)
                    Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                }
                Constants.kSTANDARDUSERDEFAULTS.removeObject(forKey: "PREVIOUS_SERACH_TERMS")

                Constants.kSTANDARDUSERDEFAULTS.synchronize()
                if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) != nil && AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                    
                    let userInfo:Dictionary<String, Any> = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as! Dictionary<String, Any>
                   
                    

                    
                    if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                        checkedSelf.updateSubscriptionInfoWithReceiptdata(receipt: userInfo["receiptData"] as? NSData, emailId: nil, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String, signUpDone: signUpDone)
                    }
                    else {
                        
                        Constants.kAPPDELEGATE.fetchUserSubscriptionStatusFromServer(shouldUpdateIAPReceipt: false, {
                            signUpDone(isSuccess)
                        })
                    }
                    
                    
                    
                    
                    
                    //checkedSelf.updateSubscriptionInfoWithReceiptdata(receipt: userInfo["receiptData"] as? NSData, emailId: nil, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String, signUpDone: signUpDone)
                }
                else {
                    
                    if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                        Constants.kAPPDELEGATE.fetchUserSubscriptionStatusFromServer(shouldUpdateIAPReceipt: false, {
                            signUpDone(isSuccess)
                        })
                        
                    } else{
                        signUpDone(isSuccess)
                    }
                }
                
            }
            else {
                checkedSelf.removeActivityIndicator()
                let reachability:Reachability = Reachability.forInternetConnection()
                if reachability.currentReachabilityStatus() == NotReachable {
                    checkedSelf.failureAlertType = .RetrySignUP
                    checkedSelf.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
                }
                else{
                    let errorMessage:String = userResponse?["error"] as? String ?? "Server error"
                    
                    if checkedSelf.delegate != nil && (checkedSelf.delegate?.responds(to: #selector(LoginViewDelegate.showAlertControllerForError(title:message:))))! {
                        checkedSelf.delegate?.showAlertControllerForError!(title: "Sign Up", message: errorMessage)
                    }
                }
            }
        })
    }
    
    //MARK: Subscription Method
    /**
     Method to update subscription info with user
     @param receipt transaction receipt
     */
    func updateSubscriptionInfoWithReceiptdata(receipt: NSData?, emailId:String?, productIdentifier:String?, transactionIdentifier:String?,  signUpDone: @escaping ((_ loginStatus: Bool) -> Void))
    {
        let requestParameters:Dictionary<String, Any> = Utility.sharedUtility.getRequestParametersForSubscription(receiptData: receipt, emailId: emailId, paymentModelObject: paymentModelObject, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            DataManger.sharedInstance.apiToUpdateSubscriptionStatus(requestParameter: requestParameters, requestType: .post) {[weak self] (subscriptionResponse, isSuccess) in
                guard let checkedSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    if subscriptionResponse != nil {
                        if isSuccess {
                            
                            if Utility.sharedUtility.checkIfUserIsLoggedIn() == false {
                                Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.SubscribedGuest.rawValue, forKey: Constants.kLoginType)
                            }
                            Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kTransactionInfo)
                            Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                            Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                            Constants.kSTANDARDUSERDEFAULTS.synchronize()
//                            Constants.kAPPDELEGATE.removePlistFromDocumentDirectory(plistName: Constants.kTransactionDetailPlistName)
                        }
                        else {
                            if let userId = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as? String {
                                if userId.isEmpty == false {
                                    if let code = subscriptionResponse!["code"] as? String {
                                        if code == "DuplicateKeyException" {
                                            if let message = subscriptionResponse!["message"] as? String {
                                                if message.range(of: userId) != nil {
                                                    if Utility.sharedUtility.checkIfUserIsLoggedIn() == false {
                                                        Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.SubscribedGuest.rawValue, forKey: Constants.kLoginType)
                                                    }
                                                    Constants.kSTANDARDUSERDEFAULTS.setValue(true, forKey: Constants.kIsSubscribedKey)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kUpdateSubscriptionStatusToServer)
                        }
                        signUpDone(isSuccess)
                    }
                    else {
                        
                        signUpDone(isSuccess)
                    }
                    checkedSelf.removeActivityIndicator()
                }
            }
        }
    }

    func skipButtonTapped() -> Void
    {
//        For Testing purposes.
//        if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.userLoginDone)))!
//        {
//            self.delegate?.userLoginDone!()
//        }
//        return
        if Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.userLoginDone)))!{
                self.delegate?.cancelButtonTapped!()
            }
        } else {
            var userDetailDict: Dictionary<String, Any>?
            
            if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                
                if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) != nil
                {
                    userDetailDict = ["accessToken": Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken)!]
                    addActivityIndicator()
                    
                    performSignUpProcess(userDetailDict: userDetailDict!)
                }
                else
                {
                    self.addActivityIndicator()
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        
                        DataManger.sharedInstance.apiToGetAnonymousToken(success: { (isSuccess) in
                            
                            DispatchQueue.main.async {
                                
                                if isSuccess {
                                    
                                    userDetailDict = ["accessToken": Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken)!]
                                    self.performSignUpProcess(userDetailDict: userDetailDict!)
                                }
                                else {
                                    
                                    self.addActivityIndicator()
                                    
                                    let cancelAction:UIAlertAction = UIAlertAction(title: Constants.kStrCancel, style: .default, handler: { (cancelAction) in
                                    })
                                    
                                    let retryAction:UIAlertAction = UIAlertAction(title: Constants.kStrRetry, style: .default, handler: { (retryAction) in
                                        self.skipButtonTapped()
                                    })
                                    
                                    let retryAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "Error", alertMessage: "Error in updating subscription status on server. Please try again", alertActions: [cancelAction, retryAction])
                                    self.present(retryAlert, animated: true, completion: nil)
                                }
                            }
                        })
                    }
                }
            }
            else {
                if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.userLoginDone)))! {
                    self.delegate?.userLoginDone!()
                }
            }
        }
    }
    
    private func performSignUpProcess(userDetailDict: Dictionary<String, Any>){
//        //Test
//        
//        if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.userLoginDone)))!
//        {
//            self.delegate?.userLoginDone!()
//        }
//        return
        self.net_signUp(email: nil, userDetailDict: userDetailDict, signUpDone: { [weak self] (signUpStatus: Bool) in
//            if signUpStatus == true
//            {
                if (self?.delegate != nil) && (self?.delegate?.responds(to: #selector(self?.delegate?.userLoginDone)))!
                {
                    self?.delegate?.userLoginDone!()
                }
//            }
        })
    }
    
    func loadAncillaryPage(_ type: String) {
        if self.delegate != nil && (self.delegate?.responds(to: #selector(loadAncillaryPage(_:))))! {
            self.delegate?.loadAncillaryPage!(type)
        }
    }
    
    
    
    private func isValidEmailAddress(emailAddressString: String) -> Bool {
        
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
    
    private func isPhoneNumberValid(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    
    //MARK: - Activity Indicator Methods
    private func addActivityIndicator() {
        if self.acitivityIndicator == nil {
            self.acitivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        }
        if self.isShowing() {
            self.acitivityIndicator?.showIndicatorOnWindow()
        }
    }
    
    private func removeActivityIndicator(){
        if let tempActivityIndicatorView = self.acitivityIndicator
        {
            tempActivityIndicatorView.removeFromSuperview()
            tempActivityIndicatorView.stopAnimating();
        }
    }
    
    
    //MARK: Display Network Error Alert
    func showAlertForAlertType(alertType: AlertType) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                if self.failureAlertType == .RetryLogin {
                   self.loginClicked()
                }
                else if self.failureAlertType == .RetrySignUP {
                   self.signUpClicked()
                }
                else if self.failureAlertType == .RetryResetPassword{
                    self.resetPasswordClicked()
                }
                
            }
        }
        
        var alertTitleString:String?
        var alertMessage:String?
        
        if alertType == .AlertTypeNoInternetFound {
            alertTitleString = Constants.kInternetConnection
            alertMessage = "Please check your Internet Connection and try again later"
        }
        else {
            alertTitleString = "No Response Received"
            alertMessage = "Unable to fetch data!\nDo you wish to Try Again?"
        }
        
        
        
        networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction, retryAction])
        
        self.present(networkUnavailableAlert!, animated: true, completion: nil)
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.first!.type == .menu {
            if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                //Check if user is susbcribed guest then make the user to go back otherwise process the skip action.
                if Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                    super.pressesBegan(presses, with: event)
                } else {
                    if checkIfPageIsSignUpPage() {
                        self.skipButtonTapped()
                    } else {
                        super.pressesBegan(presses, with: event)
                    }
                }
            } else {
                super.pressesBegan(presses, with: event)
            }
        }
        else {
            super.pressesBegan(presses, with: event)
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.first!.type == .menu {
            if checkIfPageIsSignUpPage() == false {
                super.pressesBegan(presses, with: event)
            }
        } else {
            super.pressesEnded(presses, with: event)
        }
    }
    
    private func checkIfPageIsSignUpPage() -> Bool {
        var skipButtonPresent = false
        for view in view.subviews {
            if view.tag == 929 {
                skipButtonPresent = true
                break
            }
        }
        return skipButtonPresent
    }
}
