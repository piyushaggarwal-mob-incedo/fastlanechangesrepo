//
//  SFJumbotronObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 24/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFJumbotronObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var apiURL:String?
    var trayId:String?
    var type:String?
    var jumbotronViewName:String?
    var isJumbotronLoopEnabled:Bool?
    var jumbotronImageType:String?
    var jumbotronComponents:Array<AnyObject> = []
    var animationDuration:Int?
}
