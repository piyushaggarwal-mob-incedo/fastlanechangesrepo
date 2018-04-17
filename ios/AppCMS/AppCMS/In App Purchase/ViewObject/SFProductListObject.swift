//
//  SFProductListObject.swift
//  AppCMS
//
//  Created by Rajni Pathak on 05/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class SFProductListObject: NSObject {
    
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var components:Array<Any> = []
    var type:String?
    var viewName:String?
    var moduleId:String?
}
