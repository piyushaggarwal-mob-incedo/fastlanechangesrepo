//
//  DownloadObject.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

enum downloadObjectState:Int {
    case eDownloadStateInProgress
    case eDownloadStateFinished
    case eDownloadStateError
    case eDownloadStateQueued
    case eDownloadStatePaused
    case eDownloadStateNone
    case eDownloadStateForcePaused
}

class DownloadObject: NSObject {
    /*!
     *@ discussion Property to store stores object's Priority
     */
    var filePriority: Int = 0
    /*!
     *@ discussion Property to store stores object's Name
     */
    var fileName: String = ""
    /*!
     *@ discussion Property to store stores object's ID - will act as an idenetity for download object
     */
    var fileID: String = ""
    /*!
     *@ discussion Property to store Course ID of downloaded lecture/ file
     */
    var fileCourseID: String = ""
    /*!
     *@ discussion Property to store Course Name of downloaded lecture/ file
     */
    var fileCourseName: String = ""
    /*!
     *@ discussion Property to store lecture number of downloaded lecture/ file
     */
    var fileNumber: Int = 0
    /*!
     *@ discussion Property to store priority of lecture's course
     */
    var fileCoursePriority: Int = 0
    /*!
     *@ discussion Property to store stores object's url that will be used to download its content
     */
    var fileUrl: String = ""
    /*!
     *@ discussion Property to store stores object's thumbnail url that will be used to showcase this object.
     */
    var fileImageUrl: String = ""
    var filePosterImageUrl: String = ""
    /*!
     *@ discussion Property to store stores object's Folder Path Name in which this file will be stored.
     */
    var fileFolderUrl: String = ""
    /*!
     *@ discussion Property to store stores object's saved location.
     */
    var filePathUrl: String = ""
    /*!
     *@ discussion Property to store stores object's date-time when obejct last modified/ saved.
     */
    var fileModifiedDateTime: Date?
    /*!
     *@ discussion Property to store stores file's total Length (in Data).
     */
    var fileTotalLength: Double = 0.0
    /*!
     *@ discussion Property to store stores file's Current downloaded Length (in Data).
     */
    var fileCurrentDownloadedLength: Double = 0.0
    /*!
     *@ discussion Property to store stores file's current state of Download.
     */
    var fileDownloadState:downloadObjectState?
    /*!
     *@ discussion Property to store stores file's current state of playback.
     */
    var fileWatchedPercentage: Float = 0.0
    /*!
     *@ discussion Property to store stores file's duration in minutes.
     */
    var fileDurationMinutes: NSNumber?
    /*!
     *@ discussion Property to store stores file's duration in seconds.
     */
    var fileDurationSeconds: NSNumber?
    /*!
     *@ discussion Property to store stores file's description.
     */
    var fileDescription: String = ""
    
    var isFileWatched: Bool = false
    
    var fileBitRate: String = ""
    
    /*!
     *@ discussion Property to ClosedCaption.
     */
    var closedCaptions: NSMutableSet = NSMutableSet()
    var parentalRating: String?
    var credits: NSMutableSet = NSMutableSet()
    var viewerGrade:Double?
    var year: String?
    var primaryCategory:String?
}
