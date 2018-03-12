//
//  SFVideoDetailModuleParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 23/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFVideoDetailModuleParser: NSObject {

    func parseVideoDetailModuleJson(videoDetailModuleDictionary: Dictionary<String, AnyObject>) -> SFVideoDetailModuleObject
    {
        let videoModuleObject = SFVideoDetailModuleObject()
        
        videoModuleObject.moduleID = videoDetailModuleDictionary["id"] as? String
        videoModuleObject.moduleType = videoDetailModuleDictionary["view"] as? String
        videoModuleObject.moduleTitle = videoDetailModuleDictionary["title"] as? String
        videoModuleObject.isInlineVideoPlayer = false

        let settingsDict = videoDetailModuleDictionary["settings"] as? Dictionary<String, AnyObject>
        
        if settingsDict != nil {
            
            if let inlineVideoPlayer = settingsDict!["inlineVideoPlayer"] as? Bool {
                
                videoModuleObject.isInlineVideoPlayer = inlineVideoPlayer
            }
        }
        
        if DEBUGMODE {
            var filePath:String
            filePath = (Bundle.main.resourcePath?.appending("/VideoDetail_AppleTV.json"))!
            if FileManager.default.fileExists(atPath: filePath){
                let jsonData:Data = FileManager.default.contents(atPath: filePath)!
                let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, AnyObject>
                let layoutDict = responseJson["layout"] as? Dictionary<String, Any>
                let componentArray = responseJson["components"] as? Array<Dictionary<String, AnyObject>>
                if componentArray != nil {
                    videoModuleObject.videoDetailModuleComponents = componentConfigArray(componentsArray: componentArray!)
                }
                
                let layoutObjectParser = LayoutObjectParser()
                videoModuleObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            }
        } else {
            
            let blockName:String? = videoDetailModuleDictionary["blockName"] as? String
            
            if blockName != nil {
                
                if PageUIBlocks.sharedInstance.blockComponents != nil {
                    let pageBlockComponentDict = PageUIBlocks.sharedInstance.blockComponents![blockName!] as? Dictionary<String, Any>
                    
                    if pageBlockComponentDict != nil {
                        
                        if pageBlockComponentDict?["components"] != nil {
                            
                            videoModuleObject.videoDetailModuleComponents = pageBlockComponentDict?["components"] as? Array<AnyObject>
                        }
                        
                        if pageBlockComponentDict?["layout"] != nil {
                            
                            videoModuleObject.layoutObjectDict = pageBlockComponentDict?["layout"] as! Dictionary<String, LayoutObject>
                        }
                    }
                }
            }
            
            if videoModuleObject.videoDetailModuleComponents == nil || videoModuleObject.videoDetailModuleComponents?.count == 0 {
                
                let componentArray = videoDetailModuleDictionary["components"] as? Array<Dictionary<String, AnyObject>>
                
                if componentArray != nil {
                    
                    let componentsUIParser = ComponentUIParser()
                    videoModuleObject.videoDetailModuleComponents = componentsUIParser.componentConfigArray(componentsArray: componentArray!)
                }
            }
            
            if videoModuleObject.layoutObjectDict.count == 0 {
                
                let layoutObjectParser = LayoutObjectParser()
                videoModuleObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: videoDetailModuleDictionary["layout"] as! Dictionary<String, Any>)
            }
        }
        
        return videoModuleObject
    }
    
    
    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {
        
        var componentArray:Array<AnyObject> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == "button"
            {
                let buttonParser = SFButtonParser()
                let buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(buttonObject)
            }
            else if typeOfModule == "image" || typeOfModule == "imageView"
            {
                let imageParser = SFImageParser()
                let imageObject = imageParser.parseImageJson(imageDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(imageObject)
            }
            else if typeOfModule == "label"
            {
                let labelParser = SFLabelParser()
                let labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(labelObject)
            }
            else if typeOfModule == "textView"
            {
                let textViewParser = SFTextViewParser()
                let textViewObject = textViewParser.parseTextViewJson(textViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(textViewObject)
            }
            else if typeOfModule == "separatorView"
            {
                let separatorViewParser = SFSeparatorViewParser()
                let separatorViewObject = separatorViewParser.parseSeparatorViewJson(separatorViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(separatorViewObject)
            }
            else if typeOfModule == "starRating"
            {
                 #if os(iOS)
                    let ratingViewParser = SFStarRatingParser()
                let ratingViewObject = ratingViewParser.parseStarRatingJson(starRatingDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(ratingViewObject)
                #endif
            }
            else if typeOfModule == "castView" {
                
                let castViewParser = SFCastViewParser()
                let castViewObject = castViewParser.parseCastViewJson(castViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(castViewObject)
            }
            else if typeOfModule == "progressView"
            {
                let progressViewParser = SFProgressViewParser()
                let progressViewObject = progressViewParser.parseProgressViewJson(progressViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(progressViewObject)
            }
            else if typeOfModule == "headerView"
            {
                #if os(tvOS)
                let headerViewParser = SFHeaderViewParser()
                let headerViewObject = headerViewParser.parseLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(headerViewObject)
                #endif
            }
            else if typeOfModule == "videoView"
            {
                let videoViewParser = VideoPlayerParser()
                let videoPlayerUIObject = videoViewParser.parseVideoPlayerJson(videoPlayerDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(videoPlayerUIObject)
            }
        }
        return componentArray
    }
}
