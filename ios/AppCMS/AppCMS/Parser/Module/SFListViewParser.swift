//
//  SFListViewParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 13/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFListViewParser: NSObject {

    func parseListViewJson(listViewDictionary: Dictionary<String, AnyObject>) -> SFListViewObject {
        
        let listViewObject = SFListViewObject()
        
        listViewObject.type = listViewDictionary["type"] as? String
        listViewObject.apiURL = listViewDictionary["apiURL"] as? String
        listViewObject.listViewId = listViewDictionary["id"] as? String
        listViewObject.type = listViewDictionary["type"] as? String
        listViewObject.viewName = listViewDictionary["view"] as? String
        
        var layoutDict : Dictionary<String, Any>?
        var componentArray : Array<Dictionary<String, AnyObject>>?
        
        let blockName:String? = listViewDictionary["blockName"] as? String
        listViewObject.blockName = blockName
        
        if blockName != nil {
            
            if PageUIBlocks.sharedInstance.blockComponents != nil {
                let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                
                if pageBlockComponentDict != nil {
                    
                    if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                        
                        listViewObject.listViewComponents = pageBlockComponentDict?["components"] as! Array<AnyObject>
                    }
                    
                    if pageBlockComponentDict?["layout"] != nil {
                        
                        listViewObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                    }
                }
            }
        }
        
        if listViewObject.layoutObjectDict.count == 0 {
            
            layoutDict = listViewDictionary["layout"] as? Dictionary<String, Any>
        }
        
        if listViewObject.listViewComponents.count == 0 {
            
            componentArray = listViewDictionary["components"] as? Array<Dictionary<String, AnyObject>>
            
            if componentArray != nil {
                
                let componentsUIParser = ComponentUIParser()
                listViewObject.listViewComponents = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
            }
        }
        
        if layoutDict != nil {
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            listViewObject.layoutObjectDict = layoutObjectDict
        }
        return listViewObject
    }
}
