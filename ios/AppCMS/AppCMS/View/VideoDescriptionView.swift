//
//  VideoDescriptionView.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 19/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import Cosmos

let titleLabelString = "videoTitle"
let showTitleLableString = "showTitle"
let showSubTitleLabelString = "showSubTitle"
let subTitleLabelString = "videoSubTitle"
let ageRatingLabelString = "ageLabel"
let closeButtonString = "closeButton"
let downloadButtonString = "downloadButton"
let shareButtonString = "shareButton"
let playButtonString = "playButton"
let watchlistButtonString = "watchlistButton"
let trailerButtonString = "watchTrailer"
let videoDescriptionString = "videoDescriptionText"
let showDescriptionString = "showDescriptionText"
let gridOptionsString = "gridOptions"
let publishDateString = "publishDateLabel"
let durationAndAuthorString = "durartionAndAuthorLabel"

@objc protocol VideoPlaybackDelegate: NSObjectProtocol {
    
    @objc func buttonTapped(button: SFButton, filmObject:SFFilm?, showObject:SFShow?) -> Void
    @objc func moreButtonTapped(filmObject: SFFilm?, showObject:SFShow?) -> Void
    @objc func starRatingTapped(filmObject: SFFilm?, showObject:SFShow?) -> Void
    @objc optional func playSelectedEpisode(filmObject:SFFilm?, nextEpisodesArray: Array<String>?) -> Void
    @objc optional func didSeasonSelectorButtonClicked(dropDownButton:SFDropDownButton?) -> Void
    
    @objc optional func videoPlayerFullScreenTapped(videoPlayer:CustomVideoController?, isFullScreenButtonTapped:Bool) -> Void
    @objc optional func videoPlayerUpdateForFullScreen(videoPlayer:CustomVideoController?) -> Void
    @objc optional func videoPlayerExitFullScreenTapped(videoPlayer:CustomVideoController?) -> Void
    @objc optional func videoPlayerAdded(videoPlayer:CustomVideoController?) -> Void
    @objc optional func videoPlayerFinishedPlayingMedia(videoPlayer: CustomVideoController?) -> Void

}

class VideoDescriptionView: UIView, SFButtonDelegate,downloadManagerDelegate, SFSeasonGridDelegate, VideoPlayerDelegate {
    
    
    weak var videoPlaybackDelegate: VideoPlaybackDelegate?
    var videoDescriptionModule: SFVideoDetailModuleObject!
    var showDescriptionModule: SFShowDetailModuleObject!
    var film: SFFilm!
    var show: SFShow!
    var watchlistStatus:Bool = false
    var roundProgressView:RoundProgressBar?
    var containerViewController:UIViewController!
    var seasonGridTrayObject:SFTrayObject?
    var selectedSeason:Int?
    var iOSVideoPlayer: CustomVideoController?
    private var videoDuration:Double?
    
