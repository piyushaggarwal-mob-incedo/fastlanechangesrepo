//
//  SFManagedSeason.swift
//  AppCMS
//
//  Created by Gaurav Vig on 30/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import CoreData

@objc(SFManagedSeason)
class SFManagedSeason: NSManagedObject {

    // Attributes
    @NSManaged var currentEpisode:String
    @NSManaged var seasonName:String
    
    // Relationships
    @NSManaged var show: SFManagedShow
    @NSManaged var seasonEpisodes: SFManagedSeason
}
