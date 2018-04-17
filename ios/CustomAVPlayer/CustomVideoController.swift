
 //
 //  CustomVideoController.swift
 //  VideoPlayer
 //
 //  Created by Abhinav Saldi on 08/06/17.
 //  Copyright © 2017 Viewlift. All rights reserved.
 //
 
 import UIKit
 import AVFoundation
 import GoogleInteractiveMediaAds
 import AdSupport
 import AppsFlyerLib
 import GoogleCast
 import Firebase
 private var playbackLikelyToKeepUpContext = 0
 private let AdREQUEST = "Request"
 private let ADIMPRESSION = "Impression"
 
 enum autoPlayButtonAction : String
 {
    case play
    case cancel
 }
 
 enum PlayerType : String
 {
    case liveVideoPlayer
    case streamVideoPlayer
 }
 
 enum PlayerFit : String
 {
    case fullScreen
    case smallScreen
 }

 @objc protocol VideoPlayerDelegate: NSObjectProtocol {
    
    @objc func videoPlayerStartedPlaying() -> Void
    @objc func videoPLayerFinishedVideo() -> Void
    @objc func fullScreenVideoPlayer() -> Void
    @objc func exitFullScreenVideoPlayer() -> Void
    @objc optional func updateVideoPlayerForOrientation() -> Void
    @objc optional func didDisconnectCastDevice() -> Void
    @objc optional func didCreatedPlayerView() -> Void
 }

 class VideoObject: NSObject {
    var videoTitle: String = String()
    var videoContentId: String = String()
    var videoPlayerDuration: Double = Double()
    var videoWatchedTime:Double = Double()
    var gridPermalink: String = String()
    var primaryCategory : String = String()
    var contentRating :String = String()
    var videoFileBitRate : String = String()
    
 }
 
class CustomVideoController:  UIViewController, IMAAdsLoaderDelegate, IMAAdsManagerDelegate, CastPopOverViewDelegate, SFContentWarningVCDelegate, VideoPlayerControlsDelegate, SFButtonDelegate, StreamSelectorDelegate {
    
    
    let avPlayer = AVPlayer()
    private var avPlayerLayer: AVPlayerLayer!
    private var timeObserver: AnyObject!
    private var playerRateBeforeSeek: Float = 0
    private var loadingIndicatorView:UIActivityIndicatorView?
    
    private var isFullScreenPlayback: Bool = true
    
    weak var videoPlayerDelegate: VideoPlayerDelegate?
    
    private var themeColor: String!
    private var settingController: CustomPlayerSettingsScreenViewController!
    private var controlsDisplayed: Bool!
    private var timer: Timer = Timer()
    private var timerCounter: Int = 0
    var adView:UIView!
    private var adBar:UIView!
    private var adPlayButton:UIButton!
    private var videoUrlToBePlayed:String?
    private var videoObject: VideoObject
    private var progressIndicator:MBProgressHUD?
    private var contentPlayhead:IMAAVPlayerContentPlayhead?
    private var adsLoader:IMAAdsLoader?
    private var adsManager: IMAAdsManager?
    private var playerType: PlayerType
    var playerFit : PlayerFit
    var playerControls: CustomVideoPlayerControls?
    private var isSubTitleAvailable:Bool = false
    private var subTitleString:String = ""
    private var networkUnavailableAlert:UIAlertController?
    var autoPlayObjectArray : Array <Any>=[]
    private var autoPlayViewController : AutoPlayViewController!
    private var filmIndex = 1
    var isOpenFromDownload: Bool = false
    private var film : SFFilm
    
    private var isAutoPlayArrayPopulated : Bool = false
    private var isFilmProgressUpdateInSync: Bool = false
    private let networkStatus = NetworkStatus.sharedInstance
    private var isAirplaySheetVisible : Bool = false
    private var windowSubviews: Int = 0
    
    private var is25PercentUpdated: Bool = false, is50PercentUpdated: Bool = false, is75PercentUpdated: Bool = false, is100PercentUpdated: Bool = false
    
    //Content Warning
    private var isContentWarningScreenPresented:Bool = false
    private var isContentWarningScreenShowing:Bool = false
    private let isContentWaningEnable = AppConfiguration.sharedAppConfiguration.isContentRatingEnabled ?? false
    private var playBackStreamID:String?
    private var currentTimeStamp : Date?
    private var hitBufferEventAfter5Sec : Bool = false
    private var bufferTimer : Timer?
    private var lastPlayBackTime : Float = 0
    private var currentTimeStampForBuffer : Date?
    private var apodCount : Int = 0
    private var adTag:String?
    private var backgroundImageView:UIView!
    private var backImageView:SFImageView!
    private var playButton: SFButton?
    private var toolbarView:UIView?
    private var playImage:SFImageView?
    private var subscriptionCloseButton: UIButton!
    private var signInButton:UIButton?
    private var promptView :UIView!
    private var tranparentThumbnail:SFImageView!
    private var promptLabel :UILabel!
    private var trialButton :UIButton?
    private var imagePathString: String?
    private var popUpErrorMessage :String?
    var isForcePaused : Bool = false
    private var isFreeVideo:Bool = true
    private var isLiveStream:Bool = false
    private var isTokenAvailable:Bool = false
    private var tokenHeaderDetails:Dictionary<String,String> = [:]
    var forceFullScreen: Bool = false
    private var shouldPlayHlsUrlFirst:Bool = false
    private var isShowCastingPopUp:Bool = false
    var isFirstFrameSent : Bool = false //Used to check if beacon event for first frame has fired
    var isVideoPlayedFromGrids:Bool = false
    var isViewAppear:Bool = false
    var isPlayingEpisode = false
    var videoDuration:Double?
    private var shouldDisplayPreviewPerVideo:Bool = false
    private var isNetworkPopUpDisplayed:Bool = false
    private var isVideoComplete:Bool = false
    private var videoURLDictionary: Dictionary<String, String> = [:]
//    private var currentPlayedURLIndex: Int = 0
    private var currentPlayedKey: String = ""
    
    func setCastPopOverViewDelegate(vc: UIViewController) -> Void {
        CastPopOverView.shared.setCastPopOverViewDelegate(vc: vc)
    }

    init (videoObject: VideoObject, videoPlayerType: PlayerType, videoFitType: PlayerFit) {
        self.videoObject = videoObject
        self.film=SFFilm()
        self.playerType = videoPlayerType
        self.playerFit = videoFitType
        // self.film.id = videoObject.videoContentId
        super.init(nibName: nil, bundle: nil)
        self.setCastPopOverViewDelegate(vc: self)
    }
    
    func setPlayerFit(videoPlayerFit: PlayerFit) -> Void
    {
        self.playerFit = videoPlayerFit
        if self.playerFit == .fullScreen
        {
            forceFullScreen = true
            self.playerControls?.updateControls(with: .full)
        }
        else
        {
            self.playerControls?.updateControls(with: .small)
        }
    }
    
