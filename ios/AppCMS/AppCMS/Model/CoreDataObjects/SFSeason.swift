//
//  SFSeason.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 18/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFSeason: NSObject {

    @nonobjc var seasonName:String?
    @nonobjc var primaryCategory:String?
    @nonobjc var secondaryCategory:String?
    @nonobjc var tags:String?
    @nonobjc var title:String?
    @nonobjc var episodes:Array<SFFilm>?
    
    #if os(tvOS)
    @nonobjc var isQueued: Bool?
    #endif
}
