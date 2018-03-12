//
//  PlayerViewController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 03/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import GoogleInteractiveMediaAds

class PlayerViewController: UIViewController, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {

    var videoPlayerController:AVPlayerViewController?
    var contentPlayer:AVPlayer?
    var playerLayer:AVPlayerLayer?
    var videoView:UIView!
    var permaLink:String?
    var videoUrlToBePlayed:String?
    var contentId:String?
    var progressIndicator:MBProgressHUD?
    var contentPlayhead:IMAAVPlayerContentPlayhead?
    var adsLoader:IMAAdsLoader?
    var adsManager: IMAAdsManager?
    let kTestAppAdTagUrl = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpremidpost&cmsid=496&vid=short_onecue&correlator="
    
    var adTag = "http://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/225734590/SF_Video/Mapp_iOS&ciu_szs&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1"
    
    init (videoContentId:String, permalink:String) {
        
        self.contentId = videoContentId
        self.permaLink = permalink
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        progressIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressIndicator?.label.text = "Loading..."
        
        createVideoView()
        fetchVideoURLToBePlayed()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //playerLayer?.frame = videoView.layer.bounds
    }
    
    
    func createVideoView() {
        
        videoView = UIView(frame: self.view.frame)
        videoView.backgroundColor = UIColor.black
        
        self.view.addSubview(videoView)
    }
    
    //MARK: Method to fetch Video URL to play
    func fetchVideoURLToBePlayed() {
        
        DataManger.sharedInstance.fetchURLDetailsForVideo(apiEndPoint: "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "https://apisnagfilms-dev.viewlift.com")/content/videos/\(contentId ?? "")?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "testflow2")&fields=streamingInfo") { (filmURLs) in
            
            DispatchQueue.main.async {
                
                self.progressIndicator?.hide(animated: true)
                self.playVideo(videoUrls: filmURLs)
            }
        }
    }
    
    
    func playVideo(videoUrls:Dictionary<String, AnyObject>?) {
        
        let videoUrls:Dictionary<String, AnyObject>? = videoUrls?["videoUrl"] as? Dictionary<String, AnyObject>
        
        let rendentionUrls:Array<AnyObject>? = videoUrls?["renditionUrl"] as? Array<AnyObject>
        let hlsUrl:String? = videoUrls?["hlsUrl"] as? String
        
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
            loadVideoPlayer(videoURLString: videoUrlToBePlayed!)
        }
        else {
            
            let alertController = UIAlertController(title: "Error", message: "Film url not available", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: Load VideoPlayer
    func loadVideoPlayer(videoURLString:String) {
        
        contentPlayer = AVPlayer(url: URL(string: videoURLString)!)
        
        //Create player layer for player
        playerLayer = AVPlayerLayer(player: contentPlayer)
        
        playerLayer?.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer!)
        
        createContentPlayhead()
        setUpAdsLoader()
        
        requestAds()
//        let playerItem = AVPlayerItem(url: URL(string: videoURLString)!)
//        let videoPlayer = AVPlayer(playerItem: playerItem)
//        videoPlayerController = AVPlayerViewController()
//        videoPlayerController?.player = videoPlayer
        
        NotificationCenter.default.addObserver(self, selector: Selector(("playerDidFinishPlaying:")), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: contentPlayer?.currentItem)
//        self.present(videoPlayerController!, animated: true) {
//            
//            self.videoPlayerController?.player?.play()
//        }
        
    }

    //MARK: Player Delegate
    func playerDidFinishPlaying(notification:Notification) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func contentDidFinishPlaying(notification:Notification) {
        
        // Make sure we don't call contentComplete as a result of an ad completing.
        if notification.object as? AVPlayerItem == contentPlayer?.currentItem {
            
            adsLoader!.contentComplete()
        }
    }
    
    func setUpAdsLoader() {
        
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader?.delegate = self
    }
    
    func requestAds() {
        // Create an ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: videoView, companionSlots: nil)
        
        // Create a content playhead so the SDK can track our content for VMAP and ad rules.
       // createContentPlayhead()
        
        let timeInMilliSeconds:Int64 = Int64(Date().timeIntervalSince1970)
        
        let adTagEndPoint = "&url=https://\(AppConfiguration.sharedAppConfiguration.domainName ?? "")\(permaLink ?? "")&ad_rule=0&correlator=\(timeInMilliSeconds)&cust_params=APPID%3D\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        adTag = adTag.appending(adTagEndPoint)
        
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: adTag,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil)
        
        adsLoader!.requestAds(with: request)
    }
    
    
    func createContentPlayhead() {
        
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: contentPlayer)
        NotificationCenter.default.addObserver(self, selector: Selector(("contentDidFinishPlaying:")), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: contentPlayer?.currentItem)
    }
    
    
    func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        
        
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate
        adsManager = adsLoadedData.adsManager
        adsManager!.delegate = self
        
        print("cue points >>> \(adsManager?.adCuePoints ?? [])")
        // Create ads rendering settings and tell the SDK to use the in-app browser.
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.webOpenerPresentingController = self
        
        // Initialize the ads manager.
        adsManager?.initialize(with: adsRenderingSettings)
    }
    
    
    func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        
        print("Failing loading ads \(adErrorData.adError.message)")
        contentPlayer?.play()
    }
    
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        
        print("Error loading ads: \(error.message)")
        contentPlayer?.play()
    }
    
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
        
        print("adsManager event \(event.typeString!)")
        
        switch (event.type) {
        case .LOADED:
            adsManager.start()
            break
          
        case .PAUSE:
            break
            
        case .RESUME:
            break
            
        case .TAPPED:
            break
        
        case .COMPLETE:
            contentPlayer?.play()
            break
            
        default:
            break
        }
    }
    
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        
        contentPlayer?.pause()
    }
    
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        
        contentPlayer?.play()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
