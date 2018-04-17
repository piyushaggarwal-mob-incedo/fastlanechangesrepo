//
//  SFToggleParser.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 01/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFToggleParser: NSObject {

    func parseToggleJson(toggleDictionary: Dictionary<String, AnyObject>) -> SFToggleObject
    {
        let toggleObject = SFToggleObject()
        toggleObject.key = toggleDictionary["key"] as? String
        
        let layoutDict = toggleDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            toggleObject.layoutObjectDict = layoutObjectDict
        }
         return toggleObject
    }
}
