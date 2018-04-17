//
//  Navigation.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 05/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import UIKit

enum navigationType: Int {
    case primary
    case user
    case footer
}


class NavigationItem: NSObject
{
    var title: String?
    var pageUrl: String?
    var pageId: String = ""
    var pageIcon: String?
    var subNavItems: Array<NavigationItem>
    var loggedOut:Bool?
    var loggedIn:Bool?
    var subscribed: Bool?
    var displayedPath: String?
    var type: navigationType?
    
    override init() {
        subNavItems = Array()
    }
}


class Navigation: NSObject {
        
    override init() {
        navigationDrawerAnimation = 0
        navigationDrawerCornerRadius = 1
        navigationItems = Array()
        navigationItemDict = [:]
    }
    
    //MARK: Properties
    var navigationDrawerWidth: CGFloat?
    var navigationBackgroundColor: UIColor?
    var navigationDrawerAnimation: Int?
    var navigationDrawerCornerRadius: Int?
    var navigationItemDict:Dictionary<String, Array<NavigationItem>>
    var navigationItems: Array<NavigationItem>
}

