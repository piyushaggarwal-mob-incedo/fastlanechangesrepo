//
//  ModuleAPIParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 01/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ModuleAPIParser: NSObject {

    //MARK: Method to parse page modules components
    func parseModuleContentData(moduleContentDict:Dictionary<String, AnyObject>) -> SFGridObject{
        
        let gridObject = SFGridObject()
        
        let gistDict:Dictionary<String, AnyObject>? = moduleContentDict["gist"] as? Dictionary<String, AnyObject>
        
        if gistDict != nil {
            
            gridObject.contentTitle = gistDict?["title"] as? String
            gridObject.contentId = gistDict?["id"] as? String
            gridObject.contentType = gistDict?["contentType"] as? String
            gridObject.thumbnailImageURL = gistDict?["videoImageUrl"] as? String
            gridObject.posterImageURL = gistDict?["posterImageUrl"] as? String
            gridObject.totalTime = gistDict?["runtime"] as? Double
            gridObject.watchedTime = gistDict?["watchedTime"] as? Double
            gridObject.gridPermaLink = gistDict?["permalink"] as? String
            gridObject.contentDescription = gistDict?["description"] as? String
            gridObject.parentalRating = moduleContentDict["parentalRating"] as? String
            gridObject.isFreeVideo = gistDict?["free"] as? Bool
            gridObject.publishedDate = gistDict?["publishDate"] as? Double
            gridObject.eventId = gistDict?["kisweEventId"] as? String
            gridObject.isLiveStream = gistDict?["isLiveStream"] as? Bool
            gridObject.viewerGrade = gistDict?["averageStarRating"] as? Double

            if gistDict?["imageGist"] != nil || gistDict?["badgeImages"] != nil {
                
                let imageSet = self.parseImageGist(imageGistDict: gistDict?["imageGist"] as? Dictionary<String, AnyObject>, badgeImageGist: gistDict?["badgeImages"] as? Dictionary<String, AnyObject>)
                
                if imageSet.count > 0 {
                    
                    gridObject.images = imageSet
                }
            }
            
            if gridObject.contentDescription != nil {
                
                let attributedText:NSAttributedString = NSAttributedString.init(string: gridObject.contentDescription!, attributes: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8])
                
                gridObject.contentDescription = attributedText.string.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
            }
            
            gridObject.updatedDate = gistDict?["updateDate"] as? Double
            
            let primaryCategoryDict:Dictionary<String, AnyObject>? = gistDict?["primaryCategory"] as? Dictionary<String, AnyObject>
            
            gridObject.videoCategory = primaryCategoryDict?["title"] as? String
            gridObject.year = gistDict?["year"] as? String
        }
        return gridObject
    }
    
    
    //MARK: Method to parse image
    private func parseImageGist(imageGistDict:Dictionary<String, AnyObject>?, badgeImageGist:Dictionary<String, AnyObject>?) -> NSMutableSet {
        
        let imageSet:NSMutableSet = NSMutableSet()

        if imageGistDict != nil || badgeImageGist != nil {
            
            if fetchImageUrlFromImageType(imageType: Constants.kSTRING_IMAGETYPE_32x9, imageGistDict: imageGistDict, badgeImageGist: badgeImageGist) != nil {
                
                imageSet.add(fetchImageUrlFromImageType(imageType: Constants.kSTRING_IMAGETYPE_32x9, imageGistDict: imageGistDict, badgeImageGist: badgeImageGist)!)
            }
            
            if fetchImageUrlFromImageType(imageType: Constants.kSTRING_IMAGETYPE_16x9, imageGistDict: imageGistDict, badgeImageGist: badgeImageGist) != nil {
                
                imageSet.add(fetchImageUrlFromImageType(imageType: Constants.kSTRING_IMAGETYPE_16x9, imageGistDict: imageGistDict, badgeImageGist: badgeImageGist)!)
            }
            
            if fetchImageUrlFromImageType(imageType: Constants.kSTRING_IMAGETYPE_3x4, imageGistDict: imageGistDict, badgeImageGist: badgeImageGist) != nil {
                
                imageSet.add(fetchImageUrlFromImageType(imageType: Constants.kSTRING_IMAGETYPE_3x4, imageGistDict: imageGistDict, badgeImageGist: badgeImageGist)!)
            }
            
            if fetchImageUrlFromImageType(imageType: Constants.kSTRING_IMAGETYPE_4x3, imageGistDict: imageGistDict, badgeImageGist: badgeImageGist) != nil {
                
                imageSet.add(fetchImageUrlFromImageType(imageType: Constants.kSTRING_IMAGETYPE_4x3, imageGistDict: imageGistDict, badgeImageGist: badgeImageGist)!)
            }
            
            if fetchImageUrlFromImageType(imageType: Constants.kSTRING_IMAGETYPE_1x1, imageGistDict: imageGistDict, badgeImageGist: badgeImageGist) != nil {
                
                imageSet.add(fetchImageUrlFromImageType(imageType: Constants.kSTRING_IMAGETYPE_1x1, imageGistDict: imageGistDict, badgeImageGist: badgeImageGist)!)
            }
        }
        
        return imageSet
    }
    
    
    private func fetchImageUrlFromImageType(imageType:String, imageGistDict:Dictionary<String, AnyObject>?, badgeImageGist:Dictionary<String, AnyObject>?) -> SFImage? {
        
        var imageObject:SFImage?
        
        if imageGistDict?[imageType] != nil || badgeImageGist?[imageType] != nil {
            
            let imageUrl = imageGistDict?[imageType] as? String
            
            if imageUrl != nil {
                
                imageObject = SFImage()
                
                switch imageType {
                    
                    case Constants.kSTRING_IMAGETYPE_32x9:
                        imageObject?.imageType = Constants.kSTRING_IMAGETYPE_BANNER
                        break
                    
                    case Constants.kSTRING_IMAGETYPE_16x9:
                        imageObject?.imageType = Constants.kSTRING_IMAGETYPE_VIDEO
                        break
                    
                    case Constants.kSTRING_IMAGETYPE_3x4:
                        imageObject?.imageType = Constants.kSTRING_IMAGETYPE_POSTER
                        break
                    
                    case Constants.kSTRING_IMAGETYPE_4x3:
                        imageObject?.imageType = Constants.kSTRING_IMAGETYPE_WIDGET
                        break
                    
                    case Constants.kSTRING_IMAGETYPE_1x1:
                        imageObject?.imageType = Constants.kSTRING_IMAGETYPE_SQUARE
                        break
                    
                    default:
                        break
                }
                
                imageObject?.imageSource = imageUrl
            }
            
            if badgeImageGist != nil {
                
                if imageObject == nil {
                    
                    imageObject = SFImage()
                }
                imageObject = self.parseBadgeImageGist(badgeImageGistDict: badgeImageGist, imageObject: imageObject!)
            }
        }
        
        return imageObject
    }
    
    
    //MARK: Method to parse bage image
    private func parseBadgeImageGist(badgeImageGistDict:Dictionary<String, AnyObject>?, imageObject:SFImage) -> SFImage {
        
        if imageObject.imageType == Constants.kSTRING_IMAGETYPE_VIDEO {
            
            if badgeImageGistDict?[Constants.kSTRING_IMAGETYPE_16x9] != nil {
                
                imageObject.badgeImageUrl = badgeImageGistDict?[Constants.kSTRING_IMAGETYPE_16x9] as? String
            }
        }
        else if imageObject.imageType == Constants.kSTRING_IMAGETYPE_BANNER {
            
            if badgeImageGistDict?[Constants.kSTRING_IMAGETYPE_32x9] != nil {
                
                imageObject.badgeImageUrl = badgeImageGistDict?[Constants.kSTRING_IMAGETYPE_32x9] as? String
            }
        }
        else if imageObject.imageType == Constants.kSTRING_IMAGETYPE_POSTER {
            
            if badgeImageGistDict?[Constants.kSTRING_IMAGETYPE_3x4] != nil {
                
                imageObject.badgeImageUrl = badgeImageGistDict?[Constants.kSTRING_IMAGETYPE_3x4] as? String
            }
        }
        else if imageObject.imageType == Constants.kSTRING_IMAGETYPE_WIDGET {
            
            if badgeImageGistDict?[Constants.kSTRING_IMAGETYPE_4x3] != nil {
                
                imageObject.badgeImageUrl = badgeImageGistDict?[Constants.kSTRING_IMAGETYPE_4x3] as? String
            }
        }
        else if imageObject.imageType == Constants.kSTRING_IMAGETYPE_SQUARE {
            
            if badgeImageGistDict?[Constants.kSTRING_IMAGETYPE_1x1] != nil {
                
                imageObject.badgeImageUrl = badgeImageGistDict?[Constants.kSTRING_IMAGETYPE_1x1] as? String
            }
        }
        
        return imageObject
    }
    
    
    //MARK: Method to parse Film Urls
    func parseFilmURLsData(filmURLContentJson:Dictionary<String, AnyObject>?) -> Dictionary<String, AnyObject> {
        
        var filmUrlDict:Dictionary<String, AnyObject> = [:]
        
        if filmURLContentJson?["videoAssets"] != nil {
            
           filmUrlDict["videoUrl"] = parseVideoAssetDict(videoAssetDict: filmURLContentJson?["videoAssets"] as? Dictionary<String, AnyObject>) as AnyObject
        }
        
        if filmURLContentJson?["audioAssets"] != nil {
            
            filmUrlDict["audioUrl"] = parseVideoAssetDict(videoAssetDict: filmURLContentJson?["videoAssets"] as? Dictionary<String, AnyObject>) as AnyObject
        }
        
        if filmURLContentJson?["articleAssets"] != nil {
            if let url = parseArticleDict(articleAssetDict: filmURLContentJson?["articleAssets"] as? Dictionary<String, AnyObject>){
                filmUrlDict["articleUrl"] = url as AnyObject
            }
        }
        
        filmUrlDict["isLiveStream"] = filmURLContentJson?["isLiveStream"]
        
        return filmUrlDict
    }
    
    
    //MARK: Method to parse Film Gist component
    func parseFilmGistData(filmGistJson:Dictionary<String, AnyObject>?) -> Bool {
        
        var isFreeVideo:Bool = true
        
        let freeVideoValue:Bool? = filmGistJson?["free"] as? Bool
        
        if freeVideoValue != nil {
            
            isFreeVideo = freeVideoValue!
        }
        
        return isFreeVideo
    }
    
    
    //MARK: Method to parse film images
    func parseFilmImages(filmGistJson:Dictionary<String, AnyObject>?) -> Dictionary<String, String>? {
        
        if filmGistJson?["imageGist"] != nil {
            
            let imageSet = self.parseImageGist(imageGistDict: filmGistJson?["imageGist"] as? Dictionary<String, AnyObject>, badgeImageGist: nil)
            
            if imageSet.count > 0 {
                
                //gridObject.images = imageSet
            }
        }
        
        let posterImageURL:String? = filmGistJson?["posterImageUrl"] as? String
        let videoImageURL:String? = filmGistJson?["videoImageUrl"] as? String
        
        var imageURLDict:Dictionary<String, String>?
        
        if posterImageURL != nil {
            
            if imageURLDict == nil {
                
                imageURLDict = [:]
            }
            
            imageURLDict?["posterImage"] = posterImageURL!
        }
        
        if videoImageURL != nil {
            
            if imageURLDict == nil {
                
                imageURLDict = [:]
            }
            
            imageURLDict?["videoImage"] = videoImageURL!
        }
        
        return imageURLDict
    }
    
    
    //MARK: Method to parse Film SubTitle Urls
    func parseFilmSUbTitleURLsData(filmURLContentJson:Dictionary<String, AnyObject>?) -> Dictionary<String, AnyObject> {
        
        var filmUrlSubTitleDict:Dictionary<String, AnyObject> = [:]
        filmUrlSubTitleDict["closedCaptions"] = filmURLContentJson?["closedCaptions"]
        return filmUrlSubTitleDict
    }

    
    //MARK: Method to parse Film SubTitle Urls
    func parseRelatedVideoIdsData(relatedVideoJson:Dictionary<String, AnyObject>?) -> Array<Any>? {
        
        let relatedVideoIdsArray:Array<Any>? = relatedVideoJson?["relatedVideoIds"] as? Array<Any>
        return relatedVideoIdsArray
    }
    
    //MARKLMethod to parse Article dictionary
    func parseArticleDict(articleAssetDict:Dictionary<String, AnyObject>?) -> String? {
        
        let url : String? = articleAssetDict?["url"] as? String 
        return url
    }
    
    //MARK: Method to parse video/audio assets dictionary
    func parseVideoAssetDict(videoAssetDict:Dictionary<String, AnyObject>?) -> Dictionary<String, AnyObject>? {
        
        let hlsURL = videoAssetDict?["hls"]
        
        var assetDict:Dictionary<String, AnyObject>?
        
        if hlsURL != nil {
            
            if assetDict == nil {
                
                assetDict = [:]
            }
            
            assetDict?["hlsUrl"] = hlsURL
        }
        
        let renditionUrls:Array<AnyObject>? = videoAssetDict?["mpeg"] as? Array<AnyObject>
        
        if renditionUrls != nil && (renditionUrls?.count)! > 0 {
            
            var renditionUrlArray:Array<AnyObject> = []
            
            for rendentionDict in renditionUrls! {
                
                renditionUrlArray.append(parseRenditionURLs(renditionUrlDict: rendentionDict as! Dictionary<String, AnyObject>) as AnyObject)
            }
            
            if renditionUrlArray.count > 0 {
                
                if assetDict == nil {
                    
                    assetDict = [:]
                }
                
                assetDict?["renditionUrl"] = renditionUrlArray as AnyObject
            }
        }
        
        return assetDict
    }
    
    
    //MARK: Method to parse Rendition Urls
    func parseRenditionURLs(renditionUrlDict:Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject>{
        
        var renditionDict:Dictionary<String, AnyObject> = [:]
        
        renditionDict["bitrate"] = renditionUrlDict["renditionValue"]
        renditionDict["renditionUrl"] = renditionUrlDict["url"]
        
        return renditionDict
    }
    
    
    //MARK: Method to parse Video Content Data
    func parseFilmContentData(filmContentDict:Dictionary<String, AnyObject>) -> SFFilm {
        
        let filmObject = SFFilm()
        
        if filmContentDict["gist"] != nil {
            let gistComponentDict: Dictionary<String, AnyObject>? = filmContentDict["gist"] as? Dictionary<String, AnyObject>
            
            if gistComponentDict != nil && (gistComponentDict?.count)! > 0 {
                
                filmObject.title = gistComponentDict?["title"] as? String
                filmObject.id = gistComponentDict?["id"] as? String
                filmObject.permaLink = gistComponentDict?["permalink"] as? String
                filmObject.type = gistComponentDict?["contentType"] as? String
                filmObject.durationSeconds = gistComponentDict?["runtime"] as? Int32
                filmObject.desc = gistComponentDict?["description"] as? String
                filmObject.thumbnailImageURL = gistComponentDict?["videoImageUrl"] as? String
                filmObject.filmWatchedDuration = gistComponentDict?["watchedTime"] as? Double
                filmObject.mediaType = gistComponentDict?["mediaType"] as? String
                
                #if os(tvOS)
                    filmObject.type = gistComponentDict?["mediaType"] as? String
                #endif
                
                filmObject.isFreeVideo = gistComponentDict?["free"] as? Bool
                filmObject.publishDate = gistComponentDict?["publishDate"] as? Double
                filmObject.eventId = gistComponentDict?["kisweEventId"] as? String

                if gistComponentDict?["imageGist"] != nil || gistComponentDict?["badgeImages"] != nil {
                    
                    let imageSet = self.parseImageGist(imageGistDict: gistComponentDict?["imageGist"] as? Dictionary<String, AnyObject>, badgeImageGist: gistComponentDict?["badgeImages"] as? Dictionary<String, AnyObject>)
                    
                    if imageSet.count > 0 {
                        
                        filmObject.images = imageSet
                    }
                }
                
                if filmObject.desc == nil {
                    
                    filmObject.desc = gistComponentDict?["logLine"] as? String
                }
                
                if filmObject.desc != nil {
                    
                    let attributedText:NSAttributedString = NSAttributedString.init(string: filmObject.desc!, attributes: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8])
                    
                    filmObject.desc = attributedText.string.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                }
                
                filmObject.viewerGrade = gistComponentDict?["averageStarRating"] as? Double
                
                filmObject.year = gistComponentDict?["year"] as? String
                filmObject.cacheDate = Date()
                
                let primaryCategory:Dictionary<String, AnyObject>? = gistComponentDict?["primaryCategory"] as? Dictionary<String, AnyObject>
                
                filmObject.primaryCategory = primaryCategory?["title"] as? String ?? ""
            }
        }
        
        filmObject.parentalRating = filmContentDict["parentalRating"] as? String
        
        if filmContentDict["contentDetails"] != nil {
            
            let contentDetailsComponentDict: Dictionary<String, AnyObject>? = filmContentDict["contentDetails"] as? Dictionary<String, AnyObject>
            let trailerDict:Array<Dictionary<String, AnyObject>?>? = contentDetailsComponentDict?["trailers"] as? Array<Dictionary<String, AnyObject>>
            
            if trailerDict != nil {
                for trailer in trailerDict! {
                    
                    filmObject.trailerId = trailer?["id"] as? String

                    let trailerUrlDict:Dictionary<String, AnyObject>? = parseVideoAssetDict(videoAssetDict: trailer?["videoAssets"] as? Dictionary<String, AnyObject>)
                    
                    if trailerUrlDict != nil {
                        
                        filmObject.trailerURL = trailerUrlDict?["hlsUrl"] as? String
                        
                        if filmObject.trailerURL == nil {
                            
                            let rendentionUrls:Array<AnyObject>? = trailerUrlDict?["renditionUrl"] as? Array<AnyObject>
                            
                            if rendentionUrls != nil {
                                
                                let renditionUrlDict:Dictionary<String, AnyObject>? = rendentionUrls?.last as? Dictionary<String, AnyObject>
                                
                                filmObject.trailerURL = renditionUrlDict?["renditionUrl"] as? String
                            }
                        }
                        
                        break
                    }
                }
            }
            
            if filmObject.images.count == 0 {
                let videoImageUrlDict: Dictionary<String, AnyObject>? = contentDetailsComponentDict?["videoImage"] as? Dictionary<String, AnyObject>
                
                if videoImageUrlDict != nil {
                    let imageObject: SFImage = SFImage()
                    imageObject.imageName = videoImageUrlDict?["name"] as? String
                    imageObject.imageID = videoImageUrlDict?["id"] as? String
                    imageObject.imageSource = videoImageUrlDict?["url"] as? String
                    imageObject.imageType = Constants.kSTRING_IMAGETYPE_VIDEO
                    
                    filmObject.images.add(imageObject)
                }
                
                let posterImageUrlDict: Dictionary<String, AnyObject>? = contentDetailsComponentDict?["posterImage"] as? Dictionary<String, AnyObject>
                
                if posterImageUrlDict != nil {
                    
                    let imageObject: SFImage = SFImage()
                    imageObject.imageName = posterImageUrlDict?["name"] as? String
                    imageObject.imageID = posterImageUrlDict?["id"] as? String
                    imageObject.imageSource = posterImageUrlDict?["url"] as? String
                    imageObject.imageType = Constants.kSTRING_IMAGETYPE_POSTER
                    
                    filmObject.images.add(imageObject)
                }
                
                if posterImageUrlDict != nil {
                    
                    let imageObject: SFImage = SFImage()
                    imageObject.imageName = videoImageUrlDict?["name"] as? String
                    imageObject.imageID = videoImageUrlDict?["id"] as? String
                    imageObject.imageSource = videoImageUrlDict?["url"] as? String
                    imageObject.imageType = Constants.kSTRING_IMAGETYPE_WIDGET
                    
                    filmObject.images.add(imageObject)
                }
            }
            
            #if os(iOS)
            let subTitleArray:Array<Dictionary<String, AnyObject>?>? = contentDetailsComponentDict?["closedCaptions"] as? Array<Dictionary<String, AnyObject>>
            if subTitleArray != nil {
                for subTitleObject in subTitleArray! {
                    let subTitleLocalObj :SFSubtitle = SFSubtitle()
                    subTitleLocalObj.subTitleUrl = subTitleObject?["url"] as? String ?? ""
                    subTitleLocalObj.subTitleType = subTitleObject?["format"] as? String ?? ""
                    filmObject.closedCaptions.add(subTitleLocalObj)
                }
            }
            #endif
        }

        let creditArray: Array? = filmContentDict["creditBlocks"] as? Array<Dictionary<String, Any>>
        
        if creditArray != nil {
            
            for creditObject in creditArray! {
                let creditLocalObj :SFCreditObject = SFCreditObject()
                creditLocalObj.creditTitle = creditObject["title"] as? String ?? ""
                creditLocalObj.creditTitle = creditLocalObj.creditTitle.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
                
                let creditSubArray: Array? = creditObject["credits"] as? Array<Dictionary<String, Any>>
                
                if creditSubArray != nil {
                    
                    for credit in creditSubArray! {
                        
                        let subCreditString: String? = credit["title"] as? String
                        
                        if subCreditString != nil {
                            
                            if creditLocalObj.credits == nil {
                                
                                creditLocalObj.credits = []
                            }
                            
                            creditLocalObj.credits?.append((subCreditString?.trimmingCharacters(in: .whitespacesAndNewlines))!)
                        }
                    }
                    if (creditLocalObj.creditTitle.lowercased() == "Directors".lowercased() ||  creditLocalObj.creditTitle.lowercased() == "Starring".lowercased() || creditLocalObj.creditTitle.lowercased() == "Director".lowercased()){
                        filmObject.credits.add(creditLocalObj)
                    }
                }
            }
        }
        
        if filmContentDict["streamingInfo"] != nil {
            let streamingInfoDict: Dictionary<String, AnyObject>? = filmContentDict["streamingInfo"] as? Dictionary<String, AnyObject>
            filmObject.isLiveStream = streamingInfoDict?["isLiveStream"] as? Bool
            let videoAssetsDict:Dictionary<String, AnyObject>? = streamingInfoDict?["videoAssets"] as? Dictionary<String, AnyObject>
            let mpeg:Array<Dictionary<String, AnyObject>?>? = videoAssetsDict?["mpeg"] as? Array<Dictionary<String, AnyObject>>

            if mpeg != nil {
                for filmURLObject in mpeg! {
                    let filmURLLocalObj :SFFilmURL = SFFilmURL()
                    filmURLLocalObj.renditionValue = filmURLObject?["renditionValue"] as? String ?? ""
                    filmURLLocalObj.renditionURL = filmURLObject?["url"] as? String ?? ""
                    filmObject.filmUrl.add(filmURLLocalObj)
                }
            }
        }

        return filmObject
    }
    
    
    //MARK: Method to parse Video Content Data
    func parseShowContentData(showContentDict:Dictionary<String, AnyObject>) -> SFShow {
        
        var showObject = SFShow()
        
        showObject.showId = showContentDict["id"] as? String
        
        if showContentDict["gist"] != nil {
            let gistComponentDict: Dictionary<String, AnyObject>? = showContentDict["gist"] as? Dictionary<String, AnyObject>
            
            if gistComponentDict != nil && (gistComponentDict?.count)! > 0 {
                
                showObject.showTitle = gistComponentDict?["title"] as? String
                
                if showObject.showId == nil {
                    
                    showObject.showId = gistComponentDict?["id"] as? String
                }
                showObject.permaLink = gistComponentDict?["permalink"] as? String
                showObject.type = gistComponentDict?["contentType"] as? String
                showObject.desc = gistComponentDict?["description"] as? String
                showObject.thumbnailImageURL = gistComponentDict?["videoImageUrl"] as? String
                
                if gistComponentDict?["imageGist"] != nil || gistComponentDict?["badgeImages"] != nil {
                    
                    let imageSet = self.parseImageGist(imageGistDict: gistComponentDict?["imageGist"] as? Dictionary<String, AnyObject>, badgeImageGist: gistComponentDict?["badgeImages"] as? Dictionary<String, AnyObject>)
                    
                    if imageSet.count > 0 {
                        
                        showObject.images = imageSet
                    }
                }
                
                if showObject.desc == nil {
                    
                    showObject.desc = gistComponentDict?["logLine"] as? String
                }
                
                if showObject.desc != nil {
                    
                    let attributedText:NSAttributedString = NSAttributedString.init(string: showObject.desc!, attributes: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8])
                    
                    showObject.desc = attributedText.string.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
                }
                
                showObject.viewerGrade = gistComponentDict?["averageStarRating"] as? Double
                
                showObject.year = gistComponentDict?["year"] as? String
                showObject.cacheDate = Date()
                
                let primaryCategory:Dictionary<String, AnyObject>? = gistComponentDict?["primaryCategory"] as? Dictionary<String, AnyObject>
                
                showObject.primaryCategory = primaryCategory?["title"] as? String ?? ""
            }
        }
        
        showObject.parentalRating = showContentDict["parentalRating"] as? String
        showObject = self.parseShowContentDetails(showContentDict: showContentDict, showObject: showObject)
        showObject = self.parseShowSeasonDetails(showContentDict: showContentDict, showObject: showObject)
        showObject = self.parseCastViewDetails(showContentDict: showContentDict, showObject: showObject)
        return showObject
    }
    
    
    //MARK: Method to parse Show Content Details
    private func parseShowContentDetails(showContentDict:Dictionary<String, AnyObject>, showObject:SFShow) -> SFShow {
        
        if showContentDict["showDetails"] != nil {
            
            let contentDetailsComponentDict: Dictionary<String, AnyObject>? = showContentDict["showDetails"] as? Dictionary<String, AnyObject>
            let trailerDict:Array<Dictionary<String, AnyObject>?>? = contentDetailsComponentDict?["trailers"] as? Array<Dictionary<String, AnyObject>>
            
            if trailerDict != nil {

                let trailerDict:Dictionary<String, String>? = self.parseTrailerURL(trailerDict: trailerDict!)
                
                if trailerDict != nil {
                    
                    if trailerDict!["trailerURL"] != nil {
                        
                        showObject.trailerURL = trailerDict?["trailerURL"]
                    }
                    
                    if trailerDict!["trailerId"] != nil {
                        
                        showObject.trailerId = trailerDict?["trailerId"]
                    }
                }
            }
            
//            let creditArray: Array<Dictionary<String, Any>>? = showContentDict["creditBlocks"] as? Array<Dictionary<String, Any>>
//
//            if creditArray != nil {
//
//                let creditSet:NSMutableSet? = self.parseCreditBlocks(creditArray: creditArray!)
//
//                if creditSet != nil {
//
//                    showObject.credits = creditSet!
//                }
//            }
        }
        
        return showObject
    }
    
    
    //MARK: Parse Credit Blocks
    private func parseCastViewDetails(showContentDict:Dictionary<String, AnyObject>, showObject:SFShow) -> SFShow {
        
        if showContentDict["creditBlocks"] != nil {
            
            let creditArray: Array<Dictionary<String, Any>>? = showContentDict["creditBlocks"] as? Array<Dictionary<String, Any>>
            
            if creditArray != nil {
                
                let creditSet:NSMutableSet? = self.parseCreditBlocks(creditArray: creditArray!)
                
                if creditSet != nil {
                    
                    showObject.credits = creditSet!
                }
            }
        }
        
        return showObject
    }
    
    
    //MARK: Parse Trailer Url
    private func parseTrailerURL(trailerDict:Array<Dictionary<String, AnyObject>?>) -> Dictionary<String, String>? {
        
        var formattedTrailerDict:Dictionary<String, String>?
        
        for trailer in trailerDict {
            
            let trailerUrlDict:Dictionary<String, AnyObject>? = parseVideoAssetDict(videoAssetDict: trailer?["videoAssets"] as? Dictionary<String, AnyObject>)
            
            if trailerUrlDict != nil {
                
                var trailerURL:String? = trailerUrlDict?["hlsUrl"] as? String
                
                if trailerURL == nil {
                    
                    let rendentionUrls:Array<AnyObject>? = trailerUrlDict?["renditionUrl"] as? Array<AnyObject>
                    
                    if rendentionUrls != nil {
                        
                        let renditionUrlDict:Dictionary<String, AnyObject>? = rendentionUrls?.last as? Dictionary<String, AnyObject>
                        
                        trailerURL = renditionUrlDict?["renditionUrl"] as? String
                    }
                }
                
                let trailerId:String? = trailer?["id"] as? String
                
                if trailerId != nil {
                    
                    formattedTrailerDict = [:]
                    formattedTrailerDict!["trailerId"] = trailerId!
                    
                    if trailerURL != nil {
                        
                        formattedTrailerDict!["trailerURL"] = trailerURL!
                    }
                }
                
                break
            }
        }
        
        return formattedTrailerDict
    }
    
    //MARK: Method to parse show credit blocks
    private func parseCreditBlocks(creditArray:Array<Dictionary<String, Any>>) -> NSMutableSet? {
        
        var creditSet:NSMutableSet?
        for creditObject in creditArray {
            let creditLocalObj :SFCreditObject = SFCreditObject()
            creditLocalObj.creditTitle = creditObject["title"] as? String ?? ""
            creditLocalObj.creditTitle = creditLocalObj.creditTitle.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)

            let creditSubArray: Array? = creditObject["credits"] as? Array<Dictionary<String, Any>>
            
            if creditSubArray != nil {
                
                for credit in creditSubArray! {
                    
                    let subCreditString: String? = credit["title"] as? String
                    
                    if subCreditString != nil {
                        
                        if creditLocalObj.credits == nil {
                            
                            creditLocalObj.credits = []
                        }
                        
                        creditLocalObj.credits?.append((subCreditString?.trimmingCharacters(in: .whitespacesAndNewlines))!)
                    }
                }
                if (creditLocalObj.creditTitle.lowercased() == "Directors".lowercased() ||  creditLocalObj.creditTitle.lowercased() == "Starring".lowercased() || creditLocalObj.creditTitle.lowercased() == "Director".lowercased()){
                    
                    if creditSet == nil {
                        
                        creditSet = NSMutableSet()
                    }
                    
                    creditSet?.add(creditLocalObj)
                }
            }
        }
        
        return creditSet
    }
    
    
    //MARK: Method to parse season details
    private func parseShowSeasonDetails(showContentDict:Dictionary<String, AnyObject>, showObject:SFShow) -> SFShow {
        
        if showContentDict["seasons"] != nil {
            
            let seasonDetailsArray: Array<Dictionary<String, AnyObject>?>? = showContentDict["seasons"] as? Array<Dictionary<String, AnyObject>?>
            
            if seasonDetailsArray != nil {
                
                var seasonArray:Array<SFSeason>?
                
                for seasonDict in seasonDetailsArray! {
                    
                    if seasonDict != nil {
                        
                        let season:SFSeason? = self.parseSeasonDict(seasonDict: seasonDict)
                        
                        if season != nil {
                            
                            if seasonArray == nil {
                                
                                seasonArray = []
                            }
                            seasonArray?.append(season!)
                        }
                    }
                }
                
                if seasonArray != nil {
                    
                    showObject.seasons = seasonArray
                }
            }
        }
        
        return showObject
    }
    
    //MARK: Method to parse season dict
    private func parseSeasonDict(seasonDict:Dictionary<String, AnyObject>?) -> SFSeason? {
        
        var season:SFSeason?

        if seasonDict != nil {
            
            season = SFSeason()
            season?.title = seasonDict?["title"] as? String
            
            let episodeArray:Array<Dictionary<String, AnyObject>?>? = seasonDict?["episodes"] as? Array<Dictionary<String, AnyObject>?>
            
            if episodeArray != nil {
                
                if episodeArray!.count > 0 {
                    
                    var episodesArray:Array<SFFilm>?
                    
                    for episodeDict in episodeArray! {
                        
                        if episodeDict != nil {
                            
                            let episodeObject:SFFilm = self.parseFilmContentData(filmContentDict: episodeDict!)
                            
                            if episodesArray == nil {
                                
                                episodesArray = []
                            }
                            episodesArray?.append(episodeObject)
                        }
                    }
                    
                    if episodesArray != nil {
                        
                        season?.episodes = episodesArray
                    }
                }
            }
        }
        
        return season
    }
    
    
    //MARK: Methoe
    //MARK: Method to parse type ahead search results
    func parseSearchResultDict(searchResultDict:Dictionary<String, AnyObject>) -> SFGridObject{
        
        let gridObject = SFGridObject()
        
        gridObject.contentTitle = searchResultDict["title"] as? String
        gridObject.contentId = searchResultDict["id"] as? String
        gridObject.contentType = searchResultDict["contentType"] as? String
        gridObject.thumbnailImageURL = searchResultDict["videoImageUrl"] as? String
        
        gridObject.posterImageURL = searchResultDict["posterImageUrl"] as? String
        gridObject.totalTime = searchResultDict["runtime"] as? Double
        gridObject.watchedTime = searchResultDict["watchedTime"] as? Double
        gridObject.gridPermaLink = searchResultDict["permalink"] as? String
        gridObject.isFreeVideo = searchResultDict["free"] as? Bool
        gridObject.publishedDate = searchResultDict["publishDate"] as? Double
        gridObject.eventId = searchResultDict["kisweEventId"] as? String
        gridObject.isLiveStream = searchResultDict["isLiveStream"] as? Bool

        let posterImageUrlDict:Dictionary<String, AnyObject>? = searchResultDict["posterImage"] as? Dictionary<String, AnyObject>
        
        if posterImageUrlDict != nil {
            
            gridObject.posterImageURL = posterImageUrlDict?["url"] as? String
        }
        
        let primaryCategoryDict:Dictionary<String, AnyObject>? = searchResultDict["primaryCategory"] as? Dictionary<String, AnyObject>
        
        if primaryCategoryDict != nil {
            
            gridObject.videoCategory = primaryCategoryDict?["title"] as? String
            gridObject.year = searchResultDict["year"] as? String
        }
        
        if searchResultDict["imageGist"] != nil || searchResultDict["badgeImages"] != nil {
            
            let imageSet = self.parseImageGist(imageGistDict: searchResultDict["imageGist"] as? Dictionary<String, AnyObject>, badgeImageGist: searchResultDict["badgeImages"] as? Dictionary<String, AnyObject>)
            
            if imageSet.count > 0 {
                
                gridObject.images = imageSet
            }
        }
        
        return gridObject
    }
    
    
    //MARK: Method to parse queue results
    func parseQueueResultDict(queueResultDict:Dictionary<String, AnyObject>) -> SFGridObject?{
        
        var gridObject:SFGridObject?
        
        let contentResponseDict:Dictionary<String, AnyObject>? = queueResultDict["contentResponse"] as? Dictionary<String, AnyObject>
        
        if contentResponseDict != nil {
            
            gridObject = parseModuleContentData(moduleContentDict: contentResponseDict!)
        }

        return gridObject
    }
    
   // #if os(iOS)
    //MARK: Method to parse plan page modules components
    func parsePlanPageModuleContentData(moduleContentDict:Dictionary<String, AnyObject>) -> PaymentModel{
        
        let paymentModel = PaymentModel.init().createPlanDetails(planDetailsDict: moduleContentDict)
        return paymentModel
    }
    
    
    func parsePlanPageFeatureListModuleContentData(moduleContentDict:Dictionary<String, AnyObject>) -> FeatureListModel{
        
       let featureListModel = FeatureListModel.init().createPlanFeatureListDetails(planDetailsDict: moduleContentDict)
        return featureListModel
    }
  //  #endif
}
