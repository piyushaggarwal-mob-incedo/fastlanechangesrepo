//
//  AutoplayObject.swift
//  AppCMS
//
//  Created by  Diksha Goyal on 10/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFAutoplayObject: NSObject {
   
        var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
        var backgroundColor:String?
        var components:Array<AnyObject> = []
        var moduleType:String?
        var moduleID: String?
        var viewAlpha: CGFloat?
        var timerValue : Int?

}