    init(frame: CGRect, videoDescriptionModule: SFVideoDetailModuleObject, film: SFFilm, containerViewController:UIViewController, videoDuration:Double?) {
        
        super.init(frame: frame)
        self.videoDescriptionModule = videoDescriptionModule
        self.film = film
        self.containerViewController = containerViewController
        self.videoDuration = videoDuration
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayerProgress), name: NSNotification.Name(rawValue:"updatePlayerProgress"), object: nil)
        createView()
        fetchVideoStatus()
    }
    
    init(frame: CGRect, showDescriptionModule: SFShowDetailModuleObject, show: SFShow, containerViewController:UIViewController, selectedSeason: Int) {
        
        super.init(frame: frame)
        self.showDescriptionModule = showDescriptionModule
        self.show = show
        self.containerViewController = containerViewController
        self.selectedSeason = selectedSeason
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayerProgress), name: NSNotification.Name(rawValue:"updatePlayerProgress"), object: nil)
        createView()
        fetchVideoStatus()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createView() -> Void {
        if self.videoDescriptionModule != nil && self.videoDescriptionModule.videoDetailModuleComponents != nil
        {
            createVideoViewComponents(containerView: self, itemIndex: 0)
        }
        else if self.showDescriptionModule != nil && self.showDescriptionModule.showDetailModuleComponents != nil
        {
            createVideoViewComponents(containerView: self, itemIndex: 0)
        }
    }

    
    func fetchVideoStatus() {

        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {

            self.isUserInteractionEnabled = false

            DispatchQueue.global(qos: .userInitiated).async {

                DataManger.sharedInstance.getVideoStatus(videoId: (self.film != nil) ? self.film.id: (self.show != nil) ? self.show.showId : "", success: { (videoStatusResponseDict, isSuccess) in

                    DispatchQueue.main.async {

                        self.isUserInteractionEnabled = true

                        if videoStatusResponseDict != nil && isSuccess {

                            if videoStatusResponseDict?["isQueued"] != nil {

                                self.watchlistStatus = videoStatusResponseDict?["isQueued"] as! Bool
                            }

                            if videoStatusResponseDict?["watchedTime"] != nil {

                                if self.film != nil {
                                    
                                    self.film.filmWatchedDuration = (videoStatusResponseDict?["watchedTime"] as! Double)
                                }
                            }
                            if self.roundProgressView != nil
                            {
                                self.roundProgressView?.setTheProgressForItemForDownloadProgress(self.film)
                                self.roundProgressView?.downloadObject = DownloadManager.sharedInstance.getDownloadObject(for: self.film, andShouldSaveToDirectory: false)

                            }
                            self.updateButtonWatchlistStatus()
                        }
                    }
                })
            }
        }
    }
    
    
    func updateButtonWatchlistStatus() {
        
        for component: AnyObject in self.subviews {
            
            if component is SFButton {
                
                let button = component as! SFButton
                
                if button.buttonObject?.key == watchlistButtonString {
                    
                    button.isSelected = self.watchlistStatus
                }
            }
            else if component is SFProgressView {
                
                let progressView = component as! SFProgressView
                
                if self.film.filmWatchedDuration == 0 {
                    
                    progressView.isHidden = true
                }
                else {
                    
                    progressView.isHidden = false
                }
                
                UIView.animate(withDuration: 0.5, animations: {
                    progressView.setProgress(Float(self.film.filmWatchedDuration ?? 0) / Float(self.film.durationSeconds ?? 0), animated: true)
                })
            }
        }
    }
    
    
    func updateView() -> Void
    {
        for component: AnyObject in self.subviews {
            
            if component is SFButton {
                
                updateButtonViewFrame(button: component as! SFButton, containerView: self)
            }
            else if component is SFLabel {
                
                updateLabelViewFrame(label: component as! SFLabel, containerView: self)
            }
            else if component is SFStarRatingView {
                
                updateStarViewFrame(starView: component as! SFStarRatingView, containerView: self)
            }
            else if component is SFImageView {
                updateImageViewFrame(imageView: component as! SFImageView, containerView: self)
//                let videoUIObject: VideoUIObject = VideoUIObject()
//                videoUIObject.layoutObjectDict = (component as! SFImageObject).layoutObjectDict
//                videoUIObject.type = (component as! SFImageObject).type
//                videoUIObject.key = (component as! SFImageObject).key
//                updateVideoPlayerFrame(videoPlayerUIModule: videoUIObject, containerView: self)
            }
            else if component is SFTextView {
                
                updateTextViewFrame(textView: component as! SFTextView, containerView: self)
            }
            else if component is SFCastView {
                
                updateCastViewFrame(castView: component as! SFCastView, containerView: self)
            }
            else if component is SFProgressView {
                
                updateProgressView(progressView: component as! SFProgressView, containerView: self)
            }
            else if component is SFSeparatorView {
                
                updateSeparatorView(separatorView: component as! SFSeparatorView, containerView: self)
            }
            else if component is UIView {
                
                updateGridView(gridView: component as! UIView, containerView: self)
            }
        }
        if self.iOSVideoPlayer != nil && Constants.kAPPDELEGATE.isFullScreenEnabled == false {
            
            if Constants.IPHONE {
                Constants.kAPPDELEGATE.isFullScreenEnabled = true
            }
            for component:AnyObject in (self.videoDescriptionModule.videoDetailModuleComponents)!
            {
                let videoUIObject: VideoUIObject = VideoUIObject()
                
                if component is SFImageObject {
                    videoUIObject.layoutObjectDict = (component as! SFImageObject).layoutObjectDict
                    videoUIObject.type = (component as! SFImageObject).type
                    videoUIObject.key = (component as! SFImageObject).key

                    updateVideoPlayerFrame(videoPlayerUIModule: videoUIObject, containerView: self)
                }
                else if component is VideoObject {
                    videoUIObject.layoutObjectDict = (component as! VideoUIObject).layoutObjectDict
                    videoUIObject.type = (component as! VideoUIObject).type
                    videoUIObject.key = (component as! VideoUIObject).key
                    
                    updateVideoPlayerFrame(videoPlayerUIModule: videoUIObject, containerView: self)
                }
                if self.videoPlaybackDelegate != nil && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.videoPlayerAdded(videoPlayer:))))! {
                    self.videoPlaybackDelegate?.videoPlayerAdded!(videoPlayer: self.iOSVideoPlayer)
                }
            }
        }
    }
    
    func updateVideoPlayerFrameForFullScreen() -> Void {
        if self.videoPlaybackDelegate != nil && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.videoPlayerUpdateForFullScreen(videoPlayer:))))!
        {
            self.videoPlaybackDelegate?.videoPlayerUpdateForFullScreen!(videoPlayer: self.iOSVideoPlayer)
        }
        self.iOSVideoPlayer?.setPlayerFit(videoPlayerFit: .fullScreen)
    }
    
    
    //MARK: Creation of View Components
    func createVideoViewComponents(containerView: UIView, itemIndex:Int) {
        if self.videoDescriptionModule != nil
        {
            for component:AnyObject in (self.videoDescriptionModule.videoDetailModuleComponents)! {
                
                if component is SFButtonObject {
                    
                    let buttonObject:SFButtonObject = component as! SFButtonObject
                    
                    if buttonObject.key == "playButton" && self.videoDescriptionModule.isInlineVideoPlayer
                    {
                        
                    }
                    else
                    {
                        if buttonObject.isVisibleForTablet != nil {
                            
                            if !Constants.IPHONE && buttonObject.isVisibleForTablet! && (self.film.trailerURL != nil) {
                                createButtonView(buttonObject: buttonObject, containerView: self, itemIndex: itemIndex, type: component.key!!)
                            }
                        }
                        else {
                            createButtonView(buttonObject: buttonObject, containerView: self, itemIndex: itemIndex, type: component.key!!)
                        }
                    }
                }
                else if component is SFImageObject {
                    if self.videoDescriptionModule.isInlineVideoPlayer
                    {
                        let videoUIObject: VideoUIObject = VideoUIObject()
                        videoUIObject.layoutObjectDict = (component as! SFImageObject).layoutObjectDict
                        videoUIObject.type = (component as! SFImageObject).type
                        videoUIObject.key = (component as! SFImageObject).key
                        createVideoPlayer(videoPlayerUIModule: videoUIObject, containerView: containerView)
                    }
                    else
                    {
                        createImageView(imageObject: component as! SFImageObject, containerView: containerView)
                    }
                }
                else if component is VideoObject {
                    createVideoPlayer(videoPlayerUIModule: component as! VideoUIObject, containerView: containerView)
                }
                else if component is SFLabelObject {
                    
                    createLabelView(labelObject: component as! SFLabelObject, containerView: containerView, type: component.key!!)
                }
                else if component is SFTextViewObject{
                    createTextView(textViewObject: component as! SFTextViewObject, containerView: containerView, itemIndex: itemIndex)
                }
                else if component is SFStarRatingObject
                {
                    createStarView(starObject: component as! SFStarRatingObject, containerView: containerView)
                }
                else if component is SFCastViewObject
                {
                    createCastView(castObject: component as! SFCastViewObject, containerView: containerView)
                }
                else if component is SFProgressViewObject {
                    if !self.videoDescriptionModule.isInlineVideoPlayer
                    {
                        createProgressView(progressViewObject: component as! SFProgressViewObject, containerView: containerView)
                    }
                }
                else if component is SFSeparatorViewObject {
                    
                    createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject, containerView: containerView)
                }
            }
        }
        else if self.showDescriptionModule != nil
        {
            for component:AnyObject in (self.showDescriptionModule.showDetailModuleComponents)! {
                
                if component is SFButtonObject {
                    
                    let buttonObject:SFButtonObject = component as! SFButtonObject
                    
                    if buttonObject.isVisibleForTablet != nil {
                        
                        if !Constants.IPHONE && buttonObject.isVisibleForTablet! && (self.film.trailerURL != nil) {
                            createButtonView(buttonObject: buttonObject, containerView: self, itemIndex: itemIndex, type: component.key!!)
                        }
                    }
                    else {
                        createButtonView(buttonObject: buttonObject, containerView: self, itemIndex: itemIndex, type: component.key!!)
                    }
                }
                else if component is SFImageObject {
                    
                    createImageView(imageObject: component as! SFImageObject, containerView: containerView)
                }
                else if component is SFLabelObject {
                    
                    createLabelView(labelObject: component as! SFLabelObject, containerView: containerView, type: component.key!!)
                }
                else if component is SFTextViewObject{
                    createTextView(textViewObject: component as! SFTextViewObject, containerView: containerView, itemIndex: itemIndex)
                }
                else if component is SFStarRatingObject
                {
                    createStarView(starObject: component as! SFStarRatingObject, containerView: containerView)
                }
                else if component is SFCastViewObject
                {
                    createCastView(castObject: component as! SFCastViewObject, containerView: containerView)
                }
//                else if component is SFProgressViewObject {
//
//                    createProgressView(progressViewObject: component as! SFProgressViewObject, containerView: containerView)
//                }
                else if component is SFTrayObject {
                    
                    createGridView(trayObject: component as! SFTrayObject, containerView: self)
                }
                else if component is SFSeparatorViewObject {
                    
                    createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject, containerView: containerView)
                }
            }
        }
    }
    
    
    func createLabelView(labelObject:SFLabelObject, containerView:UIView, type: String) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        
        label.createLabelView()
        if type ==  titleLabelString {
            label.text = self.film.title
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
        else if type == showTitleLableString {
            
            label.text = self.show.showTitle
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
        else if type == subTitleLabelString
        {
            label.textColor = UIColor.white.withAlphaComponent(0.51)

            label.text = self.film.getVideoInfoString()
        }
        else if type == showSubTitleLabelString {
            
            label.textColor = UIColor.white.withAlphaComponent(0.51)
            label.text = self.show.getShowInfoString()
        }
        else if type == videoDescriptionString {
            
            label.numberOfLines = 0
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            if self.film.desc != nil {
                label.text = self.film.desc!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                let isReadMoreOptionAdded:Bool = label.addTrailing(with: "... ", moreText: "More", moreTextFont: label.font, moreTextColor: Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff"))
                
                if isReadMoreOptionAdded == true {
                    
                    let moreTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.moreTapGestureRecongniser(tapGesture:)))
                    label.isUserInteractionEnabled = true
                    label.addGestureRecognizer(moreTapGesture)
                }
            }
        }
        else if type == showDescriptionString {
            
            label.numberOfLines = 0
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            if self.show.desc != nil {
                label.text = self.show.desc!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                let isReadMoreOptionAdded:Bool = label.addTrailing(with: "... ", moreText: "More", moreTextFont: label.font, moreTextColor: Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff"))
                
                if isReadMoreOptionAdded == true {
                    
                    let moreTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.moreTapGestureRecongniser(tapGesture:)))
                    label.isUserInteractionEnabled = true
                    label.addGestureRecognizer(moreTapGesture)
                }
            }
        }
        else if type == publishDateString {
            
            if film != nil {
                
                var publishDateText:String = ""
                
                if labelObject.prefixText != nil {
                    
                    publishDateText = "\(labelObject.prefixText!) "
                }
                
                if let publishTime:Double = film?.publishDate {
                
                    let date = Date(timeIntervalSince1970: (publishTime / 1000.0))//(timeInterval / 1000.0))
                    let dateString = "\(date.getMonthName()) \(date.getDateString()), \(date.getYearString())"
                    
                    publishDateText.append(dateString)
                    
                    label.text = publishDateText
                }
            }
        }
        else if type == durationAndAuthorString {
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            if self.film != nil {
                
                if self.film.durationSeconds != nil {
                    
                    let totalTime:Double = Double((film?.durationSeconds)!)
                    // MSEIOS-1298: Issue 8 : Duration Shouldn't be indented
                    label.text = totalTime.timeFormattedString(interval: totalTime).replacingOccurrences(of: " ", with: "")
                }
            }
        }
        else if type == ageRatingLabelString
        {
            if self.film != nil && self.film.parentalRating != nil {
                
                label.layer.borderColor = UIColor.white.withAlphaComponent(0.39).cgColor
                label.textColor = UIColor.white.withAlphaComponent(0.39)
                label.text = Utility.sharedUtility.calculateParentalRating(parentalRating: self.film.parentalRating!) ?? ""
                label.textAlignment = .center
                label.layer.borderWidth = 2.0
                if (label.text?.isEmpty)! {
                    
                    label.isHidden = true
                }
            }
            else {
                label.isHidden = true
            }
        }
        
        containerView.addSubview(label)

        label.changeFrameXAxis(xAxis: label.frame.minX * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameYAxis(yAxis: label.frame.minY * Utility.getBaseScreenHeightMultiplier())
        label.changeFrameWidth(width: label.frame.width * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameHeight(height: label.frame.height * Utility.getBaseScreenHeightMultiplier())
        label.font = UIFont(name: label.font.fontName, size: label.font.pointSize * Utility.getBaseScreenHeightMultiplier())
    }
    
    func moreTapGestureRecongniser(tapGesture: UITapGestureRecognizer) -> Void {
        if self.videoPlaybackDelegate != nil && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.moreButtonTapped(filmObject:showObject:))))! {
            self.videoPlaybackDelegate?.moreButtonTapped(filmObject: self.film, showObject: self.show)
        }
    }
    
    func starTapGestureRecongniser(tapGesture: UITapGestureRecognizer) -> Void {
        return
//        if self.videoPlaybackDelegate != nil && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.starRatingTapped(filmObject:))))! {
//            self.videoPlaybackDelegate?.starRatingTapped(filmObject: self.film)
//        }
    }
    
    private func createButtonView(buttonObject:SFButtonObject, containerView:UIView, itemIndex:Int, type: String) -> Void {

        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)

        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.buttonLayout = buttonLayout
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.buttonDelegate = self
        button.tag = itemIndex
        button.createButtonView()

        button.changeFrameXAxis(xAxis: button.frame.minX * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameYAxis(yAxis: button.frame.minY * Utility.getBaseScreenHeightMultiplier())
        button.changeFrameWidth(width: button.frame.width * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameHeight(height: button.frame.height * Utility.getBaseScreenHeightMultiplier())

        if type == closeButtonString{
            let cancelButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "cancelIcon.png"))
            
            button.setImage(cancelButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        }
        else if type == downloadButtonString
        {
            if AppConfiguration.sharedAppConfiguration.isDownloadEnabled != nil {
                
                if (AppConfiguration.sharedAppConfiguration.isDownloadEnabled)! {
                    
                    if (self.roundProgressView == nil) {
                        self.roundProgressView = RoundProgressBar.init(with: DownloadManager.sharedInstance.getDownloadObject(for: self.film, andShouldSaveToDirectory: false))
                        self.addSubview(self.roundProgressView!)
                    }
                    DownloadManager.sharedInstance.downloadDelegate = self
                    self.roundProgressView?.frame = button.frame
                    self.roundProgressView?.setTheProgressForItemForDownloadProgress(self.film)
                    containerView.bringSubview(toFront: self.roundProgressView!)
                }
            }
            button.isHidden = true
        }
        else if type == shareButtonString
        {
            let shareButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "shareIcon.png"))
            
            button.setImage(shareButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        }
        else if type == playButtonString
        {
            if Constants.IPHONE {
                let playButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "videoDetailPlayIcon_iPhone.png"))
                
                button.setImage(playButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                button.imageView?.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")
            }
            else {
                let playButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "videoDetailPlayIcon_iPad.png"))
                
                button.setImage(playButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                button.imageView?.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")
            }
        }
        else if type == watchlistButtonString
        {
            button.setImage(#imageLiteral(resourceName: "addToWatchlistIcon.png"), for: .normal)
            button.setImage(#imageLiteral(resourceName: "removeFromWatchlistIcon.png"), for: .selected)

            button.isSelected = watchlistStatus
            
            if self.show != nil {
                
                button.isHidden = true
                button.isEnabled = false
            }
        }
        else if type == trailerButtonString
        {
            if self.film != nil && film.trailerId == nil {
                button.isHidden = true
            }
            else if self.show != nil && show.trailerId == nil {
                button.isHidden = true
            }
        }
        else if type == gridOptionsString {
            let gridButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "gridOptions.png"))
            
            button.setImage(gridButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        }
        
        button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!, size: (button.titleLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())

        containerView.addSubview(button)
        containerView.bringSubview(toFront: button)
    }

    private func createTextView(textViewObject:SFTextViewObject, containerView:UIView, itemIndex:Int) -> Void {
        
        let textViewLayout = Utility.fetchTextViewLayoutDetails(textViewObject: textViewObject)
        let textView:SFTextView = SFTextView()
        textView.relativeViewFrame = self.frame
        textView.initialiseTextViewFrameFromLayout(textViewLayout: textViewLayout)
        textView.textViewLayout = textViewLayout
        textView.textViewObject = textViewObject
        textView.updateView()
        textView.text = self.film.desc
        
        textView.changeFrameXAxis(xAxis: textView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        textView.changeFrameYAxis(yAxis: textView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        textView.changeFrameWidth(width: textView.frame.width * Utility.getBaseScreenWidthMultiplier())
        textView.changeFrameHeight(height: textView.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
            
            textView.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
        }
        
        self.addSubview(textView)
    }
    
    private func createImageView(imageObject:SFImageObject, containerView:UIView) {
        
        let imageView:SFImageView = SFImageView()
        imageView.imageViewObject = imageObject
        imageView.relativeViewFrame = containerView.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
        imageView.updateView()
        
        imageView.changeFrameYAxis(yAxis: imageView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        imageView.changeFrameWidth(width: imageView.frame.width * Utility.getBaseScreenWidthMultiplier())
        imageView.changeFrameHeight(height: imageView.frame.height * Utility.getBaseScreenHeightMultiplier())

        var imagePathString: String?
        
        if imageObject.key == "videoImage" || imageObject.key == "showImage" {
            
            imageView.isHidden = false
            
            if self.film != nil
            {
                for image in self.film.images {
                    let imageObj: SFImage = image as! SFImage
                    if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO
                    {
                        imagePathString = imageObj.imageSource
                        break
                    }
                }
            }
            else if self.show != nil
            {
                for image in self.show.images {
                    let imageObj: SFImage = image as! SFImage
                    if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO
                    {
                        imagePathString = imageObj.imageSource
                        break
                    }
                }
                
                if imagePathString == nil {

                    imagePathString = self.show.thumbnailImageURL
                }
            }
            
            if imagePathString != nil
            {
                imagePathString = imagePathString?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: imageView.frame.size.width))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: imageView.frame.size.height))")
                imagePathString = imagePathString?.trimmingCharacters(in: .whitespaces)
                
                if imagePathString != nil
                {
                    if let imageUrl = URL(string:imagePathString!) {
                        
                        imageView.af_setImage(
                            withURL: imageUrl,
                            placeholderImage: UIImage(named: Constants.kVideoImagePlaceholder),
                            filter: nil,
                            imageTransition: .crossDissolve(0.2)
                        )
                    }
                    else {
                        
                        imageView.image = UIImage(named: Constants.kVideoImagePlaceholder)
                    }
                }
                else
                {
                    imageView.image = UIImage(named: Constants.kVideoImagePlaceholder)
                }
            }
            else {
                
                imageView.image = UIImage(named: Constants.kVideoImagePlaceholder)
            }
        }
        else if imageObject.key == "badgeImage" {
            
            if self.film != nil
            {
                for image in self.film.images {
                    
                    let imageObj: SFImage = image as! SFImage
                    if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO
                    {
                        imagePathString = imageObj.badgeImageUrl
                        break
                    }
                }
            }
            else if self.show != nil
            {
                for image in self.show.images {
                    let imageObj: SFImage = image as! SFImage
                    if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO
                    {
                        imagePathString = imageObj.badgeImageUrl
                        break
                    }
                }
            }
            
            if imagePathString != nil
            {
                imagePathString = imagePathString?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: imageView.frame.size.width))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: imageView.frame.size.height))")
                imagePathString = imagePathString?.trimmingCharacters(in: .whitespaces)
                
                if imagePathString != nil
                {                    
                    imageView.isHidden = false

                    if let imageUrl = URL(string:imagePathString!) {
                        
                        imageView.af_setImage(
                            withURL: imageUrl,
                            placeholderImage: nil,
                            filter: nil,
                            imageTransition: .crossDissolve(0.2)
                        )
                    }
                }
                else {
                    
                    imageView.isHidden = true
                }
            }
            else {
                
                imageView.isHidden = true
            }
        }

        containerView.addSubview(imageView)
    }
    
    
    private func createVideoPlayer(videoPlayerUIModule:VideoUIObject, containerView:UIView)
    {
        let videoControllerObject: VideoObject = VideoObject()
        videoControllerObject.videoTitle = self.film.title ?? ""
        videoControllerObject.videoPlayerDuration = Double(self.film.durationSeconds ?? 0)
        videoControllerObject.videoContentId = self.film.id ?? ""
        videoControllerObject.gridPermalink = self.film.permaLink ?? ""
        videoControllerObject.videoWatchedTime = self.film.filmWatchedDuration ?? 0

//        if (gridObject.eventId != nil && Constants.kAPPDELEGATE.isKisweEnable == true) {
//
//            let cellFrame:CGRect = CGRect(x: containerView.frame.origin.x, y: containerView.frame.origin.y, width: containerView.frame.width, height: self.view.frame.width * 9/16)
//            let videoDescriptionView : LiveKiswePlayerDescriptionViewController = LiveKiswePlayerDescriptionViewController.init(frame: cellFrame, gridObject: gridObject)
//            videoDescriptionView.liveVideoPlaybackDelegate = self
//            self.addChildViewController(videoDescriptionView)
//            cell.addSubview(videoDescriptionView.view)
//        }
//        else{

        let isLiveVideo = self.film.isLiveStream ?? false
        if iOSVideoPlayer != nil{
            iOSVideoPlayer?.view.removeFromSuperview()
            iOSVideoPlayer?.removeFromParentViewController()
            
            iOSVideoPlayer = nil
        }
        iOSVideoPlayer = CustomVideoController.init(videoObject: videoControllerObject, videoPlayerType: isLiveVideo ? .liveVideoPlayer : .streamVideoPlayer, videoFitType: .smallScreen)
        iOSVideoPlayer?.videoPlayerDelegate = self
        iOSVideoPlayer?.videoDuration = videoDuration
        iOSVideoPlayer?.isVideoPlayedFromGrids = true
        let layoutObject: LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: videoPlayerUIModule.layoutObjectDict)
        let cellFrame:CGRect = CGRect.init(x: CGFloat(layoutObject.xAxis ?? 0.0), y: CGFloat(layoutObject.yAxis ?? 0.0), width: CGFloat(layoutObject.width ?? 0.0), height: CGFloat(layoutObject.height ?? 0.0))
        iOSVideoPlayer?.view.frame = cellFrame
        self.addSubview((iOSVideoPlayer?.view)!)
        containerViewController.addChildViewController(self.iOSVideoPlayer!)
        iOSVideoPlayer?.view.changeFrameXAxis(xAxis: (iOSVideoPlayer?.view.frame.minX ?? 0) * Utility.getBaseScreenWidthMultiplier())
        iOSVideoPlayer?.view.changeFrameYAxis(yAxis: (iOSVideoPlayer?.view.frame.minY ?? 0) * Utility.getBaseScreenHeightMultiplier())
        iOSVideoPlayer?.view.changeFrameWidth(width: (iOSVideoPlayer?.view.frame.width ?? 0) * Utility.getBaseScreenWidthMultiplier())
        iOSVideoPlayer?.view.changeFrameHeight(height: (iOSVideoPlayer?.view.frame.height ?? 0) * Utility.getBaseScreenHeightMultiplier())

