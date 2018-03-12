//
//  SFShowGridModule.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 20/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFShowGridModule: NSObject {
    var moduleID:String?
    var moduleType:String?
    var moduleTitle:String?
    var showDetailGridModuleComponents:Array<AnyObject>?
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
}
