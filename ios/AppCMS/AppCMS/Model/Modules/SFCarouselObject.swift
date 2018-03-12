//
//  SFCarouselObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 26/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFCarouselObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var type:String?
    var keyName:String?
    var action:String?
    var carouselComponents:Array<AnyObject> = []
}
