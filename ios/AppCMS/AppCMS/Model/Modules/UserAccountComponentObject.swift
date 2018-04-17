//
//  UserAccountComponentObject.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 05/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class UserAccountComponentObject: NSObject {
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var components:Array<AnyObject> = []
    var type: String?
    var view: String?
    var key: String?
}
