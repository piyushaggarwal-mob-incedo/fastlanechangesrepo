//
//  SFTextViewParser.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit

class SFTextViewParser: NSObject {

    func parseTextViewJson(textViewDictionary: Dictionary<String, AnyObject>) -> SFTextViewObject
    {
        let textViewObject = SFTextViewObject()
        
        textViewObject.type = textViewDictionary["type"] as! String?
        textViewObject.action = textViewDictionary["action"] as! String?
        textViewObject.fontSize = textViewDictionary["fontSize"] as? Float
        textViewObject.textColor = textViewDictionary["textColor"] as? String
        textViewObject.text = textViewDictionary["text"] as? String
        textViewObject.textAlignment = textViewDictionary["textAlignment"] as? String
        textViewObject.fontFamily = textViewDictionary["fontFamily"] as? String
        textViewObject.fontWeight = textViewDictionary ["fontWeight"] as? String
        
        let layoutDict = textViewDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            textViewObject.layoutObjectDict = layoutObjectDict
        }

        return textViewObject
    }
}
