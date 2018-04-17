//
//  AppConfiguration.swift
//  SwiftPOCConfiguration
//
//  Created by Abhinav Saldi on 02/03/17.
//  Copyright © 2017 Abhinav Saldi. All rights reserved.
//

import Foundation

enum TypeOfPreview {
    case completeApplication
    case perVideo
}

class AppConfiguration: NSObject
{
    static let sharedAppConfiguration = AppConfiguration()
    
    private override init() {
//        self.pages = []
        self.pageViewControllers = []
        #if os(iOS)
        self.countryDialCodesArray = []
        #endif
        navigationMenu = Navigation.init()
        appHasTabBar = true
    }
    
    //MARK: Properties
    var appHasTabBar: Bool
    var navigationMenu: Navigation
    var appConfigVersion: Double?
    
    var backgroundColor: String?
    var themeFontColor: String?
    var jumbotronPageControlColor: String?
    var thumbnailProgressColor: String?
    var moviePlayerSliderColor: String?
    var pageTitleColor: String?
    var trayTitleColor: String?
    var trayPageNoColor: String?
    var productsPlanPageColor: String?
    var navigationBarColor: String?
    var appTextColor: String?
    var appDefaultSelectionThemeColor:String?
    var appBlockTitleColor:String?
    var appPageTitleColor:String?
    var primaryButton = PrimaryButton()
    var durationMetaData = DurationMetaData()
    var secondaryButton = SecondaryButton()
    var siteId:String?
    var googleClientId:String?
    var primaryHoverColor:String?
    var isUserDetailUpdated: Bool = false
    var isGoogleSignEnabled: Bool = false
    var videoPreviewDuration:String?
    var isVideoPreviewAvailable:Bool?
    var isVideoPreviewPerVideo:Bool?
    var appFontFamily: String?
    
    var appMinimumVersionNumber:String?
    var appAppStoreVersionNumber:String?
    var appStoreUrl:String?
    private var _templateType:String?
    private var _cachedAPIToken:String?
    
    var cachedAPIToken:String? {
        
        get {
            
            if _cachedAPIToken == nil {
                let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!)!
                let token = dicRoot["CachedAPIToken"]
                if token != nil {
                    _cachedAPIToken = token as? String
                }
            }
            return _cachedAPIToken
        }
    }
    
    var templateType:String? {
        get {
            if _templateType == nil {
                let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!)!
                var type = dicRoot["TemplateType"]
                if type == nil {
                    type = Constants.kTemplateTypeEntertainment
                }
                _templateType = type as? String
            }
            return _templateType
        }
    }

//    private var _typeOfPreview:TypeOfPreview?
    var typeOfPreview:TypeOfPreview? //{
//        get {
//            let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!)!
//            let type = dicRoot["TypeOfPreview"] as? String
//            if type != nil && type == "COMPLETE" {
//                _typeOfPreview = .completeApplication
//            } else {
//                _typeOfPreview = .perVideo
//            }
//            return _typeOfPreview
//        }
//    }
    private var _isPIPAvailable:Bool?
    var isPIPAvailable: Bool {
        get {
            let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!)!
            let type = dicRoot["isPIPRequired"] as? Bool
            if type != nil {
                _isPIPAvailable = type
            } else {
                _isPIPAvailable = false
            }
            return _isPIPAvailable!
        }
    }
    
    private var _urbanAirshipChurnAvailable:Bool?
    var urbanAirshipChurnAvailable: Bool {
        get {
            let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!)!
            let type = dicRoot["UrbanAirshipChurnTagAvailable"] as? Bool
            if type != nil {
                _urbanAirshipChurnAvailable = type
            } else {
                _urbanAirshipChurnAvailable = false
            }
            return _urbanAirshipChurnAvailable!
        }
    }
    
    private var _urbanAirshipProdMasterKey:String?
    var urbanAirshipProdMasterKey: String? {
        get {
            let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!)!
            let type = dicRoot["UrbanAirshipProdMasterKey"] as? String
            
            if type != nil {
                _urbanAirshipProdMasterKey = type
            }
            
            return _urbanAirshipProdMasterKey
        }
    }
    
    private var _urbanAirshipDevMasterKey:String?
    var urbanAirshipDevMasterKey: String? {
        get {
            let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!)!
            let type = dicRoot["UrbanAirshipDevMasterKey"] as? String
            if type != nil {
                _urbanAirshipDevMasterKey = type
            }
            
            return _urbanAirshipDevMasterKey
        }
    }
    
