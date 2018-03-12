//
//  SFSubMenuViewObject.swift
//  AppCMS
//
//  Created by Rajni Pathak on 07/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class SFSubNavigationViewObject: NSObject {
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var components:Array<AnyObject> = []
    var moduleType: String?
    var moduleTitle: String?
    var moduleID: String?
}
