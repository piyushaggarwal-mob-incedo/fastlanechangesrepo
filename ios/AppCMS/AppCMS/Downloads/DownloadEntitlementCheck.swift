//
//  DownloadEntitlementCheck.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
protocol DownloadEntitlementDelegate: class {
    func shouldPresentAlertView(message: String)
    func shouldPlayDownloadedVideo(objDownload: DownloadObject)
}

class DownloadEntitlementCheck: NSObject {
    var isEntitled:Bool?
    var delegate:DownloadEntitlementDelegate?

    static let sharedInstance:DownloadEntitlementCheck = {

        let instance = DownloadEntitlementCheck()

        return instance
    }()

    private func calicuateDaysBetweenTwoDates(start: Date, end: Date) -> Int {

        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }

    func isContentEntitledAndSubscribed(objDownload:DownloadObject) -> Void {
        let reachability:Reachability = Reachability.forInternetConnection()
        if ((Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest()) && reachability.currentReachabilityStatus() != NotReachable)  {
                DispatchQueue.global(qos: .userInitiated).async {

                    if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                        DataManger.sharedInstance.apiToGetUserEntitledStatus(success: { (isSubscribed) in
                            
                            DispatchQueue.main.async {
                                
                                if isSubscribed != nil {
                                    
                                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                        
                                        Utility.sharedUtility.setGTMUserProperty(userPropertyValue: isSubscribed! ? Constants.kGTMSubscribedPropertyValue : Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                                    }
                                    
                                    if isSubscribed! {
                                        objDownload.fileModifiedDateTime = Date();
                                        objDownload.isFileWatched = true
                                        DownloadManager.sharedInstance.updatePlistForFile(objDownload: objDownload)
                                        Constants.kSTANDARDUSERDEFAULTS.setValue(objDownload.fileModifiedDateTime, forKey: Constants.kUserOnlineTime)
                                        
                                        self.delegate?.shouldPlayDownloadedVideo(objDownload: objDownload)
                                        Constants.kAPPDELEGATE.isUserEntitled = true
                                    }
                                    else {
                                        
                                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                                        Constants.kSTANDARDUSERDEFAULTS.synchronize()
                                        self.delegate?.shouldPresentAlertView(message: "User not Entitled.")
                                        Constants.kAPPDELEGATE.isUserEntitled = false
                                    }
                                }
                                else {
                                    
                                    Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                                    
                                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                        
                                        Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                                    }
                                    
                                    self.delegate?.shouldPresentAlertView(message: "User not Entitled.")
                                    Constants.kAPPDELEGATE.isUserEntitled = false
                                }
                            }
                        })
                    }
                    else {
                        
                        objDownload.fileModifiedDateTime = Date();
                        objDownload.isFileWatched = true
                        DownloadManager.sharedInstance.updatePlistForFile(objDownload: objDownload)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(objDownload.fileModifiedDateTime, forKey: Constants.kUserOnlineTime)
                        
                        self.delegate?.shouldPlayDownloadedVideo(objDownload: objDownload)
                        Constants.kAPPDELEGATE.isUserEntitled = true
                    }
                }
        }
        else{
            DispatchQueue.main.async {
                if (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUserOnlineTime) != nil){
                    let userOnlineTime:Date = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUserOnlineTime) as? Date ?? Date()
                    let totalDays = self.calicuateDaysBetweenTwoDates(start:userOnlineTime , end:Date())
                    if (totalDays < 0) {
                        Constants.kAPPDELEGATE.isUserEntitled = false
                        self.delegate?.shouldPresentAlertView(message:Constants.kCheckSubscriptionFailureMessage)
                    }
                    else if totalDays < 30 {
                        
                        if(AppConfiguration.sharedAppConfiguration.serviceType == serviceType.AVOD) || (AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && Constants.kSTANDARDUSERDEFAULTS.bool(forKey: Constants.kIsSubscribedKey) == true) {
                            
                            objDownload.isFileWatched = true
                            DownloadManager.sharedInstance.updatePlistForFile(objDownload: objDownload)
                            Constants.kAPPDELEGATE.isUserEntitled = true
                            self.delegate?.shouldPlayDownloadedVideo(objDownload: objDownload)
                        }
                        else{
                            Constants.kAPPDELEGATE.isUserEntitled = false
                            self.delegate?.shouldPresentAlertView(message:Constants.kEntitlementErrorMessage)
                        }
                    }
                    else{
                        Constants.kAPPDELEGATE.isUserEntitled = false
                        self.delegate?.shouldPresentAlertView(message:Constants.kUserOnlineTimeAlert)
                    }
                }
                else{
                    Constants.kAPPDELEGATE.isUserEntitled = false
                    self.delegate?.shouldPresentAlertView(message:Constants.kEntitlementErrorMessage)
                }
            }
        }
    }
}
