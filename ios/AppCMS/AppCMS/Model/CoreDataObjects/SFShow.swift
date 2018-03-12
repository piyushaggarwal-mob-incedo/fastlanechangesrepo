//
//  SFShow.swift
//  AppCMS
//
//  Created by  Diksha Goyal on 04/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class SFShow: NSObject {
    
    // Attributes
    @nonobjc var showTitle: String?
    @nonobjc var showId:String?
    @nonobjc var userGrade:String?
    @nonobjc var viewerGrade:Double?
    @nonobjc var addedDate:Date?
    @nonobjc var cacheDate:Date?
    @nonobjc var publishDate:Date?
    @nonobjc var type:String?
    @nonobjc var imageURL:String?
    @nonobjc var trailerURL:String?
    @nonobjc var trailerId:String?
    @nonobjc var thumbnailImageURL:String?
    @nonobjc var seasons: Array<SFSeason>?
    @nonobjc var trailersAndClips: Array<SFFilm>?
    @nonobjc var relatedShows: Array<SFShow>?
    @nonobjc var year: String?
    @nonobjc var credits: NSMutableSet = NSMutableSet()
    @nonobjc var desc:String?
    @nonobjc var permaLink:String?
    @nonobjc var sequence: Int32?
    @nonobjc var cacheKey:String?
    @nonobjc var geo:String?
    @nonobjc var parentalRating:String?
    @nonobjc var primaryCategory:String?
    @nonobjc var images: NSMutableSet = NSMutableSet()
    #if os(tvOS)
    @nonobjc var isQueued: Bool?
    #endif
    override func mutableSetValue(forKey key: String) -> NSMutableSet {
        return self.value(forKey: key) as! NSMutableSet
    }
}

extension SFShow {
    
    //MARK - method to create video detail page - video info label(metadata)
    func getShowInfoString() -> String? {
        
        var episodeCount:Int = 0
        var seasonCount: Int = 0
        
        if seasons != nil {
            
            for season in self.seasons! {
                
                if season.episodes != nil {
                    
                    episodeCount += (season.episodes?.count)!
                }
                
                seasonCount += 1
            }
        }
        
        var totalEpisodeCountString:String?

        if seasonCount > 1 {
            
            totalEpisodeCountString = "\(seasonCount) SEASONS"
        }
        else {
            
            if episodeCount > 1 {
                
                totalEpisodeCountString = "\(episodeCount) EPISODES"
            }
            else if episodeCount == 1 {
                
                totalEpisodeCountString = "\(episodeCount) EPISODE"
            }
        }

        let showCategory:String? = self.primaryCategory ?? ""
        
        var showInfoString:String?
        
        if totalEpisodeCountString != nil {

            showInfoString = totalEpisodeCountString
        }

        if showCategory != nil {

            if showInfoString != nil {

                if !(showCategory?.isEmpty)! {
                    showInfoString?.append(" | \(showCategory!.uppercased())")
                }
            }
            else {
                showInfoString = showCategory!.uppercased()
            }
        }
        
        return showInfoString
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
    #endif
}
