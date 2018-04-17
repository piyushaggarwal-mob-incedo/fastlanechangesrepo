//
//  SFCarouselItemObject.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 04/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFCarouselItemObject: NSObject {
    var type:String?
    var components:Array<AnyObject>?
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
}
