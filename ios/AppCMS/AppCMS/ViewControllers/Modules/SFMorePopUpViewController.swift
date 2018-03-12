//
//  SFMorePopUpViewController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 07/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

/// Action associated to #SFMorePopUpViewController.
///
/// - watchlistAction: Use this to add or remove from watchlist.
/// - downloadAction: Use this to start/pause/resume/cancel download.
/// - shareFacebookAction: Use this to share via Facebook.
/// - shareTwitterAction: Use this to share via Twitter.
@objc enum MorePopUpOptions: Int {
    case watchlistAction
    case downloadAction
    case shareFacebookAction
    case shareTwitterAction
    case externalWebViewAction
    case closeAction
    case readlistAction
}

enum CompeletionHandlerOptions {
    
    case UpdateWatchlist
    case UpdateVideoPlay
}

enum WatchListActions {
    
    case removeFromWatchListAction
    case addToWatchListAction
}

enum ReadListActions {
    
    case removeFromReadListAction
    case addToReadListAction
}

@objc protocol SFMorePopUpViewControllerDelegate:NSObjectProtocol {
    @objc optional func removePopOverViewController(viewController:UIViewController) -> Void
}

class SFMorePopUpViewController: UIViewController, SFMorePopUpViewDelegate, downloadManagerDelegate {
    
