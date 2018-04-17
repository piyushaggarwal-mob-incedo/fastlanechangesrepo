//
//  VideoPlayerModule_tvOS.swift
//  AppCMS_tvOS
//
//  Created by Anirudh Vyas on 10/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

/*
 KVO context used to differentiate KVO callbacks for this class versus other
 classes in its class hierarchy.
 */
private var videoPlayerKVOContext = 0

let kPlayerZoomToggledNotification = "PlayerZoomToggled"

@objc protocol VideoPlayerModuleDelegate: NSObjectProtocol {
    
    /// Implement to scroll on gesture.
    @objc optional func scrollToNextFocusableItem()
    
}

class VideoPlayerModule_tvOS: UIViewController, AdXMLParserDelegate, AdvertisementPlayerDelegate {

    /// ModuleViewModel Delegate property. Set this to get callbacks of the inherited classes. This is private property. Set using #delegate property.
    private weak var _delegate: VideoPlayerModuleDelegate?
    weak var delegate: VideoPlayerModuleDelegate? {
        set (newDelegate) {
            _delegate = newDelegate
        }
        get {
            return _delegate
        }
    }
    
    private(set) lazy var previewEndCard : PreviewEndCardViewController = {
        let viewController = PreviewEndCardViewController(nibName: "PreviewEndCardViewController", bundle: nil)
        viewController.supportsBackButton = false
        return viewController
    }()
    
    private var playerZoomed: Bool {
        get {
            if let videoPlayer = videoPlayerVC {
                if videoPlayer.view.frame.size.width == UIScreen.main.bounds.size.width {
                    return true
                }
            } else if let adLayer = playerLayer {
                if adLayer.frame.size.width == UIScreen.main.bounds.size.width {
                    return true
                }
            } else {
                if let holderVC = playerHolderViewController {
                    if holderVC.isShowing() {
                        return true
                    }
                }
            }
            return false
        }
    }
    
    /// Seconds buffered for video player. Not private as it is accessed in the extension.
    var secondsBuffered: Float64?
    
    /// Last beacon Ping time.
    private var lastBeaconPingedTime : Float?
    
    /// Current recorded time stamp. Not private as it is accessed in the extension.
    var currentTimeStamp : Date?
    
    /// Current recorder time stamp for buffer state. Not private as it is accessed in the extension.
    var currentTimeStampForBuffer: Date?
    
    private var didAdFinishPlaying: Bool = false
    
    private var playerHolderViewController: VideoPlayerHolderViewContoller?
    
    private weak var presenterView: UIView?
    
    /// Button to allow zoom on player.
    private var zoomButton: UIButton?
    
    /// label to show Ad is playing.
    private var adLabel: UILabel?
    
    /// DFP Tag for video.
    private var dfpTag: String?
    
    /// AVPlayerLayer optional. Not private as it is accessed in the extension.
    var playerLayer : AVPlayerLayer?
    
    /// Ad parser class optional.
    private var adParser : AdXMLParser?
    
    /// Advertisement Player class optional.
    private var adPlayer : AdvertisementPlayer_tvOS?
    
    /// Background image url string
    private var backgroundImageUrlString: String?

    //MARK: - private Property
    private var timeObserverToken: Any?
    
    /// Video Object.
    var videoObject: VideoObject?

    /// Auto play array.
    var autoPlayObjectArray = [String]()
    
    /// Activity Indicator for player screen.
    private var acitivityIndicator : UIActivityIndicatorView?
    
    /// Activity Indicator for background image.
    private var imageOverlayAcitivityIndicator : UIActivityIndicatorView?
    
    /// Flag to keep check if observers are added or not.
    var addedObserverForCurrentItem : Bool = false
    
    /// AVPlayerViewController
    @objc var  videoPlayerVC  :  AVPlayerViewController?
    
    /// Holds Array of modules for the page.
    private var modulesListArray:Array<AnyObject> = []
    
    private var videoPlayerClickGesture: UITapGestureRecognizer?
    
    // Video Stream Id for Beacon Ping Events
    var videoStreamId : String?
    
    var isFirstFrameSent : Bool = false //Used to check if beacon event for first frame has fired

    /// Associated view object.
    private var _viewObject:VideoPlayerModuleViewObject?
    var viewObject:VideoPlayerModuleViewObject? {
        get {
            return _viewObject
        } set (newValue) {
            _viewObject = newValue
            if let layoutObject = newValue?.layoutObjectDict["appletv"] {
                self.viewLayout = layoutObject
            }
        }
    }
    
    /// asscociated module Object.
    var moduleObject: SFModuleObject?
    
    /// Associated view layout.
    var viewLayout:LayoutObject?
    
    /// Parent view's frame.
    var relativeViewFrame:CGRect?
    
    // Background video image
    var backgroundVideoImageView: SFImageView?
    
    // Background video image
    var focusHighlightImageView: SFImageView?
    
    /// Set if the video is free.
    private var isFreeVideo:Bool = false
    
    /// Set if the video is live.
    private var isLiveStream:Bool = false
    
    private var playbackDeniedOnLoad:Bool = false
    
    /// Check if the user paused the playback.
    private var playbackPausedByUser:Bool = false
    
    var userUnsubscribedLabel: UILabel?
    
    var swipeDownGesture: UISwipeGestureRecognizer?
    
