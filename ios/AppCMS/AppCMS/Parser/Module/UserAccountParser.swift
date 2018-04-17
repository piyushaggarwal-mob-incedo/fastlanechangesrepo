//
//  UserAccountParser.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 05/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class UserAccountParser: NSObject {
    
    func parseUserComponentJson(userComponentDictionary: Dictionary<String, AnyObject>) -> UserAccountModuleObject
    {
        let userAccountModuleObject = UserAccountModuleObject()
        
        userAccountModuleObject.moduleType = userComponentDictionary["type"] as? String
        userAccountModuleObject.moduleID = userComponentDictionary["id"] as? String
        
        let blockName:String? = userComponentDictionary["blockName"] as? String
        
        if blockName != nil {
            
            if PageUIBlocks.sharedInstance.blockComponents != nil {
                let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                
                if pageBlockComponentDict != nil {
                    
                    if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                        
                        userAccountModuleObject.components = (pageBlockComponentDict?["components"] as? Array<AnyObject>)!
                    }
                    
                    if pageBlockComponentDict?["layout"] != nil {
                        
                        userAccountModuleObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                    }
                }
            }
        }
        
        if userAccountModuleObject.components.count == 0 {
            
            let componentArray = userComponentDictionary["components"] as? Array<Dictionary<String, AnyObject>>
            
            if componentArray != nil {
                
                let componentsUIParser = ComponentUIParser()
                userAccountModuleObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
            }
        }
        
        if userAccountModuleObject.layoutObjectDict.count == 0 {
            
            let layoutObjectParser = LayoutObjectParser()
            userAccountModuleObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: userComponentDictionary["layout"] as! Dictionary<String, Any>)
        }
        
        return userAccountModuleObject
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
            else if typeOfModule == "AC Settings Account 01"
            {
                let componentKey: String = moduleDictionary["key"] as? String ?? ""
                if componentKey == "subscriptionInfo"
                {
                    if AppConfiguration.sharedAppConfiguration.serviceType == .SVOD
                    {
                        let userDetailCompParser = UserComponentDetailParser()
                        let userDetailCompObject = userDetailCompParser.parseUserDetailComponentJson(userComponentDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                        componentArray.append(userDetailCompObject)
                    }
                    else
                    {
                        continue
                    }
                }
                else if componentKey == "download"
                {
                    if AppConfiguration.sharedAppConfiguration.isDownloadEnabled != nil 
                    {
                        if AppConfiguration.sharedAppConfiguration.isDownloadEnabled == true {
                            
                            let userDetailCompParser = UserComponentDetailParser()
                            let userDetailCompObject = userDetailCompParser.parseUserDetailComponentJson(userComponentDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                            componentArray.append(userDetailCompObject)
                        }
                        else {
                            
                            continue
                        }
                    }
                    else
                    {
                        continue
                    }
                }
                else
                {
                    let userDetailCompParser = UserComponentDetailParser()
                    let userDetailCompObject = userDetailCompParser.parseUserDetailComponentJson(userComponentDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    componentArray.append(userDetailCompObject)
                }
            }
        }
        
        return componentArray
    }

}
