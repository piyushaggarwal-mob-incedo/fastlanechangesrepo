//
//  SFFooterViewParser.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 13/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFFooterViewParser: NSObject {

    func parserLayoutJson(viewModuleDictionary: Dictionary<String, AnyObject>) -> SFFooterViewObject
    {
        let associatedViewObject = SFFooterViewObject()
        
        associatedViewObject.moduleID = viewModuleDictionary["id"] as? String
        associatedViewObject.moduleType = viewModuleDictionary["view"] as? String
        associatedViewObject.moduleTitle = viewModuleDictionary["title"] as? String
        var layoutDict : Dictionary<String, Any>?

//        if DEBUGMODE {
            var filePath:String
            filePath = (Bundle.main.resourcePath?.appending("/Footer_AppleTv.json"))!
            if FileManager.default.fileExists(atPath: filePath){
                let jsonData:Data = FileManager.default.contents(atPath: filePath)!
                let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, AnyObject>
                layoutDict = responseJson["layout"] as? Dictionary<String, Any>
                let componentArray = responseJson["components"] as? Array<Dictionary<String, AnyObject>>
                if componentArray != nil {
                    associatedViewObject.components = componentConfigArray(componentsArray: componentArray!)
                }
            }
//        }
//        else {
//            let componentArray = viewModuleDictionary["components"] as? Array<Dictionary<String, AnyObject>>
//
//            if componentArray != nil {
//                associatedViewObject.components = componentConfigArray(componentsArray: componentArray!)
//            }
//            layoutDict = viewModuleDictionary["layout"] as? Dictionary<String, Any>
//        }
        
        
        
        if layoutDict != nil {
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            associatedViewObject.layoutObjectDict = layoutObjectDict
        }
        
        return associatedViewObject
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
        }
        
        return componentArray
    }

}
