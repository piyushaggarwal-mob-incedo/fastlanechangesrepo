//
//  ModuleViewModel_SubMenuViewHandler.swift
//  AppCMS
//
//  Created by Rajni Pathak on 07/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
/// SubNavTuple: Tuple which contains pageName and Instance of ViewController which is object of type: ModuleContainerViewController_tvOS
enum SubNavPageAction {
    case subNavActionToggle
    case subNavActionAlert
    case subNavActionSubscribeNow
    case subNavActionDisplay
    case subNavActionAccount
    case subNavActionSignOut
    case subNavActionSignUp

}
typealias SubNavTuple = (pageName: String, pageIcon: String, pageObject: UIViewController?, pageId: String, pageAction: SubNavPageAction, pagePath:String?)

class ModuleViewModel_SubNavigationViewHandler: ModuleViewModel, SubNavigationViewControllerDelegate {
    
    /// Holds the menu for sub menu collection view.
    private var pageName: String?
    var pageObject: Page?
    private var subMenuArray: Array<SubNavTuple> = []
    private var subNavView: SubNavigationViewController_tvOS?
    
    override init() {
        super.init()
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(refreshItems), name: Constants.kUpdateNavigationMenuItems, object: nil)
    }
    
    @objc private func refreshItems() {
        //Refresh Menu Items.
        if let subMenu = subNavView {
            let pageName = self.pageName ?? ""
            if pageName == "Settings" {
                subMenu.refreshMenu(menuArray: getSettingsSubMenuArray())
            }
        }
    }
    
    func getModuleView(parentViewFrame:CGRect, teamObject: SFSubNavigationViewObject, pageName: String) -> SubNavigationViewController_tvOS {
        
        self.pageName = pageName
        if pageName == "Settings"{
            subMenuArray = getSettingsSubMenuArray()
        }
        else{
            subMenuArray = getTeamsSubMenuArray()
        }

        let moduleHeight: CGFloat = CGFloat(Utility.fetchSubMenuLayoutDetails(teamObject: teamObject).height!)
        subNavView = SubNavigationViewController_tvOS(frame: CGRect(x: 0, y: 0, width: parentViewFrame.size.width, height: moduleHeight), teamViewObject: teamObject, menuArray: subMenuArray, pageDisplayName: pageName)
        subNavView?.delegate = self
        return subNavView!
    }
    
    ///Clear all user related data and navigate to home page
    func logoutButtonTapped() {
        Constants.kAPPDELEGATE.clearUserDefaultSettings()
        ///Navigate to home page.
        Constants.kAPPDELEGATE.navigateToHomeScreen()
    }
    
    func menuSelected(menuSelectedAtIndex: Int){
        let pageID = subMenuArray[menuSelectedAtIndex].pageId
        var page : Page?
        var filteredArray = AppConfiguration.sharedAppConfiguration.pages
        filteredArray = AppConfiguration.sharedAppConfiguration.pages.filter() { $0.pageId == pageID }
        if filteredArray.count > 0 {
            page = filteredArray[0]
        }
        if let page = page {
            
            if (page.pageName ?? "" ) == "My Account" {
                let accountPage = SFAccountInfoModuleSports_tvOS(nibName: "SFAccountInfoModuleSports_tvOS", bundle: nil)
                if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.launchAccountPage(accountPage:))))! {
                    delegate?.launchAccountPage!(accountPage: accountPage)
                }
            } else {
                let filePath:String = AppSandboxManager.getpageFilePath(fileName: page.pageId ?? "")
                let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
                
                if let jsonData = jsonData {
                    
                    let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData) as? Dictionary<String, AnyObject>
                    let pageParser = PageUIParser()
                    let pageUpdated:Page? = pageParser.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
                    //Additional check for safety.
                    if pageUpdated == nil {
                        return
                    }
                    pageUpdated?.pageName = page.pageName
                    pageUpdated?.pageAPI = page.pageAPI
                    pageUpdated?.pageUI = page.pageUI
                    pageUpdated?.pageId = page.pageId
                    
                    let pageViewController = ModuleContainerViewController_tvOS.init(pageObject: pageUpdated!,pageDisplayName: subMenuArray[menuSelectedAtIndex].pageName)
                    pageViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    pageViewController.viewModel.pageOpenAction = .masterNavigationClickAction
                    pageViewController.pagePath = subMenuArray[menuSelectedAtIndex].pagePath ?? ""
                    if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.launchTeamDetailPage(teamDetailPage:))))! {
                        delegate?.launchTeamDetailPage!(teamDetailPage: pageViewController)
                    }
                }
            }
        }
    }
    // Func to create Settings Module Items list
    
    
    func getSettingsSubMenuArray() -> Array<SubNavTuple> {
        
        var navigationArray = Array<SubNavTuple>()
        var autoPlayTuple : SubNavTuple
        if let autoPlay = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) as? Bool {
            if autoPlay{
                autoPlayTuple.pageName = Constants.kAutoplayOn
            }
            else{
                autoPlayTuple.pageName = Constants.kAutoplayOff
            }
        } else {
            autoPlayTuple.pageName = Constants.kAutoplayOff
        }
        autoPlayTuple.pageIcon = "icon-Autoplay"
        autoPlayTuple.pageObject = nil
        autoPlayTuple.pageId = ""
        autoPlayTuple.pageAction = .subNavActionToggle
        autoPlayTuple.pagePath = ""
        navigationArray.append(autoPlayTuple)
        
        var ccTuple : SubNavTuple
        if let ccEnabled = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsCCEnabled) as? Bool {
            if ccEnabled{
                ccTuple.pageName = Constants.kClosedCaptionOn
            }
            else{
                ccTuple.pageName = Constants.kClosedCaptionOff
            }
            
        } else {
            ccTuple.pageName = Constants.kClosedCaptionOff
        }
        ccTuple.pageIcon = "icon-CC"
        ccTuple.pageObject = nil
        ccTuple.pageId = ""
        ccTuple.pageAction = .subNavActionToggle
        ccTuple.pagePath = ""
        navigationArray.append(ccTuple)
        
        let isSubscribed = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool) ?? false
        if isSubscribed {
            var msTuple : SubNavTuple
            msTuple.pageName = Constants.kManageSubscriptiontvOS
            msTuple.pageIcon = "icon-subscription"
            msTuple.pageObject = nil
            msTuple.pageId = ""
            msTuple.pageAction = .subNavActionAlert
            msTuple.pagePath = ""
            navigationArray.append(msTuple)
        } else {
            var msTuple : SubNavTuple
            msTuple.pageName = Constants.kSubscribeNowtvOS
            msTuple.pageIcon = "icon-subscription"
            msTuple.pageObject = nil
            msTuple.pageId = ""
            msTuple.pageAction = .subNavActionSubscribeNow
            msTuple.pagePath = ""
            navigationArray.append(msTuple)
        }
        
        
        var page : Page?
        var ii = 0
        for navItem in getAllTheNavigationViewControllers() {
            
            if navItem.displayedPath == Constants.kSignOut{
                var signoutTuple : SubNavTuple
                signoutTuple.pageName = Constants.kSignOut
                signoutTuple.pageIcon = "icon-signout"
                signoutTuple.pageObject = nil
                signoutTuple.pageId = ""
                signoutTuple.pageAction = .subNavActionSignOut
                signoutTuple.pagePath = navItem.pageUrl ?? ""
                navigationArray.append(signoutTuple)
            } else if navItem.displayedPath == Constants.kSignUp {
                var signoutTuple : SubNavTuple
                signoutTuple.pageName = Constants.kSignUp
                signoutTuple.pageIcon = "icon-user"
                signoutTuple.pageObject = nil
                signoutTuple.pageId = ""
                signoutTuple.pageAction = .subNavActionSignUp
                signoutTuple.pagePath = navItem.pageUrl ?? ""
                navigationArray.append(signoutTuple)
            }
            else {
                var filteredArray = AppConfiguration.sharedAppConfiguration.pages
                filteredArray = AppConfiguration.sharedAppConfiguration.pages.filter() { $0.pageId == navItem.pageId }
                if filteredArray.count > 0 {
                    page = filteredArray[0]
                }
                else{
                    continue
                }
                if let page = page {
                    
                    let filePath:String = AppSandboxManager.getpageFilePath(fileName: page.pageId ?? "")
                    let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
                    
                    if let jsonData = jsonData {
                        
                        let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData) as? Dictionary<String, AnyObject>
                        
                        let pageParser = PageUIParser()
                        let pageUpdated:Page? = pageParser.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
                        //Additional check for safety.
                        if pageUpdated == nil {
                            continue
                        }
                        pageUpdated?.pageName = page.pageName
                        pageUpdated?.pageAPI = page.pageAPI
                        pageUpdated?.pageUI = page.pageUI
                        pageUpdated?.pageId = page.pageId
                        
                        let pageViewController = ModuleContainerViewController_tvOS.init(pageObject: pageUpdated!,pageDisplayName: navItem.title!)
                        pageViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        pageViewController.viewModel.pageOpenAction = .masterNavigationClickAction
                        pageViewController.isSubContainer = true
                        pageViewController.pagePath = navItem.pageUrl
                        var pageTuple : SubNavTuple
                        if navItem.displayedPath == "Authentication Screen" {
                            navItem.title = "LOG IN"
                            pageTuple.pageName = "SIGN IN"
                        } else {
                            pageTuple.pageName = navItem.title!
                        }
                        if let iconImage = navItem.pageIcon{
                            pageTuple.pageIcon = iconImage
                        }
                        else{
                            pageTuple.pageIcon = ""
                        }
                        pageTuple.pageObject = pageViewController
                        pageTuple.pageId = navItem.pageId
                        if navItem.displayedPath == "My Account" {
                            if Utility.sharedUtility.checkIfUserIsLoggedIn() && Utility.sharedUtility.checkIfUserIsSubscribedGuest() == false {
                                pageTuple.pageAction = .subNavActionAccount
                                pageTuple.pagePath = navItem.pageUrl ?? ""
                                navigationArray.append(pageTuple)
                            }
                        } else {
                            pageTuple.pageAction = .subNavActionDisplay
                            pageTuple.pagePath = navItem.pageUrl ?? ""
                            navigationArray.append(pageTuple)
                        }
                        ii = ii+1
                    }
                }
            }
           
        }
        return navigationArray
    }
    /// Populates sub-menu array depending on logged and subscription status.

    func getAllTheNavigationViewControllers() -> Array<NavigationItem>{
        /// Holds the menu for sub menu collection view.
        var appSubMenuArray:Array<NavigationItem> = []
        for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["user"] ?? []
        {
            if navigationItem.displayedPath != nil && (navigationItem.displayedPath?.uppercased() == "MY WATCHLIST" || navigationItem.displayedPath?.uppercased() == "MY HISTORY") {
                continue
            }
            if navigationItem.title != nil && (navigationItem.title?.uppercased() == "WATCHLIST" || navigationItem.title?.uppercased() == "HISTORY") {
                continue
            }
            if (navigationItem as NavigationItem).loggedIn ?? false
            {
                if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
                {
                    if (navigationItem as NavigationItem).subscribed ?? false
                    {
                        appSubMenuArray.append(navigationItem as NavigationItem)
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
                                appSubMenuArray.append(navigationItem as NavigationItem)
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
                    appSubMenuArray.append(navigationItem as NavigationItem)
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
                        appSubMenuArray.append(navigationItem as NavigationItem)
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
                                appSubMenuArray.append(navigationItem as NavigationItem)
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
                    appSubMenuArray.append(navigationItem as NavigationItem)
                }
            }
            else
            {
                continue
            }
        }


        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) == nil || Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) as! String == UserLoginType.none.rawValue
        {
            for navigationItem in updateNavigationArrayForSVODApp(){
                appSubMenuArray.append(navigationItem as NavigationItem)
            }
        }
        else
        {
            if Utility.sharedUtility.checkIfUserIsSubscribedGuest() == true {
                let navigationMenuItem: NavigationItem = NavigationItem()
                navigationMenuItem.pageId = ""
                navigationMenuItem.title = Constants.kSignUp
                navigationMenuItem.displayedPath = Constants.kSignUp
                navigationMenuItem.type = navigationType.user
                appSubMenuArray.append(navigationMenuItem)
            } else {
                let navigationMenuItem: NavigationItem = NavigationItem()
                navigationMenuItem.pageId = ""
                navigationMenuItem.title = Constants.kSignOut
                navigationMenuItem.displayedPath = Constants.kSignOut
                navigationMenuItem.type = navigationType.user
                appSubMenuArray.append(navigationMenuItem)
            }
        }
        return appSubMenuArray
    }
    
    private func updateNavigationArrayForSVODApp()  -> Array<NavigationItem>{
        var appSubMenuArray:Array<NavigationItem> = []
        for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["user"] ?? [] {
            if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
            {
                if (navigationItem as NavigationItem).loggedOut ?? false {
                    if navigationItem.displayedPath == "Create Login Screen" {
                        if Utility.sharedUtility.checkIfUserIsSubscribedGuest() == true {
                            appSubMenuArray.append(navigationItem as NavigationItem)
                        }
//                        else{
//                            var pageUpdated : Page?
//                            var filteredArray = AppConfiguration.sharedAppConfiguration.pages;
//                            filteredArray = AppConfiguration.sharedAppConfiguration.pages.filter() { $0.pageName == "View Plans" }
//                            if filteredArray.count > 0 {
//                                pageUpdated = filteredArray[0]
//                            }
//                            if let pageUpdated = pageUpdated {
//                                let navigationMenuItem: NavigationItem = NavigationItem()
//                                navigationMenuItem.pageId = pageUpdated.pageId ?? ""
//                                navigationMenuItem.title = pageUpdated.pageName ?? "View Plans"
//                                navigationMenuItem.displayedPath = pageUpdated.pageName ?? "View Plans"
//                                navigationMenuItem.type = navigationType.user
//                                appSubMenuArray.append(navigationMenuItem)
//                            }
//                        }
                    }
                    else{
                        if Utility.sharedUtility.checkIfUserIsSubscribedGuest() == false {
                            appSubMenuArray.append(navigationItem as NavigationItem)
                        }
                    }
                }
            }
            else{
                if (navigationItem as NavigationItem).loggedOut ?? false {
                    appSubMenuArray.append(navigationItem as NavigationItem)
                }
            }
        }
        return appSubMenuArray
    }
    
    
    
    /// Create sub-menu array for Teams.
    func getTeamsSubMenuArray() -> Array<SubNavTuple> {
        var subNavigationArray = Array<SubNavTuple>()
        if let _pageObject = pageObject {
            let navigationArray = AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["primary"]
            let teamsArray = navigationArray?.filter() {$0.pageId == _pageObject.pageId}
            if let _teams = teamsArray {
                var ii = 0
                for navItem in _teams[0].subNavItems
                {
                    var page : Page?
                    var filteredArray = AppConfiguration.sharedAppConfiguration.pages;
                    filteredArray = AppConfiguration.sharedAppConfiguration.pages.filter() { $0.pageId == navItem.pageId }
                    if filteredArray.count > 0 {
                        page = filteredArray[0]
                    }
                    if let page = page {
                        
                        let filePath:String = AppSandboxManager.getpageFilePath(fileName: page.pageId ?? "")
                        let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
                        
                        if let jsonData = jsonData {
                            
                            let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData) as? Dictionary<String, AnyObject>
                            
                            let pageParser = PageUIParser()
                            let pageUpdated:Page? = pageParser.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
                            //Additional check for safety.
                            if pageUpdated == nil {
                                continue
                            }
                            pageUpdated?.pageName = page.pageName
                            pageUpdated?.pageAPI = page.pageAPI
                            pageUpdated?.pageUI = page.pageUI
                            pageUpdated?.pageId = page.pageId
                            
                            let pageViewController = ModuleContainerViewController_tvOS.init(pageObject: pageUpdated!,pageDisplayName: navItem.title!)
                            pageViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                            pageViewController.viewModel.pageOpenAction = .masterNavigationClickAction
                            var pageTuple : SubNavTuple
                            pageTuple.pageName = navItem.title!
                            pageTuple.pageObject = pageViewController
                            if let iconImage = navItem.pageIcon {
                                pageTuple.pageIcon = iconImage
                            }
                            else{
                                pageTuple.pageIcon = ""
                            }
                            pageTuple.pageId = navItem.pageId
                            pageTuple.pageAction = .subNavActionDisplay
                            pageTuple.pagePath = navItem.pageUrl ?? ""
                            subNavigationArray.append(pageTuple)
                            ii = ii+1
                        }
                    }
                }
            }
        }
        return subNavigationArray
    }
    
    
}


