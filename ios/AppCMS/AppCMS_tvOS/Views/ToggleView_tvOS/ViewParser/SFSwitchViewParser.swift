//
//  ToggleViewViewParser.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 08/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFSwitchViewParser {
    
    /// Parses Layout Json for Module.
    ///
    /// - Parameter viewModuleDictionary: module view disctionary.
    /// - Returns: SFSwitchViewObject
    func parserLayoutJson(viewModuleDictionary: Dictionary<String, AnyObject>) -> SFSwitchViewObject {
        let associatedViewObject = SFSwitchViewObject()
        
        associatedViewObject.moduleID = viewModuleDictionary["id"] as? String
        associatedViewObject.moduleType = viewModuleDictionary["type"] as? String
        associatedViewObject.moduleTitle = viewModuleDictionary["title"] as? String
        associatedViewObject.key = viewModuleDictionary["key"] as? String
        associatedViewObject.textColor = viewModuleDictionary["textColor"] as? String
        associatedViewObject.letterSpacing = viewModuleDictionary["letterSpacing"] as? Float
        
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
