//
//  SFVerticalArticleViewObject.swift
//  AppCMS
//
//  Created by Gaurav Vig on 25/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import UIKit

struct SFVerticalArticleViewSettings {
    
    enum ImagePlacement {
        
        case left
        case right
        case alternate
    }
    
    enum ContentAlignment {
        
        case center
        case left
        case right
    }
    
    var contentAlignment:ContentAlignment?
    var adTag:String?
    var isInfiniteScroll:Bool?
    var adDisplayFrequency:Int?
    var imagePlacement:ImagePlacement?
    var thumbnailType:String?
    var displaySubHeading:Bool?
    
    init(settingsDict:Dictionary<String, AnyObject>) {
        
        adTag = settingsDict["adTag"] as? String
        isInfiniteScroll = settingsDict["infiniteScroll"] as? Bool
        adDisplayFrequency = settingsDict["adFrequency"] as? Int
        thumbnailType = settingsDict["thumbnailType"] as? String
        displaySubHeading = settingsDict["subheading"] as? Bool
        
        if let contentAlignment = settingsDict["contentAlignment"] as? String {
            
            switch contentAlignment {
                
            case "center":
                self.contentAlignment = ContentAlignment.center
                break
                
            case "right":
                self.contentAlignment = ContentAlignment.right
                break
                
            case "left":
                self.contentAlignment = ContentAlignment.left
                break
                
            default:
                self.contentAlignment = ContentAlignment.left
                break
            }
        }
        
        if let imagePlacement = settingsDict["imagePlacement"] as? String {
            
            switch imagePlacement {
                
            case "alternate":
                self.imagePlacement = ImagePlacement.alternate
                break
                
            case "right":
                self.imagePlacement = ImagePlacement.right
                break
                
            case "left":
                self.imagePlacement = ImagePlacement.left
                break
                
            default:
                self.imagePlacement = ImagePlacement.left
                break
            }
        }
    }
}

class SFVerticalArticleViewObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var key:String?
    var type:String?
    var components:Array<Any> = []
    var blockName:String?
    var moduleId:String?
    var settings:SFVerticalArticleViewSettings?
}
