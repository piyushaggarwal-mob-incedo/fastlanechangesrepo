//
//  SFCastViewObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 26/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFCastViewObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var action:String?
    var type:String?
    var fontSize:Float?
    var textColor:String?
    var text:String?
    var textAlignment:String?
    var fontFamilyKey:String?
    var fontFamilyValue:String?
    var backgroundColor:String?
}
