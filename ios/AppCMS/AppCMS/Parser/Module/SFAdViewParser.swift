//
//  SFAdViewParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 12/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import UIKit

class SFAdViewParser: NSObject {

    func parseAdViewModuleJson(adViewModuleDictionary: Dictionary<String, AnyObject>) -> SFAdViewObject
    {
        let adViewModuleObject = SFAdViewObject()
        
        adViewModuleObject.key = adViewModuleDictionary["key"] as? String
        adViewModuleObject.type = adViewModuleDictionary["type"] as? String
        
        let blockName:String? = adViewModuleDictionary["blockName"] as? String
        adViewModuleObject.blockName = blockName
        
        if blockName != nil {
            
            if PageUIBlocks.sharedInstance.blockComponents != nil {
                let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                
                if pageBlockComponentDict != nil {
                    
                    if pageBlockComponentDict?["layout"] != nil {
                        
                        adViewModuleObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                    }
                }
            }
        }
        
        if adViewModuleObject.layoutObjectDict.count == 0 {
            
            let layoutDict = adViewModuleDictionary["layout"] as? Dictionary<String, Any>
            if layoutDict != nil {
                
                let layoutObjectParser = LayoutObjectParser()
                let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
                adViewModuleObject.layoutObjectDict = layoutObjectDict
            }
        }
        
        return adViewModuleObject
    }
}
