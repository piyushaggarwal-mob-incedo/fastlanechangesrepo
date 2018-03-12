//
//  TabbarViewController_tvOS.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 12/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class TabbarViewController_tvOS: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //Customize UITab bar
        self.tabBar.barTintColor =  UIColor(red: 36/255, green: 41/255, blue: 43/255, alpha: 1)
 //Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        createTabBarItemsAndControllers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - customize and configure tab bar items, also create ViewControllers.
    func createTabBarItemsAndControllers() {
        
        var viewControllersArray:Array<AnyObject> = []
        
        var ii = 0
        
        let menuImagesArray: Array = ["moreTabIcon","homeTabIcon","movieTabIcon","searchIcon"]
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
                let filePath:String = AppSandboxManager.getpageFilePath(fileName: page.pageName ?? "")
                
                let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
                
                if jsonData != nil {
                    
                    //if ii < 3 {
                    let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                    
                    let pageParser = PageUIParser()
                    AppConfiguration.sharedAppConfiguration.pages.remove(at: ii)
                    let pageUpdated:Page? = pageParser.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
                    pageUpdated?.pageName = page.pageName
                    pageUpdated?.pageAPI = page.pageAPI
                    pageUpdated?.pageUI = page.pageUI
                    pageUpdated?.pageId = page.pageId
                    
                    AppConfiguration.sharedAppConfiguration.pages.insert(pageUpdated!, at: ii)
                    
//                    let pageViewController:PageViewControllerTVOS = PageViewControllerTVOS(viewControllerPage: pageUpdated!)
                    let pageViewController:PageViewController_tvOS = PageViewController_tvOS()

                    pageViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    pageViewController.view.backgroundColor =      UIColor(red: 10/255, green: 21/255, blue: 28/255, alpha: 1)
                    //pageViewController.tabBarItem = UITabBarItem(title: pageTitle ?? "", image: UIImage(named: menuImagesArray[ii+1] as String), selectedImage: UIImage(named: ""))
                    
                    pageViewController.tabBarItem = UITabBarItem(title: pageTitle ?? "", image: nil, selectedImage:nil)
                    pageViewController.tabBarItem.tag = ii
                    
//                    let navigationController: UINavigationController = UINavigationController.init(rootViewController: pageViewController)
                    viewControllersArray.append(pageViewController)
                    ii = ii+1
                    //                    }
                    //                    else
                    //                    {
                    //                        let moreViewController: MoreViewController = MoreViewController()
                    //                        moreViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    //                        moreViewController.tabBarItem = UITabBarItem(title: "Menu", image: UIImage(named: menuImagesArray[0] as String), selectedImage: UIImage(named: ""))
                    //                        moreViewController.tabBarItem.tag = 4
                    //
                    //                        let navigationController: UINavigationController = UINavigationController.init(rootViewController: moreViewController)
                    //                        viewControllersArray.insert(navigationController, at: 0)
                    //                        break
                    //                    }
                }
            }
            
        }
        //
        //        let moreViewController: MoreViewController = MoreViewController()
        //        moreViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        //        moreViewController.tabBarItem = UITabBarItem(title: "Menu", image: UIImage(named: menuImagesArray[0] as String), selectedImage: UIImage(named: ""))
        //        moreViewController.tabBarItem.tag = 4
        //
        //        var navigationController: UINavigationController = UINavigationController.init(rootViewController: moreViewController)
        //        viewControllersArray.insert(navigationController, at: 0)
        //
        //
        //        let searchViewController: SearchViewController = SearchViewController()
        //        searchViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        //        searchViewController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: menuImagesArray[menuImagesArray.count - 1] as String), selectedImage: UIImage(named: ""))
        //        searchViewController.tabBarItem.tag = 4
        //
        //        navigationController = UINavigationController.init(rootViewController: searchViewController)
        //        viewControllersArray.append(navigationController)
        //
        self.viewControllers = viewControllersArray as? [UIViewController]
        if AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItems.count > 0 {
            self.selectedIndex = 1
        }
    }
}
