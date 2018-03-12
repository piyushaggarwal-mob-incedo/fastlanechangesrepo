//
//  SFLabelParser.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit

class SFLabelParser: NSObject {

    func parseLabelJson(labelDictionary: Dictionary<String, AnyObject>) -> SFLabelObject
    {
        let labelObject = SFLabelObject()
        
        labelObject.alpha = labelDictionary["opacity"] as! Float?
        labelObject.type = labelDictionary["type"] as! String?
        labelObject.action = labelDictionary["action"] as! String?
        labelObject.backgroundColor = labelDictionary["backgroundColor"] as? String
        labelObject.selectedBackgroundColor = labelDictionary["backgroundSelectedColor"] as? String
        labelObject.textColor = labelDictionary["textColor"] as? String
        labelObject.borderWidth = labelDictionary["borderWidth"] as? Float
        labelObject.borderColor = labelDictionary["borderColor"] as? String
        labelObject.selectedTextColor = labelDictionary["selectedTextColor"] as? String
        labelObject.textFontSize = labelDictionary["textFontSize"] as? Float
        labelObject.cornerRadius = labelDictionary["cornerRadius"] as? Float
        labelObject.fontFamily = labelDictionary["fontFamily"] as? String
        labelObject.numberOfLines = labelDictionary["numberOfLines"] as? Int
        labelObject.textAlignment = labelDictionary["textAlignment"] as? String
        labelObject.letterSpacing = labelDictionary["letterSpacing"] as? Float
        labelObject.key = labelDictionary["key"] as? String
        labelObject.fontFamily = labelDictionary["fontFamily"] as? String
        labelObject.fontWeight = labelDictionary ["fontWeight"] as? String
        labelObject.text = labelDictionary["text"] as? String
        labelObject.lineHeight = labelDictionary["lineHeight"] as? Float
        labelObject.underline = labelDictionary["underlined"] as? Bool
        labelObject.hugsContent = labelDictionary["hugsContent"] as? Bool
        labelObject.backgroundColorAlpha = labelDictionary["backgroundColorAlpha"] as? Float
        labelObject.textStyle = labelDictionary["textStyle"] as? String
        labelObject.prefixText = labelDictionary["prefixText"] as? String
        
        if labelObject.underline != nil &&  labelObject.underline!{
            labelObject.underlineColor = labelDictionary["underlineColor"] as? String
            labelObject.underlineWidth = labelDictionary["underlineWidth"] as? Float
        }
        
        let layoutDict = labelDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            labelObject.layoutObjectDict = layoutObjectDict
        }

        return labelObject
    }
}
