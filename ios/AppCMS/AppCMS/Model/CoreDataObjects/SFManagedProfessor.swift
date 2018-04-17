//
//  SFManagedProfessor.swift
//  AppCMS
//
//  Created by Gaurav Vig on 30/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import CoreData

@objc(SFManagedProfessor)
class SFManagedProfessor: NSManagedObject {

    // Attributes
    @NSManaged var professorPrecedence: Int16
    @NSManaged var affiliation: String
    @NSManaged var cacheKey:String
    @NSManaged var name:String
    @NSManaged var permaLink:String
    @NSManaged var professorDegree:String
    @NSManaged var profilePic:String
    @NSManaged var cacheDate:Date
    
    // Relationships
    @NSManaged var professor: SFManagedFilm
    @NSManaged var showProfessor: SFManagedShow
}
