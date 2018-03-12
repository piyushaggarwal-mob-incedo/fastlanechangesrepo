//
//  PageAPIParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 01/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class PageAPIParser: NSObject {

    //MARK: Method to create singeleton class object
    static let sharedInstance:PageAPIParser = {
        
        let instance = PageAPIParser()
        
        return instance
    }()
    
    //MARK: Method to parse Page Content
    func parsePageAPIContent(pageContentJson:Dictionary<String, AnyObject>) -> PageAPIObject{
        
        let pageAPIObject = PageAPIObject()
        
        pageAPIObject.pageId = pageContentJson["id"] as? String
        pageAPIObject.pagePath = pageContentJson["path"] as? Array<Any>
        pageAPIObject.pageTitle = pageContentJson["title"] as? String
        
        var pageModuleArray:Dictionary<String,AnyObject> = [:]
        
        if pageContentJson["modules"] != nil {
            
            for moduleContent in pageContentJson["modules"] as! Array <AnyObject> {
                
                let moduleObject:SFModuleObject? = parsePageModuleContent(moduleContentJson: moduleContent as! Dictionary<String, AnyObject>)
                
                if moduleObject != nil {
                    
                    if moduleObject?.moduleType == "TextModule" {
                        
                        if moduleObject?.moduleRawText != nil {
                            
                            pageModuleArray["\(moduleObject?.moduleId ?? "")"] = moduleObject!
                        }
                    }
                    else {
                        
                        if moduleObject?.moduleData != nil && (moduleObject?.moduleData?.count)! > 0 {
                            
                            pageModuleArray["\(moduleObject?.moduleId ?? "")"] = moduleObject!
                        }
                    }
                }
            }
        }
        
        pageAPIObject.pageModules = pageModuleArray
        
        return pageAPIObject
    }
    
    
    //MARK: Method to parse Ancillary Page Content
    func parseAncillaryPageAPIContent(pageContentJson:Dictionary<String, AnyObject>) -> PageAPIObject{
        
        let pageAPIObject = PageAPIObject()
        
        pageAPIObject.pageId = pageContentJson["id"] as? String
        pageAPIObject.pagePath = pageContentJson["path"] as? Array<Any>
        pageAPIObject.pageTitle = pageContentJson["title"] as? String
        
        var pageModuleArray:Dictionary<String,AnyObject> = [:]
        
        if pageContentJson["modules"] != nil {
            
            for moduleContent in pageContentJson["modules"] as! Array <AnyObject> {
                
                let moduleObject:SFModuleObject? = parsePageModuleContent(moduleContentJson: moduleContent as! Dictionary<String, AnyObject>)
                
                if moduleObject != nil {
                    
                    if moduleObject?.moduleData != nil {
                        
                        pageModuleArray["\(moduleObject?.moduleId ?? "")"] = moduleObject!
                    }
                }
            }
            
        }
        
        pageAPIObject.pageModules = pageModuleArray
        
        return pageAPIObject
    }
    
    
    //MARK: Method to parse Video Page Content
    func parseVideoPageAPIContent(pageContentJson:Dictionary<String, AnyObject>) -> PageAPIObject{
        
        let pageAPIObject = PageAPIObject()
        
        pageAPIObject.pageId = pageContentJson["id"] as? String
        pageAPIObject.pagePath = pageContentJson["path"] as? Array<Any>
        pageAPIObject.pageTitle = pageContentJson["title"] as? String
        
        var pageModuleArray:Dictionary<String,AnyObject> = [:]
        
        for moduleContent in pageContentJson["modules"] as? Array <AnyObject> ?? [] {
            
            var moduleObject:SFModuleObject?
            
            if let moduleType: String = moduleContent["moduleType"] as? String {
                if moduleType == "VideoDetailModule" || moduleType == "ShowDetailModule" {
                    
                    moduleObject = self.parseVideoPageModuleContent(moduleContentJson: moduleContent as! Dictionary<String, AnyObject>, moduleType: moduleType)
                }
                else {
                    moduleObject = self.parsePageModuleContent(moduleContentJson: moduleContent as! Dictionary<String, AnyObject>)
                }
            } else {
                moduleObject = self.parsePageModuleContent(moduleContentJson: moduleContent as! Dictionary<String, AnyObject>)
            }
            
            if moduleObject != nil {
                
                if moduleObject?.moduleData != nil && (moduleObject?.moduleData?.count)! > 0 {
                    
                    pageModuleArray["\(moduleObject?.moduleId ?? "")"] = moduleObject!
                }
            }
        }
        
        pageAPIObject.pageModules = pageModuleArray
        
        return pageAPIObject
    }
    
    
    //MARK: Method to parse Page Modules list coming in page api response
    private func parsePageModuleContent(moduleContentJson:Dictionary<String, AnyObject>) -> SFModuleObject {
        
        let moduleObject = SFModuleObject()
        
        moduleObject.moduleId = moduleContentJson["id"] as? String
        moduleObject.moduleTitle = moduleContentJson["title"] as? String
        moduleObject.moduleType = moduleContentJson["moduleType"] as? String
        moduleObject.moduleRawText = moduleContentJson["rawText"] as? String
        
        if moduleObject.moduleRawText == nil {
            
            if let metadataMap = moduleContentJson["metadataMap"] as? Dictionary<String, Any> {
                
                moduleObject.moduleRawText = metadataMap["adTag"] as? String
            }
        }
        
        var moduleContentArray:Array <AnyObject> = []
        
        let contentData = moduleContentJson["contentData"] as? Array<AnyObject>
        
        if contentData != nil {
            
            for moduleContent in contentData! {
                
                let moduleAPIParser = ModuleAPIParser()
                moduleContentArray.append(moduleAPIParser.parseModuleContentData(moduleContentDict: moduleContent as! Dictionary<String, AnyObject>))
            }
        }
        
        moduleObject.moduleData = moduleContentArray
        
        return moduleObject
    }
    
    
    //MARK: Method to parse Page Modules list coming in video page api response
    func parseVideoPageModuleContent(moduleContentJson:Dictionary<String, AnyObject>, moduleType:String?) -> SFModuleObject {
        
        let moduleObject = SFModuleObject()
        
        moduleObject.moduleId = moduleContentJson["id"] as? String
        moduleObject.moduleTitle = moduleContentJson["title"] as? String
        moduleObject.moduleType = moduleContentJson["moduleType"] as? String
        
        var moduleContentArray:Array <AnyObject> = []
        
        let contentData = moduleContentJson["contentData"] as? Array<AnyObject>
        
        if contentData != nil {
            
            for moduleContent in contentData! {
                
                if moduleType == "VideoDetailModule" {
                   
                    moduleContentArray.append(parseFilmDetailsAPIContent(filmContentJson: moduleContent as! Dictionary<String, AnyObject>))
                }
                else if moduleType == "ShowDetailModule" {
                    
                    moduleContentArray.append(parseShowDetailsAPIContent(showContentJson: moduleContent as! Dictionary<String, AnyObject>))
                }
            }
        }
        
        moduleObject.moduleData = moduleContentArray
        
        return moduleObject
    }
    
    
    //MARK: Method to parse video details
    func parseFilmDetailsAPIContent(filmContentJson:Dictionary<String, AnyObject>) -> SFFilm {
        
        let moduleAPIParser = ModuleAPIParser()
        let filmObject:SFFilm = moduleAPIParser.parseFilmContentData(filmContentDict: filmContentJson)
        
        return filmObject
    }
    
    
    //MARK: Method to parse show details
    func parseShowDetailsAPIContent(showContentJson:Dictionary<String, AnyObject>) -> SFShow {
        
        let moduleAPIParser = ModuleAPIParser()
        let showObject:SFShow = moduleAPIParser.parseShowContentData(showContentDict: showContentJson)
        
        return showObject
    }
    
    
    //MARK: Method to parse video urls and video free status
    func parseVideoURLAPIContent(filmURLContentJson:Dictionary<String, AnyObject>) -> Dictionary<String, Any> {
        
        let streamInfoJson:Dictionary<String, AnyObject>? = filmURLContentJson["streamingInfo"] as? Dictionary<String, AnyObject>
        let moduleAPIParser = ModuleAPIParser()
        let filmURLs:Dictionary<String, AnyObject>? = moduleAPIParser.parseFilmURLsData(filmURLContentJson: streamInfoJson)
        
        let isFreeVideo = moduleAPIParser.parseFilmGistData(filmGistJson: filmURLContentJson["gist"] as? Dictionary<String, AnyObject>)
        let subTitleDict = self.parseVideoSubTitleURLAPIContent(filmContentJson: filmURLContentJson)
        var videoURLWithStatusDict:Dictionary<String, Any> = ["urls":filmURLs as Any, "isFreeVideo":isFreeVideo, "subTitles":subTitleDict]

        let relatedVideoIds:Array<Any>? = self.parseRelatedVideoIds(filmContentJson: filmURLContentJson)
        
        if relatedVideoIds != nil {
            
            videoURLWithStatusDict["relatedVideoIds"] = relatedVideoIds
        }
        
        let imageUrls:Dictionary<String, String>? = moduleAPIParser.parseFilmImages(filmGistJson: filmURLContentJson["gist"] as? Dictionary<String, AnyObject>)

        if imageUrls != nil {
            
            videoURLWithStatusDict["imageUrls"] = imageUrls
        }
        
        return videoURLWithStatusDict
    }
    
    
    //MARK: Method to parse download video urls and video free status
    func parseDownloadURLsAPIContent(filmURLsContentJson:Dictionary<String, AnyObject>, filmObject:SFFilm) -> SFFilm {
        
        let streamingInfoDict: Dictionary<String, AnyObject>? = filmURLsContentJson["streamingInfo"] as? Dictionary<String, AnyObject>
        filmObject.isLiveStream = streamingInfoDict?["isLiveStream"] as? Bool
        let videoAssetsDict:Dictionary<String, AnyObject>? = streamingInfoDict?["videoAssets"] as? Dictionary<String, AnyObject>
        let mpeg:Array<Dictionary<String, AnyObject>?>? = videoAssetsDict?["mpeg"] as? Array<Dictionary<String, AnyObject>>
        
        if mpeg != nil {
            for filmURLObject in mpeg! {
                let filmURLLocalObj :SFFilmURL = SFFilmURL()
                filmURLLocalObj.renditionValue = filmURLObject?["renditionValue"] as? String ?? ""
                filmURLLocalObj.renditionURL = filmURLObject?["url"] as? String ?? ""
                filmObject.filmUrl.add(filmURLLocalObj)
            }
        }
        
        return filmObject
    }
    
    
    //MARK: Method to parse video urls
    func parseVideoSubTitleURLAPIContent(filmContentJson:Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject> {
        
        let streamInfoJson:Dictionary<String, AnyObject>? = filmContentJson["contentDetails"] as? Dictionary<String, AnyObject>
        let moduleAPIParser = ModuleAPIParser()
        let filmSubTitleURL:Dictionary<String, AnyObject>? = moduleAPIParser.parseFilmSUbTitleURLsData(filmURLContentJson: streamInfoJson)
        
        return filmSubTitleURL!
    }
    
    //MARK: Method to parse related video ids
    func parseRelatedVideoIds(filmContentJson:Dictionary<String, AnyObject>) -> Array<Any>? {
        
        let relatedVideoJson:Dictionary<String, AnyObject>? = filmContentJson["contentDetails"] as? Dictionary<String, AnyObject>
        let moduleAPIParser = ModuleAPIParser()
        let relatedVideoIds:Array<Any>? = moduleAPIParser.parseRelatedVideoIdsData(relatedVideoJson: relatedVideoJson)
        return relatedVideoIds
    }
    
    
    //MARK: method to parse typeahead search results
    func parseTypeAheadSearchResults(searchResults:Array<AnyObject>) -> SFModuleObject {
        
        let moduleObject = SFModuleObject()
        
        //Commented as would need to resuse once the page api is available for search
//        moduleObject.moduleId = moduleContentJson["id"] as? String
//        moduleObject.moduleTitle = moduleContentJson["title"] as? String
//        moduleObject.moduleType = moduleContentJson["moduleType"] as? String
        
        var moduleContentArray:Array <AnyObject> = []
        
//        let contentData = moduleContentJson["contentData"] as? Array<AnyObject>
        
//        if contentData != nil {
//            
//            for moduleContent in contentData! {
        
//                moduleContentArray.append(ModuleAPIParser.sharedInstance.parseModuleContentData(moduleContentDict: moduleContent as! Dictionary<String, AnyObject>))
//            }
//        }
        
        
//        var searchResultsArray:Array<SFGridObject> = []
        
        for searchResult in searchResults {
            
            let moduleAPIParser = ModuleAPIParser()
            
            if searchResult is Dictionary<String, AnyObject> {
                
                let gistDict:Dictionary<String, AnyObject>? = (searchResult as! Dictionary<String, AnyObject>)["gist"] as? Dictionary<String, AnyObject>
                
                if gistDict != nil {
                    moduleContentArray.append(moduleAPIParser.parseSearchResultDict(searchResultDict: gistDict!))
                }
            }
        }
        
        moduleObject.moduleData = moduleContentArray

        return moduleObject
    }
    
    
    //MARK: method to parse queue results
    func parseQueueResults(queueResults:Array<AnyObject>) -> SFModuleObject {
        
        let moduleObject = SFModuleObject()

        var moduleContentArray:Array <AnyObject> = []
        
        for queueResult in queueResults {
            
            let moduleAPIParser = ModuleAPIParser()
            
            let gridObject:SFGridObject? = moduleAPIParser.parseQueueResultDict(queueResultDict: queueResult as! Dictionary<String, AnyObject>)
            
            if gridObject != nil {
                
                moduleContentArray.append(gridObject!)
            }
        }
        
        moduleObject.moduleData = moduleContentArray
        
        return moduleObject
    }
    
    
    //#if os(iOS)
    //MARK: Method to parse Subscription Plan page Content
    func parsePlanPageAPIContent(pageContentJson:Dictionary<String, AnyObject>) -> PageAPIObject{
        
        let pageAPIObject = PageAPIObject()
        
        pageAPIObject.pageId = pageContentJson["id"] as? String
        pageAPIObject.pagePath = pageContentJson["path"] as? Array<Any>
        pageAPIObject.pageTitle = pageContentJson["title"] as? String
        
        var pageModuleArray:Dictionary<String,AnyObject> = [:]
        
        if pageContentJson["modules"] != nil {
            
            for moduleContent in pageContentJson["modules"] as! Array <AnyObject> {
                
                let moduleObject:SFModuleObject? = parsePlanPageModuleContent(moduleContentJson: moduleContent as! Dictionary<String, AnyObject>)
                
                if moduleObject != nil {
                    
                    if moduleObject?.moduleData != nil && (moduleObject?.moduleData?.count)! > 0 {
                        
                        pageModuleArray["\(moduleObject?.moduleId ?? "")"] = moduleObject!
                    }
                    else if moduleObject?.moduleType == "TextModule" {
                        
                        pageModuleArray["\(moduleObject?.moduleId ?? "")"] = moduleObject!
                    }
                }
            }
        }
        
        pageAPIObject.pageModules = pageModuleArray
        
        return pageAPIObject
    }
    
    
    //MARK: Method to parse Page Modules list coming in page api response
    func parsePlanPageModuleContent(moduleContentJson:Dictionary<String, AnyObject>) -> SFModuleObject {
        
        let moduleObject = SFModuleObject()
        
        moduleObject.moduleId = moduleContentJson["id"] as? String
        moduleObject.moduleTitle = moduleContentJson["title"] as? String
        moduleObject.moduleType = moduleContentJson["moduleType"] as? String
        moduleObject.moduleDescription = moduleContentJson["description"] as? String
        
        var moduleContentArray:Array <AnyObject> = []
        
        let contentData = moduleContentJson["contentData"] as? Array<AnyObject>
        
        if contentData != nil {
            
            for moduleContent in contentData! {
                
                let moduleAPIParser = ModuleAPIParser()
                
                if moduleObject.moduleType != nil && moduleObject.moduleType == "ViewPlanModule" {
                    moduleContentArray.append(moduleAPIParser.parsePlanPageModuleContentData(moduleContentDict: moduleContent as! Dictionary<String, AnyObject>))
                }
            }
        }
        
//        //Sorting of view plan module.
//        if moduleObject.moduleType == "ViewPlanModule" && moduleContentArray.count > 1 {
//
//            moduleContentArray.sort(by: {
//
//                let paymentModel1 = ($0 as! PaymentModel).recurringPaymentsTotal?.floatValue ?? 0
//                let paymentModel2 = ($1 as! PaymentModel).recurringPaymentsTotal?.floatValue ?? 1
//
//                return paymentModel1 > paymentModel2
//            })
//        }
        
        moduleObject.moduleData = moduleContentArray
        
        return moduleObject
    }
   // #endif
}
