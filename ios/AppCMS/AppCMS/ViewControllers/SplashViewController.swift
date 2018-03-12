//
//  SplashViewController.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit
import AppsFlyerLib
import Firebase

class SplashViewController: UIViewController,SFButtonDelegate {

    var viewControllerPage: Page?
    var trayObject:SFTrayObject?
    var viewFrame: CGRect?
    var progressIndicator:MBProgressHUD?

    init () {
        
        super.init(nibName: nil, bundle: nil)
        
        self.initialiseViewControllerPageFromFilePath()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initialiseViewControllerPageFromFilePath() -> Void {
        
        let pageID: String = Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Splash Screen")!
        
        let filePath:String = AppSandboxManager.getpageFilePath(fileName: pageID)
        
        if FileManager.default.fileExists(atPath: filePath){
            let jsonData:Data = FileManager.default.contents(atPath: filePath)!
            
            let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, Any>
            viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson as Dictionary<String, AnyObject>)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "FFFFFF")
        
        self.title = viewControllerPage?.pageName
        
        if viewControllerPage?.modules != nil {
            
            for module:Any in (viewControllerPage?.modules)! {
                
                if module is SFTrayObject {
                    
                    trayObject = module as? SFTrayObject
                }
            }
        }
        
        if trayObject != nil {
            
            for component:Any in (trayObject?.trayComponents)! {
                
                if component is SFButtonObject {
                    
                    createButtonView(buttonObject: component as! SFButtonObject)
                }
                else if component is SFImageObject {
                    
                    createImageView(imageObject: component as! SFImageObject)
                }
                else if component is SFTextViewObject {
                    
                    createSplashScreenTextView(textViewObject: component as! SFTextViewObject)
                }
                else if component is SFSeparatorViewObject {
                    
                    createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
                }
                else if component is SFLabelObject {
                    
                    createLabelView(labelObject: component as! SFLabelObject, containerView: self.view)
                }
            }
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseCompletionNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishRestorePurchase), name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseCompletionNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processRestorePurchaseCompetionCallbackData(notification:)), name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreWithZeroTransaction), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processRestoreWithZeroTransactionCallbackData(notification:)), name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreWithZeroTransaction), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseFailedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restorePurchaseFailed), name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseFailedNotification), object: nil)
        // Do any additional setup after loading the view.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
