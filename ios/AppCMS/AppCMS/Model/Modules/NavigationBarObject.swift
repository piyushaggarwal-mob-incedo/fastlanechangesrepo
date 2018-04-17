//
//  NavigationBar.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 23/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class NavigationBarObject: NSObject {
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var components:Array<Any> = []
    var type:String?
}

class NavigationTitle: NSObject {
    var navLogo: Bool?
    var navTitleText: String?
}
