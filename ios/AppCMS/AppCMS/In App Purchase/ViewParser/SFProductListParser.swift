//
//  SFProductListParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 11/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFProductListParser: NSObject {

    func parseProductListJson(productListDictionary: Dictionary<String, AnyObject>) -> SFProductListObject {
        
        let productListObject = SFProductListObject()
        
        productListObject.moduleId = productListDictionary["id"] as? String
        productListObject.viewName = productListDictionary["view"] as? String
        productListObject.type = productListDictionary["type"] as? String
        
        let blockName:String? = productListDictionary["blockName"] as? String
        
        if blockName != nil {
            
            if PageUIBlocks.sharedInstance.blockComponents != nil {
                let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                
                if pageBlockComponentDict != nil {
                    
                    if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                        
                        productListObject.components = (pageBlockComponentDict?["components"] as? Array<AnyObject>)!
                    }
                    
                    if pageBlockComponentDict?["layout"] != nil {
                        
                        productListObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                    }
                }
            }
        }
        
        if productListObject.components.count == 0 {
            
            let componentArray = productListDictionary["components"] as? Array<Dictionary<String, Any>>
            
            if componentArray != nil {
                productListObject.components = componentConfigArray(componentsArray: productListDictionary["components"] as? Array<Dictionary<String, Any>>)
            }
        }
        
        if productListObject.layoutObjectDict.count == 0 {
            
            let layoutDict = productListDictionary["layout"] as? Dictionary<String, Any>
            if layoutDict != nil {
                let layoutObjectParser = LayoutObjectParser()
                let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
                productListObject.layoutObjectDict = layoutObjectDict
            }
        }
        
        return productListObject
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
