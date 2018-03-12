//
//  SFVerticalArticleViewParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 25/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import UIKit

class SFVerticalArticleViewParser: NSObject {

    //MARK: Method to parse vertical article view json
    func parseVerticalArticleViewJson(verticalArticleViewDictionary: Dictionary<String, AnyObject>) -> SFVerticalArticleViewObject {
        
        var verticalArticleViewObject = SFVerticalArticleViewObject()
        
        verticalArticleViewObject.type = verticalArticleViewDictionary["type"] as? String
        verticalArticleViewObject.key = verticalArticleViewDictionary["key"] as? String
        
        if verticalArticleViewObject.key == nil {
            
            verticalArticleViewObject.key = verticalArticleViewDictionary["type"] as? String
        }
        
        verticalArticleViewObject.moduleId = verticalArticleViewDictionary["id"] as? String
        let blockName:String? = verticalArticleViewDictionary["blockName"] as? String
        verticalArticleViewObject.blockName = blockName
        
        if blockName != nil {
            
            verticalArticleViewObject = updateVerticalViewObjectWithComponentsAndLayout(blockName: blockName!, verticalArticleViewObject: verticalArticleViewObject)
        }
        
        verticalArticleViewObject = parseLayoutAndComponents(verticalArticleViewDictionary: verticalArticleViewDictionary, verticalArticleViewObject: verticalArticleViewObject)
        
        if let settingsDict = verticalArticleViewDictionary["settings"] as? Dictionary<String, AnyObject> {
            
            verticalArticleViewObject = parseVerticalArticleViewSettings(settingsDictionary: settingsDict, verticalArticleViewObject: verticalArticleViewObject)
        }
        
        return verticalArticleViewObject
    }
    
    
    //MARK: Method to fetch layout and components for vertical article view
    private func updateVerticalViewObjectWithComponentsAndLayout(blockName:String, verticalArticleViewObject:SFVerticalArticleViewObject) -> SFVerticalArticleViewObject {
        
        if PageUIBlocks.sharedInstance.blockComponents != nil {
            let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName] as? Dictionary<String, Any>
            
            if pageBlockComponentDict != nil {
                
                if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                    
                    verticalArticleViewObject.components = pageBlockComponentDict?["components"] as! Array<AnyObject>
                }
                
                if pageBlockComponentDict?["layout"] != nil {
                    
                    verticalArticleViewObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                }
            }
        }
        
        return verticalArticleViewObject
    }
    
    
    //MARK: Method to parse layout and components for vertical article view
    private func parseLayoutAndComponents(verticalArticleViewDictionary: Dictionary<String, AnyObject>, verticalArticleViewObject: SFVerticalArticleViewObject) -> SFVerticalArticleViewObject {
        
        var layoutDict : Dictionary<String, Any>?
        var componentArray : Array<Dictionary<String, AnyObject>>?
        
        if verticalArticleViewObject.layoutObjectDict.count == 0 {
            
            layoutDict = verticalArticleViewDictionary["layout"] as? Dictionary<String, Any>
        }
        
        if verticalArticleViewObject.components.count == 0 {
            
            componentArray = verticalArticleViewDictionary["components"] as? Array<Dictionary<String, AnyObject>>
            
            if componentArray != nil {
                
                let componentsUIParser = ComponentUIParser()
                verticalArticleViewObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
            }
        }
        
        if layoutDict != nil {
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            verticalArticleViewObject.layoutObjectDict = layoutObjectDict
        }
        
        return verticalArticleViewObject
    }
    
    //MARK: Method to parse vertical article view settings
    private func parseVerticalArticleViewSettings(settingsDictionary:Dictionary<String, AnyObject>, verticalArticleViewObject:SFVerticalArticleViewObject) -> SFVerticalArticleViewObject {
        
        verticalArticleViewObject.settings = SFVerticalArticleViewSettings(settingsDict: settingsDictionary)
        return verticalArticleViewObject
    }
}
