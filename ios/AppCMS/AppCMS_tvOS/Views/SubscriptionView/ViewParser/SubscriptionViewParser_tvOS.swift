//
//  SubscritionViewParser_tvOS.swift
//  AppCMS
//
//  Created by Rajni Pathak on 01/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SubscriptionViewParser_tvOS: NSObject {
    func parserLayoutJson(viewModuleDictionary: Dictionary<String, AnyObject>) -> SubscriptionViewObject_tvOS
    {
        let associatedViewObject = SubscriptionViewObject_tvOS()
        
        associatedViewObject.moduleID = viewModuleDictionary["id"] as? String
        associatedViewObject.moduleType = viewModuleDictionary["view"] as? String
        associatedViewObject.moduleTitle = viewModuleDictionary["title"] as? String
        
        var layoutDict : Dictionary<String, Any>?
        if DEBUGMODE {//}|| TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            var filePath:String
            if associatedViewObject.moduleType == "AC SelectPlan 01" {
                filePath = (Bundle.main.resourcePath?.appending("/SubscriptionModule_AppleTV_01.json"))!
            } else {
                filePath = (Bundle.main.resourcePath?.appending("/SubscriptionModule_AppleTV_02.json"))!
            }
            
            if FileManager.default.fileExists(atPath: filePath){
                let jsonData:Data = FileManager.default.contents(atPath: filePath)!
                let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, AnyObject>
                layoutDict = responseJson["layout"] as? Dictionary<String, Any>
                let componentArray = responseJson["components"] as? Array<Dictionary<String, AnyObject>>
                if componentArray != nil {
                    associatedViewObject.components = componentConfigArray(componentsArray: componentArray!) as Array<AnyObject>
                }
            }
        } else {
            let componentArray = viewModuleDictionary["components"] as? Array<Dictionary<String, AnyObject>>
            
            if componentArray != nil {
                associatedViewObject.components = componentConfigArray(componentsArray: componentArray!) as Array<AnyObject>
            }
            layoutDict = viewModuleDictionary["layout"] as? Dictionary<String, Any>
        }
        
        //
        if layoutDict != nil {
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            associatedViewObject.layoutObjectDict = layoutObjectDict
        }
        
        return associatedViewObject
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
            else if typeOfModule == "collectionGrid" {
                let colletionGridParser = SFCollectionGridParser()
                let collectionGridObject = colletionGridParser.parseCollectionGridJson(collectionGridDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(collectionGridObject)
            }
            
        }
        
        return componentArray
    }


}
