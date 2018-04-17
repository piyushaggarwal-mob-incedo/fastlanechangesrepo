//
//  SFDownloadQualityObject.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/24/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFDownloadQualityObject: NSObject {
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var backgroundColor:String?
    var components:Array<AnyObject> = []
    var moduleType:String?
    var moduleID: String?
    var viewAlpha: CGFloat?
}
