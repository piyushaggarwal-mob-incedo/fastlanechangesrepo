//
//  SFButtonParser.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit

class SFButtonParser: NSObject {

    func parseButtonJson(buttonDictionary: Dictionary<String, AnyObject>) -> SFButtonObject
    {
        let buttonObject = SFButtonObject()
        
        buttonObject.type = buttonDictionary["type"] as? String
        buttonObject.text = buttonDictionary["text"] as? String
        buttonObject.action = buttonDictionary["action"] as? String
        buttonObject.backgroundColor = buttonDictionary["backgroundColor"] as? String
        buttonObject.selectedBackgroundColor = buttonDictionary["backgroundSelectedColor"] as? String
        buttonObject.textColor = buttonDictionary["textColor"] as? String
        buttonObject.borderWidth = buttonDictionary["borderWidth"] as? Float
        buttonObject.borderColor = buttonDictionary["borderColor"] as? String
        buttonObject.selectedTextColor = buttonDictionary["selectedTextColor"] as? String
        buttonObject.textFontSize = buttonDictionary["textFontSize"] as? Float
        buttonObject.cornerRadius = buttonDictionary["cornerRadius"] as? Float
        buttonObject.isVisibleForPhone = buttonDictionary["isVisibleForPhone"] as? Bool
        buttonObject.isVisibleForTablet = buttonDictionary["isVisibleForTablet"] as? Bool
        buttonObject.fontFamily = buttonDictionary["fontFamily"] as? String
        buttonObject.fontWeight = buttonDictionary ["fontWeight"] as? String
        buttonObject.key = buttonDictionary["key"] as? String
        buttonObject.selectedStateText = buttonDictionary["selectedStateText"] as? String
        buttonObject.imageName = buttonDictionary["imageName"] as? String
        
        
        let layoutDict = buttonDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            buttonObject.layoutObjectDict = layoutObjectDict
        }
        

        return buttonObject
    }
}   

