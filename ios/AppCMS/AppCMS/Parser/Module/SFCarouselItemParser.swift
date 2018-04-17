//
//  SFCarouselItemParser.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 04/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFCarouselItemParser: NSObject {

    func parseCarouselItem(carouselObjectDictionary: Dictionary<String, AnyObject>) -> SFCarouselItemObject
    {
        let carouselObject = SFCarouselItemObject()
        
        carouselObject.type = carouselObjectDictionary["type"] as? String
        
        let layoutObjectParser = LayoutObjectParser()
        let layoutDict = carouselObjectDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            carouselObject.layoutObjectDict = layoutObjectDict
        }
        
        return carouselObject
    }
}
