//
//  SFManagedSubtitle.swift
//  AppCMS
//
//  Created by Gaurav Vig on 30/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import CoreData

@objc(SFManagedSubtitle)
class SFManagedSubtitle: NSManagedObject {

    // Attributes
    @NSManaged var cacheKey:String
    @NSManaged var filmContent:String
    @NSManaged var filmUrl:String
    @NSManaged var language:String
    @NSManaged var cacheDate:Date
    
    // Relationships
    @NSManaged var film: SFManagedFilm
}
