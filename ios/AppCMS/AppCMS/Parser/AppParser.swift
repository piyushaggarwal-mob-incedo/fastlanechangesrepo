//
//  AppParser.swift
//  SwiftPOCConfiguration
//
//  Created by Abhinav Saldi on 06/03/17.
//  Copyright © 2017 Abhinav Saldi. All rights reserved.
//

import Foundation
import UIKit

@objc protocol AppParserDelegate:NSObjectProtocol {
    @objc func appConfigurationParsed() -> Void
}

class AppParser: NSObject
{
    weak var appParserDelegate: AppParserDelegate?
    
    func parseAppConfigurationJson(appConfigDictionary: Dictionary<String, AnyObject>) -> Void {
        AppConfiguration.sharedAppConfiguration.appConfigVersion = Double(appConfigDictionary["File Version"] as! String)!
        
        let generalConfigDictionary: Dictionary = appConfigDictionary["General"] as! Dictionary<String, AnyObject>
        
        AppConfiguration.sharedAppConfiguration.apiAccessKey = generalConfigDictionary["accessKey"] as? String
        AppConfiguration.sharedAppConfiguration.apiBaseUrl = generalConfigDictionary["apiUrl"] as? String
        AppConfiguration.sharedAppConfiguration.apiCachedBaseUrl = generalConfigDictionary["apiBaseUrlCached"] as? String
        AppConfiguration.sharedAppConfiguration.appName = generalConfigDictionary["name"] as? String
        AppConfiguration.sharedAppConfiguration.sitename = generalConfigDictionary["site"] as? String
        
        let backgroundDictionary:Dictionary<String, AnyObject>? = generalConfigDictionary["brand"] as? Dictionary<String, AnyObject>
        let generalBackgroundDict:Dictionary <String, AnyObject>? = backgroundDictionary?["general"] as? Dictionary<String, AnyObject>
        
        AppConfiguration.sharedAppConfiguration.backgroundColor = generalBackgroundDict?["backgroundColor"] as? String
        AppConfiguration.sharedAppConfiguration.appTextColor = generalBackgroundDict?["textColor"] as? String
        let pagesDictionary: Dictionary<String, AnyObject>? = appConfigDictionary["Pages"] as? Dictionary<String, AnyObject>
        
        if  pagesDictionary != nil {
            
            for (_,  pageDict) in pagesDictionary! {
                
                let pageParser = PageUIParser()
                let parsedPage: Page = pageParser.parsePageConfigurationJson(pageConfigDictionary: pageDict as! Dictionary<String, AnyObject>)
                AppConfiguration.sharedAppConfiguration.pages.append(parsedPage)
            }
        }
        
        if appParserDelegate != nil && (appParserDelegate?.responds(to: #selector(AppParserDelegate.appConfigurationParsed)))! {
            appParserDelegate?.appConfigurationParsed()
        }
        
    }
    
    
    func parseAppMainConfigurationJson(appConfigDictionary: Dictionary<String, AnyObject>, methodCallback: @escaping ((_ iOSJsonUrl: String?) -> Void)) -> Void {
        
        var plistDict: Dictionary<String,Any> = [:]
        
        plistDict["version"] = appConfigDictionary["version"] as? String ?? "1.0"
        plistDict["internalName"] = appConfigDictionary["internalName"] as? String
        plistDict["secretKey"] = appConfigDictionary["secretKey"] as? String
        plistDict["accessKey"] = appConfigDictionary["accessKey"] as? String
        plistDict["apiBaseUrl"] = appConfigDictionary["apiBaseUrl"] as? String
        plistDict["apiCacheBaseUrl"] = appConfigDictionary["apiBaseUrlCached"] as? String
        plistDict["apiClientName"] = appConfigDictionary["apiClientName"] as? String
        plistDict["appShareName"] = appConfigDictionary["appShareName"] as? String
        plistDict["faqUrl"] = appConfigDictionary["faqUrl"] as? String
        plistDict["timestamp"] = appConfigDictionary["timestamp"] as? Double
        
        let appVersionsDict:Dictionary<String, AnyObject>? = appConfigDictionary["appVersions"] as? Dictionary<String, AnyObject>
        
        if appVersionsDict != nil {
            
            var platformVersionDict:Dictionary<String, AnyObject>?
            #if os(iOS)
                platformVersionDict = appVersionsDict?["ios"] as? Dictionary<String, AnyObject>
            #else
                platformVersionDict = appVersionsDict?["appleTv"] as? Dictionary<String, AnyObject>
            #endif
            
            if platformVersionDict != nil {
                
                if platformVersionDict?["minimum"] != nil {
                    
                    plistDict["minimumAppVersion"] = platformVersionDict?["minimum"] as? String
                }
                
                if platformVersionDict?["latest"] != nil {
                    
                    plistDict["latestAppVersion"] = platformVersionDict?["latest"] as? String
                }
                
                if platformVersionDict?["updateUrl"] != nil {
                    
                    plistDict["appStoreUrl"] = platformVersionDict?["updateUrl"] as? String
                }
            }
        }
        
        if appConfigDictionary["id"] != nil {
            
            plistDict["siteId"] =  appConfigDictionary["id"] as? String
        }

        let beaconDict:Dictionary<String, AnyObject>? = appConfigDictionary["beacon"] as? Dictionary<String, AnyObject>
        
        if beaconDict != nil {
            
            plistDict["beaconSiteName"] = beaconDict?["siteName"] as? String
            plistDict["beaconClientId"] = beaconDict?["clientId"] as? String
            plistDict["beaconApiBaseUrl"] = beaconDict?["apiBaseUrl"] as? String
        }
        
        let customerServiceDict:Dictionary<String, AnyObject>? = appConfigDictionary["customerService"] as? Dictionary<String, AnyObject>

        if customerServiceDict != nil {
            
            plistDict["phone"] = customerServiceDict?["phone"] as? String ?? ""
            plistDict["email"] = customerServiceDict?["email"] as? String ?? ""
        }
        
        let brandDict:Dictionary<String, AnyObject>? = appConfigDictionary["brand"] as? Dictionary<String, AnyObject>
        let appColorDict:Dictionary<String, AnyObject>? = brandDict?["general"] as? Dictionary<String, AnyObject>
        
        let socialMediaDict:Dictionary<String, AnyObject>? = appConfigDictionary["socialMedia"] as? Dictionary<String, AnyObject>
        
        if socialMediaDict != nil {
            
            let googlePlusDict:Dictionary<String, AnyObject>? = socialMediaDict?["googlePlus"] as? Dictionary<String, AnyObject>
            
            if googlePlusDict != nil {
                
                let isGoogleSignInEnabled:Bool? = googlePlusDict?["signin"] as? Bool
                
                if isGoogleSignInEnabled != nil {
                    
                    plistDict["googleSignInEnabled"] = isGoogleSignInEnabled!
                    AppConfiguration.sharedAppConfiguration.isGoogleSignEnabled = isGoogleSignInEnabled!
                }
            }
        }
        
        let metadataDict:Dictionary<String, AnyObject>? = brandDict?["metadata"] as? Dictionary<String, AnyObject>
        
        if metadataDict != nil {
            
            if let displayDuration = metadataDict!["displayDuration"] as? Bool {
                
                plistDict["displayDuration"] = displayDuration
            }
            
            if let displayPublishDate = metadataDict!["displayPublishDate"] as? Bool {
                
                plistDict["displayPublishDate"] = displayPublishDate
            }
            
            if let displayAuthor = metadataDict!["displayAuthor"] as? Bool {
                
                plistDict["displayAuthor"] = displayAuthor
            }
            
            if let displayHoverState = metadataDict!["displayHoverState"] as? Bool {
                
                plistDict["displayHoverState"] = displayHoverState
            }
        }
        
        let navigationMenu: Navigation = Navigation()

        if appColorDict != nil {
            plistDict["textColor"] = appColorDict?["textColor"] as? String
            plistDict["backgroundColor"] = appColorDict?["backgroundColor"] as? String
            plistDict["blockTitleColor"] = appColorDict?["blockTitleColor"] as? String
            plistDict["pageTitleColor"] = appColorDict?["pageTitleColor"] as? String
            
            AppConfiguration.sharedAppConfiguration.appTextColor = appColorDict?["textColor"] as? String
            AppConfiguration.sharedAppConfiguration.backgroundColor = appColorDict?["backgroundColor"] as? String
            AppConfiguration.sharedAppConfiguration.appBlockTitleColor = appColorDict?["blockTitleColor"] as? String
            AppConfiguration.sharedAppConfiguration.pageTitleColor = appColorDict?["pageTitleColor"] as? String
            
            var fontFamily = appColorDict?["fontFamily"] as? String
            
            if fontFamily != nil {
                
                fontFamily = fontFamily?.components(separatedBy: .whitespaces).joined()
                
                plistDict["fontFamily"] = fontFamily
                AppConfiguration.sharedAppConfiguration.appFontFamily = fontFamily
            }
        }
        
        let applinkColorDict: Dictionary<String, AnyObject>? = brandDict?["link--hover"] as? Dictionary<String, AnyObject>
        if applinkColorDict != nil
        {
            AppConfiguration.sharedAppConfiguration.linkColor = applinkColorDict?["textColor"] as? String
        }
        
        
        let appBrandMetaDataDict: Dictionary<String, AnyObject>? = brandDict?["metadata"] as? Dictionary<String, AnyObject>
        if appBrandMetaDataDict != nil
        {
            AppConfiguration.sharedAppConfiguration.durationMetaData.displayAuthor = appBrandMetaDataDict?["displayAuthor"] as? Bool
            AppConfiguration.sharedAppConfiguration.durationMetaData.displayDuration = appBrandMetaDataDict?["displayDuration"] as? Bool
            AppConfiguration.sharedAppConfiguration.durationMetaData.displayPublishDate = appBrandMetaDataDict?["displayPublishDate"] as? Bool

        }
        
        
        let appCTADict:Dictionary<String, AnyObject>? = brandDict?["cta"] as? Dictionary<String, AnyObject>
        if appCTADict != nil {
            
            let appPrimaryHoverDict: Dictionary<String, AnyObject>? = appCTADict?["primary--hover"] as? Dictionary<String, AnyObject>
            if let appPrimaryHover = appPrimaryHoverDict {
                let borderDict: Dictionary<String, AnyObject>? = appPrimaryHover["border"] as? Dictionary<String, AnyObject>
                if let border = borderDict {
                    AppConfiguration.sharedAppConfiguration.primaryHoverColor = border["color"] as? String
                    
                }
            }
            
            let primaryDict:Dictionary<String, AnyObject>? = appCTADict?["primary"] as? Dictionary<String, AnyObject>
            if primaryDict != nil{
                plistDict["primary-button"] = primaryDict?["backgroundColor"] as? String
                plistDict["primary-Text"] = primaryDict?["textColor"] as? String
                
                AppConfiguration.sharedAppConfiguration.primaryButton.backgroundColor = primaryDict?["backgroundColor"] as? String
                AppConfiguration.sharedAppConfiguration.primaryButton.textColor = primaryDict?["textColor"] as? String
                AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor = primaryDict?["backgroundColor"] as? String
                
                let primaryBorderDict:Dictionary<String, AnyObject>? = primaryDict?["border"] as? Dictionary<String, AnyObject>
                if primaryBorderDict != nil{
                    AppConfiguration.sharedAppConfiguration.primaryButton.borderColor = primaryBorderDict?["color"] as? String
                    AppConfiguration.sharedAppConfiguration.primaryButton.borderSelectedColor = primaryBorderDict?["color"] as? String
                    AppConfiguration.sharedAppConfiguration.primaryButton.borderWidth = primaryBorderDict?["width"] as? Float
                }
            }
            
            let secondaryDict:Dictionary<String, AnyObject>? = appCTADict?["secondary"] as? Dictionary<String, AnyObject>
            if secondaryDict != nil{
                plistDict["secondary-button"] = secondaryDict?["blockTitleColor"] as? String
                plistDict["secondary-Text"] = secondaryDict?["pageTitleColor"] as? String
                AppConfiguration.sharedAppConfiguration.secondaryButton.backgroundColor = secondaryDict?["backgroundColor"] as? String
                AppConfiguration.sharedAppConfiguration.secondaryButton.textColor = secondaryDict?["textColor"] as? String
                AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor = secondaryDict?["backgroundColor"] as? String
                
                let secBorderDict:Dictionary<String, AnyObject>? = secondaryDict?["border"] as? Dictionary<String, AnyObject>
                if secBorderDict != nil{
                    AppConfiguration.sharedAppConfiguration.secondaryButton.borderColor = secBorderDict?["color"] as? String
                    AppConfiguration.sharedAppConfiguration.secondaryButton.borderSelectedColor = secBorderDict?["color"] as? String
                    AppConfiguration.sharedAppConfiguration.secondaryButton.borderWidth = secBorderDict?["width"] as? Float
                }
            }
        }
        
        let navColor: UIColor = Utility.hexStringToUIColor(hex: plistDict["backgroundColor"] as! String)
            navigationMenu.navigationBackgroundColor = navColor

        AppConfiguration.sharedAppConfiguration.navigationMenu = navigationMenu
        AppConfiguration.sharedAppConfiguration.configFileTimestamp = plistDict["timestamp"] as? Double
        AppConfiguration.sharedAppConfiguration.forceLogin = appConfigDictionary["forceLogin"] as? Bool ?? false
        AppConfiguration.sharedAppConfiguration.isDownloadEnabled = appConfigDictionary["isDownloadable"] as? Bool ?? false
        AppConfiguration.sharedAppConfiguration.isContentRatingEnabled = appConfigDictionary["isContentRatingEnabled"] as? Bool ?? false
        
        let serviceType = appConfigDictionary["serviceType"] as! String
        if serviceType == "SVOD"
        {
            AppConfiguration.sharedAppConfiguration.serviceType = .SVOD
        }
        else if serviceType == "AVOD"
        {
            AppConfiguration.sharedAppConfiguration.serviceType = .AVOD
        }
        else
        {
            AppConfiguration.sharedAppConfiguration.serviceType = .TVOD
        }
        
        plistDict["companyName"] = appConfigDictionary["companyName"] as? String
        plistDict["site"] = appConfigDictionary["internalName"] as? String
        plistDict["domainName"] = appConfigDictionary["domainName"] as? String
        plistDict["emailFeedbackTech"] = appConfigDictionary["emailFeedbackTech"] as? String

        let featuresDict:Dictionary<String, Any>? = appConfigDictionary["features"] as? Dictionary<String, Any>
        
        if featuresDict != nil {
            
            let freePreviewDict:Dictionary<String, Any>? = featuresDict?["free_preview"] as? Dictionary<String, Any>
            
            if freePreviewDict != nil {
                
                let isPreviewAvailable:Bool? = freePreviewDict?["isFreePreview"] as? Bool
                let isPreviewPerVideo:Bool? = freePreviewDict?["per_video"] as? Bool
                plistDict["per_video"] = isPreviewPerVideo ?? true
                plistDict["previewAvailable"] = isPreviewAvailable ?? false
                
                if isPreviewPerVideo != nil {
                    
                    plistDict["previewPerVideo"] = isPreviewPerVideo!
                }
                
                if isPreviewAvailable != nil {
                    
                    if isPreviewAvailable! {
                        
                        let previewDurationDict:Dictionary<String, Any>? = freePreviewDict?["length"] as? Dictionary<String, Any>
                        
                        if previewDurationDict != nil {
                            
                            let previewDuration:String? = previewDurationDict?["multiplier"] as? String
                            
                            if previewDuration != nil {
                                
                                plistDict["previewDuration"] = previewDuration!
                            }
                        }
                    }
                }
            }
            
            let userContentRating:Bool? = featuresDict?["user_content_rating"] as? Bool
            
            if userContentRating != nil {
                
                plistDict["userContentRating"] = userContentRating!
            }
        }
        
        let plistData = NSDictionary(dictionary: plistDict)
        AppSandboxManager.updateGeneralPlist(generalPlistDictionary: plistData)

        #if os(tvOS)
            var iOSJson:String? = appConfigDictionary["appleTv"] as? String
            if iOSJson == nil {
                iOSJson = appConfigDictionary["iOS"] as? String
            }
        #else
            let iOSJson:String? = appConfigDictionary["iOS"] as? String
        #endif
        methodCallback(iOSJson)
    }
    
    func parseiOSConfigurationJson(iOSConfigDictionary: Dictionary<String, AnyObject>, iOSConfigJsonCallback: @escaping ((_ pagesArray: Array<Any>) -> Void), iOSConfigPlistCallback: @escaping((_ pagePlist: Dictionary<String, AnyObject>) -> Void)) -> Void {
        
        let mainConfigDict:Dictionary <String, AnyObject>? = iOSConfigDictionary 
        
        let navigationMenu: Navigation = AppConfiguration.sharedAppConfiguration.navigationMenu
        navigationMenu.navigationDrawerAnimation = 1
        navigationMenu.navigationDrawerCornerRadius = 2
        navigationMenu.navigationDrawerWidth = 200.0
      
        navigationMenu.navigationBackgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        
        let navDictionary = iOSConfigDictionary["navigation"] as? Dictionary<String, Any>
        
        if let settingsDictionary = navDictionary?["settings"] as? Dictionary<String, Any> {
            
            if let primaryCtaDictionary = settingsDictionary["primaryCta"] as? Dictionary<String, Any> {
                
                AppConfiguration.sharedAppConfiguration.pageHeaderObject = PageHeaderObject.init(pageHeaderDictionary: primaryCtaDictionary)
            }
        }
        
        if let leftBarItemArray = navDictionary?["left"] as? Array<Dictionary<String, Any>> {
            
            if let leftNavItems = self.parseNavigationDict(navigationItemsArray: leftBarItemArray) {
                
                if leftNavItems.count > 0 {
                    
                    AppConfiguration.sharedAppConfiguration.leftNavItems = leftNavItems
                }
            }
        }
        
        if let rightBarItemArray = navDictionary?["right"] as? Array<Dictionary<String, Any>> {
            
            if let rightNavItems = self.parseNavigationDict(navigationItemsArray: rightBarItemArray) {
                
                if rightNavItems.count > 0 {
                    
                    AppConfiguration.sharedAppConfiguration.rightNavItems = rightNavItems
                }
            }
        }
        
        let navigationPrimaryArray = navDictionary?["primary"] as? Array<Any>
        var ii = 0
        
        var primaryNavigationItemArray:Array<NavigationItem> = []
        if navigationPrimaryArray != nil && (navigationPrimaryArray?.count)! > 0 {
            for navigationItem in navigationPrimaryArray! {
                let navDictionary = navigationItem  as! Dictionary<String, Any>
                ii = ii + 1
                let navigationMenuItem: NavigationItem = NavigationItem()
                navigationMenuItem.pageId = navDictionary["pageId"] as? String ?? ""
                navigationMenuItem.pageUrl = (navDictionary["url"] as? String) ?? ""
                navigationMenuItem.title = navDictionary["title"] as? String
                navigationMenuItem.displayedPath = navDictionary["displayedPath"] as? String
                navigationMenuItem.type = navigationType.primary
                navigationMenuItem.pageIcon = navDictionary["icon"] as? String ?? ""
                let accessLevelDictionary = navDictionary["accessLevels"] as? Dictionary<String, Any>
                
                navigationMenuItem.loggedIn = accessLevelDictionary?["loggedIn"] as? Bool
                navigationMenuItem.loggedOut = accessLevelDictionary?["loggedOut"] as? Bool
                if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
                {
                    navigationMenuItem.subscribed = accessLevelDictionary?["subscribed"] as? Bool
                }
                let subNavArray = navDictionary["items"] as? Array<Any>
                
                if subNavArray != nil {
                    
                    if (subNavArray?.count)! > 0 {
                        for subNavItem in subNavArray! {
                            let subNavDictionary = subNavItem  as! Dictionary<String, Any>
                            ii = ii + 1
                            let subNavMenuItem: NavigationItem = NavigationItem()
                            let iiNumber = ii as NSNumber
                            subNavMenuItem.pageId = subNavDictionary["pageId"] as? String ?? iiNumber.stringValue
                            subNavMenuItem.pageUrl = (subNavDictionary["url"] as? String) ?? ""
                            subNavMenuItem.title = subNavDictionary["title"] as? String
                            subNavMenuItem.displayedPath = subNavDictionary["displayedPath"] as? String
                            subNavMenuItem.pageIcon = subNavDictionary["icon"] as? String
                            navigationMenuItem.subNavItems.append(subNavMenuItem)
                        }
                    }
                }
                
                #if os(tvOS)
                if navigationMenuItem.displayedPath != "Search Screen" && navigationMenuItem.displayedPath != "Search" {
                    navigationMenu.navigationItems.append(navigationMenuItem)
                    primaryNavigationItemArray.append(navigationMenuItem)
                }
                #else
                    navigationMenu.navigationItems.append(navigationMenuItem)
                    primaryNavigationItemArray.append(navigationMenuItem)
                #endif
            }
        }
        
        if primaryNavigationItemArray.count > 0 {
            
            navigationMenu.navigationItemDict["primary"] = primaryNavigationItemArray
        }
        
        let navigationFooterArray = navDictionary?["footer"] as? Array<Any>
        
        ii = 0
        var footerNavigationItemArray:Array<NavigationItem> = []
        if navigationFooterArray != nil {
            
            for navigationItem in navigationFooterArray! {
                let navDictionary = navigationItem  as! Dictionary<String, Any>
                ii = ii + 1
                let navigationMenuItem: NavigationItem = NavigationItem()
                navigationMenuItem.pageId = navDictionary["pageId"] as? String ?? ""
                navigationMenuItem.pageUrl = (navDictionary["url"] as? String) ?? ""
                navigationMenuItem.title = navDictionary["title"] as? String
                navigationMenuItem.displayedPath = navDictionary["displayedPath"] as? String
                navigationMenuItem.type = navigationType.footer
                navigationMenuItem.pageIcon = navDictionary["icon"] as? String ?? ""
                let accessLevelDictionary = navDictionary["accessLevels"] as? Dictionary<String, Any>
                
                navigationMenuItem.loggedIn = accessLevelDictionary?["loggedIn"] as? Bool
                navigationMenuItem.loggedOut = accessLevelDictionary?["loggedOut"] as? Bool
                
                if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
                {
                    navigationMenuItem.subscribed = accessLevelDictionary?["subscribed"] as? Bool
                }

                let subNavArray = navDictionary["items"] as? Array<Any>
                
                if subNavArray != nil {
                    
                    if (subNavArray?.count)! > 0 {
                        for subNavItem in subNavArray! {
                            let subNavDictionary = subNavItem  as! Dictionary<String, Any>
                            ii = ii + 1
                            let subNavMenuItem: NavigationItem = NavigationItem()
                            let iiNumber = ii as NSNumber
                            subNavMenuItem.pageId = subNavDictionary["pageId"] as? String ?? iiNumber.stringValue
                            subNavMenuItem.pageUrl = (subNavDictionary["url"] as? String) ?? ""
                            subNavMenuItem.title = subNavDictionary["title"] as? String
                            subNavMenuItem.displayedPath = subNavDictionary["displayedPath"] as? String
                            subNavMenuItem.pageIcon = subNavDictionary["icon"] as? String
                            navigationMenuItem.subNavItems.append(subNavMenuItem)
                        }
                    }
                }
                
                footerNavigationItemArray.append(navigationMenuItem)
            }
        }
        
        if footerNavigationItemArray.count > 0 {
            
            navigationMenu.navigationItemDict["footer"] = footerNavigationItemArray
        }
        
        let navigationTabbarArray = navDictionary?["tabBar"] as? Array<Any>
        
        ii = 0
        var tabbarNavigationItemArray:Array<NavigationItem> = []
        if navigationTabbarArray != nil {
            
            for navigationItem in navigationTabbarArray! {
                let navDictionary = navigationItem  as! Dictionary<String, Any>
                ii = ii + 1
                let navigationMenuItem: NavigationItem = NavigationItem()
                navigationMenuItem.pageId = navDictionary["pageId"] as? String ?? ""
                navigationMenuItem.pageUrl = (navDictionary["url"] as? String) ?? ""
                navigationMenuItem.title = navDictionary["title"] as? String
                navigationMenuItem.displayedPath = navDictionary["displayedPath"] as? String
                navigationMenuItem.type = navigationType.footer
                navigationMenuItem.pageIcon = navDictionary["icon"] as? String ?? ""
                let accessLevelDictionary = navDictionary["accessLevels"] as? Dictionary<String, Any>
                
                navigationMenuItem.loggedIn = accessLevelDictionary?["loggedIn"] as? Bool
                navigationMenuItem.loggedOut = accessLevelDictionary?["loggedOut"] as? Bool
                
                if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
                {
                    navigationMenuItem.subscribed = accessLevelDictionary?["subscribed"] as? Bool
                }
                
                let subNavArray = navDictionary["items"] as? Array<Any>
                
                if subNavArray != nil {
                    
                    if (subNavArray?.count)! > 0 {
                        for subNavItem in subNavArray! {
                            let subNavDictionary = subNavItem  as! Dictionary<String, Any>
                            ii = ii + 1
                            let subNavMenuItem: NavigationItem = NavigationItem()
                            let iiNumber = ii as NSNumber
                            subNavMenuItem.pageId = subNavDictionary["pageId"] as? String ?? iiNumber.stringValue
                            subNavMenuItem.pageUrl = (subNavDictionary["url"] as? String) ?? ""
                            subNavMenuItem.title = subNavDictionary["title"] as? String
                            subNavMenuItem.displayedPath = subNavDictionary["displayedPath"] as? String
                            subNavMenuItem.pageIcon = subNavDictionary["icon"] as? String
                            navigationMenuItem.subNavItems.append(subNavMenuItem)
                        }
                    }
                }
                
                tabbarNavigationItemArray.append(navigationMenuItem)
            }
        }
        
        if tabbarNavigationItemArray.count > 0 {
            
            navigationMenu.navigationItemDict["tabBar"] = tabbarNavigationItemArray
        }
        
        let navigationUserArray = navDictionary?["user"] as? Array<Any>
        
        ii = 0
        var userNavigationItemArray:Array<NavigationItem> = []
        if navigationUserArray != nil {
            
            for navigationItem in navigationUserArray! {
                let navDictionary = navigationItem  as! Dictionary<String, Any>
                ii = ii + 1
                let navigationMenuItem: NavigationItem = NavigationItem()
                navigationMenuItem.pageId = navDictionary["pageId"] as? String ?? ""
                navigationMenuItem.pageUrl = (navDictionary["url"] as? String) ?? ""
                navigationMenuItem.title = navDictionary["title"] as? String
                navigationMenuItem.displayedPath = navDictionary["displayedPath"] as? String
                navigationMenuItem.pageIcon = navDictionary["icon"] as? String ?? ""
                navigationMenuItem.type = navigationType.user
                let accessLevelDictionary = navDictionary["accessLevels"] as? Dictionary<String, Any>
                
                navigationMenuItem.loggedIn = accessLevelDictionary?["loggedIn"] as? Bool
                navigationMenuItem.loggedOut = accessLevelDictionary?["loggedOut"] as? Bool
                if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD
                {
                    navigationMenuItem.subscribed = accessLevelDictionary?["subscribed"] as? Bool
                }
                
                let subNavArray = navDictionary["items"] as? Array<Any>
                
                if subNavArray != nil {
                    
                    if (subNavArray?.count)! > 0 {
                        for subNavItem in subNavArray! {
                            let subNavDictionary = subNavItem  as! Dictionary<String, Any>
                            ii = ii + 1
                            let subNavMenuItem: NavigationItem = NavigationItem()
                            let iiNumber = ii as NSNumber
                            subNavMenuItem.pageId = subNavDictionary["pageId"] as? String ?? iiNumber.stringValue
                            subNavMenuItem.pageUrl = (subNavDictionary["url"] as? String) ?? ""
                            subNavMenuItem.title = subNavDictionary["title"] as? String
                            subNavMenuItem.displayedPath = subNavDictionary["displayedPath"] as? String
                            subNavMenuItem.pageIcon = subNavDictionary["icon"] as? String
                            navigationMenuItem.subNavItems.append(subNavMenuItem)
                        }
                    }
                }
                
                userNavigationItemArray.append(navigationMenuItem)
            }
        }

        if !AppConfiguration.sharedAppConfiguration.isDownloadEnabled!
        {
            var ii = 0
            for navigation in userNavigationItemArray
            {
                if navigation.displayedPath == "My Downloads"
                {
                    userNavigationItemArray.remove(at: ii)
                }
                ii = ii + 1
            }
        }
        
        if userNavigationItemArray.count > 0 {

            navigationMenu.navigationItemDict["user"] = userNavigationItemArray
        }

        let pagesArray = iOSConfigDictionary["pages"] as? Array<Any>
        var pagesCount = 0
        if pagesArray != nil && (pagesArray?.count)! > 0 {
            for page in pagesArray! {
                let pageDictionary = page  as! Dictionary<String, Any>
                pagesCount = pagesCount + 1
                let pageItem: Page = Page.init(pageString: Constants.kSTRING_PAGETYPE_MODULAR)
                pageItem.pageId = pageDictionary["Page-ID"] as? String
                pageItem.pageUI = (pageDictionary["Page-UI"] as? String)!
                pageItem.pageVersion = pageDictionary["version"] as? String
                pageItem.pageName = pageDictionary["Page-Name"] as? String
                pageItem.pageAPI = pageDictionary["Page-API"] as? String
                pageItem.pageVersion = pageDictionary["version"] as? String
                
                AppConfiguration.sharedAppConfiguration.pages.append(pageItem)
            }
        }

        let moduleUIBlock: ModulesUIBlocks = ModulesUIBlocks.init()
        moduleUIBlock.moduleUIUrl = iOSConfigDictionary["blocksBundleUrl"] as? String
        moduleUIBlock.moduleUIVersion = iOSConfigDictionary["blocksVersion"] as? String
        
        AppConfiguration.sharedAppConfiguration.modulesUIBlock = moduleUIBlock
        
        AppConfiguration.sharedAppConfiguration.navigationMenu = navigationMenu

        let pagesJsonArray: Array? = mainConfigDict?["pages"] as? Array<AnyObject>
        if pagesJsonArray == nil {
            iOSConfigJsonCallback([])
        } else {
            iOSConfigJsonCallback(pagesJsonArray!)
        }
        
        var plistDict: Dictionary<String,Any> = [:]
        
        plistDict["version"] = mainConfigDict?["version"] as? String ?? "1.0"
        
        let analyticsDict:Dictionary<String, AnyObject>? = mainConfigDict?["analytics"] as? Dictionary<String, AnyObject>
        plistDict["googleAnalyticsId"] = analyticsDict?["googleAnalyticsId"] as? String
        
        let shortAppName:String? = mainConfigDict?["shortAppName"] as? String
        if shortAppName != nil {
            plistDict["shortAppName"] = shortAppName
        }
        let googleTagManagerId:String? = analyticsDict?["googleTagManagerId"] as? String
        
        if googleTagManagerId != nil {
            
            plistDict["googleTagManagerId"] = googleTagManagerId!
        }
        
        let adVertisingDict:Dictionary<String, AnyObject>? = mainConfigDict?["advertising"] as? Dictionary<String, AnyObject>
        if adVertisingDict != nil {
            plistDict["videoAdTag"] = adVertisingDict?["videoTag"] as? String
        }
        
        if let subscriptionFlowContentDict = mainConfigDict?["subscription_flow_content"] as? Dictionary<String, AnyObject> {
            
            if let overlayMessageContent = subscriptionFlowContentDict["overlay_message"] as? String {
                
                plistDict["overlay_message"] = overlayMessageContent
            }
            
            if let subscriptionButtonText = subscriptionFlowContentDict["subscription_button_text"] as? String {
                
                plistDict["subscription_button_text"] = subscriptionButtonText
            }
            
            if let loginButtonText = subscriptionFlowContentDict["login_button_text"] as? String {
                
                plistDict["login_button_text"] = loginButtonText
            }
        }
        
        plistDict["pages"] = pagesJsonArray
        iOSConfigPlistCallback(plistDict as Dictionary<String, AnyObject>)
    }

    
    private func parseNavigationDict(navigationItemsArray:Array<Dictionary<String, Any>>) -> Array<SFNavigationObject>? {
        
        var navItemArray:Array<SFNavigationObject> = []
        
        for navDict in navigationItemsArray {
            
            let navObject = SFNavigationObject.init(navDictionary: navDict)
            navItemArray.append(navObject)
        }
        
        return navItemArray
    }
    
    
    class func retrunVersionOfJsonFile(fileData: Data) -> String
    {
        var fileVersion: String = ""
        let jsonFile = try? JSONSerialization.jsonObject(with: fileData)
        if let jsonDictionary = jsonFile as? [String: Any] {
            fileVersion = jsonDictionary["version"] as? String ?? "0.0"
        }
        return fileVersion
    }
}
