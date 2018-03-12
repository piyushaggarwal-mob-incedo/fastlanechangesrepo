//
//  RokuDevices.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 09/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//
// Description: Provides the roku devices available.

import UIKit

class RokuDevices: NSObject, DiscoveryEventsDelegate {

    private
    var listOfRokuDevices = Array<DiscoveredRokuBox>()
    
    /// Property of having method type as the completionHandler closure.
    private
    var completionHandlerCopy : ((Array<DiscoveredRokuBox>) -> Void)? = nil
    
    /// Starts the scaning of roku devices.
    ///
    /// - Parameter completionHandler: completion callback.
    func startRokuDeviceScan(completionHandler : @escaping ((_ listOfRokuBoxes: Array<DiscoveredRokuBox>) -> Void)) -> Void {
        
        completionHandlerCopy = completionHandler
        Discovery.shared().startSSDPBroadcast(self as DiscoveryEventsDelegate)
    }
    
    
    func onFinished(_ count: Int32) {
        completionHandlerCopy! (listOfRokuDevices)
    }

    func onFound(_ box: DiscoveredRokuBox!) {
        let dialManager = DIALManager()
        DIALManager().fetchDetails(box)
        if dialManager.check(forRokudevice: box) {
            print("Roku device found:\(box?.friendlyName ?? "")")
            listOfRokuDevices.append(box)
        }
    }
    
    func connectToRokuDevice(rokuBox : DiscoveredRokuBox?, contentToBeScreened: Any?) -> Void {
        guard rokuBox != nil else {
            return
        }
        if let contentToBeScreened = contentToBeScreened {
            let launchUrl = getlaunchURLForRoku(contentToBeScreened: contentToBeScreened)
            DIALManager().launchApp(rokuBox?.dialURL, appName: "ROKUAPPNAME", videoUrl: launchUrl)
            //TODO: Update app name.
        }
    }
    
    func getlaunchURLForRoku(contentToBeScreened: Any) -> String {
        let videoLaunchUrl : String
        if contentToBeScreened is SFFilm  {
            let filmToBeScreened = contentToBeScreened as! SFFilm
            videoLaunchUrl = "playID=\(filmToBeScreened.id ?? "")&userID=userid&contentType=film"
        } else {
            //TODO: Handle for show's case.
            videoLaunchUrl = ""
        }
        return videoLaunchUrl
    }
}
    
