//
//  SFPlanMetaDataViewObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 11/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFPlanMetaDataViewObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var components:Array<Any> = []
    var type:String?
    var keyName:String?
}
