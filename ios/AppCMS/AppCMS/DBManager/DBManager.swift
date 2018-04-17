//
//  DBManager.swift
//  AppCMS
//
//  Created by Gaurav Vig on 09/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
#if os(iOS)
import MagicalRecord
#endif
class DBManager: NSObject {

    static let sharedInstance:DBManager = {
        
        let instance = DBManager()
        
        return instance
    }()
    
    
    func updateDatabaseWithFilmObject(filmObject:SFFilm) -> Bool {
        
        var isDBUpdated:Bool = false
        
        var managedFilm:SFManagedFilm? = checkIfFilmExistInDb(filmId: filmObject.id!)
        
        if managedFilm == nil {
            #if os(iOS)
            managedFilm = SFManagedFilm.mr_createEntity()
            #endif
        }
        
        if filmObject.title != nil {
            managedFilm?.title = filmObject.title!
        }
        
        if filmObject.durationMinutes != nil {
            
            managedFilm?.durationMinutes = filmObject.durationMinutes!
        }
        
        if filmObject.durationSeconds != nil {
            
            managedFilm?.durationSeconds = filmObject.durationSeconds!
        }
        
        if filmObject.episodeNumber != nil {
            
            managedFilm?.episodeNumber = filmObject.episodeNumber!
        }
        
        if filmObject.seasonNumber != nil {
            
            managedFilm?.seasonNumber = filmObject.seasonNumber!
        }
        
        if filmObject.sequence != nil {
            
            managedFilm?.sequence = filmObject.sequence!
        }
        
        if filmObject.year != nil {
            
            managedFilm?.year = filmObject.year!
        }
        
        if filmObject.geo != nil {
            
            managedFilm?.geo = filmObject.geo!
        }
        
        if filmObject.id != nil {
            
            managedFilm?.id = filmObject.id!
        }
        
        if filmObject.parentalRating != nil {
            
            managedFilm?.parentalRating = filmObject.parentalRating!
        }
        
        if filmObject.permaLink != nil {
            
            managedFilm?.permaLink = filmObject.permaLink!
        }
        
        if filmObject.primaryCategory != nil {
            
            managedFilm?.primaryCategory = filmObject.primaryCategory!
        }
        
        if filmObject.seasonName != nil {
            
            managedFilm?.seasonName = filmObject.seasonName!
        }
        
        if filmObject.secondaryCategory != nil {
            
            managedFilm?.secondaryCategory = filmObject.secondaryCategory!
        }
        
        if filmObject.showId != nil {
            
            managedFilm?.showId = filmObject.showId!
        }
        
        if filmObject.showTitle != nil {
            
            managedFilm?.showTitle = filmObject.showTitle!
        }
        
        if filmObject.tags != nil {
            
            managedFilm?.tags = filmObject.tags!
        }
        
        if filmObject.userGrade != nil {
            
            managedFilm?.userGrade = filmObject.userGrade!
        }
        
        if filmObject.viewerGrade != nil {
            
            managedFilm?.viewerGrade = filmObject.viewerGrade!
        }
        
        if filmObject.isHd != nil {
            
            managedFilm?.isHd = filmObject.isHd!
        }
        
        if filmObject.isLiveStream != nil {
            
            managedFilm?.isLiveStream = filmObject.isLiveStream!
        }
        
        if filmObject.addedDate != nil {
            
            managedFilm?.addedDate = filmObject.addedDate!
        }
        
        if filmObject.cacheDate != nil {
            
            managedFilm?.cacheDate = filmObject.cacheDate!
        }
        
        if filmObject.publishDate != nil {
            
            managedFilm?.publishDate = filmObject.publishDate!
        }
        
        if filmObject.type != nil {
            
            managedFilm?.type = filmObject.type!
        }
        
        managedFilm?.closedCaptions = filmObject.closedCaptions
        managedFilm?.credits = filmObject.credits
        managedFilm?.images = filmObject.images
        managedFilm?.professors = filmObject.professors
        managedFilm?.relatedCourses = filmObject.relatedCourses
        
        #if os(iOS)
        Constants.kMOC.perform {
            
            Constants.kMOC.mr_save(options: MRSaveOptions.synchronously, completion: { (isSaved, error) in
                isDBUpdated = isSaved
            })
//            Constants.kMOC.save(options: [MRSaveOptions.synchronously,MRSaveOptions.parentContexts], completion: { (isSaved, error) in
//                
//                isDBUpdated = isSaved
//            })
        }
        #endif
        
        return isDBUpdated
    }

    
    func checkIfFilmExistInDb(filmId:String) -> SFManagedFilm? {
        
        #if os(iOS)
        let filmObjectPredicate:NSPredicate = NSPredicate(format: "id == %@",filmId)
        let filmObjectArray:Array<AnyObject> = SFManagedFilm.mr_findAll(with: filmObjectPredicate)!
        
        var filmObject:SFManagedFilm?
        if filmObjectArray.count > 0 {
            
            filmObject = filmObjectArray.last as? SFManagedFilm
        }
        
        return filmObject
        #endif
        return nil
    }
    
    
    func fetchFilmObjectFromDatabase(filmId:String) -> SFFilm {

        let filmObject = SFFilm()

        #if os(iOS)
        let filmObjectPredicate:NSPredicate = NSPredicate(format: "id == %@",filmId)
        let filmObjectArray:Array<AnyObject>? = SFManagedFilm.mr_findAll(with: filmObjectPredicate)!

        let managedFilm:SFManagedFilm? = filmObjectArray?.last as? SFManagedFilm
            
        if managedFilm?.title != nil {
            filmObject.title = managedFilm?.title
        }
        
        if managedFilm?.durationMinutes != nil {
            
            filmObject.durationMinutes = managedFilm?.durationMinutes
        }
        
        if managedFilm?.durationSeconds != nil {
            
            filmObject.durationSeconds = managedFilm?.durationSeconds
        }
        
        if managedFilm?.episodeNumber != nil {
            
            filmObject.episodeNumber = managedFilm?.episodeNumber
        }
        
        if managedFilm?.seasonNumber != nil {
            
            filmObject.seasonNumber = managedFilm?.seasonNumber
        }
        
        if managedFilm?.sequence != nil {
            
            filmObject.sequence = managedFilm?.sequence
        }
        
        if managedFilm?.year != nil {
            
            filmObject.year = managedFilm?.year
        }
        
        if managedFilm?.geo != nil {
            
            filmObject.geo = managedFilm?.geo
        }
        
        if managedFilm?.id != nil {
            
            filmObject.id = managedFilm?.id
        }
        
        if managedFilm?.parentalRating != nil {
            
            filmObject.parentalRating = managedFilm?.parentalRating
        }
        
        if managedFilm?.permaLink != nil {
            
            filmObject.permaLink = managedFilm?.permaLink
        }
        
        if managedFilm?.primaryCategory != nil {
            
            filmObject.primaryCategory = managedFilm?.primaryCategory
        }
        
        if managedFilm?.seasonName != nil {
            
            filmObject.seasonName = managedFilm?.seasonName
        }
        
        if managedFilm?.secondaryCategory != nil {
            
            filmObject.secondaryCategory = managedFilm?.secondaryCategory
        }
        
        if managedFilm?.showId != nil {
            
            filmObject.showId = managedFilm?.showId
        }
        
        if managedFilm?.showTitle != nil {
            
            filmObject.showTitle = managedFilm?.showTitle
        }
        
        if managedFilm?.tags != nil {
            
            filmObject.tags = managedFilm?.tags
        }
        
        if managedFilm?.userGrade != nil {
            
            filmObject.userGrade = managedFilm?.userGrade
        }
        
        if managedFilm?.viewerGrade != nil {
            
            filmObject.viewerGrade = managedFilm?.viewerGrade
        }
        
        if managedFilm?.isHd != nil {
            
            filmObject.isHd = managedFilm?.isHd
        }
        
        if managedFilm?.isLiveStream != nil {
            
            filmObject.isLiveStream = managedFilm?.isLiveStream
        }
        
        if managedFilm?.addedDate != nil {
            
            filmObject.addedDate = managedFilm?.addedDate
        }
        
        if managedFilm?.cacheDate != nil {
            
            filmObject.cacheDate = managedFilm?.cacheDate
        }
        
        if managedFilm?.publishDate != nil {
            
            filmObject.publishDate = managedFilm?.publishDate
        }
        
        if managedFilm?.type != nil {
            
            filmObject.type = managedFilm?.type
        }
        
        filmObject.closedCaptions = managedFilm?.closedCaptions as! NSMutableSet
        filmObject.credits = managedFilm?.credits as! NSMutableSet
        filmObject.images = managedFilm?.images as! NSMutableSet
        filmObject.professors = managedFilm?.professors as! NSMutableSet
        filmObject.relatedCourses = managedFilm?.relatedCourses as! NSMutableSet
        #endif
        return filmObject
    }
    
    
    func deleteFilmObjectFromDatabase(filmId:String) -> Bool {
        
        let isFilmDeleted:Bool = false
        
        return isFilmDeleted
    }
}
