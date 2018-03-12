//
//  AppDelegate+PageDeepLinking.swift
//  AppCMS
//
//  Created by Gaurav Vig on 29/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    //MARK: Method to get deep link url string
    func getDeepLInkData(for url: URL) {
        
        var string: String = url.absoluteString
        
        if AppConfiguration.sharedAppConfiguration.domainName != nil {
            
            if string.contains("https://" + AppConfiguration.sharedAppConfiguration.domainName!)
            {
                string = string.replacingOccurrences(of: "https://", with: "")
            }
            else if string.contains("http://" + AppConfiguration.sharedAppConfiguration.domainName!)
            {
                string = string.replacingOccurrences(of: "http://", with: "")
            }
            if isAppConfigured
            {
                handleSnagUrl(URL.init(string: string)!)
            }
            else
            {
                if let url = URL.init(string: string) {
                    
                    self.deepLinkUrl = url
                    isPushNotificationToBeOpened = true
                }
            }
        }
    }
    
    //MARK: Handle deep linking
    func handleSnagUrl(_ url: URL) {
        
        if AppConfiguration.sharedAppConfiguration.domainName != nil
        {
            if AppConfiguration.sharedAppConfiguration.domainName != nil
            {
                let baseUrl:String = AppConfiguration.sharedAppConfiguration.domainName ?? ""
                var domainBaseUrl:String = ""
                let domainArray: Array = AppConfiguration.sharedAppConfiguration.domainName!.components(separatedBy: ".")
                var ii: Int = 0
                for domainSubString in domainArray
                {
                    if ii != 0
                    {
                        domainBaseUrl = domainBaseUrl + domainSubString
                        
                        if ii != domainArray.count - 1
                        {
                            domainBaseUrl = domainBaseUrl + "."
                        }
                    }
                    
                    ii = ii + 1
                }
                
                var deeplinkBaseUrl:String?
                
                if compareBaseUrlWithDeepLinkBaseUrl(baseUrl: baseUrl, deeplinkBaseUrl: url.absoluteString) {
                    
                    deeplinkBaseUrl = baseUrl
                }
                else if compareBaseUrlWithDeepLinkBaseUrl(baseUrl: domainBaseUrl, deeplinkBaseUrl: url.absoluteString) {
                    
                    deeplinkBaseUrl = domainBaseUrl
                }
                
                if deeplinkBaseUrl != nil && !(deeplinkBaseUrl?.isEmpty)!
                {
                    let pageRelativePath: String = url.absoluteString.replacingOccurrences(of: deeplinkBaseUrl!, with: "")
                    if pageRelativePath.contains("films") || pageRelativePath.contains("film") || pageRelativePath.contains(Constants.kVideoContentType) || pageRelativePath.contains(Constants.kVideosContentType) || pageRelativePath.contains("episodes") || pageRelativePath.contains("episode") || pageRelativePath.contains("lectures") || pageRelativePath.contains("lecture")
                    {
                        if self.tabBar != nil
                        {
                            var viewControllerPage:Page?
                            let filePath:String = AppSandboxManager.getpageFilePath(fileName: Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Video Page") ?? "")
                            if !filePath.isEmpty {
                                
                                let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
                                
                                if jsonData != nil {
                                    
                                    let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                                    
                                    viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
                                }
                            }
                            
                            if viewControllerPage != nil {
                                
                                let videoDetailViewController:VideoDetailViewController = VideoDetailViewController(viewControllerPage: viewControllerPage!, pageType: .videoDetail)
                                videoDetailViewController.pagePath = pageRelativePath
                                videoDetailViewController.view.changeFrameYAxis(yAxis: 20.0)
                                videoDetailViewController.view.changeFrameHeight(height: videoDetailViewController.view.frame.height - 20.0)
                                
                                if let topController = Utility.sharedUtility.topViewController() {
                                    
                                    if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                                        
                                        topController.navigationController?.pushViewController(videoDetailViewController, animated: true)
                                        //                        self.navigationController?.pushViewController(videoDetailViewController, animated: true)
                                    }
                                    else {
                                        
                                        topController.present(videoDetailViewController, animated: true, completion: {
                                            
                                        })
                                    }
//                                    topController.present(videoDetailViewController, animated: true, completion: {
//
//                                    })
                                }
                            }
                        }
                    }
                    else if pageRelativePath.contains(Constants.kShowContentType) || pageRelativePath.contains("course") || pageRelativePath.contains(Constants.kShowsContentType)
                    {
                        if self.tabBar != nil
                        {
                            var viewControllerPage:Page?
                            let filePath:String = AppSandboxManager.getpageFilePath(fileName: Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Show Page") ?? "")
                            if !filePath.isEmpty {
                                
                                let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
                                
                                if jsonData != nil {
                                    
                                    let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                                    
                                    viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
                                }
                            }
                            
                            if viewControllerPage != nil {
                                
                                let videoDetailViewController:VideoDetailViewController = VideoDetailViewController(viewControllerPage: viewControllerPage!, pageType: .showDetail)
                                videoDetailViewController.pagePath = pageRelativePath
                                videoDetailViewController.view.changeFrameYAxis(yAxis: 20.0)
                                videoDetailViewController.view.changeFrameHeight(height: videoDetailViewController.view.frame.height - 20.0)
                                
                                if let topController = Utility.sharedUtility.topViewController() {
                                    
                                    if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                                        
                                        topController.navigationController?.pushViewController(videoDetailViewController, animated: true)
                                        //                        self.navigationController?.pushViewController(videoDetailViewController, animated: true)
                                    }
                                    else {
                                        
                                        topController.present(videoDetailViewController, animated: true, completion: {
                                            
                                        })
                                    }
                                }
                            }
                        }
                    }
                    else if pageRelativePath.contains(Constants.kArticleContentType) ||  pageRelativePath.contains("article") || pageRelativePath.contains(Constants.kArticlesContentType)
                    {
                        if self.tabBar != nil
                        {
                            var viewControllerPage:Page?
                            let filePath:String = AppSandboxManager.getpageFilePath(fileName: Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Article Page") ?? "")
                            if !filePath.isEmpty {
                                
                                let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
                                
                                if jsonData != nil {
                                    
                                    let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                                    
                                    viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
                                }
                            }
                            
                            if viewControllerPage != nil {
                                
                                let videoDetailViewController:VideoDetailViewController = VideoDetailViewController(viewControllerPage: viewControllerPage!, pageType: .showDetail)
                                videoDetailViewController.pagePath = pageRelativePath
                                videoDetailViewController.view.changeFrameYAxis(yAxis: 20.0)
                                videoDetailViewController.view.changeFrameHeight(height: videoDetailViewController.view.frame.height - 20.0)
                                
                                if let topController = Utility.sharedUtility.topViewController() {
                                    
                                    if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                                        topController.navigationController?.pushViewController(videoDetailViewController, animated: true)
                                    }
                                    else {
                                        topController.present(videoDetailViewController, animated: true, completion: {
                                            
                                        })
                                    }
                                }
                            }
                        }
                    }
                    else if pageRelativePath.contains("categories") || pageRelativePath == ""
                    {
                        
                    }
                }
            }
        }
    }
    
    private func compareBaseUrlWithDeepLinkBaseUrl(baseUrl:String, deeplinkBaseUrl:String) -> Bool{
        
        var isDeepLinkAvailable:Bool = false
        
        if baseUrl != "" && deeplinkBaseUrl.contains(baseUrl) {
            
            isDeepLinkAvailable = true
        }
        
        return isDeepLinkAvailable
    }
}
