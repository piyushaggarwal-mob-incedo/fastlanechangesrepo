//
//  AppDelegate+AppConfiguration.swift
//  AppCMS
//
//  Created by Gaurav Vig on 29/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import Firebase
import DrawerController

extension AppDelegate {
    
    func fetchAppDomainConfiguration() {
        
        if AppConfiguration.sharedAppConfiguration.sitename == nil {
            
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/sites?domainName=\(AppConfiguration.sharedAppConfiguration.domainName ?? "")"
            
            NetworkHandler.sharedInstance.callNetworkForConfiguration(apiURL: apiEndPoint) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
                
                if responseConfigData != nil && isSuccess
                {
                    let domainContentDict:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with: responseConfigData!) as? Dictionary<String, AnyObject>
                    
                    let gistDict:Dictionary<String, AnyObject>? = domainContentDict?["gist"] as? Dictionary<String, AnyObject>
                    
                    if gistDict != nil {
                        
                        let appAccessKeyDict:Dictionary<String, AnyObject>? = gistDict?["appAccess"] as? Dictionary<String, AnyObject>
                        
                        if appAccessKeyDict != nil {
                            
                            //AppConfiguration.sharedAppConfiguration.apiSecretKey = appAccessKeyDict?["appSecretKey"] as? String
                            AppConfiguration.sharedAppConfiguration.apiAccessKey = appAccessKeyDict?["appId"] as? String
                        }
                        
                        let siteInternalName:String? = gistDict?["siteInternalName"] as? String
                        
                        if siteInternalName != nil {
                            
                            AppConfiguration.sharedAppConfiguration.sitename = siteInternalName!
                        }
                    }
                    
                    let settingsDict:Dictionary<String, AnyObject>? = domainContentDict?["setting"] as? Dictionary<String, AnyObject>
                    
                    if settingsDict != nil {
                        
                        let socialDict:Dictionary<String, AnyObject>? = settingsDict?["social"] as? Dictionary<String, AnyObject>
                        
                        if socialDict != nil {
                            
                            let googleSettingsDict:Dictionary<String, AnyObject>? = socialDict?["google"] as? Dictionary<String, AnyObject>
                            
                            if googleSettingsDict != nil {
                                
                                let googleClientId:String? = googleSettingsDict?["credentials"] as? String
                                
                                if googleClientId != nil {
                                    
                                    AppConfiguration.sharedAppConfiguration.googleClientId = googleClientId!
                                }
                            }
                        }
                    }
                }
                
                self.loadApplicationAfterDomainConfiguration()
            }
        }
        else {
            
            self.loadApplicationAfterDomainConfiguration()
        }
    }
    
    
    private func loadApplicationAfterDomainConfiguration() {
        
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
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            let authorizationToken:String? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) as? String
            let refreshToken:String? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kRefreshToken) as? String
            
            if authorizationToken == nil && refreshToken == nil {
                
                self.clearUserDefaultSettings()
            }
        }
        
        self.fetchUserSubscriptionStatusFromServer(shouldUpdateIAPReceipt: true)
        self.loadApp()
    }
    
    
    func loadApp() {
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            FIRApp.configure()
        }
        
        self.createAppPages()
        
        if AppConfiguration.sharedAppConfiguration.googleAnalyticsId != nil && !(AppConfiguration.sharedAppConfiguration.googleAnalyticsId?.isEmpty)! {
            
            googleAnalyticsSetup(googleAnalyticsId: AppConfiguration.sharedAppConfiguration.googleAnalyticsId!)
        }
        
        if AppConfiguration.sharedAppConfiguration.forceLogin != nil
        {
            if AppConfiguration.sharedAppConfiguration.forceLogin!
            {
                let splashPage: SplashViewController = SplashViewController.init()
                self.window?.rootViewController = splashPage
            }
            else
            {
                navigateToHomeScreen()
            }
        }
        else
        {
            navigateToHomeScreen()
        }        
    }
    
    //MARK: Google Anaytics setup
    func googleAnalyticsSetup(googleAnalyticsId:String)->Void {
        
        guard let newTracker = GAI.sharedInstance().tracker(withTrackingId: googleAnalyticsId) else { return }
        GAI.sharedInstance().defaultTracker = newTracker
        GAI.sharedInstance().logger.logLevel = GAILogLevel.error
        GAI.sharedInstance().defaultTracker.allowIDFACollection = true
        let version:String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        
        GAI.sharedInstance().defaultTracker.allowIDFACollection = true
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Application Started", action: "Application Version", label: version, value: NSNumber(value: -1)).build() as! [AnyHashable : Any]!)
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Application Started", action: "OS Version", label: UIDevice.current.systemVersion, value: NSNumber(value: -1)).build() as! [AnyHashable : Any]!)
        GAI.sharedInstance().defaultTracker.set(kGAIScreenName, value: "Application Launched")
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createScreenView().build() as! [AnyHashable : Any]!)
    }
    
    
    func createNavigationDrawer() -> Void {
        let navigationDrawer: LeftNavigationDrawerViewController = LeftNavigationDrawerViewController()
        navigationDrawer.selectedDrawerIndex = 0
        let centerViewController: CenterViewController = CenterViewController()
        
        let centerNavigationController = UINavigationController(rootViewController: centerViewController)
        centerNavigationController.restorationIdentifier = "CenterControllerRestorationKey"
        
        let leftNavigationController = UINavigationController(rootViewController: navigationDrawer)
        leftNavigationController.restorationIdentifier = "LeftNavigationControllerRestorationKey"
        
        centerNavigationController.navigationBar.barTintColor = AppConfiguration.sharedAppConfiguration.navigationMenu.navigationBackgroundColor
        leftNavigationController.navigationBar.barTintColor = AppConfiguration.sharedAppConfiguration.navigationMenu.navigationBackgroundColor
        
        self.drawerController = DrawerController.init(centerViewController: centerNavigationController, leftDrawerViewController: leftNavigationController)
        self.window?.rootViewController = drawerController
        
        centerViewController.updateNavigationDrawerSelection(selectedIndex: 0)
    }
    
    func createTabBar() -> Void {
        tabBar = TabBarViewController()
        self.window?.rootViewController = tabBar
        if isPushNotificationToBeOpened
        {
            openPushNotification()
        }
    }
    
    func openWelcomeScreen() -> Void {
        
        let pageViewController:SplashViewController = SplashViewController()
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        self.window?.rootViewController = pageViewController
    }
    
    func navigateToSplashScreen() -> Void {
        let splashViewController: SplashViewController = SplashViewController.init()
        self.window?.rootViewController = splashViewController
    }
    
    func navigateToHomeScreen() {
        if AppConfiguration.sharedAppConfiguration.appHasTabBar
        {
            self.createTabBar()
        }
        else
        {
            self.createNavigationDrawer()
        }
    }
    
    /*private func showDownloadAlertForAlertType() {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
            }
        }
        
        let okAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrOk, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                if AppConfiguration.sharedAppConfiguration.appHasTabBar
                {
                    if self.tabBar != nil && (self.tabBar?.viewControllers?.count)! > 0
                    {
                        self.tabBar?.selectedIndex = (self.tabBar?.viewControllers?.count)! - 1
                        if self.tabBar != nil && (self.tabBar?.viewControllers?.count)! > 0
                        {
                            if self.tabBar?.selectedViewController is UINavigationController
                            {
                                let navController: UINavigationController = self.tabBar?.selectedViewController as! UINavigationController
                                if navController.topViewController is MoreViewController
                                {
                                    let moreViewController: MoreViewController = navController.topViewController as! MoreViewController
                                    moreViewController.openDownloadPage()
                                }
                            }
                        }
                    }
                }
                else
                {
                    //To be Done - implemention for navigation menu
                }
            }
        }
        
        var alertTitleString:String?
        var alertMessage:String?
        
        
        alertTitleString = "No Network Connection found"
        alertMessage = "Please go to downloads page to access downloaded content"
        
        let navigateToDownloadPageAlert: UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction, okAction])
        
        
        self.tabBar?.selectedViewController?.present(navigateToDownloadPageAlert, animated: true, completion: nil)
    }*/

    func navigateToDownload(callback: @escaping ((_ isDowload: Bool?) -> Void))
    {
        if AppConfiguration.sharedAppConfiguration.isDownloadEnabled != nil && AppConfiguration.sharedAppConfiguration.isDownloadEnabled == true
        {
            if Utility.sharedUtility.checkIfUserIsLoggedIn()
            {
                callback(true)
                Utility.sharedUtility.displayOfflineAlertToPlayDownloadVideo(viewController: (self.tabBar?.selectedViewController)!)
            }
            else
            {
                callback(false)
            }
        }
        else
        {
            callback(false)
        }
    }
    
    func updateCenterViewController(selectedIndex: Int) -> Void
    {
        let navController: UINavigationController = self.drawerController?.centerViewController as! UINavigationController
        let centerViewController: CenterViewController? = navController.visibleViewController as? CenterViewController
        
        if centerViewController != nil {
            centerViewController?.updateNavigationDrawerSelection(selectedIndex: selectedIndex)
        }
    }
    
    
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
                
                let pageViewController:PageViewController = PageViewController(viewControllerPage: pageUpdated!)
                
                pageViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                
                AppConfiguration.sharedAppConfiguration.pageViewControllers.append(pageViewController)
            }
        }
    }
    
    func openTabBarWith(barIndex: Int) -> Void {
        
        self.tabBar?.selectedIndex = barIndex
    }
}
