//
//  TabBarViewController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 30/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.changeFrameHeight(height: 55)
        self.tabBar.barTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        createTabBarItems()
        self.setNeedsStatusBarAppearanceUpdate()
        self.tabBar.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    
    //MARK: - Create Tab Bar Items
    func createTabBarItems() {
        
        if let navItemsArray = AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["tabBar"] {
            
            self.createTabBarControllerWithTabBarConfig(navItemsArray: navItemsArray)
        }
        else {
            
            self.createTabBarControllerWithoutTabBarConfig()
        }
    }

    
    
    private func createTabBarControllerWithTabBarConfig(navItemsArray:Array<NavigationItem>) {
        
        var viewControllersArray:Array<AnyObject> = []
        
        var ii = 0
        
        //        let menuImagesArray: Array = ["moreTabIcon","homeTabIcon","movieTabIcon","searchIcon"]
        let _: Array = ["homeTabIcon","movieTabIcon","searchIcon","moreTabIcon"]
//        var isSearchDisplayed:Bool = false
        
        for navItem in navItemsArray {
            
            var page: Page!
            var pageTitle: String!
            for pageItem:Page in AppConfiguration.sharedAppConfiguration.pages {
                if pageItem.pageId == navItem.pageId
                {
                    page = pageItem
                    pageTitle = navItem.title
                    
                    break
                }
            }
            
            if (page != nil) {
                
                let filePath:String = AppSandboxManager.getpageFilePath(fileName: page.pageId ?? "")
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
                    
                    if navItem.title == "Search" || navItem.displayedPath == "Search Screen" {
                        
//                        isSearchDisplayed = true
                        let searchViewController: SearchViewController = SearchViewController()
                        searchViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        searchViewController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: navItem.pageIcon ?? "icon-search"), selectedImage: UIImage(named: ""))
                        searchViewController.tabBarItem.tag = ii
                        searchViewController.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 10)!], for: .selected)
                        
                        let navigationController: UINavigationController = UINavigationController.init(rootViewController: searchViewController)
                        viewControllersArray.append(navigationController)
                    }
                    else {
                        
                        var pageViewController:PageViewController?
                        
                        if navItem.subNavItems.count > 0 {
                            
                            pageViewController = PageViewController(viewControllerPage: pageUpdated!, navItem: navItem)
                        }
                        else {
                            
                            pageViewController = PageViewController(viewControllerPage: pageUpdated!)
                        }
                        
                        pageViewController?.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        
                        pageViewController?.tabBarItem = UITabBarItem(title: pageTitle ?? "", image: UIImage(named: navItem.pageIcon ?? ""), selectedImage: UIImage(named: ""))
                        pageViewController?.tabBarItem.tag = ii
                        pageViewController?.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 10)!], for: .selected)
                        
                        let navigationController: UINavigationController = UINavigationController.init(rootViewController: pageViewController!)
                        viewControllersArray.append(navigationController)
                    }
                }
            }
            else if navItem.title == "More" || navItem.displayedPath == "Menu Screen" || navItem.title == "Menu" {
                
                let moreViewController: MoreViewController = MoreViewController()
                moreViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                moreViewController.tabBarItem = UITabBarItem(title: navItem.title ?? "Menu", image: UIImage(named: navItem.pageIcon ?? "icon-menu"), selectedImage: UIImage(named: ""))
                moreViewController.tabBarItem.tag = ii
                moreViewController.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 10)!], for: .selected)
                
                let navigationController = UINavigationController.init(rootViewController: moreViewController)
                viewControllersArray.append(navigationController)
            }
            else if navItem.title == "Search" || navItem.displayedPath == "Search Screen" {
                
//                isSearchDisplayed = true
                let searchViewController: SearchViewController = SearchViewController()
                searchViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                searchViewController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: navItem.pageIcon ?? "icon-search"), selectedImage: UIImage(named: ""))
                searchViewController.tabBarItem.tag = ii
                searchViewController.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 10)!], for: .selected)
                
                let navigationController: UINavigationController = UINavigationController.init(rootViewController: searchViewController)
                viewControllersArray.append(navigationController)
            }
            
            
            ii = ii+1
        }
        
