//
//  SFManagedCredit.swift
//  AppCMS
//
//  Created by Gaurav Vig on 30/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import CoreData

@objc(SFManagedCredit)
class SFManagedCredit: NSManagedObject {

    // Attributes
    @NSManaged var userGrade:String
    @NSManaged var viewerGrade:Data
    
    // Relationships
    @NSManaged var film: SFManagedFilm
}
