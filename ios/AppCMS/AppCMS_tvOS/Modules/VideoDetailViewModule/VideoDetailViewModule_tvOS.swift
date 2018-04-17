//
//  VideoDetailViewModule_tvOS.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 10/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

let titleLabelString = "videoTitle"
let subTitleLabelString = "videoSubTitle"
let ageRatingLabelString = "ageLabel"
let closeButtonString = "closeButton"
let downloadButtonString = "downloadButton"
let shareButtonString = "shareButton"
let playButtonString = "playButton"
let watchlistButtonString = "watchlistButton"
let trailerButtonString = "watchTrailer"
let videoDescriptionString = "videoDescriptionText"
let badgeImageKey = "badgeImage"
let videoImageKey = "videoImage"

@objc protocol VideoPlaybackDelegate: NSObjectProtocol {
    
    @objc func buttonTapped(button: SFButton, filmObject:SFFilm) -> Void
    @objc func moreButtonTapped(filmObject: SFFilm) -> Void
    @objc optional func videoImageDidUpdateFocus(isFocused: Bool, film: SFFilm) -> Void
}

class VideoDetailViewModule_tvOS: UIViewController, SFButtonDelegate {

    weak var videoPlaybackDelegate: VideoPlaybackDelegate?
    
    /// Progress Indicator instance.
    private var progressIndicator:UIActivityIndicatorView?
    
    /// Video description module object.
    var videoDescriptionModule: SFVideoDetailModuleObject!
    
    /// SFFilm object whose details need to be populated.
    var film: SFFilm!
    
    var gridObject: SFGridObject?
    
    /// Shows the state that the page has loaded for the first time.
    var initalPageLoad : Bool = false
    
    /// Button used to transfer focus initially when there is no focusable item on this module.
    var temporaryFocusTransferButton : UIButton?
    
    /// Background focus guide. Added to transfer focus from bottom module to this module and vice-versa.
    var backgroundFocusGuide : UIFocusGuide?
    
    /// Failure Alert type.
    var failureAlertType:PageLoadAfterFailureAlert?
    
