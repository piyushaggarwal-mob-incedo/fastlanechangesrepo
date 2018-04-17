//
//  DownloadCourseManager.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class DownloadCourseManager {

    static let sharedInstance:DownloadCourseManager = {
        let instance = DownloadCourseManager()
        return instance
    }()

    func getAllDownloadCourses() -> [DownloadCourseObject] {
        let downloadObjects: [DownloadCourseObject] = getAllDownloadObjects()
        var courseArray = [DownloadCourseObject]()
        for courseObject: DownloadCourseObject in downloadObjects {
            courseArray.append(self.setPriorityToACourse(courseObject))
        }
        var sortDescriptor: NSSortDescriptor?
        sortDescriptor = NSSortDescriptor(key: "coursePriority", ascending: true)

        let sortedCourseArray: [DownloadCourseObject] = (courseArray as NSArray).sortedArray(using: [sortDescriptor!]) as! [DownloadCourseObject]
        return sortedCourseArray
    }

    func removeCourse(fromDownloadedArray courseID: String, withSuccessBlock success: @escaping (_: Void) -> Void, andFailureBlock failure: @escaping (_ error: Error?) -> Void) {
        var courseLectureCount: Int = 0
        let downloadArray: [DownloadObject] = DownloadManager.sharedInstance.getGlobalDownloadObjectsArray()
        for downloadObject: DownloadObject in downloadArray {
            if (courseID == downloadObject.fileCourseID) {
                courseLectureCount += 1
            }
        }
        var ii: Int = 0
        for downloadObject: DownloadObject in downloadArray {
            if (courseID == downloadObject.fileCourseID) {
                DownloadManager.sharedInstance.removeObject(fromDownloadedArray: downloadObject.fileID, withSuccessBlock: {() -> Void in
                    ii += 1
                    if ii == courseLectureCount {
                        success()
                    }
                }, andFailureBlock: {(_ error: Error?) -> Void in
                    failure(error)
                })
            }
        }
    }

    func getAllDownloadObjects() -> [DownloadCourseObject] {
        var coursesArray = [DownloadCourseObject]()
        let downloadArray: [DownloadObject] = DownloadManager.sharedInstance.getGlobalDownloadObjectsArray()
        var courseIDsArray = [Any]()
        for downloadObject: DownloadObject in downloadArray {
            courseIDsArray.append(downloadObject.fileCourseID)
        }
        for ii in 0..<courseIDsArray.count {
            let courseObject = DownloadCourseObject()
            courseObject.courseID = courseIDsArray[ii] as! String
            var lecturesArray = [DownloadObject]()
            for downloadObject: DownloadObject in downloadArray {
                if (downloadObject.fileCourseID == courseObject.courseID) {
                    lecturesArray.append(downloadObject)
                }
            }
            courseObject.lectures = lecturesArray
            coursesArray.append(courseObject)
        }
        for courseObject: DownloadCourseObject in coursesArray {
            courseObject.courseName = ((courseObject.lectures[0] as? DownloadObject)?.fileCourseName)!
        }
        return coursesArray
    }

    func setPriorityToACourse(_ courseObject: DownloadCourseObject) -> DownloadCourseObject {
        var i: Int = 0

        for downloadObject: Any in courseObject.lectures {

            if i < (downloadObject as! DownloadObject).filePriority {
                i = (downloadObject as! DownloadObject).filePriority
            }
        }
        courseObject.coursePriority = i
        return courseObject
    }
}
