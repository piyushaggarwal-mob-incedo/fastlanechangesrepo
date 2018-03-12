//
//  UserComponentDetailParser.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 05/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class UserComponentDetailParser: NSObject {
   
    func parseUserDetailComponentJson(userComponentDictionary: Dictionary<String, AnyObject>) -> UserAccountComponentObject
    {
        let userAccountComponentObject = UserAccountComponentObject()
        
        userAccountComponentObject.type = userComponentDictionary["type"] as? String
        userAccountComponentObject.view = userComponentDictionary["view"] as? String
        userAccountComponentObject.key = userComponentDictionary["key"] as? String ?? ""
        
        let componentArray = userComponentDictionary["components"] as? Array<Dictionary<String, AnyObject>>
        
        if componentArray != nil {
            
            let componentsUIParser = ComponentUIParser()
            userAccountComponentObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
        }
        
        let layoutObjectParser = LayoutObjectParser()
        userAccountComponentObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: userComponentDictionary["layout"] as! Dictionary<String, Any>)
        
        return userAccountComponentObject
    }
    
    
    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {
        
        var componentArray:Array<AnyObject> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == "button"
            {
                let buttonParser = SFButtonParser()
                let buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(buttonObject)
            }
            else if typeOfModule == "label"
            {
                let labelParser = SFLabelParser()
                let labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(labelObject)
            }
            else if typeOfModule == "separatorView"
            {
                let separatorViewParser = SFSeparatorViewParser()
                let separatorViewObject = separatorViewParser.parseSeparatorViewJson(separatorViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(separatorViewObject)
            }
            else if typeOfModule == "toggle"
            {
                let toggleViewParser = SFToggleParser()
                let toggleObject = toggleViewParser.parseToggleJson(toggleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(toggleObject)
            }
        }
        
        return componentArray
    }

}
