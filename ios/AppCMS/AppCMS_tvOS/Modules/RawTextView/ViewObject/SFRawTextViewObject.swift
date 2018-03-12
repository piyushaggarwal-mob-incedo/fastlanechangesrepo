//
//  SFRawTextViewObject.swift
//  AppCMS
//
//  Created by Rajni Pathak on 19/12/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class SFRawTextViewObject: NSObject {
    
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var components:Array<AnyObject> = []
    var moduleType: String?
    var moduleTitle: String?
    var moduleID: String?
}
