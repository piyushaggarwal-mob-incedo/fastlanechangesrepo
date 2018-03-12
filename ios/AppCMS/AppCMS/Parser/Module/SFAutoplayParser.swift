//
//  SFAutoplayParser.swift
//  AppCMS
//
//  Created by  Diksha Goyal on 10/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFAutoplayParser: NSObject {
    
//    //MARK: Method to create singeleton class object
//    static let sharedInstance:SFAutoplayParser = {
//        
//        let instance = SFAutoplayParser()
//        
//        return instance
//    }()
    
    func parseAutoplayModuleJson(autoplayModuleDictionary: Dictionary<String, AnyObject>) -> SFAutoplayObject
    {
        let autoPlayModuleObject = SFAutoplayObject()
        
        autoPlayModuleObject.moduleID = autoplayModuleDictionary["id"] as? String
        autoPlayModuleObject.moduleType = autoplayModuleDictionary["view"] as? String
        autoPlayModuleObject.backgroundColor = autoplayModuleDictionary["backgroundColor"] as? String
        autoPlayModuleObject.viewAlpha=autoplayModuleDictionary["alpha"] as? CGFloat
        autoPlayModuleObject.timerValue=autoplayModuleDictionary["value"] as? Int
        
        let blockName:String? = autoplayModuleDictionary["blockName"] as? String
        
        if blockName != nil {
            
            if PageUIBlocks.sharedInstance.blockComponents != nil {
                let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                
                if pageBlockComponentDict != nil {
                    
                    if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                        
                        autoPlayModuleObject.components = (pageBlockComponentDict?["components"] as? Array<AnyObject>)!
                    }
                    
                    if pageBlockComponentDict?["layout"] != nil {
                        
                        autoPlayModuleObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                    }
                }
            }
        }
        
        if autoPlayModuleObject.components.count == 0 {
            
            let componentArray = autoplayModuleDictionary["components"] as? Array<Dictionary<String, AnyObject>>
            
            if componentArray != nil {
                
                let componentsUIParser = ComponentUIParser()
                autoPlayModuleObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
            }
        }
        
        if autoPlayModuleObject.layoutObjectDict.count == 0 {
            
            let layoutObjectParser = LayoutObjectParser()
            autoPlayModuleObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: autoplayModuleDictionary["layout"] as! Dictionary<String, Any>)
        }
        
        return autoPlayModuleObject
    }
    
    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {
        
        var componentArray:Array<AnyObject> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == "button"
            {
                let buttonParser = SFButtonParser()
                var buttonObject = SFButtonObject()
                 buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(buttonObject)
            }
            else if typeOfModule == "image" || typeOfModule == "imageView"
            {
                let imageParser = SFImageParser()
                var imageObject = SFImageObject()
                 imageObject = imageParser.parseImageJson(imageDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(imageObject)
            }
            else if typeOfModule == "label"
            {
                let labelParser = SFLabelParser()
                var labelObject = SFLabelObject()
                labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(labelObject)
            }
            else if typeOfModule == "textView"
            {
                let textViewParser = SFTextViewParser()
                var textViewObject = SFTextViewObject()
                textViewObject = textViewParser.parseTextViewJson(textViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(textViewObject)
            }
           
            else if typeOfModule == "starRating"
            {
                #if os(iOS)
                    let starRatingParser = SFStarRatingParser()
                    var starRatingObject = SFStarRatingObject()
                starRatingObject = starRatingParser.parseStarRatingJson(starRatingDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    componentArray.append(starRatingObject)
                #endif
            }
            else if typeOfModule == "castView" {
                
                #if os(iOS)
                    let castViewParser = SFCastViewParser()
                    let castViewObject = castViewParser.parseCastViewJson(castViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    componentArray.append(castViewObject)
                #endif
            }
            
        }
        
        return componentArray
    }

    
}
