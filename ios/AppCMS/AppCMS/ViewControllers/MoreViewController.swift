//
//  MoreViewController.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 31/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import Apptentive
import AppsFlyerLib
import Firebase
class MoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var moreTableView: UITableView!
    var separatorView: UIView?
    var loggedInStatusLabel: UILabel?
    var loginButton: UIButton?
    var signUpButton: UIButton?
    var moreOptionsArray: Array<AnyObject> = []
    let cellHeight: Float = 48.0
    var tableViewHeight:Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() && Constants.IPHONE {
            
            self.automaticallyAdjustsScrollViewInsets = true
            self.edgesForExtendedLayout = []
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            FIRAnalytics.setScreenName("Menu Screen", screenClass: nil)
        }
        
        createNavigationBar()

        createMoreOptionArray()
        createMoreView()
        updateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.allowIDFACollection = true
        tracker.set(kGAIScreenName, value: "Menu Screen")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func createNavigationBar() {
        
        self.navigationController?.navigationBar.barTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        self.navigationItem.titleView = Utility.createNavigationTitleView(navBarHeight: (self.navigationController?.navigationBar.frame.size.height)!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Method to create More View
    private func createMoreView() -> Void {
        
        tableViewHeight = Float(moreOptionsArray.count) * cellHeight
        
        var tableViewFrame: CGRect!
        if Constants.IPHONE {
            
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                
                tableViewFrame = CGRect.init(x: 20, y: 0, width: 335, height: CGFloat(tableViewHeight))
            }
            else {
                
                tableViewFrame = CGRect.init(x: 20, y: self.view.frame.height - CGFloat(tableViewHeight) - 194.0, width: 335, height: CGFloat(tableViewHeight))
            }
        }
        else
        {
            tableViewFrame = CGRect.init(x: 30, y: self.view.frame.height - CGFloat(tableViewHeight) - 194.0, width: 223, height: CGFloat(tableViewHeight))
        }
        
        if self.moreTableView != nil {
            self.moreTableView?.removeFromSuperview()
            self.moreTableView = nil
        }
        
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() && Constants.IPHONE {
            
            moreTableView = UITableView.init(frame: tableViewFrame!, style: .plain)
        }
        else {
            
            moreTableView = UITableView.init(frame: tableViewFrame!, style: .grouped)
        }
        
        moreTableView.backgroundColor = .yellow
        moreTableView.dataSource = self
        moreTableView.delegate = self
        self.view.addSubview(moreTableView)
        self.view.backgroundColor = Utility.hexStringToUIColor(hex:AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        moreTableView.backgroundColor = .clear
        moreTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        if self.separatorView != nil {
            self.separatorView?.removeFromSuperview()
            self.separatorView = nil
        }
        self.separatorView = UIView.init()
        separatorView?.backgroundColor = Utility.hexStringToUIColor(hex: "#6C7074")
        separatorView?.alpha = 0.48
        self.view.addSubview(separatorView!)
        
        if self.loggedInStatusLabel != nil {
            self.loggedInStatusLabel?.removeFromSuperview()
            self.loggedInStatusLabel = nil
        }
        self.loggedInStatusLabel = UILabel.init()
        loggedInStatusLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        loggedInStatusLabel?.text = "CURRENTLY LOGGED OUT"
        loggedInStatusLabel?.textAlignment = .center
        loggedInStatusLabel?.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Semibold", size: 10)
        self.view.addSubview(loggedInStatusLabel!)
        
        
        if self.loginButton != nil {
            self.loginButton?.removeFromSuperview()
            self.loginButton = nil
        }
        self.loginButton = UIButton.init(type: .custom)
        loginButton?.backgroundColor = .clear
        loginButton?.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff").cgColor
        loginButton?.layer.borderWidth = 1.0
        loginButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        loginButton?.setTitle("LOG IN", for: .normal)
        loginButton?.tag = 555
        loginButton?.titleLabel?.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Semibold", size: 12)
        loginButton?.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        self.view.addSubview(loginButton!)
        
        if self.signUpButton != nil {
            self.signUpButton?.removeFromSuperview()
            self.signUpButton = nil
        }
        self.signUpButton = UIButton.init(type: .custom)
        signUpButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000")
        signUpButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor ?? AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        signUpButton?.tag = 556
        
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.AVOD
        {
            signUpButton?.setTitle("SIGN UP", for: .normal)
        }
        else if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
        {
            signUpButton?.setTitle(AppConfiguration.sharedAppConfiguration.pageHeaderObject?.buttonText ?? Constants.startSubscriptionString, for: .normal)
        }
        else
        {
            signUpButton?.setTitle("SIGN UP", for: .normal)
        }
        signUpButton?.titleLabel?.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Semibold", size: 12)
        signUpButton?.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        self.view.addSubview(signUpButton!)
    }
    
    
    func createMoreOptionArray() -> Void {
        moreOptionsArray.removeAll()
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) == nil
        {
            for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["primary"] ?? []
            {
                if (navigationItem as NavigationItem).loggedOut ?? false
                {
                    moreOptionsArray.append(navigationItem as NavigationItem)
                }
            }
            for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["user"] ?? []
            {
                if (navigationItem as NavigationItem).loggedOut ?? false && ((navigationItem as NavigationItem).title != "Log In") && ((navigationItem as NavigationItem).title != "Log Out")
                {
                    moreOptionsArray.append(navigationItem as NavigationItem)
                }
            }
            for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["footer"] ?? []
            {
                if (navigationItem as NavigationItem).loggedOut ?? false
                {
                    moreOptionsArray.append(navigationItem as NavigationItem)
                }
            }
        }
        else
        {
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) as! String == UserLoginType.none.rawValue
            {
                for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["primary"] ?? []
                {
                    if (navigationItem as NavigationItem).loggedOut ?? false
                    {
                        moreOptionsArray.append(navigationItem as NavigationItem)
                    }
                }
                for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["user"] ?? []
                {
                    if (navigationItem as NavigationItem).loggedOut ?? false && ((navigationItem as NavigationItem).title != "Log In") && ((navigationItem as NavigationItem).title != "Log Out")
                    {
                        moreOptionsArray.append(navigationItem as NavigationItem)
                    }
                }
                for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["footer"] ?? []
                {
                    if (navigationItem as NavigationItem).loggedOut ?? false
                    {
                        moreOptionsArray.append(navigationItem as NavigationItem)
                    }
                }
                
            }
            else
            {
                for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["primary"] ?? []
                {
                    if (navigationItem as NavigationItem).loggedIn ?? false
                    {
                        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
                        {
                            if (navigationItem as NavigationItem).subscribed ?? false
                            {
                                moreOptionsArray.append(navigationItem as NavigationItem)
                            }
                            else
                            {
                                if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey)  != nil
                                {
                                    if (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as! Bool)
                                    {
                                        continue
                                    }
                                    else
                                    {
                                        moreOptionsArray.append(navigationItem as NavigationItem)
                                    }
                                }
                                else
                                {
                                    continue
                                }
                            }
                        }
                        else
                        {
                            moreOptionsArray.append(navigationItem as NavigationItem)
                        }
                    }
                    else
                    {
                        continue
                    }
                }
                for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["user"] ?? []
                {
                    if (navigationItem as NavigationItem).loggedIn ?? false
                    {
                        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
                        {
                            if (navigationItem as NavigationItem).subscribed ?? false
                            {
                                if ((navigationItem as NavigationItem).title != "Log In") && ((navigationItem as NavigationItem).title != "Log Out")
                                {
                                    moreOptionsArray.append(navigationItem as NavigationItem)
                                }
                            }
                            else
                            {
                                if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey)  != nil
                                {
                                    if (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as! Bool)
                                    {
                                        continue
                                    }
                                    else
                                    {
                                        if ((navigationItem as NavigationItem).title != "Log In") && ((navigationItem as NavigationItem).title != "Log Out")
                                        {
                                            moreOptionsArray.append(navigationItem as NavigationItem)
                                        }
                                    }
                                }
                                else
                                {
                                    continue
                                }
                            }
                        }
                        else
                        {
                            if ((navigationItem as NavigationItem).title != "Log In") && ((navigationItem as NavigationItem).title != "Log Out")
                            {
                                moreOptionsArray.append(navigationItem as NavigationItem)
                            }
                        }
                    }
                    else
                    {
                        continue
                    }
                }
                for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["footer"] ?? []
                {
                    if (navigationItem as NavigationItem).loggedIn ?? false
                    {
                        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
                        {
                            if (navigationItem as NavigationItem).subscribed ?? false
                            {
                                moreOptionsArray.append(navigationItem as NavigationItem)
                            }
                            else
                            {
                                if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey)  != nil
                                {
                                    if (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as! Bool)
                                    {
                                        continue
                                    }
                                    else
                                    {
                                        moreOptionsArray.append(navigationItem as NavigationItem)
                                    }
                                }
                                else
                                {
                                    continue
                                }
                            }
                        }
                        else
                        {
                            moreOptionsArray.append(navigationItem as NavigationItem)
                        }
                    }
                    else
                    {
                        continue
                    }
                }
                let signOutNav: NavigationItem = NavigationItem.init()
                
                if Utility.sharedUtility.checkIfUserIsSubscribedGuest() && AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
                {
                    signOutNav.title = "SIGN UP"
                }
                else
                {
                    signOutNav.title = "SIGN OUT"
                }
                moreOptionsArray.append(signOutNav)
            }
        }
    }
    
    
    func updateView() -> Void
    {
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) == nil
        {
            separatorView?.isHidden = false
            loginButton?.isHidden = false
            signUpButton?.isHidden = false
            loggedInStatusLabel?.isHidden = false
        }
        else
        {
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) as! String == UserLoginType.none.rawValue
            {
                separatorView?.isHidden = false
                loginButton?.isHidden = false
                signUpButton?.isHidden = false
                loggedInStatusLabel?.isHidden = false
            }
            else
            {
                separatorView?.isHidden = true
                loginButton?.isHidden = true
                signUpButton?.isHidden = true
                loggedInStatusLabel?.isHidden = true
            }
        }
        self.moreTableView.reloadData()
    }
    
    
    //MARK - table view delegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var primaryArray:Array<Any> = []
        let navItem: NavigationItem = moreOptionsArray[indexPath.row] as! NavigationItem
        
        if navItem.type == navigationType.primary
        {
            if AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["primary"] != nil {
                
                primaryArray = AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["primary"]!
            }
            
            var tabBarIndex = 0
            var isTabAvailable = false
            
            if let tabBarArray = AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["tabBar"] {
                
                for tabBarItem in tabBarArray {
                    
                    if navItem.pageId == tabBarItem.pageId || navItem.title == tabBarItem.title{
                        
                        isTabAvailable = true
                        break
                    }
                    
                    tabBarIndex += 1
                }
            }
            
            if isTabAvailable {
                
                Constants.kAPPDELEGATE.openTabBarWith(barIndex: tabBarIndex)
            }
            else if indexPath.row < primaryArray.count && primaryArray.count > 0 && indexPath.row <= 1
            {
                Constants.kAPPDELEGATE.openTabBarWith(barIndex: indexPath.row)
            }
            else if indexPath.row < primaryArray.count && primaryArray.count > 0 {
                
                if navItem.displayedPath == "View Plans"
                {
                    let planViewController:SFProductListViewController = SFProductListViewController.init()
                    planViewController.shouldUserBeNavigatedToHomePage = true
                    let navigationController: UINavigationController = UINavigationController.init(rootViewController: planViewController)
                    self.present(navigationController, animated: true, completion: {
                        
                    })
                }
                else
                {
                    loadPageViewController(pageName: navItem.pageId, pagePath: navItem.pageUrl ?? "", navigationItem: navItem)
                }
            }
        }
        else
        {
            if indexPath.row < moreOptionsArray.count
            {
                let navItem: NavigationItem = moreOptionsArray[indexPath.row] as! NavigationItem
                
                if navItem.title?.lowercased() ==  "Contact Us".lowercased() {
                    
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                        
                        FIRAnalytics.setScreenName("Contact Us Screen", screenClass: nil)
                    }
                    
                    Apptentive.shared.presentMessageCenter(from: self)
                }
                else if navItem.title?.lowercased() == "SIGN OUT".lowercased() || navItem.title?.lowercased() == "LOGOUT".lowercased()
                {
                    if  Constants.kSTANDARDUSERDEFAULTS.bool(forKey: Constants.kIsSubscribedKey) == true
                    {
                        AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_LOGOUT, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "true"])
                        
                    }
                    else{
                        
                        AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_LOGOUT, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "false"])
                    }
                    if CastPopOverView.shared.isConnected(){
                        CastPopOverView.shared.deviceDisconnected()
                    }
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                    {
                        FIRAnalytics.logEvent(withName: Constants.kGTMLogoutEvent, parameters:nil)
                    }
                    
                    if AppConfiguration.sharedAppConfiguration.urbanAirshipChurnAvailable {
                        
                        DispatchQueue.global(qos: .userInitiated).async {
                            
                            UrbanAirshipEvent.sharedInstance.triggerUserDisAssociationToUrbanAirship()
                            UrbanAirshipEvent.sharedInstance.triggerUserLoggedInStateTagToUrbanAirship(isUserLoggedIn: false)
                        }
                    }
                    Constants.kAPPDELEGATE.clearUserDefaultSettings()
                    createMoreOptionArray()
                    createMoreView()
                    updateView()
                }
                else if navItem.title?.lowercased() == "SIGN UP".lowercased()
                {
                    let createLoginPage: LoginViewController = LoginViewController()
                    createLoginPage.loginType = loginPageType.createLogin
                    createLoginPage.pageScreenName = "Sign Up Screen"
                    createLoginPage.shouldUserBeNavigatedToHomePage = true
                    let navigationController: UINavigationController = UINavigationController.init(rootViewController: createLoginPage)
                    self.navigationController?.present(navigationController, animated: true, completion: {
                        
                    })
                }
                else if navItem.title?.lowercased() == "DOWNLOADS".lowercased() {
                    
                    loadDownloadController(pageName: navItem.pageId , pagePath: navItem.pageUrl ?? "")
                }
                else
                {
                    if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() && !Utility.sharedUtility.checkIfUserIsLoggedIn() && navItem.displayedPath == "My Account"
                    {
                        let alertController = UIAlertController(title: navItem.title, message: "You need to have account to access this feature.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (okAction) in
                            
                        })
                        
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else
                    {
                        loadAncillaryController(pageName: navItem.pageId , pagePath: navItem.pageUrl ?? "", pageTitle: navItem.title!)
                    }
                }
            }
        }
    }
    
    
    //MARK - table view data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreOptionsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(cellHeight)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(cellHeight)
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier:String = "moreCellIdentifier"
        let cell:UITableViewCell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        
        if indexPath.row <=  (moreOptionsArray.count - 1){
            let navItem: NavigationItem = moreOptionsArray[indexPath.row] as! NavigationItem
            cell.textLabel?.text = navItem.title?.uppercased()
            cell.backgroundColor = .clear
           
            if Constants.IPHONE {
                
                cell.textLabel?.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 14)
            }
            else {
                
                cell.textLabel?.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 20)
            }

            cell.textLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        }
        return cell
    }
    
    
    //MARK: - Method to load ancillary view controller
    func loadAncillaryController(pageName:String, pagePath:String, pageTitle:String) {
        
        var viewControllerPage:Page?
        
        let filePath:String = AppSandboxManager.getpageFilePath(fileName: pageName)
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
            ancillaryPageViewController.pageName = pageTitle
            self.tabBarController?.present(ancillaryPageViewController, animated: true, completion: {
            })
        }
    }
    
    
    //MARK: - Method to load ancillary view controller
    func loadPageViewController(pageName:String, pagePath:String, navigationItem: NavigationItem) {
        
        var viewControllerPage:Page?
        let filePath:String = AppSandboxManager.getpageFilePath(fileName: pageName)
        if !filePath.isEmpty {
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                
                viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
            }
        }
        
        if viewControllerPage != nil {
            
            let pageViewController:PageViewController = PageViewController(viewControllerPage: viewControllerPage!, navItem: navigationItem)
            pageViewController.view.changeFrameYAxis(yAxis: 20.0)
            pageViewController.view.changeFrameHeight(height: pageViewController.view.frame.height - 20.0)
            pageViewController.pagePath = pagePath
            pageViewController.pageId = pageName
            
            if let topController = Utility.sharedUtility.topViewController() {
                
                if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                    
                    pageViewController.displayBackButton = true
                    topController.navigationController?.pushViewController(pageViewController, animated: true)
                }
                else {
                    
                    pageViewController.displayCancelIcon = true
                    
                    let navController:UINavigationController = UINavigationController(rootViewController: pageViewController)
                    
                    self.tabBarController?.present(navController, animated: true, completion: {
                        
                    })
                }
            }
        }
    }
    
    //MARK: - Method to load ancillary view controller
    func loadDownloadController(pageName:String, pagePath:String) {
        
        var viewControllerPage:Page?
        let filePath:String = AppSandboxManager.getpageFilePath(fileName: pageName)
        
        if !filePath.isEmpty {
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                
                viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
            }
        }
        
        if viewControllerPage != nil {
            
            let downloadViewController:DownloadViewController = DownloadViewController(viewControllerPage: viewControllerPage!)
            downloadViewController.view.changeFrameYAxis(yAxis: 20.0)
            downloadViewController.view.changeFrameHeight(height: downloadViewController.view.frame.height - 20.0)
            downloadViewController.pagePath = pagePath
            self.tabBarController?.present(downloadViewController, animated: true, completion: {
                
            })
        }
    }
    
    func openDownloadPage()
    {
        if self.moreOptionsArray.count == 0
        {
            self.createMoreOptionArray()
        }
        for navigationItm in self.moreOptionsArray
        {
            if (navigationItm as! NavigationItem).title?.lowercased() == "DOWNLOADS".lowercased()
            {
                let navItem: NavigationItem = navigationItm as! NavigationItem
                loadDownloadController(pageName: navItem.pageId , pagePath: navItem.pageUrl ?? "")
            }
        }
    }
    
    func buttonTapped(sender: UIButton) -> Void {
        if sender.tag == 555
        {
            let loginViewController: LoginViewController = LoginViewController.init()
            loginViewController.loginPageSelection = 0
            loginViewController.pageScreenName = "Sign In Screen"
            loginViewController.shouldUserBeNavigatedToHomePage = true
            loginViewController.loginType = loginPageType.authentication
            let navigationController: UINavigationController = UINavigationController.init(rootViewController: loginViewController)
            self.tabBarController?.present(navigationController, animated: true, completion: {
                
            })
        }
        else
        {
            var navigationController: UINavigationController!
            
            if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.AVOD
            {
                let loginViewController: LoginViewController = LoginViewController.init()
                loginViewController.loginType = loginPageType.authentication
                loginViewController.loginPageSelection = 1
                loginViewController.pageScreenName = "Sign Up Screen"
                loginViewController.shouldUserBeNavigatedToHomePage = true
                navigationController = UINavigationController.init(rootViewController: loginViewController)
            }
            else if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
            {
                let planViewController:SFProductListViewController = SFProductListViewController.init()
                planViewController.shouldUserBeNavigatedToHomePage = true
                navigationController = UINavigationController.init(rootViewController: planViewController)
            }
            else
            {
                let loginViewController: LoginViewController = LoginViewController.init()
                loginViewController.loginType = loginPageType.authentication
                loginViewController.pageScreenName = "Sign Up Screen"
                loginViewController.shouldUserBeNavigatedToHomePage = true
                loginViewController.loginPageSelection = 1
                navigationController = UINavigationController.init(rootViewController: loginViewController)
            }
            
            self.tabBarController?.present(navigationController, animated: true, completion: {
                
            })
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        
        //Need to update once we are fetch user from navigation response
        
        var tableMarginForYAxis:CGFloat = 0
        
        if Utility.sharedUtility.isIphoneX() {
            
            tableMarginForYAxis = 20
        }
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest()
        {
        
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() && Constants.IPHONE {
                
                if tableViewHeight < Float(self.view.bounds.height)
                {
                    moreTableView.isScrollEnabled = false
                }
                else {
                    
                    moreTableView.isScrollEnabled = true
                }
                
                tableViewHeight = Float(self.view.bounds.height)
            }
            else {
                
                if tableViewHeight + 4 > Float(self.view.bounds.height - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)! - tableMarginForYAxis)
                {
                    tableViewHeight = Float(self.view.bounds.height - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)! - tableMarginForYAxis)
                    moreTableView.isScrollEnabled = true
                    self.moreTableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
                }
                else
                {
                    self.moreTableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0)
                    moreTableView.isScrollEnabled = false
                }
            }
        }
        else
        {
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() && Constants.IPHONE {
                
                if tableViewHeight < (Float(self.view.bounds.height) - 143.0)
                {
                    moreTableView.isScrollEnabled = false
                }
                else {
                    
                    moreTableView.isScrollEnabled = true
                }
                tableViewHeight = (Float(self.view.bounds.height) - 143.0)
            }
            else {
                
                if tableViewHeight + 4 > (Float(self.view.bounds.height - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!) - 143.0 - Float(tableMarginForYAxis))
                {
                    tableViewHeight = Float(self.view.bounds.height - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!) - 143.0 - Float(tableMarginForYAxis)
                    moreTableView.isScrollEnabled = true
                    self.moreTableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0)
                }
                else
                {
                    self.moreTableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0)
                    moreTableView.isScrollEnabled = false
                }
            }
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) == nil
        {
            self.updateMoreViewForNonLoggedInState()
        }
        else
        {
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) as! String != UserLoginType.none.rawValue
            {
                self.updateMoreViewForLoggedInState()
            }
            else
            {
                self.updateMoreViewForNonLoggedInState()
            }
        }
    }
    
    
    //MARK: Method to create more view for non logged in state
    private func updateMoreViewForNonLoggedInState() {
        
        if Constants.IPHONE {
            
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                
                moreTableView.frame = CGRect.init(x: 10, y: 0 , width: 335, height: CGFloat(tableViewHeight))
            }
            else {
                
                moreTableView.frame = CGRect.init(x: 10, y: self.view.frame.height - CGFloat(tableViewHeight) - (self.tabBarController?.tabBar.frame.height)!-143, width: 335, height: CGFloat(tableViewHeight))
            }
            
            moreTableView.changeFrameXAxis(xAxis: moreTableView.frame.minX * Utility.getBaseScreenWidthMultiplier())
            moreTableView.changeFrameWidth(width: moreTableView.frame.width * Utility.getBaseScreenWidthMultiplier())
            
            separatorView?.frame = CGRect.init(x: 20, y: moreTableView.frame.minY + CGFloat(tableViewHeight), width: 330, height: 1)
            
            separatorView?.changeFrameXAxis(xAxis: (separatorView?.frame.minX)! * Utility.getBaseScreenWidthMultiplier())
            separatorView?.changeFrameWidth(width: (separatorView?.frame.width)! * Utility.getBaseScreenWidthMultiplier())
            separatorView?.changeFrameHeight(height: (separatorView?.frame.height)! * Utility.getBaseScreenHeightMultiplier())
            
            loggedInStatusLabel?.frame = CGRect.init(x: (separatorView?.frame.minX)!,y: (separatorView?.frame.maxY)! + 10, width: (separatorView?.frame.width)!, height: 14)
            loggedInStatusLabel?.changeFrameWidth(width: (loggedInStatusLabel?.frame.width)! * Utility.getBaseScreenWidthMultiplier())
            loggedInStatusLabel?.changeFrameHeight(height: (loggedInStatusLabel?.frame.height)! * Utility.getBaseScreenHeightMultiplier())
            
            loginButton?.frame = CGRect.init(x: 43 * Utility.getBaseScreenWidthMultiplier(), y: (separatorView?.frame.maxY)! + 34, width: 290, height: 40)
            loginButton?.changeFrameWidth(width: (loginButton?.frame.width)! * Utility.getBaseScreenWidthMultiplier())
            loginButton?.changeFrameHeight(height: (loginButton?.frame.height)! * Utility.getBaseScreenHeightMultiplier())
            
            signUpButton?.frame = CGRect.init(x: 43 * Utility.getBaseScreenWidthMultiplier(), y: (loginButton?.frame.maxY)! + 10, width: 290, height: 40)
            signUpButton?.changeFrameWidth(width: (signUpButton?.frame.width)! * Utility.getBaseScreenWidthMultiplier())
            signUpButton?.changeFrameHeight(height: (signUpButton?.frame.height)! * Utility.getBaseScreenHeightMultiplier())
        }
        else
        {
            moreTableView.frame = CGRect.init(x: 30, y: (self.view.frame.height - CGFloat(tableViewHeight))/2, width: 223, height: CGFloat(tableViewHeight))
            
            moreTableView.changeFrameXAxis(xAxis: moreTableView.frame.minX * Utility.getBaseScreenWidthMultiplier())
            moreTableView.changeFrameWidth(width: moreTableView.frame.width * Utility.getBaseScreenWidthMultiplier())
            
            separatorView?.frame = CGRect.init(x: 297, y: moreTableView.frame.minY, width: 1, height: CGFloat(tableViewHeight))
            
            separatorView?.changeFrameXAxis(xAxis: (separatorView?.frame.minX)! * Utility.getBaseScreenWidthMultiplier())
            separatorView?.changeFrameWidth(width: (separatorView?.frame.width)! * Utility.getBaseScreenWidthMultiplier())
            separatorView?.changeFrameHeight(height: (separatorView?.frame.height)! * Utility.getBaseScreenHeightMultiplier())
            
            loginButton?.frame = CGRect.init(x: (self.view.frame.width - (separatorView?.frame.maxX)! - 290)/2 + (separatorView?.frame.maxX)!, y: (self.view.frame.height - 40)/2, width: 290, height: 40)
            loginButton?.changeFrameWidth(width: (loginButton?.frame.width)! * Utility.getBaseScreenWidthMultiplier())
            loginButton?.changeFrameHeight(height: (loginButton?.frame.height)! * Utility.getBaseScreenHeightMultiplier())
            
            loggedInStatusLabel?.frame = CGRect.init(x: (self.view.frame.width - (separatorView?.frame.maxX)! - 290)/2 + (separatorView?.frame.maxX)!,y: (loginButton?.frame.minY)! - 25 , width: 290, height: 14)
            loggedInStatusLabel?.changeFrameWidth(width: (loggedInStatusLabel?.frame.width)! * Utility.getBaseScreenWidthMultiplier())
            loggedInStatusLabel?.changeFrameHeight(height: (loggedInStatusLabel?.frame.height)! * Utility.getBaseScreenHeightMultiplier())
            
            signUpButton?.frame = CGRect.init(x: (self.view.frame.width - (separatorView?.frame.maxX)! - 290)/2 + (separatorView?.frame.maxX)!, y: (loginButton?.frame.maxY)! + 10, width: 290, height: 40)
            signUpButton?.changeFrameWidth(width: (signUpButton?.frame.width)! * Utility.getBaseScreenWidthMultiplier())
            signUpButton?.changeFrameHeight(height: (signUpButton?.frame.height)! * Utility.getBaseScreenHeightMultiplier())
        }
    }
    
    
    //MARK: Method to create more view for logged in state
    private func updateMoreViewForLoggedInState() {
        
        if Constants.IPHONE {
            
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                
                moreTableView.frame = CGRect.init(x: 10, y: 0 , width: 335, height: CGFloat(tableViewHeight))
            }
            else {
                
                moreTableView.frame = CGRect.init(x: 10, y: self.view.frame.height - CGFloat(tableViewHeight) - (self.tabBarController?.tabBar.frame.height)!, width: 335, height: CGFloat(tableViewHeight))
            }
        }
        else
        {
            moreTableView.frame = CGRect.init(x: 30, y: (self.view.frame.height - CGFloat(tableViewHeight))/2, width: self.view.frame.width - 60, height: CGFloat(tableViewHeight))
        }
        
        moreTableView.changeFrameXAxis(xAxis: moreTableView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        moreTableView.changeFrameWidth(width: moreTableView.frame.width * Utility.getBaseScreenWidthMultiplier())
    }
    
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
}
