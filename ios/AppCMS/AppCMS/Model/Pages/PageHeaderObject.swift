//
//  PageHeaderObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 15/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class PageHeaderObject: NSObject {

    var buttonText:String?
    var buttonPrefixText:String?
    var displayedPath:String?
    var pageId:String?
    var pagePath:String?
    var placement:String?
    
    init(pageHeaderDictionary:Dictionary<String, Any>) {
        
        self.buttonText = pageHeaderDictionary["ctaText"] as? String
        self.buttonPrefixText = pageHeaderDictionary["bannerText"] as? String
        self.displayedPath = pageHeaderDictionary["displayedPath"] as? String
        self.pageId = pageHeaderDictionary["pageId"] as? String
        self.pagePath = pageHeaderDictionary["url"] as? String
        self.placement = pageHeaderDictionary["placement"] as? String

        super.init()
    }
}
