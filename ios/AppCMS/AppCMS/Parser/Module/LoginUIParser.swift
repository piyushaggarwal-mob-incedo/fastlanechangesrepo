//
//  LoginViewParser.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 23/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class LoginUIParser: NSObject {
    
    func parseLoginModuleJson(loginModuleDictionary: Dictionary<String, AnyObject>) -> LoginObject
    {
        let loginModuleObject = LoginObject()
        
        loginModuleObject.moduleID = loginModuleDictionary["id"] as? String
        loginModuleObject.moduleType = loginModuleDictionary["view"] as? String
        
        let blockName:String? = loginModuleDictionary["blockName"] as? String
        
        if blockName != nil {
            
            if PageUIBlocks.sharedInstance.blockComponents != nil {
                let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                
                if pageBlockComponentDict != nil {
                    
                    if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                        
                        loginModuleObject.components = (pageBlockComponentDict?["components"] as? Array<AnyObject>)!
                    }
                    
                    if pageBlockComponentDict?["layout"] != nil {
                        
                        loginModuleObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                    }
                }
            }
        }
        
        if loginModuleObject.components.count == 0 {
            
            let componentArray = loginModuleDictionary["components"] as? Array<Dictionary<String, AnyObject>>
            
            if componentArray != nil {
                
                let componentsUIParser = ComponentUIParser()
                loginModuleObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
            }
        }
        
        if loginModuleObject.layoutObjectDict.count == 0 {
            
            let layoutObjectParser = LayoutObjectParser()
            loginModuleObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: loginModuleDictionary["layout"] as! Dictionary<String, Any>)
        }
        
        return loginModuleObject
    }
    
    
    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {
        
        var componentArray:Array<AnyObject> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == "AC Login Component" || typeOfModule == "AC Create Login Component" || typeOfModule == "AC SignUp Component" || typeOfModule == "AC SignUp 01"
            {
                let loginComponentUIParser = LoginComponentUIParser()
                let loginObject = loginComponentUIParser.parseLoginComponentJson(loginComponentDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(loginObject)
            }
            else if typeOfModule == "button"
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
            else if typeOfModule == "textfield"
            {
                let textFieldParser = SFTextFieldParser()
                let textFieldObject = textFieldParser.parseTextFieldJson(textViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(textFieldObject)
            }
            else if typeOfModule == "dropDown"
            {
                #if os(iOS)
                let dropDownParser = SFDropDownParser()
                let dropDownObject = dropDownParser.parseDropdDownJson(dropDownDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(dropDownObject)
                #endif
            }
        }
        
        return componentArray
    }
    
}
