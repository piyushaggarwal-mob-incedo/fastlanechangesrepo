//
//  SFSubMenuViewParser.swift
//  AppCMS
//
//  Created by Rajni Pathak on 07/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFSubNavigationViewParser: NSObject {
    func parseLayoutJson(viewModuleDictionary: Dictionary<String, AnyObject>) -> SFSubNavigationViewObject {
        let associatedViewObject = SFSubNavigationViewObject()
        
        associatedViewObject.moduleID = viewModuleDictionary["id"] as? String
        associatedViewObject.moduleType = viewModuleDictionary["view"] as? String
        associatedViewObject.moduleTitle = viewModuleDictionary["title"] as? String

        
        var componentArray : Array<Dictionary<String, AnyObject>>?
        let layoutObjectParser = LayoutObjectParser()
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            let filePath = Bundle.main.resourcePath?.appending("/SubMenu_AppleTV.json")
            
            if FileManager.default.fileExists(atPath: filePath!){
                let jsonData:Data = FileManager.default.contents(atPath: filePath!)!
                let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, AnyObject>
                let layoutDict = responseJson["layout"] as? Dictionary<String, Any>
                associatedViewObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
                
                componentArray = responseJson["components"] as? Array<Dictionary<String, AnyObject>>
                if componentArray != nil {
                    let componentsUIParser = ComponentUIParser()
                    associatedViewObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
                }
            }
        } else {
            if DEBUGMODE {
                let filePath = Bundle.main.resourcePath?.appending("/MenuSportsView_AppleTV.json")
                
                if FileManager.default.fileExists(atPath: filePath!){
                    let jsonData:Data = FileManager.default.contents(atPath: filePath!)!
                    let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, AnyObject>
                    let layoutDict = responseJson["layout"] as? Dictionary<String, Any>
                    associatedViewObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
                    
                    componentArray = responseJson["components"] as? Array<Dictionary<String, AnyObject>>
                    if componentArray != nil {
                        let componentsUIParser = ComponentUIParser()
                        associatedViewObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
                    }
                }
            } else {
                componentArray = viewModuleDictionary["components"] as? Array<Dictionary<String, AnyObject>>
                
                if componentArray != nil {
                    let componentsUIParser = ComponentUIParser()
                    associatedViewObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
                }
                
                associatedViewObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: viewModuleDictionary["layout"] as! Dictionary<String, Any>)
            }
        }
        return associatedViewObject
    }
}
