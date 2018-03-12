//
//  SFAccessLevelObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 20/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFAccessLevelObject: NSObject {

    var isAvailableForSubscribed:Bool?
    var isAvailableForLoggedOut:Bool?
    var isAvailableForLoggedIn:Bool?
    
    init(accessLevelDictionary:Dictionary<String, Any>) {
        
        self.isAvailableForLoggedIn = accessLevelDictionary["loggedIn"] as? Bool
        self.isAvailableForLoggedOut = accessLevelDictionary["loggedOut"] as? Bool
        self.isAvailableForSubscribed = accessLevelDictionary["subscribed"] as? Bool

        super.init()
    }
}
