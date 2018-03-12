//
//  SFTopHeadLineViewParser.swift
//  AppCMS
//
//  Created by Rajni Pathak on 19/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import Foundation

func parseTopHeadLineViewJson(topHeadlineViewDictionary: Dictionary<String, AnyObject>) -> SFTopHeadLineViewObject {
    
    let topHeadlineObject = SFTopHeadLineViewObject()
    
    topHeadlineObject.type = topHeadlineViewDictionary["type"] as? String
    topHeadlineObject.key = topHeadlineViewDictionary["key"] as? String
    topHeadlineObject.topHeadlineTitle = topHeadlineViewDictionary["title"] as? String
    var layoutDict : Dictionary<String, Any>?
    var componentArray : Array<Dictionary<String, AnyObject>>?
    
    let blockName:String? = topHeadlineViewDictionary["blockName"] as? String
    topHeadlineObject.blockName = blockName
    
    if blockName != nil {
        
        if PageUIBlocks.sharedInstance.blockComponents != nil {
            let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
            
            if pageBlockComponentDict != nil {
                
                if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                    
                    topHeadlineObject.topHeadlineViewComponents = pageBlockComponentDict?["components"] as! Array<AnyObject>
                }
                
                if pageBlockComponentDict?["layout"] != nil {
                    
                    topHeadlineObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                }
            }
        }
    }
    
    if topHeadlineObject.layoutObjectDict.count == 0 {
        
        layoutDict = topHeadlineViewDictionary["layout"] as? Dictionary<String, Any>
    }
    
    if topHeadlineObject.topHeadlineViewComponents.count == 0 {
        
        componentArray = topHeadlineViewDictionary["components"] as? Array<Dictionary<String, AnyObject>>
        
        if componentArray != nil {
            
            let componentsUIParser = ComponentUIParser()
            topHeadlineObject.topHeadlineViewComponents = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
        }
    }
    
    if layoutDict != nil {
        let layoutObjectParser = LayoutObjectParser()
        let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
        topHeadlineObject.layoutObjectDict = layoutObjectDict
    }
    
    return topHeadlineObject
}

