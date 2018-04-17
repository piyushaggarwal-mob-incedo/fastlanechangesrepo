//
//  PageUIBlocks.swift
//  AppCMS
//
//  Created by Gaurav Vig on 03/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class PageUIBlocks: NSObject {

    var blockComponents:Dictionary<String, Any>?
    
    //MARK: Method to create singeleton class object
    static let sharedInstance:PageUIBlocks = {
        
        let instance = PageUIBlocks()
        
        return instance
    }()
    
    func parseBlockComponents(blockDict:Dictionary<String, Any>) {
        
        blockComponents = [:]
        
        for (dictKeyName, dictValue) in blockDict {
            
            if (dictValue as? Dictionary<String, Any>) != nil {
                
                var localBlockDict:Dictionary<String, Any> = [:]
                let layoutDict:Dictionary<String, Any>? = (dictValue as! Dictionary<String, Any>)["layout"] as? Dictionary<String, Any>
                
                if layoutDict != nil {
                    
                    let layoutObjectParser = LayoutObjectParser()
                    localBlockDict["layout"] = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
                }
                
                let componentArray = (dictValue as! Dictionary<String, Any>)["components"] as? Array<Dictionary<String, AnyObject>>
                
                if componentArray != nil {
                    
                    let componentsUIParser = ComponentUIParser()
                    localBlockDict["components"] = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
                }
                
                blockComponents?["\(dictKeyName)"] = localBlockDict
            }
        }
    }
}
