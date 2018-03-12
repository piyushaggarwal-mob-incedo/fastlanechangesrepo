//
//  AppDelegate+DownloadConfiguration.swift
//  AppCMS
//
//  Created by Gaurav Vig on 29/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    func fetchDownloadItemsAndUpdateThePaths() {
        /*
         * Download manager - Get downloaded Objects array, set the download quality and Update the path of downloaded URLs.
         */
        DownloadManager.sharedInstance.removeTheCurrentDownloadAndFlushOutTheDataMaintainedLocallyForTheSession()
        let array = DownloadManager.sharedInstance.getDownloadedObjectsArray()
        print(array.count)
        DownloadManager.sharedInstance.updateDocumentsDirectoryPathForTheDownloadedItems()
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kDownloadQualitySelectionkey) != nil  {
            DownloadManager.sharedInstance.downloadQuality = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kDownloadQualitySelectionkey) as! String
        }
        var downloadingObject:DownloadObject? = nil
        if DownloadManager.sharedInstance.getDownloadingObjectsArray().count > 0 {
            downloadingObject = DownloadManager.sharedInstance.getDownloadingObjectsArray().first
            if(downloadingObject?.fileDownloadState == .eDownloadStatePaused || downloadingObject?.fileDownloadState == .eDownloadStateQueued){
                DownloadManager.sharedInstance.resumeDownloadingObject(with: downloadingObject!)
            }
        }
    }
    
    func resumeDowloadingObject()
    {
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            let reachability:Reachability = Reachability.forInternetConnection()
            
            if reachability.currentReachabilityStatus() == NotReachable {
                return
            }
            else
            {
                if reachability.currentReachabilityStatus() == ReachableViaWiFi {
                    var downloadingObject:DownloadObject? = nil
                    if DownloadManager.sharedInstance.getDownloadingObjectsArray().count > 0 {
                        downloadingObject = DownloadManager.sharedInstance.getDownloadingObjectsArray().first
                        if(downloadingObject?.fileDownloadState == .eDownloadStatePaused || downloadingObject?.fileDownloadState == .eDownloadStateQueued){
                            DownloadManager.sharedInstance.resumeDownloadingObject(with: downloadingObject!)
                        }
                    }
                }
                else if reachability.currentReachabilityStatus() == ReachableViaWWAN {
                    if Constants.kSTANDARDUSERDEFAULTS.bool(forKey: Constants.kCellularDownload) {
                        var downloadingObject:DownloadObject? = nil
                        if DownloadManager.sharedInstance.getDownloadingObjectsArray().count > 0 {
                            downloadingObject = DownloadManager.sharedInstance.getDownloadingObjectsArray().first
                            if(downloadingObject?.fileDownloadState == .eDownloadStatePaused || downloadingObject?.fileDownloadState == .eDownloadStateQueued){
                                DownloadManager.sharedInstance.resumeDownloadingObject(with: downloadingObject!)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateTheServerWithTheDownloadedDataWatchedPercentage() {
        
        //set download watched percentage
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            return
        }
        else
        {
            if (Constants.kLoginType != UserLoginType.none.rawValue)
            {
                for downloadObjectAtIndex: DownloadObject in DownloadManager.sharedInstance.getGlobalDownloadObjectsArray()
                {
                    if downloadObjectAtIndex.isFileWatched
                    {
                        downloadObjectAtIndex.isFileWatched = false
                        DownloadManager.sharedInstance.updatePlist(forFile: downloadObjectAtIndex)
                        
                        if downloadObjectAtIndex.fileDurationSeconds != nil {
                            
                            let totalSeconds = CInt(downloadObjectAtIndex.fileDurationSeconds!)
                            let seconds: Int = Int(downloadObjectAtIndex.fileWatchedPercentage * Float(totalSeconds)) / 100
                            //Updating the cache
                            
                            let updatePlayerProgressDict:Dictionary<String, Any> = ["userId":Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", "videoId":downloadObjectAtIndex.fileID, "watchedTime":seconds, "siteOwner":AppConfiguration.sharedAppConfiguration.sitename ?? ""]
                            
                            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/video/history"
                            
                            DataManger.sharedInstance.updateFilmProgressOnServer(apiEndPoint: apiEndPoint, requestParameters: updatePlayerProgressDict) { (errorMessage, isSuccess) in
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func startSyncBeaconEvents()
    {
        let sharedSyncManager = BeaconSyncManager.sharedInstance
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() != NotReachable {
            
            sharedSyncManager.startSyncingTheEvents(withSuccess: {(_ success: Bool) -> Void in
                
            })
        }
    }
}