    /// network unavailable alert instance.
    var networkUnavailableAlert:UIAlertController?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, videoDescriptionModule: SFVideoDetailModuleObject, film: SFFilm) {
        
        self.videoDescriptionModule = videoDescriptionModule
        self.film = film
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchVideoStatus()
        NotificationCenter.default.addObserver(self, selector:#selector(VideoDetailViewModule_tvOS.updateVideoWatchlistStatusAfterNetworkResumption), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    
    /// Creates the view for video detail.
    func createView() -> Void {
        if self.videoDescriptionModule.videoDetailModuleComponents != nil
        {
            createVideoViewComponents(containerView: self.view, itemIndex: 0)
            
        }
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports{
            temporaryFocusTransferButton = UIButton()
            temporaryFocusTransferButton?.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            self.view.addSubview(temporaryFocusTransferButton!)
        }

        //Hack: Added to call the preferredFocusView.
        disableButtons()
        invoke(selector: #selector(VideoDetailViewModule_tvOS.enableButtons), on: self, afterDelay: 1)
        invoke(selector: #selector(VideoDetailViewModule_tvOS.updateView), on:self, afterDelay:0.1)
    }
    
    private func invoke( selector:Selector, on target:AnyObject, afterDelay delay:TimeInterval ) {
        
        Timer.scheduledTimer( timeInterval: delay, target: target, selector: selector, userInfo: nil, repeats: false )
    }
    
    private func disableButtons() {
        
        for component: AnyObject in self.view.subviews {
            
            if component is SFButton {
                
                let button = component as! SFButton
                if button.buttonObject?.key != playButtonString {
                    button.isUserInteractionEnabled = false
                    button.isEnabled = false
                }
            }
        }
    }
    
    @objc private func enableButtons() {
        
        for component: AnyObject in self.view.subviews {
            
            if component is SFButton {
                
                let button = component as! SFButton
                button.isUserInteractionEnabled = true
                button.isEnabled = true
            }
        }
    }
    
    func updateView() {
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
        initalPageLoad = true
    }
    
    func fetchVideoStatus() {
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            showActivityIndicator()
            DispatchQueue.global(qos: .userInitiated).async {
                
                DataManger.sharedInstance.getVideoStatus(videoId: self.film.id, success: { [weak self] (videoStatusResponseDict, isSuccess) in
                    self?.hideActivityIndicator()
                    DispatchQueue.main.async {
                        
                        if videoStatusResponseDict != nil && isSuccess {
                            
                            if videoStatusResponseDict?["isQueued"] != nil {
                                self?.film.isQueued = videoStatusResponseDict?["isQueued"] as? Bool
                            }
                            
                            if videoStatusResponseDict?["watchedTime"] != nil {
                                self?.film.filmWatchedDuration = (videoStatusResponseDict?["watchedTime"] as! Double)
                            }
                            self?.updateButtonWatchlistStatus()
                        }
                    }
                })
            }
        }
    }
    
    func updateButtonWatchlistStatus() {
        
        for component: AnyObject in self.view.subviews {
            
            if component is SFButton {
                
                let button = component as! SFButton
                
                if button.buttonObject?.key == watchlistButtonString {
                    
                    button.isSelected = film.isQueued != nil ? film.isQueued! : false
                    break
                }
            }
        }
        
        for component: AnyObject in self.view.subviews {
            
            if component is SFButton {
                
                let button = component as! SFButton
                
                if button.buttonObject?.key == playButtonString {
                    
                    let watchedDuration = Utility.getWatchedDurationForVideo(watchedDuration: film.filmWatchedDuration ?? 0.0, totalDurarion: Double(film.durationSeconds ?? 0))
                    button.isSelected = watchedDuration == 0.0 ? false : true
                    break
                }
            }
        }
    }

    
    //MARK: Creation of View Components
    /// Call this method to create view layout.
    private func createVideoViewComponents(containerView: UIView, itemIndex:Int) {
        
        for component:AnyObject in (self.videoDescriptionModule.videoDetailModuleComponents)! {
            
            if component is SFButtonObject {
                
                let buttonObject:SFButtonObject = component as! SFButtonObject
                createButtonView(buttonObject: buttonObject, containerView: self.view, itemIndex: itemIndex, type: component.key!!)
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
            else if component is SFCastViewObject {
                createCastView(castObject: component as! SFCastViewObject, containerView: containerView)
            }
            else if component is SFHeaderViewObject {
                createHeaderView(headerObject: component as! SFHeaderViewObject, containerView: containerView)
            }
        }
    }
    
    func createHeaderView(headerObject:SFHeaderViewObject, containerView:UIView) {
        
        let headerLayout = Utility.fetchHeaderLayoutDetails(headerObject: headerObject)
        
        let header:SFHeaderView = SFHeaderView(frame: CGRect.zero)
        header.headerViewObject = headerObject
        header.headerViewlayout = headerLayout
        header.relativeViewFrame = containerView.frame
        header.initialiseHeaderViewFrameFromLayout(headerViewlayout: headerLayout)
        header.updateViewWithFilmObject(self.film)
        containerView.addSubview(header)
    }
    
    func createCastView(castObject:SFCastViewObject, containerView:UIView) {
        
        let castView:SFCastView_tvOS = SFCastView_tvOS()
        castView.castViewObject = castObject
        castView.relativeViewFrame = containerView.frame
        castView.initialiseCastViewFrameFromLayout(castViewLayout: Utility.fetchCastViewLayoutDetails(castViewObject: castObject))
        containerView.addSubview(castView)
        castView.updateView()
        castView.createSegregatedCastViewWithCastSet(self.film.credits)
    }
    
    func createLabelView(labelObject:SFLabelObject, containerView:UIView, type: String) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        
        label.createLabelView()
        if type ==  titleLabelString{
            label.text = self.film.title
        }
        else if type == subTitleLabelString {
            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
                if let totalTime = gridObject?.totalTime {
                    var dateString: String?
                    if let publishDate: Double = gridObject?.publishedDate {
                        dateString = Utility.sharedUtility.getDateStringFromIntervalWithPunctuationMark(timeInterval: publishDate)
                        label.text = "\(totalTime.timeFormattedString(interval: totalTime)) | \(dateString!)"
                    } else {
                        label.text = "\(totalTime.timeFormattedString(interval: totalTime))"
                    }
                }
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
            } else {
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff").withAlphaComponent(0.51)
                label.text = self.film.getVideoInfoString()
            }
        }
        else if type == videoDescriptionString {
            label.numberOfLines = 0
            var textWithStrippingHTMLTags: String?
            guard var description = self.film.desc else {
                return
            }
            
            textWithStrippingHTMLTags = description.stringByStrippingHTMLTags()
            label.text = textWithStrippingHTMLTags
            
            let moreButtonFont = UIFont(name: "\(label.font.familyName.replacingOccurrences(of: " " , with: ""))-Bold", size: label.font.pointSize)!
            
            let isReadMoreOptionAdded:Bool = label.addTrailing(with: "... ", moreText: "MORE", moreTextFont: moreButtonFont, moreTextColor: Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"))
            
            if isReadMoreOptionAdded == true {
                let moreTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.moreTapGestureRecongniser(tapGesture:)))
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(moreTapGesture)
                label.shouldGetFocused = true
                label.tag = 8888
            } else {
                if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment{
                    temporaryFocusTransferButton = UIButton()
                    temporaryFocusTransferButton?.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
                    self.view.addSubview(temporaryFocusTransferButton!)
                }
            }
            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
                label.sizeToFit()
            }
        }
        containerView.addSubview(label)
    }
    
    
    func moreTapGestureRecongniser(tapGesture: UITapGestureRecognizer) -> Void {
        if self.videoPlaybackDelegate != nil && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.moreButtonTapped(filmObject:))))! {
            self.videoPlaybackDelegate?.moreButtonTapped(filmObject: self.film)
        }
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if initalPageLoad == false {
            temporaryFocusTransferButton?.removeFromSuperview()
            if let viewToBeFocused = view.viewWithTag(9889) {
                return [viewToBeFocused]
            } else {
                return super.preferredFocusEnvironments
            }
        } else {
            return super.preferredFocusEnvironments
        }
    }
    
    override var preferredFocusedView: UIView? {
        get {
            if initalPageLoad == false {
                temporaryFocusTransferButton?.removeFromSuperview()
                return self.view.viewWithTag(9889)
            } else {
                return nil
            }
        }
    }
    
    func createButtonView(buttonObject:SFButtonObject, containerView:UIView, itemIndex:Int, type: String) -> Void {
        
//        button.setTitle(buttonObject.selectedStateText ?? "RESUME WATCHING", for: UIControlState.selected)
        if buttonObject.selectedStateText == nil && type == playButtonString{
            buttonObject.selectedStateText = "RESUME WATCHING"
        }
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        
        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.buttonLayout = buttonLayout
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.buttonDelegate = self
        button.tag = itemIndex
        button.createButtonView()
        containerView.addSubview(button)
        
        if type == playButtonString {
            
            button.tag = 9889
            backgroundFocusGuide = UIFocusGuide()
            containerView.addLayoutGuide(backgroundFocusGuide!)
            backgroundFocusGuide?.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            backgroundFocusGuide?.topAnchor.constraint(equalTo: button.topAnchor).isActive = true
            backgroundFocusGuide?.rightAnchor.constraint(equalTo: button.rightAnchor).isActive = true
            backgroundFocusGuide?.heightAnchor.constraint(equalTo: button.heightAnchor).isActive = true
            backgroundFocusGuide?.preferredFocusedView = button
            
            if buttonObject.imageName != nil {
                button.buttonShowsAnImage = true
                //button.setImage(UIImage(named: buttonObject.imageName ?? "videoDetailPlayIcon_tvOS"), for: UIControlState.normal)
                button.imageView?.image = UIImage(named: "videoDetailPlayIcon_tvOS")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                if let textColor = AppConfiguration.sharedAppConfiguration.primaryButton.backgroundColor {
                    button.imageView?.tintColor = Utility.hexStringToUIColor(hex: textColor)
                }
                button.contentMode = .scaleAspectFit
                button.alpha = 0.81
            }
            button.isUserInteractionEnabled = true
        }

        else if type == watchlistButtonString {
            button.isUserInteractionEnabled = false
            button.isEnabled = false
            button.isSelected = film.isQueued != nil ? film.isQueued! : false
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
        }
        else if type == trailerButtonString {
            button.isUserInteractionEnabled = false
            button.isEnabled = false
            if film.trailerURL == nil {
                button.isHidden = true
                //If button is hidden then provide one focus guide to transfer the focus.
                if film.trailerURL == nil {
                    backgroundFocusGuide = UIFocusGuide()
                    containerView.addLayoutGuide(backgroundFocusGuide!)
                    backgroundFocusGuide?.leftAnchor.constraint(equalTo: button.leftAnchor).isActive = true
                    backgroundFocusGuide?.topAnchor.constraint(equalTo: button.topAnchor).isActive = true
                    backgroundFocusGuide?.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
                    backgroundFocusGuide?.heightAnchor.constraint(equalTo: button.heightAnchor).isActive = true
                    backgroundFocusGuide?.preferredFocusedView = self.view.viewWithTag(9889)
                }
            }
        }
        
        button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!, size: (button.titleLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())

        containerView.bringSubview(toFront: button)
    }
    
    func createTextView(textViewObject:SFTextViewObject, containerView:UIView, itemIndex:Int) -> Void {
        
        let textViewLayout = Utility.fetchTextViewLayoutDetails(textViewObject: textViewObject)
        let textView:SFTextView = SFTextView()
        textView.relativeViewFrame = self.view.frame
        textView.initialiseTextViewFrameFromLayout(textViewLayout: textViewLayout)
        textView.textViewLayout = textViewLayout
        textView.textViewObject = textViewObject
        textView.updateView()
        textView.text = self.film.desc
        
        self.view.addSubview(textView)
    }
    
    func createImageView(imageObject:SFImageObject, containerView:UIView) {
        let imageView:SFImageView = SFImageView()
        imageView.imageViewObject = imageObject
        imageView.relativeViewFrame = containerView.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
        imageView.updateView()
        //imageView.adjustsImageWhenAncestorFocused = true
        
        var imagePathString: String?
        if imageObject.key == badgeImageKey {
            for image in self.film.images {
                let imageObj: SFImage = image as! SFImage
                if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO
                {
                    imagePathString = imageObj.badgeImageUrl
                    break
                }
            }
            if imagePathString != nil
            {
                imagePathString = imagePathString?.appending("?impolicy=resize&w=\(imageView.frame.size.width)&h=\(imageView.frame.size.height)")
                imagePathString = imagePathString?.trimmingCharacters(in: .whitespaces)
                
                if imagePathString != nil
                {
                    imagePathString = imagePathString?.appending("?impolicy=resize&w=\(imageView.frame.size.width)&h=\(imageView.frame.size.height)")
                    imagePathString = imagePathString?.trimmingCharacters(in: .whitespaces)
                    
                    imagePathString = imagePathString?.trimmingCharacters(in: NSCharacterSet.whitespaces)
                    
                    imageView.isHidden = false
                    
                    imageView.af_setImage(
                        withURL: URL(string:imagePathString!)!,
                        placeholderImage: nil,
                        filter: nil,
                        imageTransition: .crossDissolve(0.2)
                    )
                }
                else {
                    
                    imageView.isHidden = true
                }
            }
            else {
                
                imageView.isHidden = true
            }
            
//            imageView.image = UIImage(named: "badgeLandscape")
//            imageView.isHidden = false
            imageView.tag = 888
        }
        else if imageObject.key == videoImageKey{
            for image in self.film.images {
                let imageObj: SFImage = image as! SFImage
                if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO
                {
                    imagePathString = imageObj.imageSource
                    break
                }
            }
            if imagePathString != nil
            {
                imagePathString = imagePathString?.appending("?impolicy=resize&w=\(imageView.frame.size.width)&h=\(imageView.frame.size.height)")
                imagePathString = imagePathString?.trimmingCharacters(in: .whitespaces)
                
                imageView.af_setImage(
                    withURL: URL(string:imagePathString!)!,
                    placeholderImage: UIImage(named: Constants.kVideoImagePlaceholder),
                    filter: nil,
                    imageTransition: .crossDissolve(0.2)
                )
            }
            else
            {
                imageView.image = UIImage(named: Constants.kVideoImagePlaceholder)
            }
            imageView.tag = 999
        }
        else{
            if let imageName = imageObject.imageName{
                imageView.image = UIImage(named: imageName)
            }
            if imageObject.key == "logoImage"{
                imageView.contentMode = .scaleAspectFit
            }
            else if imageObject.key == "gradientImage"{
                imageView.contentMode = .scaleAspectFill
            }
        }

        containerView.addSubview(imageView)
    }
    
    //MARK: Button Delegate Events
    func buttonClicked(button: SFButton) {
        
        if button.buttonObject?.action == "addToWatchlist" {
            
            if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                updateVideoWatchlistStatus(filmObject: film)
            }
            else {
                
                promptUserForSignIn(film: film)
            }
        } else {
            if (self.videoPlaybackDelegate != nil) && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.buttonTapped(button:filmObject:))))!
            {
                self.videoPlaybackDelegate?.buttonTapped(button: button, filmObject: film)
            }
        }
    }
    
    private func promptUserForSignIn(film: SFFilm) {
        
        let signInAction:UIAlertAction = UIAlertAction(title: Constants.kStrSign, style: .default) { (signInAction) in
            
            Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView({ () in
                self.updateVideoWatchlistStatus(filmObject: film)
            })
        }
        
        let cancelAction:UIAlertAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
        }
        
        let userAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kStrAddToWatchlistAlertTitle, alertMessage: Constants.kStrAddToWatchlistAlertMessage, alertActions: [cancelAction, signInAction])
        
        self.present(userAlert, animated: true, completion: nil)
    }
    
    @objc private func updateVideoWatchlistStatusAfterNetworkResumption() {
        if NetworkStatus.sharedInstance.isNetworkAvailable() && networkUnavailableAlert != nil  && (networkUnavailableAlert?.isShowing())! {
            networkUnavailableAlert?.dismiss(animated: true, completion: nil)
            updateVideoWatchlistStatus(filmObject: film)
        }
    }
    
    //MARK: Method to add/remove video from Watchlist
    private func updateVideoWatchlistStatus(filmObject:SFFilm) {
        
        if film.isQueued != nil && film.isQueued! == true{
            
            //Remove video from watchlist
            removeVideoFromQueue(filmObject: filmObject)
        }
        else {
            
            //Add video to watchlist
            addVideoToQueue(filmObject: filmObject)
        }
    }
    
    
    //MARK: Method to remove video from watchlist
    private func removeVideoFromQueue(filmObject:SFFilm) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshRemoveFromWatchlist
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, filmObject: filmObject, errorMessage: nil, errorTitle: nil)
        }
        else {
            //Hardcoding the API for now
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")&contentIds=\(filmObject.id!)"
            showActivityIndicator()
            
            DataManger.sharedInstance.removeVideosFromQueue(apiEndPoint: apiEndPoint) { [weak self] (isVideoRemoved) in
                
                self?.hideActivityIndicator()
                
                if isVideoRemoved == true {
                    
                    self?.film.isQueued = false
                    self?.updateButtonWatchlistStatus()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:"isWatchlistUpdated"), object: nil)
                }
                else {
                    
                    self?.film.isQueued = true
                    self?.updateButtonWatchlistStatus()
                    self?.failureAlertType = .RefreshRemoveFromWatchlist
                    self?.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, filmObject: filmObject, errorMessage: "Unable to remove video from watchlist.", errorTitle: "Watchlist")
                }
            }
        }
    }
    
    
    //MARK: Method to add video to watchlist
    private func addVideoToQueue(filmObject:SFFilm) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshRemoveFromWatchlist
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, filmObject: filmObject, errorMessage: nil, errorTitle: nil)
        }
        else {
            
            let watchlistPayload:Dictionary<String, Any> = ["userId": Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", "contentId":filmObject.id!, "position":1, "contentType":filmObject.type ?? "video"]
            
            let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
            
            showActivityIndicator()
            DataManger.sharedInstance.addVideoToQueue(apiEndPoint: apiRequest, requestParameters: watchlistPayload, success: { [weak self] (isVideoAdded) in
                
                self?.hideActivityIndicator()
                
                if isVideoAdded != nil {
                    
                    if isVideoAdded! == true {
                        
                        self?.film.isQueued = true
                        self?.updateButtonWatchlistStatus()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"isWatchlistUpdated"), object: nil)
                    }
                    else {
                        self?.film.isQueued = false
                        self?.updateButtonWatchlistStatus()
                        
                        self?.failureAlertType = .RefreshAddToWatchlist
                        self?.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, filmObject: filmObject, errorMessage: "Unable to add video to watchlist.", errorTitle: "Watchlist")
                    }
                }
                else {
                    self?.film.isQueued = false
                    self?.updateButtonWatchlistStatus()
                    
                    self?.failureAlertType = .RefreshAddToWatchlist
                    self?.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, filmObject: filmObject, errorMessage: "Unable to add video to watchlist.", errorTitle: "Watchlist")
                }
            })
        }
    }
        
    //MARK: Helper Methods.
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment{
            DispatchQueue.main.async {
                self.videoImageGotFocusedCallback(_isFocused: true)
            }
        }
        
        //Next focus views handling.
        if context.nextFocusedView != nil && context.nextFocusedView is SFLabel {
            if context.nextFocusedView?.tag == 8888 {
                let label = context.nextFocusedView as! SFLabel
                label.updateSubTextColorOnFocus("MORE", Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "ffffff"))
            }
        }
        //Previous focus views handling.
        if context.previouslyFocusedView?.tag == 8888 &&  context.previouslyFocusedView is SFLabel{
            let label = context.previouslyFocusedView as! SFLabel
            label.updateSubTextColorOnFocus("MORE", Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"))
        }
        
    }
    
    private func videoImageGotFocusedCallback(_isFocused: Bool) {
        if self.videoPlaybackDelegate != nil && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.videoImageDidUpdateFocus(isFocused:film:))))! {
            self.videoPlaybackDelegate?.videoImageDidUpdateFocus!(isFocused: _isFocused, film: self.film)
        }
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if(presses.first?.type == UIPressType.playPause) {
            if UIScreen.main.focusedView?.tag == 9889 && UIScreen.main.focusedView is SFButton {
                let playButton = self.view.viewWithTag(9889)
                if (self.videoPlaybackDelegate != nil) && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.buttonTapped(button:filmObject:))))! {
                    self.videoPlaybackDelegate?.buttonTapped(button: playButton as! SFButton, filmObject: film)
                }
            }
        }
        super.pressesBegan(presses, with: event)
    }
    
    //MARK:Display Error in removing from watchlist
    func showWatchlistAlertForAlertType(alertType: AlertType, filmObject:SFFilm?, errorMessage:String?, errorTitle:String?) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                self.updateVideoWatchlistStatus(filmObject: filmObject!)
            }
        }
        
        var alertTitleString:String?
        var alertMessage:String?
        
        if alertType == .AlertTypeNoInternetFound {
            alertTitleString = Constants.kInternetConnection
            alertMessage = Constants.kInternetConntectionRefresh
        }
        else {
            alertTitleString = errorTitle
            alertMessage = errorMessage
        }
        
        if networkUnavailableAlert == nil {
            networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction, retryAction])
        }
        self.present(networkUnavailableAlert!, animated: true, completion: nil)
    }
    
    private func showActivityIndicator() {
        
        if progressIndicator == nil {
            progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        }
        if self.isShowing() {
            self.progressIndicator?.showIndicatorOnWindow()
        }
    }
    
    private func hideActivityIndicator() {
        progressIndicator?.removeFromSuperview()
    }
}
