//
//  SFArticleDetailObject.swift
//  AppCMS
//
//  Created by  Diksha Goyal on 17/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import Foundation

class SFArticleDetailObject: NSObject {
    
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var backgroundColor:String?
    var components:Array<AnyObject> = []
    var moduleType:String?
    var moduleID: String?
    var viewAlpha: CGFloat?
    
}