//        }
    }
    
    
    private func createStarView(starObject:SFStarRatingObject, containerView:UIView) {
        
        let starView:SFStarRatingView = SFStarRatingView()
        starView.starRatingObject = starObject
        starView.relativeViewFrame = containerView.frame

        starView.initialiseStarRatingFrameFromLayout(ratingLayout: Utility.fetchStarRatingLayoutDetails(starRatingObject: starObject))

        starView.changeFrameXAxis(xAxis: starView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        starView.changeFrameYAxis(yAxis: starView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        starView.changeFrameWidth(width: starView.frame.width * Utility.getBaseScreenWidthMultiplier())
        starView.changeFrameHeight(height: starView.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        if self.film != nil && self.film.viewerGrade != nil
        {
            if Int(self.film.viewerGrade!) > 0 {
                starView.updateView(userRating: self.film.viewerGrade!)
            }
        }
        else if self.show != nil && self.show.viewerGrade != nil
        {
            if Int(self.show.viewerGrade!) > 0 {
                starView.updateView(userRating: self.show.viewerGrade!)
            }
        }
        starView.isUserInteractionEnabled = true
        let starTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.starTapGestureRecongniser(tapGesture:)))
        starView.addGestureRecognizer(starTapGesture)
        
        containerView.addSubview(starView)
    }
    
    private func createCastView(castObject:SFCastViewObject, containerView:UIView) {
        
        let castView:SFCastView = SFCastView()
        castView.castViewObject = castObject
        castView.relativeViewFrame = containerView.frame
        castView.initialiseCastViewFrameFromLayout(castViewLayout: Utility.fetchCastViewLayoutDetails(castViewObject: castObject))
        containerView.addSubview(castView)
        castView.updateView()
        
        castView.changeFrameXAxis(xAxis: castView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        castView.changeFrameYAxis(yAxis: castView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        castView.changeFrameWidth(width: castView.frame.width * Utility.getBaseScreenWidthMultiplier())
        castView.changeFrameHeight(height: castView.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        if self.film != nil
        {
            castView.createSegregatedCastViewWithCastSet_iOS(self.film.credits)
        }
        else if self.show != nil
        {
            castView.createSegregatedCastViewWithCastSet_iOS(self.show.credits)
        }
    }

    
    private func createProgressView(progressViewObject:SFProgressViewObject, containerView:UIView) {
        
        let progressView = SFProgressView(progressViewStyle: .bar)
        
        progressView.relativeViewFrame = containerView.frame
        progressView.progressViewObject = progressViewObject
        progressView.progressTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? progressViewObject.progressColor ?? "000000")
        progressView.trackTintColor = Utility.hexStringToUIColor(hex: progressViewObject.unprogressColor ?? "ffffff").withAlphaComponent(0.59)
        progressView.initialiseProgressViewFrameFromLayout(progressViewLayout: Utility.fetchProgresViewLayoutDetails(progressViewObject: progressViewObject))
        
        UIView.animate(withDuration: 0.5, animations: {
            progressView.setProgress(Float(self.film.filmWatchedDuration ?? 0) / Float(self.film.durationSeconds ?? 0), animated: true)
        })
        
        containerView.addSubview(progressView)
        containerView.bringSubview(toFront: progressView)
        
        progressView.changeFrameXAxis(xAxis: progressView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        progressView.changeFrameYAxis(yAxis: progressView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        progressView.changeFrameWidth(width: progressView.frame.width * Utility.getBaseScreenWidthMultiplier())
        progressView.changeFrameHeight(height: progressView.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        if film.filmWatchedDuration == nil || film.filmWatchedDuration == 0 {
            
            progressView.isHidden = true
        }
    }
    
    private func createSeparatorView(separatorViewObject:SFSeparatorViewObject, containerView:UIView) {
        
        let separatorView:SFSeparatorView = SFSeparatorView(frame: CGRect.zero)
        separatorView.separtorViewObject = separatorViewObject
        separatorView.relativeViewFrame = containerView.frame
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject))
        containerView.addSubview(separatorView)
        containerView.bringSubview(toFront: separatorView)
        
        separatorView.changeFrameXAxis(xAxis: separatorView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        separatorView.changeFrameYAxis(yAxis: separatorView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        separatorView.changeFrameWidth(width: separatorView.frame.width * Utility.getBaseScreenWidthMultiplier())
        separatorView.changeFrameHeight(height: separatorView.frame.height * Utility.getBaseScreenHeightMultiplier())
    }
    
    
    func createGridView(trayObject: SFTrayObject, containerView: UIView) {
        
        let collectionGridViewController: SFSeasonGridViewController = SFSeasonGridViewController(trayObject: trayObject)
        collectionGridViewController.show = self.show
        self.seasonGridTrayObject = trayObject
        
        var rowHeight:CGFloat = CGFloat(Utility.sharedUtility.calculateCellHeightFromCellComponents(trayObject: trayObject, noOfData: Float((show?.seasons?[selectedSeason ?? 0].episodes!.count) ?? 1)))
        
        rowHeight *= Utility.getBaseScreenHeightMultiplier()
        let cellFrame:CGRect = CGRect(x: 0, y: 200, width: UIScreen.main.bounds.width, height: 70 * Utility.getBaseScreenHeightMultiplier())
        let collectionGridFrame = Utility.initialiseViewLayout(viewLayout: Utility.fetchTrayLayoutDetails(trayObject: trayObject), relativeViewFrame: cellFrame)
        
        var trailerURLMargin:CGFloat = 0
        
        if self.show.trailerURL == nil && Constants.IPHONE{
            
            trailerURLMargin = 60 * Utility.getBaseScreenHeightMultiplier()
        }
        
        collectionGridViewController.view.frame = CGRect(x: collectionGridFrame.origin.x, y: (collectionGridFrame.origin.y - trailerURLMargin) * Utility.getBaseScreenHeightMultiplier(), width: collectionGridFrame.size.width, height: rowHeight)
        collectionGridViewController.relativeViewFrame = collectionGridViewController.view.frame
        collectionGridViewController.delegate = self
        collectionGridViewController.selectedSeason = selectedSeason
        collectionGridViewController.createSubViews()
        collectionGridViewController.view.tag = 1000
        containerViewController.addChildViewController(collectionGridViewController)
        containerView.addSubview(collectionGridViewController.view)
        containerView.bringSubview(toFront: containerViewController.view)
    }
    
    func updateGridView(gridView: UIView, containerView: UIView) {
        
        if gridView.tag == 1000 && self.seasonGridTrayObject != nil {
            
            let cellFrame:CGRect = CGRect(x: 0, y: 200, width: UIScreen.main.bounds.width, height: 70 * Utility.getBaseScreenHeightMultiplier())
            let collectionGridFrame = Utility.initialiseViewLayout(viewLayout: Utility.fetchTrayLayoutDetails(trayObject: self.seasonGridTrayObject!), relativeViewFrame: cellFrame)
            var rowHeight:CGFloat = CGFloat(Utility.sharedUtility.calculateCellHeightFromCellComponents(trayObject: self.seasonGridTrayObject!, noOfData: Float((show?.seasons?[selectedSeason ?? 0].episodes!.count) ?? 1)))
            rowHeight *= Utility.getBaseScreenHeightMultiplier()
            gridView.changeFrameYAxis(yAxis: collectionGridFrame.origin.y * Utility.getBaseScreenHeightMultiplier())
            gridView.changeFrameHeight(height: rowHeight)
        }
    }
    

    //MARK: Update Video Description Subviews 
    func updateLabelViewFrame(label:SFLabel, containerView:UIView) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!)
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.changeFrameXAxis(xAxis: label.frame.minX * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameYAxis(yAxis: label.frame.minY * Utility.getBaseScreenHeightMultiplier())
        label.changeFrameWidth(width: label.frame.width * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameHeight(height: label.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        var description: String = ""
        if self.film != nil
        {
            if self.film.desc != nil {
                
                description = self.film.desc!
            }
        }
        else if self.show != nil
        {
            if self.show.desc != nil {
                
                description = self.show.desc!
            }
        }
        
        if label.labelObject?.key == videoDescriptionString
        {
            label.text = description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            //SVFA-1511
            let isReadMoreOptionAdded:Bool = label.addTrailing(with: "... ", moreText: "More", moreTextFont: label.font, moreTextColor: Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "ffffff"))
            
            if label.gestureRecognizers != nil && isReadMoreOptionAdded == false {
                
                label.gestureRecognizers?.removeAll()
            }
            
            if isReadMoreOptionAdded == true && (label.gestureRecognizers == nil || label.gestureRecognizers?.count == 0) {
                
                let moreTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.moreTapGestureRecongniser(tapGesture:)))
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(moreTapGesture)
            }
        }
    }
    
    func updateButtonViewFrame(button:SFButton, containerView:UIView) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: button.buttonObject!)
        
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        
        button.changeFrameXAxis(xAxis: button.frame.minX * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameYAxis(yAxis: button.frame.minY * Utility.getBaseScreenHeightMultiplier())
        button.changeFrameWidth(width: button.frame.width * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameHeight(height: button.frame.height * Utility.getBaseScreenHeightMultiplier())

        if button.buttonObject?.key == downloadButtonString && (AppConfiguration.sharedAppConfiguration.isDownloadEnabled ?? false) {
            self.roundProgressView?.frame = button.frame
            containerView.bringSubview(toFront: self.roundProgressView!)
        }
    }
    
    func updateTextViewFrame(textView:SFTextView, containerView:UIView) -> Void {
        
        let textViewLayout = Utility.fetchTextViewLayoutDetails(textViewObject: textView.textViewObject!)
        textView.relativeViewFrame = containerView.frame
        textView.initialiseTextViewFrameFromLayout(textViewLayout: textViewLayout)
        textView.textViewLayout = textViewLayout
        
        textView.changeFrameXAxis(xAxis: textView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        textView.changeFrameYAxis(yAxis: textView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        textView.changeFrameWidth(width: textView.frame.width * Utility.getBaseScreenWidthMultiplier())
        textView.changeFrameHeight(height: textView.frame.height * Utility.getBaseScreenHeightMultiplier())
    }
    
    func updateImageViewFrame(imageView:SFImageView, containerView:UIView) {
        
        imageView.relativeViewFrame = containerView.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageView.imageViewObject!))
        
        imageView.changeFrameYAxis(yAxis: imageView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        imageView.changeFrameWidth(width: imageView.frame.width * Utility.getBaseScreenWidthMultiplier())
        imageView.changeFrameHeight(height: imageView.frame.height * Utility.getBaseScreenHeightMultiplier())
    }
    
    func updateVideoPlayerFrame(videoPlayerUIModule:VideoUIObject, containerView:UIView) {
        let layoutObject: LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: videoPlayerUIModule.layoutObjectDict)
        let cellFrame:CGRect = CGRect.init(x: CGFloat(layoutObject.xAxis ?? 0.0), y: CGFloat(layoutObject.yAxis ?? 0.0), width: CGFloat(layoutObject.width ?? 0.0), height: CGFloat(layoutObject.height ?? 0.0))
        iOSVideoPlayer?.view.frame = cellFrame
        iOSVideoPlayer?.view.changeFrameXAxis(xAxis: (iOSVideoPlayer?.view.frame.minX ?? 0) * Utility.getBaseScreenWidthMultiplier())
        iOSVideoPlayer?.view.changeFrameYAxis(yAxis: (iOSVideoPlayer?.view.frame.minY ?? 0) * Utility.getBaseScreenHeightMultiplier())
        iOSVideoPlayer?.view.changeFrameWidth(width: (iOSVideoPlayer?.view.frame.width ?? 0) * Utility.getBaseScreenWidthMultiplier())
        iOSVideoPlayer?.view.changeFrameHeight(height: (iOSVideoPlayer?.view.frame.height ?? 0) * Utility.getBaseScreenHeightMultiplier())
    }
    
    func updateStarViewFrame(starView:SFStarRatingView, containerView:UIView) {
        
        starView.relativeViewFrame = containerView.frame
        starView.initialiseStarRatingFrameFromLayout(ratingLayout: Utility.fetchStarRatingLayoutDetails(starRatingObject: starView.starRatingObject!))
        
        starView.changeFrameXAxis(xAxis: starView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        starView.changeFrameYAxis(yAxis: starView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        starView.changeFrameWidth(width: starView.frame.width * Utility.getBaseScreenWidthMultiplier())
        starView.changeFrameHeight(height: starView.frame.height * Utility.getBaseScreenHeightMultiplier())
    }
    
    func updateCastViewFrame(castView:SFCastView, containerView:UIView) {
        
        castView.relativeViewFrame = containerView.frame
        castView.initialiseCastViewFrameFromLayout(castViewLayout: Utility.fetchCastViewLayoutDetails(castViewObject: castView.castViewObject!))
        
        castView.changeFrameXAxis(xAxis: castView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        castView.changeFrameYAxis(yAxis: castView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        castView.changeFrameWidth(width: castView.frame.width * Utility.getBaseScreenWidthMultiplier())
        castView.changeFrameHeight(height: castView.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        if self.film != nil
        {
            castView.createSegregatedCastViewWithCastSet_iOS(self.film.credits)
        }
        else if self.show != nil
        {
            castView.createSegregatedCastViewWithCastSet_iOS(self.show.credits)
        }
    }

    
    func updateProgressView(progressView:SFProgressView, containerView:UIView) {
        
        progressView.relativeViewFrame = containerView.frame
        let progressViewLayout:LayoutObject = Utility.fetchProgresViewLayoutDetails(progressViewObject: progressView.progressViewObject!)
        progressView.initialiseProgressViewFrameFromLayout(progressViewLayout: progressViewLayout)
        
        progressView.changeFrameWidth(width: progressView.frame.size.width * Utility.getBaseScreenWidthMultiplier())
        progressView.changeFrameYAxis(yAxis: ceil(progressView.frame.origin.y * Utility.getBaseScreenHeightMultiplier()))
    }
    
    private func updateSeparatorView(separatorView:SFSeparatorView, containerView:UIView) {
        
        separatorView.relativeViewFrame = containerView.frame
        let separatorViewLayout = Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorView.separtorViewObject!)
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: separatorViewLayout)
        
        separatorView.changeFrameXAxis(xAxis: separatorView.frame.minX * Utility.getBaseScreenWidthMultiplier())
        separatorView.changeFrameYAxis(yAxis: separatorView.frame.minY * Utility.getBaseScreenHeightMultiplier())
        separatorView.changeFrameWidth(width: separatorView.frame.width * Utility.getBaseScreenWidthMultiplier())
        separatorView.changeFrameHeight(height: separatorView.frame.height * Utility.getBaseScreenHeightMultiplier())
    }
    
    //MARK: Button Delegate Events
    func buttonClicked(button: SFButton) {
        if (self.videoPlaybackDelegate != nil) && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.buttonTapped(button:filmObject:showObject:))))!
        {
            self.videoPlaybackDelegate?.buttonTapped(button: button, filmObject: film, showObject: show)
        }
    }
    
    
    //MARK: Method to update player progress
    func updatePlayerProgress(notification:Notification) {
        
        if self.film != nil {
            
            guard let userInfoDict:Dictionary<String, Any> = notification.userInfo as? Dictionary<String, Any> else { return }
            guard let notificationFilmId:String = userInfoDict["filmId"] as? String else { return }
            guard let playerProgressDuration:Double = userInfoDict["playerProgress"] as? Double else { return }
            
            if notificationFilmId == self.film.id {
                
                film.filmWatchedDuration = playerProgressDuration
                updatePlayerProgressView()
            }
        }
    }
    
    
    //MARK: Update player progress view
    func updatePlayerProgressView() {
        
        for component: AnyObject in self.subviews {
            
            if component is SFProgressView {
                
                let progressView = component as! SFProgressView
                
                UIView.animate(withDuration: 0.5, animations: {
                    progressView.setProgress(Float(self.film.filmWatchedDuration ?? 0) / Float(self.film.durationSeconds ?? 0), animated: true)
                })
                progressView.isHidden = false
                return
            }
        }
    }

    // MARK: - DownloadManager Delegate
    func updateDownloadProgress(for thisObject: DownloadObject, withProgress progress: Float) {
        if (thisObject.fileID == film.id) {
            self.roundProgressView?.setTheProgressForItemForDownloadProgress(DownloadManager.sharedInstance.getFilmObject(for: thisObject))
        }
    }

    func downloadFinished(for thisObject: DownloadObject) {
        manageStateOfProgressViews(with: thisObject)
    }

    func downloadStateUpdate(for thisObject: DownloadObject) {
        manageStateOfProgressViews(with: thisObject)
    }

    func downloadFailed(for thisObject: DownloadObject) {
        manageStateOfProgressViews(with: thisObject)
    }

    func manageStateOfProgressViews(with thisObject: DownloadObject) {
        if (thisObject.fileID == film.id) {
            self.roundProgressView?.setTheProgressForItemForDownloadProgress(DownloadManager.sharedInstance.getFilmObject(for: thisObject))
        }
    }
    
    
    //MARK: - Season Grid View controller Delegates
    func didPlayVideo(contentId: String?, filmObject: SFFilm?, nextEpisodesArray: Array<String>?) {
        
        if (self.videoPlaybackDelegate != nil) && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.playSelectedEpisode(filmObject:nextEpisodesArray:))))!
        {
            self.videoPlaybackDelegate?.playSelectedEpisode!(filmObject: filmObject, nextEpisodesArray: nextEpisodesArray)
        }
    }
    
    
    func didSeasonSelectorButtonClicked(dropDownButton: SFDropDownButton?) {
        
        if self.videoPlaybackDelegate != nil && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.didSeasonSelectorButtonClicked(dropDownButton:))))! {
            
            self.videoPlaybackDelegate?.didSeasonSelectorButtonClicked!(dropDownButton: dropDownButton)
        }
    }
    
    //MARK: - Video Player Delegate
    func videoPlayerStartedPlaying() {
       
    }
    
    func videoPLayerFinishedVideo() {
        if self.videoPlaybackDelegate != nil && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.videoPlayerFinishedPlayingMedia(videoPlayer:))))! {
            self.videoPlaybackDelegate?.videoPlayerFinishedPlayingMedia!(videoPlayer: self.iOSVideoPlayer)
        }
    }
    
    func fullScreenVideoPlayer() {
        if self.videoPlaybackDelegate != nil && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.videoPlayerFullScreenTapped(videoPlayer:isFullScreenButtonTapped:))))! {
            self.videoPlaybackDelegate?.videoPlayerFullScreenTapped!(videoPlayer: self.iOSVideoPlayer, isFullScreenButtonTapped:true)
        }
    }
    
    func exitFullScreenVideoPlayer() {
        if self.videoPlaybackDelegate != nil && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.videoPlayerExitFullScreenTapped(videoPlayer:))))! {
            self.videoPlaybackDelegate?.videoPlayerExitFullScreenTapped!(videoPlayer: self.iOSVideoPlayer)
        }
    }
    
    func reAttachSmallVideoPlayer()
    {
//        self.iOSVideoPlayer?.view.transform = CGAffineTransform.init(rotationAngle: 0)
        
        if iOSVideoPlayer != nil{
            iOSVideoPlayer?.view.removeFromSuperview()
//            iOSVideoPlayer?.removeFromParentViewController()
        }
//        self.iOSVideoPlayer?.view.removeFromSuperview()
        self.iOSVideoPlayer?.setPlayerFit(videoPlayerFit: .smallScreen)
        self.addSubview((iOSVideoPlayer?.view)!)
//        containerViewController.addChildViewController(iOSVideoPlayer!)
        for component:AnyObject in (self.videoDescriptionModule.videoDetailModuleComponents)!
        {
            let videoUIObject: VideoUIObject = VideoUIObject()
            
            if component is SFImageObject {
                videoUIObject.layoutObjectDict = (component as! SFImageObject).layoutObjectDict
                videoUIObject.type = (component as! SFImageObject).type
                videoUIObject.key = (component as! SFImageObject).key
                
                updateVideoPlayerFrame(videoPlayerUIModule: videoUIObject, containerView: self)
            }
            else if component is VideoObject {
                videoUIObject.layoutObjectDict = (component as! VideoUIObject).layoutObjectDict
                videoUIObject.type = (component as! VideoUIObject).type
                videoUIObject.key = (component as! VideoUIObject).key
                
                updateVideoPlayerFrame(videoPlayerUIModule: videoUIObject, containerView: self)
            }
        }
        if Constants.kAPPDELEGATE.window?.rootViewController is UITabBarController {
            let controller = Constants.kAPPDELEGATE.window?.rootViewController as! UITabBarController
            controller.tabBar.isHidden = false
        }
        self.iOSVideoPlayer?.playMedia()
    }
    
    override func layoutSubviews() {
        
//        if self.videoDescriptionModule != nil && self.videoDescriptionModule.isInlineVideoPlayer && Constants.IPHONE {
//
//            if iOSVideoPlayer != nil {
//
//                if UIScreen.main.bounds.sizewidth > UIScreen.main.bounds.size.height {
//                if self.videoPlaybackDelegate != nil && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.videoPlayerFullScreenTapped(videoPlayer:))))! {
//                    self.videoPlaybackDelegate?.videoPlayerFullScreenTapped!(videoPlayer: self.iOSVideoPlayer)
//                }
//                }
//            }
//        }
    }
}
