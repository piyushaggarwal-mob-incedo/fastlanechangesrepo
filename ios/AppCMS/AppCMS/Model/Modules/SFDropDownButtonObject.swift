//
//  SFDropDownButtonObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 27/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFDropDownButtonObject: NSObject {

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
    var textFontSize:Float?
    var fontFamily:String?
    var fontWeight:String?
    var imageName:String?
    var key:String?
    var textAlignment:String?
    var isVerticalDropDown:Bool?
}
