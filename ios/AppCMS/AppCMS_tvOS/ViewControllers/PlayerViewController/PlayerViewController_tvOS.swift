//
//  PlayerViewController_tvOS.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 27/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

/*
	KVO context used to differentiate KVO callbacks for this class versus other
	classes in its class hierarchy.
 */
private var playerViewControllerKVOContext = 0


class PlayerViewController_tvOS: UIViewController , AdXMLParserDelegate , AdvertisementPlayerDelegate {

    /// Set if the video is live.
    private var isLiveStream:Bool = false
    
    /// label to show Ad is playing.
    private var adLabel: UILabel?
    
    var addedObserverForCurrentItem : Bool = false
    /// Network unavailable alert.
    private var networkUnavailableAlert:UIAlertController?
    
    /// AVPlayerViewController
    var  videoPlayerVC  :  AVPlayerViewController?
    
    /// Ad parser class optional.
    private var adParser : AdXMLParser?
    
    /// Advertisement Player class optional.
    private var adPlayer : AdvertisementPlayer_tvOS?
    
    /// AVPlayerLayer optional. Not private as it is accessed in the extension.
    var playerLayer : AVPlayerLayer?
    
    /// Flag to mark if a sync process is in sync.
    private var isFilmProgressUpdateInSync: Bool = false
    
    /// DFP Tag for video.
    private var dfpTag: String?
    
    /// Current recorded time stamp. Not private as it is accessed in the extension.
    var currentTimeStamp : Date?
    
    /// Last beacon Ping time.
    private var lastBeaconPingedTime : Float?
    
    /// Seconds buffered for video player. Not private as it is accessed in the extension.
    var secondsBuffered: Float64?
    
    /// Current recorder time stamp for buffer state. Not private as it is accessed in the extension.
    var currentTimeStampForBuffer: Date?
    
    /// Set if the video is free.
    private var isFreeVideo:Bool = true
    
    //var relatedFilmIds : Array <String>=[]
    /// Lazily load the relatedFilmId Array.

    var relatedFilmIds : Array <String>?
        /// Lazily load the previewEndCard view controller.
    private(set) lazy var previewEndCard : PreviewEndCardViewController = {
       let viewController = PreviewEndCardViewController(nibName: "PreviewEndCardViewController", bundle: nil)
        return viewController
    }()
    
    private var previewEndWatchedTime: Double = 0.0
    
    /// Current film for player.
    private var currentFilm: SFFilm?
    
    // Video Stream Id for Beacon Ping Events
    var videoStreamId : String?
    
    var isFirstFrameSent : Bool = false //Used to check if beacon event for first frame has fired

    //MARK: - private Property
    private var timeObserverToken: Any?
    
    /// Activity Indicator for player screen.
    private  var acitivityIndicator : UIActivityIndicatorView?
    
    //MARK: - Public property
    //videoObject property holds information related to video/movie.
    //detailPageType property holds information related to video type i.e. film or episode.
    var videoObject: VideoObject
    
