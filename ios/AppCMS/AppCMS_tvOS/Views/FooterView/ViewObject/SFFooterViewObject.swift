//
//  SFFooterViewObject.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 13/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFFooterViewObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var components:Array<AnyObject> = []
    var moduleType: String?
    var moduleTitle: String?
    var moduleID: String?
}
