//
//  SFTimerLoaderViewObject.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 05/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class SFTimerLoaderViewObject {
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var moduleType: String?
    var moduleTitle: String?
    var moduleID: String?
    var fontFamily: String?
    var fontWeight: String?
    var fontSize: Float?
    var alpha: Float?
    var showsCountDown: Bool?
    var textAlignment: String?
    var loaderTimeDuration: Int?
}
