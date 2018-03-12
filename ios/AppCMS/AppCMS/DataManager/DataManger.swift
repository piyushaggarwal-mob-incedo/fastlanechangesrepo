//
//  DataManger.swift
//  AppCMS
//
//  Created by Gaurav Vig on 31/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import Alamofire

class DataManger: NSObject {

    static let sharedInstance:DataManger = {
        
        let instance = DataManger()
        
        return instance
    }()
    
    
    //MARK: API to fetch video details
    func getVideoDetailById(shouldUseCacheUrl:Bool, apiEndPoint:String,responseForConfiguration : @escaping((_ responseConfigData : Array<AnyObject>?,_ filmObject : SFFilm?) -> Void))
    {
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_getVideoDetailById(shouldUseCacheUrl: shouldUseCacheUrl, apiEndPoint: apiEndPoint, requestHeaders: authorizationTokenHeader ,responseForConfiguration: responseForConfiguration)
        })
    }
    
    func net_getVideoDetailById(shouldUseCacheUrl:Bool, apiEndPoint:String, requestHeaders:HTTPHeaders? ,responseForConfiguration : @escaping((_ responseConfigData : Array<AnyObject>?,_ filmObject : SFFilm?) -> Void)) {
        
        var apiUrl:String = (shouldUseCacheUrl == true) ? (AppConfiguration.sharedAppConfiguration.apiCachedBaseUrl ?? AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "") : (AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")
        apiUrl.append(apiEndPoint)
        
        var updatedRequestHeader:HTTPHeaders? = requestHeaders
        
        if shouldUseCacheUrl == true {
            
            apiUrl.append("&gzip=true")
            
            if let cacheToken = AppConfiguration.sharedAppConfiguration.cachedAPIToken{
                
                if !Utility.sharedUtility.checkIfUserIsLoggedIn() && !Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                    updatedRequestHeader = nil
                    updatedRequestHeader = ["Authorization" : cacheToken]
                }
            }
        }
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiUrl, requestType: .get, requestHeaders:updatedRequestHeader, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil && isSuccess
            {
                let pageContentJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if pageContentJson is Dictionary<String,AnyObject> {
                    
                    let pageContentDict:Dictionary<String,AnyObject>? = pageContentJson as? Dictionary<String,AnyObject>
                    let recordsArray  = pageContentDict?["records"] as? Array<AnyObject>
                    
                    let dict:Dictionary<String,AnyObject>? = recordsArray?[0] as? Dictionary<String,AnyObject>
                    
                    if dict != nil {
                        let filmObject:SFFilm? = PageAPIParser.sharedInstance.parseFilmDetailsAPIContent(filmContentJson: (dict)! )
                        
                        let contentDetailsDict:Dictionary<String,AnyObject>? = dict?["contentDetails"] as? Dictionary<String, AnyObject>
                        let relatedVideos:Array<AnyObject>? =  contentDetailsDict?["relatedVideoIds"] as? Array<AnyObject>
                        responseForConfiguration(relatedVideos,filmObject)
                    }
                    else {
                        
                        responseForConfiguration(nil, nil)
                    }
                }
                else {
                    
                    responseForConfiguration(nil, nil)
                }
            }
            else
            {
                responseForConfiguration(nil, nil)
            }
        }
    }
    
    
    //MARK: Api to fetch page details
    func fetchContentForPage(shouldUseCacheUrl:Bool, apiEndPoint:String, pageAPIResponse: @escaping ((_ pageAPIObjectResponse: PageAPIObject?) -> Void)) -> Void {

        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_fetchContentForPage(shouldUseCacheUrl: shouldUseCacheUrl, apiEndPoint: apiEndPoint, requestHeaders:authorizationTokenHeader, pageAPIResponse: pageAPIResponse)
        })
    }
    
    
    func net_fetchContentForPage(shouldUseCacheUrl:Bool, apiEndPoint:String, requestHeaders:HTTPHeaders?, pageAPIResponse: @escaping ((_ pageAPIObjectResponse: PageAPIObject?) -> Void)) -> Void {
        
        var apiUrl:String = (shouldUseCacheUrl == true) ? (AppConfiguration.sharedAppConfiguration.apiCachedBaseUrl ?? AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "") : (AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")
        apiUrl.append(apiEndPoint)
        
        var updatedRequestHeader:HTTPHeaders? = requestHeaders
        
        if shouldUseCacheUrl == true {
            
            apiUrl.append("&gzip=true")
            
            if let cacheToken = AppConfiguration.sharedAppConfiguration.cachedAPIToken {
                
                if !Utility.sharedUtility.checkIfUserIsLoggedIn() && !Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                    updatedRequestHeader = nil
                    updatedRequestHeader = ["Authorization" : cacheToken]
                }
            }
        }
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiUrl, requestType: .get, requestHeaders:updatedRequestHeader, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil && isSuccess
            {
                let pageContentJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if pageContentJson is Dictionary<String,AnyObject> {
                    
                    let pageContentDict:Dictionary<String,AnyObject>? = pageContentJson as? Dictionary<String,AnyObject>
                    
                    if pageContentDict != nil {
                        
                        let pageAPIObject:PageAPIObject = PageAPIParser.sharedInstance.parsePageAPIContent(pageContentJson: pageContentDict!)
                        pageAPIResponse(pageAPIObject)
                    }
                    else {
                        
                        pageAPIResponse(nil)
                    }
                }
                else {
                    
                    pageAPIResponse(nil)
                }
            }
            else
            {
                pageAPIResponse(nil)
            }
        }
    }
    
    
    //MARK: Api to fetch Video page details
    func fetchContentForVideoPage(shouldUseCacheUrl:Bool, apiEndPoint:String, pageAPIResponse: @escaping ((_ pageAPIObjectResponse: PageAPIObject?, _ errorMessage:String?, _ isSuccess:Bool) -> Void)) -> Void {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_fetchContentForVideoPage(shouldUseCacheUrl: shouldUseCacheUrl, apiEndPoint: apiEndPoint, requestHeaders: authorizationTokenHeader, pageAPIResponse: pageAPIResponse)
        })
    }
    
    
    func net_fetchContentForVideoPage(shouldUseCacheUrl:Bool, apiEndPoint:String, requestHeaders:HTTPHeaders?, pageAPIResponse: @escaping ((_ pageAPIObjectResponse: PageAPIObject?, _ errorMessage:String?, _ isSuccess:Bool) -> Void)) -> Void {
        
        var apiUrl:String = (shouldUseCacheUrl == true) ? (AppConfiguration.sharedAppConfiguration.apiCachedBaseUrl ?? AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "") : (AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")
        apiUrl.append(apiEndPoint)
        
        var updatedRequestHeader:HTTPHeaders? = requestHeaders
        
        if shouldUseCacheUrl == true {
            
            apiUrl.append("&gzip=true")
            
            if let cacheToken = AppConfiguration.sharedAppConfiguration.cachedAPIToken {
                
                if !Utility.sharedUtility.checkIfUserIsLoggedIn() && !Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                    updatedRequestHeader = nil
                    updatedRequestHeader = ["Authorization" : cacheToken]
                }
            }
        }
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiUrl, requestType: .get, requestHeaders:updatedRequestHeader, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil
            {
                let pageContentJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if pageContentJson is Dictionary<String,AnyObject> {
                    
                    let pageContentDict:Dictionary<String,AnyObject>? = pageContentJson as? Dictionary<String,AnyObject>
                    
                    if pageContentDict != nil {
                        
                        if isSuccess == true {
                            
                            let pageAPIObject:PageAPIObject = PageAPIParser.sharedInstance.parseVideoPageAPIContent(pageContentJson: pageContentDict!)
                            pageAPIResponse(pageAPIObject, nil, isSuccess)
                        }
                        else {
                            
                            var errorMessage:String?
                            
                            if let errorCode = pageContentDict?["code"] as? String {
                                
                                if errorCode == "500" {
                                    
                                    if let apiErrorMessage = pageContentDict?["message"] as? String {
                                        
                                        errorMessage = apiErrorMessage
                                    }
                                }
                            }
                            
                            pageAPIResponse(nil, errorMessage, isSuccess)
                        }
                    }
                    else {
                        
                        pageAPIResponse(nil, nil, false)
                    }
                }
                else {
                    
                    pageAPIResponse(nil, nil, false)
                }
            }
            else
            {
                pageAPIResponse(nil, nil, false)
            }
        }
    }
    
    
    //MARK: Api to fetch video content
    func fetchContentForVideo(shouldUseCacheUrl:Bool, apiEndPoint:String, filmAPIResponse: @escaping ((_ filmObject: SFFilm?) -> Void)) -> Void  {
        
        var requestHeader:HTTPHeaders?
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) != nil {
            requestHeader = ["Authorization" : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) as! String]
        }
        
        var apiUrl:String = (shouldUseCacheUrl == true) ? (AppConfiguration.sharedAppConfiguration.apiCachedBaseUrl ?? AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "") : (AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")
        apiUrl.append(apiEndPoint)
        
        var updatedRequestHeader:HTTPHeaders? = requestHeader
        
        if shouldUseCacheUrl == true {
            
            apiUrl.append("&gzip=true")
            
            if let cacheToken = AppConfiguration.sharedAppConfiguration.cachedAPIToken {
                
                if !Utility.sharedUtility.checkIfUserIsLoggedIn() && !Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                    updatedRequestHeader = nil
                    updatedRequestHeader = ["Authorization" : cacheToken]
                }
            }
        }
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiUrl, requestType: .get, requestHeaders:updatedRequestHeader, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil {
                
                let filmContentJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if filmContentJson is Dictionary<String,AnyObject> {
                    
                    let filmContentDict:Dictionary<String,AnyObject>? = filmContentJson as? Dictionary<String,AnyObject>
                    
                    if filmContentDict != nil {
                        
                        let filmObject:SFFilm? = PageAPIParser.sharedInstance.parseFilmDetailsAPIContent(filmContentJson: filmContentDict!)
                        
                        if filmObject != nil {
                            
                            let _:Bool = DBManager.sharedInstance.updateDatabaseWithFilmObject(filmObject: filmObject!);
                            
                            filmAPIResponse(filmObject)
                        }
                        else {
                            
                            filmAPIResponse(nil)
                        }
                    }
                    else {
                        
                        filmAPIResponse(nil)
                    }
                }
                else {
                    
                    filmAPIResponse(nil)
                }
            }
            else {
                
                filmAPIResponse(nil)
            }
        }
    }
    
    
    //MARK: Api to fetch video urls
    func fetchURLDetailsForVideo(apiEndPoint:String, filmURLResponse: @escaping ((_ videoURLWithStatusDict: Dictionary<String, Any>?) -> Void)) -> Void {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_fetchURLDetailsForVideo(apiEndPoint: apiEndPoint, requestHeaders:authorizationTokenHeader, filmURLResponse: filmURLResponse)
        })
    }

    
    func net_fetchURLDetailsForVideo(apiEndPoint:String, requestHeaders:HTTPHeaders?, filmURLResponse: @escaping ((_ videoURLWithStatusDict: Dictionary<String, Any>?) -> Void)) -> Void {

        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .get, requestHeaders:requestHeaders, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil && isSuccess {
                
                let filmURLJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if filmURLJson is Dictionary<String,AnyObject> {
                    
                    let filmURLDict:Dictionary<String,AnyObject>? = filmURLJson as? Dictionary<String,AnyObject>

                    if filmURLDict != nil {
                        
                        let videoURLWithStatusDict:Dictionary<String, Any>? = PageAPIParser.sharedInstance.parseVideoURLAPIContent(filmURLContentJson: filmURLDict!)
                        
                        if videoURLWithStatusDict != nil {
                            filmURLResponse(videoURLWithStatusDict)
                        }
                        else {
                            filmURLResponse(nil)
                        }
                    }
                    else {
                        filmURLResponse(nil)
                    }
                }
                else {
                 
                    filmURLResponse(nil)
                }
            }
            else {
                
                filmURLResponse(nil)
            }
        }
    }
    
    
    //MARK: Api to fetch video urls
    func fetchDownloadURLDetailsForVideo(apiEndPoint:String, filmObject:SFFilm, filmResponse: @escaping ((_ filmObject:SFFilm) -> Void)) -> Void {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_fetchDownloadURLDetailsForVideo(apiEndPoint: apiEndPoint, filmObject:filmObject, requestHeaders:authorizationTokenHeader, filmResponse: filmResponse)
        })
    }
    
    
    private func net_fetchDownloadURLDetailsForVideo(apiEndPoint:String, filmObject:SFFilm, requestHeaders:HTTPHeaders?, filmResponse: @escaping ((_ filmObject:SFFilm) -> Void)) -> Void {
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .get, requestHeaders:requestHeaders, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil && isSuccess {
                
                let filmURLJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if filmURLJson is Dictionary<String,AnyObject> {
                    
                    let filmURLDict:Dictionary<String,AnyObject>? = filmURLJson as? Dictionary<String,AnyObject>
                    
                    if filmURLDict != nil {
                        
                        let updatedFilmObject:SFFilm = PageAPIParser.sharedInstance.parseDownloadURLsAPIContent(filmURLsContentJson: filmURLDict!, filmObject: filmObject)
                        
                        filmResponse(updatedFilmObject)
                    }
                    else {
                        filmResponse(filmObject)
                    }
                }
                else {
                    
                    filmResponse(filmObject)
                }
            }
            else {
                
                filmResponse(filmObject)
            }
        }
    }
    
    
    //MARK: Api to fetch video urls
    func fetchSubTitleDetailsForVideo(apiEndPoint:String, filmURLResponse: @escaping ((_ subTitleUrl: Dictionary<String, AnyObject>?) -> Void)) -> Void {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_fetchSubTitleURLDetailsForVideo(apiEndPoint: apiEndPoint, requestHeaders:authorizationTokenHeader, filmSubTitleURLResponse: filmURLResponse)
        })
    }
    
    
    func net_fetchSubTitleURLDetailsForVideo(apiEndPoint:String, requestHeaders:HTTPHeaders?, filmSubTitleURLResponse: @escaping ((_ filmSubTitleURL: Dictionary<String, AnyObject>?) -> Void)) -> Void {
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .get, requestHeaders:requestHeaders, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil && isSuccess {
                
                let filmSubTitleURLJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if filmSubTitleURLJson is Dictionary<String,AnyObject> {
                    
                    let filmSubTitleURLDict:Dictionary<String,AnyObject>? = filmSubTitleURLJson as? Dictionary<String,AnyObject>
                    
                    if filmSubTitleURLDict != nil {
                        
                        let filmSubTitleURL:Dictionary<String, AnyObject>? = PageAPIParser.sharedInstance.parseVideoSubTitleURLAPIContent(filmContentJson: filmSubTitleURLDict!)
                        
                        if filmSubTitleURL != nil {
                            
                            filmSubTitleURLResponse(filmSubTitleURL)
                        }
                        else {
                            
                            filmSubTitleURLResponse(nil)
                        }
                    }
                    else {
                        
                        filmSubTitleURLResponse(nil)
                    }
                }
                else {
                    
                    filmSubTitleURLResponse(nil)
                }
            }
            else {
                
                filmSubTitleURLResponse(nil)
            }
        }
    }
 
    
    //MARK: Api to fetch typeahead search results
    func fetchTypeAheadSearchResults(shouldUseCacheUrl:Bool, apiEndPoint:String, searchResults: @escaping ((_ results: SFModuleObject?) -> Void)) {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_fetchTypeAheadSearchResults(shouldUseCacheUrl: shouldUseCacheUrl, apiEndPoint: apiEndPoint, requestHeaders: authorizationTokenHeader, searchResults: searchResults)
        })
    }
    
    
    func net_fetchTypeAheadSearchResults(shouldUseCacheUrl:Bool, apiEndPoint:String, requestHeaders:HTTPHeaders?, searchResults: @escaping ((_ results: SFModuleObject?) -> Void))  {
        
        var apiUrl:String = (shouldUseCacheUrl == true) ? (AppConfiguration.sharedAppConfiguration.apiCachedBaseUrl ?? AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "") : (AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")
        apiUrl.append(apiEndPoint)
        
        if shouldUseCacheUrl == true {
            
            apiUrl.append("&gzip=true")
        }
        
        NetworkHandler.sharedInstance.callNetworkForSearchResults(apiURL: apiUrl, requestHeaders: requestHeaders) { (_ responseConfigData: Data?, _ isSuccess:Bool) in
            
            if responseConfigData != nil {
                
                if isSuccess {
                    
                    let searchResultJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                    
                    if searchResultJson is Array<AnyObject> {
                        
                        let searchResultArray:Array<AnyObject>? = searchResultJson as? Array<AnyObject>
                        
                        if searchResultArray != nil {
                            
                            let parsedSearchResults = PageAPIParser.sharedInstance.parseTypeAheadSearchResults(searchResults: searchResultArray!)
                            
                            searchResults(parsedSearchResults)
                        }
                        else {
                            
                            searchResults(nil)
                        }
                    }
                    else {
                        
                        searchResults(nil)
                    }
                }
                else {
                    
                    searchResults(nil)
                }
            }
            else {
                
                searchResults(nil)
            }
        }
    }
    
    
    //MARK: Api to ancillary page details
    func fetchContentForAncillaryPage(shouldUseCacheUrl:Bool, apiEndPoint:String, pageAPIResponse: @escaping ((_ pageAPIObjectResponse: PageAPIObject?) -> Void)) -> Void {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_fetchContentForAncillaryPage(shouldUseCacheUrl: shouldUseCacheUrl, apiEndPoint: apiEndPoint, requestHeaders: authorizationTokenHeader, pageAPIResponse: pageAPIResponse)
        })
    }
    
    
    func net_fetchContentForAncillaryPage(shouldUseCacheUrl:Bool, apiEndPoint:String, requestHeaders:HTTPHeaders?, pageAPIResponse: @escaping ((_ pageAPIObjectResponse: PageAPIObject?) -> Void)) -> Void {
        
        var apiUrl:String = (shouldUseCacheUrl == true) ? (AppConfiguration.sharedAppConfiguration.apiCachedBaseUrl ?? AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "") : (AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")
        apiUrl.append(apiEndPoint)
        
        if shouldUseCacheUrl == true {
            
            apiUrl.append("&gzip=true")
        }
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiUrl, requestType: .get, requestHeaders:requestHeaders, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil && isSuccess
            {
                let pageContentJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if pageContentJson is Dictionary<String,AnyObject> {
                    
                    let pageContentDict:Dictionary<String,AnyObject>? = pageContentJson as? Dictionary<String,AnyObject>
                    
                    if pageContentDict != nil {
                        
                        let pageAPIObject:PageAPIObject = PageAPIParser.sharedInstance.parseAncillaryPageAPIContent(pageContentJson: pageContentDict!)
                        pageAPIResponse(pageAPIObject)
                    }
                    else {
                        
                        pageAPIResponse(nil)
                    }
                }
                else {
                    
                    pageAPIResponse(nil)
                }
            }
            else
            {
                pageAPIResponse(nil)
            }
        }
    }
    
    
    func net_fetchHtmlContentForAPI(shouldUseCacheUrl:Bool, apiEndPoint:String, requestHeaders:HTTPHeaders?, pageAPIResponse: @escaping ((_ pageAPIObjectResponse: PageAPIObject?) -> Void)) -> Void {
        
        var apiUrl:String = (shouldUseCacheUrl == true) ? (AppConfiguration.sharedAppConfiguration.apiCachedBaseUrl ?? AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "") : (AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")
        apiUrl.append(apiEndPoint)
        
        if shouldUseCacheUrl == true {
            
            apiUrl.append("&gzip=true")
        }
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiUrl, requestType: .get, requestHeaders:requestHeaders, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil
            {
                let pageContentJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if pageContentJson is Dictionary<String,AnyObject> {
                    
                    let pageContentDict:Dictionary<String,AnyObject>? = pageContentJson as? Dictionary<String,AnyObject>
                    
                    if pageContentDict != nil {
                        
                        let pageAPIObject:PageAPIObject = PageAPIParser.sharedInstance.parseAncillaryPageAPIContent(pageContentJson: pageContentDict!)
                        pageAPIResponse(pageAPIObject)
                    }
                    else {
                        
                        pageAPIResponse(nil)
                    }
                }
                else {
                    
                    pageAPIResponse(nil)
                }
            }
            else
            {
                pageAPIResponse(nil)
            }
        }
    }
    
    
    //MARK: Api to post beacon data
    func postBeaconEvents(beaconEvent:BeaconEvent) {
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() != NotReachable {
            
            self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
                self.net_postBeaconEvents(beaconEvent: beaconEvent, requestHeaders: authorizationTokenHeader)
            })
        }
        else {
            #if os(iOS)
                let sharedManager = BeaconQueryManager.sharedInstance
                sharedManager.addBeaconEventParameterString(beaconParameterDict: BeaconEvent.getParameterDictionary(beaconEvent: beaconEvent))
            #endif
        }
    }

    func net_postBeaconEvents(beaconEvent:BeaconEvent, requestHeaders:HTTPHeaders?) {
        var parameterArray = Array<Dictionary<String,String>>()
        parameterArray.append(BeaconEvent.getParameterDictionary(beaconEvent: beaconEvent))
        NetworkHandler.sharedInstance.callNetworkToPostBeaconData(apiURL: self.getBaseUrlForBeaconEvents(), requestHeaders:requestHeaders , parameters: parameterArray ) { (_ responseConfigData: Bool?) in
            
        }
    }
    
    func net_postOfflineBeaconEvents(beaconEventArray : Array<Dictionary<String,String>>,pageAPIResponse: @escaping ((_ response: Bool) -> Void))
    {
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            NetworkHandler.sharedInstance.callNetworkToPostBeaconData(apiURL: self.getBaseUrlForBeaconEvents(), requestHeaders:authorizationTokenHeader , parameters: beaconEventArray) { (_ responseConfigData: Bool?) in
                pageAPIResponse(responseConfigData!)
            }
        })
    }
    
    
    func getBaseUrlForBeaconEvents() ->String
    {
        let apiEndPoint:String = AppConfiguration.sharedAppConfiguration.beaconObject?.apiBaseUrl ?? Constants.kBeaconUrl
        return apiEndPoint
    }
    
    //MARK: API to fetch Queue Data
    func fetchQueueResults(apiEndPoint:String, queueResults: @escaping ((_ results: SFModuleObject?, _ isSuccess:Bool) -> Void)) {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            self.net_fetchQueueResults(apiEndPoint: apiEndPoint, requestHeaders: authorizationTokenHeader, queueResults: queueResults)
        })
    }
    
    func net_fetchQueueResults(apiEndPoint:String, requestHeaders:HTTPHeaders?, queueResults: @escaping ((_ results: SFModuleObject?, _ isSuccess:Bool) -> Void)) {
        
//        var apiUrl:String = AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? ""
//        apiUrl.append(apiEndPoint)
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .get, requestHeaders:requestHeaders, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil {
                
                if isSuccess {

                    let queueResultJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                    
                    if queueResultJson is Dictionary<String,AnyObject> {
                        
                        let queueResultDict:Dictionary<String,AnyObject>? = queueResultJson as? Dictionary<String,AnyObject>
                        
                        if queueResultDict != nil {
                            
                            let queueResultArray:Array<AnyObject>? = queueResultDict?["records"] as? Array<AnyObject>
                            
                            if queueResultArray != nil {
                                
                                let parsedQueueResults = PageAPIParser.sharedInstance.parseQueueResults(queueResults: queueResultArray!)
                                
                                queueResults(parsedQueueResults, true)
                            }
                            else {
                                
                                queueResults(nil, true)
                            }
                        }
                        else {
                            
                            queueResults(nil, true)
                        }
                    }
                    else {
                        
                        queueResults(nil, true)
                    }
                }
                else {
                    
                    queueResults(nil, false)
                }
            }
            else {
                
                queueResults(nil, false)
            }
        }
    }
    
    
    //MARK: API to fetch Queue Data
    func fetchUserPageDetails(apiEndPoint:String, userResult: @escaping ((_ results: SFUserDetails?, _ isSuccess:Bool) -> Void)) {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_fetchUserPageResults(apiEndPoint: apiEndPoint, requestHeaders: authorizationTokenHeader, userPageResults: userResult)
        })
    }
    
    func net_fetchUserPageResults(apiEndPoint:String, requestHeaders:HTTPHeaders?, userPageResults: @escaping ((_ results: SFUserDetails?, _ isSuccess:Bool) -> Void)) {
        
//        var apiUrl:String = AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? ""
//        apiUrl.append(apiEndPoint)
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .get, requestHeaders:requestHeaders, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil {
                
                if isSuccess {
                    
                    let userPageResultJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                    
                    if userPageResultJson is Dictionary<String,AnyObject> {
                        
                        let userPageResultDict:Dictionary<String,AnyObject>? = userPageResultJson as? Dictionary<String,AnyObject>
                        
                        if userPageResultDict != nil {

                            if isSuccess {
                                
                                let userDetailObject: SFUserDetails = SFUserDetails()
                                userDetailObject.name = userPageResultDict?["name"] as? String ?? ""
                                userDetailObject.country = userPageResultDict?["country"] as? String
                                
                                let userPhoneDict = userPageResultDict?["phone"] as? Dictionary<String, Any>
                                userDetailObject.mobile = userPhoneDict?["number"] as? String ?? ""
                                userDetailObject.mobileCountryCode = userPhoneDict?["country"] as? String ?? ""
                                
                                userDetailObject.userID = userPageResultDict?["userId"] as? String
                                userDetailObject.emailID = userPageResultDict?["email"] as? String
                                userDetailObject.picture = userPageResultDict?["picture"] as? String
                                userDetailObject.registeredDate = userPageResultDict?["registeredOn"] as? Date
                                
                                userPageResults(userDetailObject, isSuccess)
                            }
                            else {
                                
                                userPageResults(nil, isSuccess)
                            }
                        }
                        else {
                            
                            userPageResults(nil, isSuccess)
                        }
                    }
                    else {
                        
                        userPageResults(nil, isSuccess)
                    }
                }
                else {
                    
                    userPageResults(nil, isSuccess)
                }
            }
            else {
                
                userPageResults(nil, isSuccess)
            }
        }
    }
    
    
    func updateUserPassword(apiEndPoint:String, newPassword: String, oldPassword:String, userResult: @escaping ((_ updatePasswordResponse:Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {

        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            let userDictionary = ["resetToken":Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) as! String, "newPassword": newPassword, "oldPassword": oldPassword]
            self.net_updateUserPassword(apiEndPoint: apiEndPoint, requestType: .post, requestParameters: userDictionary, requestHeaders: authorizationTokenHeader, success: userResult)
        })
    }
    
    func net_updateUserPassword(apiEndPoint:String, requestType:HTTPMethod, requestParameters:Dictionary<String, Any>, requestHeaders:HTTPHeaders?, success: @escaping ((_ updatePasswordResponse:Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .post, requestHeaders:requestHeaders, requestParameter: requestParameters) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil {
                
                let updatePasswordResultJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if updatePasswordResultJson is Dictionary<String,AnyObject> {
                    
                    let updatePasswordResultDict:Dictionary<String,AnyObject>? = updatePasswordResultJson as? Dictionary<String,AnyObject>
                    
                    if updatePasswordResultDict != nil {
                        
                        success(updatePasswordResultDict!, isSuccess)
                    }
                    else {
                        
                        success(nil, false)
                    }
                }
                else {
                    
                    success(nil, false)
                }
            }
            else {
                
                success(nil, false)
            }
        }
    }
    
    
    func updateUserPageDetails(apiEndPoint:String, userDictionary: [String:Any], userResult: @escaping ((_ updateUserPageResponse:Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        #if os(iOS)
            self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
                
                self.net_updateUserDetails(apiEndPoint: apiEndPoint, requestType: .put, requestParameters: userDictionary, requestHeaders: authorizationTokenHeader, success: userResult)
            })
        #endif
    }
    
    func net_updateUserDetails(apiEndPoint:String, requestType:HTTPMethod, requestParameters:Dictionary<String, Any>, requestHeaders:HTTPHeaders?, success: @escaping ((_ updateUserPageResponse:Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .post, requestHeaders:requestHeaders, requestParameter: requestParameters) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil {
                
                let updateUserDetailsResultJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if updateUserDetailsResultJson is Dictionary<String,AnyObject> {
                    
                    let updateUserDetailsResultDict:Dictionary<String,AnyObject>? = updateUserDetailsResultJson as? Dictionary<String,AnyObject>
                    
                    if updateUserDetailsResultDict != nil {
                        
                       success(updateUserDetailsResultDict!, isSuccess)
                    }
                    else {
                        
                        success(nil, false)
                    }
                }
                else {
                    
                    success(nil, false)
                }
            }
            else {
                
                success(nil, false)
            }
        }
    }
    
    //MARK: API to remove video from Queue
    func removeVideosFromQueue(apiEndPoint:String, success: @escaping ((_ isVideoRemoved: Bool) -> Void)) {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_removeVideosFromQueue(apiEndPoint: apiEndPoint, requestHeaders: authorizationTokenHeader, success: success)
        })
    }
    
    
    func net_removeVideosFromQueue(apiEndPoint:String, requestHeaders:HTTPHeaders?, success: @escaping ((_ isVideoRemoved: Bool) -> Void)) {
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .delete, requestHeaders:requestHeaders, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil && isSuccess {
                
                success(isSuccess)
            }
            else {
                
                success(false)
            }
        }
    }
    
    
    //MARK: API to add video to queue
    func addVideoToQueue(apiEndPoint:String, requestParameters:Dictionary<String, Any>, success: @escaping ((_ isVideoAdded: Bool?) -> Void)) {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_addVideoToQueue(apiEndPoint: apiEndPoint, requestHeaders: authorizationTokenHeader, requestParameters: requestParameters, success: success)
        })
    }
    
    
    func net_addVideoToQueue(apiEndPoint:String, requestHeaders:HTTPHeaders?, requestParameters:Dictionary<String, Any>, success: @escaping ((_ isVideoAdded: Bool?) -> Void)) {
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .post, requestHeaders:requestHeaders, requestParameter: requestParameters) { (_ responseConfigData: Data?, _ isSuccess:Bool) in
            
            if responseConfigData != nil && isSuccess {
                
                success(isSuccess)
            }
            else {
                
                success(isSuccess)
            }
        }
    }
    
    
    //MARK: API to SignIn
    func userSignIn(apiEndPoint:String, requestType:HTTPMethod, requestParameters:Dictionary<String, Any>, success: @escaping ((_ userResponse: Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        self.net_userSignIn(apiEndPoint: apiEndPoint, requestType: requestType, requestParameters: requestParameters, requestHeaders: nil, success: success)
    }
    
    
    func net_userSignIn(apiEndPoint:String, requestType:HTTPMethod, requestParameters:Dictionary<String, Any>, requestHeaders:HTTPHeaders? ,success: @escaping ((_ userResponse: Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .post, requestHeaders:requestHeaders, requestParameter: requestParameters) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil {
                
                let userResponse = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if userResponse is Dictionary<String,AnyObject> {
                    
                    let userDict:Dictionary<String,AnyObject>? = userResponse as? Dictionary<String,AnyObject>
                    
                    if userDict != nil {
                        
                        success(userDict, isSuccess)
                    }
                    else {
                        
                        success(nil, false)
                    }
                }
                else {
                    
                    success(nil, false)
                }
            }
            else {
                
                success(nil, false)
            }
        }
    }
    
    
    //MARK: API to SignUp
    func userSignUp(apiEndPoint:String, requestType:HTTPMethod, requestParameters:Dictionary<String, Any>, success: @escaping ((_ userResponse: Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        self.net_userSignUp(apiEndPoint: apiEndPoint, requestType: requestType, requestHeader: nil, requestParameters: requestParameters, success: success)
    }
    
    
    func net_userSignUp(apiEndPoint:String, requestType:HTTPMethod, requestHeader:HTTPHeaders?, requestParameters:Dictionary<String, Any>, success: @escaping ((_ userResponse: Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .post, requestHeaders:requestHeader, requestParameter: requestParameters) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil {
                
                let userResponse = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if userResponse is Dictionary<String,AnyObject> {
                    
                    let userDict:Dictionary<String,AnyObject>? = userResponse as? Dictionary<String,AnyObject>
                    
                    if userDict != nil {

                        success(userDict, isSuccess)
                    }
                    else {
                        
                        success(nil, false)
                    }
                }
                else {
                    
                    success(nil, false)
                }
            }
            else {
                
                success(nil, false)
            }
        }
    }
    
    
    //MARK: API to Sign in/up by Facebook
    func userSignInFromFacebook(apiEndPoint:String, requestType:HTTPMethod, requestParameters:Dictionary<String, Any>, success: @escaping ((_ userResponse: Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        self.net_userSignInFromFacebook(apiEndPoint: apiEndPoint, requestType: requestType, requestHeader: nil, requestParameters: requestParameters, success: success)
    }
    
    
    func net_userSignInFromFacebook(apiEndPoint:String, requestType:HTTPMethod, requestHeader:HTTPHeaders?,requestParameters:Dictionary<String, Any>, success: @escaping ((_ userResponse: Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .post, requestHeaders:requestHeader, requestParameter: requestParameters) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil {
                
                let userResponse = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if userResponse is Dictionary<String,AnyObject> {
                    
                    let userDict:Dictionary<String,AnyObject>? = userResponse as? Dictionary<String,AnyObject>
                    
                    if userDict != nil {
                        
                        success(userDict, isSuccess)
                    }
                    else {
                        
                        success(nil, false)
                    }
                }
                else {
                    
                    success(nil, false)
                }
            }
            else {
                
                success(nil, false)
            }
        }
    }
    
    
    //MARK: API to Reset Password
    func userResetPassword(apiEndPoint:String, requestType:HTTPMethod, requestParameters:Dictionary<String, Any>, success: @escaping ((_ userResponse: Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        self.net_userResetPassword(apiEndPoint: apiEndPoint, requestType: requestType, requestHeaders: nil, requestParameters: requestParameters, success: success)
    }
    
    
    func net_userResetPassword(apiEndPoint:String, requestType:HTTPMethod, requestHeaders:HTTPHeaders?, requestParameters:Dictionary<String, Any>, success: @escaping ((_ userResponse: Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .post, requestHeaders:nil, requestParameter: requestParameters) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil && isSuccess {
                
                let userResponse = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if userResponse is Dictionary<String,AnyObject> {
                    
                    let userDict:Dictionary<String,AnyObject>? = userResponse as? Dictionary<String,AnyObject>
                    
                    if userDict != nil {
                        
                        success(userDict, isSuccess)
                    }
                    else {
                        
                        success(nil, false)
                    }
                }
                else {
                    
                    success(nil, false)
                }
            }
            else {
                
                success(nil, false)
            }
        }
    }
    
    //MARK: Api to post beacon data
    func updateFilmProgressOnServer(apiEndPoint:String, requestParameters:Dictionary<String, Any>, filmProgressResponse: @escaping ((_ errorMessage: Dictionary<String, Any>?, _ isSuccess:Bool) -> Void)) {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_updateFilmProgressOnServer(apiEndPoint: apiEndPoint, requestHeaders: authorizationTokenHeader, requestParameters: requestParameters, filmProgressResponse: filmProgressResponse)
        })
    }
    
    func net_updateFilmProgressOnServer(apiEndPoint:String, requestHeaders:HTTPHeaders?,requestParameters:Dictionary<String, Any>, filmProgressResponse: @escaping ((_ errorMessage: Dictionary<String, Any>?, _ isSuccess:Bool) -> Void)) {
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .post, requestHeaders:requestHeaders, requestParameter: requestParameters) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil {
                
                if isSuccess == false {
                    
                    let errorResponse = try? JSONSerialization.jsonObject(with: responseConfigData!)
                    
                    if errorResponse is Dictionary<String,AnyObject> {
                        
                        let errorDict:Dictionary<String,AnyObject>? = errorResponse as? Dictionary<String,AnyObject>
                        
                        if errorDict != nil {
                            let errorMessage:String? = errorDict?["error"] as? String ?? errorDict?["message"] as? String
                            
                            if errorMessage != nil {
                                
                                filmProgressResponse(errorDict!, isSuccess)
                            }
                            else {
                                
                                filmProgressResponse(nil, isSuccess)
                            }
                        }
                        else {
                            
                            filmProgressResponse(nil, isSuccess)
                        }
                    }
                    else {
                        
                        filmProgressResponse(nil, isSuccess)
                    }
                }
                else {
                    
                    filmProgressResponse(nil, isSuccess)
                }
            }
            else {
             
                filmProgressResponse(nil, false)
            }
        }
    }
    
    
    //MARK: API to fetch user info
    func getVideoStatus(videoId:String?, success: @escaping ((_ videoStatusResponse: Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_getVideoStatus(videoId: videoId, requestHeaders: authorizationTokenHeader, success: success)
        })
    }
    
    
    func net_getVideoStatus(videoId:String?, requestHeaders:HTTPHeaders?, success: @escaping ((_ videoStatusResponse: Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/info/video/\(videoId ?? "")?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .get, requestHeaders:requestHeaders, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil && isSuccess {
                
                let videoStatusResponse = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if videoStatusResponse is Dictionary<String,AnyObject> {
                    
                    let videoStatusResponseDict:Dictionary<String,AnyObject>? = videoStatusResponse as? Dictionary<String,AnyObject>
                    
                    if videoStatusResponseDict != nil {
                        
                        success(videoStatusResponseDict, isSuccess)
                    }
                    else {
                        
                        success(nil, false)
                    }
                }
                else {
                    
                    success(nil, false)
                }
            }
            else {
                
                success(nil, false)
            }
        }
    }
    
    
    //MARK: API to fetch product page
    func fetchContentForPlansPage(apiEndPoint:String, requestHeaders:HTTPHeaders?, pageAPIResponse: @escaping ((_ pageAPIObjectResponse: PageAPIObject?, _ isSuccess:Bool) -> Void)) -> Void {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_fetchContentForPlansPage(apiEndPoint: apiEndPoint, requestHeaders: authorizationTokenHeader, pageAPIResponse: pageAPIResponse)
        })
    }
    
    func net_fetchContentForPlansPage(apiEndPoint:String, requestHeaders:HTTPHeaders?, pageAPIResponse: @escaping ((_ pageAPIObjectResponse: PageAPIObject?, _ isSuccess:Bool) -> Void)) -> Void {
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .get, requestHeaders:requestHeaders, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil && isSuccess
            {
                let pageContentJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if pageContentJson is Dictionary<String,AnyObject> {
                    
                    let pageContentDict:Dictionary<String,AnyObject>? = pageContentJson as? Dictionary<String,AnyObject>
                    
                    if pageContentDict != nil {
                        
                        let pageAPIObject:PageAPIObject = PageAPIParser.sharedInstance.parsePlanPageAPIContent(pageContentJson: pageContentDict!)
                        pageAPIResponse(pageAPIObject, isSuccess)
                    }
                    else
                    {
                        pageAPIResponse(nil, false)
                    }
                }
                else
                {
                    pageAPIResponse(nil, false)
                }
            }
            else
            {
                pageAPIResponse(nil, isSuccess)
            }
        }
    }

    
    //MARK: API to update subscription status on server
    func apiToUpdateSubscriptionStatus(requestParameter:Parameters?, requestType:HTTPMethod, success: @escaping ((_ subscriptionResponse: Dictionary<String, Any>?, _ isSuccess:Bool) -> Void)) {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_apiToUpdateSubscriptionStatus(requestHeader: authorizationTokenHeader, requestParameter: requestParameter, requestType: requestType, success: success)
        })
    }
    
    func apiToUpdateSubscriptionStatusForRestorePurchase(requestParameter:Parameters?, authorizationToken:String?, requestType:HTTPMethod, success: @escaping ((_ subscriptionResponse: Dictionary<String, Any>?, _ isSuccess:Bool) -> Void)) {
        
        if authorizationToken == nil {
            
            self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
                
                self.net_apiToUpdateSubscriptionStatus(requestHeader: authorizationTokenHeader, requestParameter: requestParameter, requestType: requestType, success: success)
            })
        }
        else {
            
            let authorizationTokenHeader:HTTPHeaders = ["Authorization" : authorizationToken!]
            self.net_apiToUpdateSubscriptionStatus(requestHeader: authorizationTokenHeader, requestParameter: requestParameter, requestType: requestType, success: success)
        }
    }
    
    func net_apiToUpdateSubscriptionStatus(requestHeader:HTTPHeaders?, requestParameter:Parameters?, requestType:HTTPMethod, success: @escaping ((_ subscriptionResponse: Dictionary<String, Any>?, _ isSuccess:Bool) -> Void)) {
        
        #if os(iOS)
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/subscription/subscribe?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&platform=ios_phone"
        #else
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/subscription/subscribe?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&platform=ios_apple_tv"
        #endif
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: requestType, requestHeaders: requestHeader, requestParameter: requestParameter) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil {
                
                let subscriptionResponseJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if subscriptionResponseJson is Dictionary<String,AnyObject> {
                    
                    let subscriptionResponseDict:Dictionary<String,AnyObject>? = subscriptionResponseJson as? Dictionary<String,AnyObject>
                    
                    if subscriptionResponseDict != nil {
                        
                        success(subscriptionResponseDict, isSuccess)
                    }
                    else {
                        
                        success(nil, false)
                    }
                }
                else {
                    
                    success(nil, false)
                }
            }
            else {
                
                success(nil, isSuccess)
            }
        }
    }
    
    
    //MARK: Api to get user subscription status
    func apiToGetUserSubscriptionStatus(success: @escaping ((_ subscriptionStatus: Dictionary<String, Any>?, _ isSuccess:Bool) -> Void)) {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_apiToGetUserSubscriptionStatus(requestHeaders: authorizationTokenHeader, requestParameters: nil, success: success)
        })
    }
    
    
    func net_apiToGetUserSubscriptionStatus(requestHeaders:HTTPHeaders?, requestParameters:Parameters?, success: @escaping ((_ subscriptionStatus: Dictionary<String, Any>?, _ isSuccess:Bool) -> Void)) {
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/subscription/user?userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")&site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .get, requestHeaders: requestHeaders, requestParameter: requestParameters) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil && isSuccess == true {
            
                let userSubscriptionStatusResponseJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if userSubscriptionStatusResponseJson is Dictionary<String,AnyObject> {
                    
                    let userSubscriptionStatusResponseDict:Dictionary<String,AnyObject>? = userSubscriptionStatusResponseJson as? Dictionary<String,AnyObject>
                    
                    if userSubscriptionStatusResponseDict != nil {
                        
                        var userSubscriptionStatusDict:Dictionary<String, Any> = [:]
                        
                        let subscriptionPlanInfoDict:Dictionary<String, AnyObject>? = userSubscriptionStatusResponseDict?["subscriptionPlanInfo"] as? Dictionary<String, AnyObject>
                        if subscriptionPlanInfoDict != nil
                        {
                            let planName: String? = subscriptionPlanInfoDict?["name"] as? String ?? ""
                            userSubscriptionStatusDict["name"] = planName
                        }
                        
                        let subscriptionInfoDict:Dictionary<String, AnyObject>? = userSubscriptionStatusResponseDict?["subscriptionInfo"] as? Dictionary<String, AnyObject>
                        
                        if subscriptionInfoDict != nil {
                            
                            let subscriptionStatus:String? = subscriptionInfoDict?["subscriptionStatus"] as? String
                            let paymentMethod:String? = subscriptionInfoDict?["paymentHandlerDisplayName"] as? String
                            let paymentPlatform:String? = subscriptionInfoDict?["platform"] as? String
                            let planId:String? = subscriptionInfoDict?["planId"] as? String
                            let planProductId:String? = subscriptionInfoDict?["identifier"] as? String
                            let subscriptionEndDate:String? = subscriptionInfoDict?["subscriptionEndDate"] as? String

                            if subscriptionStatus != nil {
                                
                                userSubscriptionStatusDict["subscriptionStatus"] = subscriptionStatus!
                                
                                if subscriptionStatus?.lowercased() == "completed".lowercased() {
                                    
                                    self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: true, subscriptionDate: subscriptionEndDate, planName: userSubscriptionStatusDict["name"] as? String)
                                }
                                else {
                                    
                                    self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: false, subscriptionDate: subscriptionEndDate, planName: userSubscriptionStatusDict["name"] as? String)
                                }

                            }
                            else {
                                
                                self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: false, subscriptionDate: subscriptionEndDate, planName: planProductId)
                            }
                            
                            if paymentMethod != nil {
                                
                                userSubscriptionStatusDict["paymentHandlerDisplayName"] = paymentMethod!
                            }
                            
                            if paymentPlatform != nil {
                                
                                userSubscriptionStatusDict["platform"] = paymentPlatform!
                            }
                            
                            if planId != nil {
                                
                                userSubscriptionStatusDict["planId"] = planId!
                            }
                            
                            if planProductId != nil {
                                
                                userSubscriptionStatusDict["planProductId"] = planProductId!
                            }
                            
                            success(userSubscriptionStatusDict.count > 0 ? userSubscriptionStatusDict : nil, isSuccess)
                        }
                        else {
                            
                            self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: false, subscriptionDate: nil, planName: nil)
                            success(subscriptionInfoDict, isSuccess)
                        }
                    }
                    else {
                        
                        self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: false, subscriptionDate: nil, planName: nil)
                        success(nil, false)
                    }
                }
                else {
                    
                    self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: false, subscriptionDate: nil, planName: nil)
                    success(nil, false)
                }
             }
            else {
                
                self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: false, subscriptionDate: nil, planName: nil)
                success(nil, isSuccess)
            }
        }
    }
    
    
    //MARK: Api to get user subscription status
    func apiToGetUserEntitledStatus(success: @escaping ((_ isSubscribed:Bool?) -> Void)) {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_apiToGetUserEntitledStatus(requestHeaders: authorizationTokenHeader, requestParameters: nil, success: success)
        })
    }
    
    
    func net_apiToGetUserEntitledStatus(requestHeaders:HTTPHeaders?, requestParameters:Parameters?, success: @escaping ((_ isSubscribed:Bool?) -> Void)) {
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/user?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .get, requestHeaders: requestHeaders, requestParameter: requestParameters) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil && isSuccess == true {
                
                let userSubscriptionStatusResponseJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if userSubscriptionStatusResponseJson is Dictionary<String,AnyObject> {
                    
                    let userSubscriptionStatusResponseDict:Dictionary<String,AnyObject>? = userSubscriptionStatusResponseJson as? Dictionary<String,AnyObject>
                    
                    if userSubscriptionStatusResponseDict != nil {
                        
                        let subscriptionStatus:Bool? = userSubscriptionStatusResponseDict?["isSubscribed"] as? Bool
                        
                        if subscriptionStatus != nil {
                            
                            self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: subscriptionStatus!, subscriptionDate: nil, planName: nil)
                            success(subscriptionStatus!)
                        }
                        else {
                            
                            let susbcriptionStatusString:String? = userSubscriptionStatusResponseDict?["isSubscribed"] as? String
                            
                            if susbcriptionStatusString != nil {
                                
                                if susbcriptionStatusString!.lowercased() == "true" || susbcriptionStatusString!.lowercased() == "1" {
                                    
                                    self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: true, subscriptionDate: nil, planName: nil)
                                    success(true)
                                }
                                else {
                                    
                                    self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: false, subscriptionDate: nil, planName: nil)
                                    success(false)
                                }
                            }
                            else {
                                
                                self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: false, subscriptionDate: nil, planName: nil)
                                success(nil)
                            }
                        }
                    }
                    else {
                        
                        self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: false, subscriptionDate: nil, planName: nil)
                        success(nil)
                    }
                }
                else {
                    
                    self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: false, subscriptionDate: nil, planName: nil)
                    success(nil)
                }
            }
            else {
                
                self.triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed: false, subscriptionDate: nil, planName: nil)
                success(nil)
            }
        }
    }

    
    private func triggerUrbanAirshipTagForSubscriptionStatus(isSubcribed:Bool, subscriptionDate:String?, planName:String?) {
        
        #if os(iOS)
        if AppConfiguration.sharedAppConfiguration.urbanAirshipChurnAvailable {
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                UrbanAirshipEvent.sharedInstance.triggerUserSubscriptionStateTagToUrbanAirship(isUserSubscribed: isSubcribed, subscriptionEndDate: subscriptionDate, planName: planName)
            }
        }
        #endif
    }
    
    
    //MARK: API to get user details from transaction id
    func apiToGetUserIdFromTransactionId(requestParameter:Dictionary<String, Any>?, success: @escaping ((_ userStatusDict: Dictionary<String, Any>?, _ isSuccess:Bool) -> Void)) {
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/signin/ios?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .post, requestHeaders: nil, requestParameter: requestParameter) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil && isSuccess == true {
                
                let userStatusResponseJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if userStatusResponseJson is Dictionary<String,AnyObject> {
                    
                    let userStatusResponseDict:Dictionary<String,AnyObject>? = userStatusResponseJson as? Dictionary<String,AnyObject>
                    
                    if userStatusResponseDict != nil {
                        
                        success(userStatusResponseDict, isSuccess)
                    }
                    else {
                        
                        success(nil, false)
                    }
                }
                else {
                    
                    success(nil, false)
                }
            }
            else {
                
                success(nil, isSuccess)
            }
        }
    }
    
    
    func getEntitlementForMovie(filmId:String, userId:String, success: @escaping ((_ userResponse: Dictionary<String, Any>?, _ isSuccess:Bool) -> Void)) {
        
    }
    func getFilmBy(filmId:String, success: @escaping ((_ filmResponse: SFFilm?, _ isSuccess:Bool) -> Void)) {

    }
    
    
    //MARK: API to get token for video urls
    func fetchTokenForVideoUrl(contentId:String, tokenHeaderDetails: @escaping ((_ tokenHeaderDict: Dictionary<String, String>?, _ isSuccess:Bool) -> Void)) {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_fetchTokenForVideoUrl(contentId: contentId, requestHeaders: authorizationTokenHeader, tokenHeaderDetails: tokenHeaderDetails)
        })
    }
    
    private func net_fetchTokenForVideoUrl(contentId:String, requestHeaders: HTTPHeaders?, tokenHeaderDetails: @escaping ((_ tokenHeaderDict: Dictionary<String, String>?, _ isSuccess:Bool) -> Void)) {
    
        let apiEndpoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/signature/\(contentId)?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndpoint, requestType: .get, requestHeaders: requestHeaders, requestParameter: nil) { (_ responseConfigData:Data?, _ isSuccess:Bool) in
            if responseConfigData != nil  && isSuccess {
                
                let videoTokenJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if videoTokenJson is Dictionary<String,AnyObject> {
                    
                    let videoTokenDict:Dictionary<String,AnyObject>? = videoTokenJson as? Dictionary<String,AnyObject>
                    
                    var filteredTokenDict:Dictionary<String,String>?
                    
                    if videoTokenDict != nil {
                        
                        let signedUrl:String? = videoTokenDict?["signed"] as? String
                        
                        if signedUrl != nil {
                            
                            let signedUrlArray:Array<String>? = signedUrl?.components(separatedBy: "?")
                            
                            if signedUrlArray != nil && (signedUrlArray?.count)! > 1 {
                                
                                let filteredTokenArray:Array<String>? = signedUrlArray?[1].components(separatedBy: "&")
                                
                                if filteredTokenArray != nil {
                                    
                                    for filteredTokenString in filteredTokenArray! {
                                    
                                        let localFilteredTokenStringArray:Array<String>? = filteredTokenString.components(separatedBy: "=")
                                        
                                        if localFilteredTokenStringArray != nil && (localFilteredTokenStringArray?.count)! > 1 {
                                            
                                            if localFilteredTokenStringArray?[0] == "Policy" {
                                                
                                                if filteredTokenDict == nil {
                                                    
                                                    filteredTokenDict = [:]
                                                }
                                                
                                                filteredTokenDict?["CloudFront-Policy"] = localFilteredTokenStringArray?[1]
                                            }
                                            else if localFilteredTokenStringArray?[0] == "Signature" {
                                                
                                                if filteredTokenDict == nil {
                                                    
                                                    filteredTokenDict = [:]
                                                }
                                                
                                                filteredTokenDict?["CloudFront-Signature"] = localFilteredTokenStringArray?[1]
                                            }
                                            else if localFilteredTokenStringArray?[0] == "Key-Pair-Id" {
                                                
                                                if filteredTokenDict == nil {
                                                    
                                                    filteredTokenDict = [:]
                                                }
                                                
                                                filteredTokenDict?["CloudFront-Key-Pair-Id"] = localFilteredTokenStringArray?[1]
                                            }
                                        }
                                    }
                                    
                                    if filteredTokenDict != nil {
                                        
                                        tokenHeaderDetails(filteredTokenDict, true)
                                    }
                                    else {
                                        
                                        tokenHeaderDetails(nil, false)
                                    }
                                }
                                else {
                                    
                                    tokenHeaderDetails(nil, false)
                                }
                            }
                            else {
                                
                                tokenHeaderDetails(nil, false)
                            }
                        }
                        else {
                            
                            tokenHeaderDetails(nil, false)
                        }
                    }
                    else {
                        
                        tokenHeaderDetails(nil, false)
                    }
                }
                else {
                    
                    tokenHeaderDetails(nil, false)
                }
            }
            else {
                
                tokenHeaderDetails(nil, false)
            }
        }
    }
    
    
    //MARK: API to validate receipt from apple
    func apiToValidateReceiptFromApple(requestParameter:Parameters?, success: @escaping ((_ userResponse: Dictionary<String, Any>?, _ isSuccess:Bool) -> Void)) {
        
        self.fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: { (authorizationTokenHeader) in
            
            self.net_apiToValidateReceiptFromApple(requestHeaders: authorizationTokenHeader, requestParameter: requestParameter, success: success)
        })
    }
    
    
    private func net_apiToValidateReceiptFromApple(requestHeaders:HTTPHeaders?, requestParameter:Parameters?, success: @escaping ((_ userResponse: Dictionary<String, Any>?, _ isSuccess:Bool) -> Void)) {
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/subscription/ios/validate_ios_receipt?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .post, requestHeaders: requestHeaders, requestParameter: requestParameter) { (_ responseConfigData:Data?, _ isSuccess:Bool) in
            
            if responseConfigData != nil && isSuccess == true {
                
                let userStatusResponseJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if userStatusResponseJson is Dictionary<String,AnyObject> {
                    
                    let userStatusResponseDict:Dictionary<String,AnyObject>? = userStatusResponseJson as? Dictionary<String,AnyObject>

                    if userStatusResponseDict != nil {
                        
                        print("user response >>>>>>> \(userStatusResponseDict!)")
                    }
                    
                    success(userStatusResponseDict!, isSuccess)
                }
                else {
                    
                    success(nil, isSuccess)
                }
            }
            else {
                
                success(nil, isSuccess)
            }
        }
    }
    
    
    //MARK: API to get anonymous token
    func apiToGetAnonymousToken(success: @escaping ((_ isSuccess:Bool) -> Void)) {
        
        let deviceUdid:String? = UIDevice.current.identifierForVendor?.uuidString
        
        let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/anonymous-token?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&uin=\(deviceUdid ?? Utility.sharedUtility.getUUID())"
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .get, requestHeaders: nil, requestParameter: nil) { (_ responseConfigData:Data?, _ isSuccess:Bool) in
            
            if responseConfigData != nil  && isSuccess {
                
                let tokenJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                
                if tokenJson is Dictionary<String,AnyObject> {
                    
                    let tokenDict:Dictionary<String,AnyObject>? = tokenJson as? Dictionary<String,AnyObject>
                    
                    if tokenDict != nil {
                        
                        let authorizationToken:String? = tokenDict?["authorizationToken"] as? String
                        
                        if authorizationToken != nil {
                            
                            if !Utility.sharedUtility.checkIfUserIsLoggedIn() && !Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                            
                                Constants.kSTANDARDUSERDEFAULTS.setValue(authorizationToken!, forKey: Constants.kAuthorizationToken)
                                Constants.kSTANDARDUSERDEFAULTS.synchronize()
                            }
                            
                            success(true)
                        }
                        else {
                            
                            success(false)
                        }
                    }
                    else {
                        
                        success(false)
                    }
                }
                else {
                    
                    success(false)
                }
            }
            else {
                
                success(false)
            }
        }
    }
    
    //MARK: API to get Authorization token
    func apiToGetUpdatedAuthorizationToken(success: @escaping ((_ userResponse: Dictionary<String, AnyObject>?, _ isSuccess:Bool) -> Void)) {
        
        let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/refresh/\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kRefreshToken) ?? "")"
        
        NetworkHandler.sharedInstance.callNetworkForContentFetch(apiURL: apiEndPoint, requestType: .get, requestHeaders:nil, requestParameter: nil) { (_ responseConfigData: Data?, _ isSuccess: Bool) in
            
            if responseConfigData != nil {
                
                if isSuccess {
                    
                    let authorizationTokenResponseJson = try? JSONSerialization.jsonObject(with: responseConfigData!)
                    
                    if authorizationTokenResponseJson is Dictionary<String,AnyObject> {
                        
                        let authorizationTokenResponseDict:Dictionary<String,AnyObject>? = authorizationTokenResponseJson as? Dictionary<String,AnyObject>
                        
                        if authorizationTokenResponseDict != nil {
                            
                            let authorizationToken:String? = authorizationTokenResponseDict?["authorization_token"] as? String
                            let refreshToken:String? = authorizationTokenResponseDict?["refresh_token"] as? String
                            let userId:String? = authorizationTokenResponseDict?["id"] as? String
                            
                            if authorizationToken != nil {
                                
                                Constants.kSTANDARDUSERDEFAULTS.setValue(authorizationToken!, forKey: Constants.kAuthorizationToken)
                                Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kAuthorizationTokenTimeStamp)
                            }
                            
                            if refreshToken != nil {
                                
                                Constants.kSTANDARDUSERDEFAULTS.setValue(refreshToken!, forKey: Constants.kRefreshToken)
                            }
                            
                            if userId != nil {
                                
                                Constants.kSTANDARDUSERDEFAULTS.setValue(userId, forKey: Constants.kUSERID)
                            }
                            
                            Constants.kSTANDARDUSERDEFAULTS.synchronize()
                            success(authorizationTokenResponseDict, isSuccess)
                        }
                        else {
                            
                            success(nil, false)
                        }
                    }
                    else {
                        
                        success(nil, false)
                    }
                }
                else {
                    
                    success(nil, false)
                }
            }
            else {
                
                success(nil, false)
            }
        }
    }
    
    
    //MARK: Check if authorization token is expired or not
    func checkIfAuthroizationTokenIsExpired() -> Bool {
        
        var isTokenExpired:Bool = false
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationTokenTimeStamp) != nil {
            
            let tokenDate:Date = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationTokenTimeStamp) as! Date
            
            if tokenDate.addingTimeInterval(TimeInterval(Constants.kAuthorizationTokenValidityTimeStamp)).compare(Date()) == .orderedAscending {
                
                isTokenExpired = true
            }
        }
        else if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationTokenTimeStamp) == nil {
            
            isTokenExpired = true
        }
        
        return isTokenExpired
    }
    
    
    //MARK: Method to fetch authorization header
    func fetchAuthorizationTokenHeader(authorizationTokenHeaderResponse: @escaping ((_ authorizationTokenHeaderDict: HTTPHeaders?) -> Void)) {
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            if checkIfAuthroizationTokenIsExpired() {
                
                apiToGetUpdatedAuthorizationToken(success: { (authenticationResponse, isSuccess) in
                    
                    if authenticationResponse != nil && isSuccess == true {
                        
                        let requestHeader:HTTPHeaders = ["Authorization" : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) as! String]
                        
                        authorizationTokenHeaderResponse(requestHeader)
                    }
                    else {
                        
                        authorizationTokenHeaderResponse(nil)
                    }
                })
            }
            else {
                
                let requestHeader:HTTPHeaders = ["Authorization" : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) as! String]
                authorizationTokenHeaderResponse(requestHeader)
            }
        }
        else {
            
            var requestHeader:HTTPHeaders?
            
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) != nil {
                requestHeader = ["Authorization" : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) as! String]
                
                authorizationTokenHeaderResponse(requestHeader)
            }
            else {
                
                apiToGetAnonymousToken(success: { (isSuccess) in
                    
                    if isSuccess {
                        
                        requestHeader = ["Authorization" : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAuthorizationToken) as! String]
                    }
                    
                    authorizationTokenHeaderResponse(requestHeader)
                })
            }
        }
    }
    
    
    #if os(iOS)
    //MARK: Urban Airship Event Handler
    func sendUrbanAirshipEvents(requestEndPoint:String, requestType:HTTPMethod, requestParameters:Parameters?) {
        
        let apiUrl = "\(Constants.kUrbanAirshipAPIBaseUrl)\(requestEndPoint)"
        
        NetworkHandler.sharedInstance.callNetworkForUrbanAirship(apiURL: apiUrl, requestParameter: requestParameters, requestType: requestType) { (responseConfigData, isSuccess) in
            
            
        }
    }
    #endif
}