//    private var _appTheme:AppTheme?
    var appTheme: AppTheme?
//    {
//        get {
//            let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!)!
//            let type = dicRoot["AppTheme"] as? String
//            _appTheme = .dark
//            if type != nil {
//                if type?.lowercased() == "light" {
//                    _appTheme = .light
//                }
//            }
//            return _appTheme
//        }
//    }
    
    var pageHeaderObject:PageHeaderObject?
    var rightNavItems:Array<SFNavigationObject>?
    var leftNavItems:Array<SFNavigationObject>?
    
    struct DurationMetaData
    {
        var displayDuration: Bool?
        var displayAuthor: Bool?
        var displayPublishDate: Bool?
    }
    
    struct PrimaryButton
    {
        var backgroundColor: String?
        var textColor: String?
        var borderColor: String?
        var borderSelectedColor: String?
        var borderUnselectedColor: String?
        var borderWidth: Float?
        var selectedColor: String?
        var unselectedColor: String?
    }
    
    struct SecondaryButton
    {
        var backgroundColor: String?
        var textColor: String?
        var borderColor: String?
        var selectedColor: String?
        var unselectedColor: String?
        var borderSelectedColor: String?
        var borderUnselectedColor: String?
        var borderWidth: Float?
    }
    
    struct SubscriptionOverlayTextObject
    {
        var overlayMessage:String?
        var subscriptionButtonText:String?
        var loginButtonText:String?
    }
    
    var isTrayInfoPresent: Bool = false

    var configFileTimestamp:Double?
    
    var apiAccessKey: String?
    var apiBaseUrl: String?
    var apiCachedBaseUrl: String?
    var facebookID: String?
    var sitename: String?
    var appName: String?
    var apiClientName:String?
    var customerServiceEmail:String?
    var customerServicePhone:String?
    var apiSecretKey:String?
    var appShareName:String?
    var companyName:String?
    var domainName:String?
    var techEmailFeedback:String?
    var faqUrl:String?
    var internalName:String?
    var googleAnalyticsId:String?
    var googleTagManagerId:String?
    
    var videoAdTag:String?
    var forceLogin:Bool?
    var isDownloadEnabled: Bool?
    var shortAppName:String?
    var isContentRatingEnabled:Bool?
    
    var serviceType: serviceType?    
    
    var pageName: String?
    var pages : Array<Page> = []
    var modulesUIBlock : ModulesUIBlocks?
    
    var pageViewControllers: Array<Any>

    #if os(iOS)
    var countryDialCodesArray: Array<SFCountryDialModel>
    #endif
    var isAppInProduction:Bool = true
    var beaconObject:Beacon?
    
    struct AppLogo {
        var logoVersion: String?
        var logoUrl: String?
    }
    
    struct TextField
    {
        var selectedColor: String?
        var unselectedColor: String?
        var textColor: String?
        var borderSelectedColor: String?
        var borderUnselectedColor: String?
    }

    struct Beacon
    {
        var apiBaseUrl: String?
        var clientId: String?
        var siteName: String?
    }
    
    var linkColor: String?
    
    var applicationType: String?
    var applicationSupportsSubscriptionToVideosCheck :Bool = false
    var subscriptionOverlayObject:SubscriptionOverlayTextObject?
    
    func createAppConfigurationPlist () {
        
        let mainConfigFilePath = AppSandboxManager.readGeneralPlistFile()
        let mainConfigDict:Dictionary<String, AnyObject>? = NSDictionary(contentsOfFile: mainConfigFilePath) as? Dictionary <String, AnyObject>
        
        if mainConfigDict != nil {
            
            apiAccessKey = mainConfigDict?["accessKey"] as? String
            apiBaseUrl = mainConfigDict?["apiBaseUrl"] as? String
            apiCachedBaseUrl = mainConfigDict?["apiCacheBaseUrl"] as? String

            apiClientName = mainConfigDict?["apiClientName"] as? String
            
            if beaconObject == nil {
                beaconObject = Beacon()
            }
            beaconObject?.apiBaseUrl = mainConfigDict?["beaconApiBaseUrl"] as? String
            beaconObject?.clientId = mainConfigDict?["beaconClientId"] as? String
            beaconObject?.siteName = mainConfigDict?["beaconSiteName"] as? String
            
            //apiSecretKey = mainConfigDict?["secretKey"] as? String
            
            customerServiceEmail = mainConfigDict?["email"] as? String
            customerServicePhone = mainConfigDict?["phone"] as? String
            
            appShareName = mainConfigDict?["appShareName"] as? String
            companyName = mainConfigDict?["companyName"] as? String
            domainName = mainConfigDict?["domainName"] as? String
            techEmailFeedback = mainConfigDict?["emailFeedbackTech"] as? String
            faqUrl = mainConfigDict?["faqUrl"] as? String
            
            if mainConfigDict?["internalName"] as? String != nil {
                
                internalName = mainConfigDict?["internalName"] as? String
            }
            
            if mainConfigDict?["site"] as? String != nil {
                
                sitename = mainConfigDict?["site"] as? String
            }
            
            appConfigVersion = mainConfigDict?["version"] as? Double
            
            backgroundColor = mainConfigDict?["backgroundColor"] as? String
            appTextColor = mainConfigDict?["textColor"] as? String
            //Set App Theme.
            appTheme = AppThemeProvider.getAppTheme(backgroundColorHex: backgroundColor ?? "000000")
            
            appDefaultSelectionThemeColor = mainConfigDict?["appDefaultSelectionThemeColor"] as? String
            appBlockTitleColor = mainConfigDict?["blockTitleColor"] as? String
            appPageTitleColor = mainConfigDict?["pageTitleColor"] as? String
            if let strFont = mainConfigDict?["fontFamily"] as? String{
                appFontFamily = strFont.replacingOccurrences(of: " ", with: "")
            }
            
            siteId = mainConfigDict?["siteId"] as? String
            videoPreviewDuration = mainConfigDict?["previewDuration"] as? String
            
            let isPreviewPerVideo = mainConfigDict?["previewPerVideo"] as? Bool ?? false
            
            typeOfPreview = isPreviewPerVideo ? .perVideo : .completeApplication
            
            isContentRatingEnabled = mainConfigDict?["userContentRating"] as? Bool
            isVideoPreviewPerVideo = mainConfigDict?["per_video"] as? Bool
            isVideoPreviewAvailable = mainConfigDict?["previewAvailable"] as? Bool
            appMinimumVersionNumber = mainConfigDict?["minimumAppVersion"] as? String
            appAppStoreVersionNumber = mainConfigDict?["latestAppVersion"] as? String
            appStoreUrl = mainConfigDict?["appStoreUrl"] as? String
            //update templateType to configure app for particular template type
            //templateType = "ENTERTAINMENT"
//            templateType = "SPORTS"
            configureCountryCodes()
        }
        
        let platformConfigPath = AppSandboxManager.readPlatformPlistFile()
        let platformConfigDict:Dictionary<String, AnyObject>? = NSDictionary(contentsOfFile: platformConfigPath) as? Dictionary <String, AnyObject>
        
        if platformConfigDict != nil {
            
            googleAnalyticsId = platformConfigDict?["googleAnalyticsId"] as? String
            googleTagManagerId = platformConfigDict?["googleTagManagerId"] as? String
            videoAdTag = platformConfigDict?["videoAdTag"] as? String
            shortAppName = platformConfigDict?["shortAppName"] as? String
            
            if subscriptionOverlayObject == nil {
                
                subscriptionOverlayObject = SubscriptionOverlayTextObject()
            }
            
            subscriptionOverlayObject?.overlayMessage = platformConfigDict?["overlay_message"] as? String
            subscriptionOverlayObject?.subscriptionButtonText = platformConfigDict?["subscription_button_text"] as? String
            subscriptionOverlayObject?.loginButtonText = platformConfigDict?["login_button_text"] as? String
        }
    }
    
    func configureCountryCodes() -> Void {
        #if os(iOS)
        let countryParser: SFCountryDialParser = SFCountryDialParser()
        let filePath: String = (Bundle.main.resourcePath?.appending("/CountryDialCodes.json"))!
        
        if FileManager.default.fileExists(atPath: filePath){
            let jsonData:Data = FileManager.default.contents(atPath: filePath)!
            let responseJson:Array<Dictionary<String, AnyObject>> = try! JSONSerialization.jsonObject(with:jsonData) as! Array<Dictionary<String, AnyObject>>
            AppConfiguration.sharedAppConfiguration.countryDialCodesArray = countryParser.parseCountryDialCodes(countryDialContentJsonArray: responseJson as Array<AnyObject>)
        }
        #endif
    }
}
