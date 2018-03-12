//
//  SFCountryDialParser.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 30/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFCountryDialParser: NSObject {
    
    //MARK: Method to parse Page Content
    func parseCountryDialCodes(countryDialContentJsonArray:Array<AnyObject>) -> Array<SFCountryDialModel>{
        
        var countryCodeArray: Array<SFCountryDialModel> = Array()
        
        for countryDialCodeDictionary in countryDialContentJsonArray {
            let countryDictionary: Dictionary = countryDialCodeDictionary as! Dictionary<String, Any>
            let countryDialObject: SFCountryDialModel = SFCountryDialModel()
            countryDialObject.countryCode = countryDictionary ["code"] as? String 
            countryDialObject.countryName = countryDictionary["name"] as? String
            countryDialObject.countryDialCode = countryDictionary["dial_code"] as? String
            
            countryCodeArray.append(countryDialObject)
        }
        
        return countryCodeArray
    }
}
