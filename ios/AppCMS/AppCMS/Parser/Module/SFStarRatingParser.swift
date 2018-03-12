//
//  SFStarRatingParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 28/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFStarRatingParser: NSObject {

    func parseStarRatingJson(starRatingDictionary: Dictionary<String, AnyObject>) -> SFStarRatingObject
    {
        let starRatingObject = SFStarRatingObject()
        
        starRatingObject.type = starRatingDictionary["type"] as? String
        starRatingObject.action = starRatingDictionary["action"] as? String
        starRatingObject.keyName = starRatingDictionary["key"] as? String
        starRatingObject.fillColor = starRatingDictionary["fillColor"] as? String
        starRatingObject.fillBorderColor = starRatingDictionary["borderColor"] as? String
        starRatingObject.clearBorderColor = starRatingDictionary["borderColor"] as? String
        starRatingObject.clearColor = starRatingDictionary["fillColor"] as? String
        starRatingObject.margin = starRatingDictionary["star-margin"] as? Double
        starRatingObject.starSize = starRatingDictionary["starSize"] as? Double
        
        let layoutDict = starRatingDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            starRatingObject.layoutObjectDict = layoutObjectDict
        }
        return starRatingObject
    }
}
