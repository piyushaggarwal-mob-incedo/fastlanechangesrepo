//
//  VideoObject.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 03/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class VideoObject: NSObject {

    var videoTitle: String?
    var videoContentId: String?
    var videoPlayerDuration: Double?
    var videoWatchedTime:Double?
    var videoDescription : String?
    var gridPermalink: String?
    var thumbnailImageUrlString: String?
    var subtitleStringUrl: String?
    var videoType : String?
    var videoContentRating : String?
    
    init(gridObject: SFGridObject) {
        self.videoTitle = gridObject.contentTitle ?? ""
        self.videoPlayerDuration = gridObject.totalTime ?? 0
        self.videoContentId = gridObject.contentId ?? ""
        self.gridPermalink = gridObject.gridPermaLink ?? ""
        self.videoWatchedTime = gridObject.watchedTime ?? 0
        self.videoDescription = gridObject.contentDescription ?? ""
        self.thumbnailImageUrlString = gridObject.thumbnailImageURL ?? ""
        self.videoType = gridObject.contentType ?? ""
        self.videoContentRating = gridObject.parentalRating ?? ""
        super.init()
    }
    
    init(filmObject: SFFilm) {
        self.videoTitle = filmObject.title ?? ""
        self.videoPlayerDuration = Double(filmObject.durationSeconds ?? 0)
        self.videoContentId = filmObject.id ?? ""
        self.gridPermalink = filmObject.permaLink ?? ""
        self.videoWatchedTime = Double(filmObject.filmWatchedDuration ?? 0)
        self.videoDescription = filmObject.desc ?? ""
        self.thumbnailImageUrlString = filmObject.thumbnailImageURL
        self.videoType = filmObject.type ?? ""
        self.videoContentRating = filmObject.parentalRating ?? ""
        super.init()
    }
    
    func update(filmObject: SFFilm) {
        self.videoTitle = filmObject.title ?? ""
        self.videoPlayerDuration = Double(filmObject.durationSeconds ?? 0)
        self.videoContentId = filmObject.id ?? ""
        self.gridPermalink = filmObject.permaLink ?? ""
        self.videoWatchedTime = Double(filmObject.filmWatchedDuration ?? 0)
        self.videoDescription = filmObject.desc ?? ""
        self.thumbnailImageUrlString = filmObject.thumbnailImageURL
        self.videoType = filmObject.type ?? ""
        self.videoContentRating = filmObject.parentalRating ?? ""
    }
}
