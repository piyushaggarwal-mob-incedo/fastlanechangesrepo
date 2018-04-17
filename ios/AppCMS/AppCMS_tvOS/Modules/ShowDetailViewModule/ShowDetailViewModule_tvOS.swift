

import UIKit

let showTitleLabelString = "showTitle"
let showSubTitleLabelString = "showSubTitle"
let showDescriptionString = "showDescriptionText"

@objc protocol ShowPlaybackDelegate: NSObjectProtocol {
    
    @objc func buttonTapped(button: SFButton, showObject: SFShow, filmObject:SFFilm, nextEpisodesArray: Array<String>?) -> Void
    @objc func playSelectedEpisode(showObject: SFShow, filmObject:SFFilm, nextEpisodesArray: Array<String>?) -> Void
    @objc func moreButtonTapped(showObject: SFShow) -> Void
    @objc optional func updateBackgroundView(isFocused: Bool,show: SFShow) -> Void

}

class ShowDetailViewModule_tvOS: UIViewController, SFButtonDelegate, SFSeasonGridDelegate {

    weak var showPlaybackDelegate: ShowPlaybackDelegate?
    
    /// Progress Indicator instance.
    private var progressIndicator:UIActivityIndicatorView?
    
    /// Video description module object.
    var showDescriptionModule: SFShowDetailModuleObject!
    
    /// SFFilm object whose details need to be populated.
    var show: SFShow!
    
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
    