//            FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [kFIRParameterItemName: self.viewControllerPage?.pageName ?? "SoftWall Screen"])
            FIRAnalytics.setScreenName(self.viewControllerPage?.pageName ?? "SoftWall Screen", screenClass: nil)

        }
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.allowIDFACollection = true
        tracker.set(kGAIScreenName, value: "softwall_view")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createButtonView(buttonObject:SFButtonObject) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
    
        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.relativeViewFrame = self.view.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.buttonDelegate = self
        button.createButtonView()
        if (buttonObject.key == "start trail button") && (AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor != nil)
        {
            button.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor!)
        }
        self.view.addSubview(button)
        
    }
    
    func createLabelView(labelObject:SFLabelObject, containerView:UIView) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        
        label.createLabelView()
        
        label.font = UIFont(name: label.font.fontName, size: label.font.pointSize * Utility.getBaseScreenHeightMultiplier())
        label.text = labelObject.text

        if labelObject.type == "actionLabel"
        {
            if AppConfiguration.sharedAppConfiguration.linkColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.linkColor!)
            }
        }
        else
        {
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
        
        if labelObject.underline != nil && (labelObject.underline)! {
            
            let line = CAShapeLayer()
            let linePath = UIBezierPath()
            linePath.move( to: CGPoint.init(x: (label.frame.width - label.intrinsicContentSize.width)/2, y: (label.frame.maxY -  label.frame.minY - CGFloat(labelObject.underlineWidth!))))
            linePath.addLine(to: CGPoint.init(x: label.intrinsicContentSize.width + (label.frame.width - label.intrinsicContentSize.width)/2, y: (label.frame.maxY - label.frame.minY - CGFloat(labelObject.underlineWidth!))))
            line.path = linePath.cgPath
            line.strokeColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? labelObject.underlineColor ?? "ffffff").cgColor
            line.lineWidth =  CGFloat(labelObject.underlineWidth!)
            line.lineJoin = kCALineJoinRound
            label.layer.addSublayer(line)
        }

        containerView.addSubview(label)
        containerView.bringSubview(toFront: label)
        
        if labelObject.action != nil
        {
            if labelObject.action == "browse"
            {
                let selectorTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.browseApp(tapGesture:)))
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(selectorTapGesture)
            }
            else if labelObject.action == "restorePurchase"
            {
                let selectorTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.restorePruchase(tapGesture:)))
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(selectorTapGesture)
            }
        }
    }
    
    
    func createImageView(imageObject:SFImageObject) -> Void {
        
        let imageView:SFImageView = SFImageView()
        imageView.imageViewObject = imageObject
        imageView.relativeViewFrame = self.view.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
        imageView.updateView()
        self.view.addSubview(imageView)
        
        if imageObject.action == "backgroundImage" {
            
            self.view.sendSubview(toBack: imageView)
        }
    }
    
    func createSplashScreenTextView(textViewObject:SFTextViewObject) -> Void {
        
        let textViewLayout = Utility.fetchTextViewLayoutDetails(textViewObject: textViewObject)
        
        let textView:SFTextView = SFTextView()
        textView.relativeViewFrame = self.view.frame
        textView.textViewObject = textViewObject
        textView.textViewLayout = textViewLayout
        textView.initialiseTextViewFrameFromLayout(textViewLayout: textViewLayout)
        textView.isSelectable = false
        textView.updateView()
        textView.text = textViewObject.text
        
        self.view.addSubview(textView)
    }
    
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) -> Void {
        
        let separatorViewLayout = Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject)
        
        let separatorView:SFSeparatorView = SFSeparatorView()
        separatorView.relativeViewFrame = self.view.frame
        
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: separatorViewLayout)
        self.view.addSubview(separatorView)
    }
    
    
    func buttonClicked(button: SFButton) {
        
        let buttonAction:String = button.buttonObject?.action ?? ""
        if(buttonAction == "signIn")
        {
            openLoginView()
        }
        else if (buttonAction == "startTrial")
        {
            openPlanPage()
        }
    }
    
    
    func openLoginView() -> Void
    {
        let loginViewController: LoginViewController = LoginViewController.init()
        loginViewController.loginType = loginPageType.authentication
        loginViewController.loginPageSelection = 0
        loginViewController.pageScreenName = "Sign In Screen"
        loginViewController.shouldUserBeNavigatedToHomePage = true
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: loginViewController)
        self.present(navigationController, animated: true, completion: {
            
        })
    }
    
    func openPlanPage() -> Void
    {
        let planViewController:SFProductListViewController = SFProductListViewController.init()
        planViewController.shouldUserBeNavigatedToHomePage = true
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: planViewController)
        self.present(navigationController, animated: true, completion: {
            
        })
    }
    
    
    func browseApp(tapGesture: UITapGestureRecognizer) -> Void
    {
        Constants.kAPPDELEGATE.createTabBar()
    }
    
    
    func restorePruchase(tapGesture: UITapGestureRecognizer) -> Void
    {
        self.showActivityIndicator(loaderText: "Restoring your purchase")
        SFStoreKitManager.sharedStoreKitManager.isProductPurchased = false
        SFStoreKitManager.sharedStoreKitManager.restorePreviousTransaction()
    }
    
    
    func finishRestorePurchase() {
        
        //self.hideActivityIndicator()
    }
    
    
    /**
     Method to handle restore purchase failure
     */
    func restorePurchaseFailed() {
        
        self.hideActivityIndicator()
        
        let okAction = UIAlertAction(title: Constants.kStrOk, style: .default) { (okAction) in
            
        }
        
        let failedRestorePurchaseAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kRestorePurchaseFailureTitle, alertMessage: Constants.kRestorePurchaseFailureMessage, alertActions: [okAction])
        self.present(failedRestorePurchaseAlert, animated: true, completion: nil)
    }
    
    
    /**
     Method to handle restore purchase compeletion callback
     
     @param notification transaction details
     */
    func processRestorePurchaseCompetionCallbackData(notification:NSNotification) {
        
        let userInfoDict:Dictionary<String, Any> = notification.userInfo as! Dictionary<String, Any>

        DispatchQueue.main.async {
            
            Constants.kSTANDARDUSERDEFAULTS.setValue(userInfoDict, forKey: Constants.kTransactionInfo)
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
            
            self.getUserStatusFromTransactionId()
        }
    }
    
    
    /**
     Method to handle restore purchase with no transaction compeletion callback
     
     @param notification
     */
    func processRestoreWithZeroTransactionCallbackData(notification:NSNotification) {
        
        self.hideActivityIndicator()
        
        let okAction:UIAlertAction = UIAlertAction(title: Constants.kStrOk, style: .default) { (okAction) in
            
        }
        
        let restorePurchaseErrorAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.RESTORE_NO_PRODUCT_TITLE, alertMessage: Constants.RESTORE_NO_PRODUCT_MESSAGE, alertActions: [okAction])
        self.present(restorePurchaseErrorAlert, animated: true, completion: nil)
    }
    
    
    /**
     Method to get user status from transaction id
     */
    func getUserStatusFromTransactionId() {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            showAlertForAlertType(alertType: .AlertTypeNoInternetFound, alertMessage: nil, alertTitle: nil)
        }
        else {
            
            let userInfo:Dictionary<String, Any> = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as! Dictionary<String, Any>
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                let receiptData:NSData? = userInfo["receiptData"] as? NSData
                
                var receiptString:String?
                if receiptData != nil {
                    
                    receiptString = (receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)))!
                }
                else {
                    
                    let receiptURL = Bundle.main.appStoreReceiptURL
                    
                    if receiptURL != nil {
                        
                        let receipt:NSData? = NSData(contentsOf:receiptURL!)
                        
                        if receipt != nil {
                            
                            receiptString = (receipt?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)))!
                        }
                    }
                }
                
                let requestParameter = ["paymentUniqueId":"\(userInfo["transactionId"] ?? "")", "site":"\(AppConfiguration.sharedAppConfiguration.sitename ?? "")", "receipt" : receiptString ?? ""]
                
                DataManger.sharedInstance.apiToGetUserIdFromTransactionId(requestParameter: requestParameter, success: { (userStatusDict, isSuccess) in
                    
                    DispatchQueue.main.async {
                        
                        if userStatusDict != nil && isSuccess {
                            
                            let refreshToken:String? = userStatusDict?["refreshToken"] as? String
                            let authorizationToken: String? = userStatusDict?["authorizationToken"] as? String
                            let id:String? = userStatusDict?["userId"] as? String
                            let email:String? = userStatusDict?["email"] as? String
                            let signInProvider:String? = userStatusDict?["provider"] as? String
                            let isSubscribed:Bool? = userStatusDict?["isSubscribed"] as? Bool
                            
                            if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                
                                FIRAnalytics.setUserID(id)
                            }
                            
                            if authorizationToken != nil && refreshToken != nil
                            {
                                Constants.kSTANDARDUSERDEFAULTS.setValue(refreshToken, forKey: Constants.kRefreshToken)
                                Constants.kSTANDARDUSERDEFAULTS.setValue(authorizationToken!, forKey: Constants.kAuthorizationToken)
                                Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kAuthorizationTokenTimeStamp)
                                Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                            }
                            
                            if id != nil {
                                
                                Constants.kSTANDARDUSERDEFAULTS.setValue(id, forKey: Constants.kUSERID)
                                AppsFlyerTracker.shared().customerUserID = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as? String ?? ""
                            }
                            
                            Constants.kSTANDARDUSERDEFAULTS.synchronize()
                            
                            self.performAfterRestoreAPI(receipt: receiptData, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String, refreshToken: refreshToken, authorizationToken: authorizationToken, userId: id, emailId: email, signInProvider: signInProvider, isSubscribed: isSubscribed)
                            //self.checkUserNavigationToScreen(emailId: email, signInProvider: signInProvider)
                        }
                        else {
                            
                            self.hideActivityIndicator()
                            self.presentCreateLoginPage()
                        }
                    }
                })
            }
        }
    }
    
    
    func performAfterRestoreAPI(receipt: NSData?, productIdentifier:String?, transactionIdentifier:String?, refreshToken:String?, authorizationToken:String?, userId:String?, emailId:String?, signInProvider:String?, isSubscribed:Bool?) {
        
        if let subscriptionStatus = isSubscribed {
            
            if !subscriptionStatus {
                
                DispatchQueue.global(qos: .userInitiated).async {
                 
                    self.updateSubscriptionInfoWithReceiptdataAfterRestorePurchaseAPI(receipt: receipt, emailId: emailId, signInProvider: signInProvider,productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier, success: { (isSuccess) in
                        
                        DispatchQueue.main.async {
                            
                            self.hideActivityIndicator()
                            
                            if isSuccess == true {
                                
                                self.checkUserNavigationToScreen(emailId: emailId, signInProvider: signInProvider)
                            }
                        }
                    })
                }
            }
            else {
                
                self.hideActivityIndicator()
                self.checkUserNavigationToScreen(emailId: emailId, signInProvider: signInProvider)
            }
        }
        else {
            
            self.hideActivityIndicator()
            self.checkUserNavigationToScreen(emailId: emailId, signInProvider: signInProvider)
        }
    }
    
    /**
     Method to update subscription info with user
     @param receipt transaction receipt
     */
    func updateSubscriptionInfoWithReceiptdataAfterRestorePurchaseAPI(receipt: NSData?, emailId:String?, signInProvider:String?, productIdentifier:String?, transactionIdentifier:String?, success: @escaping ((_ isSuccess:Bool) -> Void))
    {
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator(loaderText: nil)
        
        let requestParameters:Dictionary<String, Any> = Utility.sharedUtility.getRequestParametersForSubscription(receiptData: receipt, emailId: emailId, paymentModelObject: nil, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
        DataManger.sharedInstance.apiToUpdateSubscriptionStatus(requestParameter: requestParameters, requestType: .post) { (subscriptionResponse, isSuccess) in
            
            self.view.isUserInteractionEnabled = true
            self.hideActivityIndicator()
            
            if subscriptionResponse != nil {
                
                if isSuccess {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kTransactionInfo)
                    Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    Constants.kAPPDELEGATE.removePlistFromDocumentDirectory(plistName: Constants.kTransactionDetailPlistName)
                    success(true)
                }
                else {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    
                    let errorCode:String? = subscriptionResponse?["code"] as? String
                    
                    if errorCode != nil {
                        self.showAlertWithMessage(message: ["code": errorCode!], emailId: emailId, signInProvider: signInProvider)
                    }
                    
                    success(false)
                }
            }
            else {
                
                success(false)
            }
        }
    }
    
    func checkUserNavigationToScreen(emailId:String?, signInProvider:String?) {
        
        NotificationCenter.default.removeObserver(self)
        if emailId != nil {
            
            if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                
                Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMLoggedInPropertyValue, userPropertyKeyName: Constants.kGTMLoggedInProperty)
            }
            
            if signInProvider != nil {
                
                if signInProvider!.lowercased() == "facebook" {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Facebook.rawValue, forKey: Constants.kLoginType)
                }
                else if signInProvider!.lowercased() == "google" || signInProvider!.lowercased() == "gmail" || signInProvider!.lowercased() == "googleplus" {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Gmail.rawValue, forKey: Constants.kLoginType)
                }
                else {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Email.rawValue, forKey: Constants.kLoginType)
                }
            }
            else {
                
                Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Email.rawValue, forKey: Constants.kLoginType)
            }
            
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
            Constants.kAPPDELEGATE.navigateToHomeScreen()
        }
        else {
            
            Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.SubscribedGuest.rawValue, forKey: Constants.kLoginType)
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
            self.displayAlertForSubscribedGuestUser()
        }
    }
    
    
    func displayAlertForSubscribedGuestUser() {
        
        let createAccountAction = UIAlertAction(title: Constants.kCreateAccountTitle, style: .default) { (createAccountAction) in
            
            self.presentCreateLoginPage()
        }
        
        let skipCreateAccountAction = UIAlertAction(title: Constants.kSkipCreateAccountTitle, style: .default) { (skipCreateAccountAction) in
            
            Constants.kAPPDELEGATE.navigateToHomeScreen()
        }
        
        let accountCreationAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kRestoreSuccessTitle, alertMessage: Constants.kRestoreSuccessMessageForNonLinkedAccount, alertActions: [createAccountAction, skipCreateAccountAction])
        
        self.present(accountCreationAlert, animated: true, completion: nil)
    }
    
    
    /**
     Method to present create your account screen
     */
    func presentCreateLoginPage()
    {
        NotificationCenter.default.removeObserver(self)
        let loginViewController: LoginViewController = LoginViewController.init()
        loginViewController.loginPageSelection = 0
        loginViewController.pageScreenName = "Sign Up Screen"
        loginViewController.loginType = .createLogin
        loginViewController.paymentModelObject = nil
        loginViewController.shouldUserBeNavigatedToHomePage = true
        loginViewController.navigationController?.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if UIApplication.shared.statusBarOrientation.isLandscape && !Constants.IPHONE
        {
            viewFrame = CGRect.init(x: 0, y: 0, width: 768, height: 1024)
        }
        else
        {
            viewFrame = CGRect.init(x: 0, y: 0, width: 1024, height: 768)
        }
        
        if !Constants.IPHONE {
        
            for subview:Any in self.view.subviews {
                
                if subview is SFButton {
                    
                    updateButtonViewFrame(button: subview as! SFButton)
                }
                else if subview is SFLabel{
                    updateLabelViewFrame(label: subview as! SFLabel)
                }
                else if subview is SFTextView {
                    
                    let textView:SFTextView = subview as! SFTextView
                    let textViewLayout = Utility.fetchTextViewLayoutDetails(textViewObject: textView.textViewObject!)
                    textView.relativeViewFrame = UIScreen.main.bounds
                    textView.initialiseTextViewFrameFromLayout(textViewLayout: textViewLayout)
                }
                else if subview is SFImageView {
                    
                    let imageView:SFImageView = subview as! SFImageView
                    imageView.relativeViewFrame = UIScreen.main.bounds
                    imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageView.imageViewObject!))
                }
            }
        }
    }
    
    
    //MARK: Update Video Description Subviews
    func updateLabelViewFrame(label:SFLabel) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!)
        label.labelLayout = labelLayout
        label.relativeViewFrame = viewFrame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
    }
    
    func updateButtonViewFrame(button:SFButton) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: button.buttonObject!)
        
        button.relativeViewFrame = viewFrame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
    }
    
    
    //MARK: Show/Hide Activity Indicator
    private func showActivityIndicator(loaderText:String?) {
        
        progressIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        if loaderText != nil {
            
            progressIndicator?.mode = .indeterminate
            progressIndicator?.label.text = loaderText!
        }
    }
    
    private func hideActivityIndicator() {
        
        progressIndicator?.hide(animated: true)
    }
    
    
    //MARK: Display Network Error Alert
    private func showAlertForAlertType(alertType: AlertType, alertMessage:String?, alertTitle:String?) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
            }
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                self.getUserStatusFromTransactionId()
            }
        }
        
        var alertTitleString:String? = alertTitle
        var alertMessageString:String? = alertMessage
        
        if alertType == .AlertTypeNoInternetFound {
            
            if alertTitleString == nil {
                
                alertTitleString = Constants.kInternetConnection
            }
            
            if alertMessageString == nil {
                
                alertMessageString = Constants.kInternetConntectionRefresh
            }
        }
        else {
            
            if alertTitleString == nil {
                
                alertTitleString = Constants.kNoResponseErrorTitle
            }
            
            if alertMessageString == nil {
                
                alertMessageString = Constants.kSubscriptionNoResponseErrorMessage
            }
        }
        
        let networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction, retryAction])
        self.present(networkUnavailableAlert, animated: true, completion: nil)
    }

    /**
     Method to show the popup
     
     @param message popUp informations
     */
    private func showAlertWithMessage(message: Dictionary<String, Any>, emailId:String?, signInProvider:String?)
    {
        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kStrUserSubscribed)
        Constants.kSTANDARDUSERDEFAULTS.synchronize()
        
        let okAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrOk, style: .default) { (result : UIAlertAction) in
            
            self.hideActivityIndicator()
            self.checkUserNavigationToScreen(emailId: emailId, signInProvider: signInProvider)
        }
        
        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
            
            self.hideActivityIndicator()
        }
        
        let errorCode:String = message[Constants.PAYMENT_NOTIFICATION_CODE_KEY] as! String
        
        if (errorCode.lowercased() == Constants.kPaymentFailedCode.lowercased() || errorCode.lowercased() == Constants.kSubscriptionServiceFailedErrorCode.lowercased()) {
            DispatchQueue.main.async {
                let paymentAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "Payment Failed!", alertMessage: "The payment process did not complete/failed.\nTap OK to continue.\nTap Try Again to try again!", alertActions: [okAction, cancelAction])
                self.present(paymentAlert, animated: true, completion: nil)
            }
        } else if (errorCode.lowercased() == Constants.kDuplicateUserErrorCode.lowercased()) {
            
            DispatchQueue.main.async {
                let paymentAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "Payment Failed!", alertMessage: "You may have another account associated with the entered Apple Id. Kindly log in with that \(Bundle.main.infoDictionary?["CFBundleDisplayName"] ?? "") account.\nTap OK to continue.\nTap Try Again to try again!", alertActions: [okAction, cancelAction])
                self.present(paymentAlert, animated: true, completion: nil)
            }
        }
        else if errorCode.lowercased() == Constants.kUserNotFoundInSubscripionFailedErrorCode.lowercased() {
            
            DispatchQueue.main.async {
                
                self.hideActivityIndicator()
                self.presentCreateLoginPage()
            }
        }
        else if errorCode.lowercased() == Constants.kIllegalArugmentExceptionFailedErrorCode.lowercased(){
            
            self.hideActivityIndicator()
            self.checkUserNavigationToScreen(emailId: emailId, signInProvider: signInProvider)
        }
        else {
            
            DispatchQueue.main.async {
                let paymentAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "Payment Failed!", alertMessage: "The payment process got failed.\nTap Retry to try again!", alertActions: [cancelAction, cancelAction])
                self.present(paymentAlert, animated: true, completion: nil)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
