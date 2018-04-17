//
//  SFTextViewObject.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit

class SFTextViewObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var action:String?
    var type:String?
    var fontSize:Float?
    var textColor:String?
    var text:String?
    var textAlignment:String?
    var fontFamily:String?
    var fontWeight:String?
    var backgroundColor:String?
}
