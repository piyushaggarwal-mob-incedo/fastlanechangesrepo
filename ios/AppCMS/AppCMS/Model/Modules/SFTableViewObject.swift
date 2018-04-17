//
//  SFTableViewCellObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 22/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFTableViewObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var backgroundColor:String?
    var trayComponents:Array<Any> = []
    var cornerRadius:Float?
    var isHorizontalScroll:Bool?
    var trayPadding:Float?
    var trayClickAction:String?
    var type:String?
    var keyName:String?
}
