//
//  LoginModule.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 23/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class LoginObject: NSObject {
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var backgroundColor:String?
    var components:Array<AnyObject> = []
    var moduleType:String?
    var moduleID: String?
}
