//
//  SFWatchlistAndHistoryViewParser.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 10/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFWatchlistAndHistoryViewParser: NSObject {
    
    func parseLayoutJson(viewModuleDictionary: Dictionary<String, AnyObject>) -> SFWatchlistAndHistoryViewObject
    {
        let associatedViewObject = SFWatchlistAndHistoryViewObject()
        
        associatedViewObject.moduleID = viewModuleDictionary["id"] as? String
        associatedViewObject.moduleType = viewModuleDictionary["view"] as? String
        associatedViewObject.moduleTitle = viewModuleDictionary["title"] as? String
        
//        #if os(tvOS)
//            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
//                var filePath:String
//                if associatedViewObject.moduleType == "AC Watchlist 01" {
//                    filePath = (Bundle.main.resourcePath?.appending("/WatchlistModule_AppleTV.json"))!
//                } else {
//                    filePath = (Bundle.main.resourcePath?.appending("/HistoryModule_AppleTV.json"))!
//                }
//                if FileManager.default.fileExists(atPath: filePath){
//                    let jsonData:Data = FileManager.default.contents(atPath: filePath)!
//                    let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, AnyObject>
//                    let layoutDict = responseJson["layout"] as? Dictionary<String, Any>
//                    let componentArray = responseJson["components"] as? Array<Dictionary<String, AnyObject>>
//
//                    if componentArray != nil {
//                        associatedViewObject.components = componentConfigArray(componentsArray: componentArray!)
//                    }
//
//                    let layoutObjectParser = LayoutObjectParser()
//                    associatedViewObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
//                }
//            } else {
//                let componentArray = viewModuleDictionary["components"] as? Array<Dictionary<String, AnyObject>>
//
//                if componentArray != nil {
//                    associatedViewObject.components = componentConfigArray(componentsArray: componentArray!)
//                }
//
//                let layoutObjectParser = LayoutObjectParser()
//                associatedViewObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: viewModuleDictionary["layout"] as! Dictionary<String, Any>)
//            }
//        #else
            if DEBUGMODE {
                var filePath:String
                if associatedViewObject.moduleType == "AC Watchlist 01" {
                    filePath = (Bundle.main.resourcePath?.appending("/WatchlistModule_AppleTV.json"))!
                } else {
                    filePath = (Bundle.main.resourcePath?.appending("/HistoryModule_AppleTV.json"))!
                }
                if FileManager.default.fileExists(atPath: filePath){
                    let jsonData:Data = FileManager.default.contents(atPath: filePath)!
                    let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, AnyObject>
                    let layoutDict = responseJson["layout"] as? Dictionary<String, Any>
                    let componentArray = responseJson["components"] as? Array<Dictionary<String, AnyObject>>
                    
                    if componentArray != nil {
                        associatedViewObject.components = componentConfigArray(componentsArray: componentArray!)
                    }
                    
                    let layoutObjectParser = LayoutObjectParser()
                    associatedViewObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
                }
            } else {
                let componentArray = viewModuleDictionary["components"] as? Array<Dictionary<String, AnyObject>>
                
                if componentArray != nil {
                    associatedViewObject.components = componentConfigArray(componentsArray: componentArray!)
                }
                
                let layoutObjectParser = LayoutObjectParser()
                associatedViewObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: viewModuleDictionary["layout"] as! Dictionary<String, Any>)
            }
        //#endif
        return associatedViewObject
    }
    
    
    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {
        
        var componentArray:Array<AnyObject> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == "button"
            {
                let buttonParser = SFButtonParser()
                let buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(buttonObject)
            }
            else if typeOfModule == "image" || typeOfModule == "imageView"
            {
                let imageParser = SFImageParser()
                let imageObject = imageParser.parseImageJson(imageDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(imageObject)
            }
            else if typeOfModule == "label"
            {
                let labelParser = SFLabelParser()
                let labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(labelObject)
            }
            else if typeOfModule == "textView"
            {
                let textViewParser = SFTextViewParser()
                let textViewObject = textViewParser.parseTextViewJson(textViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(textViewObject)
            }
            else if typeOfModule == "separatorView"
            {
                let separatorViewParser = SFSeparatorViewParser()
                let separatorViewObject = separatorViewParser.parseSeparatorViewJson(separatorViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(separatorViewObject)
            }
            else if typeOfModule == "tableView"
            {
                let tableViewParser = SFTableViewParser()
                let tableViewCellObject = tableViewParser.parseTableViewJson(tableViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(tableViewCellObject)
            }
        }
        
        return componentArray
    }
    
}
