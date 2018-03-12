//
//  SFFilmProtocol.swift
//  AppCMS
//
//  Created by Gaurav Vig on 04/04/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import CoreData

@objc protocol SFFilmProtocol: NSObjectProtocol {
    
    // Attributes
    @objc optional var durationMinutes: Int32 { get set }
    @objc optional var durationSeconds: Int32 { get set }
    @objc optional var episodeNumber: Int32 { get set }
    @objc optional var seasonNumber: Int32 { get set }
    @objc optional var sequence: Int32 { get set }
    @objc optional var year: Int32 { get set }
    @objc optional var filmPercentage:Double { get set }
    @objc optional var filmWatchedDuration: Double { get set }
    @objc optional var adTag: String { get set }
    @objc optional var cacheKey:String { get set }
    @objc optional var desc:String { get set }
    @objc optional var geo:String { get set }
    @objc optional var id:String { get set }
    @objc optional var parentalRating:String { get set }
    @objc optional var permaLink:String { get set }
    @objc optional var primaryCategory:String { get set }
    @objc optional var seasonName:String { get set }
    @objc optional var secondaryCategory:String { get set }
    @objc optional var showId:String { get set }
    @objc optional var showTitle:String { get set }
    @objc optional var tags:String { get set }
    @objc optional var title:String { get set }
    @objc optional var userGrade:String { get set }
    @objc optional var viewerGrade:String { get set }
    @objc optional var isHd:Bool { get set }
    @objc optional var isLiveStream:Bool { get set }
    @objc optional var addedDate:Date { get set }
    @objc optional var cacheDate:Date { get set }
    @objc optional var publishDate:Date { get set }
    @objc optional var type:String { get set }
    
    // Relationships
    @objc optional var closedCaptions: NSSet { get set }
    @objc optional var credits: NSSet { get set }
    @objc optional var filmUrl: NSSet { get set }
    @objc optional var images: NSSet { get set }
    @objc optional var professors: NSSet { get set }
    @objc optional var relatedCourses: NSSet { get set }
    @objc optional var relatedFilm: SFManagedFilm { get set }
    @objc optional var relatedFilms: NSSet { get set }
    @objc optional var season: SFManagedSeason { get set }
    @objc optional var seasonFilm: SFManagedFilm { get set }
    @objc optional var seasonFilms: NSSet { get set }

    
}
