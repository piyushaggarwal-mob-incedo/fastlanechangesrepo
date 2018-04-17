//
//  LayoutObject.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit

protocol PropertyNames {
    func propertyNames() -> [Any]
}

extension PropertyNames
{
    func propertyNames() -> [Any] {
        return Mirror(reflecting: self).children.flatMap { $0.label }
    }
}


class LayoutObject: NSObject, PropertyNames {
    
    var xAxis:Float?
    var yAxis:Float?
    var width:Float?
    var maxWidth: Float?
    var height:Float?
    var leftMargin:Float?
    var topMargin:Float?
    var rightMargin:Float?
    var bottomMargin:Float?
    var isWidthFlexible:Bool?
    var isHeightFlexible:Bool?
    var aspectRatio:String?
    var isVerticallyAligned:Bool?
    var isHorizontallyAligned:Bool?
    var isVerticallyCentered:Bool?
    var gridWidth:Float?
    var gridHeight:Float?
    var fontSize:Float?
    var fontSizeValue:Float?
    var fontSizeKey:Float?
    var trayPadding:Float?
    var itemHeight:Float?
    var itemWidth:Float?
    var numberOfLines:Int?
    var playerHeight:Float?
    var playerXAxis:Float?
    var playerYAxis:Float?
    var playerWidth:Float?
}

