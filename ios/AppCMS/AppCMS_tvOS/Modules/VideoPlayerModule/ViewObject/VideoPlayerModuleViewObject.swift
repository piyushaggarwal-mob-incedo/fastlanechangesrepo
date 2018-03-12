//
//  VideoPlayerModuleViewObject.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 01/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class VideoPlayerModuleViewObject: NSObject {
    
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var components:Array<AnyObject> = []
    var moduleType: String?
    var moduleTitle: String?
    var moduleID: String?
    var isZoomSupported: Bool?
}
