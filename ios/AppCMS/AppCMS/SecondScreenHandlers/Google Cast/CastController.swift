

import UIKit
import GoogleCast
import AVFoundation
import Firebase


class CastController: NSObject, GCKDiscoveryManagerListener, GCKRemoteMediaClientListener,GCKSessionManagerListener {
    
    private var deviceConnected : GCKDevice!
    private var deviceDiscoveryManager : GCKDiscoveryManager!
    private var listOfCastDevices = Array<GCKDevice>()
    var timer = Timer()
//    var relatedDownloads = Array<SFFilm>()
    var relatedVideos:Array<Any> = []
    var isOpenFromDownloads: Bool = false
    var mediaContentUrl:String!
    var progressIndicator:MBProgressHUD?
    var mediaInfo: GCKMediaInformation!
    var bufferTimer : Timer?
    var lastPlayBackTime : Float = 0
    /// Property of having method type as the completionHandler closure.
    private
    var completionHandlerCopy : ((Array<GCKDevice>) -> Void)? = nil
    var isFilmProgressUpdateInSync: Bool = false
    var currentCastedMovieTitle: String?
    var currentCastedMovieID: String?
    var is25PercentUpdated: Bool = false, is50PercentUpdated: Bool = false, is75PercentUpdated: Bool = false, is100PercentUpdated: Bool = false

    var playBackStreamID:String? //variable holds StreamID value for current video
    var currentTimeStamp:Date? //variable holds current Time Stamp value
    var isFirstFrameSent : Bool = false //Used to check if beacon event for first frame has fired
    var isPlayBeaconSent : Bool = false //Used to check if beacon event for play has fired
    var currentTimeStampForBuffer : Date?//variable holds current Time Stamp For Buffering event so that it should be fired only after interval of 5 sec.
    
    
    func startCastDeviceScan(completionHandler : @escaping ((_ listOfCastDevices: Array<GCKDevice>) -> Void)) -> Void {
        completionHandlerCopy = completionHandler
        startScanning()
    }
    
    private func startScanning () {
        //Initialize the device scanner.
        
        let castOptions = GCKCastOptions(receiverApplicationID: kGCKMediaDefaultReceiverApplicationID)
        GCKCastContext.setSharedInstanceWith(castOptions)
        deviceDiscoveryManager = GCKCastContext.sharedInstance().discoveryManager
        deviceDiscoveryManager?.startDiscovery()
        deviceDiscoveryManager?.add(self as GCKDiscoveryManagerListener)
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
        GCKCastContext.sharedInstance().sessionManager.add(self as GCKSessionManagerListener)
    }
    
    func getNumberOfDevices() -> UInt {
        return (deviceDiscoveryManager?.deviceCount)!
    }
    
    
    
    func didStartDiscovery(forDeviceCategory deviceCategory: String) {
        print("")
    }
    
    func willUpdateDeviceList() {
        print("")
        completionHandlerCopy!(getDeviceList())
        
    }
    
    func didUpdateDeviceList() {
        completionHandlerCopy!(getDeviceList())
    }
    
    func getDeviceList() -> Array<GCKDevice>{
        listOfCastDevices.removeAll()
        var deviceCount : UInt = 0
        while deviceCount < (deviceDiscoveryManager?.deviceCount)! {
            let device = (deviceDiscoveryManager?.device(at: deviceCount))!
            if device.type != .nearbyUnpaired{
                listOfCastDevices.append(device)
            }
            deviceCount += 1
        }
        return listOfCastDevices
    }
    
    
    