    /// Custom initializer for PlayerViewController_tvOS class.
    ///
    /// - Parameter videoObject: videoObject instance.
    init(videoObject: VideoObject) {
        self.videoObject = videoObject
        super.init(nibName: nil, bundle: nil)
//        self.videoObject.dfpTag  =  self.preparedfpTag()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black
        NotificationCenter.default.addObserver(self, selector:#selector(checkPlayerStatusAndPlayVideo), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        //Check for internet.
        checkForInternetConnectionBeforeProceeding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc private func checkPlayerStatusAndPlayVideo()
    {
        let networkStatus = NetworkStatus.sharedInstance
        if networkStatus.isNetworkAvailable() {
            if networkUnavailableAlert != nil {
                networkUnavailableAlert?.dismiss(animated: true, completion: nil)
                if self.videoPlayerVC?.player != nil {
                    playVideo(videoPlayer: videoPlayerVC!)
                }
                else
                {
                    checkForInternetConnectionBeforeProceeding()
                }
            }
        }
    }
    
    @objc private func checkForInternetConnectionBeforeProceeding() {
        let networkStatus = NetworkStatus.sharedInstance
        if networkStatus.isNetworkAvailable() {
            if networkUnavailableAlert != nil {
                networkUnavailableAlert?.dismiss(animated: true, completion: {
                })
                if self.videoPlayerVC?.player != nil {
                    playVideo(videoPlayer: videoPlayerVC!)
                }
                else{
                    self.checkForAdsAndPlayVideoOrAds()
                }
            } else {
                ////self.checkForAdsAndPlayVideoOrAds()
                if self.videoPlayerVC?.player != nil {
                    playVideo(videoPlayer: videoPlayerVC!)
                }
                else{
                    self.checkForAdsAndPlayVideoOrAds()
                }
            }
        }
        else {
                showAlertForAlertType(alertType: .AlertTypeNoInternetFound, isAlertForVideoDetailAPI: true, contentId: nil)
        }
    }
    
    open func checkIfAlertIsAlreadyShowing() -> Bool? {
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            if topController is UIAlertController {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    private func checkForAdsAndPlayVideoOrAds ()
    {
        var isSubscribed = false
        if let _isSubscribed = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool) {
            isSubscribed = _isSubscribed
        }
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && isSubscribed { //Bypassing ads only in one case.
            startProcessForPlayingVideo()
        } else {
            checkIfVideoIsLive(contentId: self.videoObject.videoContentId!, completed: { [weak self] (isLive) in
                guard let checkedSelf = self else {return}
                if isLive == false {
                    checkedSelf.dfpTag = checkedSelf.preparedfpTag()
                    if  (checkedSelf.dfpTag != nil && (checkedSelf.dfpTag?.characters.count)! > 0) && checkedSelf.adParser == nil && checkedSelf.videoPlayerVC == nil{
                        checkedSelf.addActivityIndicator()
                        if checkedSelf.adParser == nil {
                            checkedSelf.adParser = AdXMLParser.init(xmlURl: checkedSelf.dfpTag!)
                            checkedSelf.adParser?.delegate = self
                            checkedSelf.adParser?.configureParserAndStartParsing()
                        }
                    }
                    else {
                        checkedSelf.startProcessForPlayingVideo()
                    }
                } else {
                    checkedSelf.startProcessForPlayingVideo()
                }
            })
        }
    }


    deinit {
        print("Deinit call of playercontroller")
        self.removePeriodicTimeObserver()
        self.removeObservers()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - prepare dfptag for advertisement
    
    private func preparedfpTag() -> String
    {
        let isSubscribed = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) ?? false
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && isSubscribed as! Bool {
            return ""
        } else {
            let timeInMilliSeconds:Int64 = Int64(Date().timeIntervalSince1970)
            
            if let videoAdTag = AppConfiguration.sharedAppConfiguration.videoAdTag {
                
                let adTagEndPoint = "&url=https://\(AppConfiguration.sharedAppConfiguration.domainName ?? "")\(videoObject.gridPermalink ?? "")&ad_rule=0&correlator=\(timeInMilliSeconds)&cust_params=APPID%3D\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
                
                return videoAdTag.appending(adTagEndPoint)
            }
            else {
                
                return ""
            }
        }
    }
    
    //MARK: -  Create Player and Configure it to play the video
    private  func  setUpVideoPlayer(videoURL : String)
    {
        //If the view isn't showing, do not play video.
        if self.isShowing() == false{
            return
        }
        let encodedVideoURL : String?
        if videoURL.characters.count > 0 {
            let urlStringLocal = videoURL.trimmingCharacters(in: NSCharacterSet.whitespaces)
            encodedVideoURL = Utility.urlEncodedString_ch(emailStr: urlStringLocal)
        } else {
            //Show Failure Alert.
            return
        }
        
        guard let _encodedVideoURL = encodedVideoURL else {
            //Show Alert
            return
        }
        
        // URL to local or streamed media
        let url: URL? = URL(string: _encodedVideoURL)
        
        //  Create asset instance
        guard let _url = url else {
            //Show alert
            return
        }
        let asset = AVAsset(url: _url)
        
        let playableKey = "playable"
        
        // Load the "playable" property
        asset.loadValuesAsynchronously(forKeys: [playableKey]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: playableKey, error: &error)
            switch status {
            case .loaded:
                // Sucessfully loaded. Continue processing.
                DispatchQueue.main.async {
                    self.createPlayerWithAsset(asset)
                }
                break
                
            case .failed:
                // Handle error
                self.removeActivityIndicator()
                break
            case .cancelled:
                // Terminate processing
                self.removeActivityIndicator()
                break
            default:
                // Handle all other cases
                self.removeActivityIndicator()
                break
                
            }
        }
    }
    
    private func createPlayerWithAsset(_ asset : AVAsset)
    {
        //process format-specific metadata collection
        //Create player item
        let  playerItem = AVPlayerItem(asset: asset)
        
        //Create player instance
        let player = AVPlayer(playerItem: playerItem)
        
        //Create AVPlayerViewController Instance.
        self.videoPlayerVC = AVPlayerViewController()
        self.videoPlayerVC?.view.frame = self.view.frame
        
        // Associate player with view controller
        self.videoPlayerVC?.player = player

        if self.videoObject.videoWatchedTime! > Double(0)
        {
            self.videoPlayerVC?.player?.seek(to: CMTimeMakeWithSeconds(self.videoObject.videoWatchedTime!, 100))
        }
        //Add  videoplayercontroller view
        self.view.addSubview((self.videoPlayerVC?.view)!)
        
        ///Create external meta data
        //self.videoPlayerVC?.player?.currentItem?.externalMetadata = self.setExternalMetaData()
        
        self.setExternalMetaData()
        
        self.addPeriodicTimeObserver()
        
        //Beacon PLAY Event.
        self.fireBeaconPlayEvent()
        currentTimeStamp = Date()
        
        //Google Analytics event
        if self.videoObject.videoTitle != nil {
            //GA play event
            GATrackerTVOS.sharedInstance().event(withCategory: "player-video", action: "playVideo", label: videoObject.videoTitle, customParameters: [ "ev" : String(Int(-1)) ])
        }
        
        if addedObserverForCurrentItem == false {
            //Add observer on player current item
            addObserver(self, forKeyPath: #keyPath(videoPlayerVC.player.currentItem.loadedTimeRanges), options: [.new, .initial], context: &playerViewControllerKVOContext)
            addObserver(self, forKeyPath: #keyPath(videoPlayerVC.player.currentItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
            addObserver(self, forKeyPath: #keyPath(videoPlayerVC.player.currentItem.isPlaybackBufferEmpty), options: [.new, .initial], context: &playerViewControllerKVOContext)
            addedObserverForCurrentItem = true
        }
        
        //Add Notification for the player.
        self.addNotificationForPlayer()
        self.addSubtitleViewForPlayer()
    }
    
    private func addSubtitleViewForPlayer() {
        
        if let videoSubtitleStr = videoObject.subtitleStringUrl {
            guard let subtitleURL = URL(string: Utility.urlEncodedString_ch(emailStr: videoSubtitleStr)) else {
                return
            }
            
            if subtitleURL.absoluteString != ""  {
                
                DispatchQueue.main.async {
                    
                    self.videoPlayerVC?.player?.addSubtitles(parentView: self.view).open(file: subtitleURL, encoding: .utf8, isPathLocal: false)
                }
            }
        }
    }
    
    /// Fetching video live stream details.
    ///
    /// - Parameters:
    ///   - contentId: contentId for video to be played.
    ///   - completed: completion callback.
    private func checkIfVideoIsLive(contentId: String, completed: @escaping (Bool) -> ()) {
        DataManger.sharedInstance.fetchURLDetailsForVideo(apiEndPoint: "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/videos/\(contentId)?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&fields=streamingInfo") { [weak self] (videoURLWithStatusDict) in
            guard let checkedSelf = self else {
                return
            }
            let filmURLs:Dictionary<String, AnyObject>? = videoURLWithStatusDict?["urls"] as? Dictionary<String, AnyObject>
            if filmURLs != nil {
                checkedSelf.isLiveStream = filmURLs?["isLiveStream"] as? Bool ?? false
            }
            completed(checkedSelf.isLiveStream)
        }
    }
    
    func fetchVideoURLToBePlayed(contentId:String) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            //Network not available remove Activity Indicator.
            removeActivityIndicator()
        }
        else {
            
            DataManger.sharedInstance.fetchURLDetailsForVideo(apiEndPoint: "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/videos/\(self.videoObject.videoContentId!)?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&fields=streamingInfo,gist,contentDetails(relatedVideoIds)") { [weak self] (videoURLWithStatusDict) in
                
                guard let checkedSelf = self else {
                    return
                }
                
                if videoURLWithStatusDict != nil {
                    
                    checkedSelf.isFreeVideo = videoURLWithStatusDict?["isFreeVideo"] as! Bool
                    let filmURLs:Dictionary<String, AnyObject>? = videoURLWithStatusDict?["urls"] as? Dictionary<String, AnyObject>
                    
                    if filmURLs != nil {
                        
                        if checkedSelf.relatedFilmIds == nil {
                            
                            let relatedVideoIds:Array<Any>? = videoURLWithStatusDict?["relatedVideoIds"] as? Array<Any>
                            
                            if relatedVideoIds != nil {
                                
                                checkedSelf.relatedFilmIds = relatedVideoIds! as? Array<String>
                            }
                        }
                        
                        checkedSelf.videoObject.videoWatchedTime = 0.0
                        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                            
                            DataManger.sharedInstance.getVideoStatus(videoId: checkedSelf.videoObject.videoContentId, success: { [weak self] (videoStatusResponseDict, isSuccess) in
                                
                                guard let checkedSelf = self else {
                                    return
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    if videoStatusResponseDict != nil && isSuccess {
                                        
                                        if videoStatusResponseDict?["watchedTime"] != nil {
                                            
                                            checkedSelf.videoObject.videoWatchedTime = (videoStatusResponseDict?["watchedTime"] as! Double)
                                            if checkedSelf.previewEndWatchedTime > checkedSelf.videoObject.videoWatchedTime! {
                                                checkedSelf.videoObject.videoWatchedTime = checkedSelf.previewEndWatchedTime
                                            }
                                            checkedSelf.videoObject.videoWatchedTime = Utility.getWatchedDurationForVideo(watchedDuration: checkedSelf.videoObject.videoWatchedTime!, totalDurarion: checkedSelf.videoObject.videoPlayerDuration!)
                                        }
                                    }
                                    checkedSelf.fetchAdditionalFilmData(videoUrls: filmURLs)
                                }
                            })
                        }
                        else {
                            checkedSelf.fetchAdditionalFilmData(videoUrls: filmURLs)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            checkedSelf.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived, isAlertForVideoDetailAPI: true, contentId: nil)
                        }
                    }
                }
                else {
                    
                    DispatchQueue.main.async {
                        checkedSelf.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived, isAlertForVideoDetailAPI: true, contentId: nil)
                    }
                }
            }
        }
    }
    
    
    /// Method to check whether to show movie preview or not.
    ///
    /// - Parameter currentDuration: current duration of movie player.
    /// - Returns: Flag whether to show movie preview or not.
    func shouldDisplayPreviewEndScreen(currentDuration:Int) -> Bool {

        var shouldDisplayMoviePreviewEndScreen:Bool = false
        
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && !self.isFreeVideo {
            
            if AppConfiguration.sharedAppConfiguration.isVideoPreviewPerVideo ?? false {
                if AppConfiguration.sharedAppConfiguration.videoPreviewDuration != nil {
                    let videoPreviewDurationInSeconds:Int = Int(AppConfiguration.sharedAppConfiguration.videoPreviewDuration!)! * 60
                    
                    if currentDuration > videoPreviewDurationInSeconds {
                        
                        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) != nil {
                            
                            if !(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as! Bool) {
                                
                                shouldDisplayMoviePreviewEndScreen = true
                            }
                        }
                        else {
                            
                            shouldDisplayMoviePreviewEndScreen = true
                        }
                    }
                }
            } else if Constants.kPreviewEndEnforcer.isPreviewAllowed == false {
                let isSubscribed = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool ?? false
                if isSubscribed == false {
                    shouldDisplayMoviePreviewEndScreen = true
                }
            }
        }
        return shouldDisplayMoviePreviewEndScreen
    }
    
    /// Method used to fetch additional data required for video playback. Current responsibilty of this method is the call the subtitle fetch method and auto play array fetch method.
    ///
    /// - Parameter videoUrls: Accepts video urls to be passed to prepareUrlToBePlayed method further.
    private func fetchAdditionalFilmData(videoUrls:Dictionary<String, AnyObject>?) {
        
        fetchSubtitlesForVideo { [weak self] in
            self?.fetchAutoPlayArrayAndFilmDetails {
                self?.prepareUrlToBePlayed(videoUrls: videoUrls)
            }
        }
    }
    
    /// Fetching subtitles for video.
    ///
    /// - Parameter completion: completion callback on fetch completion.
    private func fetchSubtitlesForVideo(completion: @escaping (() -> Void)) {

        DataManger.sharedInstance.fetchSubTitleDetailsForVideo(apiEndPoint: "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/videos/\(self.videoObject.videoContentId!)?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&fields=contentDetails") { (filmURLs) in
            
            if filmURLs != nil {
                if filmURLs?["closedCaptions"] != nil {
                    let subTitleArray:Array<Dictionary<String, AnyObject>?>? = filmURLs?["closedCaptions"] as? Array<Dictionary<String, AnyObject>>
                    if let _subTitleArray = subTitleArray {
                        for subTitleObject in _subTitleArray {
                            if let subTitleFormat = subTitleObject?["format"] as? String {
                                if subTitleFormat == "SRT" || subTitleFormat == "srt" {
                                    self.videoObject.subtitleStringUrl = subTitleObject?["url"] as? String ?? ""
                                    break
                                }
                            }
                        }
                        completion()
                    } else {
                        completion()
                    }
                } else {
                    completion()
                }
            } else {
                completion()
            }
        }
    }
    
    /// Method to fetch Auto Play array. This additionally shortens the array by removing repeating value.
    ///
    /// - Parameter completion: completion callback on fetch completion.
    private func fetchAutoPlayArrayAndFilmDetails(completion: @escaping (() -> Void)) {
        
        AutoPlayArrayHandler().getTheAutoPlaybackArrayForFilm(film: videoObject.videoContentId!) { [weak self] (arrayOfFilmIds, film) in
            //Fill auto play only once.
            
            if self?.relatedFilmIds == nil {
                if let arrayOfFilmIds = arrayOfFilmIds {
                    //Removing any duplicates.
                    var reducedArray = Array<String>()
                    for id in arrayOfFilmIds {
                        if let contentId = self?.videoObject.videoContentId {
                            if (id as! String) != contentId {
                                reducedArray.append(id as! String)
                            }
                        }
                    }
                    self?.relatedFilmIds = reducedArray
                } else {
                        completion()
                        return
                }
            }
            //Update the current film object everytime on method call.
             if let checkedSelf = self {
                if film != nil{
                    checkedSelf.currentFilm = film
                    completion()
                }
                else{
                    if checkedSelf.relatedFilmIds?.isEmpty == false {
                        checkedSelf.videoObject.videoContentId = checkedSelf.relatedFilmIds?[0]
                        checkedSelf.relatedFilmIds?.remove(at: 0)
                        checkedSelf.fetchAutoPlayArrayAndFilmDetails(completion: {
                            completion()
                        })
                    }
                    else{
                        //Remove notification, observer for player.
                        checkedSelf.resetPlayer()
                        //Pop to previous controller
                        checkedSelf.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    private func prepareUrlToBePlayed(videoUrls:Dictionary<String, AnyObject>?)  {
        self.videoStreamId = Utility.generateStreamID(movieName: videoObject.videoTitle ?? "")
        self.isFirstFrameSent = false
        let videoUrls:Dictionary<String, AnyObject>? = videoUrls?["videoUrl"] as? Dictionary<String, AnyObject>
        if videoUrls == nil{
            
            DispatchQueue.main.async {
                self.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived, isAlertForVideoDetailAPI: true, contentId: nil)
            }
        }
        else{
            let rendentionUrls:Array<AnyObject>? = videoUrls?["renditionUrl"] as? Array<AnyObject>
            let hlsUrl:String? = videoUrls?["hlsUrl"] as? String
            var videoUrlToBePlayed:String?
            
            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
                if hlsUrl != nil {
                    
                    videoUrlToBePlayed = hlsUrl
                }
                else if rendentionUrls != nil {
                    
                    if (rendentionUrls?.count)! > 0 {
                        
                        let renditionUrlDict:Dictionary<String, AnyObject>? = rendentionUrls?.last as? Dictionary<String, AnyObject>
                        
                        videoUrlToBePlayed = renditionUrlDict?["renditionUrl"] as? String
                    }
                }
                
                if videoUrlToBePlayed != nil {
                    checkForContentRatingAndDecideTheFlow(videoUrlToBePlayed: videoUrlToBePlayed)
                }
            } else {
                if rendentionUrls != nil {
                    
                    if (rendentionUrls?.count)! > 0 {
                        
                        let renditionUrlDict:Dictionary<String, AnyObject>? = rendentionUrls?.last as? Dictionary<String, AnyObject>
                        
                        videoUrlToBePlayed = renditionUrlDict?["renditionUrl"] as? String
                    }
                } else if hlsUrl != nil {
                    
                    videoUrlToBePlayed = hlsUrl
                }
                
                if videoUrlToBePlayed != nil {
                    checkForContentRatingAndDecideTheFlow(videoUrlToBePlayed: videoUrlToBePlayed)
                }
            }
        }
    }
    
    /// Checks for content rating and shows a warning screen, if required.
    ///
    /// - Parameter videoUrlToBePlayed: url of the video to be played.
    private func checkForContentRatingAndDecideTheFlow(videoUrlToBePlayed: String?) {
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            self.setUpVideoPlayer(videoURL: videoUrlToBePlayed!)
        }
        else{
            if let isContentRatingEnabled = AppConfiguration.sharedAppConfiguration.isContentRatingEnabled {
                if isContentRatingEnabled {
                    let rating = currentFilm?.parentalRating ?? ""
                    let videoPlaybackDuration = videoObject.videoWatchedTime ?? 0.0
                    if (rating != "NR" || videoObject.videoContentRating != "NR") && videoPlaybackDuration == 0.0 {
                        let contentRatingView = SFCRWModule.init()
                        contentRatingView.contentRating = currentFilm?.parentalRating ?? videoObject.videoContentRating
                        contentRatingView.completionHandler = { [weak self] (shouldPlayVideo) in
                            guard let checkedSelf = self else {
                                return
                            }
                            if shouldPlayVideo {
                                DispatchQueue.main.async {
                                    checkedSelf.setUpVideoPlayer(videoURL: videoUrlToBePlayed!)
                                }
                            } else {
                                //Remove notification, observer for player.
                                checkedSelf.resetPlayer()
                                //Pop to previous controller
                                checkedSelf.navigationController?.popViewController(animated: true)
                            }
                        }
                        self.present(contentRatingView, animated: true, completion: nil)
                    } else {
                        self.setUpVideoPlayer(videoURL: videoUrlToBePlayed!)
                    }
                } else {
                    self.setUpVideoPlayer(videoURL: videoUrlToBePlayed!)
                }
            } else {
                self.setUpVideoPlayer(videoURL: videoUrlToBePlayed!)
            }
        }
    }
    
    //MARK: - Observers method for video playback
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,  change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        
        if keyPath == #keyPath(videoPlayerVC.player.currentItem.status) {
            // Display an error if status becomes Failed
            
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newStatus: AVPlayerItemStatus
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
            }
            else {
                newStatus = .unknown
            }
            
            if newStatus == .failed {
                self.removeActivityIndicator()
                //Beacon VIDEO FAILED Event.
                self.fireBeaconPlaybackFailedEvent()
                handle(error: videoPlayerVC?.player?.currentItem?.error as NSError?)
            }
            else if newStatus == .readyToPlay {
                self.removeActivityIndicator()
                if (networkUnavailableAlert != nil){
                    networkUnavailableAlert?.dismiss(animated: true, completion: {
                    })
                }
                //Beacon FIRST FRAME Event.
                if(isFirstFrameSent == false)
                {
                    isFirstFrameSent = true
                    self.fireBeaconFirstFrameEvent()
                }
                playVideo(videoPlayer: videoPlayerVC!)
            }
            else if newStatus == .unknown {
                if lastBeaconPingedTime != nil || secondsBuffered != nil {
                    //Beacon DROPPED STREAM Event.
                    self.fireBeaconDroppedStreamEvent()
                }
            }
        }
        
        else if keyPath == #keyPath(videoPlayerVC.player.currentItem.isPlaybackBufferEmpty) {
            let networkStatus = NetworkStatus.sharedInstance
            //Beacon BUFFERING Event.
            self.fireBeaconBufferingEvent()

            if !networkStatus.isNetworkAvailable(){
                showAlertWhileBuffering()
            }
        }
        //Getting Buffered duration.
        else if keyPath == #keyPath(videoPlayerVC.player.currentItem.loadedTimeRanges) {

            guard let change = change else {
                return
            }
            if let timeRanges = change[NSKeyValueChangeKey.newKey] {
                let timeRangesAsArray = timeRanges as! Array<CMTimeRange>
                if timeRangesAsArray.isEmpty == false {
                    let timeRange = timeRangesAsArray[0]
                    let _secondsBuffered = CMTimeGetSeconds(timeRange.duration)
                    secondsBuffered = _secondsBuffered
                }
            }
        }
    }
    
    private func setExternalMetaData(){ //-> [AVMetadataItem] {
        var externalMetaDataArray = Array<AVMetadataItem>()
        
        if let title = self.videoObject.videoTitle
        {
            let titleItem = AVMutableMetadataItem()
            titleItem.identifier = AVMetadataCommonIdentifierTitle
            titleItem.value = title as NSString
            titleItem.extendedLanguageTag = "und"
            externalMetaDataArray.append(titleItem)
        }
        
        
        if let descritption = self.videoObject.videoDescription
        {
            let descriptionItem = AVMutableMetadataItem()
            descriptionItem.identifier = AVMetadataCommonIdentifierDescription
            descriptionItem.value = descritption.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil) as NSCopying & NSObjectProtocol //descritption as NSString
            descriptionItem.extendedLanguageTag = "und"
            externalMetaDataArray.append(descriptionItem)
        }
        
        if let videoURL = self.videoObject.thumbnailImageUrlString
        {
            var imagePathString = videoURL
            imagePathString = imagePathString.appending("?impolicy=resize&w=\(421)&h=\(236)")
            imagePathString = imagePathString.trimmingCharacters(in: .whitespaces)
            
            let url = URL(string: imagePathString)
            let data = try? Data(contentsOf: url!)
            
            if data != nil
            {
                if let image = UIImage(data: data!){
                    let artwork = AVMutableMetadataItem()
                    artwork.key = AVMetadataCommonKeyArtwork as NSCopying & NSObjectProtocol
                    artwork.keySpace = AVMetadataKeySpaceCommon
                    artwork.value = UIImagePNGRepresentation(image)! as NSCopying & NSObjectProtocol
                    artwork.extendedLanguageTag = "und";
                    externalMetaDataArray.append(artwork)
                    self.videoPlayerVC?.player?.currentItem?.externalMetadata = externalMetaDataArray
                }
            }
            
            //return externalMetaDataArray
        }
        self.videoPlayerVC?.player?.currentItem?.externalMetadata = externalMetaDataArray
    }
    
    
    //MARK: - Player finish's playing current item.
    func videoPlayerItemDidFinishedPlaying(notification: Notification) -> Void {
        print("Player finished playing current item");
        let time : Float64 = CMTimeGetSeconds((self.videoPlayerVC?.player!.currentTime())!);
        self.updatePlayerProgressToServerAfterThirySeconds(currentTime: time)
        
        if let autoPlay = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) as? Bool
        {
            if autoPlay
            {
                self.resetPlayer()
                if relatedFilmIds?.isEmpty == false {
                    videoObject.videoContentId = relatedFilmIds?[0]
                    relatedFilmIds?.remove(at: 0)
                    let previousFilm = currentFilm
                    self.addActivityIndicator()
                    fetchAutoPlayArrayAndFilmDetails(completion: { [weak self] in
                        if let checkedSelf = self {
                            if let currentFilm = checkedSelf.currentFilm {
                                checkedSelf.videoObject.update(filmObject: currentFilm)
                                checkedSelf.showAutoPlayScreenAndDecideTheFlow(previousFilm: previousFilm!)
                            }
                        }
                    })
                } else {
                    //Remove notification, observer for player.
                    self.resetPlayer()
                    //Pop to previous controller
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                //Remove notification, observer for player.
                self.resetPlayer()
                //Pop to previous controller
                self.navigationController?.popViewController(animated: true)
            }
        } else{
            //Remove notification, observer for player.
            self.resetPlayer()
            //Pop to previous controller
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    /// Shows the auto play screen. Also acts the receiver of the completion callback of the auto play screen. Flow of the video player page is further decided based on the callback bool received.
    ///
    /// - Parameter previousFilm: SFFilm object for previous film.
    private func showAutoPlayScreenAndDecideTheFlow(previousFilm: SFFilm) {
        //Reset preview watched duration
        previewEndWatchedTime = 0.0
        //
        var isEpisodicContent: Bool = false
        if let contentType = previousFilm.mediaType {
            if contentType == Constants.kEpisodicContentType{
                isEpisodicContent = true
            }
            else{
                isEpisodicContent = false
            }
        }
        else{
            isEpisodicContent = false
        }
        
        let autoPlayModule = SFAutoPlayViewModule_tvOS.init(isEpisodicVideo: isEpisodicContent)
        

        autoPlayModule.nextFilm = currentFilm
        autoPlayModule.completionHandler = { [weak self] shouldAutoPlay in
            if shouldAutoPlay {
                if let checkedSelf = self {
                    //TODO: Check!
                    //ReInitialize the player. Check for various instance.
                    checkedSelf.checkForInternetConnectionBeforeProceeding()
                }
            } else {
                if let checkedSelf = self {
                    //Remove notification, observer for player.
                    checkedSelf.resetPlayer()
                    //Pop to previous controller
                    checkedSelf.navigationController?.popViewController(animated: true)
                }
                
            }
        }
        autoPlayModule.previousFilm = previousFilm
        self.present(autoPlayModule, animated: true, completion: nil)
    }
    
    private func resetPlayer(){
        //remove notification
        self.removeNotifications()
        
        //remove Observers
        self.removeObservers()
        
        //remove periodic time observers.
        self.removePeriodicTimeObserver()
        
        //Player is end playing the video remove the player and notification.
        self.removePlayer()
    }
    
    private func removePlayer() -> Void{
        if let videoPlayer = videoPlayerVC {
            pauseVideo(videoPlayer:videoPlayer)
        }
        self.videoPlayerVC?.player =  nil
        self.videoPlayerVC?.view.removeFromSuperview()
        self.videoPlayerVC = nil
        self.adParser = nil
        self.adPlayer = nil
    }
    
    //MARK: -  Periodic Observer Methods
    private func addPeriodicTimeObserver() {
        // Notify every 1 second
        let time = CMTime(seconds: 1, preferredTimescale: 10)
        timeObserverToken = self.videoPlayerVC?.player?.addPeriodicTimeObserver(forInterval: time,  queue: .main) {
            [weak self] time in
            guard let checkedSelf = self else {return}
            let time : Float64 = CMTimeGetSeconds((checkedSelf.videoPlayerVC?.player!.currentTime())!);
            if (Int(time) > 0 && (checkedSelf.videoPlayerVC?.player?.rate)! > Float(0.0) && Int(time) % 30 == 0) {
                checkedSelf.fireBeaconEventOnEveryThirtySeconds(currentTime: Float(time))
                if checkedSelf.isLiveStream == false {
                    checkedSelf.updatePlayerProgressToServerAfterThirySeconds(currentTime: time)
                }
            }
            //MARK: Checks whether the preview screen should be shown or not.
            if checkedSelf.shouldDisplayPreviewEndScreen(currentDuration: Int(time)) && checkedSelf.isPreviewEndCardScreenShowing() == false {
                //Locally saving the played time.
                checkedSelf.previewEndWatchedTime = time
                //Remove notification, observer for player.
                checkedSelf.resetPlayer()
                //Show PreviewEndCardController
                checkedSelf.previewEndCard.film = checkedSelf.currentFilm
                checkedSelf.previewEndCard.completionHandler = { (shouldPlayVideo) in
                    checkedSelf.previewEndCard.view.removeFromSuperview()
                    if shouldPlayVideo {
                        //Play the video again.
                        checkedSelf.checkForInternetConnectionBeforeProceeding()
                    } else {
                        //Pop to previous controller
                        checkedSelf.navigationController?.popViewController(animated: true)
                    }
                }
                checkedSelf.addChildViewController(checkedSelf.previewEndCard)
                checkedSelf.previewEndCard.view.tag = 786
                checkedSelf.previewEndCard.view.alpha = 0.0
                checkedSelf.view.addSubview(checkedSelf.previewEndCard.view)
                UIView.animate(withDuration: 0.4, animations: {
                    checkedSelf.previewEndCard.view.alpha = 1.0
                })
                checkedSelf.view.setNeedsFocusUpdate()
            }
        }
    }
    
    /// Method to check whether the
    ///
    /// - Returns: returns true if the previewEndCard is showing or not.
    private func isPreviewEndCardScreenShowing() -> Bool {
        var previewScreenShowing = false
        for view in self.view.subviews {
            if view.tag == 786 {
                previewScreenShowing = true
                break
            }
        }
        return previewScreenShowing
    }

    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            self.videoPlayerVC?.player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    //MARK: Fire BeaconEvents after every thirty seconds.
    private func fireBeaconEventOnEveryThirtySeconds(currentTime:Float) {
        if(lastBeaconPingedTime == currentTime) {
            return
        }
        lastBeaconPingedTime = currentTime
        //Beacon PING Event.
        self.fireBeaconPingEvent(currentTime: currentTime)
    }

    
    //MARK:Update Player Progress API to server
    func updatePlayerProgressToServerAfterThirySeconds(currentTime:Double) {
        
        guard let videoContentId = videoObject.videoContentId else {
            return
        }
        
        guard let userId = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) else {
            return
        }
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() != NotReachable {//&& !self.isFilmProgressUpdateInSync {
            
            self.isFilmProgressUpdateInSync = true
            let syncTime = min(currentTime,(self.videoObject.videoPlayerDuration!))
            let updatePlayerProgressDict:Dictionary<String, Any> = ["userId":userId, "videoId":videoContentId, "watchedTime":syncTime, "siteOwner":AppConfiguration.sharedAppConfiguration.sitename ?? ""]
            
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/video/history"
            
            DataManger.sharedInstance.updateFilmProgressOnServer(apiEndPoint: apiEndPoint, requestParameters: updatePlayerProgressDict) { (errorMessage, isSuccess) in
                
                if isSuccess == false {
                    
                    if errorMessage != nil {

//                        self.videoPlayerVC?.player?.pause()
//                        let error:String? = errorMessage?["error"] as? String ?? errorMessage?["message"] as? String
//                        let errorCode:String? = errorMessage?["code"] as? String
                        
//                        if errorCode != nil &&  errorCode == "401" {
//                            //TODO: show preview error.
//                        }
//                        else {
//                            let okAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { [weak self] (okAction) in
//                                
//                                self?.removeAdPlayer()
//                                self?.navigationController?.popViewController(animated: true)
//                            })
                            
//                            let errorAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "", alertMessage: error!, alertActions: [okAction])
//                            self.present(errorAlert, animated: true, completion: nil)
//                        }
                    }
                    else {
                        self.isFilmProgressUpdateInSync = false
                    }
                }
                else {
                    //self.isFilmProgressUpdateInSync = false
                }
            }
        }
    }

    
    //MARK:- Add notification for the player
    private func addNotificationForPlayer() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(videoPlayerItemDidFinishedPlaying(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: self.videoPlayerVC?.player?.currentItem)
    }
    
    
    //MARK: - Remove notification and Observers.
    private  func removeNotifications() -> Void {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.videoPlayerVC?.player?.currentItem)
    }
    
    private  func removeObservers() -> Void {
        if videoPlayerVC?.player?.currentItem != nil && addedObserverForCurrentItem == true {
            removeObserver(self, forKeyPath: #keyPath(videoPlayerVC.player.currentItem.loadedTimeRanges), context: &playerViewControllerKVOContext)
            removeObserver(self, forKeyPath: #keyPath(videoPlayerVC.player.currentItem.status), context: &playerViewControllerKVOContext)
            removeObserver(self, forKeyPath: #keyPath(videoPlayerVC.player.currentItem.isPlaybackBufferEmpty), context: &playerViewControllerKVOContext)
            addedObserverForCurrentItem = false
        }
    }
    
    //MARK: - Activity Indicator Methods
    private func addActivityIndicator(){
        if acitivityIndicator == nil {
            self.acitivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        }
        self.acitivityIndicator!.center = self.view.center
        self.view.addSubview(self.acitivityIndicator!)
        self.acitivityIndicator!.startAnimating()
    }
    
    private func removeActivityIndicator(){
        if let tempActivityIndicatorView = self.acitivityIndicator
        {
            tempActivityIndicatorView.removeFromSuperview()
            tempActivityIndicatorView.stopAnimating();
        }
        
    }
    
    //MARK: - Error Method
    func handle(error: NSError?) {
        print("Error occured-----\(String(describing: error?.localizedDescription))")
    }
    
    //MARK: - Remote button press events
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        
        if(presses.first?.type == UIPressType.menu) {
            self.resetPlayer()
            removeAdPlayer()
            
            // handle event
        } else {
            // perform default action (in your case, exit)
            super.pressesBegan(presses, with: event)
        }
    }
    
    
    //MARK: Display Network Error Alert
    func showAlertForAlertType(alertType: AlertType, isAlertForVideoDetailAPI:Bool, contentId:String?) {
        
        if checkIfAlertIsAlreadyShowing() == true {
            return
        }
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { [weak self] (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                if isAlertForVideoDetailAPI {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { [weak self] (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                if isAlertForVideoDetailAPI {
                    self?.checkForInternetConnectionBeforeProceeding()
                }
                else {
                    
                    self?.fetchVideoURLToBePlayed(contentId: contentId!)
                }
            }
        }
        
        var alertTitleString:String?
        var alertMessage:String?
        
        if alertType == .AlertTypeNoInternetFound {
            alertTitleString = Constants.kInternetConnection
            alertMessage = Constants.kInternetConntectionRefresh
        }
        else {
            alertTitleString = "No Response Received"
            alertMessage = "Unable to fetch data!\nDo you wish to Try Again?"
        }
        
        let alertActions = [closeAction,retryAction]
        networkUnavailableAlert = nil
        networkUnavailableAlert = UIAlertController(title: alertTitleString, message: alertMessage, preferredStyle: .alert)
        for action:UIAlertAction in alertActions  {
            
            networkUnavailableAlert?.addAction(action)
        }
        self.present(networkUnavailableAlert!, animated: true, completion: nil)
    }
    
    func showAlertWhileBuffering() {
        
        if checkIfAlertIsAlreadyShowing() == true {
            return
        }
        
        let okction:UIAlertAction = UIAlertAction.init(title: "OK", style: .default) { (result : UIAlertAction) in
        }
        
        var alertTitleString:String?
        var alertMessage:String?
        
        alertTitleString = Constants.kInternetConnection
        alertMessage = Constants.kInternetConntectionRefresh
        
        let alertActions = [okction]
        networkUnavailableAlert = nil
        networkUnavailableAlert = UIAlertController(title: alertTitleString, message: alertMessage, preferredStyle: .alert)
        for action:UIAlertAction in alertActions  {
            
            networkUnavailableAlert?.addAction(action)
        }
        self.present(networkUnavailableAlert!, animated: true, completion: nil)
    }
    
    
    //MARK: - ADXMLParser Delegate
    func advURlToBePlayed(adURLToPlay: String?, skipDuration: Int?) {
        
        self.removeActivityIndicator()
        adParser = nil
        
        if let adURlString = adURLToPlay{
            print("add url to play : \(adURlString)")
            createAndConfigureAdPlayer(adURlString)
        }
        else{
            startProcessForPlayingVideo()
        }
    }
    
    private func startProcessForPlayingVideo() {
        
        let isNetworkAvailable = NetworkStatus.sharedInstance.isNetworkAvailable()
        if isNetworkAvailable {
            if let videoObjectContentId = self.videoObject.videoContentId{
                if self.videoPlayerVC == nil {
                    self.addActivityIndicator()
                    self.fetchVideoURLToBePlayed(contentId: videoObjectContentId)
                }
            }
        }
    }
    
    private func createAndConfigureAdPlayer(_ urlString : String)
    {
        let isNetworkAvailable = NetworkStatus.sharedInstance.isNetworkAvailable()
        if isNetworkAvailable {
            self.addActivityIndicator()
            let videoURL = URL(string: urlString)// "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
            if adPlayer == nil {
                adPlayer = AdvertisementPlayer_tvOS(url: videoURL!)
            }
            adPlayer?.videoObjectBeingPlayed = videoObject
            adPlayer?.videoStreamId = videoStreamId

            adPlayer?.delegate = self
            if playerLayer == nil {
                playerLayer = AVPlayerLayer(player: adPlayer)
            }
            adPlayer?.setObserversForPlayer()
            adPlayer?.addNotificationForCurrentItem()
            playerLayer?.frame = self.view.bounds
            self.view.layer.addSublayer(playerLayer!)
        } else {
//            showAlertForAlertType(alertType: .AlertTypeNoInternetFound, isAlertForVideoDetailAPI: true, contentId: nil)
        }
    }
    
    //MARK : - AdvertisementPlayer delegate
    
    func adPlayerStartPlayingAds() {
        if self.isShowing() == false {
            self.adPlayer?.volume = 0.0
            self.adPlayer?.pause()
        } else {
            self.adPlayer?.volume = 1.0
            self.adPlayer?.play()
        }
        adLabel = UILabel(frame: CGRect(x:(self.view.frame.size.width - 120), y: (self.view.frame.size.height - 120), width: 120, height: 50))
        adLabel?.text = "Ad"
        adLabel?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        adLabel?.textAlignment = .center
        adLabel?.textColor = .white
        adLabel?.shadowColor = .black
        self.view.addSubview(adLabel!)
        self.removeActivityIndicator()
    }
    
    func adPlayerFailsToPlayAds()  {
        self.removeActivityIndicator()
        adLabel?.removeFromSuperview()
        ///Play video if ad is failing to play.
        startProcessForPlayingVideo()
    }
    
    func adPlayerFinishedPlayingAds(){
        removeAdPlayer()
        adLabel?.removeFromSuperview()
        //Play video/movie after ad.
        startProcessForPlayingVideo()
    }
    
    private  func removeAdPlayer(){
        adPlayer?.pause()
        adPlayer?.removeObserversForPlayer()
        adPlayer?.removeNotificationForCurrentItem()
        adParser?.delegate = nil
        adPlayer?.delegate = nil
        adPlayer = nil
        adParser = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    private func playVideo(videoPlayer: AVPlayerViewController) {
        videoPlayer.player?.play()
        if isFreeVideo == false && AppConfiguration.sharedAppConfiguration.isVideoPreviewPerVideo == false {
            Constants.kPreviewEndEnforcer.startAppOnTimeTracking()
        }
    }
    
    private func pauseVideo(videoPlayer: AVPlayerViewController) {
        videoPlayer.player?.pause()
        if isFreeVideo == false && AppConfiguration.sharedAppConfiguration.isVideoPreviewPerVideo == false {
            Constants.kPreviewEndEnforcer.pauseAppOnTimeTracking()
        }
    }
}
