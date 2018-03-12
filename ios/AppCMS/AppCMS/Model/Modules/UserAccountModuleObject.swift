//
//  UserAccountModuleObject.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 05/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class UserAccountModuleObject: NSObject {
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var components:Array<AnyObject> = []
    var moduleType: String?
    var moduleTitle: String?
    var moduleID: String?
}
