//
//  AppThemeProvider.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 13/03/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import Foundation

struct RGB {
    var red: Double
    var green: Double
    var blue: Double
}

enum AppTheme {
    case light
    case dark
}

class AppThemeProvider {
    
    class func hexStringToRGB (hex:String) -> RGB {
        
        var cString:String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = cString.substring(from: cString.index(after: cString.startIndex))
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16)
        let green = Double((rgbValue & 0x00FF00) >> 8)
        let blue = Double(rgbValue & 0x0000FF)
        let rgb = RGB(red:red, green:green, blue:blue)
        return rgb
    }
    
    class func getAppTheme(backgroundColorHex: String) -> AppTheme {
        var rgb = AppThemeProvider.hexStringToRGB(hex: backgroundColorHex)
        rgb.red = rgb.red * 0.299
        rgb.green = rgb.green * 0.587
        rgb.blue = rgb.blue * 0.114
        let sum = rgb.red + rgb.green + rgb.blue
        if sum > 186 {
            return AppTheme.light
        } else {
            return AppTheme.dark
        }
    }
}
