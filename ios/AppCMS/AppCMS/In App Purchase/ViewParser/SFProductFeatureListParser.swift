//
//  SFProductFeatureListParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 11/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFProductFeatureListParser: NSObject {
    
    func parseProductFeatureListJson(productFeatureListDictionary: Dictionary<String, AnyObject>) -> SFProductFeatureListObject {
        
        let productFeatureListObject = SFProductFeatureListObject()
        
        productFeatureListObject.moduleId = productFeatureListDictionary["id"] as? String
        productFeatureListObject.viewName = productFeatureListDictionary["view"] as? String
        productFeatureListObject.type = productFeatureListDictionary["type"] as? String
        
        let settingsDict = productFeatureListDictionary["settings"] as? Dictionary<String, AnyObject>
        
        if settingsDict != nil {
            
            let itemList = settingsDict?["items"] as? Array<AnyObject>
            
            if itemList != nil {
                
                for featueList in itemList! {
                    
                    let moduleAPIParser = ModuleAPIParser()
                    productFeatureListObject.featureListArray.append(moduleAPIParser.parsePlanPageFeatureListModuleContentData(moduleContentDict: featueList as! Dictionary<String, AnyObject>))
                }
            }
        }
        
        let blockName:String? = productFeatureListDictionary["blockName"] as? String
        
        if blockName != nil {
            
            if PageUIBlocks.sharedInstance.blockComponents != nil {
                let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                
                if pageBlockComponentDict != nil {
                    
                    if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                        
                        productFeatureListObject.components = (pageBlockComponentDict?["components"] as? Array<AnyObject>)!
                    }
                    
                    if pageBlockComponentDict?["layout"] != nil {
                        
                        productFeatureListObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                    }
                }
            }
        }
        
        if productFeatureListObject.components.count == 0 {
            
            let componentArray = productFeatureListDictionary["components"] as? Array<Dictionary<String, Any>>
            
            if componentArray != nil {
                productFeatureListObject.components = componentConfigArray(componentsArray: productFeatureListDictionary["components"] as? Array<Dictionary<String, Any>>)
            }
        }
        
        if productFeatureListObject.layoutObjectDict.count == 0 {
            
            let layoutDict = productFeatureListDictionary["layout"] as? Dictionary<String, Any>
            if layoutDict != nil {
                let layoutObjectParser = LayoutObjectParser()
                let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
                productFeatureListObject.layoutObjectDict = layoutObjectDict
            }
        }
        return productFeatureListObject
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
            else if typeOfModule == "collectionGrid" {
                let colletionGridParser = SFCollectionGridParser()
                let collectionGridObject = colletionGridParser.parseCollectionGridJson(collectionGridDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(collectionGridObject)
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
