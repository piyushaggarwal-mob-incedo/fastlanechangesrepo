//
//  AppDelegate.swift
//  AppCMS_tvOS
//
//  Created by Dheeraj Singh Rathore on 07/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics

enum UserLoginType: String {
    case Email
    case Facebook
    case Gmail
    case SubscribedGuest
    case none
}

enum serviceType: Int {
    case SVOD
    case AVOD
    case TVOD
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,AppConfigManagerDelegate  {
    
    var didMenuRevealMessageShowOnce = false
    var isVersionChanged: Bool = false
    var authorizationTokenTimeStamp:Date?
    var window: UIWindow?
    var loadingViewController : LoadingSplashViewController_tvOS?
    var appContainerVC : AppContainerViewController_tvOS?
    var networkUnavailableAlert : UIAlertController?
    var isAppConfigurationIsProgress : Bool = false
    var isAppConfigured: Bool = false
    /// PopOver controller instance.
    var morePopOver: SFPopOverController?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let appVersion:String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let appBuild:String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    var shouldDisplayAppUpdateView:Bool = true
    lazy var previewEndEnforcer = PreviewEndEnforcer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        URLCache.shared.removeAllCachedResponses()
        //Setting the cookie policy set to AcceptNever so that the cookie is not saved in url request
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        Fabric.with([Crashlytics.self])
        //Setting up Network Reachability Handler.
        NetworkStatus.sharedInstance.startNetworkReachabilityObserver()
        //Adding network change notification observer.
        NotificationCenter.default.addObserver(self, selector:#selector(checkAndRemoveNoNetworkAlert), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        loadingViewController = storyboard.instantiateViewController(withIdentifier: "LoadingSplashViewController_tvOS") as? LoadingSplashViewController_tvOS
        self.window?.rootViewController =  loadingViewController;
        self.window?.makeKeyAndVisible()
        startAppConfiguration()
//        previewEndEnforcer.startAppOnTimeTracking()
        return true
    }
    
    private func startAppConfiguration() {
        if isAppConfigurationIsProgress == false {
            isAppConfigurationIsProgress = true
            let appConfigManager = AppConfigManager.init(appConfigurationDelegate: self)
            appConfigManager.startConfiguringApp()
        }
    }
    
    @objc private func checkAndRemoveNoNetworkAlert() {
        let networkStatus = NetworkStatus.sharedInstance
        if networkStatus.isNetworkAvailable() {
            if let networkAlert = networkUnavailableAlert {
                networkAlert.dismiss(animated: true, completion: {
                })
            }
            if AppConfiguration.sharedAppConfiguration.pages.isEmpty == true {
                startAppConfiguration()
            }
        }
    }
    
    //MARK: Display Network Error Alert
    private func showAlertForNoInternet() {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            self.startAppConfiguration()
        }
        
        var alertTitleString:String?
        var alertMessage:String?
        alertTitleString = Constants.kInternetConnection
        alertMessage = Constants.kInternetConntectionRefresh
        
        networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction, retryAction])
        
        self.window?.rootViewController?.present(networkUnavailableAlert!, animated: true, completion: nil)
    }
    
    //MARK: Google Anaytics setup
    func googleAnalyticsSetup(googleAnalyticsId:String)->Void {
        
        GATrackerTVOS.sharedInstance().setTrackingID(googleAnalyticsId)
        //        GATrackerTVOS.sharedInstance().setTrackingID("UA-102744671-1") //Debug id.
        
        //Application launch Event.
        let version:String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        GATrackerTVOS.sharedInstance().event(withCategory: "Application Started", action: "Application Version", label: version, customParameters: [ "ev" : String(Int(-1)) ])
        GATrackerTVOS.sharedInstance().event(withCategory: "Application Started", action: "OS Version", label: UIDevice.current.systemVersion, customParameters: [ "ev" : String(Int(-1)) ])
        GATrackerTVOS.sharedInstance().screenView("Application Launched", customParameters: [ "ev" : String(Int(-1)) ])
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name(rawValue: "ApplicationWillResignActive"), object: nil)

        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name(rawValue: "ApplicationEnteredBackground"), object: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name(rawValue: "ApplicationEnteredForeground"), object: nil)
        
        //Check for updated configurations in the background.
        if isAppConfigured {
            let appConfigManager = AppConfigManager.init(appConfigurationDelegate: self)
            appConfigManager.downloadConfigFilesInBackground()
        }
        let version = Bundle.main.infoDictionary?["CFBundleVersion"]
        GATrackerTVOS.sharedInstance().event(withCategory: "Application Foreground", action: "Application Version", label: version as? String, customParameters: [ "ev" : String(Int(-1)) ])
        GATrackerTVOS.sharedInstance().event(withCategory: "Application Foreground", action: "OS Version", label: UIDevice.current.systemVersion, customParameters: [ "ev" : String(Int(-1)) ])
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {

        Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name(rawValue: "ApplicationBecameActive"), object: nil)

        if !Utility.sharedUtility.checkIfUserIsLoggedIn() && !Utility.sharedUtility.checkIfUserIsSubscribedGuest() && AppConfiguration.sharedAppConfiguration.apiBaseUrl != nil && AppConfiguration.sharedAppConfiguration.sitename != nil {
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                DataManger.sharedInstance.apiToGetAnonymousToken(success: { (isSuccess) in
                    
                })
            }
        }
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            self.fetchUserSubscriptionStatusFromServer(shouldUpdateIAPReceipt: true)
            
        }
    }
    
    func fetchUserSubscriptionStatusFromServer(shouldUpdateIAPReceipt:Bool, _ completion: (()->())? = nil) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() != NotReachable {
            
            if (Utility.sharedUtility.checkIfUserIsSubscribedGuest() || Utility.sharedUtility.checkIfUserIsLoggedIn()) && AppConfiguration.sharedAppConfiguration.serviceType != nil {
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                        
                        DataManger.sharedInstance.apiToGetUserEntitledStatus(success: { (isSubscribed) in
                            
                            DispatchQueue.main.async {
                                
                                if isSubscribed != nil {
                                    Constants.kSTANDARDUSERDEFAULTS.set(isSubscribed!, forKey: Constants.kIsSubscribedKey)
                                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                                }
                                else {
                                    
                                    let subscriptionStatus:Bool? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool
                                    
                                    if subscriptionStatus != nil {

                                    }
                                    else {
                                        
                                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                                        Constants.kSTANDARDUSERDEFAULTS.synchronize()
                                    }
                                }
                                
                                if shouldUpdateIAPReceipt {
                                    
                                    self.updateIAPReceiptToServer(isSubscribed: isSubscribed ?? false)
                                }
                            }
                            if let _completion = completion {
                                _completion()
                            }
                        })
                    }
                }
            }
        }
    }
    
    //MARK: Update IAP Receipt to server
    private func updateIAPReceiptToServer(isSubscribed:Bool) {
        let transactionInfo:Dictionary<String, Any>? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as? Dictionary<String, Any>
        
        if transactionInfo != nil && isSubscribed == true {
            
            let receiptData:NSData? = transactionInfo?["receiptData"] as? NSData
            
            if receiptData != nil {
                
                self.updateSubscriptionInfoWithReceiptdata(isSubscribed: isSubscribed, receipt: receiptData!, emailId: nil, productIdentifier: nil, transactionIdentifier: nil, success: { (isSuccess) in
                    
                })
            }
        }
    }
    
    /**
     Method to update subscription info with user
     @param receipt transaction receipt
     */
    func updateSubscriptionInfoWithReceiptdata(isSubscribed:Bool, receipt: NSData?, emailId:String?, productIdentifier:String?, transactionIdentifier:String?, success: @escaping ((_ isSuccess:Bool) -> Void))
    {
        let requestParameters:Dictionary<String, Any> = Utility.sharedUtility.getRequestParametersForSubscription(receiptData: receipt, emailId: emailId, paymentModelObject: nil, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
        
        DataManger.sharedInstance.apiToUpdateSubscriptionStatus(requestParameter: requestParameters, requestType: isSubscribed == true ? .put : .post ) { (subscriptionResponse, isSuccess) in
            
            if subscriptionResponse != nil {
                
                if isSuccess {
                    if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) == nil {
                        Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.SubscribedGuest.rawValue, forKey: Constants.kLoginType)
                    }
                    Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                    Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kTransactionInfo)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    
                    success(true)
                }
                else {
                    
                    success(isSuccess)
                }
            }
            else {
                
                success(false)
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        previewEndEnforcer.saveUsageTime()
    }
    
    func appConfigurationCompletedWithSuccess(configurationDone: Bool) -> Void
    {
        isAppConfigurationIsProgress = false
        isAppConfigured = configurationDone
        //Handle the case of no data neither local nor from the server.
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() == NotReachable && configurationDone == false {
            
            showAlertForNoInternet()
            return
        }
        
        //        let currentVersionReleaseDate = Utility.sharedUtility.getCurrentAppVersionDateFromiTunes()
        //
        //        if currentVersionReleaseDate != nil {
        //
        //            Constants.kSTANDARDUSERDEFAULTS.setValue(currentVersionReleaseDate, forKey: "AppVersionReleaseDate")
        //        }
        
        AppConfiguration.sharedAppConfiguration.createAppConfigurationPlist()
        
        let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/sites?domainName=\(AppConfiguration.sharedAppConfiguration.domainName ?? "")"
        
        NetworkHandler.sharedInstance.callNetworkForConfiguration(apiURL: apiEndPoint) { (_ responseConfigData: Data?, isSuccess) in
            if responseConfigData != nil
            {
                let domainContentDict:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with: responseConfigData!) as? Dictionary<String, AnyObject>
                
                let gistDict:Dictionary<String, AnyObject>? = domainContentDict?["gist"] as? Dictionary<String, AnyObject>
                
                if gistDict != nil {
                    
                    let appAccessKeyDict:Dictionary<String, AnyObject>? = gistDict?["appAccess"] as? Dictionary<String, AnyObject>
                    
                    if appAccessKeyDict != nil {
                        
//                        AppConfiguration.sharedAppConfiguration.apiSecretKey = appAccessKeyDict?["appSecretKey"] as? String
                        AppConfiguration.sharedAppConfiguration.apiAccessKey = appAccessKeyDict?["appId"] as? String
                    }
                    
                }
            }
        }
        
        let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!)!
        
        let appSecretKey:String? = dicRoot["AppSecretKey"] as? String
        
        if appSecretKey != nil {
            
            AppConfiguration.sharedAppConfiguration.apiSecretKey = appSecretKey!
        }

        
        if !Utility.sharedUtility.checkIfUserIsLoggedIn() && !Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                DataManger.sharedInstance.apiToGetAnonymousToken(success: { (isSuccess) in
                    
                })
            }
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) == nil {
            Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kAutoPlay)
        }
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            let authorizationToken:String? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) as? String
            let refreshToken:String? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kRefreshToken) as? String
            
            if authorizationToken == nil && refreshToken == nil {
                self.clearUserDefaultSettings()
            }
        }
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            self.fetchUserSubscriptionStatusFromServer(shouldUpdateIAPReceipt: true)
        }
        
        self.createAppPages()
        //Added default GA ID provided by Zhibo
        if AppConfiguration.sharedAppConfiguration.googleAnalyticsId != nil && !(AppConfiguration.sharedAppConfiguration.googleAnalyticsId?.isEmpty)! {
            
            self.googleAnalyticsSetup(googleAnalyticsId: AppConfiguration.sharedAppConfiguration.googleAnalyticsId!)
        }
        else {
            self.googleAnalyticsSetup(googleAnalyticsId: "UA-98825998-2")
        }
        self.animateAppLogoAndNavigateToHomeScreen()
    }
    
    // MARK: - createAppPages parse page's response and fill page object
    func createAppPages() -> Void {
        var ii = 0
        for pageItem in AppConfiguration.sharedAppConfiguration.pages {
            let page: Page = pageItem
            let filePath:String = AppSandboxManager.getpageFilePath(fileName: page.pageName ?? "")
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                
                let pageParser = PageUIParser()
                AppConfiguration.sharedAppConfiguration.pages.remove(at: ii)
                let pageUpdated:Page? = pageParser.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
                pageUpdated?.pageName = page.pageName
                pageUpdated?.pageAPI = page.pageAPI
                pageUpdated?.pageUI = page.pageUI
                pageUpdated?.pageId = page.pageId
                
                AppConfiguration.sharedAppConfiguration.pages.insert(pageUpdated!, at: ii)
                ii = ii+1
            }
        }
    }
    
    func animateAppLogoAndNavigateToHomeScreen() {
        loadingViewController?.triggerAnimation(completionHandler: { (completed) in
            //navigate to home page
            self.navigateToHomeScreen()
        })
    }
    
    func navigateToHomeScreen() {
        //Create app container view which will hold both top menu collection view and top/root level controller.
        if let appContainer = appContainerVC {
            appContainer.removeFromParentViewController()
        }
        appContainerVC = storyboard.instantiateViewController(withIdentifier: "AppContainerViewController_tvOS") as? AppContainerViewController_tvOS
        let navigationController = UINavigationController(rootViewController: appContainerVC!)
        navigationController.isNavigationBarHidden = true
        appContainerVC?.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        UIView.transition(with: self.window!, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            DispatchQueue.main.async {
                self.window?.rootViewController =  navigationController;
            }
        }, completion: { (completed) in })
    }
    
    func clearUserDefaultSettings() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserLoggedInStatusUpdated"), object: nil)
        Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.none.rawValue, forKey: Constants.kLoginType)
        Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kAuthorizationToken)
        Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kRefreshToken)
        Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kAuthorizationTokenTimeStamp)
        Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kUSERID)
        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsAccountLinked)
        Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kAutoPlay)
        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsCCEnabled)
        Constants.kSTANDARDUSERDEFAULTS.removeObject(forKey: "PREVIOUS_SERACH_TERMS")
        
        Constants.kSTANDARDUSERDEFAULTS.synchronize()

        DispatchQueue.global(qos: .userInitiated).async {
            
            DataManger.sharedInstance.apiToGetAnonymousToken(success: { (isSuccess) in
                
            })
        }
    }
}



