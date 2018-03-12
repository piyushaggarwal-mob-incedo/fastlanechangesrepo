//
//  SFWebViewObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 09/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFWebViewObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var trayId:String?
    var type:String?
    var keyName:String?
    var isWebViewInteractive:Bool?
    var shouldNavigateToExternalBrowser:Bool?
}
