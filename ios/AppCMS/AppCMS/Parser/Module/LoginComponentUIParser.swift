//
//  LoginComponentUIParser.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 23/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class LoginComponentUIParser: NSObject {

    func parseLoginComponentJson(loginComponentDictionary: Dictionary<String, AnyObject>) -> LoginComponent
    {
        let loginComponentObject = LoginComponent()
        
        loginComponentObject.type = loginComponentDictionary["type"] as? String
        
        let componentArray = loginComponentDictionary["components"] as? Array<Dictionary<String, AnyObject>>
        
        if componentArray != nil {
            
            let componentsUIParser = ComponentUIParser()
            loginComponentObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
        }
        
        let layoutObjectParser = LayoutObjectParser()
        loginComponentObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: loginComponentDictionary["layout"] as! Dictionary<String, Any>)
        
        return loginComponentObject
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
            else if typeOfModule == "textfield"
            {
                let textFieldParser = SFTextFieldParser()
                let textFieldObject = textFieldParser.parseTextFieldJson(textViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(textFieldObject)
            }
            else if typeOfModule == "separatorView"
            {
                let separatorViewParser = SFSeparatorViewParser()
                let separatorViewObject = separatorViewParser.parseSeparatorViewJson(separatorViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(separatorViewObject)
            }
            else if typeOfModule == "AC SegmentedView"
            {
                let segmentViewParser = SFSegmentViewParser()
                let segmentViewobject = segmentViewParser.parseSegmentViewJson(segmentViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(segmentViewobject)
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
