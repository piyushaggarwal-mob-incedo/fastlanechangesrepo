//
//  String+TimeFormatter.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 03/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension Double {
    
    func timeFormattedString(interval: Double) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%2d:%02d:%02d", hours, minutes, seconds)
    }
    
    func articleTimeFormattedString(interval: Int) -> String {
        
        return "\(interval)min"
    }
}
