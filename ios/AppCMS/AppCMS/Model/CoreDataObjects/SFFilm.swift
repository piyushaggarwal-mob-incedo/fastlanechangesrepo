//
//  SFFilm.swift
//  AppCMS
//
//  Created by Gaurav Vig on 04/04/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
//import SFFilmProtocol

@objc(SFFilm)
class SFFilm: NSObject {

    // Attributes
    @nonobjc var durationMinutes: Int32?
    @nonobjc var durationSeconds: Int32?
    @nonobjc var episodeNumber: Int32?
    @nonobjc var seasonNumber: Int32?
    @nonobjc var sequence: Int32?
    @nonobjc var year: String?
    @nonobjc var filmPercentage:Double?
    @nonobjc var filmWatchedDuration: Double?
    @nonobjc var adTag: String?
    @nonobjc var cacheKey:String?
    @nonobjc var desc:String?
    @nonobjc var geo:String?
    @nonobjc var id:String?
    @nonobjc var parentalRating:String?
    @nonobjc var permaLink:String?
    @nonobjc var primaryCategory:String?
    @nonobjc var seasonName:String?
    @nonobjc var secondaryCategory:String?
    @nonobjc var showId:String?
    @nonobjc var showTitle:String?
    @nonobjc var tags:String?
    @nonobjc var title:String?
    @nonobjc var userGrade:String?
    @nonobjc var viewerGrade:Double?
    @nonobjc var isHd:Bool?
    @nonobjc var isLiveStream:Bool?
    @nonobjc var addedDate:Date?
    @nonobjc var cacheDate:Date?
    @nonobjc var publishDate:Double?
    @nonobjc var type:String?
    @nonobjc var imageURL:String?
    @nonobjc var trailerURL:String?
    @nonobjc var trailerId:String?
    @nonobjc var thumbnailImageURL:String?
    @nonobjc var fileBitRate:String?
    @nonobjc var isFreeVideo:Bool?
    #if os(tvOS)
    @nonobjc var isQueued: Bool?
    #endif
    @nonobjc var mediaType:String?
    @nonobjc var eventId:String?
    
    // Relationships
    @nonobjc var closedCaptions: NSMutableSet = NSMutableSet()
    @nonobjc var credits: NSMutableSet = NSMutableSet()
    @nonobjc var filmUrl: NSMutableSet = NSMutableSet()
    @nonobjc var images: NSMutableSet = NSMutableSet()
    @nonobjc var professors: NSMutableSet  = NSMutableSet()
    @nonobjc var relatedCourses: NSMutableSet = NSMutableSet()
    @nonobjc var relatedFilm: SFFilm?
    @nonobjc var relatedFilms: NSMutableSet = NSMutableSet()
    @nonobjc var season: SFManagedSeason?
    @nonobjc var seasonFilm: SFFilm?
    @nonobjc var seasonFilms: NSMutableSet = NSMutableSet()
    
    override func mutableSetValue(forKey key: String) -> NSMutableSet {
        return self.value(forKey: key) as! NSMutableSet
    }
    
    #if os(tvOS)
    
    override init() {
        super.init()
    }
    
    init(videoObject: VideoObject) {
        self.title = videoObject.videoTitle ?? ""
        self.durationSeconds = Int32(videoObject.videoPlayerDuration ?? 0)
        self.id = videoObject.videoContentId ?? ""
        self.permaLink = videoObject.gridPermalink ?? ""
        self.filmWatchedDuration = videoObject.videoWatchedTime ?? 0
        self.desc = videoObject.videoDescription ?? ""
        self.thumbnailImageURL = videoObject.thumbnailImageUrlString
        super.init()
    }
    #endif
    
}

extension SFFilm {
    
    //MARK - method to create video detail page - video info label(metadata)
    func getVideoInfoString() -> String? {
        
        let videoDurationInMinutes:Int = Int(self.durationSeconds ?? 0) / 60
        let videoDurationInSecs:Int = Int(self.durationSeconds ?? 0)
        
        var videoDurationValue:String?
        
        if videoDurationInMinutes > 1 {
            
            videoDurationValue = "\(videoDurationInMinutes) MINS"
        } else if videoDurationInMinutes == 1 {
            
            videoDurationValue = "\(videoDurationInMinutes) MIN"
        }
        else if videoDurationInSecs > 0 && videoDurationInMinutes < 1 {
            
            videoDurationValue = "\(videoDurationInSecs) SECS"
        }
        else if videoDurationInSecs == 0 {
            
            videoDurationValue = "\(videoDurationInSecs) SEC"
        }
        
        let videoYear:String? = self.year ?? ""
        let videoCategory:String? = self.primaryCategory ?? ""
        
        var videoInfoString:String?
        
        if videoDurationValue != nil {
            
            videoInfoString = videoDurationValue
        }
        
        if videoYear != nil {
            
            if videoInfoString != nil {
                if (videoYear?.characters.count)! > 0 {
                    videoInfoString?.append(" | \(videoYear!)")
                }
            }
            else if (videoYear?.characters.count)! > 0 {
                videoInfoString = videoYear!
            }
        }
        
        if videoCategory != nil {
            
            if videoInfoString != nil {
                
                if !(videoCategory?.isEmpty)! {
                    videoInfoString?.append(" | \(videoCategory!.uppercased())")
                }
            }
            else {
                videoInfoString = videoCategory!.uppercased()
            }
        }
        
        return videoInfoString
    }
    
    #if os(iOS)
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
    #endif
}
