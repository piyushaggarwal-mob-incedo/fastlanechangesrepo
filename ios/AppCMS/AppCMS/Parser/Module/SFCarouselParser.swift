//
//  SFCarouselParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 26/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFCarouselParser: NSObject {

    func parseCarouselJson(carouselDict: Dictionary<String, AnyObject>) -> SFCarouselObject {
        
        let carouselObject = SFCarouselObject()
        
        carouselObject.type = carouselDict["type"] as? String
        carouselObject.keyName = carouselDict["key"] as? String
        carouselObject.action = carouselDict["trayClickAction"] as? String
        
        let componentArray = carouselDict["components"] as? Array<Dictionary<String, AnyObject>>
        if componentArray != nil {
            
            let componentsUIParser = ComponentUIParser()
            carouselObject.carouselComponents = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
        }
        
        let layoutObjectParser = LayoutObjectParser()
        carouselObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: carouselDict["layout"] as! Dictionary<String, Any>)
        
        return carouselObject
    }
    
    
    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {
        
        var componentArray:Array<AnyObject> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == "button" {
                
                let buttonParser = SFButtonParser()
                let buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(buttonObject)
            }
            else if typeOfModule == "image" {
                
                let imageParser = SFImageParser()
                let imageObject = imageParser.parseImageJson(imageDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(imageObject)
            }
            else if typeOfModule == "label" {
                
                let labelParser = SFLabelParser()
                let labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(labelObject)
            }
            else if typeOfModule == "textView" {
                
                let textViewParser = SFTextViewParser()
                let textViewObject = textViewParser.parseTextViewJson(textViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(textViewObject)
            }
            else if typeOfModule == "separatorView" {
                
                let separatorViewParser = SFSeparatorViewParser()
                let separatorViewObject = separatorViewParser.parseSeparatorViewJson(separatorViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(separatorViewObject)
            } else if typeOfModule == "carouselItem"
            {
                let carouselItemObject = SFCarouselItemParser().parseCarouselItem(carouselObjectDictionary: moduleDictionary)
                componentArray.append(carouselItemObject)
            }
        }
        
        return componentArray
    }

}
