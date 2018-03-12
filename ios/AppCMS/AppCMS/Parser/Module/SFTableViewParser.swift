//
//  SFTableViewCellParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 22/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFTableViewParser: NSObject {

    //MARK: Method to create singeleton class object
//    static let sharedInstance:SFTableViewParser = {
//        
//        let instance = SFTableViewParser()
//        
//        return instance
//    }()
    
    
    func parseTableViewJson(tableViewDictionary: Dictionary<String, AnyObject>) -> SFTableViewObject {
        
        let tableViewObject = SFTableViewObject()
        
        tableViewObject.backgroundColor = tableViewDictionary["backgroundColor"] as? String
        tableViewObject.cornerRadius = tableViewDictionary["cornerRadius"] as? Float
        tableViewObject.isHorizontalScroll = tableViewDictionary["isHorizontalScroll"] as? Bool
        tableViewObject.trayPadding = tableViewDictionary["trayPadding"] as? Float
        tableViewObject.type = tableViewDictionary["type"] as? String
        tableViewObject.trayClickAction = tableViewDictionary["trayClickAction"] as? String
        
        let blockName:String? = tableViewDictionary["blockName"] as? String
        
        if blockName != nil {
            
            if PageUIBlocks.sharedInstance.blockComponents != nil {
                let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                
                if pageBlockComponentDict != nil {
                    
                    if pageBlockComponentDict?["components"] as? Array<AnyObject> != nil {
                        
                        tableViewObject.trayComponents = pageBlockComponentDict?["components"] as! Array<AnyObject>
                    }
                    
                    if pageBlockComponentDict?["layout"] != nil {
                        
                        tableViewObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                    }
                }
            }
        }
        
        if tableViewObject.trayComponents.count == 0 {
            
            let tableViewComponentsArray = tableViewDictionary["components"] as? Array<Dictionary<String, AnyObject>>
            
            if tableViewComponentsArray != nil {
                
                let componentsUIParser = ComponentUIParser()
                tableViewObject.trayComponents = componentsUIParser.componentConfigArray(componentsArray: tableViewComponentsArray!)
            }
        }
        
        if tableViewObject.layoutObjectDict.count == 0 {
            
            let layoutDict = tableViewDictionary["layout"] as? Dictionary<String, Any>
            if layoutDict != nil {
                
                let layoutObjectParser = LayoutObjectParser()
                let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
                tableViewObject.layoutObjectDict = layoutObjectDict
            }
        }
        return tableViewObject
    }
    
    func tableViewConfigArray(tableViewComponentsArray:Array<Dictionary<String, Any>>) -> Array<Any> {
        
        var tableViewArray:Array<Any> = []
        
        for moduleDictionary: Dictionary<String, Any> in tableViewComponentsArray {
            
            let typeOfModule: String = moduleDictionary["type"] as! String
            
            if typeOfModule == "button"
            {
                let buttonParser = SFButtonParser()
                var buttonObject = SFButtonObject()
                buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                tableViewArray.append(buttonObject)
            }
            else if typeOfModule == "image"
            {
                let imageParser = SFImageParser()
                var imageObject = SFImageObject()
                imageObject = imageParser.parseImageJson(imageDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                tableViewArray.append(imageObject)
            }
            else if typeOfModule == "label"
            {
                let labelParser = SFLabelParser()
                var labelObject = SFLabelObject()
                labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                tableViewArray.append(labelObject)
            }
            else if typeOfModule == "textView"
            {
                let textViewParser = SFTextViewParser()
                var textViewObject = SFTextViewObject()
                textViewObject = textViewParser.parseTextViewJson(textViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                tableViewArray.append(textViewObject)
            }
            else if typeOfModule == "separatorView"
            {
                let separatorViewParser = SFSeparatorViewParser()
                var separatorViewObject = SFSeparatorViewObject()
                separatorViewObject = separatorViewParser.parseSeparatorViewJson(separatorViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                tableViewArray.append(separatorViewObject)
            }
            else if typeOfModule == "progressView"
            {
                let progressViewParser = SFProgressViewParser()
                var progressViewObject = SFProgressViewObject()
                progressViewObject = progressViewParser.parseProgressViewJson(progressViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                tableViewArray.append(progressViewObject)
            }
            else if typeOfModule == "starRatingView"
            {
                let starRatingParser = SFStarRatingParser()
                var starRatingObject = SFStarRatingObject()
                starRatingObject = starRatingParser.parseStarRatingJson(starRatingDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                tableViewArray.append(starRatingObject)
            }
        }
        
        return tableViewArray
    }
}
