//
//  SFArticleDetailModuleParser.swift
//  AppCMS
//
//  Created by  Diksha Goyal on 17/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import Foundation

class SFArticleDetailModuleParser: NSObject {
    
    func parseArticleDetailJson(articleDetailDictionary: Dictionary<String, AnyObject>) -> SFArticleDetailObject
    {
        let articleDetailObject = SFArticleDetailObject()
        
        articleDetailObject.moduleID = articleDetailDictionary["id"] as? String
        articleDetailObject.moduleType = articleDetailDictionary["view"] as? String
        articleDetailObject.backgroundColor = articleDetailDictionary["backgroundColor"] as? String
        articleDetailObject.viewAlpha=articleDetailDictionary["alpha"] as? CGFloat
        
        let blockName:String? = articleDetailDictionary["blockName"] as? String
        if blockName != nil {
            if PageUIBlocks.sharedInstance.blockComponents != nil {
                let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                
                if pageBlockComponentDict != nil {
                    
                    if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                        
                        articleDetailObject.components = (pageBlockComponentDict?["components"] as? Array<AnyObject>)!
                    }
                    
                    if pageBlockComponentDict?["layout"] != nil {
                        
                        articleDetailObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                    }
                }
            }
        }
        
        if articleDetailObject.components.count == 0 {
            
            let componentArray = articleDetailDictionary["components"] as? Array<Dictionary<String, AnyObject>>
            
            if componentArray != nil {
                
                let componentsUIParser = ComponentUIParser()
                articleDetailObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
            }
        }
        
        if articleDetailObject.layoutObjectDict.count == 0 {
            
            let layoutObjectParser = LayoutObjectParser()
            articleDetailObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: articleDetailDictionary["layout"] as! Dictionary<String, Any>)
        }
        
        return articleDetailObject
        
    }
    
   private func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {
        
        var componentArray:Array<AnyObject> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == "webView"
            {
                let webViewParser = SFWebViewParser()
                let webViewObject = webViewParser.parseWebViewJson(webViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(webViewObject)
            }
        }
        return componentArray
    }
    
}
