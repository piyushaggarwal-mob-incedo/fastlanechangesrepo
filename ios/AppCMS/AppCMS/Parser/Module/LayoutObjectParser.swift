//
//  LayoutObjectParser.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit

class LayoutObjectParser: NSObject {

    //MARK: Method to create singeleton class object
//    static let sharedInstance:LayoutObjectParser = {
//        
//        let instance = LayoutObjectParser()
//        
//        return instance
//    }()
    
    func parseLayoutJson(layoutDictionary: Dictionary<String, Any>) -> Dictionary<String, LayoutObject>
    {
        var layoutObjectDict:Dictionary<String, LayoutObject> = [:]
        
        #if os(tvOS)
            if layoutDictionary["appletv"] != nil {
                let appleTVLayoutObject:LayoutObject? = createLayoutObject(subLayoutDict: layoutDictionary["appletv"] as? Dictionary<String, Any>)
                if appleTVLayoutObject != nil {
                    layoutObjectDict["appletv"] = appleTVLayoutObject
                }
            } else if layoutDictionary.isEmpty == false {
                layoutObjectDict["appletv"] = createLayoutObject(subLayoutDict: layoutDictionary)
            }
        #else
            let iPhoneLayoutObject:LayoutObject? = createLayoutObject(subLayoutDict: layoutDictionary["mobile"] as? Dictionary<String, Any>)
            let iPadLandscapeLayoutDict:LayoutObject? = createLayoutObject(subLayoutDict: layoutDictionary["tabletLandscape"] as? Dictionary<String, Any>)
            let iPadPortraitLayoutDict:LayoutObject? = createLayoutObject(subLayoutDict: layoutDictionary["tabletPortrait"] as? Dictionary<String, Any>)
            
            if iPhoneLayoutObject != nil {
                layoutObjectDict["iPhone"] = iPhoneLayoutObject
            }
            if iPadLandscapeLayoutDict != nil {
                layoutObjectDict["iPadLandscape"] = iPadLandscapeLayoutDict
            }
            if iPadPortraitLayoutDict != nil {
                layoutObjectDict["iPadPortrait"] = iPadPortraitLayoutDict
            }
        #endif
        return layoutObjectDict
    }
    
    
    func createLayoutObject(subLayoutDict:Dictionary<String, Any>?) -> LayoutObject? {
        
        let layoutObject = LayoutObject()
        
        layoutObject.height = subLayoutDict?["height"] as? Float
        layoutObject.width = subLayoutDict?["width"] as? Float
        layoutObject.maxWidth = subLayoutDict?["maximumWidth"] as? Float
        layoutObject.xAxis = subLayoutDict?["xAxis"] as? Float
        layoutObject.yAxis = subLayoutDict?["yAxis"] as? Float
        layoutObject.aspectRatio = subLayoutDict?["aspectRatio"] as? String
        layoutObject.bottomMargin = subLayoutDict?["bottomMargin"] as? Float
        layoutObject.topMargin = subLayoutDict?["topMargin"] as? Float
        layoutObject.leftMargin = subLayoutDict?["leftMargin"] as? Float
        layoutObject.rightMargin = subLayoutDict?["rightMargin"] as? Float
        layoutObject.isHeightFlexible = subLayoutDict?["isFlexibleHeight"] as? Bool
        layoutObject.isWidthFlexible = subLayoutDict?["isFlexibleWidth"] as? Bool
        layoutObject.isVerticallyAligned = subLayoutDict?["isVerticallyAligned"] as? Bool
        layoutObject.isHorizontallyAligned = subLayoutDict?["isHorizontallyAligned"] as? Bool
        layoutObject.isVerticallyCentered = subLayoutDict?["isVerticallyCentered"] as? Bool
        layoutObject.gridWidth = subLayoutDict?["gridWidth"] as? Float
        layoutObject.gridHeight = subLayoutDict?["gridHeight"] as? Float
        layoutObject.itemHeight = subLayoutDict?["itemHeight"] as? Float
        layoutObject.itemWidth = subLayoutDict?["itemWidth"] as? Float
        layoutObject.fontSize = subLayoutDict?["fontSize"] as? Float
        layoutObject.fontSizeKey = subLayoutDict?["fontSizeKey"] as? Float
        layoutObject.fontSizeValue = subLayoutDict?["fontSizeValue"] as? Float
        layoutObject.trayPadding = subLayoutDict?["trayPadding"] as? Float
        layoutObject.numberOfLines = subLayoutDict?["numberOfLines"] as? Int
        layoutObject.playerWidth = subLayoutDict?["playerWidth"] as? Float
        layoutObject.playerXAxis = subLayoutDict?["playerXAxis"] as? Float
        layoutObject.playerYAxis = subLayoutDict?["playerYAxis"] as? Float
        layoutObject.playerHeight = subLayoutDict?["playerHeight"] as? Float
        return layoutObject
    }
}
