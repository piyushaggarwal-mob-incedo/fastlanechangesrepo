//
//  SFDownloadQualityParser.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/24/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFDownloadQualityParser: NSObject {

    //MARK: Method to create singeleton class object
    static let sharedInstance:SFDownloadQualityParser = {

        let instance = SFDownloadQualityParser()

        return instance
    }()

    func parseDownloadQualityModuleJson(downloadQualityModuleDictionary: Dictionary<String, AnyObject>) -> SFDownloadQualityObject
    {
        let downloadQualityModuleObject = SFDownloadQualityObject()

        downloadQualityModuleObject.moduleID = downloadQualityModuleDictionary["id"] as? String
        downloadQualityModuleObject.moduleType = downloadQualityModuleDictionary["view"] as? String
        downloadQualityModuleObject.backgroundColor = downloadQualityModuleDictionary["backgroundColor"] as? String
        downloadQualityModuleObject.viewAlpha=downloadQualityModuleDictionary["alpha"] as? CGFloat

        let blockName:String? = downloadQualityModuleDictionary["blockName"] as? String
        
        if blockName != nil {
            
            if PageUIBlocks.sharedInstance.blockComponents != nil {
                let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                
                if pageBlockComponentDict != nil {
                    
                    if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                        
                        downloadQualityModuleObject.components = (pageBlockComponentDict?["components"] as? Array<AnyObject>)!
                    }
                    
                    if pageBlockComponentDict?["layout"] != nil {
                        
                        downloadQualityModuleObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                    }
                }
            }
        }
        
        if downloadQualityModuleObject.components.count == 0 {
            
            let componentArray = downloadQualityModuleDictionary["components"] as? Array<Dictionary<String, AnyObject>>
            
            if componentArray != nil {
                downloadQualityModuleObject.components = componentConfigArray(componentsArray: componentArray!)
            }
        }
        
        if downloadQualityModuleObject.layoutObjectDict.count == 0 {
            
            let layoutObjectParser = LayoutObjectParser()
            
            downloadQualityModuleObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: downloadQualityModuleDictionary["layout"] as! Dictionary<String, Any>)
        }
        
        return downloadQualityModuleObject
    }

    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {

        var componentArray:Array<AnyObject> = []

        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {

            let typeOfModule: String? = moduleDictionary["type"] as? String

            if typeOfModule == "button"
            {
                let buttonParser = SFButtonParser()
                var buttonObject = SFButtonObject()
                buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(buttonObject)
            }
            else if typeOfModule == "label"
            {
                let labelParser = SFLabelParser()
                var labelObject = SFLabelObject()
                labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(labelObject)
            }
            else if typeOfModule == "tableView"
            {
                let tableViewParser =   SFTableViewParser()
                let tableViewCellObject = tableViewParser.parseTableViewJson(tableViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(tableViewCellObject)
            }

        }

        return componentArray
    }
}
