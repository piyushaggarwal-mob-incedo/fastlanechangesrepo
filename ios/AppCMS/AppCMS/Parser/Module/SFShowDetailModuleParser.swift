//
//  SFShowDetailModuleParser.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 20/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFShowDetailModuleParser: NSObject {
    
    func parseShowDetailModuleJson(showDetailModuleDictionary: Dictionary<String, AnyObject>) -> SFShowDetailModuleObject
    {
        let showModuleObject = SFShowDetailModuleObject()
        
        showModuleObject.moduleID = showDetailModuleDictionary["id"] as? String
        showModuleObject.moduleType = showDetailModuleDictionary["view"] as? String
        showModuleObject.moduleTitle = showDetailModuleDictionary["title"] as? String
        
        if DEBUGMODE {
            var filePath:String
            filePath = (Bundle.main.resourcePath?.appending("/ShowDetail_AppleTV.json"))!
            if FileManager.default.fileExists(atPath: filePath){
                let jsonData:Data = FileManager.default.contents(atPath: filePath)!
                let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, AnyObject>
                let layoutDict = responseJson["layout"] as? Dictionary<String, Any>
                let componentArray = responseJson["components"] as? Array<Dictionary<String, AnyObject>>
                if componentArray != nil {
                    showModuleObject.showDetailModuleComponents = componentConfigArray(componentsArray: componentArray!)
                }
                
                let layoutObjectParser = LayoutObjectParser()
                showModuleObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            }
        } else {
            
            let blockName:String? = showDetailModuleDictionary["blockName"] as? String
            
            if blockName != nil {
                
                if PageUIBlocks.sharedInstance.blockComponents != nil {
                    let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                    
                    if pageBlockComponentDict != nil {
                        
                        if pageBlockComponentDict?["components"] != nil {
                            
                            showModuleObject.showDetailModuleComponents = pageBlockComponentDict?["components"] as? Array<AnyObject>
                        }
                        
                        if pageBlockComponentDict?["layout"] != nil {
                            
                            showModuleObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                        }
                    }
                }
            }
            
            if showModuleObject.showDetailModuleComponents == nil || showModuleObject.showDetailModuleComponents?.count == 0 {
                
                let componentArray = showDetailModuleDictionary["components"] as? Array<Dictionary<String, AnyObject>>
                
                if componentArray != nil {
                    
                    let componentsUIParser = ComponentUIParser()
                    showModuleObject.showDetailModuleComponents = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
                }
            }
            
            if showModuleObject.layoutObjectDict.count == 0 {
                
                let layoutObjectParser = LayoutObjectParser()
                showModuleObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: showDetailModuleDictionary["layout"] as! Dictionary<String, Any>)
            }
        }
        
        return showModuleObject
    }
    
    
    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {
        
        var componentArray:Array<AnyObject> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == "button"
            {
                let buttonParser = SFButtonParser()
                let buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(buttonObject)
            }
            else if typeOfModule == "image" || typeOfModule == "imageView"
            {
                let imageParser = SFImageParser()
                let imageObject = imageParser.parseImageJson(imageDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(imageObject)
            }
            else if typeOfModule == "label"
            {
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
            else if typeOfModule == "starRating"
            {
                #if os(iOS)
                    let ratingViewParser = SFStarRatingParser()
                    let ratingViewObject = ratingViewParser.parseStarRatingJson(starRatingDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    componentArray.append(ratingViewObject)
                #endif
            }
            else if typeOfModule == "castView" {
                
                let castViewParser = SFCastViewParser()
                let castViewObject = castViewParser.parseCastViewJson(castViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(castViewObject)
            }
            else if typeOfModule == "progressView"
            {
                let progressViewParser = SFProgressViewParser()
                let progressViewObject = progressViewParser.parseProgressViewJson(progressViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(progressViewObject)
            }
            else if typeOfModule == "headerView"
            {
                #if os(tvOS)
                    let headerViewParser = SFHeaderViewParser()
                    let headerViewObject = headerViewParser.parseLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    componentArray.append(headerViewObject)
                #endif
            }
            else if typeOfModule == "AC SeasonTray 01"
            {
                let trayParser = SFTrayParser()
                let trayObject = trayParser.parseTrayJson(trayDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if trayObject.layoutObjectDict.isEmpty == false {
                    componentArray.append(trayObject)
                }
            }
        }
        
        return componentArray
    }
}
