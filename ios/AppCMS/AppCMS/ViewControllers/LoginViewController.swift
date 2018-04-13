//
//  LoginViewController.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 23/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import AppsFlyerLib
import AdSupport
import Firebase
enum loginPageType:String {
    case authentication
    case createLogin
}

class LoginViewController: UIViewController, LoginViewDelegate, UIAlertViewDelegate, GIDSignInUIDelegate {

    var modulesListArray:Array<AnyObject> = []
    var modulesArray:Array<AnyObject> = []
    var loginPageSelection: Int = 0
    var paymentModelObject:PaymentModel?
    var completionHandlerCopy : ((Bool) -> Void)? = nil
    var progressIndicator:MBProgressHUD?
    var shouldUserBeNavigatedToHomePage:Bool?
    var loginType: loginPageType!
    var pageScreenName:String?
    private var subscriptionReceiptData:NSData?
    private var emailId:String?, productIdentifier:String?, transactionIdentifier:String?
    
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
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        // Do any additional setup after loading the view.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
//            FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [kFIRParameterItemName: pageScreenName ?? "Login Screen"])
            FIRAnalytics.setScreenName(pageScreenName ?? "Login Screen", screenClass: nil)

        }
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.allowIDFACollection = true
        tracker.set(kGAIScreenName, value: pageScreenName ?? "Login Screen")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchLoginPageUI() -> Void {
        
        var filePath:String!
        
        if self.loginType == loginPageType.authentication {
            guard let pageID: String = Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Authentication Screen") else { return }
            filePath = AppSandboxManager.getpageFilePath(fileName: pageID)
        }
        else if self.loginType == loginPageType.createLogin
        {
            guard let pageID: String = Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Create Login Screen") else { return }
            filePath = AppSandboxManager.getpageFilePath(fileName: pageID)
        }
        
        if FileManager.default.fileExists(atPath: filePath){
            let jsonData:Data = FileManager.default.contents(atPath: filePath)!
            
            let responseStarJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, Any>
            let responseJson:Array<Dictionary<String, AnyObject>>? = responseStarJson["moduleList"] as? Array<Dictionary<String, AnyObject>>
            
            if responseJson != nil {
                
                let moduleUIParser = ModuleUIParser()
                modulesListArray = moduleUIParser.parseModuleConfigurationJson(modulesConfigurationArray: responseJson!) as Array<AnyObject>
                createModules()
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
        self.navigationController?.navigationBar.barTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        self.navigationItem.titleView = Utility.createNavigationTitleView(navBarHeight: (self.navigationController?.navigationBar.frame.size.height)!)
        let closeButton: UIButton = UIButton.init(type: .custom)
        
        if self.loginType == loginPageType.createLogin
        {
            closeButton.setTitle("Skip", for: UIControlState.normal)
            closeButton.frame = CGRect.init(x: 0, y: 0, width: 40, height: 22)
            closeButton.addTarget(self, action: #selector(skipButtonTapped(sender:)), for: .touchUpInside)
        }
        else
        {
            let closeButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "cancelIcon.png"))
            
            closeButton.setImage(closeButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            closeButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
            
            closeButton.frame = CGRect.init(x: 0, y: 0, width: 22, height: 22)
            closeButton.addTarget(self, action: #selector(closeButtonTapped(sender:)), for: .touchUpInside)
        }

        let closeBarButtonItem: UIBarButtonItem = UIBarButtonItem.init(customView: closeButton)
        self.navigationItem.rightBarButtonItem = closeBarButtonItem
    }
    
    func closeButtonTapped(sender: UIButton) -> Void {
        self.view.endEditing(true)
        self.navigationController?.dismiss(animated: false, completion: {
            
            if self.completionHandlerCopy != nil {
                self.completionHandlerCopy!(false)
            }
        })
    }
    
    
    func skipButtonTapped(sender: UIButton) -> Void
    {
        self.view.endEditing(true)
        var userDetailDict: Dictionary<String, Any>?
        
        if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) != nil
            {
                userDetailDict = ["accessToken": Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken)!]
                showActivityIndicator(loaderText: nil)
                
                performSignUpProcess(userDetailDict: userDetailDict!)
            }
            else
            {
                self.showActivityIndicator(loaderText: nil)
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    DataManger.sharedInstance.apiToGetAnonymousToken(success: { (isSuccess) in
                        
                        DispatchQueue.main.async {
                            
                            if isSuccess {
                                
                                userDetailDict = ["accessToken": Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken)!]
                                self.performSignUpProcess(userDetailDict: userDetailDict!)
                            }
                            else {
                                
                                self.hideActivityIndicator()
                                
                                let cancelAction:UIAlertAction = UIAlertAction(title: Constants.kStrCancel, style: .default, handler: { (cancelAction) in
                                    
                                })
                                
                                let retryAction:UIAlertAction = UIAlertAction(title: Constants.kStrRetry, style: .default, handler: { (retryAction) in
                                    
                                    self.skipButtonTapped(sender: sender)
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
            
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func performSignUpProcess(userDetailDict: Dictionary<String, Any>) {
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/signup?device=ios_phone&site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"

        DispatchQueue.global(qos: .userInitiated).async {
            
            DataManger.sharedInstance.userSignUp(apiEndPoint: apiEndPoint, requestType: .post, requestParameters: userDetailDict, success: { (userResponse, isSuccess) in
                
                DispatchQueue.main.async {
                    
                    if userResponse != nil {
                        
                        if isSuccess {
                            
                            let refreshToken:String? = userResponse?["refreshToken"] as? String
                            let authorizationToken: String? = userResponse?["authorizationToken"] as? String
                            let id:String? = userResponse?["userId"] as? String
                            
                            if authorizationToken != nil && refreshToken != nil
                            {
                                Constants.kSTANDARDUSERDEFAULTS.setValue(refreshToken, forKey: Constants.kRefreshToken)
                                Constants.kSTANDARDUSERDEFAULTS.setValue(authorizationToken!, forKey: Constants.kAuthorizationToken)
                                Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.SubscribedGuest.rawValue, forKey: Constants.kLoginType)
                                Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kAuthorizationTokenTimeStamp)
                            }
                            
                            if id != nil {
                                
                                Constants.kSTANDARDUSERDEFAULTS.setValue(id, forKey: Constants.kUSERID)
                                Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                                AppsFlyerTracker.shared().customerUserID = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as? String ?? ""
                            }
                            
                            if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                
                                FIRAnalytics.setUserID(id)
                            }
                            
                            AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_REGISTRATION, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "",Constants.APPSFLYER_KEY_DEVICEID : ASIdentifierManager.shared().advertisingIdentifier.uuidString , Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "true"])

                            DownloadManager.sharedInstance.downloadQuality = ""
                            Constants.kSTANDARDUSERDEFAULTS.set(DownloadManager.sharedInstance.downloadQuality, forKey: Constants.kDownloadQualitySelectionkey)
                            Constants.kSTANDARDUSERDEFAULTS.synchronize()
                            
                            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) != nil && AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                                
                                let userInfo:Dictionary<String, Any> = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as! Dictionary<String, Any>
                                self.updateSubscriptionInfoWithReceiptdata(receipt: userInfo["receiptData"] as? NSData, emailId: nil, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String)
                            }
                        }
                        else {
                            
                            self.hideActivityIndicator()
                            let errorMessage:String = userResponse?["error"] as? String ?? userResponse?["message"] as? String ?? "Server error"
                            
                            let alertView: UIAlertView = UIAlertView.init(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                            alertView.show()
                        }
                    }
                    else {
                        
                        self.hideActivityIndicator()
                        let errorMessage:String = userResponse?["error"] as? String ?? "Server error"
                        
                        let alertView: UIAlertView = UIAlertView.init(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK")
                        alertView.show()
                    }
                }
            })
        }
    }
    
    //MARK: Show/Hide Activity Indicator
    func showActivityIndicator(loaderText:String?) {
        
        progressIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        if loaderText != nil {
            
            progressIndicator?.label.text = loaderText!
        }
    }
    
    //MARK: Subscription Method
    /**
     Method to update subscription info with user
     @param receipt transaction receipt
     */
    func updateSubscriptionInfoWithReceiptdata(receipt: NSData?, emailId:String?, productIdentifier:String?, transactionIdentifier:String?)
    {
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator(loaderText: nil)
        
        let requestParameters:Dictionary<String, Any> = Utility.sharedUtility.getRequestParametersForSubscription(receiptData: receipt, emailId: emailId, paymentModelObject: paymentModelObject, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            DataManger.sharedInstance.apiToUpdateSubscriptionStatus(requestParameter: requestParameters, requestType: .post) { (subscriptionResponse, isSuccess) in
                
                self.subscriptionReceiptData = nil
                self.emailId = nil
                self.transactionIdentifier = nil
                self.productIdentifier = nil
                
                DispatchQueue.main.async {
                    
                    self.view.isUserInteractionEnabled = true
                    self.hideActivityIndicator()
                    
                    if subscriptionResponse != nil {
                        
                        if isSuccess {
                            
                            Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kTransactionInfo)
                            Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                            Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                            Constants.kSTANDARDUSERDEFAULTS.synchronize()
                            Constants.kAPPDELEGATE.removePlistFromDocumentDirectory(plistName: Constants.kTransactionDetailPlistName)
                            
                            self.nextStepAfterSuccess()
                        }
                        else {
                            
                            let errorCode:String? = subscriptionResponse?["code"] as? String
                            
                            if errorCode != nil {
                                
                                self.showAlertWithMessage(message: ["code": errorCode!], receipt: receipt, emailId: emailId, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
                            }
                            else {
                                
                                self.nextStepAfterSuccess()
                            }
                        }
                    }
                    else {
                        
                        self.showAlertWithMessage(message: [:], receipt: receipt, emailId: emailId, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
                    }
                }
            }
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
                
                self.nextStepAfterSuccess()
            }
            else if errorCode?.lowercased() == Constants.kIllegalArugmentExceptionFailedErrorCode.lowercased(){
                
                self.nextStepAfterSuccess()
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
                
                self.nextStepAfterSuccess()
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
            //self.nextStepAfterSuccess()
            break
        case 103:
            
            if buttonIndex == 0 {
                
                self.subscriptionReceiptData = nil
                self.emailId = nil
                self.transactionIdentifier = nil
                self.productIdentifier = nil
                
                self.nextStepAfterSuccess()
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
    
    func displayAlertOnSuccess() {
        
        let alertView: UIAlertView = UIAlertView.init(title: Constants.kSuccess, message: Constants.kCreateLoginSuccessMessage, delegate: self, cancelButtonTitle: Constants.kStrOk)
        alertView.tag = 100
        alertView.show()
    }
    
    
    func nextStepAfterSuccess() {
        
        if shouldUserBeNavigatedToHomePage != nil
        {
            if shouldUserBeNavigatedToHomePage!
            {
                Constants.kAPPDELEGATE.navigateToHomeScreen()
            }
            else
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserLoggedInStatusUpdated"), object: nil)
                self.navigationController?.dismiss(animated: true, completion: {
                    
                })
            }
        }
        else
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserLoggedInStatusUpdated"), object: nil)
            self.navigationController?.dismiss(animated: true, completion: {
                
            })
        }
    }

    
    func hideActivityIndicator() {
        
        progressIndicator?.hide(animated: true)
    }
    
    func createModules() -> Void {
        for module:AnyObject in self.modulesListArray {
            
            if module is LoginObject {
                var ii: Int = 0
                for component in (module as! LoginObject).components
                {
                    if component is LoginComponent
                    {
                        let loginFrame: CGRect = CGRect.init(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64)
                        let loginView: SFLoginView = SFLoginView.init(frame: loginFrame, loginObject: component as! LoginComponent, viewTag: ii)
                        loginView.loginViewDelegate = self
                        loginView.paymentModelObject = paymentModelObject
                        self.modulesArray.append(loginView)
                        self.view.addSubview(loginView)
                    }
                    ii = ii+1
                }
            }
        }
        updateViewSelection()
    }
    
    
    func userLoginDone() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserLoggedInStatusUpdated"), object: nil)

        if shouldUserBeNavigatedToHomePage != nil
        {
            if shouldUserBeNavigatedToHomePage!
            {
                Constants.kAPPDELEGATE.navigateToHomeScreen()
            }
            else
            {
                self.navigationController?.dismiss(animated: false, completion: {
                    
                    if self.completionHandlerCopy != nil {
                        
                        self.completionHandlerCopy!(true)
                    }
                })
            }
        }
        else
        {
            self.navigationController?.dismiss(animated: false, completion: {
                
                if self.completionHandlerCopy != nil {
                    
                    self.completionHandlerCopy!(true)
                }
            })
        }
        
        if AppConfiguration.sharedAppConfiguration.urbanAirshipChurnAvailable {
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                UrbanAirshipEvent.sharedInstance.triggerUserAssociationToUrbanAirship()
                UrbanAirshipEvent.sharedInstance.triggerUserLoggedInStateTagToUrbanAirship(isUserLoggedIn: true)
            }
        }
    }
    
    
    func segmentSelectionChanged() -> Void
    {
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.AVOD
        {
            if self.loginPageSelection == 0
            {
                self.loginPageSelection = 1
            }
            else
            {
                self.loginPageSelection = 0
            }
            updateViewSelection()
        }
        else if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
        {
            let planViewController:SFProductListViewController = SFProductListViewController.init()
            let navigationController: UINavigationController = UINavigationController.init(rootViewController: planViewController)
            self.present(navigationController, animated: true, completion: {
                
            })
        }
    }
    
    func updateViewSelection() -> Void {
        
        for module in modulesArray
        {
            if module is SFLoginView
            {
                let selectedTag: Int = (module as! SFLoginView).viewTag!
                if selectedTag == self.loginPageSelection {
                    (module as! SFLoginView).isHidden = false
                }
                else
                {
                    (module as! SFLoginView).isHidden = true
                }
            }
        }
    }
    
    
    func forgotPasswordTapped() -> Void
    {
        let resetPasswordViewController: ResetPasswordViewController = ResetPasswordViewController.init()
        self.navigationController?.pushViewController(resetPasswordViewController, animated: true)
    }
    
    
    func privacyPolicyTapped() {
        
        loadAncillaryController(pageName: "Privacy Policy", pagePath: "/privacy-policy")
    }
    
    
    func termsOfUseTapped() {
        
        loadAncillaryController(pageName: "Terms of Service", pagePath: "/tos")
    }
    
    
    //MARK: Load ancillary page
    func loadAncillaryController(pageName:String, pagePath:String) {
        
        var viewControllerPage:Page?
        let filePath:String = AppSandboxManager.getpageFilePath(fileName: Utility.sharedUtility.getPageIdFromPagesArray(pageName: pageName) ?? "")
        if !filePath.isEmpty {
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                
                viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
            }
        }
        
        if viewControllerPage != nil {
            
            let ancillaryPageViewController:AncillaryPageViewController = AncillaryPageViewController(viewControllerPage: viewControllerPage!)
            ancillaryPageViewController.view.changeFrameYAxis(yAxis: 20.0)
            ancillaryPageViewController.view.changeFrameHeight(height: ancillaryPageViewController.view.frame.height - 20.0)
            ancillaryPageViewController.pagePath = pagePath
            ancillaryPageViewController.pageName = pageName
            self.present(ancillaryPageViewController, animated: true, completion: {
                
            })
        }
    }
}


