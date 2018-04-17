//
//  AdvertisementPlayer+Beacon.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 11/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import CoreMedia

extension AdvertisementPlayer_tvOS {
    
    //MARK:- Ping Beacon Event for Ads on basis of event type
    func pingBeaconEventForAds(_ eventType : String) {
        if let videoObject = videoObjectBeingPlayed {
            var beaconDict : Dictionary<String,String> = [:]
            beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId ?? ""
            beaconDict[Constants.kBeaconUrlKey] = BeaconEvent.generateURL(movieName: videoObject.videoTitle ?? "")
            beaconDict[Constants.kBeaconRefKey] = Constants.kBeaconViewingFilmPage
            beaconDict[Constants.kBeaconApodKey] = "0" //Only Pre-roles supported aso of now.
            beaconDict[Constants.kBeaconVposKey] = String(CMTimeGetSeconds(self.currentTime()))
            beaconDict[Constants.kBeaconAposKey] = String(CMTimeGetSeconds(self.currentTime()))
            beaconDict[Constants.kBeaconPlayerKey] = Constants.kBeaconEventNativePlayer
            beaconDict[Constants.kBeaconTstampoverrideKey] = BeaconEvent.getCurrentTimeStamp()
            if let streamId = videoStreamId{
                beaconDict[Constants.kBeaconStream_idKey] = streamId
            }
            else{
                beaconDict[Constants.kBeaconStream_idKey] = Utility.generateStreamID(movieName: videoObject.videoTitle ?? "")
            }

            beaconDict[Constants.kBeaconMedia_typeKey] = Constants.kBeaconEventMediaTypeVideo
            if(eventType == ADREQUEST) {
                beaconDict[Constants.kBeaconPaKey] = Constants.kBeaconEventTypeAdRequest
            }
            else {
                beaconDict[Constants.kBeaconPaKey] = Constants.kBeaconEventTypeAdImpression
            }
            let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
            DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
        }
    }
}
