//
//  SFStarRatingObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 28/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFStarRatingObject: NSObject {

    var layoutObjectDict: Dictionary <String,LayoutObject> = [:]
    var type: String?
    var fillBorderColor: String?
    var clearBorderColor: String?
    var fillColor: String?
    var clearColor: String?
    var keyName: String?
    var action: String?
    var margin: Double?
    var starSize: Double?
}
