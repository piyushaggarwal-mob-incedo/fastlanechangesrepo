//
//  SFProductFeatureListObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 11/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFProductFeatureListObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var components:Array<Any> = []
    var featureListArray:Array<FeatureListModel> = []
    var type:String?
    var viewName:String?
    var moduleId:String?
}