    init(frame: CGRect, showDescriptionModule: SFShowDetailModuleObject, show: SFShow) {
        super.init(nibName: nil, bundle: nil)
        self.view.frame = frame
        self.showDescriptionModule = showDescriptionModule
        self.show = show
        createView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchVideoStatus()
        NotificationCenter.default.addObserver(self, selector:#selector(ShowDetailViewModule_tvOS.updateVideoWatchlistStatusAfterNetworkResumption), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    
    /// Creates the view for video detail.
    func createView() -> Void {
        if self.showDescriptionModule.showDetailModuleComponents != nil
        {
            createVideoViewComponents(containerView: self.view, itemIndex: 0)
        }
        //Hack: Added to call the preferredFocusView.
        invoke(selector: #selector(ShowDetailViewModule_tvOS.updateView), on:self, afterDelay:0.1)
    }
    
    private func invoke( selector:Selector, on target:AnyObject, afterDelay delay:TimeInterval ) {
        
        Timer.scheduledTimer( timeInterval: delay, target: target, selector: selector, userInfo: nil, repeats: false )
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
                
                DataManger.sharedInstance.getVideoStatus(videoId: self.show.showId, success: { [weak self] (videoStatusResponseDict, isSuccess) in
                    self?.hideActivityIndicator()
                    DispatchQueue.main.async {
                        
                        if videoStatusResponseDict != nil && isSuccess {
                            
                            if videoStatusResponseDict?["isQueued"] != nil {
                                self?.show.isQueued = videoStatusResponseDict?["isQueued"] as? Bool
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
                    
                    button.isSelected = show.isQueued != nil ? show.isQueued! : false
                    break
                }
            }
        }
    }

    
    //MARK: Creation of View Components
    /// Call this method to create view layout.
    private func createVideoViewComponents(containerView: UIView, itemIndex:Int) {
        
        for component:AnyObject in (self.showDescriptionModule.showDetailModuleComponents)! {
            
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
            else if component is SFTrayObject {
                
                createGridView(trayObject: component as! SFTrayObject, containerView: containerView)
            }
        }
    }
    
    
    func createGridView(trayObject: SFTrayObject, containerView: UIView) {
        let seasonsArray =  self.show.seasons
        guard let seasonArray = seasonsArray else {
            return
        }
        for season in seasonArray{
            let collectionGridViewController: SFSeasonGridViewController_tvOS = SFSeasonGridViewController_tvOS(trayObject: trayObject)
            collectionGridViewController.show = self.show
            collectionGridViewController.currentSectionIndex = (seasonArray.index(of: season))!
            var collectionGridFrame = Utility.initialiseViewLayout(viewLayout: Utility.fetchTrayLayoutDetails(trayObject: trayObject), relativeViewFrame: containerView.frame)
            
            let originY = collectionGridFrame.origin.y + (CGFloat(collectionGridViewController.currentSectionIndex) * collectionGridFrame.size.height)
            // let originY = collectionGridFrame.origin.y + (CGFloat(i) * collectionGridFrame.size.height)
            // i = i+1
            collectionGridFrame.origin.y = originY
            
            collectionGridViewController.view.frame = collectionGridFrame
            
            collectionGridViewController.relativeViewFrame = collectionGridViewController.view.frame
            collectionGridViewController.delegate = self
            collectionGridViewController.createSubViews()
            collectionGridViewController.view.tag = 1000
            self.addChildViewController(collectionGridViewController)
            containerView.addSubview(collectionGridViewController.view)
        }
    }
        
    
    func createHeaderView(headerObject:SFHeaderViewObject, containerView:UIView) {
        
        let headerLayout = Utility.fetchHeaderLayoutDetails(headerObject: headerObject)
        
        let header:SFHeaderView = SFHeaderView(frame: CGRect.zero)
        header.headerViewObject = headerObject
        header.headerViewlayout = headerLayout
        header.relativeViewFrame = containerView.frame
        header.initialiseHeaderViewFrameFromLayout(headerViewlayout: headerLayout)
        header.updateViewWithShowObject(self.show)
        containerView.addSubview(header)
    }
    
    func createCastView(castObject:SFCastViewObject, containerView:UIView) {
        
        let castView:SFCastView_tvOS = SFCastView_tvOS()
        castView.castViewObject = castObject
        castView.relativeViewFrame = containerView.frame
        castView.initialiseCastViewFrameFromLayout(castViewLayout: Utility.fetchCastViewLayoutDetails(castViewObject: castObject))
        containerView.addSubview(castView)
        castView.updateView()
        castView.createSegregatedCastViewWithCastSet(self.show.credits)
    }
    
    func createLabelView(labelObject:SFLabelObject, containerView:UIView, type: String) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        
        label.createLabelView()
        if type ==  showTitleLabelString{
            label.text = self.show.showTitle
        }
        else if type == showSubTitleLabelString {
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff").withAlphaComponent(0.51)
            label.text = self.show.getShowInfoString()
        }
        else if type == showDescriptionString {
            label.numberOfLines = 0
            var textWithStrippingHTMLTags: String?
            guard var description = self.show.desc else {
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
                temporaryFocusTransferButton = UIButton()
                temporaryFocusTransferButton?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
                //self.view.addSubview(temporaryFocusTransferButton!)
            }
        }
        containerView.addSubview(label)
    }
    
    func moreTapGestureRecongniser(tapGesture: UITapGestureRecognizer) -> Void {
        if self.showPlaybackDelegate != nil && (self.showPlaybackDelegate?.responds(to: #selector(self.showPlaybackDelegate?.moreButtonTapped(showObject:))))! {
            self.showPlaybackDelegate?.moreButtonTapped(showObject: self.show)
        }
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if initalPageLoad == false {
            if let viewToBeFocused = view.viewWithTag(9889) {
                return [viewToBeFocused]
            } else {
                return super.preferredFocusEnvironments
            }
        } else {
            return super.preferredFocusEnvironments
        }
    }

    
    func createButtonView(buttonObject:SFButtonObject, containerView:UIView, itemIndex:Int, type: String) -> Void {
        
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
        }
        else if type == watchlistButtonString {
            button.isSelected = show.isQueued != nil ? show.isQueued! : false
        }
        else if type == trailerButtonString {
            if show.trailerURL == nil {
                button.isHidden = true
                //If button is hidden then provide one focus guide to transfer the focus.
                backgroundFocusGuide = UIFocusGuide()
                containerView.addLayoutGuide(backgroundFocusGuide!)
                backgroundFocusGuide?.leftAnchor.constraint(equalTo: button.leftAnchor).isActive = true
                backgroundFocusGuide?.topAnchor.constraint(equalTo: button.topAnchor).isActive = true
                backgroundFocusGuide?.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
                backgroundFocusGuide?.heightAnchor.constraint(equalTo: button.heightAnchor).isActive = true
                backgroundFocusGuide?.preferredFocusedView = self.view.viewWithTag(9889)
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
        textView.text = self.show.desc
        
        self.view.addSubview(textView)
    }
    
    func createImageView(imageObject:SFImageObject, containerView:UIView) {
        
        
        let imageView:SFImageView = SFImageView()
        imageView.imageViewObject = imageObject
        imageView.relativeViewFrame = containerView.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
        imageView.updateView()        
        
        var imagePathString: String?
        if imageObject.key == badgeImageKey {
            for image in self.show.images {
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
        }
        else{
            imagePathString = self.show.thumbnailImageURL
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
        }
        
        containerView.addSubview(imageView)

    }
    
    //MARK: Button Delegate Events
    func buttonClicked(button: SFButton) {
        
        if button.buttonObject?.action == "addToWatchlist" {
            
            if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                updateVideoWatchlistStatus(showObject: show)
            }
            else {
                
                promptUserForSignIn(showObject: show)
            }
        } else {
            let filmObject = show?.seasons?.first?.episodes![0]
            
            //As currently last Played Episode Id is not available
            let nextEpisodesArray:Array<String>? = self.fetchNextEpisodesToBeAutoPlayed(filmObject: filmObject!, seasonsArray: (show?.seasons)!, currentEpisodeIndex:0, seasonIndex: 0)
            
            if (self.showPlaybackDelegate != nil) && (self.showPlaybackDelegate?.responds(to: #selector(self.showPlaybackDelegate?.buttonTapped(button:showObject:filmObject:nextEpisodesArray:))))!
            {
                self.showPlaybackDelegate?.buttonTapped(button: button, showObject:show, filmObject: filmObject!, nextEpisodesArray:nextEpisodesArray ?? [])
            }
        }
    }
    func playSelectedEpisode(showObject:SFShow, filmObject: SFFilm, nextEpisodesArray: Array<String>?){
        if (self.showPlaybackDelegate != nil) && (self.showPlaybackDelegate?.responds(to: #selector(self.showPlaybackDelegate?.playSelectedEpisode(showObject:filmObject:nextEpisodesArray:))))!
        {
            self.showPlaybackDelegate?.playSelectedEpisode(showObject:show, filmObject: filmObject, nextEpisodesArray:nextEpisodesArray ?? [])
        }
    }
    
    
    private func videoImageGotFocusedCallback(_isFocused: Bool) {
        if self.showPlaybackDelegate != nil && (self.showPlaybackDelegate?.responds(to: #selector(self.showPlaybackDelegate?.updateBackgroundView(isFocused:show:))))! {
            self.showPlaybackDelegate?.updateBackgroundView!(isFocused: _isFocused, show: show)
        }
    }
    
    private func fetchNextEpisodesToBeAutoPlayed(filmObject:SFFilm, seasonsArray:Array<SFSeason>, currentEpisodeIndex:Int, seasonIndex:Int) -> Array<String>?{
        
        var nextEpisodeArray:Array<String>?
        var currentEpisodeIndexValue = currentEpisodeIndex + 1
        
        for seasonNumber in seasonIndex ..< seasonsArray.count {
            
            if seasonNumber != seasonIndex {
                
                currentEpisodeIndexValue = 0
            }
            
            let episodesArray = seasonsArray[seasonNumber].episodes
            
            if episodesArray != nil {
                
                if currentEpisodeIndexValue < (episodesArray?.count)! {
                    
                    for episodeNumber in currentEpisodeIndexValue ..< (episodesArray?.count)! {
                        
                        if nextEpisodeArray == nil {
                            
                            nextEpisodeArray = []
                        }
                        
                        let nextEpisode:SFFilm = episodesArray![episodeNumber]
                        
                        if nextEpisode.id != nil {
                            
                            nextEpisodeArray?.append(nextEpisode.id!)
                        }
                    }
                }
            }
        }
        
        return nextEpisodeArray
    }
    
    
    
    
    private func promptUserForSignIn(showObject: SFShow) {
        
        let signInAction:UIAlertAction = UIAlertAction(title: Constants.kStrSign, style: .default) { (signInAction) in
            
            Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView({ () in
                self.updateVideoWatchlistStatus(showObject: showObject)
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
            updateVideoWatchlistStatus(showObject: show)
        }
    }
    //MARK: Method to add/remove video from Watchlist
    private func updateVideoWatchlistStatus(showObject:SFShow) {
        
        if show.isQueued != nil && show.isQueued! == true{
            
            //Remove video from watchlist
            removeVideoFromQueue(showObject: showObject)
        }
        else {
            
            //Add video to watchlist
            addVideoToQueue(showObject: showObject)
        }
    }
    
    
    //MARK: Method to remove video from watchlist
    private func removeVideoFromQueue(showObject:SFShow) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshRemoveFromWatchlist
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, showObject: showObject, errorMessage: nil, errorTitle: nil)
        }
        else {
            //Hardcoding the API for now
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")&contentIds=\(showObject.showId!)"
            showActivityIndicator()
            
            DataManger.sharedInstance.removeVideosFromQueue(apiEndPoint: apiEndPoint) { [weak self] (isVideoRemoved) in
                
                self?.hideActivityIndicator()
                
                if isVideoRemoved == true {
                    
                    self?.show.isQueued = false
                    self?.updateButtonWatchlistStatus()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:"isWatchlistUpdated"), object: nil)
                }
                else {
                    
                    self?.show.isQueued = true
                    self?.updateButtonWatchlistStatus()
                    self?.failureAlertType = .RefreshRemoveFromWatchlist
                    self?.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, showObject: showObject, errorMessage: "Unable to remove video from watchlist.", errorTitle: "Watchlist")
                }
            }
        }
    }
    
    
    //MARK: Method to add video to watchlist
    private func addVideoToQueue(showObject:SFShow) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshRemoveFromWatchlist
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, showObject: showObject, errorMessage: nil, errorTitle: nil)
        }
        else {
            
            let watchlistPayload:Dictionary<String, Any> = ["userId": Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", "contentId":showObject.showId!, "position":1, "contentType":showObject.type ?? "video"]
            
            let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
            
            showActivityIndicator()
            DataManger.sharedInstance.addVideoToQueue(apiEndPoint: apiRequest, requestParameters: watchlistPayload, success: { [weak self] (isVideoAdded) in
                
                self?.hideActivityIndicator()
                
                if isVideoAdded != nil {
                    
                    if isVideoAdded! == true {
                        
                        self?.show.isQueued = true
                        self?.updateButtonWatchlistStatus()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"isWatchlistUpdated"), object: nil)
                    }
                    else {
                        self?.show.isQueued = false
                        self?.updateButtonWatchlistStatus()
                        
                        self?.failureAlertType = .RefreshAddToWatchlist
                        self?.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, showObject: showObject, errorMessage: "Unable to add video to watchlist.", errorTitle: "Watchlist")
                    }
                }
                else {
                    self?.show.isQueued = false
                    self?.updateButtonWatchlistStatus()
                    
                    self?.failureAlertType = .RefreshAddToWatchlist
                    self?.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, showObject: showObject, errorMessage: "Unable to add video to watchlist.", errorTitle: "Watchlist")
                }
            })
        }
    }
        
    //MARK: Helper Methods.
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        videoImageGotFocusedCallback(_isFocused: true)

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
    
   
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if(presses.first?.type == UIPressType.playPause) {
            if UIScreen.main.focusedView?.tag == 9889 && UIScreen.main.focusedView is SFButton {
                let playButton = self.view.viewWithTag(9889)
                let filmObject = show?.seasons?.first?.episodes![0]
                
                //As we currently there is only 1 season
                let nextEpisodesArray:Array<String>? = self.fetchNextEpisodesToBeAutoPlayed(filmObject: filmObject!, seasonsArray: (show?.seasons)!, currentEpisodeIndex:0, seasonIndex: 0)
                
                if (self.showPlaybackDelegate != nil) && (self.showPlaybackDelegate?.responds(to: #selector(self.showPlaybackDelegate?.buttonTapped(button:showObject:filmObject:nextEpisodesArray:))))!
                {
                    self.showPlaybackDelegate?.buttonTapped(button: playButton as! SFButton, showObject:show, filmObject: filmObject!, nextEpisodesArray:nextEpisodesArray!)
                }
            }
        }
        super.pressesBegan(presses, with: event)
    }
    
    //MARK:Display Error in removing from watchlist
    func showWatchlistAlertForAlertType(alertType: AlertType, showObject:SFShow?, errorMessage:String?, errorTitle:String?) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                self.updateVideoWatchlistStatus(showObject: showObject!)
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
