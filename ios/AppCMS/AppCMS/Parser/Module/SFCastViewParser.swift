
//
//  SFCastViewParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 26/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFCastViewParser: NSObject {

    func parseCastViewJson(castViewDictionary: Dictionary<String, AnyObject>) -> SFCastViewObject
    {
        let castViewObject = SFCastViewObject()
        
        castViewObject.type = castViewDictionary["type"] as? String
        castViewObject.textColor = castViewDictionary["textColor"] as? String
        castViewObject.fontFamilyKey = castViewDictionary["fontFamilyKey"] as? String
        castViewObject.fontFamilyValue = castViewDictionary["fontFamilyValue"] as? String
        
        let layoutDict = castViewDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            castViewObject.layoutObjectDict = layoutObjectDict
        }

        return castViewObject
    }
}
