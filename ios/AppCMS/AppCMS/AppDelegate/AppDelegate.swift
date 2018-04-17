//
//  AppDelegate.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 17/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import DrawerController
import MagicalRecord
import Apptentive
import AirshipKit
import Fabric
import Crashlytics
import FBSDKCoreKit
import AppsFlyerLib
import Firebase
import StoreKit
import KMSDK

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

class AppDelegate: UIResponder, UIApplicationDelegate, AppConfigManagerDelegate, UAPushNotificationDelegate, UARegistrationDelegate {
    
    var window: UIWindow?
    var loadingViewController:LoadingViewController = LoadingViewController()
    var drawerController: DrawerController?
    var tabBar: TabBarViewController?
    var isVersionChanged: Bool = false
    var userLoginType:UserLoginType?
    var deepLinkUrl: URL?
    var alreadyNavigated: Bool?
    var isAutoPlayPopUpVisible: Bool = false
    var isCastingViewVisible: Bool = false
    var isBackgroundImageVisible: Bool = false
    var isAppConfigured: Bool = false
    var isPushNotificationToBeOpened: Bool = false
    var isUserEntitled:Bool = false
    var isKisweEnable:Bool = false
    var isPlayMovieOnLandscapeOnly:Bool = true
    var appUpdateView:SFAppUpdateView?
    var shouldDisplayAppUpdateView:Bool = true
    var isFullScreenEnabled:Bool = false
    var isStatusUpdateAPIInProgress = false

    lazy var previewEndEnforcer = PreviewEndEnforcer()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!)!
        
        if #available(iOS 11.0, *) {
            if ((self.window?.safeAreaInsets.top)! > CGFloat(0.0)){
                Utility.sharedUtility.isDeviceIphoneX = true
            }
        }

        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            self.fetchUserDefaultsFromPlist()
            self.fetchTransactionDetailsFromPlist()
        }
        self.kisweSdkConfiguration(dicRoot: dicRoot)
        NetworkStatus.sharedInstance.startNetworkReachabilityObserver()
        Fabric.with([Crashlytics.self])
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        pushNotificationConfiguration()
        setCoreDataSetup()
        startDeviceScan()
        
        apptentiveConfiguration(dicRoot: dicRoot)
        appsflyerConfiguration(dicRoot: dicRoot)
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) == nil
        {
            Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kAutoPlay)
        }
        
        let appConfigManager = AppConfigManager.init(appConfigurationDelegate: self)
        appConfigManager.startConfiguringApp()

        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kCellularDownload) == nil
        {
            Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kCellularDownload)
        }
        
        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.RESUME_DOWNLOAD)
        Constants.kSTANDARDUSERDEFAULTS.synchronize()
        //Setting the cookie policy set to AcceptNever so that the cookie is not saved in url request
        //HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        
        self.fetchDownloadItemsAndUpdateThePaths()
        self.floodLightConfiguration(dicRoot: dicRoot)
        
        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: "isContentWarningForcefullyDismissed")
        Constants.kSTANDARDUSERDEFAULTS.synchronize()
        
