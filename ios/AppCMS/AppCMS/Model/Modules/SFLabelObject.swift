//
//  SFLabelObject.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit

class SFLabelObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var action:String?
    var text:String?
    var type:String?
    var backgroundColor:String?
    var selectedBackgroundColor:String?
    var borderWidth:Float?
    var borderColor:String?
    var textColor:String?
    var selectedTextColor:String?
    var cornerRadius:Float?
    var textFontSize:Float?
    var fontFamily:String?
    var fontWeight:String?
    var numberOfLines:Int?
    var textAlignment:String?
    var key:String?
    var underline: Bool?
    var underlineColor: String?
    var underlineWidth: Float?
    var alpha: Float?
    var letterSpacing: Float?
    var lineHeight: Float?
    var hugsContent: Bool?
    var backgroundColorAlpha: Float?
    var textStyle: String?
    var prefixText: String?
}