    func isCastingVideo() -> Bool {
        
        let castSession = GCKCastContext.sharedInstance().sessionManager.currentCastSession
        if (castSession?.remoteMediaClient?.mediaStatus?.mediaInformation?.contentID != nil) && (castSession?.remoteMediaClient?.connected)!{
            return true
        }
        else{
            return false
        }
    }
    
    
    func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    
    // MARK:-
    /** func playSelectedItemRemotely will  fetch details for video to be played.
     Params:
     contentId: String (videoId)
     
     */
    func playSelectedItemRemotely(contentId: String, isDownloaded: Bool, relatedContentIds: Array<Any>?, contentTitle: String) {
        
        self.currentCastedMovieTitle = contentTitle
        self.currentCastedMovieID = contentId
        if let topController = topViewController() {
            self.showActivityIndicator(loaderText: "Loading", vc: topController)
        }
        self.isOpenFromDownloads = isDownloaded
        if relatedContentIds != nil{
            //self.relatedDownloads = relatedContentIds!
            self.relatedVideos = relatedContentIds!
        }
        if let currentCastedTitle = currentCastedMovieTitle{
            self.playBackStreamID = Utility.sharedUtility.generateStreamID(movieName:currentCastedTitle)
        }
        self.fetchVideoURLToBePlayed(contentId: contentId)
    }
    
    
    // MARK:-
    /** func fetchVideoURLToBePlayed - fetch details for video to be played.
     Params:
     contentId: String (videoId)
     
     */
    func fetchVideoURLToBePlayed(contentId: String) {
        
        DataManger.sharedInstance.fetchURLDetailsForVideo(apiEndPoint: "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/videos/\(contentId)?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&fields=streamingInfo,gist,contentDetails") { (videoURLWithStatusDict) in
            
            if videoURLWithStatusDict != nil {
                
                let filmURLs:Dictionary<String, AnyObject>? = videoURLWithStatusDict?["urls"] as? Dictionary<String, AnyObject>
                
                if filmURLs != nil {
                    
                    let subTitleDict:Dictionary<String, AnyObject>? = videoURLWithStatusDict?["subTitles"] as? Dictionary<String, AnyObject>
                    
                    var subTitleUrlStr:String?
                    
                    if subTitleDict != nil {
                        
                        subTitleUrlStr = self.parseSubTitles(subTitleDict: subTitleDict!)
                    }
                    
                    DataManger.sharedInstance.getVideoStatus(videoId: contentId, success: { (videoStatusResponseDict, isSuccess) in
                        var mediaStartTime: Double! = 0.0
                        DispatchQueue.main.async {
                            
                            if videoStatusResponseDict != nil && isSuccess {
                                
                                if videoStatusResponseDict?["watchedTime"] != nil {
                                    
                                    mediaStartTime = (videoStatusResponseDict?["watchedTime"] as! Double)
                                }
                            }
                            
                            let videoUrls:Dictionary<String, AnyObject>? = filmURLs?["videoUrl"] as? Dictionary<String, AnyObject>
                            
                            let rendentionUrls:Array<AnyObject>? = videoUrls?["renditionUrl"] as? Array<AnyObject>
                            var filmUrl:String!

                            if rendentionUrls != nil {
                                
                                if (rendentionUrls?.count)! > 0 {
                                    
                                    let renditionUrlDict:Dictionary<String, AnyObject>? = rendentionUrls?.first as? Dictionary<String, AnyObject>
                                    
                                    filmUrl = renditionUrlDict?["renditionUrl"] as? String
                                }
                            }
                            
                            if filmUrl != nil {
                                self.mediaContentUrl = filmUrl
                                let autoplayhandler = AutoPlayArrayHandler()
                                autoplayhandler.getTheAutoPlaybackArrayForFilm(film:contentId){ (relatedArray, filmObject) in
                                    if filmObject != nil {
                                        
                                        if filmObject?.durationSeconds != nil
                                        {
                                            CastPopOverView.shared.setVideoContent(contentId: filmObject?.id, filmTitle: filmObject?.title, durationSeconds: Double((filmObject?.durationSeconds!)!))
                                            mediaStartTime = Utility.sharedUtility.getWatchedDurationForVideo(watchedDuration: mediaStartTime, totalDurarion: Double((filmObject?.durationSeconds!)!))
                                        }
                                        else
                                        {
                                            mediaStartTime = 0.0
                                        }
                                        
                                        
                                        var mediaQueueArray = Array<Any>()
                                        
                                        let mediaInformation = self.buildMediaInformation(film: filmObject!, filmURL: filmUrl, subTitleUrlStr: subTitleUrlStr)
                                        
                                        let mediaQueueElement = GCKMediaQueueItem(mediaInformation:  mediaInformation, autoplay: true, startTime: mediaStartTime, playbackDuration: 0.0, preloadTime: 10.0, activeTrackIDs: nil, customData: nil)
                                        
                                        mediaQueueArray.append(mediaQueueElement)
                                        var relatedVideoArray = Array<Any>()
                                        
                                        if(self.isOpenFromDownloads){
                                            
                                            if (self.relatedVideos.count > 0) {
                                                
                                                for i in 0 ..< (self.relatedVideos.count) {
                                                    
                                                    let currentFilm:SFFilm? = self.relatedVideos[i] as? SFFilm
                                                    
                                                    if currentFilm != nil {
                                                        
                                                        let teamId:String = (currentFilm?.id)!
                                                        if(teamId as String != filmObject?.id)
                                                        {
                                                            relatedVideoArray.append(teamId)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        else{
                                            
                                            if self.relatedVideos.count > 0 {
                                                
                                                relatedVideoArray = self.relatedVideos
                                            }
                                            else {
                                                
                                                if relatedArray != nil {
                                                    
                                                    for i in 0 ..< (relatedArray?.count)!{
                                                        
                                                        let teamId:String? = relatedArray![i] as? String
                                                        
                                                        if teamId != nil {
                                                            
                                                            if(teamId! != filmObject?.id)
                                                            {
                                                                relatedVideoArray.append(teamId!)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if (relatedVideoArray.count > 0) {
                                            if((Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay)) != nil)
                                            {
                                                var mediaItemDict:Dictionary<String, GCKMediaQueueItem> = [:]
                                                for relatedFilmId in relatedVideoArray {
                                                    self.fetchRelatedVideoURLToBePlayed(contentId:relatedFilmId as! String){ (mediaQueueElement) in
                                                        if(mediaQueueElement != nil){
                                                            
                                                            mediaItemDict[relatedFilmId as! String] = mediaQueueElement!
                                                            
                                                            if mediaItemDict.count == relatedVideoArray.count {
                                                                
                                                                self.createCastAutoplayArray(mediaContentDict: mediaItemDict, relatedVideoArray: relatedVideoArray)
                                                            }
                                                            //GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient?.queueInsert(mediaQueueElement!, beforeItemWithID: kGCKMediaQueueInvalidItemID)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        self.hideActivityIndicator()
                                        self.switchToCastingMode(mediaQueueArray: mediaQueueArray)
                                    }
                                    else {
                                        
                                        self.hideActivityIndicator()
                                        self.switchToCastingMode(mediaQueueArray: nil)
                                    }
                                }
                            }
                        }
                        
                    })
                }
                else {
                    
                    self.hideActivityIndicator()
                }
            }
            else {
                
                self.hideActivityIndicator()
            }
        }
    }
    

    private func createCastAutoplayArray(mediaContentDict:Dictionary<String, GCKMediaQueueItem>, relatedVideoArray:Array<Any>) {
    
        for relatedVideoId in relatedVideoArray {
            
            if relatedVideoId is String {
                
                GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient?.queueInsert(mediaContentDict[relatedVideoId as! String]!, beforeItemWithID: kGCKMediaQueueInvalidItemID)
            }
        }
    }
    
    
    func fetchRelatedVideoURLToBePlayed(contentId: String, responseForConfiguration : @escaping ( _ mediaData :GCKMediaQueueItem?) -> Void)
    {
        DataManger.sharedInstance.fetchURLDetailsForVideo(apiEndPoint: "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/videos/\(contentId)?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&fields=streamingInfo,gist,contentDetails") { (videoURLWithStatusDict) in
            
            if videoURLWithStatusDict != nil {
                
                let filmURLs:Dictionary<String, AnyObject>? = videoURLWithStatusDict?["urls"] as? Dictionary<String, AnyObject>
                
                if filmURLs != nil {
                    
                    let subTitleDict:Dictionary<String, AnyObject>? = videoURLWithStatusDict?["subTitles"] as? Dictionary<String, AnyObject>
                    
                    var subTitleUrlStr:String?
                    
                    if subTitleDict != nil {
                        
                        subTitleUrlStr = self.parseSubTitles(subTitleDict: subTitleDict!)
                    }
                    
                    DataManger.sharedInstance.getVideoStatus(videoId: contentId, success: { (videoStatusResponseDict, isSuccess) in
                        var mediaStartTime: Double! = 0
                        DispatchQueue.main.async {
                            
                            if videoStatusResponseDict != nil && isSuccess {
                                
                                if videoStatusResponseDict?["watchedTime"] != nil {
                                    
                                    mediaStartTime = (videoStatusResponseDict?["watchedTime"] as! Double)
                                    
                                }
                            }
                            
                            let videoUrls:Dictionary<String, AnyObject>? = filmURLs?["videoUrl"] as? Dictionary<String, AnyObject>
                            let rendentionUrls:Array<AnyObject>? = videoUrls?["renditionUrl"] as? Array<AnyObject>
                            var filmUrl:String!
                            if rendentionUrls != nil {
                                
                                if (rendentionUrls?.count)! > 0 {
                                    
                                    let renditionUrlDict:Dictionary<String, AnyObject>? = rendentionUrls?.first as? Dictionary<String, AnyObject>
                                    
                                    filmUrl = renditionUrlDict?["renditionUrl"] as? String
                                }
                            }
                            
                            if filmUrl != nil {
                                let autoplayhandler = AutoPlayArrayHandler()
                                autoplayhandler.getTheAutoPlaybackArrayForFilm(film:contentId){ (relatedArray, filmObject) in
                                    
                                    if filmObject !=  nil {
                                        if filmObject?.durationSeconds != nil
                                        {
                                            mediaStartTime = Utility.sharedUtility.getWatchedDurationForVideo(watchedDuration: mediaStartTime, totalDurarion: Double((filmObject?.durationSeconds!)!))
                                        }
                                        else
                                        {
                                            mediaStartTime = 0.0
                                        }
                                        
                                        let mediaInformation = self.buildMediaInformation(film: filmObject!, filmURL: filmUrl, subTitleUrlStr: subTitleUrlStr)
                                        
                                        let mediaQueueElement = GCKMediaQueueItem(mediaInformation:  mediaInformation, autoplay: true, startTime: mediaStartTime, playbackDuration: 0.0, preloadTime: 10.0, activeTrackIDs: nil, customData: nil)
                                        
                                        responseForConfiguration(mediaQueueElement)
                                    }
                                    else{
                                        responseForConfiguration(nil)
                                    }
                                }
                            }
                        }
                    })
                }
                else {
                    
                    self.hideActivityIndicator()
                }
            }
            else {
                
                self.hideActivityIndicator()
            }
        }
    }
    
    
    //MARK: Method to parse subtitle from api response
    func parseSubTitles(subTitleDict:Dictionary<String, AnyObject>) -> String? {
        
        var subTitleUrlStr:String?
        
        let subTitleArray:Array<Dictionary<String, AnyObject>?>? = subTitleDict["closedCaptions"] as? Array<Dictionary<String, AnyObject>>
        
        if subTitleArray != nil {
            
            for subTitleObject in subTitleArray! {
                
                let subTitleFormat:String? = subTitleObject?["format"] as? String
                
                if subTitleFormat != nil {
                    
                    if subTitleFormat?.lowercased() == "vtt" {
                        
                        subTitleUrlStr = subTitleObject?["url"] as? String ?? ""
                        break
                    }
                }
            }
        }
        
        return subTitleUrlStr
    }
    
    
    /** func buildMediaInformation set GCKMediaMetadata to cast.
     
     */
    func buildMediaInformation(film: SFFilm, filmURL: String, subTitleUrlStr:String?) -> GCKMediaInformation {
        let metaData = GCKMediaMetadata(metadataType: GCKMediaMetadataType.generic)
        metaData.setString(film.title!, forKey: kGCKMetadataKeyTitle)
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        metaData.setString(appName!, forKey: kGCKMetadataKeySubtitle)
        
        var mediaTracksArray:Array<GCKMediaTrack>?
        
        if subTitleUrlStr != nil {
            
            let captionsTrack:GCKMediaTrack = GCKMediaTrack.init(identifier: 1, contentIdentifier: subTitleUrlStr!, contentType: "text/vtt", type: .text, textSubtype: .captions, name: "English Captions", languageCode: "en", customData: nil)
            
            if mediaTracksArray == nil {
                
                mediaTracksArray = []
            }
            
            mediaTracksArray?.append(captionsTrack)
        }
        
        var imagePathString = ""
        for image in film.images {
            let imageObj: SFImage = image as! SFImage
            if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO
            {
                imagePathString = imageObj.imageSource ?? ""
            }
        }
        
        if !imagePathString.isEmpty {
            
            let url:URL? = URL(string:imagePathString)
            
            if url != nil {
                
                metaData.addImage(GCKImage(url: url!, width: 480, height: 360))
            }
        }
        
        let ContentID = film.id
        let mediaInformation  = GCKMediaInformation(contentID: filmURL,
                                                    streamType: GCKMediaStreamType.none,
                                                    contentType:"video/mp4",
                                                    metadata: metaData as GCKMediaMetadata,
                                                    streamDuration: 0,
                                                    mediaTracks: mediaTracksArray,
                                                    textTrackStyle: nil,
                                                    customData: ContentID)
        
        return mediaInformation
    }
    
    
    /** func switchToCastingMode will display cast expanded view
     */
    func switchToCastingMode(mediaQueueArray: Array<Any>?) {
        let castSession = GCKCastContext.sharedInstance().sessionManager.currentCastSession
        
        if mediaQueueArray != nil && castSession?.remoteMediaClient?.mediaStatus?.mediaInformation?.contentID != self.mediaContentUrl {
            castSession?.remoteMediaClient?.queueLoad(mediaQueueArray as! [GCKMediaQueueItem], start: 0, repeatMode: GCKMediaRepeatMode.off)
        }
        castSession?.remoteMediaClient?.add(self as GCKRemoteMediaClientListener)
        castSession?.remoteMediaClient?.notifyDidUpdateMetadata()
        castSession?.remoteMediaClient?.notifyDidUpdateMediaStatus()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateCastProgress)), userInfo: nil, repeats: true)
        GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()
    }
    
    
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        guard let mediaStatus = mediaStatus else { return }
        let elapsedTime : Float
        let castSession = GCKCastContext.sharedInstance().sessionManager.currentCastSession
        if castSession == nil{
            timer.invalidate()
        }
        elapsedTime = Float((castSession?.remoteMediaClient?.approximateStreamPosition())!)
        if(!isPlayBeaconSent)
        {
            currentTimeStamp = Date()
            var beaconDict : Dictionary<String,String> = [:]
            beaconDict[Constants.kBeaconVidKey] = self.currentCastedMovieID
            beaconDict[Constants.kBeaconUrlKey]=BeaconEvent.generateURL(movieName: self.currentCastedMovieTitle ?? "")
            beaconDict[Constants.kBeaconRefKey]=Constants.kBeaconViewingFilmPage
            beaconDict[Constants.kBeaconPaKey]=Constants.kBeaconEventTypePlay
            beaconDict[Constants.kBeaconVposKey]=String(elapsedTime)
            beaconDict[Constants.kBeaconAposKey]=String(elapsedTime)
            beaconDict[Constants.kBeaconTstampoverrideKey]=BeaconEvent.getCurrentTimeStamp()
            beaconDict[Constants.kBeaconStream_idKey]=self.playBackStreamID
            beaconDict[Constants.kBeaconPlayerKey]=Constants.kBeaconEventChromecast
            beaconDict[Constants.kBeaconMedia_typeKey]=Constants.kBeaconEventMediaTypeVideo
            beaconDict[Constants.kBeaconDp2Key]=Utility.sharedUtility.getDp2ParameterForBeaconEvent(fileName: self.currentCastedMovieID ?? "")
            let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
            DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
            isPlayBeaconSent = true
        }
        switch mediaStatus.playerState {
        case .playing:
            if(isFirstFrameSent == false)
            {
                isFirstFrameSent = true
                let elapsed = Date().timeIntervalSince(currentTimeStamp!)
                let duration = Float(elapsed)
                var beaconDict : Dictionary<String,String> = [:]
                beaconDict[Constants.kBeaconVidKey] = self.currentCastedMovieID
                beaconDict[Constants.kBeaconUrlKey]=BeaconEvent.generateURL(movieName: self.currentCastedMovieTitle ?? "")
                beaconDict[Constants.kBeaconRefKey]=Constants.kBeaconViewingFilmPage
                beaconDict[Constants.kBeaconPaKey]=Constants.kBeaconEventFirstFrame
                beaconDict[Constants.kBeaconVposKey]=String(elapsedTime)
                beaconDict[Constants.kBeaconAposKey]=String(elapsedTime)
                beaconDict[Constants.kBeaconTstampoverrideKey]=BeaconEvent.getCurrentTimeStamp()
                beaconDict[Constants.kBeaconStream_idKey]=self.playBackStreamID
                beaconDict[Constants.kBeaconTtfirstframeKey]=String(duration)
                beaconDict[Constants.kBeaconPlayerKey]=Constants.kBeaconEventChromecast
                beaconDict[Constants.kBeaconMedia_typeKey]=Constants.kBeaconEventMediaTypeVideo
                beaconDict[Constants.kBeaconDp2Key]=Utility.sharedUtility.getDp2ParameterForBeaconEvent(fileName: self.currentCastedMovieID ?? "")
                let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
                DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
            }
            
        case .buffering:
            if(Constants.buffercount < 5){
                Constants.buffercount = Constants.buffercount + 1
                return
            }
            var beaconDict : Dictionary<String,String> = [:]
            beaconDict[Constants.kBeaconVidKey] = self.currentCastedMovieID
            beaconDict[Constants.kBeaconUrlKey]=BeaconEvent.generateURL(movieName: self.currentCastedMovieTitle ?? "")
            beaconDict[Constants.kBeaconRefKey]=Constants.kBeaconViewingFilmPage
            beaconDict[Constants.kBeaconPaKey]=Constants.kBeaconEventBuffering
            beaconDict[Constants.kBeaconVposKey]=String(elapsedTime)
            beaconDict[Constants.kBeaconAposKey]=String(elapsedTime)
            beaconDict[Constants.kBeaconTstampoverrideKey]=BeaconEvent.getCurrentTimeStamp()
            beaconDict[Constants.kBeaconStream_idKey]=self.playBackStreamID
            beaconDict[Constants.kBeaconPlayerKey]=Constants.kBeaconEventChromecast
            beaconDict[Constants.kBeaconMedia_typeKey]=Constants.kBeaconEventMediaTypeVideo
            beaconDict[Constants.kBeaconDp2Key]=Utility.sharedUtility.getDp2ParameterForBeaconEvent(fileName: self.currentCastedMovieID ?? "")
            let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
            DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)
             Constants.buffercount = 0
            break;
        default:
            break
        }
        
    }
    
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaMetadata: GCKMediaMetadata?){
        
        //Reseting the progress update boolean flag
        is75PercentUpdated = false
        is50PercentUpdated = false
        is25PercentUpdated = false
        is100PercentUpdated = false
        
        self.mediaInfo = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient?.mediaStatus?.mediaInformation
        if (self.mediaInfo != nil) && ((self.mediaInfo.customData) is String){
            if let currentContentId = self.mediaInfo.customData  as? String{
                CastPopOverView.shared.setVideoContent(contentId: currentContentId, filmTitle: self.mediaInfo.metadata?.string(forKey: kGCKMetadataKeyTitle), durationSeconds: self.mediaInfo.streamDuration)
                if(self.currentCastedMovieID != currentContentId)
                {
                    
                    self.currentCastedMovieTitle = self.mediaInfo.metadata?.string(forKey: kGCKMetadataKeyTitle)
                    self.currentCastedMovieID = currentContentId
                    if let currentCastedTitle = currentCastedMovieTitle
                    {
                        self.playBackStreamID = Utility.sharedUtility.generateStreamID(movieName:currentCastedTitle)
                    }
                    isFirstFrameSent = false
                    isPlayBeaconSent=false
                }
            }
        }
    }
    
    
    public func remoteMediaClient(_ client: GCKRemoteMediaClient, didStartMediaSessionWithID sessionID: Int)
    {
        if client.connected
        {
            if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
            {
                FIRAnalytics.logEvent(withName: Constants.kGTMStreamStartEvent, parameters: [Constants.kGTMVideoIDAttribute : self.currentCastedMovieID ?? "", Constants.kGTMVideoNameAttribute: currentCastedMovieTitle ?? "", Constants.kGTMSeriesIDAttribute: "", Constants.kGTMSeriesNameAttribute:"", Constants.kGTMVideoPlayerTypeAttribute : Constants.kGTMSecondScreenPlayer, Constants.kGTMVideoMediaTypeAttribute: Constants.kGTMVideoContent])
            }
        }
    }
    
    
    //MARK - Show/Hide Activity Indicator
    func showActivityIndicator(loaderText:String?, vc:UIViewController) {
        
        progressIndicator = MBProgressHUD.showAdded(to: vc.view, animated: true)
        if loaderText != nil {
            
            progressIndicator?.label.text = loaderText!
        }
    }
    
    
    func hideActivityIndicator() {
        
        progressIndicator?.hide(animated: true)
    }
    
    //MARK: Fire BeaconEvents and update player progress Api to server
    func updateCastProgress() {
        
        let castSession = GCKCastContext.sharedInstance().sessionManager.currentCastSession
        if castSession == nil{
            timer.invalidate()
        }
        else if UIApplication.shared.applicationState == .active {
            if self.isCastingVideo(){
                let elapsedTime: Float64 = (castSession?.remoteMediaClient?.approximateStreamPosition())!
                let duration: Float64 = (castSession?.remoteMediaClient?.mediaStatus?.mediaInformation?.streamDuration)!
                if elapsedTime > 0 && castSession?.remoteMediaClient?.mediaStatus?.playerState == GCKMediaPlayerState.playing {
                    
                    let currentDuration:Int = Int(elapsedTime)
                    
                    if currentDuration % 30 == 0 && currentDuration > 0 {
                        
                        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                            
                            updatePlayerProgressToServerAfterThirySeconds(currentTime: Double(currentDuration))
                        }
                        
                        fireBeaconEventAfterThirtySeconds(currentTime: Float(currentDuration))
                    }
                    if duration.isNaN || duration.isInfinite{
                        return
                    }
                    let film25percentValue: Int = Int(duration * 0.25)
                    let film50percentValue: Int = Int(duration * 0.50)
                    let film75percentValue: Int = Int(duration * 0.75)
                    let film100percentValue: Int = Int(duration)
                    
                    if currentDuration >= film25percentValue && currentDuration > 0
                    {
                        if is25PercentUpdated != true && Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                        {
                            is25PercentUpdated = true
                            FIRAnalytics.logEvent(withName: Constants.kGTMStream25PercentEvent, parameters: [Constants.kGTMVideoIDAttribute : self.currentCastedMovieID ?? "", Constants.kGTMVideoNameAttribute: self.currentCastedMovieTitle ?? "", Constants.kGTMSeriesIDAttribute: "", Constants.kGTMSeriesNameAttribute:"", Constants.kGTMVideoPlayerTypeAttribute : Constants.kGTMSecondScreenPlayer, Constants.kGTMVideoMediaTypeAttribute: Constants.kGTMVideoContent])
                        }
                    }
                    if currentDuration >= film50percentValue && currentDuration > 0
                    {
                        if is50PercentUpdated != true && Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                        {
                            is50PercentUpdated = true
                            FIRAnalytics.logEvent(withName: Constants.kGTMStream50PercentEvent, parameters: [Constants.kGTMVideoIDAttribute : self.currentCastedMovieID ?? "", Constants.kGTMVideoNameAttribute: currentCastedMovieTitle ?? "", Constants.kGTMSeriesIDAttribute: "", Constants.kGTMSeriesNameAttribute:"", Constants.kGTMVideoPlayerTypeAttribute : Constants.kGTMSecondScreenPlayer, Constants.kGTMVideoMediaTypeAttribute: Constants.kGTMVideoContent])
                        }
                    }
                    if currentDuration >= film75percentValue && currentDuration > 0
                    {
                        if is75PercentUpdated != true && Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                        {
                            is75PercentUpdated = true
                            FIRAnalytics.logEvent(withName: Constants.kGTMStream75PercentEvent, parameters: [Constants.kGTMVideoIDAttribute : self.currentCastedMovieID ?? "", Constants.kGTMVideoNameAttribute: currentCastedMovieTitle ?? "", Constants.kGTMSeriesIDAttribute: "", Constants.kGTMSeriesNameAttribute:"", Constants.kGTMVideoPlayerTypeAttribute : Constants.kGTMSecondScreenPlayer, Constants.kGTMVideoMediaTypeAttribute: Constants.kGTMVideoContent])
                        }
                    }
                    if currentDuration == film100percentValue && currentDuration > 0
                    {
                        if is100PercentUpdated != true && Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                        {
                            is100PercentUpdated = true
                            FIRAnalytics.logEvent(withName: Constants.kGTMStream100PercentEvent, parameters: [Constants.kGTMVideoIDAttribute : self.currentCastedMovieID ?? "", Constants.kGTMVideoNameAttribute: currentCastedMovieTitle ?? "", Constants.kGTMSeriesIDAttribute: "", Constants.kGTMSeriesNameAttribute:"", Constants.kGTMVideoPlayerTypeAttribute : Constants.kGTMSecondScreenPlayer, Constants.kGTMVideoMediaTypeAttribute: Constants.kGTMVideoContent])
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Fire BeaconEvents
    func fireBeaconEventAfterThirtySeconds(currentTime:Float) {
        
        //Ping Beacon event
        if(self.lastPlayBackTime == currentTime){return}
        lastPlayBackTime=currentTime
        var beaconDict : Dictionary<String,String> = [:]
        beaconDict[Constants.kBeaconVidKey] = self.currentCastedMovieID
        beaconDict[Constants.kBeaconUrlKey]=BeaconEvent.generateURL(movieName: self.currentCastedMovieTitle ?? "")
        beaconDict[Constants.kBeaconRefKey]=Constants.kBeaconViewingFilmPage
        beaconDict[Constants.kBeaconPaKey]=Constants.kBeaconEventTypePing
        beaconDict[Constants.kBeaconVposKey]=String(currentTime)
        beaconDict[Constants.kBeaconAposKey]=String(currentTime)
        beaconDict[Constants.kBeaconTstampoverrideKey]=BeaconEvent.getCurrentTimeStamp()
        beaconDict[Constants.kBeaconStream_idKey]=self.playBackStreamID
        beaconDict[Constants.kBeaconPlayerKey]=Constants.kBeaconEventChromecast
        beaconDict[Constants.kBeaconMedia_typeKey]=Constants.kBeaconEventMediaTypeVideo
        beaconDict[Constants.kBeaconDp2Key]=Utility.sharedUtility.getDp2ParameterForBeaconEvent(fileName: self.currentCastedMovieID ?? "")
        let fireBeaconEvent : BeaconEvent = BeaconEvent.init(beaconDict)
        DataManger.sharedInstance.postBeaconEvents(beaconEvent: fireBeaconEvent)  
    }
    
    //MARK:Update Player Progress API to server
    func updatePlayerProgressToServerAfterThirySeconds(currentTime:Double) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() != NotReachable { //&& !self.isFilmProgressUpdateInSync {
            
            if mediaInfo != nil {
                
                self.isFilmProgressUpdateInSync = true

                let updatePlayerProgressDict:Dictionary<String, Any> = ["userId":Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", "videoId":self.mediaInfo.customData as? String ?? "", "watchedTime":currentTime, "siteOwner":AppConfiguration.sharedAppConfiguration.sitename ?? ""]
                
                let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/video/history"
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"isHistoryUpdated"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"updatePlayerProgress"), object: nil, userInfo: ["playerProgress":currentTime, "filmId":self.mediaInfo.customData ?? " "])
                
                DataManger.sharedInstance.updateFilmProgressOnServer(apiEndPoint: apiEndPoint, requestParameters: updatePlayerProgressDict) { (errorMessage, isSuccess) in
                    
//                    if isSuccess == false {
//                        
//                        if errorMessage != nil {
//                            
//                            let castSession = GCKCastContext.sharedInstance().sessionManager.currentCastSession
//                            castSession?.remoteMediaClient?.pause()
//                            if let topController = self.topViewController() {
//                                
//                                let okAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (okAction) in
//                                    CastPopOverView.shared.deviceDisconnected()
//                                })
//
//                                let error:String? = errorMessage?["error"] as? String ?? errorMessage?["message"] as? String
//                                if error != nil{
//                                    let errorAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "", alertMessage: error!, alertActions: [okAction])
//                                    topController.present(errorAlert, animated: true, completion: nil)
//                                }
//                            }
//                        }
//                        else {
//                            
//                            self.isFilmProgressUpdateInSync = false
//                        }
//                    }
//                    else {
//                        
//                        self.isFilmProgressUpdateInSync = false
//                    }
                }
            }
        }
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        let device : GCKDevice = session.device
        CastPopOverView.shared.selectedDevice = device
        CastPopOverView.shared.connectToDevice()
        Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name("ApplicationResumeCasting"), object: nil)
    }

}