//        HTTPCookieStorage.shared.removeCookies(since: Date())

        return true
    }

    
    //MARK: Method for kiswe configuration
    private func kisweSdkConfiguration(dicRoot:NSDictionary) {
        
        if let isKisweRequired:Bool = dicRoot["isKisweRequired"] as? Bool {
            if(isKisweRequired){
                isKisweEnable = true
                KMSDK.shared.setAPIToken("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJLaXN3ZSIsInN1YiI6MTM5MDk5LCJleHAiOiIyMDMwLTAzLTE0VDAwOjAwOjAwLjAwMFoifQ.ZAvxOdEAW-h7JtCOy6JJTL78EqRxu8Y5LYKLMv7-fh4")
            }
        }
    }
    
    
    //MARK: Method for push notification configuration
    private func pushNotificationConfiguration() {
        
        let config:UAConfig = UAConfig.default()
        UAirship.takeOff(config)
        UAirship.push().resetBadge()
        UAirship.push().notificationOptions = [UANotificationOptions.alert, UANotificationOptions.badge, UANotificationOptions.sound]
        UAirship.push().userPushNotificationsEnabled = true
        UAirship.push().pushNotificationDelegate = self
        UAirship.push().registrationDelegate = self
    }
    
    
    //MARK: Method for apptentive configuration
    private func apptentiveConfiguration(dicRoot:NSDictionary) {
        
        let apptentiveAppKey:String? = dicRoot["Apptentive AppKey"] as? String
        let apptentiveSignature:String? = dicRoot["Apptentive AppSignature"] as? String
        let apptentiveAppId:String? = dicRoot["Apptentive AppId"] as? String
        
        if apptentiveAppKey != nil && apptentiveSignature != nil {
            
            if let configuration = ApptentiveConfiguration(apptentiveKey: apptentiveAppKey!, apptentiveSignature: apptentiveSignature!) {
                
                if apptentiveAppId != nil {
                    
                    configuration.appID = apptentiveAppId!
                    Apptentive.register(with: configuration)
                }
            }
        }
    }
    
    
    //MARK: Method for appsflyer configuration
    private func appsflyerConfiguration(dicRoot:NSDictionary) {
        
        let appsflyerkey:String? = dicRoot["AppFlyer Key"] as? String
        
        if appsflyerkey != nil {
            
            AppsFlyerTracker.shared().appsFlyerDevKey = appsflyerkey
            
        }
        
        let appsflyerAppid:String? = dicRoot["AppFlyer APPID"] as? String
        
        if appsflyerAppid != nil {
            
            AppsFlyerTracker.shared().appleAppID = appsflyerAppid
        }
    }
    
    
    //MARK: Method for floodlight configuration
    private func floodLightConfiguration(dicRoot:NSDictionary) {
        
        let isFloodLightAPICalledForFirstLaunch: Bool = (Constants.kSTANDARDUSERDEFAULTS.value(forKey:  Constants.kisFloodLightAPICalledForFirstLaunch) != nil)
        
        if let isFloodLightRequired:Bool = dicRoot["isFloodLightRequired"] as? Bool {
            
            if !isFloodLightAPICalledForFirstLaunch && isFloodLightRequired {
                
                self.floodLightTagAPICall()
            }
        }
    }
    
    
    //MARK: Method for FloodLight API Call
    private func floodLightTagAPICall() -> Void {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() != NotReachable {
            
            NetworkHandler.sharedInstance.floodLightAPICallWithSuccess { (_ isSuccess:Bool) in
                
                if(isSuccess)
                {
                    Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kisFloodLightAPICalledForFirstLaunch)
                }
            }
        }
    }
    
    
    //Delegate for iOS 8 or below
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if sourceApplication != nil {
            
            let query = url.absoluteString.removingPercentEncoding
            let targetURL = URL(string: query!)
            alreadyNavigated = false
            
            if (query?.contains("facebook"))! {
                
                let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                                          open: url,
                                                                                          sourceApplication: sourceApplication,
                                                                                          annotation: annotation)
                return handled
            }
            else if (query?.contains("google"))!
            {
                let handled: Bool = GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
                return handled
            }
            else if targetURL != nil
            {
                getDeepLInkData(for: targetURL!)
                return false
            }
            else
            {
                return false
            }
        }
        
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if #available(iOS 9.0, *) {
            
            guard let sourceApplication: String = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String else { return false }
            
            let query = url.absoluteString.removingPercentEncoding
            let targetURL = URL(string: query!)
            alreadyNavigated = false

            if (query?.contains("facebook"))! {
                
                let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(app,
                                                                                          open: url,
                                                                                          sourceApplication: sourceApplication,
                                                                                          annotation: options[UIApplicationOpenURLOptionsKey.annotation])
                return handled
            }
            else if (query?.contains("google"))!
            {
                let handled: Bool = GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
                return handled
            }
            else if targetURL != nil
            {
                getDeepLInkData(for: targetURL!)
                return false
            }
            else
            {
                return false
            }
            
            
        } else {
            
            return false
            // Fallback on earlier versions
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            
            let url = userActivity.webpageURL
            
            if url != nil {
                
                getDeepLInkData(for: url!)
            }
        }
        return true
    }
    
    func check(forNetwork notification: Notification) {
        check(forInternetConnection: true)
    }
    
    func check(forInternetConnection isReachabilityChanged: Bool) {
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() != NotReachable {
            
            updateTheServerWithTheDownloadedDataWatchedPercentage()
            self.resumeDowloadingObject()
            self.startSyncBeaconEvents()
            
            if isAppConfigured {
                let appConfigManager = AppConfigManager.init(appConfigurationDelegate: self)
                appConfigManager.downloadConfigFilesInBackground()
            }
        }
        else
        {
            Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.RESUME_DOWNLOAD)
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
        }
    }
    
    private
    func startDeviceScan() {
        SecondScreenDeviceProvider.shared.startDeviceScan()
    }
    
    func appConfigurationCompletedWithSuccess(configurationDone: Bool) -> Void
    {
        isAppConfigured = true
        AppConfiguration.sharedAppConfiguration.createAppConfigurationPlist()
        self.fetchAppDomainConfiguration()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if Constants.IPHONE {
            
            var supportedOrientationsArray: UIInterfaceOrientationMask = UIInterfaceOrientationMask.portrait
            
            let viewControllers = UIApplication.shared.delegate?.window??.rootViewController?.childViewControllers
            if viewControllers != nil
            {
                for viewController in viewControllers! {
                    
                    if viewController is SFMorePopUpViewController {
                        
                        return [.portrait]
                    }
                    guard let viewCont: UIViewController = (viewController as! UINavigationController).visibleViewController else { return supportedOrientationsArray }
                    if isFullScreenEnabled == true {
//                        if (self.isPlayMovieOnLandscapeOnly == true){
//                            supportedOrientationsArray = [ .landscapeLeft, .landscapeRight]
//                        }
//                        else{
                            supportedOrientationsArray = [.portrait, .landscapeLeft, .landscapeRight]
//                        }
                    }
                    if(isAutoPlayPopUpVisible || isCastingViewVisible || isBackgroundImageVisible)
                    {
                        return [.portrait]
                    }
                    if (viewCont is KisweBaseViewController || viewCont.presentedViewController is KisweBaseViewController){
                        supportedOrientationsArray = [.portrait, .landscapeLeft, .landscapeRight]
                    }
                    else if  (viewCont is CustomVideoController || viewCont.presentedViewController is CustomVideoController ) {
                        if (self.isPlayMovieOnLandscapeOnly == true){
                            supportedOrientationsArray = [ .landscapeLeft, .landscapeRight]
                        }
                        else{
                            supportedOrientationsArray = [.portrait, .landscapeLeft, .landscapeRight]
                        }
                        
                    }
                    else if viewCont is AncillaryPageViewController || viewCont.presentedViewController is AncillaryPageViewController || viewCont is DownloadViewController || viewCont.presentedViewController is DownloadViewController
                    {
                        let newViewController = (viewCont as UIViewController).presentedViewController
                        
                        if newViewController is KisweBaseViewController || newViewController?.presentedViewController is KisweBaseViewController{
                            supportedOrientationsArray = [.portrait, .landscapeLeft, .landscapeRight]
                        }
                        else if newViewController is CustomVideoController || newViewController?.presentedViewController is CustomVideoController  {
                            if (self.isPlayMovieOnLandscapeOnly == true ){
                                supportedOrientationsArray = [ .landscapeLeft, .landscapeRight]
                            }
                            else{
                                supportedOrientationsArray = [.portrait, .landscapeLeft, .landscapeRight]
                            }
                        }
                    }
                }
            }
            return supportedOrientationsArray
        }
        else {
            
            return [.portrait, .landscapeLeft, .landscapeRight]
        }
    }
    
    
    func application(_ application: UIApplication, didChangeStatusBarOrientation oldStatusBarOrientation: UIInterfaceOrientation) {
        
        self.updateAppUpdateViewFrameOnOrientationChange()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        self.updateOrCreatePlist()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        DownloadManager.sharedInstance.updateDocumentsDirectoryPathForTheDownloadedItems()
        
        Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name(rawValue: "ApplicationEnteredBackground"), object: nil)
        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.RESUME_DOWNLOAD)
        Constants.kSTANDARDUSERDEFAULTS.synchronize()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
        UAirship.push().resetBadge()
        Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name(rawValue: "ApplicationEnteredForeground"), object: nil)
        
        if isAppConfigured {
            let appConfigManager = AppConfigManager.init(appConfigurationDelegate: self)
            appConfigManager.downloadConfigFilesInBackground()
        }
        let version = Bundle.main.infoDictionary?["CFBundleVersion"]
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        
        tracker.allowIDFACollection = true
        tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Application Foreground", action: "Application Version", label: version as? String ?? "1.0", value: NSNumber(value: -1)).build() as! [AnyHashable : Any]!)
        tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Application Foreground", action: "OS Version", label: UIDevice.current.systemVersion, value: NSNumber(value: -1)).build() as! [AnyHashable : Any]!)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        NotificationCenter.default.addObserver(self, selector:#selector(check(forNetwork:)), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)

        if !Utility.sharedUtility.checkIfUserIsLoggedIn() && !Utility.sharedUtility.checkIfUserIsSubscribedGuest() && AppConfiguration.sharedAppConfiguration.apiBaseUrl != nil && AppConfiguration.sharedAppConfiguration.sitename != nil {
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                DataManger.sharedInstance.apiToGetAnonymousToken(success: { (isSuccess) in
                    
                })
            }
        }
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            self.fetchUserSubscriptionStatusFromServer(shouldUpdateIAPReceipt: true)

            AppsFlyerTracker.shared().customerUserID = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as? String ?? ""
            AppsFlyerTracker.shared().trackAppLaunch()
            
            if  Constants.kSTANDARDUSERDEFAULTS.bool(forKey: Constants.kIsSubscribedKey) == true
            {
                AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_APPOPEN, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "true"])
            }
            else
            {
                AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_APPOPEN, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "" , Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "false"])
            }
        }
        else
        {
            AppsFlyerTracker.shared().customerUserID=""
            AppsFlyerTracker.shared().trackAppLaunch()
            AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_APPOPEN, withValues: nil)
        }
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
//        HTTPCookieStorage.shared.removeCookies(since: Date())
        previewEndEnforcer.saveUsageTime()
        self.updateOrCreatePlist()
        DownloadManager.sharedInstance.pauseDownloadingObject(isForcePaused: false)
        DownloadManager.sharedInstance.updateDocumentsDirectoryPathForTheDownloadedItems()
        UAirship.push().resetBadge()
        if CastPopOverView.shared.isConnected(){
            CastPopOverView.shared.deviceDisconnected()
        }
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UAAppIntegration.application(UIApplication.shared, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        AppsFlyerTracker.shared().registerUninstall(deviceToken)
        AppsFlyerTracker.shared().useUninstallSandbox=false
        Apptentive.shared.setPushProvider(.urbanAirship, deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        UAAppIntegration.application(UIApplication.shared, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        UAAppIntegration.application(application, didRegister: notificationSettings)
    }
    
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        print("Recived: \(userInfo)")
        
    }
	
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        UAAppIntegration.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        let handledByApptentive = Apptentive.shared.didReceiveRemoteNotification(userInfo, from: (self.window?.rootViewController)!, fetchCompletionHandler: completionHandler)

        if !handledByApptentive {
            // handle non-Apptentive push notification if needed
            completionHandler(.noData)
        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        if let actionIdentifier = identifier {
            UAAppIntegration.application(application, handleActionWithIdentifier: actionIdentifier, forRemoteNotification: userInfo, completionHandler: completionHandler)
        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        if let actionIdentifier = identifier {
            UAAppIntegration.application(application, handleActionWithIdentifier: actionIdentifier, forRemoteNotification: userInfo, withResponseInfo: responseInfo, completionHandler: completionHandler)
        }
    }
    
    /**
     * Called when a notification is received in the foreground.
     *
     * @param notificationContent UANotificationContent object representing the notification info.
     *
     * @param completionHandler the completion handler to execute when notification processing is complete.
     */
    func receivedForegroundNotification(_ notificationContent: UANotificationContent, completionHandler: @escaping () -> Void) {
        remoteNotificationRecievedWith(userInfo: notificationContent.notificationInfo as! Dictionary<String, Any>, isAppInForground: true)
    }
    
    /**
     * Called when a notification is received in the background or foreground and results in a user interaction.
     * User interactions can include launching the application from the push, or using an interactive control on the notification interface
     * such as a button or text field.
     *
     * @param notificationResponse UANotificationResponse object representing the user's response
     * to the notification and the associated notification contents.
     *
     * @param completionHandler the completion handler to execute when processing the user's response has completed.
     */
    func receivedNotificationResponse(_ notificationResponse: UANotificationResponse, completionHandler: @escaping () -> Void) {
        remoteNotificationRecievedWith(userInfo: notificationResponse.notificationContent.notificationInfo as! Dictionary<String, Any>, isAppInForground: false)

    }
    
    /**
     * Called when a notification is received in the background.
     *
     * @param notificationContent UANotificationContent object representing the notification info.
     *
     * @param completionHandler the completion handler to execute when notification processing is complete.
     */
    func receivedBackgroundNotification(_ notificationContent: UANotificationContent, completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        remoteNotificationRecievedWith(userInfo: notificationContent.notificationInfo as! Dictionary<String, Any>, isAppInForground: false)

    }
    
    
    func remoteNotificationRecievedWith(userInfo: Dictionary<String, Any>, isAppInForground: Bool) -> Void {
        
        var deepLink: URL?
        for info in userInfo
        {
            if info.key == "^d"
            {
                let notificationResponse: String = info.value as! String
                
                var notificationStringArray: Array = notificationResponse.components(separatedBy: ".")
                
                if notificationStringArray.count > 0
                {
                    notificationStringArray.remove(at: 0)
                }
                
                var deeplinkString: String = ""
                var ii: Int = 0
                for notifString in notificationStringArray
                {
                    deeplinkString.append(notifString)
                    if ii != notificationStringArray.count - 1
                    {
                        deeplinkString.append(".")
                    }
                    ii = ii + 1
                }
                
                if deeplinkString != ""
                {
                    deepLink = URL.init(string: deeplinkString)!
                }
            }
        }
        
        self.deepLinkUrl = deepLink

        if isAppConfigured
        {
            if self.deepLinkUrl != nil
            {
                if isAppInForground
                {
                    let appName: String = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
                    
                    let alertController:UIAlertController = UIAlertController(title: appName, message: "Push notification recieved", preferredStyle: .alert)
                    
                    let okAction:UIAlertAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (okaction) in
                        
                    })
                    
                    let viewAction:UIAlertAction = UIAlertAction(title: "View", style: .default, handler: { (viewAction) in
                        
                        self.handleSnagUrl(self.deepLinkUrl!)
                    })
                    
                    alertController.addAction(okAction)
                    alertController.addAction(viewAction)
                    
                    if let topController = Utility.sharedUtility.topViewController() {
                        
                        topController.present(alertController, animated: true, completion: {
                            
                        })
                    }
                }
                else
                {
                    handleSnagUrl(self.deepLinkUrl!)
                }
            }
        }
        else
        {
            isPushNotificationToBeOpened = true
        }
    }
    
    func openPushNotification() -> Void {
        isPushNotificationToBeOpened = false
        if self.deepLinkUrl != nil
        {
            handleSnagUrl(self.deepLinkUrl!)
        }
    }
    

    func clearUserDefaultSettings() {

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserLoggedInStatusUpdated"), object: nil)
        DownloadManager.sharedInstance.pauseDownloadingObject(isForcePaused: false)
        DownloadManager.sharedInstance.updateDocumentsDirectoryPathForTheDownloadedItems()
        DownloadManager.sharedInstance.removeTheCurrentDownloadAndFlushOutTheDataMaintainedLocallyForTheSession()
        Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.none.rawValue, forKey: Constants.kLoginType)
        Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kAuthorizationToken)
        Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kRefreshToken)
        Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kAuthorizationTokenTimeStamp)
        Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kUSERID)
        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsAccountLinked)
        Constants.kSTANDARDUSERDEFAULTS.synchronize()
        
        self.removePlistFromDocumentDirectory(plistName: Constants.kUserDetailsPlistName)
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            FIRAnalytics.setUserID(nil)
            Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotLoggedInPropertyValue, userPropertyKeyName: Constants.kGTMLoggedInProperty)
            Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            DataManger.sharedInstance.apiToGetAnonymousToken(success: { (isSuccess) in
                
            })
        }
    }
}
