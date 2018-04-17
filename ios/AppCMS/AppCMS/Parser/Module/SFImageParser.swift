//
//  SFImageParser.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit

class SFImageParser: NSObject {

    func parseImageJson(imageDictionary: Dictionary<String, AnyObject>) -> SFImageObject
    {
        let imageObject = SFImageObject()
        imageObject.backgroundColor = imageDictionary["backgroundColor"] as? String
        imageObject.alpha = imageDictionary["opacity"] as? Float
        imageObject.type = imageDictionary["type"] as? String
        imageObject.action = imageDictionary["action"] as? String
        imageObject.key = imageDictionary["key"] as? String
        imageObject.imageName = imageDictionary["imageName"] as? String
        let settingDict = imageDictionary["settings"] as? Dictionary<String, AnyObject>
        if let settings = settingDict {
            imageObject.autoHide = settings["autoHide"] as? Bool
            imageObject.autoHideDuration = settings["autoHideDuration"] as? Float
        }
        
        let layoutDict = imageDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            imageObject.layoutObjectDict = layoutObjectDict
        }

        return imageObject
    }
}
