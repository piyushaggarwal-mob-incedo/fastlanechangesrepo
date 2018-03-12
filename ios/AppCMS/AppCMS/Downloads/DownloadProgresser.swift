//
//  DownloadProgresser.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class DownloadProgresser: NSObject {

    static let sharedInstance:DownloadProgresser = {
        let instance = DownloadProgresser()
        return instance
    }()

    func addFilm(toListOfDownloads filmToBeAdded: SFFilm, withSuccess success: @escaping (_: Void) -> Void, andFailure failure: @escaping (_: Void) -> Void) {

        let isVideoPresent: Bool = DownloadManager.sharedInstance.downloadingObjectsContainsFile(withID: filmToBeAdded.id!)

        let reachability:Reachability = Reachability.forInternetConnection()

        if reachability.currentReachabilityStatus() == NotReachable && !isVideoPresent {
            let alert = UIAlertView(title: "Internet Connection", message: "Not connected to internet. Please check your device settings.", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "")
            alert.show()
            failure()
            return
        }

        else if reachability.currentReachabilityStatus() == ReachableViaWWAN && !(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kDownloadCellularSelectionkey) as! Bool) {
            let alert = UIAlertView(title: "Internet Connection", message: "Not connected to WiFi. Please enable download using Cellular data from settings page.", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "")
            alert.show()
            failure()
            return
        }
        else {
            let downloadObject = DownloadManager.sharedInstance.getDownloadObject(for: filmToBeAdded, andShouldSaveToDirectory: false)
            if isVideoPresent {
                DownloadManager.sharedInstance.removeObject(fromDownloadedArray: downloadObject.fileID, withSuccessBlock: {() -> Void in
                    success()
                }, andFailureBlock: {(_ error: Error?) -> Void in
                    failure()
                })
            }
            else {
                DataManger.sharedInstance.getEntitlementForMovie(filmId: filmToBeAdded.id!, userId: Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as! String, success: { (_ responseDict: Dictionary?,isSuccess:Bool) in
                    let hashMapDict:Dictionary<String,Any> = responseDict?["hashMap"] as! Dictionary<String, Any>
                    let statusString:String? = hashMapDict["status"] as? String
                    if (statusString != nil && statusString == "success"){
                        DispatchQueue.main.async(execute: {() -> Void in
                            DownloadManager.sharedInstance.addObject(toDownload: downloadObject)
                            success()
                        })
                    }
                    else {
                        let errorString: String? = hashMapDict["errorMessage"] as? String
                        print(errorString ?? "")
                        failure()
                    }
                })

            }
        }
    }

    func addArrayOfFilmsToDownloadsByCheckingEntitlement(forEach arrayOfFilmsToDownload: [SFFilm], withSuccess success: @escaping (_: Void) -> Void, andFailedFilm failedFilm: @escaping (_ failedFilmObject: SFFilm) -> Void) {
        for filmToBeDownloaded: SFFilm in arrayOfFilmsToDownload {
            self.checkFilmEntitlmentCheckerAndFetchResponse(for: filmToBeDownloaded, withSuccess: success, andFailedFilm: failedFilm)
        }
    }

    func checkFilmEntitlmentCheckerAndFetchResponse(for filmToBeDownloaded: SFFilm, withSuccess success: @escaping (_: Void) -> Void, andFailedFilm failedFilm: @escaping (_ failedFilmObject: SFFilm) -> Void) {
        /*Checking entitlement for the film to be downloaded.*/
        DataManger.sharedInstance.getEntitlementForMovie(filmId: filmToBeDownloaded.id!, userId: Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as! String, success: { (_ responseDict: Dictionary?,isSuccess:Bool) in
            let hashMapDict:Dictionary<String,Any> = responseDict?["hashMap"] as! Dictionary<String, Any>
            let statusString:String? = hashMapDict["status"] as? String
            if (statusString != nil && statusString == "success"){
                /*Fetching response for the film to be downloaded.*/
                DataManger.sharedInstance.getFilmBy(filmId: filmToBeDownloaded.id!, success: {(_ film: SFFilm?, _ isSuccess:Bool) in
                    if(isSuccess == true)
                    {
                        if DownloadManager.sharedInstance.downloadingObjectsContainsFile(withID: (film?.id!)!) {
                            //                     failure();
                        }
                        else {
                            DispatchQueue.main.async(execute: {() -> Void in
                                let downloadObj = DownloadManager.sharedInstance.getDownloadObject(for: film!, andShouldSaveToDirectory: true)
                                if downloadObj.fileUrl != "" && film?.isLiveStream == false {
                                    DownloadManager.sharedInstance.addObject(toDownload: downloadObj)
                                    success()
                                }
                                else {
                                    failedFilm(film!)
                                }
                            })
                        }
                    }
                    else{
                        failedFilm(filmToBeDownloaded)
                    }
                })

            }
            else{
                failedFilm(filmToBeDownloaded)
            }
        })
    }
}
