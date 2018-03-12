//
//  SFTimerLoaderViewParser.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 05/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class SFTimerLoaderViewParser {
    
    func parserLayoutJson(viewModuleDictionary: Dictionary<String, AnyObject>) -> SFTimerLoaderViewObject {
        let associatedViewObject = SFTimerLoaderViewObject()
        
        associatedViewObject.moduleID = viewModuleDictionary["id"] as? String
        associatedViewObject.moduleType = viewModuleDictionary["type"] as? String
        associatedViewObject.moduleTitle = viewModuleDictionary["title"] as? String
        associatedViewObject.fontFamily = viewModuleDictionary["fontFamily"] as? String
        associatedViewObject.alpha = viewModuleDictionary["opacity"] as? Float
        associatedViewObject.showsCountDown = viewModuleDictionary["showsCountdown"] as? Bool
        associatedViewObject.textAlignment = viewModuleDictionary["textAlignment"] as? String
        associatedViewObject.loaderTimeDuration = viewModuleDictionary["timerValue"] as? Int
        associatedViewObject.fontSize = viewModuleDictionary["fontSize"] as? Float
        associatedViewObject.fontWeight = viewModuleDictionary["fontWeight"] as? String
        
        var layoutDict : Dictionary<String, Any>?
        layoutDict = viewModuleDictionary["layout"] as? Dictionary<String, Any>
        
        if layoutDict != nil {
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            associatedViewObject.layoutObjectDict = layoutObjectDict
        }
        
        return associatedViewObject
    }
}
