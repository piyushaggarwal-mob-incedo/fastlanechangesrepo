//
//  DownloadCourseObject.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class DownloadCourseObject: NSObject {
    /*!
     *@ discussion Property to store object's Priority.
     */
    var coursePriority: Int = 0

    /*!
     *@ discussion Property to store object's Name.
     */
    var courseName: String = ""

    /*!
     *@ discussion Property to store object's ID.
     */
    var courseID: String = ""

    /*!
     *@ discussion Property to store lectures present in course.
     */
    var lectures = [Any]()
}
