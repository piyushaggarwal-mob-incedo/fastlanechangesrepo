//
//  SFVerticalArticleMetadataObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 25/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import UIKit

class SFVerticalArticleMetadataObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var type:String?
    var key:String?
    var blockName:String?
    var components:Array<Any> = []
    var backgroundColor:String?
}
