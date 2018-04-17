//
//  SFVideoDetailModuleObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 23/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFVideoDetailModuleObject: NSObject {

    var moduleID:String?
    var moduleType:String?
    var moduleTitle:String?
    var videoDetailModuleComponents:Array<AnyObject>?
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var apiURL:String?
    var isInlineVideoPlayer:Bool = false
}
