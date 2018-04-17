//
//  SFPageControlParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 25/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFPageControlParser: NSObject {

    func parsePageControlJson(pageControlDictionary: Dictionary<String, AnyObject>) -> SFPageControlObject
    {
        let pageControlObject = SFPageControlObject()
        
        pageControlObject.type = pageControlDictionary["type"] as? String
        pageControlObject.selectorColor = pageControlDictionary["selectedColor"] as? String
        pageControlObject.unSelectedColor = pageControlDictionary["unSelectedColor"] as? String
                
        let layoutDict = pageControlDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            pageControlObject.layoutObjectDict = layoutObjectDict
        }

        return pageControlObject
    }

}
