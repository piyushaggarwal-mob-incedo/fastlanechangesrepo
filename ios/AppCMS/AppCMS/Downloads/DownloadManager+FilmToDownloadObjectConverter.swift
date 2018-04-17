//
//  DownloadManager+FilmToDownloadObjectConverter.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

extension DownloadManager {
    /*!
     * @discussion Method to return an array of downloadObjects from an array of Film Objects.
     * @param NSArray* containing SFFilms or SFManagedFilms.
     * @return NSArray* containing DownloadObjects
     */

    func getArrayOfDownloadObejcts(fromFilmObjectsArray arrayOfFilms: [SFFilm]) -> [DownloadObject] {
        var arrayOfObjectsToBeReturned = [DownloadObject]()
        for film: SFFilm in arrayOfFilms {
            arrayOfObjectsToBeReturned.append(getDownloadObject(for: film))
        }
        return arrayOfObjectsToBeReturned
    }
    /*!
     * @discussion Method to return downloadObject for a SFFilm object.
     * @param SFFilm* film.
     * @param BOOL shouldSaveToPlist. Set this only when you need to add the converted object to the list of downloads.
     * @return DownloadObject*
     */
    func getDownloadObject(for film: SFFilm, andShouldSaveToDirectory shouldSaveToPlist: Bool) -> DownloadObject {
        let downloadObject = getDownloadObject(for: film)
        if shouldSaveToPlist {
//            DispatchQueue.global(qos: .utility).async(execute: {() -> Void in
//               let url = URL(string: downloadObject.fileUrl)
//                if url != nil{
//                    URLSession.shared.dataTask(with: url!, completionHandler: { (responseData:Data?, response:URLResponse?, error:Error?) in
//                        let size: Int64? = response?.expectedContentLength
//                        DispatchQueue.main.async {
//                            downloadObject.fileTotalLength =  Double (size ?? 0)
//                            if film.isLiveStream == false{
//                                self.updatePlistForFile(objDownload: downloadObject)
//                            }
//                        }
//                    }).resume()
//                }
//            })
        }
        return downloadObject
    }

    /*!
     * @discussion Method to return film object from a given download object.
     * @param DownloadObject* objDownload.
     * @return SFFilm*
     */
    func getFilmObject(for objDownload: DownloadObject) -> SFFilm {
        let film_Selected = SFFilm()
        film_Selected.id = objDownload.fileID
        film_Selected.title = objDownload.fileName
        film_Selected.durationMinutes = objDownload.fileDurationMinutes?.int32Value
        film_Selected.durationSeconds = objDownload.fileDurationSeconds?.int32Value
        film_Selected.desc = objDownload.fileDescription
        film_Selected.filmPercentage = Double(objDownload.fileWatchedPercentage)
        film_Selected.id = objDownload.fileID
        film_Selected.showId = objDownload.fileCourseID
        film_Selected.showTitle = objDownload.fileCourseName
        film_Selected.episodeNumber = Int32(objDownload.fileNumber)

        film_Selected.parentalRating = objDownload.parentalRating
        film_Selected.year = objDownload.year
        film_Selected.primaryCategory = objDownload.primaryCategory
        film_Selected.viewerGrade = objDownload.viewerGrade
        film_Selected.fileBitRate = objDownload.fileBitRate
        let images = NSMutableSet()
        let image = SFImage()
        image.imageSource = objDownload.filePosterImageUrl
        
        images.add(image)
        film_Selected.images = images
        film_Selected.closedCaptions = objDownload.closedCaptions
        return film_Selected
    }

