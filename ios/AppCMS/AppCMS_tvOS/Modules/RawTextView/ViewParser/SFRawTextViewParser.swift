//
//  SFRawTextViewParser.swift
//  Monumental_tvOS
//
//  Created by Rajni Pathak on 19/12/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFRawTextViewParser: NSObject {
    func parseLayoutJson(viewModuleDictionary: Dictionary<String, AnyObject>) -> SFRawTextViewObject {
        let associatedViewObject = SFRawTextViewObject()
        
        associatedViewObject.moduleID = viewModuleDictionary["id"] as? String
        associatedViewObject.moduleType = viewModuleDictionary["view"] as? String
        associatedViewObject.moduleTitle = viewModuleDictionary["title"] as? String
        
        
        var componentArray : Array<Dictionary<String, AnyObject>>?
        let layoutObjectParser = LayoutObjectParser()
            let filePath = Bundle.main.resourcePath?.appending("/RawTextView_AppleTV.json")
            
            if FileManager.default.fileExists(atPath: filePath!){
                let jsonData:Data = FileManager.default.contents(atPath: filePath!)!
                let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, AnyObject>
                let layoutDict = responseJson["layout"] as? Dictionary<String, Any>
                associatedViewObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
                
                componentArray = responseJson["components"] as? Array<Dictionary<String, AnyObject>>
                if componentArray != nil {
                    let componentsUIParser = ComponentUIParser()
                    associatedViewObject.components = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
                }
            }
        return associatedViewObject
    }
}
