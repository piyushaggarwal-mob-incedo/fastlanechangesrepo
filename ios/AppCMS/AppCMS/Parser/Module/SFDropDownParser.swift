//
//  SFDropDownParser.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 30/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFDropDownParser: NSObject
{
    func parseDropdDownJson(dropDownDictionary: Dictionary<String, AnyObject>) -> SFDropDownObject
    {
        let dropDownObject = SFDropDownObject()
        
        #if os(iOS)
            dropDownObject.type = dropDownDictionary["type"] as! String?
            dropDownObject.action = dropDownDictionary["action"] as! String?
        #endif
        dropDownObject.fontSize = dropDownDictionary["fontSize"] as? Float
        dropDownObject.textColor = dropDownDictionary["textColor"] as? String
        dropDownObject.text = dropDownDictionary["text"] as? String
        dropDownObject.textAlignment = dropDownDictionary["textAlignment"] as? String
        dropDownObject.fontFamily = dropDownDictionary["fontFamily"] as? String
        dropDownObject.fontWeight = dropDownDictionary ["fontWeight"] as? String
        dropDownObject.backgroundColor = dropDownDictionary["backgroundColor"] as? String
        dropDownObject.isProtected = dropDownDictionary["protected"] as? Bool
        dropDownObject.cornerRadius = dropDownDictionary["cornerRadius"] as? Float
        dropDownObject.key = dropDownDictionary["key"] as? String
        let layoutDict = dropDownDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            dropDownObject.layoutObjectDict = layoutObjectDict
        }
        
        return dropDownObject
    }
}