    func getVideoDetail() -> VideoObject
    {
        return self.videoObject
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func managePreviewTimer(isPlayerPaused: Bool) {
        
        if self.isFreeVideo == false {
            
            if isPlayerPaused == true {
                
                Constants.kPreviewEndEnforcer.startAppOnTimeTracking()
            }
            else {
                
                Constants.kPreviewEndEnforcer.pauseAppOnTimeTracking()
            }
        }
    }

    private func pauseAVPlayer() {
        self.avPlayer.pause()
        
        if AppConfiguration.sharedAppConfiguration.typeOfPreview == TypeOfPreview.completeApplication && AppConfiguration.sharedAppConfiguration.videoPreviewDuration != nil {
            
            self.managePreviewTimer(isPlayerPaused: false)
        }
    }

    private func playAVPlayer() {
        if self.adView != nil && self.adView.isHidden == false{
            self.adView.isHidden = true
        }
        if self.videoPlayerDelegate != nil && (self.videoPlayerDelegate?.responds(to: #selector(self.videoPlayerDelegate?.videoPlayerStartedPlaying)))!{
            self.videoPlayerDelegate?.videoPlayerStartedPlaying()
        }
        if AppConfiguration.sharedAppConfiguration.videoPreviewDuration != nil && AppConfiguration.sharedAppConfiguration.typeOfPreview == TypeOfPreview.completeApplication {
            
            if shouldPlayVideo() {

                if playerFit == .fullScreen {
                    
                    UIApplication.shared.isStatusBarHidden = true
                }

                self.avPlayer.play()
                
                if AppConfiguration.sharedAppConfiguration.typeOfPreview == TypeOfPreview.completeApplication {
                    
                    self.managePreviewTimer(isPlayerPaused: true)
                }
            }
            else{
                self.stopPlayback()
            }
        }
        else {
            
            if playerFit == .fullScreen {
                
                UIApplication.shared.isStatusBarHidden = true
            }

            self.avPlayer.play()
        }
    }

    private func shouldPlayVideo() -> Bool {
        
        var shouldPlay = false
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            
            let isSubscribed = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool ?? false)
            if isSubscribed == false {
                
                if self.isFreeVideo {
                    
                    shouldPlay = true
                }
                else {
                    
                    if Constants.kPreviewEndEnforcer.isPreviewAllowed {
                        
                        shouldPlay = true
                    } else {
                        
                        shouldPlay = false
                    }
                }
            }
            else {
                
                shouldPlay = true
            }
        }
        else {
            
            shouldPlay = true
        }
        return shouldPlay
    }
    
    
    @objc private func stopPlayback() {
        self.avPlayer.pause()
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
            Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name(rawValue: Constants.kDismissPIP), object: nil)
            self.showBackgroundImage(errorMessage: AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.overlayMessage ?? Constants.kGetMemberShipMessage)
            if self.forceFullScreen{
                self.videoPlayerBackButtonTapped()
            }
        }
        else{
            self.showBackgroundImage(errorMessage: AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.overlayMessage ?? Constants.kEntitlementErrorMessage)
        }
    }
    func check(forNetwork notification: Notification) {
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() == NotReachable {
            self.hideActivityIndicatorView()
            self.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
        }
    }

    func removeNotifications() throws {
        Constants.kNOTIFICATIONCENTER.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    //MARK: - View Controller Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.isNetworkPopUpDisplayed = false
        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: "isContentWarningForcefullyDismissed")
        Constants.kSTANDARDUSERDEFAULTS.synchronize()
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(stopPlayback), name: kPreviewEndEnforcerTimeUp, object: nil)
        Constants.kAPPDELEGATE.isBackgroundImageVisible = false

        self.view.backgroundColor = .black
        
        if let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!) {
            
            if let shouldPlayHlsFirst:Bool = dicRoot["shouldPlayHlsUrlFirst"] as? Bool {
                
                self.shouldPlayHlsUrlFirst = shouldPlayHlsFirst
            }
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleWirelessRoutesDidChange(notification:)), name: NSNotification.Name.MPVolumeViewWirelessRoutesAvailableDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAudioSessionEvent(notification:)), name:NSNotification.Name.AVAudioSessionInterruption, object: nil)
        
        if self.playerFit != PlayerFit.smallScreen {
            
            UIApplication.shared.isStatusBarHidden = true
        }
        
        self.controlsDisplayed = false
        
        if (self.isOpenFromDownload == true) {
            
            self.isViewAppear = true
            createVideoPlayer(urlString: videoObject.gridPermalink)
            checkViewStatus()
            if (self.autoPlayObjectArray.isEmpty == false) {
                
                self.autoPlayObjectArray.remove(at: 0)
            }
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.adView != nil && self.adView.isHidden == false{
            if self.adPlayButton != nil{
                self.adPlayButton.isSelected = true
            }
        }
        if self.adsManager != nil{
            self.adsManager?.pause()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isViewAppear = false
        if self.adView != nil && self.adView.isHidden == false{
            if self.adPlayButton != nil{
                self.adPlayButton.isSelected = true
            }
        }
        if self.adsManager != nil{
            self.adsManager?.pause()
        }

        self.pauseAVPlayer()
        UIApplication.shared.isStatusBarHidden = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ApplicationEnteredBackground"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ApplicationEnteredForeground"), object: nil)
        timer.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defer {
            Constants.kNOTIFICATIONCENTER.addObserver(self, selector:#selector(check(forNetwork:)), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        }
        do {
            try self.removeNotifications()
        }
        catch {
            print("Encountered error \(error)")
        }
        self.isViewAppear = true
        Constants.kAPPDELEGATE.isCastingViewVisible = false
        Constants.kAPPDELEGATE.isBackgroundImageVisible = false

        if self.playerFit != PlayerFit.smallScreen {
            if Constants.kSTANDARDUSERDEFAULTS.bool(forKey: "isContentWarningForcefullyDismissed") {
                
                if Constants.kAPPDELEGATE.isPlayMovieOnLandscapeOnly == true {
                    
                    UIApplication.shared.isStatusBarHidden = false
                    Constants.kAPPDELEGATE.isBackgroundImageVisible = true
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                    Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: "isContentWarningForcefullyDismissed")
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                }
            }
            else {
                
                UIApplication.shared.isStatusBarHidden = true
                if Constants.kAPPDELEGATE.isPlayMovieOnLandscapeOnly == true {
                    
                    if !forceFullScreen {
                        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                    }
                }
            }
        }
    
        if(CastPopOverView.shared.isConnected()){
            if (backgroundImageView == nil){
                DispatchQueue.main.async {
                    UIApplication.shared.isStatusBarHidden = false
                    if  UIDeviceOrientationIsLandscape(UIDevice.current.orientation) && Constants.IPHONE
                    {
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                    }
                    self.checkForInternetConnectionAndLoadVideo()

                }

                if self.playerFit == .fullScreen
                {
                    self.dismiss(animated: false) {
                        CastPopOverView.shared.delegate = nil
                    }
                }
            }
            else
            {
                self.showBackgroundImageForCasting()
            }
            return
        }
        
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(enteredBackground), name: NSNotification.Name("ApplicationEnteredBackground"), object: nil)
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(enteresForeground), name: NSNotification.Name("ApplicationEnteredForeground"), object: nil)
        Constants.kAPPDELEGATE.isAutoPlayPopUpVisible = false
        
        if (self.isOpenFromDownload == false) {
            
            if (backgroundImageView != nil) {
                self.removeBackgroundImageView()
                if  Utility.sharedUtility.checkIfMoviePlayable() == true || self.isFreeVideo {
                    self.checkForInternetConnectionAndLoadVideo()
                }
                else{
                    self.showBackgroundImage(errorMessage: popUpErrorMessage)
                }
            }
            else{
                checkForInternetConnectionAndLoadVideo()
            }
        }
        
        self.controlsDisplayed = false
        if self.avPlayer.currentItem != nil
        {
            if self.avPlayer.rate > 0
            {
                self.playerControls?.setPlayButtonState(state: true)
            }
            else
            {
                self.playerControls?.setPlayButtonState(state: false)
            }
        }
        if !self.isForcePaused
        {
            self.playMedia()
        }
    }
    
    
    func enteredBackground()
    {
        if self.playerControls != nil
        {
            if (self.playerControls?.isAirPlayRouteActive() ?? false)
            {
                return
            }
            
            if self.avPlayer.currentItem != nil
            {
                self.pauseAVPlayer()
            }
        }
    }
    
    
    func enteresForeground()
    {
        if self.playerControls != nil
        {
            if(self.playerControls?.getPlayButtonState() ?? false || self.forceFullScreen || self.playerFit == .smallScreen)
            {
                self.playMedia()
            }
            else{
                self.pauseAVPlayer()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: kPreviewEndEnforcerTimeUp, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        removeObserversFromVideoPlayer()
        do {
            try self.removeNotifications()
        }
        catch {
            print("Encountered error \(error)")
        }
    }
    
    
    private func removeObserversFromVideoPlayer() -> Void {
        if timeObserver != nil
        {
            avPlayer.removeTimeObserver(timeObserver)
            timeObserver = nil
        }
        
        if avPlayer.currentItem != nil
        {
            avPlayer.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            avPlayer.currentItem?.removeObserver(self, forKeyPath: "status")
            avPlayer.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            avPlayer.removeObserver(self, forKeyPath: "rate")
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: self.avPlayer.currentItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: self.avPlayer.currentItem)
            NotificationCenter.default.removeObserver(self, name: Notification.Name.MPVolumeViewWirelessRoutesAvailableDidChange, object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name.AVAudioSessionInterruption, object: nil)
            avPlayer.replaceCurrentItem(with: nil)
        }
    }
    
    
    private func fetchVideoDetailAndRelatedVideosForAutoPlay(filmID:String)
    {
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
        }
        else {
            let autoplayhandler = AutoPlayArrayHandler()
            autoplayhandler.getTheAutoPlaybackArrayForFilm(film:filmID){ (relatedVideoArray, filmObject) in
                
                if filmObject != nil {
                    
                    self.film=filmObject!
                    
                    if(self.autoPlayObjectArray.isEmpty) && relatedVideoArray != nil && !self.isPlayingEpisode {
                        
                        if(!self.isAutoPlayArrayPopulated)
                        {
                            self.isAutoPlayArrayPopulated = true
                            
                            for i in 0 ..< (relatedVideoArray?.count)!{
                                
                                let teamId: String? = relatedVideoArray![i] as? String
                                
                                if teamId != nil {
                                    
                                    if(teamId! != filmObject?.id)
                                    {
                                        self.autoPlayObjectArray.append(teamId!)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        checkViewStatus()
        let aTouch: UITouch = touches.first as! UITouch
        let point: CGPoint = aTouch.location(in: self.view)
        if self.subscriptionCloseButton != nil && self.subscriptionCloseButton.frame.contains(point) {
            closeButtonTapped(sender: self.subscriptionCloseButton)
        }
    }
    
    
    private func checkViewStatus() -> Void {
        
        if !self.controlsDisplayed
        {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerSelector), userInfo: nil, repeats: true)
        }
        
        controlAVPlayerControlItems()
    }
    
    
    func timerSelector() -> Void {
        if timerCounter > 3
        {
            timerCounter = 0
            controlAVPlayerControlItems()
            return
        }
        timerCounter = timerCounter + 1
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Layout subviews manually
        if self.avPlayerLayer != nil
        {
            avPlayerLayer.frame = view.bounds
        }
        
        if self.backgroundImageView != nil
        {
            backgroundImageView.frame = view.bounds
            if CastPopOverView.shared.isConnected() && self.isShowCastingPopUp == true{
                self.updateViewFrameForCastingPopup()
            }
            else{
                self.updateViewFrameForPopup()
            }
        }
        
        if self.loadingIndicatorView != nil {
            
            self.loadingIndicatorView?.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        }
        
        if adView != nil
        {
            adView.frame = self.view.bounds
            
            if adBar != nil && adPlayButton != nil {
                
                adBar.frame = CGRect(x: 0, y: adView.bounds.size.height - 40, width: adView.frame.size.width, height: 40)
                adPlayButton.frame = CGRect(x: adBar.frame.midX - (adPlayButton.currentImage?.size.width ?? 19)/2, y: (adBar.frame.size.height - (adPlayButton.currentImage?.size.height ?? 21))/2, width: (adPlayButton.currentImage?.size.width ?? 19), height: (adPlayButton.currentImage?.size.height ?? 21))
            }
        }
        
        if self.playerControls != nil
        {
            self.playerControls?.frame = self.view.bounds
            if self.playerFit == .fullScreen
            {
                self.view.frame = UIScreen.main.bounds
                self.playerControls?.frame = self.view.bounds
                self.playerControls?.updateControls(with: .full)

            }
            else
            {
                self.playerControls?.updateControls(with: .small)
            }
        }
        
        if self.subscriptionCloseButton != nil && self.playerFit == .fullScreen
        {
            var yAxis:CGFloat = 5
            
            if Utility.sharedUtility.isIphoneX() {
                
                yAxis += 20
            }
            
            self.subscriptionCloseButton.frame = CGRect.init(x: 5, y: yAxis, width: 23, height: 32)
        }
    }

    private func controlAVPlayerControlItems() -> Void
    {
        if self.playerControls != nil {
            if(self.checkIfAlertViewHasPresented())!{
                self.controlsDisplayed = false
            }
            let reachability:Reachability = Reachability.forInternetConnection()
            if reachability.currentReachabilityStatus() == NotReachable
            {
                self.playerControls?.updateControlsWithNoInternet()
            }
            
            self.playerControls?.isHidden = self.controlsDisplayed
            
            if(isSubTitleAvailable) {
                self.playerControls?.updateViewWithSubtitle(present: isSubTitleAvailable)
            }
        }
        self.controlsDisplayed = !self.controlsDisplayed
        
        
        if !self.controlsDisplayed
        {
            self.timer.invalidate()
        }
    }
    
    
    private func checkIfAlertViewHasPresented() -> Bool? {
        
        var keyWindow = UIApplication.shared.keyWindow
        if keyWindow == nil {
            keyWindow = UIApplication.shared.windows[0]
        }
        if windowSubviews == (keyWindow?.layer.sublayers?.count)!{
            self.isAirplaySheetVisible = false
        }
        if self.isAirplaySheetVisible
        {
            return true
        }
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
    
    func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .began {
            self.isAirplaySheetVisible = true
        }
        else if gesture.state == .ended {
            self.isAirplaySheetVisible = true
            var keyWindow = UIApplication.shared.keyWindow
            if keyWindow == nil {
                keyWindow = UIApplication.shared.windows[0]
            }
            windowSubviews = (keyWindow?.layer.sublayers?.count)!
        }
            
        else if gesture.state == .cancelled {
            self.isAirplaySheetVisible = true
        }
        else if gesture.state == .failed {
            self.isAirplaySheetVisible = true
        }
    }
    
    
    private func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        
        if avPlayer.currentItem != nil && !elapsedTime.isNaN && !elapsedTime.isInfinite && !duration.isNaN && !duration.isInfinite {
            
            if loadingIndicatorView != nil {
                if (loadingIndicatorView?.isAnimating)! {
                    loadingIndicatorView?.stopAnimating()
                }
            }
            
            //Added check to show preview
            if self.shouldDisplayPreview(currentDuration: Int(elapsedTime)) {
                
                self.pauseAVPlayer()
                
                if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                    self.showBackgroundImage(errorMessage: AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.overlayMessage ?? Constants.kGetMemberShipMessage)
                }
                else{
                    self.showBackgroundImage(errorMessage: AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.overlayMessage ?? Constants.kEntitlementErrorMessage)
                }
                
                return
            }
            
            let timeRemaining: Float64 = CMTimeGetSeconds(avPlayer.currentItem!.duration) - elapsedTime
            
            let hours: Float64 = timeRemaining / 3600
            
            if self.playerType != .liveVideoPlayer
            {
                if hours >= 1
                {
                    self.playerControls?.updateTimeLabel(timeLabelText: String(format: "%02d:%02d:%02d", ((lround(timeRemaining) / 3600) % 3600), ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60))
                }
                else
                {
                    self.playerControls?.updateTimeLabel(timeLabelText: String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60))
                }
                if elapsedTime > 0 && (self.avPlayer.rate == 1 || (self.playerControls?.isAirPlayRouteActive() ?? false)) {
                    
                    let currentDuration:Int = Int(elapsedTime)
                    
                    if currentDuration % 30 == 0 && currentDuration > 0 {
                        
                        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                            
                            updatePlayerProgressToServerAfterThirySeconds(currentTime: Double(currentDuration))
                        }
                        
                        fireBeaconEventAfterThirtySeconds(currentTime: Float(currentDuration))
                    }
                    
                    let film25percentValue: Int = Int(CMTimeGetSeconds(avPlayer.currentItem!.duration) * 0.25)
                    let film50percentValue: Int = Int(CMTimeGetSeconds(avPlayer.currentItem!.duration) * 0.50)
                    let film75percentValue: Int = Int(CMTimeGetSeconds(avPlayer.currentItem!.duration) * 0.75)
                    let film100percentValue: Int = Int(CMTimeGetSeconds(avPlayer.currentItem!.duration))
                    
                    var currentVideoPlayer: String = Constants.kGTMNativePlayer
                    
                    if self.isAudioSessionUsingAirplay() == true
                    {
                        currentVideoPlayer = Constants.kGTMAirplayPlayer
                    }
                    
                    
                    if currentDuration >= film25percentValue && currentDuration > 0
                    {
                        if is25PercentUpdated != true && Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                        {
                            is25PercentUpdated = true
                            FIRAnalytics.logEvent(withName: Constants.kGTMStream25PercentEvent, parameters: [Constants.kGTMVideoIDAttribute : self.videoObject.videoContentId, Constants.kGTMVideoNameAttribute: self.videoObject.videoTitle, Constants.kGTMSeriesIDAttribute: "", Constants.kGTMSeriesNameAttribute:"", Constants.kGTMVideoPlayerTypeAttribute : currentVideoPlayer, Constants.kGTMVideoMediaTypeAttribute: Constants.kGTMVideoContent])
                        }
                    }
                    if currentDuration >= film50percentValue && currentDuration > 0
                    {
                        if is50PercentUpdated != true && Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                        {
                            is50PercentUpdated = true
                            FIRAnalytics.logEvent(withName: Constants.kGTMStream50PercentEvent, parameters: [Constants.kGTMVideoIDAttribute : self.videoObject.videoContentId, Constants.kGTMVideoNameAttribute: self.videoObject.videoTitle, Constants.kGTMSeriesIDAttribute: "", Constants.kGTMSeriesNameAttribute:"", Constants.kGTMVideoPlayerTypeAttribute : currentVideoPlayer, Constants.kGTMVideoMediaTypeAttribute: Constants.kGTMVideoContent])
                        }
                    }
                    if currentDuration >= film75percentValue && currentDuration > 0
                    {
                        if is75PercentUpdated != true && Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                        {
                            is75PercentUpdated = true
                            FIRAnalytics.logEvent(withName: Constants.kGTMStream75PercentEvent, parameters: [Constants.kGTMVideoIDAttribute : self.videoObject.videoContentId, Constants.kGTMVideoNameAttribute: self.videoObject.videoTitle, Constants.kGTMSeriesIDAttribute: "", Constants.kGTMSeriesNameAttribute:"", Constants.kGTMVideoPlayerTypeAttribute : currentVideoPlayer, Constants.kGTMVideoMediaTypeAttribute: Constants.kGTMVideoContent])
                        }
                    }
                    if currentDuration == film100percentValue && currentDuration > 0
                    {
                        if is100PercentUpdated != true && Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                        {
                            is100PercentUpdated = true
                            FIRAnalytics.logEvent(withName: Constants.kGTMStream100PercentEvent, parameters: [Constants.kGTMVideoIDAttribute : self.videoObject.videoContentId, Constants.kGTMVideoNameAttribute: self.videoObject.videoTitle, Constants.kGTMSeriesIDAttribute: "", Constants.kGTMSeriesNameAttribute:"", Constants.kGTMVideoPlayerTypeAttribute : currentVideoPlayer, Constants.kGTMVideoMediaTypeAttribute: Constants.kGTMVideoContent])
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: Check movie to be played after preview duration
    private func shouldDisplayPreview(currentDuration:Int) -> Bool {
        
        var shouldDisplayMoviePreview:Bool = false
        
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && AppConfiguration.sharedAppConfiguration.videoPreviewDuration != nil && !self.isFreeVideo {
            
            if AppConfiguration.sharedAppConfiguration.typeOfPreview == TypeOfPreview.perVideo {
                
                let videoPreviewDurationInSeconds:Int = Int(AppConfiguration.sharedAppConfiguration.videoPreviewDuration!)! * 60
                
                if currentDuration > videoPreviewDurationInSeconds {
                    
                    if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) != nil {
                        
                        if !(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as! Bool) {
                            
                            shouldDisplayMoviePreview = true
                            shouldDisplayPreviewPerVideo = true
                        }
                    }
                    else {
                        
                        shouldDisplayMoviePreview = true
                        shouldDisplayPreviewPerVideo = true
                    }
                }
            }
            else {
                
                return !self.shouldPlayVideo()
            }
        }
//        else if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && !self.isFreeVideo {
//
//            shouldDisplayMoviePreview = true
//            shouldDisplayPreviewPerVideo = true
//        }
        
        return shouldDisplayMoviePreview
    }
    
    
    private func isAudioSessionUsingAirplay() -> Bool {
        let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
        let currentRoute: AVAudioSessionRouteDescription = audioSession.currentRoute
        for outPutPort in currentRoute.outputs
        {
            if outPutPort.portType == AVAudioSessionPortAirPlay
            {
                return true
            }
        }
        return false
    }
    
    
    func updateSlider(elapsedTime: Float64, duration: Float64) {
        
        if self.avPlayer.currentItem != nil {

            let currentTimeValue: Float =  Float(CMTimeGetSeconds(avPlayer.currentTime()) / CMTimeGetSeconds(avPlayer.currentItem!.duration))
            self.playerControls?.updateSliderValue(sliderValue: currentTimeValue)
        }
    }
    
    
    //MARK: - Observer & notifications listners
    func observeTime(elapsedTime: CMTime) {
        
        if avPlayer.currentItem != nil {
            
            let duration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
            
            if  duration > 0.0 {
                
                let elapsedTime = CMTimeGetSeconds(elapsedTime)
                updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
                
                if self.playerType == .streamVideoPlayer {
                    
                    updateSlider(elapsedTime: elapsedTime, duration: duration)
                }
            }
        }
    }
    
    
//    func handleWirelessRoutesDidChange(notification: NSNotification) -> Void {
//        let volumeView: MPVolumeView = notification.object as! MPVolumeView
//        if volumeView.isWirelessRouteActive
//        {
//            print("true 11111111111111")
//        }
//    }
    
    func onAudioSessionEvent(notification: Notification) {
        if notification.name != NSNotification.Name.AVAudioSessionInterruption
            || notification.userInfo == nil{
            return
        }
        var info = notification.userInfo!
        var intValue: UInt = 0
        (info[AVAudioSessionInterruptionTypeKey] as! NSValue).getValue(&intValue)
        if let type = AVAudioSessionInterruptionType.init(rawValue: intValue) {
            switch type {
            case .began:
                // interruption began
                break
            case .ended:
                // interruption ended
                if (self.avPlayer.rate == 0){
                    self.playMedia()
                }
                break
            }
        }
    }
    
    //Mark:  Cast Delegate Methods
    func didConnectToCastDevice() {
        
        self.hideActivityIndicatorView()
        self.pauseAVPlayer()
        if self.adsManager != nil{
            self.adsManager?.pause()
        }
        if forceFullScreen || self.playerFit == .smallScreen{
            if forceFullScreen{
                self.castVideo()
            }
            self.removeNotificationsAndSubviews(isBackButtonRemove: true)
            self.showBackgroundImageForCasting()
            self.videoPlayerBackButtonTapped()
        }
        else
        {
            self.castVideo()
        }
    }
    
    func didDisConnectToCastDevice(){
        Constants.kAPPDELEGATE.isCastingViewVisible = false
        Constants.kAPPDELEGATE.isBackgroundImageVisible = false
        let contentID = self.videoObject.videoContentId
        if (CastPopOverView.shared.getVideoContent() != nil) {
            self.removeNotificationsAndSubviews(isBackButtonRemove: true)
            self.removeBackgroundImageView()
            if (self.isOpenFromDownload == true){
                createVideoPlayer(urlString: "")
                checkViewStatus()
                if (self.autoPlayObjectArray.isEmpty == false && contentID != self.videoObject.videoContentId){
                    self.autoPlayObjectArray.remove(at: 0)
                }
            }
            else
            {
                self.removeNotificationsAndSubviews(isBackButtonRemove: true)
                DispatchQueue.main.async {
                    if self.videoPlayerDelegate != nil && (self.videoPlayerDelegate?.responds(to: #selector(self.videoPlayerDelegate?.didDisconnectCastDevice)))!{
                        self.videoPlayerDelegate?.didDisconnectCastDevice?()
                    }
                    else
                    {
                        self.checkForInternetConnectionAndLoadVideo()
                    }

                }
            }
        }
        else{

            if self.playerType == .liveVideoPlayer{
                DispatchQueue.main.async {
                    self.removeNotificationsAndSubviews(isBackButtonRemove: true)
                    self.checkForInternetConnectionAndLoadVideo()
                }
            }
            else
            {
                DispatchQueue.main.async {
                    UIApplication.shared.isStatusBarHidden = false
                    if  UIDeviceOrientationIsLandscape(UIDevice.current.orientation) && Constants.IPHONE
                    {
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                    }
                }

                self.dismiss(animated: false) {
                    CastPopOverView.shared.delegate = nil
                }
            }
        }
    }
    
    func castVideo(){
        
        if CastPopOverView.shared.isConnected() {
            
            if  Utility.sharedUtility.checkIfMoviePlayable() == true || self.isFreeVideo {
                Constants.kAPPDELEGATE.isCastingViewVisible = true
                if  UIDeviceOrientationIsLandscape(UIDevice.current.orientation) && Constants.IPHONE
                {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
                
                let ContentId = self.videoObject.videoContentId
                CastController().playSelectedItemRemotely(contentId: ContentId, isDownloaded:  self.isOpenFromDownload, relatedContentIds: self.autoPlayObjectArray, contentTitle: self.videoObject.videoTitle)
                
                if (self.playerControls != nil && !(self.playerControls?.getBackButtonTappedState())!)
                {
//                    let ExpTime = TimeInterval(60 * 60 * 24 * 365)
//                    HTTPCookieStorage.shared.removeCookies(since: Date.init(timeInterval: -ExpTime, since: Date()))
                    
                    self.playerControls?.setBackButtonTappedState(status: true)
                    self.pauseAVPlayer()
                    
                    UIApplication.shared.isStatusBarHidden = false
                    Constants.kAPPDELEGATE.isBackgroundImageVisible = true
                    removeObserversFromVideoPlayer()
                    
                    self.dismiss(animated: true) {
                        CastPopOverView.shared.delegate = nil
                    }
                }
            }
            else{
                var alertTitle = ""
                if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                    
                    if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                        
                        alertTitle = AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.overlayMessage ?? Constants.kGetMemberShipMessage
                    }
                    else {
                        
                        alertTitle = AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.overlayMessage ?? Constants.kEntitlementErrorMessage
                    }
                }
                else {
                    
                    alertTitle = Constants.kEntitlementLoginErrorMessage
                }
                
                self.showBackgroundImage(errorMessage: alertTitle)
            }
        }
    }
    
    func castButtonTapped(sender: AnyObject){
    }
    
    func displayNonEntitledUserAlert(errorMessage: String) {
        
        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
            
            
        }
        
        let signInAction = UIAlertAction(title: Constants.kStrSign, style: .default) { (signInAction) in
            
            //self.displayLoginScreen(button: button, filmObject: filmObject, loginCompeletionHandlerType: .UpdateVideoPlay)
        }
        
        let subscriptionAction = UIAlertAction(title: Constants.kStrSubscription, style: .default) { (subscriptionAction) in
            
            //self.displayPlanPage(button: button, filmObject: filmObject, loginCompeletionHandlerType: .UpdateVideoPlay)
        }
        
        var alertActionArray:Array<UIAlertAction>?
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            alertActionArray = [cancelAction, subscriptionAction]
        }
        else {
            
            alertActionArray = [cancelAction, signInAction, subscriptionAction]
        }
        
        let nonEntitledAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kEntitlementErrorTitle, alertMessage: errorMessage, alertActions: alertActionArray!)
        
        self.present(nonEntitledAlert, animated: true, completion: nil)
    }
    
    
    /// Method to remove the background Image View
    func removeBackgroundImageView() -> Void {
        Constants.kAPPDELEGATE.isBackgroundImageVisible = false
        if ((backgroundImageView) != nil){
            backgroundImageView.removeFromSuperview()
            backgroundImageView = nil
        }
    }
    
    /// Method to open login page
    ///
    /// - Parameter sender: UIButton
    func loginTapped(sender: UIButton) -> Void {
        UIApplication.shared.isStatusBarHidden = false
        let loginViewController: LoginViewController = LoginViewController.init()
        loginViewController.loginPageSelection = 0
        loginViewController.pageScreenName = "Sign In Screen"
        loginViewController.loginType = loginPageType.authentication
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: loginViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
    /// Method to open plan page to take subscription
    ///
    /// - Parameter sender: UIButton
    func startFreeTrialTapped(sender: UIButton) -> Void {
        UIApplication.shared.isStatusBarHidden = false
        let planViewController:SFProductListViewController = SFProductListViewController.init()
        planViewController.shouldUserBeNavigatedToHomePage = false
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: planViewController)
        self.present(navigationController, animated: true, completion: nil)
    }

    func buttonClicked(button: SFButton) {
        self.castVideo()
    }

    /// Method to show the popup on receive error message while playing movie
    ///
    /// - Parameter errorMessage: error message
    func showBackgroundImageForCasting() -> Void {
        Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name(rawValue: Constants.kDismissPIP), object: nil)
        var message : String?
        if let deviceSelected = CastPopOverView.shared.selectedDevice{
            if (CastPopOverView.shared.getVideoContent() != nil && CastPopOverView.shared.getVideoContent().videoContentId != ""){
                message = "Casting the \(CastPopOverView.shared.getVideoContent().videoTitle) to \(deviceSelected.friendlyName ?? "")."
            }
            else{
                message = "Touch to cast the video on your Chromecast device."
            }
            self.removeObserversFromVideoPlayer()
            self.removeNotificationsAndSubviews(isBackButtonRemove: false)
            self.removeBackgroundImageView()
            Constants.kAPPDELEGATE.isBackgroundImageVisible = true
            if  UIDeviceOrientationIsLandscape(UIDevice.current.orientation) && Constants.IPHONE
            {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
            self.isShowCastingPopUp = true
            backgroundImageView = UIView()
            backgroundImageView.frame = view.bounds
            self.view.addSubview(backgroundImageView)

            backImageView = SFImageView()
            backImageView.frame = backgroundImageView.bounds
            self.backgroundImageView.addSubview(backImageView)

            if imagePathString != nil
            {
                imagePathString = imagePathString?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: backgroundImageView.frame.size.width))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: backgroundImageView.frame.size.height))")

                if !(imagePathString?.isEmpty)! {

                    if let imageUrl = URL(string:imagePathString!) {

                        backImageView.af_setImage(
                            withURL: imageUrl,
                            placeholderImage: UIImage(named: Constants.kPosterImagePlaceholder),
                            filter: nil,
                            imageTransition: .crossDissolve(0.2)
                        )
                    }
                    else {

                        backImageView.image = UIImage(named: Constants.kPosterImagePlaceholder)
                    }
                }
            }
            else
            {
                backImageView.image = UIImage(named: Constants.kPosterImagePlaceholder)
            }
            playButton = SFButton(frame: CGRect.zero)
            playButton?.relativeViewFrame = self.backgroundImageView.frame
            playButton?.buttonDelegate = self
            playButton?.createButtonView()
            playButton?.center = self.backgroundImageView.center
            playButton?.frame = self.backgroundImageView.bounds
            self.backgroundImageView.addSubview(playButton!)
            self.view.sendSubview(toBack: backgroundImageView)

            toolbarView = UIView()
            toolbarView?.backgroundColor = UIColor.black
            toolbarView?.alpha = 0.78
            self.backgroundImageView.addSubview(toolbarView!)

            playImage = SFImageView()
            playImage?.image = UIImage(named: "play_light")
            self.toolbarView?.addSubview(playImage!)


            if let popUpMessage = message {

                self.removeAllSubviewsOnPromtView()
                if self.subscriptionCloseButton != nil{
                    self.subscriptionCloseButton.isHidden = false
                }
                self.showPopUpForCasting(message: popUpMessage)
                self.updateViewFrameForCastingPopup()
            }
            self.backgroundImageView.bringSubview(toFront: playButton!)
        }

    }

    func updateViewFrameForCastingPopup(){
        backImageView.frame = backgroundImageView.bounds
        playButton?.frame = backgroundImageView.bounds
        playButton?.center = backgroundImageView.center
        if Constants.IPHONE {
            promptView.frame = CGRect(x: 0, y: 0, width: 300, height: 110)
            promptView.layer.cornerRadius = 6.0
            tranparentThumbnail.frame = CGRect(x: 0, y: 0, width: promptView.frame.size.width, height: promptView.frame.size.height)
            promptLabel.frame = CGRect(x: 0, y: 10, width: promptView.frame.size.width, height: promptView.frame.size.height - 20)
            promptLabel.font = UIFont (name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 19)
            promptView.center = backgroundImageView.center
            toolbarView?.frame = CGRect(x: 0, y: backImageView.frame.height - 50, width: backImageView.frame.size.width, height: 50)
            playImage?.frame = CGRect(x: 0, y: 7, width: 35, height: 35)
        }
        else{
            promptView.frame = CGRect(x: 0, y: 0, width: 600, height: 125)
            promptView.center = backgroundImageView.center
            promptView.layer.cornerRadius = 6.0
            promptView.clipsToBounds = true
            tranparentThumbnail.frame = CGRect(x: 0, y: 0, width: promptView.frame.size.width, height: promptView.frame.size.height)
            promptLabel.frame = CGRect(x: 33, y: 10, width: promptView.frame.size.width - 66, height: promptView.frame.size.height - 20)
            promptLabel.font = UIFont (name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 21)
            toolbarView?.frame = CGRect(x: 0, y: backImageView.frame.height - 75, width: backImageView.frame.size.width, height: 75)
            playImage?.frame = CGRect(x: 0, y: 15, width: 46, height: 46)
        }
    }


    /// Method to show popup for guest user
    ///
    /// - Parameter errorMessage: error message
    func showPopUpForCasting(message:String) -> Void {
        promptView = UIView()
        promptView.backgroundColor = UIColor.clear
        backgroundImageView.addSubview(promptView)

        tranparentThumbnail = SFImageView()
        tranparentThumbnail.backgroundColor = UIColor.black
        tranparentThumbnail.alpha = 0.78
        promptView.addSubview(tranparentThumbnail)

        promptLabel = UILabel()
        promptLabel.textAlignment = .center;
        promptLabel.textColor = UIColor.white;
        promptLabel.numberOfLines = 3;
        promptLabel.text = message
        promptView.addSubview(promptLabel)
    }



    /// Method to show popup for guest user
    ///
    /// - Parameter errorMessage: error message
    func showPopUpForGuestUser(errorMessage:String) -> Void {
        promptView = UIView()
        promptView.backgroundColor = UIColor.clear
        backgroundImageView.addSubview(promptView)
        
        tranparentThumbnail = SFImageView()
        tranparentThumbnail.backgroundColor = UIColor.black
        tranparentThumbnail.alpha = 0.78
        promptView.addSubview(tranparentThumbnail)
        
        promptLabel = UILabel()
        promptLabel.textAlignment = .center;
        promptLabel.textColor = UIColor.white;
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
            promptLabel.numberOfLines = 3;
        }
        else{
            promptLabel.numberOfLines = 2;
        }
        
        promptLabel.minimumScaleFactor = 0.5
        promptLabel.adjustsFontSizeToFitWidth = true
        promptLabel.text = errorMessage
        promptLabel.minimumScaleFactor = 0.5
        promptLabel.adjustsFontSizeToFitWidth = true
        promptView.addSubview(promptLabel)
        
        signInButton = UIButton.init(type: UIButtonType.custom)
        signInButton?.addTarget(self, action: #selector(loginTapped(sender:)), for: .touchUpInside)

        signInButton?.setTitle(AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.loginButtonText ?? "LOG IN", for: .normal)
        signInButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        if Constants.IPHONE {
            signInButton?.titleLabel?.font = UIFont (name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 12)
        }
        else{
            signInButton?.titleLabel?.font = UIFont (name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 15)
        }
        
        promptView.addSubview(signInButton!)
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            trialButton = UIButton.init(type: UIButtonType.custom)
            trialButton?.addTarget(self, action: #selector(startFreeTrialTapped(sender:)), for: .touchUpInside)
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                trialButton?.setTitle(AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.subscriptionButtonText ?? Constants.kStartFreetrialButton.uppercased(), for: .normal)
            }
            else{
                trialButton?.setTitle(AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.subscriptionButtonText ?? Constants.startSubscriptionString.uppercased(), for: .normal)
            }

            trialButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
            if Constants.IPHONE {
                trialButton?.titleLabel?.font = UIFont (name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 12)
            }
            else{
                trialButton?.titleLabel?.font = UIFont (name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 15)
            }
            
            promptView.addSubview(trialButton!)
        }
    }
    
    /// Method to show the popup for unsubscribe user
    ///
    /// - Parameter errorMessage: error message
    func showPopUpForUnSubscribedUser(errorMessage:String) -> Void {
        promptView = UIView()
        promptView.backgroundColor = UIColor.clear
        backgroundImageView.addSubview(promptView)
        
        tranparentThumbnail = SFImageView()
        tranparentThumbnail.backgroundColor = UIColor.black
        tranparentThumbnail.alpha = 0.78
        promptView.addSubview(tranparentThumbnail)
        
        promptLabel = UILabel()
        promptLabel.textAlignment = .center;
        promptLabel.textColor = UIColor.white;
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
            promptLabel.numberOfLines = 3;
        }
        else{
            promptLabel.numberOfLines = 2;
        }
        promptLabel.text = errorMessage
        promptLabel.minimumScaleFactor = 0.5
        promptLabel.adjustsFontSizeToFitWidth = true
        promptView.addSubview(promptLabel)
        
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            trialButton = UIButton.init(type: UIButtonType.custom)
            trialButton?.addTarget(self, action: #selector(startFreeTrialTapped(sender:)), for: .touchUpInside)
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                trialButton?.setTitle(AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.subscriptionButtonText ?? Constants.kStartFreetrialButton.uppercased(), for: .normal)
            }
            else{
                trialButton?.setTitle(AppConfiguration.sharedAppConfiguration.subscriptionOverlayObject?.subscriptionButtonText ?? Constants.startSubscriptionString.uppercased(), for: .normal)
            }
            trialButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
            if Constants.IPHONE {
                trialButton?.titleLabel?.font = UIFont (name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 12)
            }
            else{
                trialButton?.titleLabel?.font = UIFont (name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 15)
            }
            
            promptView.addSubview(trialButton!)
        }
    }
    
    /// Method to update the subview's frame
    func updateViewFrameForPopup() -> Void {
        backImageView.frame = backgroundImageView.bounds
        let spacer : CGFloat = (TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased()) ? 10 : 0
        if Constants.IPHONE {
            
            promptView.frame = CGRect(x: 0, y: 0, width: 300, height: 150)
            promptView.layer.cornerRadius = 6.0
            tranparentThumbnail.frame = CGRect(x: 0, y: 0, width: promptView.frame.size.width, height: promptView.frame.size.height)
            promptLabel.frame = CGRect(x: 0, y: 20, width: promptView.frame.size.width, height: 60)
            signInButton?.frame = CGRect(x: promptLabel.frame.origin.x + 15, y: promptLabel.frame.origin.y + promptLabel.frame.size.height + spacer, width: 124, height: 40)
            if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                if signInButton != nil {
                    trialButton?.frame = CGRect(x: 162, y: promptLabel.frame.origin.y + promptLabel.frame.size.height + spacer, width: 124, height: 40)
                }
                else{
                    trialButton?.frame = CGRect(x: (promptView.frame.size.width - 180) / 2, y: promptLabel.frame.origin.y + promptLabel.frame.size.height + 10, width: 180, height: 40)
                }

            }
            
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                promptLabel.font = UIFont (name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 14)
            }
            else{
                promptLabel.font = UIFont (name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 19)
            }
            promptView.center = backgroundImageView.center
        }
        else{
            promptView.frame = CGRect(x: 0, y: 0, width: 600, height: 125)
            promptView.center = backgroundImageView.center
            promptView.layer.cornerRadius = 6.0
            promptView.clipsToBounds = true
            tranparentThumbnail.frame = CGRect(x: 0, y: 0, width: promptView.frame.size.width, height: promptView.frame.size.height)
            promptLabel.frame = CGRect(x: 33, y: 10, width: promptView.frame.size.width - 66, height: 46)
            signInButton?.frame = CGRect(x: promptLabel.frame.origin.x + (promptLabel.frame.size.width - 325) / 2, y: promptLabel.frame.origin.y + promptLabel.frame.size.height + 9, width: 140, height: 40)
            if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                if(signInButton != nil){
                    trialButton?.frame = CGRect(x: 290, y: (signInButton?.frame.origin.y)!, width: 140 + spacer, height: 40)
                }
                else{
                    trialButton?.frame = CGRect(x: (promptView.frame.size.width - 250)/2, y: promptLabel.frame.origin.y + promptLabel.frame.size.height + 10, width: 250, height: 40)
                }
            }
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                promptLabel.font = UIFont (name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 16)
            }
            else{
                promptLabel.font = UIFont (name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 21)
            }
        }
        if self.subscriptionCloseButton != nil && self.playerFit == .fullScreen
        {
            self.subscriptionCloseButton.isUserInteractionEnabled = true
            self.subscriptionCloseButton.isHidden = false
            
            var yAxis:CGFloat = 5
            
            if Utility.sharedUtility.isIphoneX() {
                
                yAxis += 20
            }
            
            self.subscriptionCloseButton.frame = CGRect.init(x: 5, y: yAxis, width: 23, height: 32)
            self.backImageView.addSubview(self.subscriptionCloseButton)
            self.backImageView.bringSubview(toFront: self.subscriptionCloseButton)
        }
    }
    
    func removeAllSubviewsOnPromtView() -> Void {
        if(signInButton != nil){
            signInButton?.removeFromSuperview()
            signInButton = nil
        }
        if(tranparentThumbnail != nil){
            tranparentThumbnail.removeFromSuperview()
            tranparentThumbnail = nil
        }
        if(promptLabel != nil){
            promptLabel.removeFromSuperview()
            promptLabel = nil
        }
        if(trialButton != nil){
            trialButton?.removeFromSuperview()
            trialButton = nil
        }
        if(promptView != nil){
            promptView?.removeFromSuperview()
            promptView = nil
        }
        
    }
    
    /// Method to show the popup on receive error message while playing movie
    ///
    /// - Parameter errorMessage: error message
    func showBackgroundImage(errorMessage:String?) -> Void {
        
        popUpErrorMessage = errorMessage
        self.removeNotificationsAndSubviews(isBackButtonRemove: false)
        self.removeBackgroundImageView()
        Constants.kAPPDELEGATE.isBackgroundImageVisible = true
        if  UIDeviceOrientationIsLandscape(UIDevice.current.orientation) && Constants.IPHONE
        {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
        self.isShowCastingPopUp = false
        backgroundImageView = UIView()
        backgroundImageView.frame = view.bounds
        self.view.addSubview(backgroundImageView)
        
        backImageView = SFImageView()
        backImageView.frame = backgroundImageView.bounds
        self.backgroundImageView.addSubview(backImageView)
        
        //Updated as per new requirement
        backImageView.backgroundColor = .black
//        if imagePathString != nil
//        {
//            imagePathString = imagePathString?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: backgroundImageView.frame.size.width))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: backgroundImageView.frame.size.height))")
//
//            if !(imagePathString?.isEmpty)! {
//
//                if let imageUrl = URL(string:imagePathString!) {
//
//                    backImageView.af_setImage(
//                        withURL: imageUrl,
//                        placeholderImage: UIImage(named: Constants.kPosterImagePlaceholder),
//                        filter: nil,
//                        imageTransition: .crossDissolve(0.2)
//                    )
//                }
//                else {
//
//                    backImageView.image = UIImage(named: Constants.kPosterImagePlaceholder)
//                }
//            }
//        }
//        else
//        {
//            backImageView.image = UIImage(named: Constants.kPosterImagePlaceholder)
//        }
        
        self.view.sendSubview(toBack: backgroundImageView)
        
        if let message = errorMessage {
            
            self.removeAllSubviewsOnPromtView()
            if self.subscriptionCloseButton != nil{
                self.subscriptionCloseButton.isHidden = false
            }

            if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest()  {
                
                //show popup for unsubscribed user
                self.showPopUpForUnSubscribedUser(errorMessage: message)
            }
            else {
                
                //show popup for guest user
                self.showPopUpForGuestUser(errorMessage: message)
            }
            
            self.updateViewFrameForPopup()
        }
    }
    
    
    //MARK: - View Creation Method
    func createVideoPlayer(urlString: String) -> Void {
        view.backgroundColor = .black
        var urlStringLocal = ""
        var url:URL? = nil

        if Utility.sharedUtility.checkIfMovieIsDownloaded(fileID : videoObject.videoContentId) {
            
            urlStringLocal = DownloadManager.sharedInstance.getMP4UrlPathForTheDownloadObject(forFileId: videoObject.videoContentId);
            url = URL(fileURLWithPath: urlStringLocal)
            self.fetchSubtitleForDownloadedVideo()
        }
        else
        {
            var urlStringLocal: String = urlString.trimmingCharacters(in: NSCharacterSet.whitespaces)
            urlStringLocal = Utility.urlEncodedString_ch(emailStr: urlStringLocal)
            url = URL(string: urlStringLocal)!
        }

        if avPlayerLayer != nil{
            avPlayerLayer.removeFromSuperlayer()
            avPlayerLayer = nil
        }

        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
//        if tokenHeaderDetails.count > 0 {
//
//            var cookieArray:Array<HTTPCookie>?
//            for (keyName, keyValue) in tokenHeaderDetails {
//
//                let localCookie:HTTPCookie? = self.setCookie(key: keyName, value: keyValue as AnyObject, url: "vhoichoitest.viewlift.com")
//
//                if localCookie != nil {
//
//                    if cookieArray == nil {
//
//                        cookieArray = []
//                    }
//
//                    cookieArray?.append(localCookie!)
//                }
//            }
//
//            if cookieArray != nil {
//
//                HTTPCookieStorage.shared.setCookies(cookieArray!, for: url!, mainDocumentURL: url!)
//            }
//        }
//
//        if HTTPCookieStorage.shared.cookies != nil {
//
//            let urlAsset = AVURLAsset.init(url: url!, options: [AVURLAssetHTTPCookiesKey : (HTTPCookieStorage.shared.cookies)!])
//            let playerItem = AVPlayerItem.init(asset: urlAsset)
//            avPlayer.replaceCurrentItem(with: playerItem)
//        }
//        else {
        
            let playerItem = AVPlayerItem(url: url!)
            avPlayer.replaceCurrentItem(with: playerItem)
//        }
       
        self.trackAnalyticsEventsForFilmViewing()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            //print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                //print("AVAudioSession is Active")
            } catch _ as NSError {
                //print(error.localizedDescription)
            }
        } catch _ as NSError {
            //print(error.localizedDescription)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerItemDidFinishedPlaying(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerItemDidStalledPlayback(notification:)), name: .AVPlayerItemPlaybackStalled, object: self.avPlayer.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerItemDidFailedToPlayToEnd(notification:)), name: .AVPlayerItemFailedToPlayToEndTime, object: self.avPlayer.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerItemPlayerError(notification:)), name: .AVPlayerItemNewErrorLogEntry, object: self.avPlayer.currentItem)

        self.avPlayer.addObserver(self, forKeyPath: "rate", options: .initial, context: nil)
        if self.playerControls != nil {
            self.playerControls?.removeFromSuperview()
            self.playerControls = nil
        }
        if self.playerType == .liveVideoPlayer
        {
            self.playerControls = CustomVideoPlayerControls.init(frame: self.view.bounds, videoDetailObject: self.videoObject, videoPlayerType: .liveVideoControls)
        }
        else
        {
            if isOpenFromDownload || Utility.sharedUtility.checkIfMovieIsDownloaded(fileID: videoObject.videoContentId)
            {
                self.playerControls = CustomVideoPlayerControls.init(frame: self.view.bounds, videoDetailObject: self.videoObject, videoPlayerType: .downloadedControls)
            }
            else
            {
                self.playerControls = CustomVideoPlayerControls.init(frame: self.view.bounds, videoDetailObject: self.videoObject, videoPlayerType: .streamVideoControls)
            }
        }

        
        if self.playerControls != nil
        {
            self.playerControls?.createView(subtitleUrlString: self.subTitleString, isSubtitleAvailable: self.isSubTitleAvailable)
            self.playerControls?.playerControlDelegate = self
            self.view.addSubview(playerControls!)
            if self.playerFit == .fullScreen && self.forceFullScreen == false
            {
                self.playerControls?.updateControls(with: .full)
            }
            else
            {
                self.playerControls?.updateControls(with: .small)
            }
            if self.videoURLDictionary.count > 0
            {
                let urlKeysArray: Array<String> = Array(self.videoURLDictionary.keys)
                self.playerControls?.updateSettingButtonLabel(streamQualityString: self.currentPlayedKey)
            }
        }
        
        self.subscriptionCloseButton = UIButton.init(type: UIButtonType.custom)
        
        var yAxis:CGFloat = 5
        
        if Utility.sharedUtility.isIphoneX() {
            
            yAxis += 20
        }
        
        self.subscriptionCloseButton.frame = CGRect(x: 5, y: yAxis, width: 23, height: 32)
        self.subscriptionCloseButton.setImage(#imageLiteral(resourceName: "Back.png"), for: .normal)
        self.subscriptionCloseButton.addTarget(self, action: #selector(closeButtonTapped(sender:)), for: .touchUpInside)
        self.subscriptionCloseButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
//        self.subscriptionCloseButton.isHidden = false
        
        self.videoPLayerAddTimerForElapsedTimeLabel()
        
        avPlayer.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp",
                                          options: .new, context: nil)
        avPlayer.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        avPlayer.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
       
        
        var beaconDict : Dictionary<String,String> = [:]
        beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId
        beaconDict[Constants.kBeaconUrlKey]=BeaconEvent.generateURL(movieName: videoObject.videoTitle)
        beaconDict[Constants.kBeaconRefKey]=Constants.kBeaconViewingFilmPage
        beaconDict[Constants.kBeaconPaKey]=Constants.kBeaconEventTypePlay
        beaconDict[Constants.kBeaconVposKey]=String(self.videoObject.videoWatchedTime)
        beaconDict[Constants.kBeaconAposKey]=String(self.videoObject.videoWatchedTime)
        beaconDict[Constants.kBeaconPlayerKey]=self.getCurrentPlayer()
        beaconDict[Constants.kBeaconTstampoverrideKey]=BeaconEvent.getCurrentTimeStamp()
        beaconDict[Constants.kBeaconStream_idKey]=self.playBackStreamID
        beaconDict[Constants.kBeaconMedia_typeKey]=Constants.kBeaconEventMediaTypeVideo
        beaconDict[Constants.kBeaconDp2Key]=Utility.sharedUtility.getDp2ParameterForBeaconEvent(fileName: videoObject.videoContentId)
        let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
        DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
        currentTimeStamp = Date()
        
        //GA play event
        let gaTracker = GAI.sharedInstance().defaultTracker
        
        if gaTracker != nil {
            
            gaTracker?.allowIDFACollection = true
            gaTracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "player-video", action: "playVideo", label: videoObject.videoTitle, value: NSNumber(value: -1)).build() as! [AnyHashable : Any]!)
        }
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            var pageTitle = "Player Screen - "
            pageTitle += self.videoObject.videoTitle
            if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
            {
                FIRAnalytics.setScreenName(pageTitle, screenClass: nil)
            }
        }
        
        if self.isOpenFromDownload
        {
            if DownloadManager.sharedInstance.downloadingObjectsContainsFile(withID: videoObject.videoContentId)
            {
                for downloadObject in DownloadManager.sharedInstance.globalDownloadArray
                {
                    if self.videoObject.videoContentId == downloadObject.fileID
                    {
                        self.videoObject.videoWatchedTime = Utility.sharedUtility.getWatchedDurationForVideo(watchedDuration: Double(downloadObject.fileWatchedPercentage) * self.videoObject.videoPlayerDuration / 100, totalDurarion: self.videoObject.videoPlayerDuration)
                        
                        self.avPlayer.seek(to: CMTimeMakeWithSeconds(self.videoObject.videoWatchedTime, 100))
                    }

                }
            }
        }
        else
        {
            if self.videoObject.videoWatchedTime > 0
            {
                self.avPlayer.seek(to: CMTimeMakeWithSeconds(self.videoObject.videoWatchedTime, 100))
            }
        }
        
        if isOpenFromDownload == true {
            
            self.playerControls?.setPlayButtonState(state: true)
            if(!videoObject.contentRating.isEmpty && isContentWaningEnable && videoObject.contentRating != "NR" && (self.videoObject.videoWatchedTime == 0 || self.videoObject.videoWatchedTime == 100))
            {
                self.perform(#selector(showContentWarningScreen), with: nil, afterDelay: 0.2)
            }
            else
            {
                self.playMedia()
            }
        }
        if self.videoPlayerDelegate != nil && (self.videoPlayerDelegate?.responds(to: #selector(self.videoPlayerDelegate?.didCreatedPlayerView)))!{
            self.videoPlayerDelegate?.didCreatedPlayerView?()
        }
    }
    
    private func addObserverOnVideoPlayerItem()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerItemDidFinishedPlaying(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerItemDidStalledPlayback(notification:)), name: .AVPlayerItemPlaybackStalled, object: self.avPlayer.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerItemDidFailedToPlayToEnd(notification:)), name: .AVPlayerItemFailedToPlayToEndTime, object: self.avPlayer.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerItemPlayerError(notification:)), name: .AVPlayerItemNewErrorLogEntry, object: self.avPlayer.currentItem)

        avPlayer.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp",
                                          options: .new, context: nil)
        avPlayer.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        avPlayer.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
    }
    
    private func removeObserverFromVideoPlayerItem()
    {
        if avPlayer.currentItem != nil
        {
            avPlayer.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            avPlayer.currentItem?.removeObserver(self, forKeyPath: "status")
            avPlayer.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: self.avPlayer.currentItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: self.avPlayer.currentItem)
            avPlayer.replaceCurrentItem(with: nil)
        }
    }
    
    private func setCookie(key: String, value:AnyObject, url:String) -> HTTPCookie? {
        
        let ExpTime = TimeInterval(60 * 60 * 24 * 365)

        let cookieProps: [HTTPCookiePropertyKey : Any] = [
            HTTPCookiePropertyKey.domain: url,
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: key,
            HTTPCookiePropertyKey.value: value,
            HTTPCookiePropertyKey.secure: "TRUE",
            HTTPCookiePropertyKey.expires: Date.init(timeInterval: ExpTime, since: Date())
        ]

        let cookie = HTTPCookie(properties: cookieProps)
        
        return cookie
    }
    
    func closeButtonTapped(sender: UIButton)
    {
//        let ExpTime = TimeInterval(60 * 60 * 24 * 365)
//        HTTPCookieStorage.shared.removeCookies(since: Date.init(timeInterval: -ExpTime, since: Date()))
        
        self.pauseAVPlayer()
        
        UIApplication.shared.isStatusBarHidden = false
        Constants.kAPPDELEGATE.isBackgroundImageVisible = true
        removeObserversFromVideoPlayer()
        self.dismiss(animated: true) {
            CastPopOverView.shared.delegate = nil
        }
    }
    
    //MARK: Fetch Subtitle for DownloadedVideo
    func fetchSubtitleForDownloadedVideo()  {
        
        let filePath: String = DownloadManager.sharedInstance.storageManager.checkIfFileExist(inDownloads: videoObject.videoContentId, andType: "srt")
        let filePathLength = Int(filePath.count)
        if  filePathLength > 0 {
            
            let ccPathLocal = DownloadManager.sharedInstance.getSubTitleFilePathForTheDownloadObject(forFileId: videoObject.videoContentId)
            self.subTitleString = ccPathLocal
            self.isSubTitleAvailable = true
        }
    }
    
    func checkForInternetConnectionAndLoadVideo() {
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() == NotReachable {

            if self.isOpenFromDownload == false {
                
                DispatchQueue.main.async {
                    if self.isNetworkPopUpDisplayed == false{
                        self.isNetworkPopUpDisplayed = true
                        self.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
                    }
                }
            }
        }
        else {
            
            if self.avPlayer.currentItem == nil {
                self.removeNotificationsAndSubviews(isBackButtonRemove: true)
                if AppConfiguration.sharedAppConfiguration.videoAdTag != nil {
                    
                    if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                        
                        if let isSubscribed = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool {
                            
                            if !isSubscribed {
                                
                                adTag = AppConfiguration.sharedAppConfiguration.videoAdTag!
                            }
                        }
                        else {
                            
                            adTag = AppConfiguration.sharedAppConfiguration.videoAdTag!
                        }
                    }
                    else {
                        
                        adTag = AppConfiguration.sharedAppConfiguration.videoAdTag!
                    }
                }

                if adTag != nil {
                    
                    createAdView()
                }

                self.perform(#selector(showActivityIndicatorView), with: nil, afterDelay: 0.001)
                fetchTokenDetails()
            }
            else if (CastPopOverView.shared.isConnected() == true){
                self.removeNotificationsAndSubviews(isBackButtonRemove: true)
                self.showBackgroundImageForCasting()
            }
        }

    }
    
    func enableViewTouchEvents(withTochEnabled isEnabled: Bool) -> Void {
        self.playerControls?.setUserInteractionForControls(userInteraction: isEnabled)
    }
    
    
    //MARK: Method to fetch Token details
    private func fetchTokenDetails() {
        
//        if self.isTokenAvailable == false {
//
//            let ExpTime = TimeInterval(60 * 60 * 24 * 365)
//            HTTPCookieStorage.shared.removeCookies(since: Date.init(timeInterval: -ExpTime, since: Date()))
//
//            DataManger.sharedInstance.fetchTokenForVideoUrl(contentId: self.videoObject.videoContentId) { (tokenHeaderDetails, isSuccess) in
//
//                if tokenHeaderDetails != nil && isSuccess {
//
//                    self.tokenHeaderDetails = tokenHeaderDetails!
//                    self.isTokenAvailable = true
//                }
//
//                self.fetchVideoURLToBePlayed()
//            }
//        }
//        else {
        
            self.fetchVideoURLToBePlayed()
//        }
    }
    
    
    //MARK: Method to fetch Video URL to play
    private func fetchVideoURLToBePlayed() {
        
        DataManger.sharedInstance.fetchURLDetailsForVideo(apiEndPoint: "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/videos/\(self.videoObject.videoContentId)?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&fields=streamingInfo,gist(free,videoImageUrl,posterImageUrl,imageGist),contentDetails(closedCaptions,relatedVideoIds)") { (videoURLWithStatusDict) in
            
            if videoURLWithStatusDict != nil {
                
                self.isFreeVideo = videoURLWithStatusDict?["isFreeVideo"] as! Bool
                
                let imageUrlsDict:Dictionary<String, String>? = videoURLWithStatusDict?["imageUrls"] as? Dictionary<String, String>
                
                if imageUrlsDict != nil {
                    
                    self.parseVideoBackgroundImageUrl(imageUrlsDict: imageUrlsDict!)
                }
                
                if self.isSubTitleAvailable == false && (DownloadManager.sharedInstance.checkIfFolderExist(withFileName: self.videoObject.videoContentId) == false)
                {
                    let subTitleDict:Dictionary<String, AnyObject>? = videoURLWithStatusDict?["subTitles"] as? Dictionary<String, AnyObject>
                    
                    if subTitleDict != nil {
                        
                        self.parseSubTitles(subTitleDict: subTitleDict!)
                    }
                }
                
                if self.autoPlayObjectArray.isEmpty && !self.isPlayingEpisode {
                    
                    let relatedVideoIds:Array<Any>? = videoURLWithStatusDict?["relatedVideoIds"] as? Array<Any>
                    
                    if relatedVideoIds != nil {
                        
                        self.autoPlayObjectArray = relatedVideoIds!
                    }
                }
                
                let filmURLs:Dictionary<String, AnyObject>? = videoURLWithStatusDict?["urls"] as? Dictionary<String, AnyObject>
                
                if filmURLs != nil {
                    
                    if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                        
                        DataManger.sharedInstance.getVideoStatus(videoId: self.videoObject.videoContentId, success: { (videoStatusResponseDict, isSuccess) in
                            
                            DispatchQueue.main.async {
                                
                                if videoStatusResponseDict != nil && isSuccess {
                                    
                                    if videoStatusResponseDict?["watchedTime"] != nil {
                                        
                                        if self.videoDuration != nil {
                                            self.videoObject.videoWatchedTime = self.videoDuration!
                                        }
                                        else {
                                         
                                            self.videoObject.videoWatchedTime = (videoStatusResponseDict?["watchedTime"] as! Double)
                                            self.videoObject.videoWatchedTime = Utility.sharedUtility.getWatchedDurationForVideo(watchedDuration: self.videoObject.videoWatchedTime, totalDurarion: self.videoObject.videoPlayerDuration)

                                        }
                                    }
                                }
                                
                                if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                                        self.updateProgressWithInitialPlaybackTime(currentTime: self.videoObject.videoWatchedTime, videoUrls: filmURLs)
                                }
                            }
                        })
                    }
                    else {
                        
                        DispatchQueue.main.async {
                            
                            if self.videoDuration != nil {
                                
                                self.videoObject.videoWatchedTime = self.videoDuration!
                            }
                            self.playVideo(videoUrls: filmURLs)

                        }
                    }
                    
                    self.playBackStreamID = Utility.sharedUtility.generateStreamID(movieName: self.videoObject.videoTitle)
                    self.apodCount=0
                    self.isFirstFrameSent = false
                    
                    if(!self.autoPlayObjectArray.isEmpty)
                    {
                        let filmId:String = self.autoPlayObjectArray[0] as! String
                        self.fetchVideoDetailAndRelatedVideosForAutoPlay(filmID: filmId)
                    }
                }
                else {
                    
                    self.hideActivityIndicatorView()
                    self.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived)
                }
            }
            else {
                
                self.hideActivityIndicatorView()
                self.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived)
            }
        }
    }
    
    //MARK: Method to parse video backgroud
    private func parseVideoBackgroundImageUrl(imageUrlsDict: Dictionary<String, String>) {
        
        if imageUrlsDict["posterImage"] != nil {
            
            self.imagePathString = imageUrlsDict["posterImage"]
        }
        else if imageUrlsDict["videoImage"] != nil {
            
            self.imagePathString = imageUrlsDict["videoImage"]
        }
    }
    
    
    //MARK: Method to parse subtitle from api response
    private func parseSubTitles(subTitleDict:Dictionary<String, AnyObject>) {
        
        let subTitleArray:Array<Dictionary<String, AnyObject>?>? = subTitleDict["closedCaptions"] as? Array<Dictionary<String, AnyObject>>
        
        if subTitleArray != nil {
            
            for subTitleObject in subTitleArray! {
                
                let subTitleFormat:String? = subTitleObject?["format"] as? String
                
                if subTitleFormat != nil {
                    
                    if subTitleFormat?.lowercased() == "srt" {
                        
//                        self.playerControls?.setSubtitleUrlString(subTitleString: subTitleObject?["url"] as? String ?? "")
//                        self.playerControls?.setIsSubTitleAvailable(isSubTitleAvailable: true)
                        self.subTitleString = subTitleObject?["url"] as? String ?? ""
                        self.isSubTitleAvailable = true
                        break
                    }
                }
            }
        }
    }
    
    
    //MARK: Play video with URL
    private func playVideo(videoUrls:Dictionary<String, AnyObject>?) {
        if CastPopOverView.shared.isConnected() {
            if self.playerFit == .smallScreen{
                self.removeNotificationsAndSubviews(isBackButtonRemove: true)
                self.showBackgroundImageForCasting()
            }
            else{
                self.castVideo()
            }
            return;
        }

        if let isLive:Bool = videoUrls?["isLiveStream"] as? Bool {
            self.isLiveStream = isLive
        }

        if self.isLiveStream == true {
            
            self.playerType = .liveVideoPlayer
        }
        
        let videoUrls:Dictionary<String, AnyObject>? = videoUrls?["videoUrl"] as? Dictionary<String, AnyObject>
        
        let rendentionUrls:Array<AnyObject>? = videoUrls?["renditionUrl"] as? Array<AnyObject>
        let hlsUrl:String? = videoUrls?["hlsUrl"] as? String

        self.videoURLDictionary = Dictionary.init()
        if (rendentionUrls?.count)! > 0
        {
            var ii: Int = 0
            for renditionDict in rendentionUrls!
            {
                let renditionUrlDict:Dictionary<String, AnyObject>? = renditionDict as? Dictionary<String, AnyObject>
                if renditionUrlDict != nil
                {
                    var dictKey: String = renditionUrlDict?["bitrate"] as? String ?? ""
                    if !dictKey.isEmpty
                    {
                        dictKey = dictKey.replacingOccurrences(of: "_", with: "")
                        let dictValue: String = renditionUrlDict?["renditionUrl"] as! String
                        
                        self.videoURLDictionary[dictKey] = dictValue
                        if ii < 1
                        {
                            self.currentPlayedKey = dictKey
                        }
                    }
                }
                ii = ii + 1
            }
        }
        if self.shouldPlayHlsUrlFirst && hlsUrl != nil
        {
            self.videoURLDictionary["Auto"] = hlsUrl
        }
        
        if self.shouldPlayHlsUrlFirst {
            if hlsUrl != nil
            {
                self.currentPlayedKey = "Auto"
            }
        }
        else {
            
//            if rendentionUrls == nil && hlsUrl != nil
//            {
//                self.currentPlayedKey = "Auto"
//            }
        }
        
        if !self.currentPlayedKey.isEmpty
        {
            videoUrlToBePlayed =  self.videoURLDictionary[self.currentPlayedKey]
        }

        if videoUrlToBePlayed != nil {
            self.playerControls?.updateSettingButtonLabel(streamQualityString: self.currentPlayedKey)
            loadVideoPlayer(videoURLString: videoUrlToBePlayed!)
        }
        else {
            
            let alertController = UIAlertController(title: "Error", message: "Film url not available", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: Constants.kStrOk, style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                UIApplication.shared.isStatusBarHidden = false
                Constants.kAPPDELEGATE.isBackgroundImageVisible = true
                self.dismiss(animated: true) {
                    CastPopOverView.shared.delegate = nil
                }
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: Load VideoPlayer
    func loadVideoPlayer(videoURLString:String) {
        if AppConfiguration.sharedAppConfiguration.typeOfPreview == TypeOfPreview.completeApplication && (self.shouldPlayVideo() == false || AppConfiguration.sharedAppConfiguration.videoPreviewDuration != nil) {
            
            if shouldPlayVideo() == false {
                self.subscriptionCloseButton = UIButton.init(type: UIButtonType.custom)
                
                var yAxis:CGFloat = 5
                
                if Utility.sharedUtility.isIphoneX() {
                    
                    yAxis += 20
                }
                self.subscriptionCloseButton.frame = CGRect(x: 5, y: yAxis, width: 23, height: 32)
                self.subscriptionCloseButton.setImage(#imageLiteral(resourceName: "Back.png"), for: .normal)
                self.subscriptionCloseButton.addTarget(self, action: #selector(closeButtonTapped(sender:)), for: .touchUpInside)
                self.subscriptionCloseButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
                self.stopPlayback()
                return
            }
        }
        self.removeObserversFromVideoPlayer()
        createVideoPlayer(urlString: videoURLString)
        checkViewStatus()
        
        //Check if ad tag is available or not
        if shouldDisplayAd() {
            
            self.view.bringSubview(toFront: adView)
            createContentPlayhead()
            setUpAdsLoader()
            requestAds()
        }
        else {
            
            if(!videoObject.contentRating.isEmpty && isContentWaningEnable && videoObject.contentRating != "NR" && (self.videoObject.videoWatchedTime == 0 || self.videoObject.videoWatchedTime == 100))
            {
                self.perform(#selector(showContentWarningScreen), with: nil, afterDelay: 0.2)
            }
            else
            {
                if self.isViewAppear == true{
                    self.playMedia()
                }
            }
        }
    }
    
    
    //MARK: Method to check to display ad or not
    private func shouldDisplayAd() -> Bool {
        
        var shouldDisplayAd = false
        
        if adTag != nil {

            shouldDisplayAd = true
             if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD  {
                if Constants.kSTANDARDUSERDEFAULTS.bool(forKey: Constants.kIsSubscribedKey) == true || self.isLiveStream == true{
                    shouldDisplayAd = false
                }
            }
        }
        
        return shouldDisplayAd
    }
    
    //MARK: Method to play video
    func playVideo()
    {
        if(self.avPlayer.currentItem != nil && self.avPlayer.rate == 0 && isContentWarningScreenShowing == false && isViewAppear && self.isForcePaused == false) {
            if self.adView != nil && self.adView.isHidden == false && self.isLiveStream == false{
                self.adsManager?.resume()
                if self.adPlayButton != nil{
                    self.adPlayButton.isSelected = false
                }
                return
            }
            self.playAVPlayer()
        }
    }
    
    
    //MARK: Method to pause video
    func pauseVideo()
    {
        if self.avPlayer.currentItem != nil
        {
            self.pauseAVPlayer()
        }
    }
    
    func avPlayerItemDidFinishedPlaying(notification: Notification) -> Void {
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            updatePlayerProgressToServerAfterThirySeconds(currentTime: self.videoObject.videoPlayerDuration)
        }
        
        fireBeaconEventAfterThirtySeconds(currentTime: Float(self.videoObject.videoPlayerDuration))
        
        
        if forceFullScreen {
            //self.videoPlayerBackButtonTapped()
        }
        else
        {
            UIApplication.shared.isStatusBarHidden = false
            if Constants.IPHONE
            {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
        
        showActivityIndicatorView()
        
        self.autoPlayForArrayItems()
    }
    
    func autoPlayForArrayItems()
    {
        let currentAutoPlayState: Bool? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) as? Bool
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) != nil
        {
            if currentAutoPlayState! && !self.autoPlayObjectArray.isEmpty
            {
                is75PercentUpdated = false
                is50PercentUpdated = false
                is25PercentUpdated = false
                is100PercentUpdated = false
                
                if self.isOpenFromDownload == false {
                    
                    self.autoPlayObjectArray.remove(at: 0)
                }
                
                self.setVideoObjectFromFilmObject()
                if self.videoPlayerDelegate != nil && (self.videoPlayerDelegate?.responds(to: #selector(self.videoPlayerDelegate?.videoPLayerFinishedVideo)))!
                {
                    self.videoPlayerDelegate?.videoPLayerFinishedVideo()
                }
            }
            else
            {
                if self.isVideoPlayedFromGrids {
                    self.isVideoComplete = true
                    self.isForcePaused = true
                    self.pauseAVPlayer()
                    hideActivityIndicatorView()
                }
                else {
                    
                    dimissPlayerViewIfAutoPlayItemNotFound()
                }
                
            }
        }
        else
        {
            if self.isVideoPlayedFromGrids {
                
                self.pauseAVPlayer()
                hideActivityIndicatorView()
            }
            else {
                
                dimissPlayerViewIfAutoPlayItemNotFound()
            }
        }
    }
    
    
    func setVideoObjectFromFilmObject(){
        
        if (isOpenFromDownload == true) {
            
            if self.autoPlayObjectArray.count > 0 {
                
                let obj: Any? = self.autoPlayObjectArray[0]
                
                if obj != nil {
                    
                    if obj is SFFilm {
                        
                        self.film = obj as! SFFilm
                    }
                }
                else {
                    
                    dimissPlayerViewIfAutoPlayItemNotFound()
                }
            }
            else {
                
                dimissPlayerViewIfAutoPlayItemNotFound()
            }
        }
        
        videoObject.videoTitle = film.title ?? ""
        videoObject.videoPlayerDuration = Double(film.durationSeconds ?? 0)
        videoObject.videoContentId = film.id ?? ""
        videoObject.gridPermalink = film.permaLink ?? ""
        videoObject.videoWatchedTime = Double(film.filmWatchedDuration ?? 0)
        
        if film.id != nil {
            
            if self.isVideoPlayedFromGrids {
             
                hideActivityIndicatorView()
                self.playNextVideoWithoutAutoPlayScreen()
            }
            else {
                
                self.presentAutoplayController()
            }
        }
        else {
            
            if self.isVideoPlayedFromGrids {
                
                self.pauseAVPlayer()
                hideActivityIndicatorView()
            }
            else {
                
                dimissPlayerViewIfAutoPlayItemNotFound()
            }
        }
    }
    
    
    private func playNextVideoWithoutAutoPlayScreen() {
        
        self.removeNotificationsAndSubviews(isBackButtonRemove: false)
        
        if (self.isOpenFromDownload == true ) {
            
            let obj: Any = self.autoPlayObjectArray[0]
            
            if obj is SFFilm {
                
                self.createVideoPlayer(urlString: videoObject.gridPermalink)
                self.checkViewStatus()
                if (self.autoPlayObjectArray.isEmpty == false) {
                    
                    self.autoPlayObjectArray.remove(at: 0)
                }
            }
            else{
                
                DispatchQueue.main.async {
                    self.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
                }
            }
        }
        else {
            
            checkForInternetConnectionAndLoadVideo()
        }
    }
    
    //MARK: Dismiss player view if autoplay UI not found.
    private func dimissPlayerViewIfAutoPlayItemNotFound() {
        
//        let ExpTime = TimeInterval(60 * 60 * 24 * 365)
//        HTTPCookieStorage.shared.removeCookies(since: Date.init(timeInterval: -ExpTime, since: Date()))
        
        self.pauseAVPlayer()
        hideActivityIndicatorView()
        Constants.kAPPDELEGATE.isBackgroundImageVisible = true
        self.dismiss(animated: true) {
            
            CastPopOverView.shared.delegate = nil
        }
    }
    
    
    func removeNotificationsAndSubviews(isBackButtonRemove:Bool)
    {
        if timeObserver != nil {
            
            avPlayer.removeTimeObserver(timeObserver)
            timeObserver = nil
        }
        
        if avPlayer.currentItem != nil{
            avPlayer.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            avPlayer.currentItem?.removeObserver(self, forKeyPath: "status")
            avPlayer.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            
            avPlayer.removeObserver(self, forKeyPath: "rate")
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: self.avPlayer.currentItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: self.avPlayer.currentItem)
        }
        for subview in self.view.subviews {
            
            if isBackButtonRemove == false && subview.tag == 101{
                continue
            }
            subview.removeFromSuperview()
        }
        
        self.pauseAVPlayer()
        if avPlayerLayer != nil{
            avPlayerLayer.player?.pause()
            avPlayer.replaceCurrentItem(with: nil)
            avPlayerLayer .removeFromSuperlayer()
        }
        if self.loadingIndicatorView != nil {
            self.loadingIndicatorView?.stopAnimating()
            self.loadingIndicatorView = nil
        }

        self.isSubTitleAvailable = false
    }
    
    
    func avPlayerItemDidFailedToPlayToEnd(notification: Notification) -> Void
    {
        
    }
    
    func avPlayerItemPlayerError(notification: NSNotification) -> Void
    {
        print("Video Error = \(notification.object.debugDescription)")
//        let error: NSError = notification.object as! NSError
//        if error.code == 403
//        {
//            fetchTokenDetails()
//        }
    }
    
    func avPlayerItemDidStalledPlayback(notification: Notification) -> Void
    {
        
    }
    
    override func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer?) {
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object is AVPlayer) && keyPath == "rate"
        {
            if avPlayer.rate > 0
            {
                avPlayerItemDidChangePlayingStatus(isPlaying: true)
            }
            else if avPlayer.rate == 0
            {
                avPlayerItemDidChangePlayingStatus(isPlaying: false)
            }
        }
        else if (object is AVPlayerItem) && keyPath == "status"
        {
            if avPlayer.status == .failed
            {
                print("Video Error = \(avPlayer.status)")
            }
        }
       
        if object is AVPlayerItem {
            
            if let currentItem = self.avPlayer.currentItem {
                if keyPath == "playbackBufferEmpty"
                {
                    self.sendBufferingEvent()
                }
                if currentItem.status == AVPlayerItemStatus.readyToPlay {
                    
                    if isOpenFromDownload || Utility.sharedUtility.checkIfMovieIsDownloaded(fileID: videoObject.videoContentId)
                    {
                        if loadingIndicatorView != nil {
                            if (loadingIndicatorView?.isAnimating)! {
                                
                                loadingIndicatorView?.stopAnimating()
                            }
                        }
                        //self.enableViewTouchEvents(withTochEnabled: true)
                    }
                    
                    self.enableViewTouchEvents(withTochEnabled: true)
                    
                    switch keyPath! {
                    case "playbackLikelyToKeepUp":
                        
                        if avPlayer.currentItem!.isPlaybackLikelyToKeepUp {
                            
                            if loadingIndicatorView != nil {
                                if (loadingIndicatorView?.isAnimating)! {
                                    
                                    loadingIndicatorView?.stopAnimating()
                                }
                            }
                            //self.enableViewTouchEvents(withTochEnabled: true)
                        } else {
                            
                            if loadingIndicatorView != nil {
                                
                                loadingIndicatorView?.startAnimating()
                            }
                        }
                        
                    case "status":
                        if(isFirstFrameSent == false)
                        {
                        isFirstFrameSent = true
                        let elapsed = Date().timeIntervalSince(currentTimeStamp!)
                        let duration = Float(elapsed)
                        var beaconDict : Dictionary<String,String> = [:]
                        beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId
                        beaconDict[Constants.kBeaconUrlKey]=BeaconEvent.generateURL(movieName: videoObject.videoTitle)
                        beaconDict[Constants.kBeaconRefKey]=Constants.kBeaconViewingFilmPage
                        beaconDict[Constants.kBeaconPaKey]=Constants.kBeaconEventFirstFrame
                        beaconDict[Constants.kBeaconVposKey]=String(CMTimeGetSeconds(self.avPlayer.currentTime()))
                        beaconDict[Constants.kBeaconAposKey]=String(CMTimeGetSeconds(self.avPlayer.currentTime()))
                        beaconDict[Constants.kBeaconPlayerKey]=self.getCurrentPlayer()
                        beaconDict[Constants.kBeaconTstampoverrideKey]=BeaconEvent.getCurrentTimeStamp()
                        beaconDict[Constants.kBeaconStream_idKey]=self.playBackStreamID
                        beaconDict[Constants.kBeaconTtfirstframeKey]=String(duration)
                        beaconDict[Constants.kBeaconMedia_typeKey]=Constants.kBeaconEventMediaTypeVideo
                        beaconDict[Constants.kBeaconDp2Key]=Utility.sharedUtility.getDp2ParameterForBeaconEvent(fileName: videoObject.videoContentId)
                        let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
                        DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
                        }
                    default :
                        break
                    }
                }
                else if currentItem.status == AVPlayerItemStatus.failed {
                    var beaconDict : Dictionary<String,String> = [:]
                    beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId
                    beaconDict[Constants.kBeaconUrlKey]=BeaconEvent.generateURL(movieName: videoObject.videoTitle)
                    beaconDict[Constants.kBeaconRefKey]=Constants.kBeaconViewingFilmPage
                    beaconDict[Constants.kBeaconPaKey]=Constants.kBeaconEventFailedToStart
                    beaconDict[Constants.kBeaconVposKey]=String(CMTimeGetSeconds(self.avPlayer.currentTime()))
                    beaconDict[Constants.kBeaconAposKey]=String(CMTimeGetSeconds(self.avPlayer.currentTime()))
                    beaconDict[Constants.kBeaconPlayerKey]=self.getCurrentPlayer()
                    beaconDict[Constants.kBeaconTstampoverrideKey]=BeaconEvent.getCurrentTimeStamp()
                    beaconDict[Constants.kBeaconStream_idKey]=self.playBackStreamID
                    beaconDict[Constants.kBeaconMedia_typeKey]=Constants.kBeaconEventMediaTypeVideo
                    beaconDict[Constants.kBeaconDp2Key]=Utility.sharedUtility.getDp2ParameterForBeaconEvent(fileName: videoObject.videoContentId)
                    let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
                    DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
                    
                } else if currentItem.status == AVPlayerItemStatus.unknown {
                    print("Unknown ")
                }
            }
        }
    }

    
    
    
    
    private func avPlayerItemDidChangePlayingStatus(isPlaying: Bool) -> Void
    {
        if self.playerControls != nil
        {
            if AppConfiguration.sharedAppConfiguration.typeOfPreview == TypeOfPreview.completeApplication && AppConfiguration.sharedAppConfiguration.videoPreviewDuration != nil {
                
                self.managePreviewTimer(isPlayerPaused: isPlaying)
            }
            
            self.playerControls?.setPlayButtonState(state: isPlaying)
        }
    }
    
    
    //MARK: Method to create ad view
    private func createAdView() {
        
        adView = UIView(frame: self.view.frame)
        adView.backgroundColor = UIColor.black
        
        self.view.addSubview(adView)
    }
    private func getCurrentPlayer() ->String
    {
        var currentVideoPlayer: String = Constants.kBeaconEventNativePlayer
        
        if self.isAudioSessionUsingAirplay() == true
        {
            currentVideoPlayer = Constants.kBeaconEventAirplayPlayer
        }
        
        return currentVideoPlayer
    }
    
    private func sendBufferingEvent()
    {
        if(avPlayer.currentItem!.isPlaybackBufferEmpty)
        {
            if(Constants.buffercount < 5){
                 Constants.buffercount = Constants.buffercount + 1
                return
            }
            
            var beaconDict : Dictionary<String,String> = [:]
            beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId
            beaconDict[Constants.kBeaconUrlKey]=BeaconEvent.generateURL(movieName: videoObject.videoTitle)
            beaconDict[Constants.kBeaconRefKey]=Constants.kBeaconViewingFilmPage
            beaconDict[Constants.kBeaconPaKey]=Constants.kBeaconEventBuffering
            beaconDict[Constants.kBeaconVposKey]=String(CMTimeGetSeconds(self.avPlayer.currentTime()))
            beaconDict[Constants.kBeaconAposKey]=String(CMTimeGetSeconds(self.avPlayer.currentTime()))
            beaconDict[Constants.kBeaconPlayerKey]=self.getCurrentPlayer()
            beaconDict[Constants.kBeaconTstampoverrideKey]=BeaconEvent.getCurrentTimeStamp()
            beaconDict[Constants.kBeaconStream_idKey]=self.playBackStreamID
            beaconDict[Constants.kBeaconMedia_typeKey]=Constants.kBeaconEventMediaTypeVideo
            beaconDict[Constants.kBeaconDp2Key]=Utility.sharedUtility.getDp2ParameterForBeaconEvent(fileName: videoObject.videoContentId)
            let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
            DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
            Constants.buffercount = 0
        }
        
    }
    
    func addPlayPauseButtonTap() {
        
        if self.adPlayButton.isSelected {
            
            self.adsManager?.pause()
        }
        else {
            self.adsManager?.resume()
        }
        
        self.adPlayButton.isSelected = !self.adPlayButton.isSelected
    }
    
    func setUpAdsLoader() {
        
        //AC-325 - Added ima settings to disable player info for Google sdk
        let imaSettings:IMASettings = IMASettings()
        imaSettings.disableNowPlayingInfo = true
        
        adsLoader = IMAAdsLoader(settings: imaSettings)
        adsLoader?.delegate = self
    }
    
    func requestAds() {
        // Create an ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: adView, companionSlots: nil)
        
        // Create a content playhead so the SDK can track our content for VMAP and ad rules.
        // createContentPlayhead()
        
        let timeInMilliSeconds:Int64 = Int64(Date().timeIntervalSince1970)
        
        let adTagEndPoint = "&url=https://\(AppConfiguration.sharedAppConfiguration.domainName ?? "")\(videoObject.gridPermalink)&ad_rule=0&correlator=\(timeInMilliSeconds)&cust_params=APPID%3D\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&device[ifa]=\(Utility.sharedUtility.getUUID())"
        adTag = adTag?.appending(adTagEndPoint)
        
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: adTag,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil)
        
        adsLoader!.requestAds(with: request)
    }
    
    func createContentPlayhead() {
        
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: self.avPlayer)
        //        NotificationCenter.default.addObserver(self, selector: Selector(("AdDidFinishPlaying:")), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem)
    }
    
    func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        //        self.view.isUserInteractionEnabled = true
        
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate
        adsManager = adsLoadedData.adsManager
        adsManager!.delegate = self
        
        // Create ads rendering settings and tell the SDK to use the in-app browser.
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.webOpenerPresentingController = self
        
        // Initialize the ads manager.
        adsManager?.initialize(with: adsRenderingSettings)
        if self.adsManager?.adCuePoints != nil {
            self.playerControls?.setSliderQueuePoints(cuePoints: self.adsManager?.adCuePoints! as! Array<AnyObject>, duration: self.videoObject.videoPlayerDuration)
        }
        
        adBar = UIView(frame: CGRect(x: 0, y: adView.bounds.size.height - 40, width: adView.frame.size.width, height: 40))
        adBar.backgroundColor = UIColor(red: 116.0/255.0, green: 118.0/255.0, blue: 122.0/255.0, alpha: 1.0)
        adBar.alpha = 0.7
        adBar.isOpaque = false
        
        let singleTapOnAdBar:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CustomVideoController.addPlayPauseButtonTap))
        adBar.addGestureRecognizer(singleTapOnAdBar)
        
        adView.addSubview(adBar)
        
        let adPlayButtonImage:UIImage = #imageLiteral(resourceName: "mediaPlay.png")
        adPlayButton = UIButton(type: .custom)
        adPlayButton.frame = CGRect(x: adBar.frame.midX - adPlayButtonImage.size.width/2, y: (adBar.frame.size.height - adPlayButtonImage.size.height)/2, width: adPlayButtonImage.size.width, height: adPlayButtonImage.size.height)
        adPlayButton.setImage(adPlayButtonImage, for: .normal)
        adPlayButton.setImage(#imageLiteral(resourceName: "Pause.png"), for: .selected)
        adPlayButton.addTarget(self, action: #selector(CustomVideoController.addPlayPauseButtonTap), for: .touchUpInside)
        adBar.addSubview(adPlayButton)
    }
    
    func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        
        self.adView.isHidden = true
        if(!videoObject.contentRating.isEmpty && isContentWaningEnable && videoObject.contentRating != "NR" && (self.videoObject.videoWatchedTime == 0 || self.videoObject.videoWatchedTime == 100))
        {
            self.perform(#selector(showContentWarningScreen), with: nil, afterDelay: 0.2)
        }
        else
        {
            self.playMedia()
        }
        
    }
    func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        //        self.view.isUserInteractionEnabled = true
        
        print("Error loading ads: \(error.message)")
        self.adView.isHidden = true
        self.playMedia()
    }
    func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
        //        self.view.isUserInteractionEnabled = true
        print("adsManager event \(event.typeString!)")
        
        switch (event.type) {
        case .LOADED:
            self.adView.isHidden = false
            adsManager.start()
            if isViewAppear == false{
                adsManager.pause()
            }
            self.adPlayButton.isSelected = true
            break
        case .STARTED:
            self.apodCount = +1
            self.adPlayButton.isSelected = true
            //Ad Request Beacon Event
            self.pingBeaconEventForAds(AdREQUEST,apodCount: self.apodCount)
            //Ad Impression Beacon Event
            self.pingBeaconEventForAds(ADIMPRESSION,apodCount: self.apodCount)
            break
        case .PAUSE:
            self.adPlayButton.isSelected = false
            break
            
        case .RESUME:
            self.adPlayButton.isSelected = true
            break
            
        case .TAPPED:
            break
            
        case .COMPLETE:
            self.adPlayButton.isSelected = false
            self.adView.isHidden = true
            if(videoObject.contentRating.characters.count>0 && !isContentWarningScreenPresented && isContentWaningEnable && videoObject.contentRating != "NR" && (self.videoObject.videoWatchedTime == 0 || self.videoObject.videoWatchedTime == 100))
            {
                self.perform(#selector(showContentWarningScreen), with: nil, afterDelay: 0.2)
            }
            else
            {
                self.playMedia()
            }
            
            break
            
        default:
            break
        }
    }
    
    //MARK:- Ping Beacon Event for Ads on basis of event type
    private func pingBeaconEventForAds(_ eventType : String , apodCount : Int)
    {
        var beaconDict : Dictionary<String,String> = [:]
        beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId
        beaconDict[Constants.kBeaconUrlKey]=BeaconEvent.generateURL(movieName: videoObject.videoTitle)
        beaconDict[Constants.kBeaconRefKey]=Constants.kBeaconViewingFilmPage
        
        beaconDict[Constants.kBeaconApodKey]=String(self.apodCount)
        beaconDict[Constants.kBeaconVposKey]=String(CMTimeGetSeconds(self.avPlayer.currentTime()))
        beaconDict[Constants.kBeaconAposKey]=String(CMTimeGetSeconds(self.avPlayer.currentTime()))
        beaconDict[Constants.kBeaconPlayerKey]=self.getCurrentPlayer()
        beaconDict[Constants.kBeaconTstampoverrideKey]=BeaconEvent.getCurrentTimeStamp()
        beaconDict[Constants.kBeaconStream_idKey]=self.playBackStreamID
        beaconDict[Constants.kBeaconMedia_typeKey]=Constants.kBeaconEventMediaTypeVideo
        beaconDict[Constants.kBeaconDp2Key]=Utility.sharedUtility.getDp2ParameterForBeaconEvent(fileName: videoObject.videoContentId)
        if(eventType == AdREQUEST)
        {
            beaconDict[Constants.kBeaconPaKey]=Constants.kBeaconEventTypeAdRequest
        }
        else
        {
            beaconDict[Constants.kBeaconPaKey]=Constants.kBeaconEventTypeAdImpression
        }
        
        let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
        DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
    }
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        
        self.adPlayButton.isSelected = false
        self.adView.isHidden = false
        self.pauseAVPlayer()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        
        self.adPlayButton.isSelected = false
        self.adView.isHidden = true
        self.playMedia()
    }
    
    //MARK - Activity IndicatorView method
    func showActivityIndicatorView() {
        
        if loadingIndicatorView == nil {
            
            loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            self.view.addSubview(loadingIndicatorView!)
        }
        
        loadingIndicatorView?.frame.origin = self.view.center
        self.view.bringSubview(toFront: loadingIndicatorView!)
        loadingIndicatorView?.hidesWhenStopped = true
        loadingIndicatorView?.startAnimating()
    }
    
    private func hideActivityIndicatorView() {
        
        if loadingIndicatorView != nil {
            
            if (loadingIndicatorView?.isAnimating)! {
                loadingIndicatorView?.stopAnimating()
            }
        }
    }
    
    //MARK: Fire BeaconEvents
    private func fireBeaconEventAfterThirtySeconds(currentTime:Float) {
        if(lastPlayBackTime == currentTime)
        {return}
        lastPlayBackTime = currentTime
        var beaconDict : Dictionary<String,String> = [:]
        beaconDict[Constants.kBeaconVidKey] = videoObject.videoContentId
        beaconDict[Constants.kBeaconUrlKey]=BeaconEvent.generateURL(movieName: videoObject.videoTitle)
        beaconDict[Constants.kBeaconRefKey]=Constants.kBeaconViewingFilmPage
        beaconDict[Constants.kBeaconPaKey]=Constants.kBeaconEventTypePing
        beaconDict[Constants.kBeaconApodKey]=String(self.apodCount)
        beaconDict[Constants.kBeaconVposKey]=String(currentTime)
        beaconDict[Constants.kBeaconAposKey]=String(currentTime)
        beaconDict[Constants.kBeaconPlayerKey]=self.getCurrentPlayer()
        beaconDict[Constants.kBeaconBitrateKey]=self.getBitRate(fileID: videoObject.videoContentId)
        beaconDict[Constants.kBeaconResolutionHeightKey]=String(describing: self.avPlayer.currentItem?.presentationSize.height ?? 0)
        beaconDict[Constants.kBeaconResolutionWidthKey]=String(describing: self.avPlayer.currentItem?.presentationSize.width ?? 0 )
        beaconDict[Constants.kBeaconTstampoverrideKey]=BeaconEvent.getCurrentTimeStamp()
        beaconDict[Constants.kBeaconStream_idKey]=self.playBackStreamID
        beaconDict[Constants.kBeaconMedia_typeKey]=Constants.kBeaconEventMediaTypeVideo
        beaconDict[Constants.kBeaconDp2Key]=Utility.sharedUtility.getDp2ParameterForBeaconEvent(fileName: videoObject.videoContentId)
        let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
        DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
    }
    
    private func updateProgressWithInitialPlaybackTime(currentTime:Double,videoUrls:Dictionary<String, AnyObject>?){
        
        if DownloadManager.sharedInstance.downloadingObjectsContainsFile(withID: videoObject.videoContentId)
        {
            var moviePercentage: Float = Float(currentTime) / Float(videoObject.videoPlayerDuration)
            moviePercentage = moviePercentage * 100
            DownloadManager.sharedInstance.updatePlist(forFileWatchedPercentage: videoObject.videoContentId, watchedPercentage: moviePercentage)
        }
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() != NotReachable { //&& !self.isFilmProgressUpdateInSync {
            
            self.isFilmProgressUpdateInSync = true
            
            //            let updatePlayerProgressDict:Dictionary<String, Any> = ["userId":Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", "videoId":videoObject.videoContentId, "watchedTime":currentTime, "siteOwner":AppConfiguration.sharedAppConfiguration.sitename ?? ""]
            //
            //            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/video/history"
            //
            //            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"isHistoryUpdated"), object: nil)
            //            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"updatePlayerProgress"), object: nil, userInfo: ["playerProgress":currentTime, "filmId":videoObject.videoContentId])
            
            self.playVideo(videoUrls: videoUrls)
            
            //            DataManger.sharedInstance.updateFilmProgressOnServer(apiEndPoint: apiEndPoint, requestParameters: updatePlayerProgressDict) { (errorMessage, isSuccess) in
            //                self.hideActivityIndicatorView()
            //                self.playVideo(videoUrls: videoUrls)
            //                if isSuccess == false {
            //                    if errorMessage != nil {
            //                        let okAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (okAction) in
            //
            //                            UIApplication.shared.isStatusBarHidden = false
            //                            if  UIDeviceOrientationIsLandscape(UIDevice.current.orientation) && Constants.IPHONE
            //                            {
            //                                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            //                            }
            //
            //                            self.dismiss(animated: true) {
            //                                CastPopOverView.shared.delegate = nil
            //                            }
            //                        })
            //                        let error:String? = errorMessage?["error"] as? String ?? errorMessage?["message"] as? String
            //                        let errorCode:String? = errorMessage?["code"] as? String
            //                        if errorCode != nil &&  errorCode == "401"{
            //                            self.showBackgroundImage(errorMessage: error ?? Constants.kEntitlementErrorMessage)
            //                        }
            //                        else{
            //                            if error != nil{
            //                                let errorAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "", alertMessage: error!, alertActions: [okAction])
            //                                self.present(errorAlert, animated: true, completion: nil)
            //                            }
            //                        }
            //                    }
            //                    else {
            //                        self.isFilmProgressUpdateInSync = false
            //                        self.playVideo(videoUrls: videoUrls)
            //                    }
            //                }
            //                else {
            //                    self.isFilmProgressUpdateInSync = false
            //                    self.playVideo(videoUrls: videoUrls)
            //                }
            //            }
        }
    }
    
    
    //MARK:Update Player Progress API to server
    private func updatePlayerProgressToServerAfterThirySeconds(currentTime:Double) {
        
        if DownloadManager.sharedInstance.downloadingObjectsContainsFile(withID: videoObject.videoContentId)
        {
            var moviePercentage: Float = Float(currentTime) / Float(videoObject.videoPlayerDuration)
            moviePercentage = moviePercentage * 100
            DownloadManager.sharedInstance.updatePlist(forFileWatchedPercentage: videoObject.videoContentId, watchedPercentage: moviePercentage)
        }
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() != NotReachable {//&& !self.isFilmProgressUpdateInSync {
            
            self.isFilmProgressUpdateInSync = true
            
            let updatePlayerProgressDict:Dictionary<String, Any> = ["userId":Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", "videoId":videoObject.videoContentId, "watchedTime":currentTime, "siteOwner":AppConfiguration.sharedAppConfiguration.sitename ?? ""]
            
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/video/history"
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"isHistoryUpdated"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"updatePlayerProgress"), object: nil, userInfo: ["playerProgress":currentTime, "filmId":videoObject.videoContentId])
            
            DataManger.sharedInstance.updateFilmProgressOnServer(apiEndPoint: apiEndPoint, requestParameters: updatePlayerProgressDict) { (errorMessage, isSuccess) in
                
                //                if isSuccess == false {
                //
                //                    if errorMessage != nil {
                //
                //                        self.avPlayer.pause()
                //
                //                        let error:String? = errorMessage?["error"] as? String ?? errorMessage?["message"] as? String
                //                        let errorCode:String? = errorMessage?["code"] as? String
                //
                //                        if errorCode != nil &&  errorCode == "401" {
                //
                //                            self.showBackgroundImage(errorMessage: error ?? Constants.kEntitlementErrorMessage)
                //                        }
                //                        else {
                //
                //                            if error != nil {
                //
                //                                if self.timeObserver != nil {
                //
                //                                    self.avPlayer.removeTimeObserver(self.timeObserver)
                //                                    self.timeObserver = nil
                //                                }
                //
                //                                let okAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (okAction) in
                //
                //                                    UIApplication.shared.isStatusBarHidden = false
                //
                //                                    if  UIDeviceOrientationIsLandscape(UIDevice.current.orientation) && Constants.IPHONE
                //                                    {
                //                                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                //                                    }
                //
                //                                    self.dismiss(animated: true) {
                //                                        CastPopOverView.shared.delegate = nil
                //                                    }
                //                                })
                //
                //                                let errorAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "", alertMessage: error!, alertActions: [okAction])
                //                                self.present(errorAlert, animated: true, completion: nil)
                //                            }
                //                        }
                //                    }
                //                    else {
                //
                //                        self.isFilmProgressUpdateInSync = false
                //                    }
                //                }
                //                else {
                //
                //                    self.isFilmProgressUpdateInSync = false
                //                }
            }
        }
    }
    
    
    //MARK: Display Network Error Alert
    private func showAlertForAlertType(alertType: AlertType) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {

                if self.forceFullScreen == false
                {
                    UIApplication.shared.isStatusBarHidden = false
                    Constants.kAPPDELEGATE.isBackgroundImageVisible = true
                    self.dismiss(animated: true) {
                        CastPopOverView.shared.delegate = nil
                    }
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
            alertMessage = "Unable to play video!"
        }
        
        networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction])
        
        self.present(networkUnavailableAlert!, animated: true, completion: nil)
    }
    
    
    // Mark:- Present Autoplay View
    private func presentAutoplayController()
    {
        hideActivityIndicatorView()
        
//        let ExpTime = TimeInterval(60 * 60 * 24 * 365)
//        HTTPCookieStorage.shared.removeCookies(since: Date.init(timeInterval: -ExpTime, since: Date()))

        if timeObserver != nil {
            
            avPlayer.removeTimeObserver(timeObserver)
            timeObserver = nil
        }
        
        self.isFilmProgressUpdateInSync = false
        self.isForcePaused = false
        self.isTokenAvailable = false
        self.isFreeVideo = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissAutoplayView), name: NSNotification.Name(rawValue: "dismissAutoplayView"), object: nil)
        
        Constants.kAPPDELEGATE.isAutoPlayPopUpVisible = true
        
        if autoPlayViewController != nil {
            
            autoPlayViewController = nil
        }
        
        autoPlayViewController = AutoPlayViewController.init()
        autoPlayViewController.filmObject=film
        
        let navEditorViewController: UINavigationController = UINavigationController.init(rootViewController: autoPlayViewController)
        if Constants.IPHONE
        {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        navEditorViewController.modalPresentationStyle = .overFullScreen
        self.present(navEditorViewController, animated: true, completion: nil)
    }
    
    
    // Mark :- Dismiss Autoplay View
    func dismissAutoplayView(_ notification: Notification)  {
        
        UIApplication.shared.isStatusBarHidden = true
        NotificationCenter.default.removeObserver(self, name : NSNotification.Name(rawValue: "dismissAutoplayView"), object:nil)
        
        if let buttonTapped = notification.object as? autoPlayButtonAction {
            if (buttonTapped==autoPlayButtonAction.cancel)
            {
                autoPlayViewController.dismiss(animated: false, completion:
                    {
                        UIApplication.shared.isStatusBarHidden = false
                        self.dismiss(animated: true, completion:nil)
                        Constants.kAPPDELEGATE.isAutoPlayPopUpVisible = true
                } )
            }
            else {
                
                self.removeNotificationsAndSubviews(isBackButtonRemove: true)
                
                if (self.isOpenFromDownload == true ) {
                    
                    let obj: Any = self.autoPlayObjectArray[0]
                    
                    if obj is SFFilm {
                        
                        self.createVideoPlayer(urlString: videoObject.gridPermalink)
                        self.checkViewStatus()
                        if (self.autoPlayObjectArray.isEmpty == false) {
                            
                            self.autoPlayObjectArray.remove(at: 0)
                        }
                    }
                    else{
                        
                        DispatchQueue.main.async {
                            self.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
                        }
                    }
                }
                else {
                    
                    checkForInternetConnectionAndLoadVideo()
                }
                
                Constants.kAPPDELEGATE.isAutoPlayPopUpVisible = false
                autoPlayViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    private func trackAnalyticsEventsForFilmViewing()
    {
        if(!self.videoObject.videoContentId.isEmpty)
        {
            if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                
                if  Constants.kSTANDARDUSERDEFAULTS.bool(forKey: Constants.kIsSubscribedKey) == true
                {
                    
                    AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_FILMVIEWING, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "",Constants.APPSFLYER_KEY_FILMID : self.videoObject.videoContentId ,
                                                                                                             Constants.APPSFLYER_KEY_COURSE_CATEGORY:self.videoObject.primaryCategory ,
                                                                                                             Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_VALUE_ENTITLED : "true"])
                }
                else
                {
                    AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_FILMVIEWING, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "",Constants.APPSFLYER_KEY_FILMID : self.videoObject.videoContentId ,
                                                                                                             Constants.APPSFLYER_KEY_COURSE_CATEGORY:self.videoObject.primaryCategory ,
                                                                                                             Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_VALUE_ENTITLED : "false"])
                }
                
                if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                {
                    var currentVideoPlayer: String = Constants.kGTMNativePlayer
                    
                    if self.isAudioSessionUsingAirplay() == true
                    {
                        currentVideoPlayer = Constants.kGTMAirplayPlayer
                    }
                    
                    FIRAnalytics.logEvent(withName: Constants.kGTMStreamStartEvent, parameters: [Constants.kGTMVideoIDAttribute : self.videoObject.videoContentId, Constants.kGTMVideoNameAttribute: self.videoObject.videoTitle, Constants.kGTMSeriesIDAttribute: "", Constants.kGTMSeriesNameAttribute:"", Constants.kGTMVideoPlayerTypeAttribute : currentVideoPlayer, Constants.kGTMVideoMediaTypeAttribute: Constants.kGTMVideoContent])
                }
            }
        }
    }
    
     
   func playMedia() -> Void {
        
        if(self.avPlayer.currentItem != nil && self.avPlayer.rate == 0 && isContentWarningScreenShowing == false && isViewAppear && self.isForcePaused == false) {
            if self.adView != nil && self.adView.isHidden == false && self.isLiveStream == false{
                self.adsManager?.resume()
                if self.adPlayButton != nil{
                    self.adPlayButton.isSelected = false
                }
                return
            }
            self.playAVPlayer()
        }
    }
    
    //MARK:ContentWarning
    func showContentWarningScreen()
    {
        isContentWarningScreenShowing = true
        let sfcontentWarningVC: SFContentWarningVC = SFContentWarningVC.init(contentCategory: videoObject.contentRating)
        sfcontentWarningVC.sfContentWarningVCDelegate = self
        self.present(sfcontentWarningVC, animated: true, completion: nil)
    }
    
    
    //MARK: CRW Delegate
    func timmerCompleted(){
        isContentWarningScreenPresented = true;
        isContentWarningScreenShowing = false
        self.isViewAppear = true
        self.playMedia()
    }
    
    
    //MARK : GET BitRate
    private func getBitRate(fileID : String) -> String
    {
        if(Utility.sharedUtility.checkIfMovieIsDownloaded(fileID: fileID))
        {
            for downloadObjectAtIndex: DownloadObject in DownloadManager.sharedInstance.getGlobalDownloadObjectsArray()
            {
                if(downloadObjectAtIndex.fileID == fileID)
                {
                    return downloadObjectAtIndex.fileBitRate
                }
            }
        }
        else
        {
            var avgBitrate:Int = 0
            if avPlayer.currentItem != nil
            {
                if avPlayer.currentItem?.accessLog() != nil
                {
                    if avPlayer.currentItem?.accessLog()?.events != nil {
                        
                        for event in (avPlayer.currentItem?.accessLog()?.events)!{
                            
                            if !event.indicatedBitrate.isNaN && !event.indicatedBitrate.isInfinite {
                                
                                avgBitrate = Int(event.indicatedBitrate)
                            }
                        }
                    }
                    
                    avgBitrate = avgBitrate/1000
                    return "\(avgBitrate)"
                }
                else
                {
                    return ""
                }
            }
            else
            {
                return ""
            }
        }
        return ""
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    
    //MARK - Video Player Control Delegate methods
    
    func videoPlayerAddSubtitle() -> Void
    {
        if let subTitleUrl = URL(string: self.playerControls?.getSubtitleUrlString() ?? "") {
            if Utility.sharedUtility.checkIfMovieIsDownloaded(fileID : videoObject.videoContentId) {
                
                self.avPlayer.addSubtitles(parentView: self.view).open(file: subTitleUrl, encoding: .utf8, isPathLocal: true)
            }
            else
            {
                self.avPlayer.addSubtitles(parentView: self.view).open(file: subTitleUrl, encoding: .utf8, isPathLocal: false)
                
            }
        }
    }
    
    
    func videoPLayerAddTimerForElapsedTimeLabel() -> Void
    {
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { (elapsedTime: CMTime) in
            self.observeTime(elapsedTime: elapsedTime)
        }) as AnyObject
    }
    
    func videoPlayerSeekBack() {
        let timeToSeek: CMTime = CMTimeMakeWithSeconds(10.0, 1)
        if avPlayer.status == .readyToPlay {
            self.avPlayer.seek(to: (self.avPlayer.currentTime() - timeToSeek))
        }
    }
    
    func videoPlayerSeekForward() {
        let timeToSeek: CMTime = CMTimeMakeWithSeconds(10.0, 1)
        if avPlayer.status == .readyToPlay {
            self.avPlayer.seek(to: (self.avPlayer.currentTime() + timeToSeek))
        }
    }
    
    func videoPlayerSettingsTapped() {
        settingController = CustomPlayerSettingsScreenViewController.init()
        settingController.streamSelectorArray = Array(self.videoURLDictionary.keys)
        settingController.streamSelectorDelegate = self
        settingController.selectedKey = self.currentPlayedKey
        self.view.addSubview(settingController.view)
        self.view.bringSubview(toFront: settingController.view)
        self.pauseVideo()
    }
    
    func streamQualityDidChanged(selectedIndex: Int, selectedKey: String)
    {
        if self.currentPlayedKey == selectedKey
        {
            self.playVideo()
            return
        }
//        if self.currentPlayedURLIndex == selectedIndex
//        {
//            self.playVideo()
//            return
//        }
//        self.currentPlayedURLIndex = selectedIndex
        self.currentPlayedKey = selectedKey
//        let urlKeysArray: Array<String> = Array(self.videoURLDictionary.keys)
        self.playerControls?.updateSettingButtonLabel(streamQualityString: currentPlayedKey)

        self.videoUrlToBePlayed = self.videoURLDictionary[currentPlayedKey]
        self.updateVideoStream()
    }
    
    func streamSelectorViewRemovedFromSuperView() -> Void
    {
        if !self.isForcePaused
        {
            self.playVideo()
        }
    }
    
    func updateVideoStream()
    {
        if loadingIndicatorView != nil {
            loadingIndicatorView?.startAnimating()
        }
//        self.createVideoPlayer(urlString: self.videoUrlToBePlayed!)
        
        
        let currentTime: CMTime = self.avPlayer.currentTime()
        self.removeObserverFromVideoPlayerItem()
        var url:URL? = nil
        var urlStringLocal: String = self.videoUrlToBePlayed!.trimmingCharacters(in: NSCharacterSet.whitespaces)
        urlStringLocal = Utility.urlEncodedString_ch(emailStr: urlStringLocal)
        url = URL(string: urlStringLocal)!
        let playerItem = AVPlayerItem(url: url!)
        avPlayer.replaceCurrentItem(with: playerItem)
        self.addObserverOnVideoPlayerItem()
        self.avPlayer.seek(to: currentTime)
        self.playVideo()
    }
    
    func sliderValueChanged(newValue: Float64) {
        
        if avPlayer.currentItem != nil {
            
            let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
            let elapsedTime: Float64 = videoDuration * newValue
            updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        }
    }
    
    func sliderValueBeganTraking(newValue: Float64) -> Void
    {
        playerRateBeforeSeek = avPlayer.rate
        self.pauseAVPlayer()
    }
    
    func sliderValueEndTraking(newValue: Float64) -> Void
    {
        if avPlayer.currentItem != nil
        {
            let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
            let elapsedTime: Float64 = videoDuration * newValue
            updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
            if avPlayer.status == .readyToPlay {
                avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, 1000) , toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (Bool) in
                    if self.playerRateBeforeSeek > 0 {
                        self.playMedia()
                    }
                })
            }
        }
    }
    
    func videoPlayerBackButtonTapped() -> Void
    {
        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: "isContentWarningForcefullyDismissed")
        Constants.kSTANDARDUSERDEFAULTS.synchronize()
        
        if forceFullScreen || Constants.kAPPDELEGATE.isFullScreenEnabled
        {
            self.playerFit = .smallScreen
            self.playerControls?.updateControls(with: .small)
            if self.videoPlayerDelegate != nil && (self.videoPlayerDelegate?.responds(to: #selector(self.videoPlayerDelegate?.exitFullScreenVideoPlayer)))!
            {
                self.videoPlayerDelegate?.exitFullScreenVideoPlayer()
            }
            forceFullScreen = false
        }
        else
        {
//            let ExpTime = TimeInterval(60 * 60 * 24 * 365)
//            HTTPCookieStorage.shared.removeCookies(since: Date.init(timeInterval: -ExpTime, since: Date()))
            
            self.pauseAVPlayer()
            
            UIApplication.shared.isStatusBarHidden = false
            Constants.kAPPDELEGATE.isBackgroundImageVisible = true
            removeObserversFromVideoPlayer()
            self.dismiss(animated: true) {
                CastPopOverView.shared.delegate = nil
            }
        }
    }
    
    func videoPlayerClosedCaptionButtonTapped(sender: UIButton) -> Void
    {
        self.avPlayer.subtitleLabel?.isHidden = !Constants.kSTANDARDUSERDEFAULTS.bool(forKey: Constants.kIsCCEnabled)
        Constants.kSTANDARDUSERDEFAULTS.set(sender.isSelected, forKey: Constants.kIsCCEnabled)
    }

    func videoPlayerPlayButtonTapped() -> Void
    {
        if self.avPlayer.rate == 0
        {
            self.isForcePaused = false
            if self.isVideoComplete == true{
                self.isVideoComplete = false
                self.avPlayer.seek(to: CMTimeMakeWithSeconds(self.videoObject.videoWatchedTime, 100))
            }
            self.avPlayer.rate = 1
        }
        else
        {
            self.isForcePaused = true
            self.avPlayer.rate = 0
        }
    }
    
    func videoPlayerChromCastButtonTapped(sender: UIButton) -> Void
    {
        CastPopOverView.shared.chooseDevice(chromeCastButton: sender, vc: self)
    }
    
    func videoPlayerAirplayButtonTapped() -> Void
    {
        
    }
    
    func videoPlayerFullScreenButtonTapped() -> Void
    {
        forceFullScreen = true
        self.playerFit = .fullScreen
        if self.videoPlayerDelegate != nil && (self.videoPlayerDelegate?.responds(to: #selector(self.videoPlayerDelegate?.fullScreenVideoPlayer)))!
        {
            
            self.videoPlayerDelegate?.fullScreenVideoPlayer()
        }
    }
    
    func videoPlayerFullScreen() -> Void
    {
        forceFullScreen = true
        self.playerFit = .fullScreen
        if self.videoPlayerDelegate != nil && (self.videoPlayerDelegate?.responds(to: #selector(self.videoPlayerDelegate?.updateVideoPlayerForOrientation)))!
        {
            self.videoPlayerDelegate?.updateVideoPlayerForOrientation!()
        }
    }
    
    func videoPlayerExitFullScreen() -> Void
    {
        if forceFullScreen || Constants.kAPPDELEGATE.isFullScreenEnabled
        {
            self.playerFit = .smallScreen
            self.playerControls?.updateControls(with: .small)
            if self.videoPlayerDelegate != nil && (self.videoPlayerDelegate?.responds(to: #selector(self.videoPlayerDelegate?.exitFullScreenVideoPlayer)))!
            {
                self.videoPlayerDelegate?.exitFullScreenVideoPlayer()
            }
            forceFullScreen = false
        }
    }
    
 }