    /*!
     * @discussion Method which returns the updated download URL for a film Id
     * @param downloadObject - DownloadObject*
     * @param success - (void(^)(NSString* downloadObjectUrl))
     * @param failure - (void(^)(NSError* error))
     * @param downloadCurrentURL - NSURL*
     * @return - void
     */
    func fetchAndUpdateTheDownloadURLForDownloadObject(withDownloadObject downloadObject: DownloadObject?, withDownloadObjectCurrentUrl downloadCurrentURL: URL, withSuccess success: @escaping (_: String) -> Void, andFailure failure: @escaping (_: Error) -> Void) {
        DispatchQueue.global(qos: .utility).async(execute: {() -> Void in
            var request = URLRequest(url: downloadCurrentURL)
            request.httpMethod = "HEAD"
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)

            let dataTask: URLSessionTask? = session.dataTask(with: request, completionHandler: { (_ data: Data?, _ response: URLResponse?, _ error: Error?) in
                if error != nil {
                    success(downloadCurrentURL.absoluteString)
                    print("dataTaskWithRequest error: \(String(describing: error))")
                    return
                }
                if response != nil{
                    let statusCode: Int? = (response as! HTTPURLResponse).statusCode
                    if statusCode != 200 {
                        
                        if downloadObject != nil {
                            
                            self.downloadVideoIfUrlAvailable(downloadObject: downloadObject, downloadUrlResponse: { (downloadUrl) in
                                
                                if downloadUrl != nil && downloadUrl != "" {
                                    
                                    success(downloadUrl!)
                                }
                                else {
                                    
                                     success(downloadCurrentURL.absoluteString)
                                }
                            })
                        }
                        else {
                            
                            success(downloadCurrentURL.absoluteString)
                        }
                    }
                    else{
                        success(downloadCurrentURL.absoluteString)
                    }
                }
                })
            dataTask?.resume()
        })
    }

    private func downloadVideoIfUrlAvailable(downloadObject:DownloadObject?, downloadUrlResponse: @escaping ((_ downloadUrl:String?) -> Void)) {
        
        
        var filmObject:SFFilm? = self.getFilmObject(for: downloadObject!)
        
        if filmObject != nil {
            let apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/videos/\((filmObject?.id)!)?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&fields=streamingInfo"
            DataManger.sharedInstance.fetchDownloadURLDetailsForVideo(apiEndPoint: apiEndPoint, filmObject: filmObject!, filmResponse: { (updatedFilmObject) in
                
                filmObject = updatedFilmObject
                
                var downloadURL:String?
                
                if filmObject != nil {
                    
                    if downloadObject?.fileBitRate != nil {
                        
                        if (downloadObject?.fileBitRate.contains("360"))! {
                            
                            downloadURL = Utility.urlEncodedString_ch(emailStr: self.getDownloadURL(film: filmObject!, downloadQuality: "360"))
                            if downloadURL == "" {
                                
                                downloadURL = Utility.urlEncodedString_ch(emailStr: self.getDownloadURL(film: filmObject!, downloadQuality: "720p"))
                            }
                        }
                        else if (downloadObject?.fileBitRate.contains("720"))! {
                            
                            downloadURL = Utility.urlEncodedString_ch(emailStr: self.getDownloadURL(film: filmObject!, downloadQuality: "720p"))
                            if downloadURL == "" {
                                
                                downloadURL = Utility.urlEncodedString_ch(emailStr: self.getDownloadURL(film: filmObject!, downloadQuality: "360p"))
                            }
                        }
                    }
                    
                    if downloadURL == nil || downloadURL == "" {
                        
                        if self.downloadQuality.contains("360") {
                            downloadURL = Utility.urlEncodedString_ch(emailStr: self.getDownloadURL(film: filmObject!, downloadQuality: self.downloadQuality))
                            if downloadURL == "" {
                                
                                downloadURL = Utility.urlEncodedString_ch(emailStr: self.getDownloadURL(film: filmObject!, downloadQuality: "720p"))
                            }
                        }
                        else if self.downloadQuality.contains("720") {
                            
                            downloadURL = Utility.urlEncodedString_ch(emailStr: self.getDownloadURL(film: filmObject!, downloadQuality: self.downloadQuality))
                            if downloadURL == "" {
                                
                                downloadURL = Utility.urlEncodedString_ch(emailStr: self.getDownloadURL(film: filmObject!, downloadQuality: "360p"))
                            }
                        }
                    }
                    
                    if downloadURL == nil || downloadURL == "" {
                        
                        if filmObject?.filmUrl != nil {
                            
                            for filmUrl in (filmObject?.filmUrl)! {
                                let filmUrlObject: SFFilmURL = filmUrl as! SFFilmURL
                                downloadURL = Utility.urlEncodedString_ch(emailStr: filmUrlObject.renditionURL)
                                break
                            }
                        }
                    }
                }
                
                downloadUrlResponse(downloadURL)
            })
        }
        else {
            
            downloadUrlResponse(nil)
        }
    }

    
    func getDownloadURL(film: SFFilm, downloadQuality:String) -> String {
        var downloadURL = ""
        for filmUrl in film.filmUrl {
            let filmUrlObject: SFFilmURL = filmUrl as! SFFilmURL
            if filmUrlObject.renditionValue.contains(downloadQuality){
                downloadURL = filmUrlObject.renditionURL
                break
            }
        }
        return downloadURL
    }

    func getimageURL(film: SFFilm, forType:String) -> String {
        var downloadURL = ""
        for filmUrl in film.images {
            let filmUrlObject: SFImage = filmUrl as! SFImage
            if filmUrlObject.imageType ?? "" == forType{
                
                if  filmUrlObject.imageSource != nil {
                    downloadURL = filmUrlObject.imageSource ?? ""
                }
                break
            }
            else if filmUrlObject.imageType == nil {
                if  filmUrlObject.imageSource != nil {
                    downloadURL = filmUrlObject.imageSource ?? ""
                }
            }
        }
        return downloadURL
    }

    func getDownloadObject(for film: SFFilm) -> DownloadObject {
        let downloadObjectToBeReturned = DownloadObject()

        downloadObjectToBeReturned.fileID = film.id!
        downloadObjectToBeReturned.fileName = film.title!
        downloadObjectToBeReturned.fileDurationMinutes = film.durationMinutes as NSNumber?

        downloadObjectToBeReturned.fileDurationSeconds = film.durationSeconds as NSNumber?
        if downloadObjectToBeReturned.fileDurationMinutes == nil {
            if downloadObjectToBeReturned.fileDurationSeconds != nil {
                let seconds:Int = (downloadObjectToBeReturned.fileDurationSeconds?.intValue)!
                let minutes:Int  = Int(round(Double(seconds / 60)))
                downloadObjectToBeReturned.fileDurationMinutes = minutes as NSNumber
            }
        }
        downloadObjectToBeReturned.fileDescription = film.desc ?? ""
        downloadObjectToBeReturned.fileWatchedPercentage = Float(film.filmPercentage ?? 0)
        downloadObjectToBeReturned.fileDownloadState = downloadObjectState(rawValue: getCurrentDownloadStateForFile(withFileID: film.id!))
        downloadObjectToBeReturned.filePathUrl = ""
        downloadObjectToBeReturned.fileFolderUrl = ""
        downloadObjectToBeReturned.filePriority = 1
        downloadObjectToBeReturned.fileModifiedDateTime = Date()
        downloadObjectToBeReturned.fileCourseID = film.showId ?? ""
        downloadObjectToBeReturned.fileCourseName = film.showTitle ?? ""
        downloadObjectToBeReturned.fileNumber = Int(film.episodeNumber ?? 0)
        downloadObjectToBeReturned.fileCurrentDownloadedLength = 0
        downloadObjectToBeReturned.closedCaptions = film.closedCaptions
        
        if downloadQuality != ""{
            var downloadURL = ""

            if (downloadQuality.contains("360")){
                downloadURL = Utility.urlEncodedString_ch(emailStr: self.getDownloadURL(film: film, downloadQuality: downloadQuality))
                if downloadURL == "" {
                    
                    downloadURL = Utility.urlEncodedString_ch(emailStr: self.getDownloadURL(film: film, downloadQuality: "720p"))
                }
                downloadObjectToBeReturned.fileBitRate = "360"
            }
            else if (downloadQuality.contains("720")){
                
                downloadURL = Utility.urlEncodedString_ch(emailStr: self.getDownloadURL(film: film, downloadQuality: downloadQuality))
                if downloadURL == "" {
                    
                    downloadURL = Utility.urlEncodedString_ch(emailStr: self.getDownloadURL(film: film, downloadQuality: "360p"))
                }
                
                downloadObjectToBeReturned.fileBitRate = "720"
            }
            
            downloadObjectToBeReturned.fileUrl = downloadURL
        }

        if downloadObjectToBeReturned.fileUrl == "" {
            
            for filmUrl in film.filmUrl {
                let filmUrlObject: SFFilmURL = filmUrl as! SFFilmURL
                downloadObjectToBeReturned.fileUrl = Utility.urlEncodedString_ch(emailStr: filmUrlObject.renditionURL)
                break
            }
        }
        
        var type = "poster"

        var imageURL = self.getimageURL(film: film, forType: type)

        if imageURL != "" {
            downloadObjectToBeReturned.filePosterImageUrl = imageURL;
        }
        
        imageURL = ""
        if imageURL == "" {
            type = "video"
            imageURL = self.getimageURL(film: film, forType: type)
            
        }
        if imageURL == "" {
            type = "widget"
            imageURL = self.getimageURL(film: film, forType: type)
        }
        downloadObjectToBeReturned.filePosterImageUrl = imageURL;
        downloadObjectToBeReturned.fileImageUrl = imageURL
        downloadObjectToBeReturned.credits = film.credits
        downloadObjectToBeReturned.parentalRating = film.parentalRating ?? ""
        downloadObjectToBeReturned.year = film.year ?? ""
        downloadObjectToBeReturned.primaryCategory = film.primaryCategory ?? ""
        if film.viewerGrade != nil {
            downloadObjectToBeReturned.viewerGrade = film.viewerGrade!
        }
        return downloadObjectToBeReturned
    }
}
