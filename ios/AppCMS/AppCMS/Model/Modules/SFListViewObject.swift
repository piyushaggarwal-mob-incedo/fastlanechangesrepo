//
//  SFListViewObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 13/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFListViewObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var apiURL:String?
    var listViewId:String?
    var type:String?
    var viewName:String?
    var listViewComponents:Array<Any> = []
    var blockName:String?
}
