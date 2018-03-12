//
//  SFManagedFilmUrl.swift
//  AppCMS
//
//  Created by Gaurav Vig on 30/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import CoreData

@objc(SFManagedFilmUrl)
class SFManagedFilmUrl: NSManagedObject {

    // Attributes
    @NSManaged var type:String
    @NSManaged var url:String
    
    // Relationships
    @NSManaged var film: SFManagedFilm
}
