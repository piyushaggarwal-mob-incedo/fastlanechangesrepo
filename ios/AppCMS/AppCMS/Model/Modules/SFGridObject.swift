//
//  SFGridObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 01/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFGridObject: NSObject {

    var contentType:String?
    var contentId:String?
    var contentImage:SFManagedImage?
    var contentTitle:String?
    var thumbnailImageURL:String?
    var posterImageURL: String?
    var watchedTime:Double?
    var totalTime:Double?
    var gridPermaLink:String?
    var year:String?
    var videoCategory:String?
    var numberOfSeasons:String?
    var contentDescription: String?
    var updatedDate:Double?
    var totalSize:Double?
    var isDownloadComplete:Bool?
    var parentalRating:String?
    var isFreeVideo:Bool?
    var images: NSMutableSet = NSMutableSet()
    var publishedDate: Double?
    var eventId:String?
    var isLiveStream:Bool?
    var viewerGrade:Double?
}

extension SFGridObject {
    
    func getVideoInfoString() -> String? {
        
        let videoDurationInMinutes:Int = Int(self.totalTime ?? 0) / 60
        
        var videoDurationValue:String?
        
        if videoDurationInMinutes > 1 {
            
            videoDurationValue = "\(videoDurationInMinutes) MINS"
        }
        else if videoDurationInMinutes == 1 {
            
            videoDurationValue = "\(videoDurationInMinutes) MIN"
        }
        else if videoDurationInMinutes > 0 && videoDurationInMinutes < 1 {
            
            videoDurationValue = "\(videoDurationInMinutes) SECS"
        }
        else if videoDurationInMinutes == 0 {
            
            videoDurationValue = "\(videoDurationInMinutes) SEC"
        }
        
        let videoYear:String? = self.year
        
        var videoInfoString:String?
        
        if videoDurationValue != nil {
            
            videoInfoString = videoDurationValue
        }
        
        if videoYear != nil {
            
            if videoInfoString != nil {
                videoInfoString?.append(" | \(videoYear!)")
            }
            else {
                videoInfoString = videoYear!
            }
        }
        
        return videoInfoString
    }
}
