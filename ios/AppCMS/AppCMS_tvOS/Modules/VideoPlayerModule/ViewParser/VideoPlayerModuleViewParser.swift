//
//  VideoPlayerModuleViewParser.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 01/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class VideoPlayerModuleViewParser: NSObject {
    
    func parseLayoutJson(viewModuleDictionary: Dictionary<String, AnyObject>) -> VideoPlayerModuleViewObject {
        let associatedViewObject = VideoPlayerModuleViewObject()
        
        associatedViewObject.moduleID = viewModuleDictionary["id"] as? String
        associatedViewObject.moduleType = viewModuleDictionary["view"] as? String
        associatedViewObject.moduleTitle = viewModuleDictionary["title"] as? String
        let settingDict = viewModuleDictionary["settings"] as? Dictionary<String, AnyObject>
        if let settings = settingDict {
            if let isZoomSupported = settings["isZoomSupported"] as? Bool{
                associatedViewObject.isZoomSupported = isZoomSupported
            }
            else{
                associatedViewObject.isZoomSupported = true
            }
        }
        
        var layoutKey = "layout"
        var componentsKey = "components"
        
        #if os(tvOS)
        if let isZoomSupported = associatedViewObject.isZoomSupported {
            if isZoomSupported {
                layoutKey = "layout_focusable"
                componentsKey = "components_focusable"
            }
        }
        #endif
        
        var componentArray : Array<Dictionary<String, AnyObject>>?
        let layoutObjectParser = LayoutObjectParser()

        if DEBUGMODE {
            let filePath = Bundle.main.resourcePath?.appending("/VideoPlayerHub_AppleTV_focusablePlayer.json")
            
            if FileManager.default.fileExists(atPath: filePath!){
                let jsonData:Data = FileManager.default.contents(atPath: filePath!)!
                let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, AnyObject>
                let localSettingDict = responseJson["settings"] as? Dictionary<String, AnyObject>
                if let settings = localSettingDict {
                    associatedViewObject.isZoomSupported = settings["isZoomSupported"] as? Bool
                }
                if let isZoomSupported = associatedViewObject.isZoomSupported {
                    if isZoomSupported {
                        layoutKey = "layout_focusable"
                        componentsKey = "components_focusable"
                    }
                }
                let layoutDict = responseJson[layoutKey] as? Dictionary<String, Any>
                associatedViewObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
                componentArray = responseJson[componentsKey] as? Array<Dictionary<String, AnyObject>>
                if componentArray != nil {
                    let componentsUIParser = ComponentUIParser()
                    associatedViewObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
                }
            }
        } else {
            componentArray = viewModuleDictionary[componentsKey] as? Array<Dictionary<String, AnyObject>>
            
            if componentArray != nil {
                let componentsUIParser = ComponentUIParser()
                associatedViewObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
            }
            
            if let layoutDict = viewModuleDictionary[layoutKey] {
                associatedViewObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict as! Dictionary<String, Any>)
            }
        }
        return associatedViewObject
    }
}
