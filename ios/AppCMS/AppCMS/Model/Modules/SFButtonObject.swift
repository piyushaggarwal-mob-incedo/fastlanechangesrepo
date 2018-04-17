//
//  SFButtonObject.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit

class SFButtonObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var action:String?
    var text:String?
    var selectedText:String?
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
    var imageName:String?
    var key:String?
    var isVisibleForTablet:Bool?
    var isVisibleForPhone:Bool?
    var selectedStateText:String?
}
