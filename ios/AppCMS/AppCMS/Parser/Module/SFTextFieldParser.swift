//
//  SFTextFieldParser.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 23/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class SFTextFieldParser: NSObject {

    func parseTextFieldJson(textViewDictionary: Dictionary<String, AnyObject>) -> SFTextFieldObject
    {
        let textFieldObject = SFTextFieldObject()
        
        #if os(iOS)
            textFieldObject.type = textViewDictionary["type"] as! String?
        #endif
        textFieldObject.fontSize = textViewDictionary["fontSize"] as? Float
        textFieldObject.textColor = textViewDictionary["textColor"] as? String
        textFieldObject.text = textViewDictionary["text"] as? String
        textFieldObject.textAlignment = textViewDictionary["textAlignment"] as? String
        textFieldObject.fontFamily = textViewDictionary["fontFamily"] as? String
        textFieldObject.fontWeight = textViewDictionary ["fontWeight"] as? String
        textFieldObject.backgroundColor = textViewDictionary["backgroundColor"] as? String
        textFieldObject.isProtected = textViewDictionary["protected"] as? Bool
        textFieldObject.cornerRadius = textViewDictionary["cornerRadius"] as? Float
        textFieldObject.key = textViewDictionary["key"] as? String
        let layoutDict = textViewDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            textFieldObject.layoutObjectDict = layoutObjectDict
        }
        
        return textFieldObject
    }
}
