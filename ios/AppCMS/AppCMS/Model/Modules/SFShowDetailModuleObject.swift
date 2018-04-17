//
//  SFShowDetailModuleObject.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 19/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFShowDetailModuleObject: NSObject {
    var moduleID:String?
    var moduleType:String?
    var moduleTitle:String?
    var showDetailModuleComponents:Array<AnyObject>?
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var apiURL:String?
}
