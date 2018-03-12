//
//  AppContainerViewModel_tvOS.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 21/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

/// PageTuple: Tuple which contains pageName and Instance of ViewController which is object of type: ModuleContainerViewController_tvOS
//typealias PageTuple = (pageName: String, pageObject: ModuleContainerViewController_tvOS)
typealias PageTuple = (pageName: String, pageIcon: String, pageObject: UIViewController)


class AppContainerViewModel_tvOS: NSObject {
    
    /// Array of Navigation Controllers to be shown on Tab bar.
    private var navigationViewControllers = Array<PageTuple>()
    
    func getAllTheNavigationViewControllers() -> Array<PageTuple> {
        var navigationArray = Array<PageTuple>()
        var page : Page?
        var ii = 0
        for navItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItems {
            
            var filteredArray = AppConfiguration.sharedAppConfiguration.pages;
            filteredArray = AppConfiguration.sharedAppConfiguration.pages.filter() { $0.pageId == navItem.pageId }
            if filteredArray.count > 0 {
                page = filteredArray[0]
            } else {
                //continue
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
                    var pageTuple : PageTuple
                    pageTuple.pageName = navItem.title!
                    pageTuple.pageObject = pageViewController
                    if let iconImage = navItem.pageIcon {
                        pageTuple.pageIcon = iconImage
                    }
                    else{
                        pageTuple.pageIcon = ""
                    }
                    navigationArray.append(pageTuple)
                    ii = ii+1
                }
            }
        }
        
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment{
            let appSubContainer = AppSubContainerController()
            /*Append searchContainerVC to pageTuple.*/
            var pageTupleSubContainer : PageTuple
            let suffixString = AppConfiguration.sharedAppConfiguration.shortAppName ?? "Profile"
            pageTupleSubContainer.pageName = "My \(suffixString)"
            pageTupleSubContainer.pageObject = appSubContainer
            pageTupleSubContainer.pageIcon = "profile"
            navigationArray.append(pageTupleSubContainer)
            
            let searchBaseVC = SearchBaseViewController()
            /*Append searchContainerVC to pageTuple.*/
            var pageTuple : PageTuple
            pageTuple.pageName = "Search"
            pageTuple.pageObject = searchBaseVC
            pageTuple.pageIcon = "icon-search"
            navigationArray.append(pageTuple)
        } else if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            let searchBaseVC = SearchBaseViewController()
            /*Append searchContainerVC to pageTuple.*/
            var pageTuple : PageTuple
            pageTuple.pageName = "Search"
            pageTuple.pageObject = searchBaseVC
            pageTuple.pageIcon = "icon-search"
            navigationArray.insert(pageTuple, at: 0)
        }
        
        /*Append pagetuple to navigation array*/
        navigationViewControllers = navigationArray

        return navigationViewControllers
    }
}
