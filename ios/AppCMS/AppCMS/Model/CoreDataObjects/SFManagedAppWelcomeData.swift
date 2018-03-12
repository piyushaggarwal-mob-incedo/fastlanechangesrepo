//
//  SFManagedAppWelcomeData.swift
//  AppCMS
//
//  Created by Gaurav Vig on 30/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import CoreData

@objc(SFManagedAppWelcomeData)
class SFManagedAppWelcomeData: NSManagedObject {

    // Attributes
    @NSManaged var welcomeDataTimeStamp: Int64
    @NSManaged var appPromotionalDescription: String
    @NSManaged var appPromotionalLink:String
    @NSManaged var appWelcomeTitle:String
    @NSManaged var cacheKey:String
    @NSManaged var isBrowser:String
    @NSManaged var cacheDate:Date
    
    // Relationships
    @NSManaged var welcomeFilms: SFManagedShow
    @NSManaged var welcomeImages: SFManagedImage
}
