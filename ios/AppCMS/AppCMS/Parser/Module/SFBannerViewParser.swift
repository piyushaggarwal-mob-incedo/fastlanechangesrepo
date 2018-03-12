//
//  SFBannerViewParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 14/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFBannerViewParser: NSObject {

    func parseBannerViewJson(bannerViewDictionary: Dictionary<String, AnyObject>) -> SFBannerViewObject {
        
        var bannerViewObject = SFBannerViewObject()
        
        bannerViewObject.type = bannerViewDictionary["type"] as? String
        bannerViewObject.apiURL = bannerViewDictionary["apiURL"] as? String
        bannerViewObject.bannerViewId = bannerViewDictionary["id"] as? String
        bannerViewObject.type = bannerViewDictionary["type"] as? String
        bannerViewObject.viewName = bannerViewDictionary["view"] as? String
        
        var layoutDict : Dictionary<String, Any>?
        var componentArray : Array<Dictionary<String, AnyObject>>?
        
        let blockName:String? = bannerViewDictionary["blockName"] as? String
        bannerViewObject.blockName = blockName
        
        if blockName != nil {
            
            if PageUIBlocks.sharedInstance.blockComponents != nil {
                let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                
                if pageBlockComponentDict != nil {
                    
                    if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                        
                        bannerViewObject.bannerViewComponents = pageBlockComponentDict?["components"] as! Array<AnyObject>
                    }
                    
                    if pageBlockComponentDict?["layout"] != nil {
                        
                        bannerViewObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                    }
                }
            }
        }
        
        if bannerViewObject.layoutObjectDict.count == 0 {
            
            layoutDict = bannerViewDictionary["layout"] as? Dictionary<String, Any>
        }
        
        if bannerViewObject.bannerViewComponents.count == 0 {
            
            componentArray = bannerViewDictionary["components"] as? Array<Dictionary<String, AnyObject>>
            
            if componentArray != nil {
                
                let componentsUIParser = ComponentUIParser()
                bannerViewObject.bannerViewComponents = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
            }
        }
        
        if layoutDict != nil {
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            bannerViewObject.layoutObjectDict = layoutObjectDict
        }
        
        let settingsDict:Dictionary<String, AnyObject>? = bannerViewDictionary["settings"] as? Dictionary<String, AnyObject>
        
        if settingsDict != nil {
            
            bannerViewObject = self.parseSettingsDictionary(settingsDict: settingsDict!, bannerViewObject: bannerViewObject)
        }
        
        return bannerViewObject
    }
    
    
    //MARK: Method to parse banner view settings
    private func parseSettingsDictionary(settingsDict: Dictionary<String, AnyObject>, bannerViewObject:SFBannerViewObject) -> SFBannerViewObject {
        
        bannerViewObject.bannerImage = settingsDict["image"] as? String
        bannerViewObject.bannerViewBackgroundColor = settingsDict["backgroundColor"] as? String
        bannerViewObject.bannerTitle = settingsDict["title"] as? String
        bannerViewObject.bannerTitleTextColor = settingsDict["textColor"] as? String
        
        var gridOptionArray:Array<SFLinkObject> = []
        
        let socialLinkArray:Array<Dictionary<String, AnyObject>>? = settingsDict["socialLinks"] as? Array<Dictionary<String, AnyObject>>
        
        if socialLinkArray != nil {
            
            for socialLinkDict:Dictionary<String, AnyObject> in socialLinkArray! {
                
                if let linkObject = self.parseGridOptions(gridOptionsDict: socialLinkDict) {
                    
                    gridOptionArray.append(linkObject)
                }
            }
        }
        
        let linksArray:Array<Dictionary<String, AnyObject>>? = settingsDict["links"] as? Array<Dictionary<String, AnyObject>>
        
        if linksArray != nil {
            
            for linkDict:Dictionary<String, AnyObject> in linksArray! {
                
                if let linkObject = self.parseGridOptions(gridOptionsDict: linkDict) {
                    
                    gridOptionArray.append(linkObject)
                }
            }
        }
        
        bannerViewObject.bannerGridOptions = gridOptionArray
        return bannerViewObject
    }

    
    //MARK: Method to parse banner view grid options
    private func parseGridOptions(gridOptionsDict:Dictionary<String, AnyObject>) -> SFLinkObject? {
        
        let platformDict:Dictionary<String, Any>? = gridOptionsDict["platforms"] as? Dictionary<String, Any>
        
        if platformDict != nil {
            
            let isAvailableForiOS:Bool = platformDict?["ios"] as? Bool ?? false
            
            if isAvailableForiOS {
                
                let linkObject = SFLinkObject()
                
                linkObject.displayedPath = gridOptionsDict["displayedPath"] as? String
                linkObject.title = gridOptionsDict["title"] as? String
                return linkObject
            }
        }
        else {
            
            let linkObject = SFLinkObject()
            
            linkObject.displayedPath = gridOptionsDict["displayedPath"] as? String
            linkObject.title = gridOptionsDict["title"] as? String
            return linkObject
        }
        
        return nil
    }
}
