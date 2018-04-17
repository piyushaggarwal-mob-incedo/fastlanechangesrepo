//
//  SFPlanMetaDataViewParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 11/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFPlanMetaDataViewParser: NSObject {

    func parsePlanMetaDataViewJson(planMetaDataViewDictionary: Dictionary<String, AnyObject>) -> SFPlanMetaDataViewObject {
        
        let planMetaDataViewObject = SFPlanMetaDataViewObject()
        
        planMetaDataViewObject.keyName = planMetaDataViewDictionary["key"] as? String
        planMetaDataViewObject.type = planMetaDataViewDictionary["type"] as? String
        
        let componentArray = planMetaDataViewDictionary["components"] as? Array<Dictionary<String, Any>>
        
        if componentArray != nil {
            planMetaDataViewObject.components = componentConfigArray(componentsArray: planMetaDataViewDictionary["components"] as? Array<Dictionary<String, Any>>)
        }
        
        let layoutDict = planMetaDataViewDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            planMetaDataViewObject.layoutObjectDict = layoutObjectDict
        }
        return planMetaDataViewObject
    }
    
    
    func componentConfigArray(componentsArray:Array<Dictionary<String, Any>>?) -> Array<Any> {
        
        var componentArray:Array<Any> = []
        
        for moduleDictionary: Dictionary<String, Any> in componentsArray!  {
            
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
        }
        
        return componentArray
    }
}
