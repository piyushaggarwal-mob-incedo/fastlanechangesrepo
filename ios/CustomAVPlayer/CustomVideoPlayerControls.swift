//
//  CustomVideoPlayerControls.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 08/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import MarqueeLabel
import MediaPlayer

@objc protocol VideoPlayerControlsDelegate: NSObjectProtocol {
    
    @objc func videoPlayerAddSubtitle() -> Void
    @objc func videoPLayerAddTimerForElapsedTimeLabel() -> Void
    
    @objc func videoPlayerSeekBack() -> Void
    @objc func videoPlayerSeekForward() -> Void
    
    @objc func sliderValueChanged(newValue: Float64) -> Void
    @objc func sliderValueBeganTraking(newValue: Float64) -> Void
    @objc func sliderValueEndTraking(newValue: Float64) -> Void

    @objc func videoPlayerBackButtonTapped() -> Void
    @objc func videoPlayerClosedCaptionButtonTapped(sender: UIButton) -> Void
    @objc func videoPlayerPlayButtonTapped() -> Void
    @objc func videoPlayerChromCastButtonTapped(sender: UIButton) -> Void
    @objc func videoPlayerAirplayButtonTapped() -> Void
    @objc func videoPlayerFullScreenButtonTapped() -> Void
    @objc func videoPlayerSettingsTapped() -> Void
}

class CustomVideoPlayerControls: UIView {

    enum PlayerControlScreen : String
    {
        case full
        case small
    }
    
    enum PlayerControlType : String
    {
        case liveVideoControls
        case streamVideoControls
        case downloadedControls
    }
    
    weak var playerControlDelegate: VideoPlayerControlsDelegate?
    
    private var playerControlScreen: PlayerControlScreen
    private var playerControlType: PlayerControlType
    
    private var chromecastButton: UIButton!
    private var backbutton: UIButton!
    private var videoTitle: MarqueeLabel!
    private var airPlayButton: MPVolumeView!
    private var settingsButton: UIButton!
    
    private var playButton: UIButton!
    private var rewindButton: UIButton!
    private var forwardButton: UIButton!
    private var videoSeekSlider: CustomSlider!
    private var timeRemainingLabel: UILabel!
    private var fullScreenButton: UIButton!
    private var gradientView: UIView!
    private var ccButton: UIButton!
    private var ccLabel:UILabel!
    var isSubTitleAvailable:Bool = false
    var subTitleUrlStr:String!   = ""
    private let ccButtonWidth:CGFloat = 38
    private let ccButtonHeight:CGFloat = 30
    private var isBackButtonTapped: Bool = false

    private let controlsHeight: CGFloat = 30
    private let timeLabelWidth: CGFloat = 70
    private let airplayButtonWidth: CGFloat = 44
    
    private var topGradientLayer: CAGradientLayer!
    private var bottomGradientLayer: CAGradientLayer!

    private let videoObject: VideoObject
    
    private let viewDisplayed: Bool = false
    
    
    func networkConnectionChanged() {
        if self.backbutton != nil {
            let reachability:Reachability = Reachability.forInternetConnection()
            if reachability.currentReachabilityStatus() == NotReachable {
                self.chromecastButton.isHidden = true
                self.airPlayButton.isHidden = true
            }
            else{
                self.chromecastButton.isHidden = self.viewDisplayed
            }
        }
    }
    