    /// Computed get only property for getting player frame.
    private var playerViewFrame: CGRect {
        get {
            var width:Float = 1920, height:Float = 1080, x:Float = 0, y:Float = 0
            if let playerWidth = viewLayout?.playerWidth {
                width = playerWidth
            }
            if let playerHeight = viewLayout?.playerHeight {
                height = playerHeight
            }
            if let playerX = viewLayout?.playerXAxis {
                x = playerX
            }
            if let playerY = viewLayout?.playerYAxis {
                y = playerY
            }
            if let playerHolderVC = playerHolderViewController {
                if playerHolderVC.isShowing() {
                    return CGRect(x: 0, y: 0, width: 1920, height: 1080)
                }
            }
            return CGRect(x: Int(x), y: Int(y), width: Int(width), height: Int(height))
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        resetPlayer()
        NotificationCenter.default.removeObserver(self, name: kPreviewEndEnforcerTimeUp, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("MenuToggled"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ApplicationWillResignActive"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ApplicationBecameActive"), object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("BackButtonTapped"), object: nil)
    }
    
    init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        self.view.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createModules()
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "#000000")
//        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(togglePlayerZoomAction), name: NSNotification.Name("BackButtonTapped"), object: nil)
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(stopPlayback), name: kPreviewEndEnforcerTimeUp, object: nil)
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(menuToggled), name: NSNotification.Name("MenuToggled"), object: nil)
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(appBecameActive), name: NSNotification.Name("ApplicationBecameActive"), object: nil)
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(wilResignActive), name: NSNotification.Name("ApplicationWillResignActive"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc private func appBecameActive() {
        /// Check if, player is added play the video.
        
        if let videoPlayer = videoPlayerVC {
            if self.isShowing() && (Constants.kAPPDELEGATE.appContainerVC?.isMenuViewShowing)! == false {
                if playbackPausedByUser == false {
                    videoPlayer.player?.volume = 1.0
                    playVideo(videoPlayer: videoPlayer)
                }
            } else {
                videoPlayer.player?.volume = 0.0
                pauseVideo(videoPlayer: videoPlayer)
            }
        }
        
        if let adPlayer = adPlayer {
            if self.isShowing() && (Constants.kAPPDELEGATE.appContainerVC?.isMenuViewShowing)! == false {
                if playbackPausedByUser == false {
                    adPlayer.volume = 1.0
                    adPlayer.play()
                }
            } else {
                adPlayer.volume = 0.0
                adPlayer.pause()
            }
        }
    }
    
    @objc private func wilResignActive() {
        /// Check if, player is added play the video.
        if let videoPlayer = videoPlayerVC {
            videoPlayer.player?.volume = 0.0
            pauseVideo(videoPlayer: videoPlayer)
        }
        
        if let adPlayer = adPlayer {
            adPlayer.volume = 0.0
            adPlayer.pause()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /// Check if, player is added play the video.
        if self.isShowing() && (Constants.kAPPDELEGATE.appContainerVC?.isMenuViewShowing)! == false {
            if let videoPlayer = videoPlayerVC {
                if playbackPausedByUser == false {
                    videoPlayer.player?.volume = 1.0
                    playVideo(videoPlayer: videoPlayer)
                }
            } else if let adPlayer = adPlayer {
                if playbackPausedByUser == false {
                    adPlayer.volume = 1.0
                    adPlayer.play()
                }
            } else if playbackDeniedOnLoad {
                //Check if ad already played.
                if didAdFinishPlaying {
                    createCustomPlayer()
                } else {
                    checkForAdsAndPlayVideoOrAds()
                }
            }
        }
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        /// Check if, player is added pause the video.
        if let videoPlayer = videoPlayerVC {
            videoPlayer.player?.volume = 0.0
            pauseVideo(videoPlayer: videoPlayer)
        }
        if let adPlayer = adPlayer {
            adPlayer.volume = 0.0
            adPlayer.pause()
        }
        super.viewWillDisappear(animated)
    }
    
    /// Starting point which trigger page creations.
    func constructPage() {
        addActivityIndicator()
        createPageViewElements()
        videoObject = VideoObject(gridObject: fetchGridObject())
        checkForAdsAndPlayVideoOrAds()
    }
    
    //MARK: View Creation Methods.
    /// Method to create modules for the page.
    private func createModules() {
        if modulesListArray.isEmpty == false {
            createPageViewElements()
        }
    }
    
    //MARK: Creating view elements
    private func createPageViewElements() {
        for component:AnyObject in (self._viewObject?.components)! {
            if component is SFImageObject {
                createImageView(imageObject: component as! SFImageObject)
            }
        }
    }
    
    func createImageView(imageObject:SFImageObject) -> Void {
        
        let imageView = SFImageView()
        imageView.imageViewObject = imageObject
        imageView.relativeViewFrame = self.view.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
        imageView.updateView()
        if imageObject.key == "movieImageView" {
            self.removeActivityIndicator()
            backgroundVideoImageView = imageView
            backgroundVideoImageView?.frame = playerViewFrame
            imageOverlayAcitivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            imageOverlayAcitivityIndicator?.center = CGPoint(x: (backgroundVideoImageView?.bounds.width)!/2, y: (backgroundVideoImageView?.bounds.height)!/2)
            backgroundVideoImageView?.addSubview(imageOverlayAcitivityIndicator!)
            imageOverlayAcitivityIndicator?.startAnimating()
            if let appBackgroundImage = UIImage(named: "app_background") {
                backgroundVideoImageView?.image = appBackgroundImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                if let backGroundColor = AppConfiguration.sharedAppConfiguration.backgroundColor{
                    backgroundVideoImageView?.tintColor = Utility.hexStringToUIColor(hex: backGroundColor)
                }
            }
            videoPlayerClickGesture = UITapGestureRecognizer.init(target: self, action: #selector(VideoPlayerModule_tvOS.togglePlayerZoomAction))
            videoPlayerClickGesture?.numberOfTapsRequired = 1
//            self.view.addGestureRecognizer(videoPlayerClickGesture!)
            zoomButton = UIButton(frame: playerViewFrame)
            zoomButton?.backgroundColor = .clear
            self.view.addSubview(zoomButton!)
            view.bringSubview(toFront: zoomButton!)
            zoomButton?.addTarget(self, action: #selector(VideoPlayerModule_tvOS.togglePlayerZoomAction), for: .primaryActionTriggered)
            self.view.addSubview(imageView)
            
        } else if imageObject.key == "focusHighlightImage" {
            //            if let image = UIImage(named: "playerFocusbackground") {
            //                imageView.image = image
            //            }
            focusHighlightImageView = imageView
            setGradientOnFocusHighlightImage()
            self.view.addSubview(imageView)
            focusHighlightImageView?.isHidden = true
            self.view.sendSubview(toBack: focusHighlightImageView!)
            focusHighlightImageView?.alpha = 0.0
        }
        self.view.changeFrameHeight(height: relativeViewFrame?.size.height ?? 1080)

        swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeDownGesture?.direction = UISwipeGestureRecognizerDirection.down
//        self.view.addGestureRecognizer(swipeDownGesture!)
    }
    
    private func setGradientOnFocusHighlightImage() {
        let appBackgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        let appPrimaryHover = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "000000")
        let startColor = RGBA(red: appBackgroundColor.redValue, green: appBackgroundColor.greenValue, blue: appBackgroundColor.blueValue, alpha: appBackgroundColor.alphaValue)
        let endColor = RGBA(red: appPrimaryHover.redValue, green: appPrimaryHover.greenValue, blue: appPrimaryHover.blueValue, alpha: appPrimaryHover.alphaValue)
        let gradientImage = UIImage.image(withRGBAGradientPoints: [GradientPoint(location: 0, color: startColor), GradientPoint(location: 1, color: endColor)], size: CGSize(width: (focusHighlightImageView?.bounds.size.width ?? 0.0), height: (focusHighlightImageView?.bounds.size.height ?? 0.0)))
        focusHighlightImageView?.image = gradientImage
    }
    
    @objc private func togglePlayerZoomAction() {
        togglePlayerZoom()
    }
    
    private func togglePlayerZoom(animationCompletion: (() -> Void)? = nil) {
        weak var _super = self.parent
        if let _ = backgroundVideoImageView { //If video player not present, do not do anything!
            if backgroundVideoImageView?.alpha != 0 && playerLayer == nil {
                if let playerHolderVC = playerHolderViewController {
                    if playerHolderVC.isShowing() == false {
                        return
                    }
                } else {
                    return
                }
            }
        }
        let isZoomSupported = viewObject?.isZoomSupported ?? false
        if isZoomSupported {
            zoomButton?.isEnabled = false
            videoPlayerClickGesture?.isEnabled = false
            let notificationDict: [String:Bool] = ["zoomed":!playerZoomed]
            if let videoPlayer = videoPlayerVC?.player {
                if Double(videoPlayer.rate) > 0.0 {
                    playbackPausedByUser = false
                    videoPlayer.volume = 1.0
                    
                } else {
                    videoPlayer.volume = 0.0
                    playbackPausedByUser = true
                }
            }
            if playerZoomed {
                self.playerHolderViewController?.dismiss(animated: false, completion: {
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name("BackButtonTapped"), object: nil)
                    UIView.animate(withDuration: 0.1, animations: { [weak self] in
                        guard let _ = self else {
                            return
                        }
                        self?.view.frame = (self?.relativeViewFrame)!
                        if let videoPlayer = self?.videoPlayerVC {
                            videoPlayer.view.frame = (self?.playerViewFrame)!
                        } else {
                            if let adLayer = self?.playerLayer {
                                adLayer.frame = (self?.playerViewFrame)!
                                self?.adLabel?.changeFrameXAxis(xAxis: (self?.playerViewFrame.size.width)! + (self?.playerViewFrame.origin.x)! - 120)
                                self?.adLabel?.changeFrameYAxis(yAxis: (self?.playerViewFrame.origin.y)! + (self?.playerViewFrame.size.height)! - 120)
                            }
                        }
                    }) { [weak self] (completed) in
                        guard let _ = self else {
                            return
                        }
                        if let backgroundImageView = self?.backgroundVideoImageView {
                            backgroundImageView.frame = (self?.playerViewFrame)!
                            self?.imageOverlayAcitivityIndicator?.center = CGPoint(x: backgroundImageView.bounds.width/2, y: backgroundImageView.bounds.height/2)
                        }
                        self?.presenterView?.addSubview((self?.view)!)
                        self?.videoPlayerVC?.showsPlaybackControls = false
                        self?.videoPlayerVC?.view.isUserInteractionEnabled = false
                        self?.zoomButton?.isEnabled = true
                        self?.videoPlayerClickGesture?.isEnabled = true
                        Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name(rawValue: kPlayerZoomToggledNotification), object: notificationDict)
                        self?.view.bringSubview(toFront: (self?.zoomButton)!)
                        if let _completion = animationCompletion {
                            _completion()
                        }
                    }
                })
            } else {
                self.presenterView = self.view.superview
                if self.playerHolderViewController == nil {
                    self.playerHolderViewController = VideoPlayerHolderViewContoller()
                    self.playerHolderViewController?.view.frame = CGRect(x: 0, y: 0, width: 1920, height:1080)
                    self.playerHolderViewController?.view.backgroundColor = .black
                }
                UIView.animate(withDuration: 0.1, animations: { [weak self] in
                    guard let _ = self else {
                        return
                    }
                    self?.view.frame = CGRect(x: 0, y: 0, width: 1920, height:1080)
                    if let videoPlayer = self?.videoPlayerVC {
                        videoPlayer.view.frame = CGRect(x: 0, y: 0, width: 1920, height:1080)
                    } else {
                        if let adLayer = self?.playerLayer {
                            adLayer.frame = CGRect(x: 0, y: 0, width: 1920, height:1080)
                            self?.adLabel?.changeFrameXAxis(xAxis: 1800)
                            self?.adLabel?.changeFrameYAxis(yAxis: 960)
                        }
                    }
                    self?.playerHolderViewController?.view.addSubview((self?.view)!)
                }) { [weak self] (completed) in
                    guard let _ = self else {
                        return
                    }
                    if let _ = _super {
                        _super?.present((self?.playerHolderViewController)!, animated: true, completion: {
                            Constants.kNOTIFICATIONCENTER.addObserver(self!, selector: #selector(self?.togglePlayerZoomAction), name: NSNotification.Name("BackButtonTapped"), object: nil)
                            if let backgroundImageView = self?.backgroundVideoImageView {
                                backgroundImageView.frame = (self?.playerViewFrame)!
                                self?.imageOverlayAcitivityIndicator?.center = CGPoint(x: backgroundImageView.bounds.width/2, y: backgroundImageView.bounds.height/2)
                            }
                            if let adPlayer = self?.adPlayer {
                                adPlayer.volume = 1.0
                                adPlayer.play()
                            }
                            if let videoPlayer = self?.videoPlayerVC?.player {
                                if self?.playbackPausedByUser == false {
                                    videoPlayer.play()
                                    videoPlayer.volume = 1.0
                                }
                            }
                        })
                    } else {
                        Constants.kAPPDELEGATE.appContainerVC?.present((self?.playerHolderViewController)!, animated: true, completion: {
                            Constants.kNOTIFICATIONCENTER.addObserver(self!, selector: #selector(self?.togglePlayerZoomAction), name: NSNotification.Name("BackButtonTapped"), object: nil)
                            if let backgroundImageView = self?.backgroundVideoImageView {
                                backgroundImageView.frame = (self?.playerViewFrame)!
                                self?.imageOverlayAcitivityIndicator?.center = CGPoint(x: backgroundImageView.bounds.width/2, y: backgroundImageView.bounds.height/2)
                            }
                            if let adPlayer = self?.adPlayer {
                                adPlayer.volume = 1.0
                                adPlayer.play()
                            }
                            if let videoPlayer = self?.videoPlayerVC?.player {
                                if self?.playbackPausedByUser == false {
                                    videoPlayer.play()
                                    videoPlayer.volume = 1.0
                                }
                            }
                        })
                    }
                    
//                    if (self?.isLiveStream)! {
//                        self?.videoPlayerVC?.showsPlaybackControls = true
//                    }
                    self?.videoPlayerVC?.showsPlaybackControls = true
                    self?.videoPlayerVC?.view.isUserInteractionEnabled = true
                    self?.videoPlayerClickGesture?.isEnabled = true
                    self?.view.sendSubview(toBack: (self?.zoomButton)!)
                    Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name(rawValue: kPlayerZoomToggledNotification), object: notificationDict)
                    if let _completion = animationCompletion {
                        _completion()
                    }
                }
            }
        } else {
            if let _completion = animationCompletion {
                _completion()
            }
        }
    }
    
    @objc private func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.down:
                if delegate != nil && (delegate?.responds(to: #selector(VideoPlayerModuleDelegate.scrollToNextFocusableItem)))! {
                    delegate?.scrollToNextFocusableItem!()
                }
            default:
                break
            }
        }
    }
    
    /// Fetching image URL to be shown player.
    ///
    /// - Returns: image URL string.
    private func setImageForPlayer(urlString: String) {
        if let backgroundImageView = backgroundVideoImageView {
            if urlString.isEmpty == false {
                let imageURL = urlString.appending("?impolicy=resize&w=\(backgroundImageView.frame.size.width)&h=\(backgroundImageView.frame.size.height )")
                if let url = URL(string: imageURL) {
                    backgroundImageView.af_setImage(
                        withURL:url,
                        placeholderImage: nil,
                        filter: nil,
                        imageTransition: .crossDissolve(1)
                    )
                }
            }
        }
        if urlString.isEmpty == false {
            if let imageUrl = URL(string: urlString) {
                previewEndCard.imageUrl = imageUrl
            }
        }
    }
    
    /// Fetching content Id of the video to be played.
    ///
    /// - Returns: contentId of the item.
    private func fetchContentIdForPlayer() -> String {
        var contentId: String?
        if let moduleObject = moduleObject {
            if let moduleData = moduleObject.moduleData {
                let trayObject = moduleData[0] as! SFGridObject
                contentId = trayObject.contentId
            }
        }
        return contentId ?? ""
    }
    
    /// Fetching gridObject of the video to be played.
    ///
    /// - Returns: contentId of the item.
    private func fetchGridObject() -> SFGridObject {
        var gridObject: SFGridObject?
        if let moduleObject = moduleObject {
            if let moduleData = moduleObject.moduleData {
                gridObject = moduleData[0] as? SFGridObject
            }
        }
        return gridObject!
    }
    
    private func shouldPlayVideo() -> Bool {
        var shouldPlay = false
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            let isSubscribed = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool ?? false)
            if isSubscribed == false {
                if self.isFreeVideo {
                    shouldPlay = true
                } else {
                    if Constants.kPreviewEndEnforcer.isPreviewAllowed {
                        shouldPlay = true
                    } else {
                        shouldPlay = false
                    }
                }
            } else {
                shouldPlay = true
            }
        } else {
            shouldPlay = true
        }
        return shouldPlay
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
    
    /// Fetching video details.
    ///
    /// - Parameters:
    ///   - contentId: contentId for video to be played.
    ///   - completed: completion callback.
    private func fetchVideoDetails(contentId: String, completed: @escaping (String) -> ()) {
        DataManger.sharedInstance.fetchURLDetailsForVideo(apiEndPoint: "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/videos/\(contentId)?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&fields=streamingInfo,gist(free,videoImageUrl,posterImageUrl,imageGist),contentDetails(closedCaptions,relatedVideoIds)") { [weak self] (videoURLWithStatusDict) in
            
            guard let checkedSelf = self else {
                return
            }
            checkedSelf.isFreeVideo = videoURLWithStatusDict?["isFreeVideo"] as? Bool ?? false
            
            if checkedSelf.autoPlayObjectArray.isEmpty {
                
                let relatedVideoIds:Array<String>? = videoURLWithStatusDict?["relatedVideoIds"] as? Array<String>
                
                if relatedVideoIds != nil {
                    
                    checkedSelf.autoPlayObjectArray = relatedVideoIds!
                }
            }
            
            let filmURLs:Dictionary<String, AnyObject>? = videoURLWithStatusDict?["urls"] as? Dictionary<String, AnyObject>
            
            if filmURLs != nil {
                completed(checkedSelf.prepareUrlToBePlayed(videoUrls: filmURLs))
            }
            
            if let gistDict:Dictionary<String, AnyObject> = videoURLWithStatusDict?["imageUrls"] as? Dictionary<String, AnyObject> {
                if let videoImageUrl = gistDict["videoImage"] {
                    checkedSelf.backgroundImageUrlString = videoImageUrl as? String
                    checkedSelf.setImageForPlayer(urlString:checkedSelf.backgroundImageUrlString!)
                } else {
                    
                }
            }
        }
    }
    
    /// Fethcing the correct URL to be played.
    ///
    /// - Parameter videoUrls: dictionary of recieved video URLs.
    /// - Returns: URL to be played.
    private func prepareUrlToBePlayed(videoUrls:Dictionary<String, AnyObject>?) -> String {
        
        self.videoStreamId = Utility.generateStreamID(movieName: videoObject?.videoTitle ?? "")
        self.isFirstFrameSent = false
        var videoUrlToBePlayed:String?
        if shouldPlayVideo() {
            let videoUrls:Dictionary<String, AnyObject>? = videoUrls?["videoUrl"] as? Dictionary<String, AnyObject>
            let rendentionUrls:Array<AnyObject>? = videoUrls?["renditionUrl"] as? Array<AnyObject>
            let hlsUrl:String? = videoUrls?["hlsUrl"] as? String
            
            if hlsUrl != nil {
                
                videoUrlToBePlayed = hlsUrl
            } else if rendentionUrls != nil {
                
                if (rendentionUrls?.count)! > 0 {
                    
                    let renditionUrlDict:Dictionary<String, AnyObject>? = rendentionUrls?.last as? Dictionary<String, AnyObject>
                    
                    videoUrlToBePlayed = renditionUrlDict?["renditionUrl"] as? String
                }
            }
//            videoUrlToBePlayed = "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
//            videoUrlToBePlayed = "https://snagfilms-lh.akamaihd.net/i/Laxsportsnetwork_1@322790/master.m3u8?7544bdcc50dae6fd8d8ebeb3ba54706c7eb1db7bd808eb469b2094bb2d8fa248a93aed9f18570510bf020033a32d809b23"
        } else {
            videoUrlToBePlayed = "Not Subscribed"
        }
        
        return videoUrlToBePlayed ?? ""
    }
    
    private func removeSubscribeNowPrompt() {
        if let label = userUnsubscribedLabel {
            label.removeFromSuperview()
        }
    }

    
    //MARK: Player related methods.
    private func createCustomPlayer() {
        if let backgroundImageView = backgroundVideoImageView {
            backgroundImageView.alpha = 1.0
        }
        focusHighlightImageView?.alpha = 1.0
        fetchVideoDetails(contentId: (videoObject?.videoContentId)!) { [weak self] (playbackURL) in
            
            guard let _ = self else {
                return
            }
            if playbackURL == "Not Subscribed" {
                self?.playbackDeniedOnLoad = true
                self?.prepareViewForEndCard()
            } else {
                self?.removeSubscribeNowPrompt()
                guard let url = URL(string: playbackURL) else{
                    self?.playNext()
                    return
                }
                let asset = AVAsset(url: url)
                
                let playableKey = "playable"
                
                // Load the "playable" property
                asset.loadValuesAsynchronously(forKeys: [playableKey]) {
                    var error: NSError? = nil
                    let status = asset.statusOfValue(forKey: playableKey, error: &error)
                    switch status {
                    case .loaded:
                        // Sucessfully loaded. Continue processing.
                        DispatchQueue.main.async { [weak self] in
                            guard let checkedSelf = self else {
                                return
                            }
                            checkedSelf.createPlayerWithAsset(asset)
                        }
                        break
                    case .failed:
                        //Keep showing image view
                        break
                    case .cancelled:
                        //Keep showing image view
                        break
                    default:
                        //Keep showing image view
                        break
                    }
                }
            }
        }
    }

    /// Create video player module or add directly.
    ///
    /// - Parameter asset: asset to be added to the player.
    private func createPlayerWithAsset(_ asset : AVAsset) {
        //process format-specific metadata collection
        //Create player item
        let  playerItem = AVPlayerItem(asset: asset)
        
        //Create player instance
        let player = AVPlayer(playerItem: playerItem)
        self.videoPlayerVC = AVPlayerViewController()
        self.view.frame = relativeViewFrame!
        self.videoPlayerVC?.view.frame = playerViewFrame
        if playerZoomed {
            self.videoPlayerVC?.showsPlaybackControls = true
            self.videoPlayerVC?.view.isUserInteractionEnabled = true
        } else {
            self.videoPlayerVC?.showsPlaybackControls = false
            self.videoPlayerVC?.view.isUserInteractionEnabled = false
        }
        // Associate player with view controller
        self.videoPlayerVC?.player = player
        
        //GA play event
        GATrackerTVOS.sharedInstance().event(withCategory: "player-video", action: "playVideo", label: fetchContentIdForPlayer(), customParameters: [ "ev" : String(Int(-1)) ])
        
        self.addObserverForPlayer()
        
        //Beacon PLAY Event.
        self.fireBeaconPlayEvent()
        currentTimeStamp = Date()
        
        //Add Notification for the player.
        self.addNotificationForPlayer()
        self.videoPlayerVC?.view.alpha = 0.0
        //Add video Player Controller view
        self.view.addSubview((self.videoPlayerVC?.view)!)
        self.view.changeFrameHeight(height: relativeViewFrame?.size.height ?? 1080)
    }
    
    private  func removeObservers() -> Void {
        if videoPlayerVC?.player?.currentItem != nil && addedObserverForCurrentItem == true {
            removeObserver(self, forKeyPath: #keyPath(videoPlayerVC.player.currentItem.status), context: &videoPlayerKVOContext)
            removeObserver(self, forKeyPath: #keyPath(videoPlayerVC.player.currentItem.loadedTimeRanges), context: &videoPlayerKVOContext)
            removeObserver(self, forKeyPath: #keyPath(videoPlayerVC.player.currentItem.isPlaybackBufferEmpty), context: &videoPlayerKVOContext)
            addedObserverForCurrentItem = false
        }
    }
    
    private func addObserverForPlayer() {
        if addedObserverForCurrentItem == false {
            addPeriodicTimeObserver()
            //Add observer on player current item
            addObserver(self, forKeyPath: #keyPath(videoPlayerVC.player.currentItem.loadedTimeRanges), options: [.new, .initial], context: &videoPlayerKVOContext)
            addObserver(self, forKeyPath: #keyPath(videoPlayerVC.player.currentItem.isPlaybackBufferEmpty), options: [.new, .initial], context: &videoPlayerKVOContext)
            addObserver(self, forKeyPath: #keyPath(videoPlayerVC.player.currentItem.status), options: [.new, .initial], context: &videoPlayerKVOContext)
            addedObserverForCurrentItem = true
        }
    }
    
    //MARK: -  Periodic Observer Methods
    private func addPeriodicTimeObserver() {
        // Notify every 1 second
        let time = CMTime(seconds: 0.1, preferredTimescale: 10)
        timeObserverToken = self.videoPlayerVC?.player?.addPeriodicTimeObserver(forInterval: time,  queue: .main) {
            [weak self] time in
            guard let checkedSelf = self else {return}
            let time : Float64 = CMTimeGetSeconds((checkedSelf.videoPlayerVC?.player!.currentTime())!);
            if (Int(time) > 0 && (checkedSelf.videoPlayerVC?.player?.rate)! > Float(0.0) && Int(time) % 30 == 0) {
                checkedSelf.fireBeaconEventOnEveryThirtySeconds(currentTime: Float(time))
            }
            if let videoPlayer = checkedSelf.videoPlayerVC {
                if checkedSelf.isShowing() == false {
                    if (videoPlayer.player?.rate)! > Float(0.0) {
                        videoPlayer.player?.volume = 0.0
                        checkedSelf.pauseVideo(videoPlayer: videoPlayer)
                    }
                } else {
                    if (videoPlayer.player?.volume)! < Float(1.0) {
                        videoPlayer.player?.volume = 1.0
                    }
                }
            }
        }
    }
    
    @objc private func menuToggled() {
        if let videoPlayer = self.videoPlayerVC {
            if self.isShowing() == true {
                if (Constants.kAPPDELEGATE.appContainerVC?.isMenuViewShowing)! {
                    videoPlayer.player?.volume = 0.0
                    pauseVideo(videoPlayer: videoPlayer)
                } else {
                    if playbackPausedByUser == false {
                        videoPlayer.player?.volume = 1.0
                        playVideo(videoPlayer: videoPlayer)
                    }
                }
            }
        }
        
        if let adPlayer = adPlayer {
            if self.isShowing() == true {
                if (Constants.kAPPDELEGATE.appContainerVC?.isMenuViewShowing)! {
                    adPlayer.volume = 0.0
                    adPlayer.pause()
                } else {
                    if playbackPausedByUser == false {
                        adPlayer.volume = 1.0
                        adPlayer.play()
                    }
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
    
    private func resetPlayer(){
        
        //remove notification
        self.removeNotifications()
        
        //remove Observers
        self.removeObservers()
        
        self.removePeriodicTimeObserver()
        
        //Player is end playing the video remove the player and notification.
        self.removePlayer()
    }
    
    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            self.videoPlayerVC?.player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    private func removePlayer() -> Void{
        if let videoPlayer = videoPlayerVC {
            pauseVideo(videoPlayer: videoPlayer)
        }
        self.videoPlayerVC?.player =  nil
        self.videoPlayerVC?.view.removeFromSuperview()
        self.videoPlayerVC = nil
    }
    
    func videoPlayerItemDidFinishedPlaying(notification: Notification) -> Void {
        playNext()
    }
    
    private func playNext() {
        if let autoPlay = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) as? Bool
        {
            if autoPlay
            {
//                if playerZoomed {
//                    togglePlayerZoom(animationCompletion: { [weak self] in
//                        guard let _ = self else { return }
//                        self?.resetPlayer()
//                        if self?.autoPlayObjectArray.isEmpty == false {
//                            self?.videoObject?.videoContentId = self?.autoPlayObjectArray[0]
//                            self?.autoPlayObjectArray.remove(at: 0)
//                            self?.addActivityIndicator()
//                            self?.fetchAutoPlayArrayAndFilmDetails(completion: { [weak self] in
//                                if let checkedSelf = self {
//                                    checkedSelf.resetPlayer()
//                                    checkedSelf.checkForAdsAndPlayVideoOrAds()
//                                }
//                            })
//                        }
//                    })
//                } else {
                    self.resetPlayer()
                    if autoPlayObjectArray.isEmpty == false {
                        videoObject?.videoContentId = autoPlayObjectArray[0]
                        autoPlayObjectArray.remove(at: 0)
                        self.addActivityIndicator()
                        fetchAutoPlayArrayAndFilmDetails(completion: { [weak self] in
                            if let checkedSelf = self {
                                checkedSelf.resetPlayer()
                                checkedSelf.checkForAdsAndPlayVideoOrAds()
                            }
                        })
                    }
//                }
            } else {
                //Stay as is. Do nothing.
            }
        } else {
            //Stay as is. Do nothing.
        }
    }
    
    /// Method to fetch Auto Play array. This additionally shortens the array by removing repeating value.
    ///
    /// - Parameter completion: completion callback on fetch completion.
    private func fetchAutoPlayArrayAndFilmDetails(completion: @escaping (() -> Void)) {
        
        AutoPlayArrayHandler().getTheAutoPlaybackArrayForFilm(film: (videoObject?.videoContentId)!) { [weak self] (arrayOfFilmIds, film) in
            //Fill auto play only once.
            if self?.autoPlayObjectArray == nil {
                if let arrayOfFilmIds = arrayOfFilmIds {
                    //Removing any duplicates.
                    var reducedArray = Array<String>()
                    for id in arrayOfFilmIds {
                        if let contentId = self?.videoObject?.videoContentId {
                            if (id as! String) != contentId {
                                reducedArray.append(id as! String)
                            }
                        }
                    }
                    self?.autoPlayObjectArray = reducedArray
                } else {
                    completion()
                    return
                }
            }
            //Update the current film object everytime on method call.
            if let checkedSelf = self {
                if film != nil{
                    completion()
                }
                else{
                    if checkedSelf.autoPlayObjectArray.isEmpty == false {
                        checkedSelf.videoObject?.videoContentId = checkedSelf.autoPlayObjectArray[0]
                        checkedSelf.autoPlayObjectArray.remove(at: 0)
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
                //Beacon VIDEO FAILED Event.
                self.fireBeaconPlaybackFailedEvent()
                self.removeActivityIndicator()
                self.imageOverlayAcitivityIndicator?.isHidden = true
            }
            else if newStatus == .readyToPlay {
                self.removeActivityIndicator()
                //Beacon FIRST FRAME Event.
                if(isFirstFrameSent == false)
                {
                    isFirstFrameSent = true
                    self.fireBeaconFirstFrameEvent()
                }
                //Beacon FIRST FRAME Event.
                UIView.animate(withDuration: 1, animations: { [weak self] in
                    
                    guard let checkedSelf = self else {
                        return
                    }
                    checkedSelf.backgroundVideoImageView?.alpha = 0.0
                    checkedSelf.videoPlayerVC?.view.alpha = 1.0
                    if let swipeDown = checkedSelf.swipeDownGesture {
                        checkedSelf.view.removeGestureRecognizer(swipeDown)
                    }
                }, completion: { [weak self] (completed) in
                    guard let checkedSelf = self else {
                        return
                    }
                    if checkedSelf.isShowing() && (Constants.kAPPDELEGATE.appContainerVC?.isMenuViewShowing)! == false {
                        if checkedSelf.playbackPausedByUser == false {
                            checkedSelf.videoPlayerVC?.player?.volume = 1.0
                            if checkedSelf.shouldPlayVideo() {
                                if let videoPlayer = checkedSelf.videoPlayerVC {
                                    checkedSelf.playVideo(videoPlayer: videoPlayer)
                                }
                            }
                        }
                    }
                })
            }
            else if newStatus == .unknown {
                if lastBeaconPingedTime != nil || secondsBuffered != nil {
                    //Beacon DROPPED STREAM Event.
                    self.fireBeaconDroppedStreamEvent()
                }
            }
        }
        else if keyPath == #keyPath(videoPlayerVC.player.currentItem.isPlaybackBufferEmpty) {
                //Beacon BUFFERING Event.
                self.fireBeaconBufferingEvent()
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
    
    //MARK: Fire BeaconEvents after every thirty seconds.
    private func fireBeaconEventOnEveryThirtySeconds(currentTime:Float) {
        if(lastBeaconPingedTime == currentTime) {
            return
        }
        lastBeaconPingedTime = currentTime
        //Beacon PING Event.
        self.fireBeaconPingEvent(currentTime: currentTime)
    }
    
    @objc private func stopPlayback() {
        prepareViewForEndCard(completed: { [weak self] in
            guard let _ = self else {return}
            self?.resetPlayer()
        })
    }
    
    //MARK: - End Card View Methods.
    private func prepareViewForEndCard(completed: (() -> Void)? = nil) {
        if playerZoomed {
            togglePlayerZoom(animationCompletion: { [weak self] in
                guard let _ = self else { return }
                DispatchQueue.main.async {
                    self?.createAndAddEndCardView()
                    if let _completed = completed {
                        _completed()
                    }
                }
            })
        } else {
            createAndAddEndCardView()
            if let _completed = completed {
                _completed()
            }
        }
    }
    
    private func createAndAddEndCardView() {
        self.playbackDeniedOnLoad = true
        self.previewEndCard.completionHandler = { (shouldPlayVideo) in
            self.previewEndCard.view.removeFromSuperview()
        }
        self.view.changeFrameHeight(height: relativeViewFrame?.size.height ?? 1080)
        self.addChildViewController(self.previewEndCard)
        if let backgroundImageString = backgroundImageUrlString {
            self.setImageForPlayer(urlString:backgroundImageString)
        }
        self.previewEndCard.view.frame = playerViewFrame
        self.previewEndCard.view.alpha = 1.0
        self.view.addSubview(self.previewEndCard.view)
        self.view.setNeedsFocusUpdate()
        self.view.changeFrameHeight(height: relativeViewFrame?.size.height ?? 1080)
    }
    
    //MARK: - Activity Indicator Methods
    private func addActivityIndicator(){
        if acitivityIndicator == nil {
            self.acitivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        }
        if let videoPlayer = videoPlayerVC {
            self.acitivityIndicator!.center = CGPoint(x: videoPlayer.view.bounds.width/2, y: videoPlayer.view.bounds.height/2)
        } else if let _playerLayer = playerLayer {
            self.acitivityIndicator!.center = CGPoint(x: _playerLayer.bounds.width/2, y: _playerLayer.bounds.height/2)
        } else {
            self.acitivityIndicator!.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        }
        self.view.addSubview(self.acitivityIndicator!)
        self.view.changeFrameHeight(height: relativeViewFrame?.size.height ?? 1080)
        self.acitivityIndicator!.startAnimating()
    }
    
    private func removeActivityIndicator(){
        if let tempActivityIndicatorView = self.acitivityIndicator
        {
            tempActivityIndicatorView.removeFromSuperview()
            tempActivityIndicatorView.stopAnimating();
        }
    }
    
    private func playVideo(videoPlayer: AVPlayerViewController) {
        videoPlayer.player?.play()
        if isFreeVideo == false {
            Constants.kPreviewEndEnforcer.startAppOnTimeTracking()
        }
    }
    
    private func pauseVideo(videoPlayer: AVPlayerViewController) {
        videoPlayer.player?.pause()
        if isFreeVideo == false {
            Constants.kPreviewEndEnforcer.pauseAppOnTimeTracking()
        }
    }
    
    // Ad Player.
    
    //MARK: - ADXMLParser Delegate
    func advURlToBePlayed(adURLToPlay: String?, skipDuration: Int?) {
        
        self.removeActivityIndicator()
        adParser = nil
        
        if let adURlString = adURLToPlay{
            print("add url to play : \(adURlString)")
            createAndConfigureAdPlayer(adURlString,skipDuration: skipDuration)
        }
        else{
            createCustomPlayer()
        }
        
    }
    
    private func checkForAdsAndPlayVideoOrAds ()
    {
        var isSubscribed = false
        if let _isSubscribed = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool) {
            isSubscribed = _isSubscribed
        }
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && isSubscribed { //Bypassing ads only in one case.
            createCustomPlayer()
        } else {
            checkIfVideoIsLive(contentId: (videoObject?.videoContentId)!, completed: { [weak self] (isLive) in
                guard let checkedSelf = self else {return}
                if isLive == false {
                    checkedSelf.dfpTag = checkedSelf.preparedfpTag()
                    if  (checkedSelf.dfpTag != nil && (checkedSelf.dfpTag?.characters.count)! > 0) && checkedSelf.adParser == nil && checkedSelf.videoPlayerVC == nil{
//                        checkedSelf.addActivityIndicator()
                        if checkedSelf.adParser == nil {
                            checkedSelf.adParser = AdXMLParser.init(xmlURl: checkedSelf.dfpTag!)
                            checkedSelf.adParser?.delegate = checkedSelf
                            checkedSelf.adParser?.configureParserAndStartParsing()
                        }
                    }
                    else {
                        checkedSelf.createCustomPlayer()
                    }
                } else {
                    checkedSelf.createCustomPlayer()
                }
            })
        }
    }
    
    private func preparedfpTag() -> String {
        let isSubscribed = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) ?? false
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && isSubscribed as! Bool {
            return ""
        } else {
            let timeInMilliSeconds:Int64 = Int64(Date().timeIntervalSince1970)
            
            if let videoAdTag = AppConfiguration.sharedAppConfiguration.videoAdTag {
            
            let adTagEndPoint = "&url=https://\(AppConfiguration.sharedAppConfiguration.domainName ?? "")\(videoObject?.gridPermalink ?? "")&ad_rule=0&correlator=\(timeInMilliSeconds)&cust_params=APPID%3D\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
            
                return videoAdTag.appending(adTagEndPoint)
            }
            else {

                return ""
            }
        }
    }
    
    private func createAndConfigureAdPlayer(_ urlString : String, skipDuration: Int?) {
        let isNetworkAvailable = NetworkStatus.sharedInstance.isNetworkAvailable()
        if isNetworkAvailable {
            if let backgroundImageView = backgroundVideoImageView {
                if let appBackgroundImage = UIImage(named: "app_background") {
                    backgroundImageView.image = appBackgroundImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    if let backGroundColor = AppConfiguration.sharedAppConfiguration.backgroundColor{
                        backgroundImageView.tintColor = Utility.hexStringToUIColor(hex: backGroundColor)
                    }
                }
                backgroundImageView.alpha = 1.0
                self.view.bringSubview(toFront: backgroundImageView)
                focusHighlightImageView?.alpha = 1.0
            }
            let videoURL = URL(string: urlString)//"http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4")
            if adPlayer == nil {
                adPlayer = AdvertisementPlayer_tvOS(url: videoURL!)
            }
            adPlayer?.skipDuration = skipDuration
            adPlayer?.videoObjectBeingPlayed = videoObject
            adPlayer?.videoStreamId = videoStreamId
            adPlayer?.delegate = self
            if playerLayer == nil {
                playerLayer = AVPlayerLayer(player: adPlayer)
            }
            adPlayer?.setObserversForPlayer()
            adPlayer?.addNotificationForCurrentItem()
            self.view.changeFrameHeight(height: relativeViewFrame?.size.height ?? 1080)
            playerLayer?.frame = playerViewFrame
            self.view.layer.addSublayer(playerLayer!)
            self.view.backgroundColor = .clear
            if let zoomButton = zoomButton { //In order to zoom ad player.
                self.view.bringSubview(toFront: zoomButton)
            }
            self.view.changeFrameHeight(height: relativeViewFrame?.size.height ?? 1080)
        }
    }
    
    //MARK : - AdvertisementPlayer delegate
    
    func adPlayerStartPlayingAds() {
        if self.isShowing() == false || (Constants.kAPPDELEGATE.appContainerVC?.isMenuViewShowing)! == true {
            self.adPlayer?.volume = 0.0
            self.adPlayer?.pause()
        } else {
            self.adPlayer?.volume = 1.0
            self.adPlayer?.play()
        }
        didAdFinishPlaying = false
        self.view.changeFrameWidth(width: relativeViewFrame?.size.width ?? 1920)
        self.view.changeFrameHeight(height: relativeViewFrame?.size.height ?? 1080)
        adLabel = UILabel(frame: CGRect(x: playerViewFrame.size.width + playerViewFrame.origin.x - 120, y: playerViewFrame.origin.y + playerViewFrame.size.height - 120, width: 120, height: 50))
        var fontFamily: String?
        if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
            fontFamily = _fontFamily
        }
        if fontFamily == nil {
            fontFamily = "OpenSans"
        }
        adLabel?.font = UIFont(name: "\(fontFamily!)-SemiBold", size: 30)
        adLabel?.text = "Ad"
        adLabel?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        adLabel?.textAlignment = .center
        adLabel?.textColor = .white
        adLabel?.shadowColor = .black
        self.view.addSubview(adLabel!)
        self.removeActivityIndicator()
    }
    
    func adPlayerFailsToPlayAds()  {
        didAdFinishPlaying = true
        adLabel?.removeFromSuperview()
        self.removeActivityIndicator()
        removeAdPlayer()
        ///Play video if ad is failing to play.
        createCustomPlayer()
    }
    
    func adPlayerFinishedPlayingAds(){
        stopAdPlaybackAndConfigurePlayer()
    }
    
    private func stopAdPlaybackAndConfigurePlayer() {
        didAdFinishPlaying = true
        adLabel?.removeFromSuperview()
        if playerZoomed && shouldPlayVideo() == false {
            togglePlayerZoom(animationCompletion: { [weak self] in
                guard let _ = self else { return }
                //Play video/movie after ad.
                self?.removeAdPlayer()
                self?.createCustomPlayer()
            })
        } else {
            removeAdPlayer()
            createCustomPlayer()
        }
    }
    
    func adCanBeSkipped() {
        if let _adLabel = adLabel {
            _adLabel.text = "Press Play to Skip"
        }
    }
    
    func adCurrentPlaybackTimeUpdated() {
        if let _adPlayer = adPlayer {
            if self.isShowing() && (Constants.kAPPDELEGATE.appContainerVC?.isMenuViewShowing)! == false {} else {
                if let holderVC = playerHolderViewController {
                    if holderVC.isShowing() == false {
                        if _adPlayer.rate > 0.0 {
                            _adPlayer.pause()
                        }
                    }
                }
            }
        }
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
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        focusHighlightImageView?.isHidden = true
        if let focusedView = context.nextFocusedView {
            if focusedView.parentViewController == self {
                focusHighlightImageView?.isHidden = false
            }
        }
    }
    
//    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        if presses.first?.type == UIPressType.playPause {
//            if let _ = adPlayer {
//                if let _adLabel = adLabel {
//                    if _adLabel.text == "Press Play to Skip" {
//                        stopAdPlaybackAndConfigurePlayer()
//                    }
//                }
//            }
//        }
//    }
}

fileprivate class VideoPlayerHolderViewContoller: UIViewController {
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.first?.type == .menu {
            Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name(rawValue: "BackButtonTapped"), object: nil)
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
