//
//  SFTrayParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 23/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFTrayParser: NSObject {
    
    func parseTrayJson(trayDictionary: Dictionary<String, AnyObject>) -> SFTrayObject {
        
        let trayObject = SFTrayObject()

        trayObject.type = trayDictionary["type"] as? String
        trayObject.apiURL = trayDictionary["apiURL"] as? String
        trayObject.trayId = trayDictionary["id"] as? String
        trayObject.type = trayDictionary["type"] as? String
        trayObject.trayViewName = trayDictionary["view"] as? String
        
        let traySettingsDict:Dictionary<String, AnyObject>? = trayDictionary["settings"] as? Dictionary<String, AnyObject>
        trayObject.trayImageType = traySettingsDict?["thumbnailType"] as? String

        var layoutDict : Dictionary<String, Any>?
        var componentArray : Array<Dictionary<String, AnyObject>>?

        if DEBUGMODE {//}|| TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            var filePath:String
            filePath = (Bundle.main.resourcePath?.appending("/Tray_AppleTV.json"))!
            if trayObject.trayViewName == "AC SeasonTray 01" {
                filePath = (Bundle.main.resourcePath?.appending("/Tray_03_AppleTV.json"))!
            }
            if trayObject.trayViewName == "AC Grid 01" {
                filePath = (Bundle.main.resourcePath?.appending("/Grid_AppleTV.json"))!
            }
            if trayObject.trayViewName == "AC Tray 03" || trayObject.type == "AC Tray 03" {
                filePath = (Bundle.main.resourcePath?.appending("/Tray_03_AppleTV.json"))!
            }
            if FileManager.default.fileExists(atPath: filePath){
                let jsonData:Data = FileManager.default.contents(atPath: filePath)!
                let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, AnyObject>
                layoutDict = responseJson["layout"] as? Dictionary<String, Any>
                componentArray = responseJson["components"] as? Array<Dictionary<String, AnyObject>>
                if componentArray != nil {
                    trayObject.trayComponents = componentConfigArray(componentsArray: componentArray)
                }
            }
        } else {
            
            let blockName:String? = trayDictionary["blockName"] as? String
            
            if blockName != nil {
                
                if PageUIBlocks.sharedInstance.blockComponents != nil {
                    let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                    
                    if pageBlockComponentDict != nil {
                        
                        if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                            
                            trayObject.trayComponents = pageBlockComponentDict?["components"] as! Array<AnyObject>
                        }
                        
                        if pageBlockComponentDict?["layout"] != nil {
                            
                            trayObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                        }
                    }
                }
            }
            
            if trayObject.layoutObjectDict.count == 0 {
                
                layoutDict = trayDictionary["layout"] as? Dictionary<String, Any>
            }
            
            if trayObject.trayComponents.count == 0 {
                
                componentArray = trayDictionary["components"] as? Array<Dictionary<String, AnyObject>>
                
                if componentArray != nil {
                    
                    let componentsUIParser = ComponentUIParser()
                    trayObject.trayComponents = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
                }
            }
        }
        
        if layoutDict != nil {
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            trayObject.layoutObjectDict = layoutObjectDict
        }
        return trayObject
    }
    
    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>?) -> Array<Any> {
        
        var componentArray:Array<Any> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray!  {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == "button"
            {
                let buttonParser = SFButtonParser()
                let buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(buttonObject)
            }
            else if typeOfModule == "image" {
                
                let imageParser = SFImageParser()
                let imageObject = imageParser.parseImageJson(imageDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(imageObject)
            }
            else if typeOfModule == "label" {
                
                let labelParser = SFLabelParser()
                let labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(labelObject)
            }
            else if typeOfModule == "actionLabel" {
                
                let labelParser = SFLabelParser()
                let labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(labelObject)
            }
            else if typeOfModule == "textView"
            {
                let textViewParser = SFTextViewParser()
                let textViewObject = textViewParser.parseTextViewJson(textViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(textViewObject)
            }
            else if typeOfModule == "separatorView"
            {
                let separatorViewParser = SFSeparatorViewParser()
                let separatorViewObject = separatorViewParser.parseSeparatorViewJson(separatorViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(separatorViewObject)
            }
            else if typeOfModule == "collectionGrid" {
                let colletionGridParser = SFCollectionGridParser()
                let collectionGridObject = colletionGridParser.parseCollectionGridJson(collectionGridDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(collectionGridObject)
            }
            else if typeOfModule == "progressView"
            {
                let progressViewParser = SFProgressViewParser()
                var progressViewObject = SFProgressViewObject()
                progressViewObject = progressViewParser.parseProgressViewJson(progressViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                componentArray.append(progressViewObject)
            }
            else if typeOfModule == "tableView" {
                
                let tableViewParser = SFTableViewParser()
                let tableViewObject = tableViewParser.parseTableViewJson(tableViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(tableViewObject)
            }
        }
        
        return componentArray
    }
}
