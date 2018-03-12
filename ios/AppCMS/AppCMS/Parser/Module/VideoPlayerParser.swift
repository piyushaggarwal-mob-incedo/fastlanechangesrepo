//
//  VideoPlayerParser.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 19/12/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class VideoPlayerParser: NSObject {
    func parseVideoPlayerJson(videoPlayerDictionary: Dictionary<String, AnyObject>) -> VideoUIObject
    {
        let videoUIObject = VideoUIObject()
        
        videoUIObject.type = videoPlayerDictionary["type"] as? String
        videoUIObject.key = videoPlayerDictionary["key"] as? String
        let layoutDict = videoPlayerDictionary["layout"] as? Dictionary<String, Any>
        if layoutDict != nil {
            
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            videoUIObject.layoutObjectDict = layoutObjectDict
        }
        
        return videoUIObject
    }
}
