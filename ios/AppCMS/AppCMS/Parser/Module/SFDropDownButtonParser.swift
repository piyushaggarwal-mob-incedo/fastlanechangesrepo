//
//  SFDropDownButtonParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 28/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFDropDownButtonParser: NSObject {

    func parseButtonJson(buttonDictionary: Dictionary<String, AnyObject>) -> SFDropDownButtonObject
    {
        let dropDownButtonObject = SFDropDownButtonObject()
        
        dropDownButtonObject.type = buttonDictionary["type"] as? String
        dropDownButtonObject.text = buttonDictionary["text"] as? String
        dropDownButtonObject.action = buttonDictionary["action"] as? String
        dropDownButtonObject.backgroundColor = buttonDictionary["backgroundColor"] as? String
        dropDownButtonObject.selectedBackgroundColor = buttonDictionary["backgroundSelectedColor"] as? String
        dropDownButtonObject.textColor = buttonDictionary["textColor"] as? String
        dropDownButtonObject.borderWidth = buttonDictionary["borderWidth"] as? Float
        dropDownButtonObject.borderColor = buttonDictionary["borderColor"] as? String
        dropDownButtonObject.selectedTextColor = buttonDictionary["selectedTextColor"] as? String
        dropDownButtonObject.textFontSize = buttonDictionary["textFontSize"] as? Float
        dropDownButtonObject.fontFamily = buttonDictionary["fontFamily"] as? String
        dropDownButtonObject.fontWeight = buttonDictionary ["fontWeight"] as? String
        dropDownButtonObject.key = buttonDictionary["key"] as? String
        dropDownButtonObject.imageName = buttonDictionary["buttonImage"] as? String
        dropDownButtonObject.textAlignment = buttonDictionary["textAlignment"] as? String
        dropDownButtonObject.isVerticalDropDown = buttonDictionary["isVerticalDropDown"] as? Bool
        
        let layoutDict = buttonDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            dropDownButtonObject.layoutObjectDict = layoutObjectDict
        }
        
        return dropDownButtonObject
    }
}
