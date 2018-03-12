//
//  SFManagedShow.swift
//  AppCMS
//
//  Created by Gaurav Vig on 30/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import CoreData

@objc(SFManagedShow)
class SFManagedShow: NSManagedObject {

    // Attributes
    @NSManaged var durationMinutes: Int32
    @NSManaged var durationSeconds: Int32
    @NSManaged var noOfEpisodes: Int32
    @NSManaged var sequence: Int32
    @NSManaged var year: Int32
    @NSManaged var cacheKey:String
    @NSManaged var desc:String
    @NSManaged var id:String
    @NSManaged var permaLink:String
    @NSManaged var primaryCategory:String
    @NSManaged var title:String
    @NSManaged var userGrade:String
    @NSManaged var viewerGrade:String
    @NSManaged var isHd:Bool
    @NSManaged var addedDate:Date
    @NSManaged var cacheDate:Date
    @NSManaged var type:String
    
    // Relationships
    @NSManaged var courses: SFManagedFilm
    @NSManaged var images: SFManagedImage
    @NSManaged var professors: SFManagedProfessor
    @NSManaged var relatedShow: SFManagedShow
    @NSManaged var seasons: SFManagedSeason
    @NSManaged var show: SFManagedShow
    @NSManaged var welcomeFilmItem: SFManagedAppWelcomeData
}
