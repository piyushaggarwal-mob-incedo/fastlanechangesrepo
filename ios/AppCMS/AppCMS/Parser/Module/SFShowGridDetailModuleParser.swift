//
//  SFShowGridDetailModuleParser.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 20/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFShowGridDetailModuleParser: NSObject {
    
    func parseShowGridsModuleJson(showGridModuleDictionary: Dictionary<String, AnyObject>) -> SFShowGridModule
    {
        let showGridModuleObject = SFShowGridModule()
        
        showGridModuleObject.moduleID = showGridModuleDictionary["id"] as? String
        showGridModuleObject.moduleType = showGridModuleDictionary["view"] as? String
        showGridModuleObject.moduleTitle = showGridModuleDictionary["title"] as? String
        
        let blockName:String? = showGridModuleDictionary["blockName"] as? String
        
        if blockName != nil {
            
            if PageUIBlocks.sharedInstance.blockComponents != nil {
                let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                
                if pageBlockComponentDict != nil {
                    
                    if pageBlockComponentDict?["components"] != nil {
                        
                        showGridModuleObject.showDetailGridModuleComponents = pageBlockComponentDict?["components"] as? Array<AnyObject>
                    }
                    
                    if pageBlockComponentDict?["layout"] != nil {
                        
                        showGridModuleObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                    }
                }
            }
        }
        
        if showGridModuleObject.showDetailGridModuleComponents == nil || showGridModuleObject.showDetailGridModuleComponents?.count == 0 {
            
            let componentArray = showGridModuleDictionary["components"] as? Array<Dictionary<String, AnyObject>>
            
            if componentArray != nil {
                
                let componentsUIParser = ComponentUIParser()
                showGridModuleObject.showDetailGridModuleComponents = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
            }
        }
        
        if showGridModuleObject.layoutObjectDict.count == 0 {
            
            let layoutObjectParser = LayoutObjectParser()
            showGridModuleObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: showGridModuleDictionary["layout"] as! Dictionary<String, Any>)
        }
        return showGridModuleObject
    }
    
    
    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {
        
        var componentArray:Array<AnyObject> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == "AC Episode Module"
            {
                let trayParser = SFTrayParser()
                let trayObject = trayParser.parseTrayJson(trayDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if trayObject.layoutObjectDict.isEmpty == false {
                    componentArray.append(trayObject)
                }
            }
            else if typeOfModule == "AC SegmentedView"
            {
                let segmentViewParser = SFSegmentViewParser()
                let segmentViewobject = segmentViewParser.parseSegmentViewJson(segmentViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(segmentViewobject)
            }
        }
        
        return componentArray
    }
}
