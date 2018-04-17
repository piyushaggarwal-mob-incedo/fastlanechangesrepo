//
//  PlayerViewController_tvOS+PlayEvent.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 11/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import CoreMedia

extension PlayerViewController_tvOS {
    
    func fireBeaconPlayEvent() {
        var beaconDict : Dictionary<String,String> = [:]
        beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId
        beaconDict[Constants.kBeaconUrlKey] = BeaconEvent.generateURL(movieName: videoObject.videoTitle ?? "")
        beaconDict[Constants.kBeaconRefKey] = Constants.kBeaconViewingFilmPage
        beaconDict[Constants.kBeaconPaKey] = Constants.kBeaconEventTypePlay
        beaconDict[Constants.kBeaconVposKey] = String(self.videoObject.videoWatchedTime ?? 0.0)
        beaconDict[Constants.kBeaconAposKey] = String(self.videoObject.videoWatchedTime ?? 0.0 )
        beaconDict[Constants.kBeaconPlayerKey] = Constants.kBeaconEventNativePlayer
        beaconDict[Constants.kBeaconTstampoverrideKey] = BeaconEvent.getCurrentTimeStamp()
        if let streamId = videoStreamId{
            beaconDict[Constants.kBeaconStream_idKey] = streamId
        }
        else{
            beaconDict[Constants.kBeaconStream_idKey] = Utility.generateStreamID(movieName: videoObject.videoTitle ?? "")
        }
        beaconDict[Constants.kBeaconMedia_typeKey] = Constants.kBeaconEventMediaTypeVideo
        let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
        DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
    }
}
