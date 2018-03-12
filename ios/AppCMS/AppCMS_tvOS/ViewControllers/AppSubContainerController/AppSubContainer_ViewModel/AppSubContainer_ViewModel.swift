//
//  AppSubContainer_ViewModel.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 03/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class AppSubContainer_ViewModel: NSObject {
    
    var loadSpecificPage:SubContainerLoadsSpecificPage = .loadAll
    
    /// Holds the menu for sub menu collection view.
    var appSubMenuArray:Array<NavigationItem> = []
    
    /// Populates sub-menu array depending on logged and subscription status.
    func populateSubMenuArray() -> Void {
        appSubMenuArray.removeAll()
        if loadSpecificPage == .loadLoginPage
        {
            appSubMenuArray.append(getLoginPageForNavigation())
        }
        else if loadSpecificPage == .loadPlansPage
        {
            appSubMenuArray.append(getViewPlansPageForNavigation())
        }
        else if loadSpecificPage == .loadSignUpPage
        {
            appSubMenuArray.append(getViewSignUpPageNavigation())
        }
        else {
            
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) == nil
            {
                updateNavigationArrayForSVODApp()
            }
            else
            {
                if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) as! String == UserLoginType.none.rawValue
                {
                    updateNavigationArrayForSVODApp()
                }
                else
                {
                    for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["user"] ?? []
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
                }
            }
        }
    }
    //Authentication Screen
    private func updateNavigationArrayForSVODApp(){
        for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["user"] ?? [] {
            if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
            {
                if (navigationItem as NavigationItem).loggedOut ?? false {
                    if navigationItem.displayedPath == "Create Login Screen" {
                        var pageUpdated : Page?
                        var filteredArray = AppConfiguration.sharedAppConfiguration.pages;
                        filteredArray = AppConfiguration.sharedAppConfiguration.pages.filter() { $0.pageName == "View Plans" }
                        if filteredArray.count > 0 {
                            pageUpdated = filteredArray[0]
                        }
                        if let pageUpdated = pageUpdated {
                            let navigationMenuItem: NavigationItem = NavigationItem()
                            navigationMenuItem.pageId = pageUpdated.pageId ?? ""
                            navigationMenuItem.title = pageUpdated.pageName ?? "View Plans"
                            navigationMenuItem.displayedPath = pageUpdated.pageName ?? "View Plans"
                            navigationMenuItem.type = navigationType.user
                            appSubMenuArray.append(navigationMenuItem)
                        }
                    }
                    else{
                        appSubMenuArray.append(navigationItem as NavigationItem)
                    }
                }
            }
            else{
                if (navigationItem as NavigationItem).loggedOut ?? false {
                    appSubMenuArray.append(navigationItem as NavigationItem)
                }
            }
        }
    }
    
    private func getLoginPageForNavigation() -> NavigationItem  {
        var navigationMenuItem: NavigationItem?
        for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["user"] ?? [] {
            if navigationItem.displayedPath == "Authentication Screen" {
                navigationMenuItem = navigationItem
                break
            }
        }
        return navigationMenuItem ?? NavigationItem()
    }
    
    private func getViewPlansPageForNavigation() -> NavigationItem  {
        let navigationMenuItem: NavigationItem = NavigationItem()
        var pageUpdated : Page?
        var filteredArray = AppConfiguration.sharedAppConfiguration.pages;
        filteredArray = AppConfiguration.sharedAppConfiguration.pages.filter() { $0.pageName == "View Plans" }
        if filteredArray.count > 0 {
            pageUpdated = filteredArray[0]
        }
        if let pageUpdated = pageUpdated {
            navigationMenuItem.pageId = pageUpdated.pageId ?? ""
            navigationMenuItem.title = pageUpdated.pageName ?? ""
            navigationMenuItem.type = navigationType.user
        }
        return navigationMenuItem
    }
    
    private func getViewSignUpPageNavigation() -> NavigationItem  {
        var navigationMenuItem: NavigationItem?
        for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["user"] ?? [] {
            if navigationItem.displayedPath == "Create Login Screen" {
                navigationMenuItem = navigationItem
                break
            }
        }
        return navigationMenuItem ?? NavigationItem()
    }
    
    /// Array of Navigation Controllers to be shown on Tab bar.
    private var navigationViewControllers = Array<PageTuple>()
    
    func getAllTheNavigationViewControllers() -> Array<PageTuple> {
        populateSubMenuArray()

        var navigationArray = Array<PageTuple>()
        var page : Page?
        var ii = 0
        for navItem in appSubMenuArray {
            
            var filteredArray = AppConfiguration.sharedAppConfiguration.pages
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
                    pageViewController.viewModel.pageOpenAction = .subNavigationClickAction
                    pageViewController.isSubContainer = true
                    pageViewController.pagePath = navItem.pageUrl
                    var pageTuple : PageTuple
                    pageTuple.pageName = navItem.title!
                    if let iconImage = navItem.pageIcon{
                        pageTuple.pageIcon = iconImage
                    }
                    else{
                        pageTuple.pageIcon = ""
                    }
                    pageTuple.pageObject = pageViewController
                    navigationArray.append(pageTuple)
                    ii = ii+1
                }
            }
        }
        
        /*Append pagetuple to navigation array*/
        navigationViewControllers = navigationArray
        
        return navigationViewControllers
    }
    
    
    /// Returns a dummy array of items.
    ///
    /// - Returns: array of dummy navigation items.
    func getDummyArrayForGuestUser() -> Array<PageTuple> {
        var arrayOfItems = Array<PageTuple>()
        let pageNames = ["Log In","Terms","Sign Up","Privacy Policy"]
        for pageName in pageNames {
            let pageUpdated = Page.init(pageString: Constants.kSTRING_PAGETYPE_MODULAR)
            pageUpdated.pageName = pageName
            pageUpdated.pageAPI = ""
            pageUpdated.pageUI = ""
            pageUpdated.pageId = "123"
            let appSubContainer = ModuleContainerViewController_tvOS.init(pageObject: pageUpdated, pageDisplayName: pageName)
            
            if pageName == "Terms" || pageName == "Privacy Policy" {
                
                appSubContainer.pagePath = pageName == "Terms" ? "/tos" : "/privacy-policy"
                appSubContainer.viewModel.pageOpenAction = .displayAction
                if let pageobject = getPageForPageName("Privacy Policy"){
                    pageUpdated.modules = pageobject.modules
                }
                
            }
            else if (pageName == "Log In" || pageName == "Sign Up"){
                appSubContainer.viewModel.pageOpenAction = .displayAction
                if let pageobject = getPageForPageName("Authentication Screen"){
                    pageUpdated.modules = pageobject.modules
                }
            }
            else{
                pageUpdated.modules = Array<Any>()
                appSubContainer.viewModel.pageOpenAction = .subNavigationClickAction
                
            }
            
            /*Append searchContainerVC to pageTuple.*/
            var pageTupleSubContainer : PageTuple
            pageTupleSubContainer.pageName = pageName
            pageTupleSubContainer.pageObject = appSubContainer
            pageTupleSubContainer.pageIcon = ""
            arrayOfItems.append(pageTupleSubContainer)
        }
        return arrayOfItems
    }
    
    func  getPageForPageName(_ pageName : String) -> Page? {
        var viewControllerPage:Page?
        //"Privacy Policy"
        //"Authentication Screen"
        let filePath:String = AppSandboxManager.getpageFilePath(fileName: Utility.getPageIdFromPagesArray(pageName: pageName) ?? "")
        if !filePath.isEmpty {
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                
                viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
            }
        }
        
        return viewControllerPage
    }
    
}
