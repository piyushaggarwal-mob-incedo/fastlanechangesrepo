//
//  SFSeparatorViewParser.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 17/03/17.
//
//

import UIKit

class SFSeparatorViewParser: NSObject {

    func parseSeparatorViewJson(separatorViewDictionary: Dictionary<String, AnyObject>) -> SFSeparatorViewObject
    {
        let separatorViewObject = SFSeparatorViewObject()
        
        separatorViewObject.backgroundColor = separatorViewDictionary["backgroundColor"] as? String
        separatorViewObject.type = separatorViewDictionary["type"] as? String
        separatorViewObject.opacity = separatorViewDictionary["opacity"] as? Float
        separatorViewObject.key = separatorViewDictionary["key"] as? String
        let layoutObjectParser = LayoutObjectParser()
        let layoutDict = separatorViewDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            separatorViewObject.layoutObjectDict = layoutObjectDict
        }

        return separatorViewObject
    }
}
