//
//  SFManagedTray.swift
//  AppCMS
//
//  Created by Gaurav Vig on 30/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import CoreData

@objc(SFManagedTray)
class SFManagedTray: NSManagedObject {

    // Attributes
    @NSManaged var desc:String
    @NSManaged var id:String
    @NSManaged var subHeading:String
    @NSManaged var trayAction:String
    @NSManaged var title:String
    @NSManaged var isHd:Bool
    @NSManaged var type:String
    
    // Relationships
    @NSManaged var images: SFManagedImage
}
