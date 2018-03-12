//
//  SFSegmentObject.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 26/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class SFSegmentObject: NSObject {
    var type:String?
    var components:Array<AnyObject>?
    var selectedIndex: Int?
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var value: String?
}
