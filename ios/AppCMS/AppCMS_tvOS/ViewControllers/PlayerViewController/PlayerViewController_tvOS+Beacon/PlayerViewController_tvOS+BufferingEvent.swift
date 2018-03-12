//
//  PlayerViewController_tvOS+BufferingEvent.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 11/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import CoreMedia

extension PlayerViewController_tvOS {

    func fireBeaconBufferingEvent() {
        if(Constants.buffercount < 5){
            Constants.buffercount = Constants.buffercount + 1
            return
        }
        var beaconDict : Dictionary<String,String> = [:]
        beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId
        beaconDict[Constants.kBeaconUrlKey] = BeaconEvent.generateURL(movieName: videoObject.videoTitle ?? "")
        beaconDict[Constants.kBeaconRefKey] = Constants.kBeaconViewingFilmPage
        beaconDict[Constants.kBeaconPaKey] = Constants.kBeaconEventBuffering
        beaconDict[Constants.kBeaconVposKey] = String(CMTimeGetSeconds((self.videoPlayerVC?.player?.currentTime())!))
        beaconDict[Constants.kBeaconAposKey] = String(CMTimeGetSeconds((self.videoPlayerVC?.player?.currentTime())!))
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
        Constants.buffercount = 0
    }
}
