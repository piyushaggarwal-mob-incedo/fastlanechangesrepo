//
//  SFBannerViewObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 14/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFBannerViewObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var apiURL:String?
    var bannerViewId:String?
    var type:String?
    var viewName:String?
    var bannerViewComponents:Array<Any> = []
    var blockName:String?
    var bannerViewBackgroundColor:String?
    var bannerTitle:String?
    var bannerImage:String?
    var bannerGridOptions:Array<SFLinkObject>?
    var bannerTitleTextColor:String?
}
