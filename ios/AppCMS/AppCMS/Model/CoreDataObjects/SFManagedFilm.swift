//
//  SFManagedFilm.swift
//  AppCMS
//
//  Created by Gaurav Vig on 30/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import CoreData

//@objc(SFManageFilm)
class SFManagedFilm: NSManagedObject {

    // Attributes
    @NSManaged var durationMinutes: Int32
    @NSManaged var durationSeconds: Int32
    @NSManaged var episodeNumber: Int32
    @NSManaged var seasonNumber: Int32
    @NSManaged var sequence: Int32
    @NSManaged var year: String
    @NSManaged var filmPercentage:Double
    @NSManaged var filmWatchedDuration: Double
    @NSManaged var adTag: String
    @NSManaged var cacheKey:String
    @NSManaged var desc:String
    @NSManaged var geo:String
    @NSManaged var id:String
    @NSManaged var parentalRating:String
    @NSManaged var permaLink:String
    @NSManaged var primaryCategory:String
    @NSManaged var seasonName:String
    @NSManaged var secondaryCategory:String
    @NSManaged var showId:String
    @NSManaged var showTitle:String
    @NSManaged var tags:String
    @NSManaged var title:String
    @NSManaged var userGrade:String
    @NSManaged var viewerGrade:Double
    @NSManaged var isHd:Bool
    @NSManaged var isLiveStream:Bool
    @NSManaged var addedDate:Date
    @NSManaged var cacheDate:Date
    @NSManaged var publishDate:Double
    @NSManaged var type:String
    @NSManaged var imageURL:String
    @NSManaged var trailerURL:String
    @NSManaged var trailerId:String
    @NSManaged var isFreeVideo:Bool
    // Relationships
    @NSManaged var closedCaptions: NSSet
    @NSManaged var credits: NSSet
    @NSManaged var filmUrl: NSSet
    @NSManaged var images: NSSet
    @NSManaged var professors: NSSet
    @NSManaged var relatedCourses: NSSet
    @NSManaged var relatedFilm: SFManagedFilm
    @NSManaged var relatedFilms: NSSet
    @NSManaged var season: SFManagedSeason
    @NSManaged var seasonFilm: SFManagedFilm
    @NSManaged var seasonFilms: NSSet
    @NSManaged var eventId:String?
}

extension SFManagedFilm {
    
    @objc(addImagesObject:)
    @NSManaged public func addImagesObject(value: NSManagedObject)
    @objc(removeImagesObject:)
    @NSManaged public func removeImagesObject(value: NSManagedObject)
    @objc(addImages:)
    @NSManaged public func addImages(values: NSSet)
    @objc(removeImages:)
    @NSManaged public func removeImages(values: NSSet)
    
    @objc(addAdsObject:)
    @NSManaged public func addAdsObject(value: NSManagedObject)
    @objc(removeAdsObject:)
    @NSManaged public func removeAdsObject(value: NSManagedObject)
    @objc(addAds:)
    @NSManaged public func addAds(values: NSSet)
    @objc(removeAds:)
    @NSManaged public func removeAds(values: NSSet)

    @objc(addClosedCaptionsObject:)
    @NSManaged public func addClosedCaptionsObject(value: NSManagedObject)
    @objc(removeClosedCaptionsObject:)
    @NSManaged public func removeClosedCaptionsObject(value: NSManagedObject)
    @objc(addClosedCaptions:)
    @NSManaged public func addClosedCaptions(values: NSSet)
    @objc(removeClosedCaptions:)
    @NSManaged public func removeClosedCaptions(values: NSSet)
}