//        if !isSearchDisplayed && TEMPLATETYPE.lowercased() != Constants.kTemplateTypeSports.lowercased() {
//
//            isSearchDisplayed = true
//            let searchViewController: SearchViewController = SearchViewController()
//            searchViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
//            searchViewController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "icon-search.png"), selectedImage: UIImage(named: ""))
//            searchViewController.tabBarItem.tag = ii
//            searchViewController.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "OpenSans", size: 10)!], for: .selected)
//
//            let navigationController: UINavigationController = UINavigationController.init(rootViewController: searchViewController)
//            viewControllersArray.append(navigationController)
//        }
        
        viewControllers = viewControllersArray as? [UIViewController]
        
        if let navItemsArray = AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["tabBar"] {
            
            if navItemsArray.count > 0 {
                
                self.selectedIndex = 0
            }
        }
    }
    
    
    private func createTabBarControllerWithoutTabBarConfig() {
        
        var viewControllersArray:Array<AnyObject> = []
        
        var ii = 0
        
        let menuImagesArray: Array = ["homeTabIcon","movieTabIcon","searchIcon","moreTabIcon"]
        
        for navItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItems {
            
            var page: Page!
            var pageTitle: String!
            for pageItem in AppConfiguration.sharedAppConfiguration.pages {
                if pageItem.pageId == navItem.pageId
                {
                    page = pageItem
                    pageTitle = navItem.title
                }
            }
            
            if (page != nil) {
                
                let filePath:String = AppSandboxManager.getpageFilePath(fileName: page.pageId ?? "")
                let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
                
                if jsonData != nil {
                    
                    //                    if ii < 3 {
                    let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                    
                    let pageParser = PageUIParser()
                    AppConfiguration.sharedAppConfiguration.pages.remove(at: ii)
                    let pageUpdated:Page? = pageParser.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
                    pageUpdated?.pageName = page.pageName
                    pageUpdated?.pageAPI = page.pageAPI
                    pageUpdated?.pageUI = page.pageUI
                    pageUpdated?.pageId = page.pageId
                    
                    AppConfiguration.sharedAppConfiguration.pages.insert(pageUpdated!, at: ii)
                    
                    let pageViewController:PageViewController = PageViewController(viewControllerPage: pageUpdated!)
                    pageViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    
                    pageViewController.tabBarItem = UITabBarItem(title: pageTitle ?? "", image: UIImage(named: menuImagesArray[ii] as String), selectedImage: UIImage(named: ""))
                    pageViewController.tabBarItem.tag = ii
                    pageViewController.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 10)!], for: .selected)
                    
                    let navigationController: UINavigationController = UINavigationController.init(rootViewController: pageViewController)
                    viewControllersArray.append(navigationController)
                    ii = ii+1
                }
            }
            
            if ii > 1 {
                
                break
            }
        }
        
        let searchViewController: SearchViewController = SearchViewController()
        searchViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        searchViewController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: menuImagesArray[menuImagesArray.count - 2] as String), selectedImage: UIImage(named: ""))
        searchViewController.tabBarItem.tag = 4
        searchViewController.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 10)!], for: .selected)
        
        var navigationController: UINavigationController = UINavigationController.init(rootViewController: searchViewController)
        viewControllersArray.append(navigationController)
        
        let moreViewController: MoreViewController = MoreViewController()
        moreViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        moreViewController.tabBarItem = UITabBarItem(title: "Menu", image: UIImage(named: menuImagesArray.last!), selectedImage: UIImage(named: ""))
        moreViewController.tabBarItem.tag = 4
        moreViewController.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 10)!], for: .selected)
        
        navigationController = UINavigationController.init(rootViewController: moreViewController)
        viewControllersArray.append(navigationController)
        
        
        viewControllers = viewControllersArray as? [UIViewController]
        
        if AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItems.count > 0 {
            self.selectedIndex = 0
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        print("item value \(item)")
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
