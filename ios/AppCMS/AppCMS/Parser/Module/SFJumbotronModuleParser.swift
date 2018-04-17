//
//  SFJumbotronModuleParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 24/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFJumbotronModuleParser: NSObject {

    //MARK: Method to create singeleton class object
//    static let sharedInstance:SFJumbotronModuleParser = {
//        
//        let instance = SFJumbotronModuleParser()
//        
//        return instance
//    }()
    
    func parseJumbotronJson(jumbotronDict: Dictionary<String, AnyObject>) -> SFJumbotronObject {
        
        let jumbotronObject = SFJumbotronObject()
        
        jumbotronObject.type = jumbotronDict["type"] as? String
        jumbotronObject.apiURL = jumbotronDict["apiURL"] as? String
        jumbotronObject.trayId = jumbotronDict["id"] as? String
        jumbotronObject.type = jumbotronDict["type"] as? String
        jumbotronObject.jumbotronViewName = jumbotronDict["view"] as? String
        
        let jumbotronSettingsDict:Dictionary<String, AnyObject>? = jumbotronDict["settings"] as? Dictionary<String, AnyObject>
        jumbotronObject.isJumbotronLoopEnabled = jumbotronSettingsDict?["loop"] as? Bool
        jumbotronObject.jumbotronImageType = jumbotronSettingsDict?["thumbnailType"] as? String
        jumbotronObject.animationDuration = jumbotronSettingsDict?["animationDuration"] as? Int
        
        if DEBUGMODE {
            var filePath:String
            filePath = (Bundle.main.resourcePath?.appending("/Carousel_AppleTV.json"))!
            if FileManager.default.fileExists(atPath: filePath){
                let jsonData:Data = FileManager.default.contents(atPath: filePath)!
                let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, AnyObject>
                
                let jumbotronSettingsDict:Dictionary<String, AnyObject>? = /*Change this for debug layout for settings*/jumbotronDict["settings"] as? Dictionary<String, AnyObject>
                jumbotronObject.isJumbotronLoopEnabled = jumbotronSettingsDict?["loop"] as? Bool
                jumbotronObject.jumbotronImageType = jumbotronSettingsDict?["thumbnailType"] as? String
                jumbotronObject.animationDuration = jumbotronSettingsDict?["animationDuration"] as? Int
                
                let layoutDict = responseJson["layout"] as? Dictionary<String, Any>
                let componentArray = responseJson["components"] as? Array<Dictionary<String, AnyObject>>
                if componentArray != nil {
                    jumbotronObject.jumbotronComponents = componentConfigArray(componentsArray: componentArray!)
                }
                let layoutObjectParser = LayoutObjectParser()
                jumbotronObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            }
        } else {
            let jumbotronSettingsDict:Dictionary<String, AnyObject>? = jumbotronDict["settings"] as? Dictionary<String, AnyObject>
            jumbotronObject.isJumbotronLoopEnabled = jumbotronSettingsDict?["loop"] as? Bool
            jumbotronObject.jumbotronImageType = jumbotronSettingsDict?["thumbnailType"] as? String
            jumbotronObject.animationDuration = jumbotronSettingsDict?["animationDuration"] as? Int
            
            let blockName:String? = jumbotronDict["blockName"] as? String
            
            if blockName != nil {
                
                if PageUIBlocks.sharedInstance.blockComponents != nil {
                    let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                    
                    if pageBlockComponentDict != nil {
                        
                        if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                            
                            jumbotronObject.jumbotronComponents = pageBlockComponentDict?["components"] as! Array<AnyObject>
                        }
                        
                        if pageBlockComponentDict?["layout"] != nil {
                            
                            jumbotronObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                        }
                    }
                }
            }
            
            if jumbotronObject.jumbotronComponents.count == 0 {
                
                let componentArray = jumbotronDict["components"] as? Array<Dictionary<String, AnyObject>>
                if componentArray != nil {
                    
                    let componentsUIParser = ComponentUIParser()
                    jumbotronObject.jumbotronComponents = componentsUIParser.componentConfigArray(componentsArray: componentArray! as Array<Dictionary<String, AnyObject>>)
                }
            }
            
            if jumbotronObject.layoutObjectDict.count == 0 {
                
                let layoutObjectParser = LayoutObjectParser()
                jumbotronObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: jumbotronDict["layout"] as! Dictionary<String, Any>)
            }
        }

        return jumbotronObject
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
            else if typeOfModule == "image"
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
            else if typeOfModule == "pageControl"
            {
                let pageControlParser = SFPageControlParser()
                let pageControlObject = pageControlParser.parsePageControlJson(pageControlDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(pageControlObject)
            }
            else if typeOfModule == "carousel" {
                
                let carouselParser = SFCarouselParser()
                let carouselObject = carouselParser.parseCarouselJson(carouselDict: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(carouselObject)
            }
        }
        
        return componentArray
    }
}
