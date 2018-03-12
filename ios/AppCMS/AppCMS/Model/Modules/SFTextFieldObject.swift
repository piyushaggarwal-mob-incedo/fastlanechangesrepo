//
//  SFTextField.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 23/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class SFTextFieldObject: NSObject {
    
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
}