    private var morePopUpOptions:Array<Dictionary<String, Any>>
    private var contentId:String?
    weak var delegate:SFMorePopUpViewControllerDelegate?
    private var contentType:String?
    private var film : SFFilm?
    var roundProgressView:RoundProgressBar?
    var watchListStatus:WatchListActions?
    var readListStatus:ReadListActions?
    var watchlistStatusUpdateLabel:UILabel?
    var networkUnavailableAlert:UIAlertController?
    var progressIndicator:MBProgressHUD?
    private var isWatchlistFetchInProgress:Bool = false
    private var isDownloadFetchInProgress:Bool = false
    // lazy loading more pop up view
    private(set) lazy var morePopUpView: SFMorePopUpView = {
        
        let view = SFMorePopUpView()
        view.frame = self.view.frame
        view.viewDelegate = self
        view.backgroundColor = (Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")).withAlphaComponent(0.46)
        
        return view
    }()

    init(contentId:String?, moreOptionArray:Array<Dictionary<String, Any>>) {
        
        self.morePopUpOptions = moreOptionArray
        self.contentId = contentId
        super.init(nibName: nil, bundle: nil)
    }
    
    init(contentId:String?, contentType:String?, moreOptionArray:Array<Dictionary<String, Any>>) {
        
        self.morePopUpOptions = moreOptionArray
        self.contentId = contentId
        self.contentType = contentType
        super.init(nibName: nil, bundle: nil)
    }

    init(contentId:String?, contentType:String?, moreOptionArray:Array<Dictionary<String, Any>>, filmObject:SFFilm?) {

        self.morePopUpOptions = moreOptionArray
        self.contentId = contentId
        self.contentType = contentType
        self.film = filmObject
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createRoundProgressView(downloadObject: DownloadObject) -> Void {
        self.morePopUpView.fileDownloadState = downloadObject.fileDownloadState
        DownloadManager.sharedInstance.downloadDelegate = self
        self.roundProgressView = RoundProgressBar.init(with: downloadObject)
        self.roundProgressView?.setTheProgressForItemForDownloadProgress(self.film!)
    }

    func getDownloadObject() -> DownloadObject? {
        var downloadObject:DownloadObject?
        for obj in DownloadManager.sharedInstance.globalDownloadArray{
            if obj.fileID == self.contentId{
                downloadObject = obj
                break
            }
        }
        return downloadObject
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        self.view.addSubview(morePopUpView)
        self.morePopUpView.backgroundColor = (Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")).withAlphaComponent(0.46)
        self.morePopUpView.frame = UIScreen.main.bounds
        self.morePopUpView.morePopUpOptions = morePopUpOptions
        self.morePopUpView.createMorePopUpView()
        
        if self.contentId != nil && contentType != nil {
            
            if contentType?.lowercased() == Constants.kVideosContentType || contentType?.lowercased() == Constants.kVideoContentType {
                
                self.fetchVideoWatchlistStatus()
                self.fetchVideoDownloadStatus()
            }
            
            if (self.roundProgressView == nil) {
                if let downloadObject = self.getDownloadObject(){
                    self.film = DownloadManager.sharedInstance.getFilmObject(for: downloadObject)
                    self.createRoundProgressView(downloadObject: downloadObject)
                }
            }
            
            NotificationCenter.default.addObserver(self, selector:#selector(removeMorePopUpOnDownloadStart(notification:)), name: NSNotification.Name(rawValue: "DownloadStarted"), object: nil)
        }
        // Do any additional setup after loading the view.
    }

    deinit{
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DownloadStarted"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - API to fetch video watchlist status
    private func fetchVideoWatchlistStatus() {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
        }
        else {
            
            if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {

                self.view.isUserInteractionEnabled = false
                
                self.isWatchlistFetchInProgress = true
                showActivityIndicator(loaderText: nil)
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    DataManger.sharedInstance.getVideoStatus(videoId: self.contentId, success: { [weak self] (videoStatusResponseDict, isSuccess) in
                        
                        DispatchQueue.main.async {
                            guard let _ = self else {
                                return
                            }
                            self?.view.isUserInteractionEnabled = true
                            self?.hideActivityIndicator()
                            self?.isWatchlistFetchInProgress = false
                            if videoStatusResponseDict != nil && isSuccess {
                                
                                if videoStatusResponseDict?["isQueued"] != nil {
                                    
                                    let value : Bool = (videoStatusResponseDict?["isQueued"])! as! Bool
                                    if(value)
                                    {
                                        self?.watchListStatus = WatchListActions.removeFromWatchListAction
                                        self?.morePopUpView.watchListStatus = WatchListActions.removeFromWatchListAction
                                    }
                                    else
                                    {
                                        self?.watchListStatus = WatchListActions.addToWatchListAction
                                        self?.morePopUpView.watchListStatus = WatchListActions.addToWatchListAction
                                    }
                                    if !(self?.isWatchlistFetchInProgress)! && !(self?.isDownloadFetchInProgress)! {
                                        
                                        self?.morePopUpView.updateMorePopUpViewStatus()
                                    }
                                }
                            }
                        }
                    })
                }
            }
            else{
                self.morePopUpView.watchListStatus = WatchListActions.addToWatchListAction
                self.isWatchlistFetchInProgress = false
                if !self.isWatchlistFetchInProgress && !self.isDownloadFetchInProgress {
                    self.morePopUpView.updateMorePopUpViewStatus()
                }
            }
        }
    }
    
    
    //MARK: More Popover view delegate
    func buttonClicked(button: UIButton, buttonAction: MorePopUpOptions, externalWebLink: String?) {
        
        switch buttonAction {
        case .closeAction:
            
            if delegate != nil {
                
                if (delegate?.responds(to: #selector(SFMorePopUpViewControllerDelegate.removePopOverViewController(viewController:))))! {
                    
                    delegate?.removePopOverViewController!(viewController: self)
                }
            }
            break
        
        case .externalWebViewAction:
            
            if externalWebLink != nil {
                
                if let webUrl = URL(string: externalWebLink!) {
                    
                    UIApplication.shared.openURL(webUrl)
                }
            }
            break
        
        case .watchlistAction:
            
            if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                
                updateVideoWatchlistStatus(button: button)
            }
            else {
                
                userPromptForSignIn(button: button, filmObject: nil)
            }
            break
        
        case .downloadAction:
            
            if (self.film == nil) {
                let reachability:Reachability = Reachability.forInternetConnection()
                if reachability.currentReachabilityStatus() == NotReachable {
                    self.networkNotAvailable()
                }
                else{
                    let autoplayhandler = AutoPlayArrayHandler()
                    self.showActivityIndicator(loaderText: "")
                    autoplayhandler.getTheAutoPlaybackArrayForFilm(film:self.contentId!){ [weak self] (relatedVideoArray, filmObject) in
                        guard let _ = self else {
                            return
                        }
                        self?.hideActivityIndicator()
                        if filmObject != nil{
                            self?.film = filmObject
                            let downloadObject:DownloadObject = DownloadManager.sharedInstance.getDownloadObject(for: (self?.film)!, andShouldSaveToDirectory: false)
                            self?.createRoundProgressView(downloadObject: downloadObject)
                            self?.roundProgressView?.downloadButtonTapped(sender: (self?.roundProgressView?.downloadButton!)!)
                        }
                    }
                }
            }
            else{
                let downloadObject:DownloadObject = DownloadManager.sharedInstance.getDownloadObject(for: self.film!, andShouldSaveToDirectory: false)
                if downloadObject.fileDownloadState != .eDownloadStateFinished{
                    self.roundProgressView?.downloadButtonTapped(sender: (self.roundProgressView?.downloadButton!)!)
                }
            }
            break
        
        case .readlistAction:
            break
        default:
            break
        }
//        if buttonAction == .closeAction {
//
//            if delegate != nil {
//
//                if (delegate?.responds(to: #selector(SFMorePopUpViewControllerDelegate.removePopOverViewController(viewController:))))! {
//
//                    delegate?.removePopOverViewController!(viewController: self)
//                }
//            }
//        }
//        else if buttonAction == .externalWebViewAction {
//
//            if externalWebLink != nil {
//
//                if let webUrl = URL(string: externalWebLink!) {
//
//                     UIApplication.shared.openURL(webUrl)
//                }
//            }
//        }
//        else if buttonAction == .watchlistAction {
//
//            if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
//
//                updateVideoWatchlistStatus(button: button)
//            }
//            else {
//
//                userPromptForSignIn(button: button, filmObject: nil)
//            }
//        }
//        else if buttonAction == .downloadAction
//        {
//            if (self.film == nil) {
//                let reachability:Reachability = Reachability.forInternetConnection()
//                if reachability.currentReachabilityStatus() == NotReachable {
//                    self.networkNotAvailable()
//                }
//                else{
//                    let autoplayhandler = AutoPlayArrayHandler()
//                    self.showActivityIndicator(loaderText: "")
//                    autoplayhandler.getTheAutoPlaybackArrayForFilm(film:self.contentId!){ [weak self] (relatedVideoArray, filmObject) in
//                        guard let _ = self else {
//                            return
//                        }
//                        self?.hideActivityIndicator()
//                        if filmObject != nil{
//                            self?.film = filmObject
//                            let downloadObject:DownloadObject = DownloadManager.sharedInstance.getDownloadObject(for: (self?.film)!, andShouldSaveToDirectory: false)
//                            self?.createRoundProgressView(downloadObject: downloadObject)
//                            self?.roundProgressView?.downloadButtonTapped(sender: (self?.roundProgressView?.downloadButton!)!)
//                        }
//                    }
//                }
//            }
//            else{
//                let downloadObject:DownloadObject = DownloadManager.sharedInstance.getDownloadObject(for: self.film!, andShouldSaveToDirectory: false)
//                if downloadObject.fileDownloadState != .eDownloadStateFinished{
//                    self.roundProgressView?.downloadButtonTapped(sender: (self.roundProgressView?.downloadButton!)!)
//                }
//            }
//        }
    }

    /*!
     * @brief networkNotAvailable method prompt user if network is not available.
     * @param nil.
     */
    private func networkNotAvailable() {
        
        let alertController = UIAlertController(title: "Internet Connection", message: "Video stopped downloading. Please try again when connected to wi-fi or enable cellular data.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Constants.kStrClose, style: .default, handler: {(_ action: UIAlertAction) -> Void in
        })
        alertController.addAction(cancelAction)
        alertController.show()

    }
    
    //MARK: - Fetch video download status
    private func fetchVideoDownloadStatus() {
        
        if !self.isWatchlistFetchInProgress && !self.isDownloadFetchInProgress {
            
            self.morePopUpView.updateMorePopUpViewStatus()
        }
    }
    
    
    //MARK: Button handler events
    func buttonClicked(buttonAction:MorePopUpOptions) {
        
        
    }

    
    func userPromptForSignIn(button:UIButton?, filmObject:SFFilm?) {
        
        let signInAction:UIAlertAction = UIAlertAction(title: Constants.kStrSign, style: .default) { (signInAction) in
            
            self.displayLoginScreen(button: button, filmObject: filmObject, loginCompeletionHandlerType: .UpdateWatchlist)
        }
        
        let cancelAction:UIAlertAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
            
        }
        
        let userAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kStrAddToWatchlistAlertTitle, alertMessage: Constants.kStrAddToWatchlistAlertMessage, alertActions: [cancelAction, signInAction])
        
        self.present(userAlert, animated: true, completion: nil)
    }
    
    
    func displayLoginScreen(button:UIButton?, filmObject:SFFilm?, loginCompeletionHandlerType:CompeletionHandlerOptions) -> Void {
        
        displayLoginViewWithCompletionHandler(button: button, filmObject: filmObject) { (isSuccessfullyLoggedIn) in
            
            if isSuccessfullyLoggedIn {
                
                if loginCompeletionHandlerType == CompeletionHandlerOptions.UpdateWatchlist {
                    
                    self.updateVideoWatchlistStatus(button: button!)
                }
            }
        }
    }
    
    
    func displayLoginViewWithCompletionHandler(button:UIButton?, filmObject:SFFilm?, completionHandler: @escaping ((_ isSuccessfullyLoggedIn: Bool) -> Void)) -> Void {
        
        let loginViewController: LoginViewController = LoginViewController.init()
        loginViewController.loginPageSelection = 0
        loginViewController.pageScreenName = "Sign In Screen"
        loginViewController.loginType = loginPageType.authentication
        loginViewController.completionHandlerCopy = completionHandler
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: loginViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    //MARK: Method to update watchlist status
    func updateVideoWatchlistStatus(button:UIButton?) {
        
        if (self.watchListStatus == WatchListActions.removeFromWatchListAction) {
            
            //Remove video from watchlist
            removeVideoFromQueue(button: button)
        }
        else {
            
            //Add video to watchlist
            addVideoToQueue(button: button)
        }
    }
    
    
    //MARK: Method to add video to watchlist
    func addVideoToQueue(button:UIButton?) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            self.showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, errorMessage: nil, errorTitle: nil,  button: nil)
        }
        else {
            
            let watchlistPayload:Dictionary<String, Any> = ["userId": Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", "contentId": self.contentId! , "position":1, "contentType":self.contentType!]
            
            let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
            
            showActivityIndicator(loaderText: nil)
            DataManger.sharedInstance.addVideoToQueue(apiEndPoint: apiRequest, requestParameters: watchlistPayload, success: { (isVideoAdded) in
                
                self.hideActivityIndicator()
                
                if isVideoAdded != nil {
                    
                    if isVideoAdded! == true {
                        
                        if button != nil {
                            
                            button?.setTitle(Constants.kRemoveFromWatchlist, for: .normal)
                        }
                        
                        self.showWatchlistStatusUpdateView(viewText: "Added to Watchlist")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"isWatchlistUpdated"), object: nil)
                        self.removeMorePopOverView()
                    }
                    else
                    {
                        var errorMessage:String = "Unable to add video to watchlist."
                        
                        if self.contentType == Constants.kShowContentType ||  self.contentType == Constants.kShowsContentType {
                            
                            errorMessage = "Unable to add show to watchlist."
                        }
                        
                        self.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, errorMessage: errorMessage, errorTitle: "Watchlist", button: nil)
                    }
                }
                else {
                    
                    var errorMessage:String = "Unable to add video to watchlist."
                    
                    if self.contentType == Constants.kShowContentType ||  self.contentType == Constants.kShowsContentType {

                        errorMessage = "Unable to add show to watchlist."
                    }
                    
                    self.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, errorMessage: errorMessage, errorTitle: "Watchlist",  button: nil)
                }
            })
        }
    }
    
    //MARK: Method to remove video from watchlist
    func removeVideoFromQueue(button:UIButton?) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, errorMessage: nil, errorTitle: nil,  button: nil)
        }
        else {
            
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")&contentIds=\(self.contentId!)"
            showActivityIndicator(loaderText: nil)
            
            DataManger.sharedInstance.removeVideosFromQueue(apiEndPoint: apiEndPoint) { (isVideoRemoved) in
                
                self.hideActivityIndicator()
                
                if isVideoRemoved == true {
                    
                    if button != nil {
                        
                        button?.setTitle(Constants.kAddToWatchlist, for: .normal)
                    }
                    self.showWatchlistStatusUpdateView(viewText: "Removed from Watchlist")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:"isWatchlistUpdated"), object: nil)
                    self.removeMorePopOverView()
                }
                else {
                    
                    var errorMessage:String = "Unable to remove video from watchlist."
                    if self.contentType != nil{
                        if self.contentType == Constants.kShowContentType ||  self.contentType == Constants.kShowsContentType {

                            errorMessage = "Unable to remove show from watchlist."
                        }
                    }
                    self.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, errorMessage: errorMessage, errorTitle: "Watchlist", button: nil)
                }
            }
        }
    }
    
    
    //MARK: Display watchlist add/remove view
    func showWatchlistStatusUpdateView(viewText:String) {
        
        watchlistStatusUpdateLabel = UILabel(frame: UIScreen.main.bounds)
        watchlistStatusUpdateLabel?.text = viewText
        watchlistStatusUpdateLabel?.font = UIFont(name: "Lato", size: 17.0)
        watchlistStatusUpdateLabel?.textAlignment = .center
        watchlistStatusUpdateLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "fffff")
        watchlistStatusUpdateLabel?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000").withAlphaComponent(0.9)
        let window = UIApplication.shared.keyWindow!
        window.addSubview(watchlistStatusUpdateLabel!)
        self.watchlistStatusUpdateLabel?.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            
            self.watchlistStatusUpdateLabel?.alpha = 1.0
            
        }) { (finished) in
            
            UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
                
                self.watchlistStatusUpdateLabel?.alpha = 0.0
                
            }, completion: { (finished) in
                self.watchlistStatusUpdateLabel?.removeFromSuperview()
                self.watchlistStatusUpdateLabel = nil
            })
        }
    }
    
    
    //MARK:-Display Error in removing from watchlist
    func showWatchlistAlertForAlertType(alertType: AlertType, errorMessage:String?, errorTitle:String?, button:SFButton?) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                if(errorTitle == "fetchVideoWatchlistStatus")
                {
                    self.fetchVideoWatchlistStatus()
                }
                else
                {
                    self.updateVideoWatchlistStatus(button: button)
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
            
            alertTitleString = errorTitle
            alertMessage = errorMessage
        }
        
        networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction, retryAction])
        let window = UIApplication.shared.keyWindow!
        window.rootViewController?.present(networkUnavailableAlert!, animated: true, completion: nil)
    }
    
    
    //MARK:- Remove pop over view
    func removeMorePopOverView()
    {
        if delegate != nil {
            
            if (delegate?.responds(to: #selector(SFMorePopUpViewControllerDelegate.removePopOverViewController(viewController:))))! {
                
                delegate?.removePopOverViewController!(viewController: self)
            }
        }
    }
    
    func removeMorePopUpOnDownloadStart(notification:Notification){
        //self.removeMorePopOverView()
    }
    
    
    //MARK - Show/Hide Activity Indicator
    func showActivityIndicator(loaderText:String?) {
        
        let window = UIApplication.shared.keyWindow!
        progressIndicator = MBProgressHUD.showAdded(to: window, animated: true)
        if loaderText != nil {
            
            progressIndicator?.label.text = loaderText!
        }
    }
    
    func hideActivityIndicator() {
        
        progressIndicator?.hide(animated: true)
    }
    
    
    //MARK:- Download Delegates
    func downloadFinished(for thisObject: DownloadObject) {
        
        manageStateOfProgressViews(with: thisObject)
    }
    
    func downloadStateUpdate(for thisObject: DownloadObject) {
        
        manageStateOfProgressViews(with: thisObject)
    }
    
    func downloadFailed(for thisObject: DownloadObject) {
        
        manageStateOfProgressViews(with: thisObject)
    }
    
    
    func updateDownloadProgress(for thisObject: DownloadObject, withProgress progress: Float) {
        
        if (thisObject.fileID == contentId) {
            self.roundProgressView?.setTheProgressForItemForDownloadProgress(DownloadManager.sharedInstance.getFilmObject(for: thisObject))
        }
        
    }
    
    func manageStateOfProgressViews(with thisObject: DownloadObject) {
        
        if (thisObject.fileID == self.film!.id) {
            self.roundProgressView?.setTheProgressForItemForDownloadProgress(DownloadManager.sharedInstance.getFilmObject(for: thisObject))
            self.morePopUpView.fileDownloadState = thisObject.fileDownloadState
            self.morePopUpView.updateMorePopUpViewStatus()
        }
    }
    
    
    //MARK: Orientaion Method
    override func viewDidLayoutSubviews() {
        
        self.morePopUpView.frame = self.view.frame
        self.morePopUpView.updateSubViewFrames()
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
