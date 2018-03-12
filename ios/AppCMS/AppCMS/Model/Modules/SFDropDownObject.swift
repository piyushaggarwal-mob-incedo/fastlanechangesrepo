//
//  SFDropDownObject.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 30/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFDropDownObject: NSObject {
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var type:String?
    var fontSize:Float?
    var textColor:String?
    var text:String?
    var textAlignment:String?
    var fontFamily:String?
    var fontWeight:String?
    var backgroundColor:String?
    var opacity: Float?
    var isProtected: Bool?
    var key: String?
    var cornerRadius:Float?
    var action: String?
}
