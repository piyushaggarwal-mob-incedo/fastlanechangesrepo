//
//  AdvertisementPlayer_tvOS.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 10/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import AVFoundation

let ADREQUEST = "Request"
let ADIMPRESSION = "Impression"

/*
	KVO context used to differentiate KVO callbacks for this class versus other
	classes in its class hierarchy.
 */
private var playerViewControllerKVOContext = 1

@objc protocol AdvertisementPlayerDelegate {
    
    /*Advertisement player has started playing the advertisement */
    @objc optional func adPlayerStartPlayingAds()
    
    /*Advertisement player has finished playing the advertisement*/
    @objc optional func adPlayerFinishedPlayingAds()
    
    /*Advertisement player has fail's to play the advertisement*/
    @objc  optional func adPlayerFailsToPlayAds()
    
    /*Called when ad player can be skipped*/
    @objc  optional func adCanBeSkipped()
    
    /*Called when ad player can be skipped*/
    @objc  optional func adCurrentPlaybackTimeUpdated()
}

class AdvertisementPlayer_tvOS: AVPlayer {
    
    private var lastTimeRegistered:Int = -1
    
    private var isFireSkipNotificationOnce:Bool = false
    
    //MARK: - private Property
    private var timeObserverToken: Any?
    
    var skipDuration: Int?
    
    var observersAdded = false
    
    ///Create  delegate property of AdvertisementPlayerDelegate.
    weak var delegate:AdvertisementPlayerDelegate?
    
    /// Video Object of video being played.
    var videoObjectBeingPlayed : VideoObject?
    
    var videoStreamId : String?
    
    /// Activity Indicator showing on ad player.
    private  var acitivityIndicator : UIActivityIndicatorView?
    
    func setObserversForPlayer() -> Void {
        
        if observersAdded == false {
            addPeriodicTimeObserver()
            addObserver(self, forKeyPath: #keyPath(AdvertisementPlayer_tvOS.currentItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
            addObserver(self, forKeyPath: #keyPath(AdvertisementPlayer_tvOS.rate), options: [.new, .initial], context: &playerViewControllerKVOContext)
            observersAdded = true
        }
    }
    
    private func addPeriodicTimeObserver() {
        // Notify every 1 second
        let time = CMTime(seconds: 1, preferredTimescale: 10)
        timeObserverToken = self.addPeriodicTimeObserver(forInterval: time,  queue: .main) {
            [weak self] time in
            guard let checkedSelf = self else {return}
            let time : Float64 = CMTimeGetSeconds(checkedSelf.currentTime())
            if checkedSelf.lastTimeRegistered != Int(time) {
                print("Last Registered time \(checkedSelf.lastTimeRegistered)")
                checkedSelf.delegate?.adCurrentPlaybackTimeUpdated?()
                checkedSelf.lastTimeRegistered = Int(time)
            }
            if let skipDuration = checkedSelf.skipDuration {
                if Int(time) >= skipDuration {
                    if checkedSelf.isFireSkipNotificationOnce == false {
//                        checkedSelf.delegate?.adCanBeSkipped?()
                        checkedSelf.isFireSkipNotificationOnce = true
                    }
                }
            }
        }
    }
    
    func addNotificationForCurrentItem() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(adsPlayerDidFinishedPlayingCurrentItem(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: self.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(adsPlayerFailsToPlayCurrentItem(notification:)), name: .AVPlayerItemFailedToPlayToEndTime, object: self.currentItem)
    }
    
    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            self.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func removeNotificationForCurrentItem() -> Void {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.currentItem)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: self.currentItem)
    }
    
    
    func removeObserversForPlayer() -> Void {
        
        if observersAdded == true {
//            removeObserversForPlayer()
            removePeriodicTimeObserver()
            removeObserver(self, forKeyPath: #keyPath(AdvertisementPlayer_tvOS.currentItem.status), context: &playerViewControllerKVOContext)
            removeObserver(self, forKeyPath: #keyPath(AdvertisementPlayer_tvOS.rate), context: &playerViewControllerKVOContext)
            observersAdded = false
        }
    }
    
    
    //MARK: - Observers method for video playback
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,  change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        
        if keyPath == #keyPath(AdvertisementPlayer_tvOS.currentItem.status) {
            // Display an error if status becomes Failed
            let newStatus: AVPlayerItemStatus
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
            }
            else {
                newStatus = .unknown
                handle(error: self.currentItem?.error as NSError?)
            }
            
            if newStatus == .failed {
                handle(error: self.currentItem?.error as NSError?)
            }
            else if newStatus == .readyToPlay {
                delegate?.adPlayerStartPlayingAds?()
                pingBeaconEventForAds(ADREQUEST)
            }
        }
        
        if keyPath == #keyPath(AdvertisementPlayer_tvOS.rate) {
            // Display an error if status becomes Failed
//            if self.rate == 0{
//                self.play()
//            }
        }
    }
    
    
    //MARK: - Ads Player finish's playing current item.
    func adsPlayerDidFinishedPlayingCurrentItem(notification: Notification) -> Void {
        //print("Player finished playing current item")
        pingBeaconEventForAds(ADIMPRESSION)
        delegate?.adPlayerFinishedPlayingAds?()
    }
    
    
    ///MARK: - Ads Player fail's to play current item.
    func adsPlayerFailsToPlayCurrentItem(notification: Notification) -> Void {
        //print("Ad Player fails to play")
        delegate?.adPlayerFailsToPlayAds?()
    }
    
    //MARK: - Error Method
    func handle(error: NSError?) {
        print("Error occured-----\(String(describing: error?.localizedDescription))")
        
        ///advertisement player fails to play the video.
        delegate?.adPlayerFailsToPlayAds?()
    }
    
    deinit {
        print("Deinit call of playercontroller")
        self.removeObserversForPlayer()
        self.removeNotificationForCurrentItem()
    }
}
