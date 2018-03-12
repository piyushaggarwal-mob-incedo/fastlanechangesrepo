//
//  SFTrayObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 23/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFTrayObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var apiURL:String?
    var trayId:String?
    var type:String?
    var trayViewName:String?
    var trayImageType:String?
    var trayComponents:Array<Any> = []
}
