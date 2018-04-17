//
//  SFCollectionGridParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 23/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFCollectionGridParser: NSObject {

    func parseCollectionGridJson(collectionGridDictionary: Dictionary<String, AnyObject>) -> SFCollectionGridObject {
        
        let collectionGridObject = SFCollectionGridObject()

        collectionGridObject.backgroundColor = collectionGridDictionary["backgroundColor"] as? String
        collectionGridObject.cornerRadius = collectionGridDictionary["cornerRadius"] as? Float
        collectionGridObject.isHorizontalScroll = collectionGridDictionary["isHorizontalScroll"] as? Bool
        collectionGridObject.trayPadding = collectionGridDictionary["trayPadding"] as? Float
        collectionGridObject.type = collectionGridDictionary["type"] as? String
        collectionGridObject.key = collectionGridDictionary["key"] as? String
        
        if collectionGridObject.key == nil {
            
            collectionGridObject.key = collectionGridDictionary["type"] as? String
        }
        
        collectionGridObject.trayClickAction = collectionGridDictionary["trayClickAction"] as? String
        collectionGridObject.supportPagination = collectionGridDictionary["supportPagination"] as? Bool
        
        let collectionGridComponentsArray = collectionGridDictionary["components"] as? Array<Dictionary<String, AnyObject>>
        
        if collectionGridComponentsArray != nil {
            
            let componentsUIParser = ComponentUIParser()
            collectionGridObject.trayComponents = componentsUIParser.componentConfigArray(componentsArray: collectionGridComponentsArray!)
        }
                
        let layoutDict = collectionGridDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            collectionGridObject.layoutObjectDict = layoutObjectDict
        }

        return collectionGridObject
    }

    func collectionGridConfigArray(collectionGridComponentsArray:Array<Dictionary<String, Any>>) -> Array<Any> {
        
        var collectionGridArray:Array<Any> = []
        
        for moduleDictionary: Dictionary<String, Any> in collectionGridComponentsArray {
            
            let typeOfModule: String = moduleDictionary["type"] as! String
            
            if typeOfModule == "button"
            {
                let buttonParser = SFButtonParser()
                var buttonObject = SFButtonObject()
                buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                collectionGridArray.append(buttonObject)
            }
            else if typeOfModule == "image"
            {
                let imageParser = SFImageParser()
                var imageObject = SFImageObject()
                imageObject = imageParser.parseImageJson(imageDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                collectionGridArray.append(imageObject)
            }
            else if typeOfModule == "label"
            {
                let labelParser = SFLabelParser()
                var labelObject = SFLabelObject()
                labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                collectionGridArray.append(labelObject)
            }
            else if typeOfModule == "textView"
            {
                let textViewParser = SFTextViewParser()
                var textViewObject = SFTextViewObject()
                textViewObject = textViewParser.parseTextViewJson(textViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                collectionGridArray.append(textViewObject)
            }
            else if typeOfModule == "separatorView"
            {
                let separatorViewParser = SFSeparatorViewParser()
                var separatorViewObject = SFSeparatorViewObject()
                separatorViewObject = separatorViewParser.parseSeparatorViewJson(separatorViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                collectionGridArray.append(separatorViewObject)
            }
            else if typeOfModule == "progressView"
            {
                let progressViewParser = SFProgressViewParser()
                var progressViewObject = SFProgressViewObject()
                progressViewObject = progressViewParser.parseProgressViewJson(progressViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                collectionGridArray.append(progressViewObject)
            }
            else if typeOfModule == "starRatingView"
            {
                let starRatingParser = SFStarRatingParser()
                var starRatingObject = SFStarRatingObject()
                starRatingObject = starRatingParser.parseStarRatingJson(starRatingDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                collectionGridArray.append(starRatingObject)
            }
            else if typeOfModule == "planMetaDataView" {
                
                let planMetaDataViewParser = SFPlanMetaDataViewParser()
                let planMetaDataViewObject = planMetaDataViewParser.parsePlanMetaDataViewJson(planMetaDataViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                
                collectionGridArray.append(planMetaDataViewObject)
            }
        }
        
        return collectionGridArray
    }
}
