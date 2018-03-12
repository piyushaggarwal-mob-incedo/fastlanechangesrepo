//
//  SFManagedImage.swift
//  AppCMS
//
//  Created by Gaurav Vig on 30/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import CoreData

@objc(SFManagedImage)
class SFManagedImage: NSManagedObject {

    // Attributes
    @NSManaged var height: Int32
    @NSManaged var sequence: Int32
    @NSManaged var width: Int32
    @NSManaged var cacheKey:String
    @NSManaged var src:String
    @NSManaged var type:String
    @NSManaged var cacheDate:Date
    
    // Relationships
    @NSManaged var film: SFManagedFilm
    @NSManaged var show: SFManagedShow
    @NSManaged var trayImage: SFManagedTray
    @NSManaged var welcome: SFManagedAppWelcomeData
}
