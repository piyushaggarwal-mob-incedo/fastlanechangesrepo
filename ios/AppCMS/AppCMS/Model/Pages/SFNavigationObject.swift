//
//  SFNavigationObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 20/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFNavigationObject: NSObject {

    var iconName:String?
    var title:String?
    var displayedPath:String?
    var pageId:String?
    var pagePath:String?
    var navigationAccessLevel:SFAccessLevelObject?
    
    init(navDictionary:Dictionary<String, Any>) {
        
        self.iconName = navDictionary["icon"] as? String
        self.title = navDictionary["title"] as? String
        self.displayedPath = navDictionary["displayedPath"] as? String
        self.pageId = navDictionary["pageId"] as? String
        self.pagePath = navDictionary["url"] as? String
        
        if let accessLevelDict = navDictionary["accessLevels"] as? Dictionary<String, Any> {
            
            self.navigationAccessLevel = SFAccessLevelObject.init(accessLevelDictionary: accessLevelDict)
        }
        
        super.init()
    }
}
