//
//  SFProgressViewParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 23/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFProgressViewParser: NSObject {

    func parseProgressViewJson(progressViewDictionary: Dictionary<String, AnyObject>) -> SFProgressViewObject
    {
        let progressViewObject = SFProgressViewObject()
        
        progressViewObject.type = progressViewDictionary["type"] as? String
        progressViewObject.progressColor = progressViewDictionary["progressColor"] as? String
        progressViewObject.unprogressColor = progressViewDictionary["unprogressColor"] as? String
        
        let layoutDict = progressViewDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            progressViewObject.layoutObjectDict = layoutObjectDict
        }

        return progressViewObject
    }

}
