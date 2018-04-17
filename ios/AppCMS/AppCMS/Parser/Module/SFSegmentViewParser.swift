//
//  SFSegmentViewParser.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 26/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class SFSegmentViewParser: NSObject {

    func parseSegmentViewJson(segmentViewDictionary: Dictionary<String, AnyObject>) -> SFSegmentObject
    {
        let segmentObject = SFSegmentObject()
        
        segmentObject.type = segmentViewDictionary["type"] as! String?
        let componentArray = segmentViewDictionary["components"] as? Array<Dictionary<String, AnyObject>>
        
        if componentArray != nil {
            
            let componentsUIParser = ComponentUIParser()
            segmentObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
        }

        segmentObject.selectedIndex = segmentViewDictionary["selectedIndex"] as? Int
        let layoutDict = segmentViewDictionary["layout"] as? Dictionary<String, Any>
        segmentObject.value = segmentViewDictionary["value"] as? String
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            segmentObject.layoutObjectDict = layoutObjectDict
        }
        
        return segmentObject
    }
    
    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {
        
        var componentArray:Array<AnyObject> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == "label"
            {
                let labelParser = SFLabelParser()
                let labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(labelObject)
            }
        }
        
        return componentArray
    }
}