    init(frame: CGRect, videoDetailObject: VideoObject, videoPlayerType: PlayerControlType) {
        self.playerControlType = videoPlayerType
        self.playerControlScreen = .small
        self.videoObject = videoDetailObject
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewLoad() -> Void
    {
        let controlsY: CGFloat = self.bounds.size.height - controlsHeight - 5
        
        self.backbutton.frame = CGRect.init(x: 5, y: 5, width: 23, height: 32)
        self.chromecastButton.frame = CGRect.init(x: self.frame.width - 35, y: 11, width: 30, height: 40)
        self.chromecastButton.sizeToFit()
        self.airPlayButton.frame = CGRect.init(x: self.frame.width - airplayButtonWidth - 40, y: 0, width: airplayButtonWidth, height: airplayButtonWidth)
        
        self.videoTitle.frame = CGRect.init(x: self.backbutton.frame.maxX + 5, y: 10, width: airPlayButton.frame.minX - backbutton.frame.maxX - 10, height: 22)
        self.playButton.frame = CGRect.init(x: 13, y: controlsY + 3, width: 18.5, height: 21)
        self.rewindButton.frame = CGRect.init(x: self.playButton.frame.maxX + 13, y: controlsY, width: 26, height: 26)
        self.forwardButton.frame = CGRect.init(x: self.playButton.frame.maxX + 13, y: controlsY, width: 26, height: 26)
        self.settingsButton.frame = CGRect.init(x: self.playButton.frame.maxX + 13, y: controlsY, width: 26, height: 26)
        self.videoSeekSlider.frame = CGRect(x: self.rewindButton.frame.maxX + 15,
                                            y: controlsY, width: self.bounds.size.width - ( self.rewindButton.frame.maxX + 15) - timeLabelWidth - 10, height: controlsHeight)
        self.timeRemainingLabel.frame = CGRect(x: self.videoSeekSlider.frame.maxX + 10, y: controlsY - 2, width: timeLabelWidth, height: controlsHeight)
        if(isSubTitleAvailable){
            self.videoSeekSlider.frame = CGRect(x: self.rewindButton.frame.maxX + 15,
                                                y: controlsY, width: self.bounds.size.width - ( self.rewindButton.frame.maxX + 15) - timeLabelWidth - 20 - ccButtonWidth, height: controlsHeight)
            
            self.timeRemainingLabel.frame = CGRect(x: self.videoSeekSlider.frame.maxX + 10, y: controlsY - 2, width: timeLabelWidth, height: controlsHeight)
            
            if (self.ccButton != nil){
                self.ccButton.frame = CGRect(x:self.timeRemainingLabel.frame.size.width+self.timeRemainingLabel.frame.origin.x-4,y:self.timeRemainingLabel.center.y-ccButtonHeight/2, width:ccButtonWidth, height:ccButtonHeight)
            }
        }
        
        if !Constants.IPHONE {
            if(self.chromecastButton != nil){
                CastPopOverView.shared.updateAlertFramesOnOrientation(chromeCastButton: self.chromecastButton, view: self)
            }
        }
    }
    
    func updateControls(with playerControlScreen: PlayerControlScreen)
    {
        self.playerControlScreen = playerControlScreen
        var controlsY: CGFloat = 0.0
        
        if self.playerControlScreen == .full
        {
            self.chromecastButton.isHidden = false
            self.airPlayButton.isHidden = false
            self.backbutton.isHidden = false
            self.videoTitle.isHidden = false
            self.fullScreenButton.isHidden = true
            self.backbutton.frame = CGRect.init(x: 5, y: 5, width: 23, height: 32)
            self.chromecastButton.frame = CGRect.init(x: self.frame.width - 35, y: 11, width: 30, height: 40)
            self.chromecastButton.sizeToFit()
            self.airPlayButton.frame = CGRect.init(x: self.frame.width - airplayButtonWidth - 40, y: 0, width: airplayButtonWidth, height: airplayButtonWidth)
            self.videoTitle.frame = CGRect.init(x: self.backbutton.frame.maxX + 5, y: 10, width: airPlayButton.frame.minX - backbutton.frame.maxX - 10, height: 22)
            controlsY = self.bounds.size.height - (controlsHeight * 2) - 5
            self.playButton.frame = CGRect.init(x: (self.frame.width - 18.5) / 2, y: controlsY + 3 + controlsHeight, width: 18.5, height: 21)
            
            switch self.playerControlType {
            case .liveVideoControls:
                self.rewindButton.isHidden = true
                self.forwardButton.isHidden = true
                self.settingsButton.isHidden = true
                self.videoSeekSlider.frame = CGRect(x: 15,
                                                    y: controlsY, width: self.bounds.size.width - timeLabelWidth - 10, height: controlsHeight)
                self.videoSeekSlider.isHidden = true
                self.timeRemainingLabel.frame = CGRect(x: self.videoSeekSlider.frame.maxX + 10, y: self.playButton.center.y - controlsHeight/2, width: timeLabelWidth/2, height: controlsHeight)
                if(isSubTitleAvailable){
                    self.videoSeekSlider.frame = CGRect(x: self.playButton.frame.maxX + 15,
                                                        y: controlsY, width: self.bounds.size.width - ( self.playButton.frame.maxX + 15) - timeLabelWidth - 20 - ccButtonWidth, height: controlsHeight)
                    
                    self.timeRemainingLabel.frame = CGRect(x: self.videoSeekSlider.frame.maxX + 10, y: self.playButton.frame.minY, width: timeLabelWidth/2, height: controlsHeight)
                    
                    if (self.ccButton != nil){
                        self.ccButton.frame = CGRect(x:self.frame.size.width - self.timeRemainingLabel.frame.origin.x - 10,y:self.timeRemainingLabel.center.y-ccButtonHeight/2, width:ccButtonWidth, height:ccButtonHeight)
                    }
                }
                
                if !Constants.IPHONE {
                    if(self.chromecastButton != nil){
                        CastPopOverView.shared.updateAlertFramesOnOrientation(chromeCastButton: self.chromecastButton, view: self)
                    }
                }
                self.fullScreenButton.frame = CGRect.init(x: self.timeRemainingLabel.frame.maxX + 10, y: self.playButton.frame.minY, width: 25, height: 25)
                break
                
            case .streamVideoControls:
                
                self.videoSeekSlider.isHidden = false
                self.rewindButton.isHidden = false
                self.forwardButton.isHidden = false
                self.settingsButton.isHidden = false
                self.rewindButton.frame = CGRect.init(x: self.playButton.frame.minX - 56, y: self.playButton.frame.minY - 3, width: 26, height: 26)
                self.forwardButton.frame = CGRect.init(x: self.playButton.frame.maxX + 30, y: self.playButton.frame.minY - 3, width: 26, height: 26)
                self.videoSeekSlider.frame = CGRect(x: 10,
                                                    y: controlsY, width: self.bounds.size.width - timeLabelWidth - 30, height: controlsHeight)
                self.timeRemainingLabel.frame = CGRect(x: self.videoSeekSlider.frame.maxX + 10, y: controlsY - 2, width: timeLabelWidth, height: controlsHeight)
                if(isSubTitleAvailable){
                    if (self.ccButton != nil){
                        self.ccButton.frame = CGRect(x:self.frame.size.width - ccButtonWidth - 25,y: controlsY + controlsHeight, width:ccButtonWidth, height:ccButtonHeight)
                    }
                }
                
                if !Constants.IPHONE {
                    if(self.chromecastButton != nil){
                        CastPopOverView.shared.updateAlertFramesOnOrientation(chromeCastButton: self.chromecastButton, view: self)
                    }
                }
                self.settingsButton.frame = CGRect(x:25, y: controlsY + controlsHeight, width:ccButtonWidth * 2, height:ccButtonHeight)
                self.fullScreenButton.frame = CGRect.init(x: self.timeRemainingLabel.frame.maxX + 1, y: self.playButton.frame.minY, width: 25, height: 25)
                break
                
            case .downloadedControls:
                self.videoSeekSlider.isHidden = false
                self.rewindButton.isHidden = false
                self.forwardButton.isHidden = false
                self.settingsButton.isHidden = true
                self.rewindButton.frame = CGRect.init(x: self.playButton.frame.minX - 56, y: self.playButton.frame.minY - 3, width: 26, height: 26)
                self.forwardButton.frame = CGRect.init(x: self.playButton.frame.maxX + 30, y: self.playButton.frame.minY - 3, width: 26, height: 26)
                self.videoSeekSlider.frame = CGRect(x: 10,
                                                    y: controlsY, width: self.bounds.size.width - timeLabelWidth - 30, height: controlsHeight)
                self.timeRemainingLabel.frame = CGRect(x: self.videoSeekSlider.frame.maxX + 10, y: controlsY - 2, width: timeLabelWidth, height: controlsHeight)
                if(isSubTitleAvailable){
                    if (self.ccButton != nil){
                        self.ccButton.frame = CGRect(x:self.frame.size.width - ccButtonWidth - 25,y: controlsY + controlsHeight, width:ccButtonWidth, height:ccButtonHeight)
                    }
                }
                
                if !Constants.IPHONE {
                    if(self.chromecastButton != nil){
                        CastPopOverView.shared.updateAlertFramesOnOrientation(chromeCastButton: self.chromecastButton, view: self)
                    }
                }
                self.settingsButton.frame = CGRect(x:25, y: controlsY + controlsHeight, width:ccButtonWidth * 2, height:ccButtonHeight)
                self.fullScreenButton.frame = CGRect.init(x: self.timeRemainingLabel.frame.maxX + 1, y: self.playButton.frame.minY, width: 25, height: 25)
                
                break
            }
        }
        else if self.playerControlScreen == .small
        {
            self.chromecastButton.isHidden = true
            self.airPlayButton.isHidden = true
            self.backbutton.isHidden = true
            self.videoTitle.isHidden = true
            self.fullScreenButton.isHidden = false
            self.forwardButton.isHidden = true
            self.settingsButton.isHidden = true
            controlsY = self.bounds.size.height - controlsHeight - 5
            self.playButton.frame = CGRect.init(x: 13, y: controlsY + 3, width: 18.5, height: 21)
            switch self.playerControlType {
            case .liveVideoControls:
                self.rewindButton.isHidden = true
                self.videoSeekSlider.frame = CGRect(x: self.playButton.frame.maxX + 15,
                                                    y: controlsY, width: self.bounds.size.width - ( self.playButton.frame.maxX + 15) - timeLabelWidth - 10, height: controlsHeight)
                self.videoSeekSlider.isHidden = true
                self.timeRemainingLabel.frame = CGRect(x: self.videoSeekSlider.frame.maxX + 10, y: controlsY - 2, width: timeLabelWidth/2, height: controlsHeight)
                if(isSubTitleAvailable){
                    self.videoSeekSlider.frame = CGRect(x: self.playButton.frame.maxX + 15,
                                                        y: controlsY, width: self.bounds.size.width - ( self.playButton.frame.maxX + 15) - timeLabelWidth - 20 - ccButtonWidth, height: controlsHeight)
                    
                    self.timeRemainingLabel.frame = CGRect(x: self.videoSeekSlider.frame.maxX + 10, y: controlsY - 2, width: timeLabelWidth/2, height: controlsHeight)
                    
                    if (self.ccButton != nil){
                        self.ccButton.frame = CGRect(x:self.timeRemainingLabel.frame.size.width+self.timeRemainingLabel.frame.origin.x-4,y:self.timeRemainingLabel.center.y-ccButtonHeight/2, width:ccButtonWidth, height:ccButtonHeight)
                    }
                }
                
                if !Constants.IPHONE {
                    if(self.chromecastButton != nil){
                        CastPopOverView.shared.updateAlertFramesOnOrientation(chromeCastButton: self.chromecastButton, view: self)
                    }
                }
                self.fullScreenButton.frame = CGRect.init(x: self.timeRemainingLabel.frame.maxX + 10, y: self.playButton.frame.minY, width: 25, height: 25)
                break
                
            case .streamVideoControls:
                
                self.videoSeekSlider.isHidden = false
                self.rewindButton.isHidden = false
                self.rewindButton.frame = CGRect.init(x: self.playButton.frame.maxX + 5, y: controlsY, width: 26, height: 26)
                self.videoSeekSlider.frame = CGRect(x: self.rewindButton.frame.maxX + 10,
                                                    y: controlsY, width: self.bounds.size.width - ( self.rewindButton.frame.maxX + 10) - timeLabelWidth - 40, height: controlsHeight)
                self.timeRemainingLabel.frame = CGRect(x: self.videoSeekSlider.frame.maxX + 10, y: controlsY - 2, width: timeLabelWidth, height: controlsHeight)
                if(isSubTitleAvailable){
                    self.videoSeekSlider.frame = CGRect(x: self.rewindButton.frame.maxX + 15,
                                                        y: controlsY, width: self.bounds.size.width - ( self.rewindButton.frame.maxX + 15) - timeLabelWidth - 20 - ccButtonWidth, height: controlsHeight)
                    
                    self.timeRemainingLabel.frame = CGRect(x: self.videoSeekSlider.frame.maxX, y: controlsY - 2, width: timeLabelWidth, height: controlsHeight)
                    
                    if (self.ccButton != nil){
                        self.ccButton.frame = CGRect(x:self.timeRemainingLabel.frame.size.width+self.timeRemainingLabel.frame.origin.x-4,y:self.timeRemainingLabel.center.y-ccButtonHeight/2, width:ccButtonWidth, height:ccButtonHeight)
                    }
                }
                
                if !Constants.IPHONE {
                    if(self.chromecastButton != nil){
                        CastPopOverView.shared.updateAlertFramesOnOrientation(chromeCastButton: self.chromecastButton, view: self)
                    }
                }
                self.fullScreenButton.frame = CGRect.init(x: self.timeRemainingLabel.frame.maxX + 1, y: self.playButton.frame.minY, width: 25, height: 25)
                break
            case .downloadedControls:
                self.videoSeekSlider.isHidden = false
                self.rewindButton.isHidden = false
                self.rewindButton.frame = CGRect.init(x: self.playButton.frame.maxX + 5, y: controlsY, width: 26, height: 26)
                self.videoSeekSlider.frame = CGRect(x: self.rewindButton.frame.maxX + 10,
                                                    y: controlsY, width: self.bounds.size.width - ( self.rewindButton.frame.maxX + 10) - timeLabelWidth - 40, height: controlsHeight)
                self.timeRemainingLabel.frame = CGRect(x: self.videoSeekSlider.frame.maxX + 10, y: controlsY - 2, width: timeLabelWidth, height: controlsHeight)
                if(isSubTitleAvailable){
                    self.videoSeekSlider.frame = CGRect(x: self.rewindButton.frame.maxX + 15,
                                                        y: controlsY, width: self.bounds.size.width - ( self.rewindButton.frame.maxX + 15) - timeLabelWidth - 20 - ccButtonWidth, height: controlsHeight)
                    
                    self.timeRemainingLabel.frame = CGRect(x: self.videoSeekSlider.frame.maxX, y: controlsY - 2, width: timeLabelWidth, height: controlsHeight)
                    
                    if (self.ccButton != nil){
                        self.ccButton.frame = CGRect(x:self.timeRemainingLabel.frame.size.width+self.timeRemainingLabel.frame.origin.x-4,y:self.timeRemainingLabel.center.y-ccButtonHeight/2, width:ccButtonWidth, height:ccButtonHeight)
                    }
                }
                
                if !Constants.IPHONE {
                    if(self.chromecastButton != nil){
                        CastPopOverView.shared.updateAlertFramesOnOrientation(chromeCastButton: self.chromecastButton, view: self)
                    }
                }
                self.fullScreenButton.frame = CGRect.init(x: self.timeRemainingLabel.frame.maxX + 1, y: self.playButton.frame.minY, width: 25, height: 25)
                
                break
            }
        }

        
        addGradientView()
    }
    
    func updateViewWithSubtitle(present: Bool) -> Void {
        if self.ccButton != nil {
            self.ccButton.isHidden = !present
        }
    }
    
    func createView(subtitleUrlString:String, isSubtitleAvailable:Bool) -> Void {
        self.addGradientView()
        self.backbutton = UIButton.init(type: UIButtonType.custom)
        //        self.backbutton.frame = CGRect(x: 5, y: 5, width: 23, height: 32)
        self.backbutton.tag = 101
        self.backbutton.setImage(#imageLiteral(resourceName: "Back Chevron.png"), for: .normal)
        self.backbutton.addTarget(self, action: #selector(backButtonTapped(sender:)), for: .touchUpInside)
        self.backbutton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        self.addSubview(self.backbutton)
        
        var castImage = UIImage(named: Constants.IMAGE_NAV_BUTTON_CHROMECAST_NORMAL)
        
        if CastPopOverView.shared.isConnected(){
            castImage = UIImage(named: Constants.IMAGE_NAV_BUTTON_CHROMECAST_CONNECTED)
        }
        
        self.chromecastButton = UIButton(type: .custom)
        
        self.chromecastButton.addTarget(self, action: #selector(castButtonTapped(sender:)), for: .touchDown)
        self.chromecastButton.setImage(castImage, for: .normal)
        let listOfAvailableDevices = SecondScreenDeviceProvider.shared.allAvailableDevices()
        if listOfAvailableDevices.count > 0{
            chromecastButton.isHidden = false
        }
        else{
            chromecastButton.isHidden = false
        }
        self.addSubview(self.chromecastButton)
        
        
        self.fullScreenButton = UIButton(type: .custom)
        self.fullScreenButton.addTarget(self, action: #selector(fullScreenButtonTapped(sender:)), for: .touchDown)
        self.fullScreenButton.setImage(#imageLiteral(resourceName: "Fullscreen.png"), for: .normal)
        self.fullScreenButton.isHidden = false
        self.fullScreenButton.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1)
        self.addSubview(self.fullScreenButton)
        
        
        self.airPlayButton = MPVolumeView()
        airPlayButton.showsVolumeSlider = false
//        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
//        lpgr.minimumPressDuration = 0.01
//        lpgr.cancelsTouchesInView = false
//        airPlayButton.addGestureRecognizer(lpgr)
        self.addSubview(self.airPlayButton)
        
        self.videoTitle = MarqueeLabel()
        self.videoTitle.text = videoObject.videoTitle
        
        self.videoTitle.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Semibold", size: 15)
        self.videoTitle.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        setMarqueeProperties(marqueueLabel: self.videoTitle, isLabelized: true)
        self.addSubview(self.videoTitle)
        
        self.playButton = UIButton.init(type: UIButtonType.custom)
        self.playButton.setImage(#imageLiteral(resourceName: "Pause.png"), for: .selected)
        self.playButton.setImage(#imageLiteral(resourceName: "mediaPlay.png"), for: .normal)
        self.playButton.addTarget(self, action: #selector(playButtonTapped(sender:)), for: .touchUpInside)
        self.playButton.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1)
        
        self.playButton.isUserInteractionEnabled = true
        self.addSubview(self.playButton)
        
        self.rewindButton = UIButton.init(type: UIButtonType.custom)
        self.rewindButton.setImage(#imageLiteral(resourceName: "RewindButton.png"), for: .normal)
        self.rewindButton.addTarget(self, action: #selector(rewindButtonTapped(sender:)), for: .touchUpInside)
        self.rewindButton.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1)
        self.addSubview(self.rewindButton)
        
        self.forwardButton = UIButton.init(type: UIButtonType.custom)
        self.forwardButton.setImage(#imageLiteral(resourceName: "Forward.png"), for: .normal)
        self.forwardButton.addTarget(self, action: #selector(forwardButtonTapped(sender:)), for: .touchUpInside)
        self.forwardButton.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1)
        self.addSubview(self.forwardButton)
        
        self.settingsButton = UIButton.init(type: UIButtonType.custom)
        self.settingsButton.setTitleColor(.white, for: .normal)
        self.settingsButton.titleLabel?.font = UIFont.init(name: "OpenSans-Bold", size: 15)
        self.settingsButton.layer.cornerRadius = 5
        self.settingsButton.layer.borderWidth = 2
        self.settingsButton.layer.borderColor = UIColor.white.cgColor
        self.settingsButton.addTarget(self, action: #selector(settingsButtonTapped(sender:)), for: .touchUpInside)
        self.addSubview(self.settingsButton)
        
        switch self.playerControlType {
        case .liveVideoControls:
            self.videoSeekSlider = CustomSlider.init(sliderType: .liveVideoSlider, frame: CGRect.zero)
            self.videoSeekSlider.isUserInteractionEnabled = false
            break
        case .streamVideoControls:
            self.videoSeekSlider = CustomSlider.init(sliderType: .streamVideoSlider, frame: CGRect.zero)
            videoSeekSlider.addTarget(self, action: #selector(sliderBeganTracking),
                                      for: UIControlEvents.touchDown)
            videoSeekSlider.addTarget(self, action: #selector(sliderEndedTracking),
                                      for: [UIControlEvents.touchUpInside, UIControlEvents.touchUpOutside])
            videoSeekSlider.addTarget(self, action: #selector(sliderValueChanged),
                                      for: UIControlEvents.valueChanged)
            break
        case .downloadedControls:
            self.videoSeekSlider = CustomSlider.init(sliderType: .streamVideoSlider, frame: CGRect.zero)
            videoSeekSlider.addTarget(self, action: #selector(sliderBeganTracking),
                                      for: UIControlEvents.touchDown)
            videoSeekSlider.addTarget(self, action: #selector(sliderEndedTracking),
                                      for: [UIControlEvents.touchUpInside, UIControlEvents.touchUpOutside])
            videoSeekSlider.addTarget(self, action: #selector(sliderValueChanged),
                                      for: UIControlEvents.valueChanged)
            break
        }
        self.addSubview(videoSeekSlider)
        
        self.videoSeekSlider.isUserInteractionEnabled = false
        
        timeRemainingLabel = UILabel.init()
        timeRemainingLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        timeRemainingLabel.textAlignment = .center
        timeRemainingLabel.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 15)
        
        if self.playerControlType == .liveVideoControls
        {
            timeRemainingLabel.textColor = .red
            timeRemainingLabel.text = "LIVE"
            timeRemainingLabel.font = UIFont.boldSystemFont(ofSize: 12)
        }
        else
        {
            if self.playerControlDelegate != nil && (self.playerControlDelegate?.responds(to: #selector(self.playerControlDelegate?.videoPlayerAddSubtitle)))!
            {
                self.playerControlDelegate?.videoPlayerAddSubtitle()
            }
            timeRemainingLabel.textColor = .white
        }
        
        self.addSubview(timeRemainingLabel)
        
        self.isSubTitleAvailable = isSubtitleAvailable
        self.subTitleUrlStr = subtitleUrlString
//
        if (self.isSubTitleAvailable && !self.subTitleUrlStr.isEmpty)
        {
            let encodedSubTitleString = Utility.urlEncodedString_ch(emailStr: self.subTitleUrlStr)
            
            if !encodedSubTitleString.isEmpty {
                
                let subtitleURL = URL(string: encodedSubTitleString)
                
                if subtitleURL != nil {
                    if subtitleURL!.absoluteString != "" {
                        //CloesedCaption
                        self.ccButton = UIButton.init(type: UIButtonType.custom)
                        self.ccButton.addTarget(self, action: #selector(self.ccButtonTapped(sender:)), for: .touchUpInside)
//                        self.ccButton.setImage(#imageLiteral(resourceName: "icon_ cc_disable.png"), for: .normal)
//                        self.ccButton.setImage(#imageLiteral(resourceName: "icon_cc_enable.png"), for: .selected)
                        self.addSubview(self.ccButton)
                        self.ccButton.isSelected = Constants.kSTANDARDUSERDEFAULTS.bool(forKey: Constants.kIsCCEnabled)
                        
                        if self.ccButton.isSelected{
                            self.ccButton.setImage(#imageLiteral(resourceName: "icon_cc_enable.png"), for: .normal)
                        }
                        else{
                            self.ccButton.setImage(#imageLiteral(resourceName: "icon_ cc_disable.png"), for: .normal)
                        }
                        self.ccButton.isHidden = false
                        DispatchQueue.main.async {
                            if self.playerControlDelegate != nil && (self.playerControlDelegate?.responds(to: #selector(self.playerControlDelegate?.videoPlayerAddSubtitle)))!
                            {
                                self.playerControlDelegate?.videoPlayerAddSubtitle()
                            }
                        }
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector:#selector(networkConnectionChanged), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    
    func addGradientView()
    {
        if bottomGradientLayer != nil
        {
            bottomGradientLayer.removeFromSuperlayer()
            bottomGradientLayer = nil
        }
        if topGradientLayer != nil
        {
            topGradientLayer.removeFromSuperlayer()
            topGradientLayer = nil
        }
        
        if self.playerControlScreen == .full
        {
            topGradientLayer = CAGradientLayer()
            topGradientLayer.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: 60)
            
            topGradientLayer.locations = [0.0, 0.25, 0.65, 0.95]
            
            topGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            topGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            topGradientLayer.colors = [UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor, UIColor.clear.cgColor]
            self.layer.insertSublayer(topGradientLayer, at: 0)
            
            bottomGradientLayer = CAGradientLayer()
            bottomGradientLayer.frame = CGRect.init(x: 0, y: self.frame.height - 120, width: self.frame.width, height: 120)
            
            bottomGradientLayer.locations = [0.0, 0.25, 0.65, 0.95]
            
            bottomGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            bottomGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            bottomGradientLayer.colors = [UIColor.clear.cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor]
            self.layer.insertSublayer(bottomGradientLayer, at: 0)
        }
        else
        {
            bottomGradientLayer = CAGradientLayer()
            bottomGradientLayer.frame = CGRect.init(x: 0, y: self.frame.height - 60, width: self.frame.width, height: 60)
            
            bottomGradientLayer.locations = [0.0, 0.25, 0.65, 0.95]
            
            bottomGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            bottomGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            bottomGradientLayer.colors = [UIColor.clear.cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor]
            self.layer.insertSublayer(bottomGradientLayer, at: 0)
        }
    }
    
    //MARK: Set properties for Marquee label
    func setMarqueeProperties(marqueueLabel: MarqueeLabel, isLabelized:Bool) {
        
        marqueueLabel.type = .continuous
        marqueueLabel.speed = .duration(15.0)
        marqueueLabel.animationCurve = .easeInOut
        marqueueLabel.fadeLength = 10.0
        marqueueLabel.leadingBuffer = 10.0
        marqueueLabel.trailingBuffer = 15.0
        marqueueLabel.textAlignment = .center
        marqueueLabel.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        marqueueLabel.layer.shadowRadius = 1.0
        marqueueLabel.layer.shadowOpacity = 0.8
        marqueueLabel.layer.masksToBounds = false
        marqueueLabel.layer.shouldRasterize = true
    }
    
//    func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//
//        if gesture.state == .began {
//            self.isAirplaySheetVisible = true
//        }
//        else if gesture.state == .ended {
//            self.isAirplaySheetVisible = true
//            var keyWindow = UIApplication.shared.keyWindow
//            if keyWindow == nil {
//                keyWindow = UIApplication.shared.windows[0]
//            }
//            windowSubviews = (keyWindow?.layer.sublayers?.count)!
//        }
//
//        else if gesture.state == .cancelled {
//            self.isAirplaySheetVisible = true
//        }
//        else if gesture.state == .failed {
//            self.isAirplaySheetVisible = true
//        }
//    }
    
    func updateControlsWithNoInternet() -> Void {
        self.chromecastButton.isHidden = true
        self.airPlayButton.isHidden = true
    }
    
    func updateTimeLabel(timeLabelText: String) -> Void {
        timeRemainingLabel.text = timeLabelText
    }
    
    func isAirPlayRouteActive() -> Bool
    {
        return self.airPlayButton.isWirelessRouteActive
    }
    
    func updateSliderValue(sliderValue: Float) -> Void
    {
        self.videoSeekSlider.value = sliderValue
    }
    
    func setPlayButtonState(state: Bool) {
        self.playButton.isSelected = state
    }
    
    func getPlayButtonState() -> Bool {
        if self.playButton != nil
        {
            return self.playButton.isSelected
        }
        else
        {
            return false
        }
    }
    
    func isVideoPlayingViaAirplay() -> Bool
    {
        if self.airPlayButton != nil && self.airPlayButton.isWirelessRouteActive == true
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func setUserInteractionForControls(userInteraction: Bool)
    {
        if self.videoSeekSlider != nil {
            chromecastButton.isUserInteractionEnabled = userInteraction
            airPlayButton.isUserInteractionEnabled = userInteraction
            
            playButton.isUserInteractionEnabled = userInteraction
            rewindButton.isUserInteractionEnabled = userInteraction
            forwardButton.isUserInteractionEnabled = userInteraction
            
            settingsButton.isUserInteractionEnabled = userInteraction
            
            if self.playerControlType == .streamVideoControls || self.playerControlType == .downloadedControls
            {
                videoSeekSlider.isUserInteractionEnabled = userInteraction
            }
            else
            {
                videoSeekSlider.isUserInteractionEnabled = false
            }
            if ccButton != nil
            {
                ccButton.isUserInteractionEnabled = userInteraction
            }
        }
    }
    
    func setSliderQueuePoints(cuePoints: Array<AnyObject>, duration: TimeInterval)
    {
        self.videoSeekSlider.setCuePoints(cuePoints: cuePoints, duration: duration)
    }
    
    func backButtonTapped(sender: UIButton) -> Void {
        
        if !isBackButtonTapped
        {
            isBackButtonTapped = true
            if self.playerControlDelegate != nil && (self.playerControlDelegate?.responds(to: #selector(self.playerControlDelegate?.videoPlayerBackButtonTapped)))!
            {
                self.playerControlDelegate?.videoPlayerBackButtonTapped()
                self.isBackButtonTapped = false
            }
        }
    }
    
    func getBackButtonTappedState() -> Bool
    {
        return self.isBackButtonTapped
    }
    
    func setBackButtonTappedState(status: Bool)
    {
        self.isBackButtonTapped = status
    }
    
    func setSubtitleUrlString(subTitleString: String)
    {
        self.subTitleUrlStr = subTitleString
    }
    
    func getSubtitleUrlString() -> String
    {
        return self.subTitleUrlStr
    }
    
    func setIsSubTitleAvailable(isSubTitleAvailable: Bool)
    {
        self.isSubTitleAvailable = isSubTitleAvailable
    }
    
    func getIsSubTitleAvailable() -> Bool
    {
        return self.isSubTitleAvailable
    }
    
    func castButtonTapped(sender: UIButton) -> Void
    {
        if self.playerControlDelegate != nil && (self.playerControlDelegate?.responds(to: #selector(self.playerControlDelegate?.videoPlayerChromCastButtonTapped(sender:))))!
        {
            self.playerControlDelegate?.videoPlayerChromCastButtonTapped(sender: sender)
        }
    }
    
    func fullScreenButtonTapped(sender: UIButton)
    {
        //To be changed after small player orientation handling
//        self.updateControls(with: .full)
        if self.playerControlDelegate != nil && (self.playerControlDelegate?.responds(to: #selector(self.playerControlDelegate?.videoPlayerFullScreenButtonTapped)))!
        {
            self.playerControlDelegate?.videoPlayerFullScreenButtonTapped()
        }
    }
    
    func playButtonTapped(sender: UIButton) -> Void
    {
        self.playButton.isSelected = !self.playButton.isSelected
        if self.playerControlDelegate != nil && (self.playerControlDelegate?.responds(to: #selector(self.playerControlDelegate?.videoPlayerPlayButtonTapped)))!
        {
            self.playerControlDelegate?.videoPlayerPlayButtonTapped()
        }
    }
    
    func ccButtonTapped(sender: UIButton) -> Void {
        self.ccButton.isSelected = !self.ccButton.isSelected
        if self.ccButton.isSelected
        {
            self.ccButton.setImage(#imageLiteral(resourceName: "icon_cc_enable.png"), for: .normal)
        }
        else
        {
            self.ccButton.setImage(#imageLiteral(resourceName: "icon_ cc_disable.png"), for: .normal)
        }
        
        if self.playerControlDelegate != nil && (self.playerControlDelegate?.responds(to: #selector(self.playerControlDelegate?.videoPlayerClosedCaptionButtonTapped(sender:))))!
        {
            self.playerControlDelegate?.videoPlayerClosedCaptionButtonTapped(sender:sender)
        }
        
//        Constants.kSTANDARDUSERDEFAULTS.set(self.ccButton.isSelected, forKey: Constants.kIsCCEnabled)
    }
    
    func rewindButtonTapped(sender: UIButton) -> Void {
        if self.playerControlDelegate != nil && (self.playerControlDelegate?.responds(to: #selector(self.playerControlDelegate?.videoPlayerSeekBack)))!
        {
            self.playerControlDelegate?.videoPlayerSeekBack()
        }
    }
    
    func forwardButtonTapped(sender: UIButton) -> Void {
        if self.playerControlDelegate != nil && (self.playerControlDelegate?.responds(to: #selector(self.playerControlDelegate?.videoPlayerSeekForward)))!
        {
            self.playerControlDelegate?.videoPlayerSeekForward()
        }
    }
    
    func settingsButtonTapped(sender: UIButton) -> Void {
        if self.playerControlDelegate != nil && (self.playerControlDelegate?.responds(to: #selector(self.playerControlDelegate?.videoPlayerSettingsTapped)))!
        {
            self.playerControlDelegate?.videoPlayerSettingsTapped()
        }
    }
    
    
    func sliderBeganTracking(slider: UISlider) {
        if self.playerControlDelegate != nil && (self.playerControlDelegate?.responds(to: #selector(self.playerControlDelegate?.sliderValueBeganTraking(newValue:))))!
        {
            self.playerControlDelegate?.sliderValueBeganTraking(newValue:0.0)
        }
    }
    
    func sliderEndedTracking(slider: UISlider) {
        let sliderValue: Float64 = Float64(videoSeekSlider.value)
        if self.playerControlDelegate != nil && (self.playerControlDelegate?.responds(to: #selector(self.playerControlDelegate?.sliderValueEndTraking(newValue:))))!
        {
            self.playerControlDelegate?.sliderValueEndTraking(newValue: sliderValue)
        }
    }
    
    func sliderValueChanged(slider: UISlider)
    {
        let sliderValue: Float64 = Float64(videoSeekSlider.value)
        if self.playerControlDelegate != nil && (self.playerControlDelegate?.responds(to: #selector(self.playerControlDelegate?.sliderValueChanged(newValue:))))!
        {
            self.playerControlDelegate?.sliderValueChanged(newValue: sliderValue)
        }
    }
    
    func updateSettingButtonLabel(streamQualityString: String) -> Void
    {
        self.settingsButton.setTitle(streamQualityString,for: .normal)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
