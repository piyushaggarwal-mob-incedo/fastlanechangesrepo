//
//  SFCRWModuleViewParser.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 01/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class SFCRWModuleViewParser: NSObject {
    
    func parseLayoutJson(viewModuleDictionary: Dictionary<String, AnyObject>) -> SFCRWModuleViewObject {
        let associatedViewObject = SFCRWModuleViewObject()
        
        associatedViewObject.moduleID = viewModuleDictionary["id"] as? String
        associatedViewObject.moduleType = viewModuleDictionary["view"] as? String
        associatedViewObject.moduleTitle = viewModuleDictionary["title"] as? String
        let settingDict = viewModuleDictionary["settings"] as? Dictionary<String, AnyObject>
        if let settings = settingDict {
            associatedViewObject.moduleDuration = settings["duration"] as? Double
            associatedViewObject.moduleSupportsAnimation = settings["animates"] as? Bool
        }
        
        
        var componentArray : Array<Dictionary<String, AnyObject>>?
        let layoutObjectParser = LayoutObjectParser()

        if DEBUGMODE {
            var filePath:String
            filePath = (Bundle.main.resourcePath?.appending("/CRW_AppleTV.json"))!
            if FileManager.default.fileExists(atPath: filePath){
                let jsonData:Data = FileManager.default.contents(atPath: filePath)!
                let responseJson:Array<Dictionary<String, AnyObject>>? = try! JSONSerialization.jsonObject(with:jsonData) as? Array<Dictionary<String, AnyObject>>
                let layoutDict = responseJson![0]["layout"] as? Dictionary<String, Any>
                componentArray = responseJson![0]["components"] as? Array<Dictionary<String, AnyObject>>
                if componentArray != nil {
                    associatedViewObject.components = componentConfigArray(componentsArray: componentArray!)
                }
                associatedViewObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            }
        } else {
            componentArray = viewModuleDictionary["components"] as? Array<Dictionary<String, AnyObject>>
            
            if componentArray != nil {
                associatedViewObject.components = componentConfigArray(componentsArray: componentArray!)
            }
            
            associatedViewObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: viewModuleDictionary["layout"] as! Dictionary<String, Any>)
        }
        return associatedViewObject
    }
    
    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {
        
        var componentArray:Array<AnyObject> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == "button" {
                let buttonParser = SFButtonParser()
                let buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if buttonObject.layoutObjectDict.isEmpty == false {
                    componentArray.append(buttonObject)
                }
            }
            else if typeOfModule == "label" {
                let labelParser = SFLabelParser()
                let labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if labelObject.layoutObjectDict.isEmpty == false {
                    componentArray.append(labelObject)
                }
            }
            else if typeOfModule == "progressView" {
                let progressViewParser = SFProgressViewParser()
                let progressViewObject = progressViewParser.parseProgressViewJson(progressViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if progressViewObject.layoutObjectDict.isEmpty == false {
                    componentArray.append(progressViewObject)
                }
            }
        }
        return componentArray
    }
}
