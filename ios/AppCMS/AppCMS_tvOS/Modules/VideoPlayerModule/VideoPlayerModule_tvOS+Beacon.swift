//
//  VideoPlayerModule_tvOS+Beacon.swift
//  AppCMS_tvOS
//
//  Created by Anirudh Vyas on 21/12/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

import CoreMedia

extension VideoPlayerModule_tvOS {

    func fireBeaconBufferingEvent() {
        if(Constants.buffercount < 5){
            Constants.buffercount = Constants.buffercount + 1
            return
        }
        guard let videoObject = videoObject else {
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
    
    func fireBeaconDroppedStreamEvent() {
        
        guard let videoObject = videoObject else {
            return
        }
        var beaconDict : Dictionary<String,String> = [:]
        beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId
        beaconDict[Constants.kBeaconUrlKey] = BeaconEvent.generateURL(movieName: videoObject.videoTitle ?? "")
        beaconDict[Constants.kBeaconRefKey] = Constants.kBeaconViewingFilmPage
        beaconDict[Constants.kBeaconPaKey] = Constants.kBeaconEventDroppedStream
        beaconDict[Constants.kBeaconVposKey] = String(CMTimeGetSeconds((self.videoPlayerVC?.player?.currentTime())!))
        beaconDict[Constants.kBeaconAposKey] = String(CMTimeGetSeconds((self.videoPlayerVC?.player?.currentTime())!))
        beaconDict[Constants.kBeaconPlayerKey] = Constants.kBeaconEventNativePlayer
        beaconDict[Constants.kBeaconTstampoverrideKey]=BeaconEvent.getCurrentTimeStamp()
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
    
    func fireBeaconPlayEvent() {
        
        guard let videoObject = videoObject else {
            return
        }
        var beaconDict : Dictionary<String,String> = [:]
        beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId
        beaconDict[Constants.kBeaconUrlKey] = BeaconEvent.generateURL(movieName: videoObject.videoTitle ?? "")
        beaconDict[Constants.kBeaconRefKey] = Constants.kBeaconViewingFilmPage
        beaconDict[Constants.kBeaconPaKey] = Constants.kBeaconEventTypePlay
        beaconDict[Constants.kBeaconVposKey] = String(videoObject.videoWatchedTime ?? 0.0)
        beaconDict[Constants.kBeaconAposKey] = String(videoObject.videoWatchedTime ?? 0.0 )
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
    
    func fireBeaconFirstFrameEvent() {
        
        guard let videoObject = videoObject else {
            return
        }
        let elapsed = Date().timeIntervalSince(currentTimeStamp!)
        let duration = Float(elapsed)
        var beaconDict : Dictionary<String,String> = [:]
        beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId
        beaconDict[Constants.kBeaconUrlKey] = BeaconEvent.generateURL(movieName: videoObject.videoTitle ?? "")
        beaconDict[Constants.kBeaconRefKey] = Constants.kBeaconViewingFilmPage
        beaconDict[Constants.kBeaconPaKey] = Constants.kBeaconEventFirstFrame
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
        beaconDict[Constants.kBeaconTtfirstframeKey] = String(duration)
        beaconDict[Constants.kBeaconMedia_typeKey] = Constants.kBeaconEventMediaTypeVideo
        beaconDict[Constants.kBeaconBufferHealthKey] = String(secondsBuffered ?? 0.0)
        let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
        DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
    }
    
    func fireBeaconPingEvent(currentTime:Float) {
        
        guard let videoObject = videoObject else {
            return
        }
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
    
    func fireBeaconPlaybackFailedEvent() {
        
        guard let videoObject = videoObject else {
            return
        }
        
        var beaconDict : Dictionary<String,String> = [:]
        beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId
        beaconDict[Constants.kBeaconUrlKey] = BeaconEvent.generateURL(movieName: videoObject.videoTitle ?? "")
        beaconDict[Constants.kBeaconRefKey] = Constants.kBeaconViewingFilmPage
        beaconDict[Constants.kBeaconPaKey] = Constants.kBeaconEventFailedToStart
        beaconDict[Constants.kBeaconVposKey] = String(CMTimeGetSeconds((self.videoPlayerVC?.player?.currentTime())!))
        beaconDict[Constants.kBeaconAposKey] = String(CMTimeGetSeconds((self.videoPlayerVC?.player?.currentTime())!))
        beaconDict[Constants.kBeaconPlayerKey] = Constants.kBeaconEventNativePlayer
        beaconDict[Constants.kBeaconTstampoverrideKey]=BeaconEvent.getCurrentTimeStamp()
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
