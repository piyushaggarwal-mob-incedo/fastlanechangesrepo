//
//  Date+StringComponents.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 06/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension Date {
    
    func getMonthName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }
    
    func getDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    func getYearString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
