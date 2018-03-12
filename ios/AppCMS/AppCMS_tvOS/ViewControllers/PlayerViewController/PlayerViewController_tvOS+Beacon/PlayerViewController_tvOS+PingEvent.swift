//
//  PlayerViewController_tvOS+PingEvent.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 11/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import CoreMedia

extension PlayerViewController_tvOS {
    
    func fireBeaconPingEvent(currentTime:Float) {
        var beaconDict : Dictionary<String,String> = [:]
        beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId
        beaconDict[Constants.kBeaconUrlKey] = BeaconEvent.generateURL(movieName: videoObject.videoTitle ?? "")
        beaconDict[Constants.kBeaconRefKey] = Constants.kBeaconViewingFilmPage
        beaconDict[Constants.kBeaconPaKey] = Constants.kBeaconEventTypePing
        beaconDict[Constants.kBeaconVposKey] = String(currentTime)
        beaconDict[Constants.kBeaconAposKey] = String(currentTime)
        beaconDict[Constants.kBeaconPlayerKey] = Constants.kBeaconEventNativePlayer
        beaconDict[Constants.kBeaconBitrateKey] = self.getBitRate(fileID: videoObject.videoContentId ?? "")
        beaconDict[Constants.kBeaconResolutionHeightKey] = String(describing: self.videoPlayerVC?.player?.currentItem?.presentationSize.height ?? 1080)
        beaconDict[Constants.kBeaconResolutionWidthKey] = String(describing: self.videoPlayerVC?.player?.currentItem?.presentationSize.width ?? 1920)
        beaconDict[Constants.kBeaconTstampoverrideKey] = BeaconEvent.getCurrentTimeStamp()
        if let streamId = videoStreamId{
            beaconDict[Constants.kBeaconStream_idKey] = streamId
        }
        else{
            beaconDict[Constants.kBeaconStream_idKey] = Utility.generateStreamID(movieName: videoObject.videoTitle ?? "")
        }
        beaconDict[Constants.kBeaconMedia_typeKey] = Constants.kBeaconEventMediaTypeVideo
        beaconDict[Constants.kBeaconBufferHealthKey] = String(secondsBuffered ?? 0.0)
        let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
        DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
    }
    
    //MARK : GET BitRate
    private func getBitRate(fileID : String) -> String
    {
        var avgBitrate:Int = 0
        if videoPlayerVC?.player?.currentItem != nil {
            if videoPlayerVC?.player?.currentItem?.accessLog() != nil {
                if videoPlayerVC?.player?.currentItem?.accessLog()?.events != nil {
                    
                    for event in (videoPlayerVC?.player?.currentItem?.accessLog()?.events)!{
                        avgBitrate = Int(event.indicatedBitrate)
                    }
                }
                avgBitrate = avgBitrate/1000
                return String(avgBitrate)
            }
            else {
                return ""
            }
        }
        else {
            return ""
        }
    }

}
