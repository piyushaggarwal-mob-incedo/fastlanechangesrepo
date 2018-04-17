//
//  ModuleContainerViewController_tvOS.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 21/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

/// The view controller which acts the single page module loader for all pages.
class ModuleContainerViewController_tvOS: BaseViewController, UITableViewDataSource, UITableViewDelegate, ModuleViewModelDelegate
{
    
    //ModuleViewModelHandlers
    
    /// Lazily creating the carouselModuleHandler
    private(set) lazy var carouselHandlerViewModel: ModuleViewModel_CarouselHandler = {
        let viewModel = ModuleViewModel_CarouselHandler()
        viewModel.delegate = self
        return viewModel
    }()
    
    /// Lazily creating the videoPlayerViewHandler
    private(set) lazy var videopPlayerHandlerViewModel: ModuleViewModel_VideoPlayerModuleHandler = {
        let viewModel = ModuleViewModel_VideoPlayerModuleHandler()
        viewModel.delegate = self
        return viewModel
    }()
    
    /// Lazily creating the collectionGridModuleHandler
    private(set) lazy var collectionGridHandlerViewModel: ModuleViewModel_CollectionGridHandler = {
        let viewModel = ModuleViewModel_CollectionGridHandler()
        viewModel.delegate = self
        return viewModel
    }()
    
    /// Lazily creating the videoDetailModuleHandler
    private(set) lazy var videoDetailHandlerViewModel: ModuleViewModel_VideoDetailHandler = {
        let viewModel = ModuleViewModel_VideoDetailHandler()
        viewModel.delegate = self
        return viewModel
    }()
    
    /// Lazily creating the showDetailModuleHandler
    private(set) lazy var showDetailHandlerViewModel: ModuleViewModel_ShowDetailHandler = {
        let viewModel = ModuleViewModel_ShowDetailHandler()
        viewModel.delegate = self
        return viewModel
    }()
    /// Lazily creating the loginViewModuleHandler
    private(set) lazy var loginViewHandlerViewModel: ModuleViewModel_LoginViewHandler = {
        let viewModel = ModuleViewModel_LoginViewHandler()
        viewModel.delegate = self
        return viewModel
    }()
    
    /// Lazily creating the ancillaryViewModuleHandler
    private(set) lazy var ancillaryViewHandlerViewModel: ModuleViewModel_AncillaryViewHandler = {
        let viewModel = ModuleViewModel_AncillaryViewHandler()
        viewModel.delegate = self
        return viewModel
    }()
    
    /// Lazily creating the watchlistHistory View Handler
    private(set) lazy var watchlistHistoryViewHandler: ModuleViewModel_WatchListHistoryHandler = {
        let viewModel = ModuleViewModel_WatchListHistoryHandler()
        viewModel.delegate = self
        return viewModel
    }()
    
    
    /// Lazily creating the watchlistHistory View Handler
    private(set) lazy var settingViewHandler: ModuleViewModel_SettingViewHandler = {
        let viewModel = ModuleViewModel_SettingViewHandler()
        viewModel.delegate = self
        return viewModel
    }()
    
    /// Lazily creating the ContactUs View Handler
    private(set) lazy var contactUsViewHandler: ModuleViewModel_ContactUsViewHandler = {
        let viewModel = ModuleViewModel_ContactUsViewHandler()
        return viewModel
    }()
    
    /// Lazily creating the RawText View Handler
    private(set) lazy var rawTextViewHandler: ModuleViewModel_RawTextViewHandler = {
        let viewModel = ModuleViewModel_RawTextViewHandler()
        return viewModel
    }()
    
    /// Lazily creating the SubscriptionViewModuleHandler
    private(set) lazy var subscriptionViewHandler: ModuleViewModel_SubscriptionViewHandler = {
        let viewModel = ModuleViewModel_SubscriptionViewHandler()
        viewModel.delegate = self
        return viewModel
    }()
    
    
    /// Lazily creating the TeamsPage
    private(set) lazy var teamsViewHandler: ModuleViewModel_SubNavigationViewHandler = {
        let viewModel = ModuleViewModel_SubNavigationViewHandler()
        viewModel.delegate = self
        if let pageObject = self.viewControllerPage{
            viewModel.pageObject = pageObject
        }
        return viewModel
    }()
    // -ModuleViewModelHandlers
    
    /// Top Banner View Module.
    private var topBannerView: TopBannerSubscriptionModule?
    
    /// Associated viewModel for View Controller class.
    let viewModel = ModuleContainerViewModel_tvOS()
    
    /// Content Id for page. Set this to fetch data for the page.
    var contentId:String?
    
    /// Grid Object for page. Set this to pass grid object data.
    var gridObject:SFGridObject?
    
    /// Page path for page. Set this to fetch data for the page.
    var pagePath:String?
    
    /// Video Player instance for playing trailers.
    private var videoPlayerController:AVPlayerViewController?
    
    /// Page object instance.
    private var viewControllerPage: Page?
    
    /// Page's display name.
    private var pageDisplayName: String?
    
    /// Base table view. This table acts as the base of majority of views in this project.
    private var tableView:UITableView?
    
    /// Mark this 'true' if any fetch request is in progress.
    var fetchRequestInProcess:Bool = false
    
    /// Holds the list of module dictionaries.
    private var modulesListDict:Dictionary<String, Any> = [:]
    
    /// Classe's page api object. Holds the data for the page.
    private var pageAPIObject:PageAPIObject?
    
    /// Holds modules' list.
    private var modulesListArray:Array<Any> = []
    
    /// Alert type for classifying the alert to be shown.
    private var alertType:AlertType?
    
    /// Module dictionary for table cells.
    private var cellModuleDict:Dictionary<String, AnyObject> = [:]
    
    /// Set this background view if the page is a non master navigation type.
    private var backGroundImageView: BackgroundImageViewContainer?

    /// Footer view instance for this class.
    private var footerView : SFFooterView?
    
    /// Holds the instance of the last focused item.
    private var lastFocusedView: Any?
    
    /// Network unavailable alert.
    private var trailerUnavailableAlert:UIAlertController?
    
    /// Trailer URL.
    private var trailerURL:String?
    
    /// Mark this if the module container class belongs to a viewcontroller which is a sub container type. E.g. Watchlist, History etc.
    var isSubContainer:Bool = false
    
    var addBackgroundImage:Bool = false
    
    /// Custom constructor method.
    ///
    /// - Parameter viewControllerPage: Page object passed from the instialising class.
    init (pageObject: Page, pageDisplayName: String) {
        self.pageDisplayName = pageDisplayName
        self.viewControllerPage = pageObject
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("Init with coder not imolemented.")
    }
    
    deinit {
        ///Remove observers
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidReceiveMemoryWarning, object: nil);
        NotificationCenter.default.removeObserver(self, name: Constants.KRefreshDataOfPage, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPlayerZoomToggledNotification), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewController = self
        self.title = viewControllerPage?.pageName
        createBackgroundImageView()
        
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment {
            addFooterViewToTheView()
        }
        NotificationCenter.default.addObserver(self, selector:#selector(playerModuleZoomed), name: NSNotification.Name(rawValue: kPlayerZoomToggledNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(refreshPageAfterDataUpdate), name: NSNotification.Name(rawValue: Constants.kUpdateAppNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(applicationConfigured), name: NSNotification.Name(rawValue: Constants.kAppConfigureNotification), object: nil)
        
        // Register to receive notification
//        NotificationCenter.default.addObserver(self, selector: #selector(clearSavedCellData), name: Notification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustFooterFrame(_:)), name: Constants.kToggleMenuBarNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(menuTappedOnCarousel(_:)), name: NSNotification.Name(rawValue: "MenuButtonTappedOnCarousel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPageData(_:)), name: Constants.KRefreshDataOfPage, object: nil)
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(enteredBackground), name: NSNotification.Name("ApplicationEnteredBackground"), object: nil)
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(enteredForeground), name: NSNotification.Name("ApplicationEnteredForeground"), object: nil)
    }
    
    @objc private func enteredBackground() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kUpdateAppNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kAppConfigureNotification), object: nil)
    }
    
    
    @objc private func enteredForeground() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kUpdateAppNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kAppConfigureNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(refreshPageAfterDataUpdate), name: NSNotification.Name(rawValue: Constants.kUpdateAppNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(applicationConfigured), name: NSNotification.Name(rawValue: Constants.kAppConfigureNotification), object: nil)
    }
    
    @objc private func clearSavedCellData() {
        cellModuleDict.removeAll()
        for child in childViewControllers {
            child.removeFromParentViewController()
        }
        tableView?.reloadData()
    }
    
    @objc private func menuTappedOnCarousel (_ notification: NSNotification) {
        if viewModel.pageOpenAction == .masterNavigationClickAction {
            self.pressesBegan(notification.userInfo?["presses"] as! Set<UIPress>, with: notification.userInfo?["event"] as? UIPressesEvent)
        }
    }
    
    private func createBackgroundImageView() {
        if viewModel.pageOpenAction == .videoClickAction || viewModel.pageOpenAction == .showClickAction {
            backGroundImageView = BackgroundImageViewContainer(frame: self.view.bounds)
            backGroundImageView?.isUserInteractionEnabled = false
            backGroundImageView?.imageOverlayView.isUserInteractionEnabled = false
            self.view.addSubview(backGroundImageView!)
        }
    }
    
    @objc private func adjustFooterFrame (_ notification: NSNotification) {
        let userInfo = notification.userInfo
        let margin = isSubContainer ? 140 : 0
        if (userInfo?["value"] as! Bool) {
            UIView.animate(withDuration: 0.2, animations: {
                self.footerView?.changeFrameYAxis(yAxis: CGFloat(1080 - (340 + margin)))
            }, completion: { (completed) in
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.footerView?.changeFrameYAxis(yAxis: CGFloat(1080 - (200 + margin)))
            }, completion: { (completed) in
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //SetUp page.
        createTableView()
        
        if addBackgroundImage {
            //            let backgroundImage = UIImage(named: "app_background.png")
            //            self.view.backgroundColor =   UIColor(patternImage:backgroundImage!)
            
            if let backgroundColor = AppConfiguration.sharedAppConfiguration.backgroundColor{
                self.view.backgroundColor = Utility.hexStringToUIColor(hex: backgroundColor)
            }
            else {
                if AppConfiguration.sharedAppConfiguration.appTheme == .light{
                    self.view.backgroundColor = .white
                }
                else{
                    self.view.backgroundColor = .black
                }
            }
            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
                let topBar = UIView(frame: CGRect(x: 0, y: 0, width: (self.view.bounds.size.width), height: 10))
                topBar.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "#000000")
                self.view.addSubview(topBar)
                self.view.bringSubview(toFront: topBar)
            }
        } else {
            self.view.backgroundColor = UIColor.clear
        }
        
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            let isSubscribed = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool ?? false)
            if isSubscribed == true {
                if let topBanner = topBannerView {
                    topBanner.isHidden = true
                    tableView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(self, selector:#selector(checkTrailerAlertIsShowing), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        if viewModel.pageOpenAction != nil && (viewModel.pageOpenAction == .masterNavigationClickAction ||  viewModel.pageOpenAction == .subNavigationClickAction) {
            let userInfo = [ "value" : true ]
            NotificationCenter.default.post(name: Notification.Name("ToggleMenuBarInteraction"), object: nil , userInfo : userInfo )
        }
        if let pageName = self.viewControllerPage?.pageName {
            GATrackerTVOS.sharedInstance().screenView(pageName, customParameters: nil)
        } else {
            GATrackerTVOS.sharedInstance().screenView("Page Screen", customParameters: nil)
        }
        if lastFocusedView != nil {
            self.updateFocusIfNeeded()
        }
        
        if Utility.sharedUtility.shouldDisplayForceUpdate() {
            
            Constants.kAPPDELEGATE.presentAppUpdateView(isForceUpdate: true)
        }
        else if Utility.sharedUtility.shouldDisplaySoftUpdate() {
            
            Constants.kAPPDELEGATE.presentAppUpdateView(isForceUpdate: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        lastFocusedView = UIScreen.main.focusedView
        viewModel.hideSwipeUpToSeeMenuHeadsUpNotification()
    }
    
    /// Load Page Data
    override func loadPageData() {
        super.loadPageData()
        if (pageAPIObject == nil && fetchRequestInProcess == false) || doesPageHaveDataForModules() == false {
            fetchPageContent()
        }
    }
    
    @objc private func refreshPageData (_ notification: NSNotification) {
        
        if Utility.sharedUtility.checkIfUserIsSubscribedGuest() || Utility.sharedUtility.checkIfUserIsLoggedIn() {
            if self.isShowing() {
                self.showActivityIndicator()
                callPageDataFetchAPI()
            }
        }
    }

    @objc private func playerModuleZoomed(sender: Notification) {
        if self.isShowing() {
            if let objectInfo = sender.object as? [String:Bool] {
                let zoomed = objectInfo["zoomed"] ?? false
                if zoomed {
                    fireNotificationToDisableMenuController()
                    disablePageModules()
                    self.tableView?.isScrollEnabled = false
                } else {
                    fireNotificationToEnableMenuController()
                    enablePageModules()
                    self.tableView?.isScrollEnabled = true
                }
            }
        }
    }
    
    private func enablePageModules() {
        var ii = 0
        while ii < cellModuleDict.count {
            let cell:UITableViewCell? = cellModuleDict["\(String(ii))"] as? UITableViewCell
            if cell?.tag != 404 {
                cell?.isUserInteractionEnabled = true
            }
            ii += 1
        }
    }
    
    private func disablePageModules() {
        var ii = 0
        while ii < cellModuleDict.count {
            let cell:UITableViewCell? = cellModuleDict["\(String(ii))"] as? UITableViewCell
            if cell?.tag != 404 {
                cell?.isUserInteractionEnabled = false
            }
            ii += 1
        }
    }
    
    @objc private func refreshPageAfterDataUpdate() {
        if (viewModel.pageOpenAction == .masterNavigationClickAction || viewModel.pageOpenAction == .subNavigationClickAction) && fetchRequestInProcess == false {

            var zz: Int = 0
            for localPage in AppConfiguration.sharedAppConfiguration.pages
            {
                if localPage.pageId == self.viewControllerPage?.pageId ?? ""
                {
                    if localPage.isPageUpdated == true
                    {
                        localPage.isPageUpdated = false
                        let filePath:String = AppSandboxManager.getpageFilePath(fileName: localPage.pageId ?? "")
                        let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
                        
                        if jsonData != nil {
                            let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                            let pageParser = PageUIParser()
                            let pageUpdated:Page? = pageParser.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
                            
                            if pageUpdated != nil {
                                if pageUpdated?.modules != nil && (pageUpdated?.modules.count)! > 0 {
                                    self.viewControllerPage?.modules = (pageUpdated?.modules)!
                                }
                            }
                        }
                        self.viewControllerPage?.isPageUpdated = localPage.isPageUpdated
                        AppConfiguration.sharedAppConfiguration.pages[zz] = localPage
                        fetchPageContent()
                        break
                    }
                }
                zz = zz + 1
            }
        }
    }
    
    // Called when app is configured.
    func applicationConfigured() {
        Constants.kAPPDELEGATE.dimissSoftAppUpdateAlert {
            
            if Utility.sharedUtility.shouldDisplayForceUpdate() {
                
                Constants.kAPPDELEGATE.presentAppUpdateView(isForceUpdate: true)
            }
            else if Utility.sharedUtility.shouldDisplaySoftUpdate() {
                
                Constants.kAPPDELEGATE.presentAppUpdateView(isForceUpdate: false)
            }
        }
    }
    
    func checkIfModuleComingInServerResponse(moduleId:String?) -> Bool {

        if (pageAPIObject?.pageModules?["\(moduleId ?? "")"]) != nil {
            return true
        } else {
            return false
        }
    }
    
    /// Method to fetch page module layout list
    private func createPageModuleLayoutList() {
        
        modulesListArray.removeAll()

        for module:Any in (viewControllerPage?.modules)! {
            
            if module is SFTrayObject {
                
                let trayObject:SFTrayObject = module as! SFTrayObject
                
                if checkIfModuleComingInServerResponse(moduleId: trayObject.trayId) {
                    
                    modulesListDict["\(trayObject.trayId!)"] = trayObject
                    modulesListArray.append(trayObject)
                }
            }
            else if module is SFJumbotronObject {
                
                let jumbotronObject:SFJumbotronObject = module as! SFJumbotronObject
                
                if checkIfModuleComingInServerResponse(moduleId: jumbotronObject.trayId) {
                    
                    modulesListDict["\(jumbotronObject.trayId!)"] = jumbotronObject
                    modulesListArray.append(jumbotronObject)
                }
            }
            else if module is SFVideoDetailModuleObject {
                
                let videoDetailObject:SFVideoDetailModuleObject = module as! SFVideoDetailModuleObject
                
                if checkIfModuleComingInServerResponse(moduleId: videoDetailObject.moduleID) {
                    
                    modulesListDict["\(videoDetailObject.moduleID!)"] = videoDetailObject
                    modulesListArray.append(videoDetailObject)
                }
            }
            else if module is SFShowDetailModuleObject {
                
                let showDetailObject:SFShowDetailModuleObject = module as! SFShowDetailModuleObject
                
                if checkIfModuleComingInServerResponse(moduleId: showDetailObject.moduleID) {
                    
                    modulesListDict["\(showDetailObject.moduleID!)"] = showDetailObject
                    modulesListArray.append(showDetailObject)
                }
            }
            else if module is LoginViewObject_tvOS{
                let loginViewObject : LoginViewObject_tvOS = module as! LoginViewObject_tvOS
                modulesListDict["\(loginViewObject.moduleID!)"] = loginViewObject
                modulesListArray.append(loginViewObject)
            }
            else if module is AncillaryViewObject_tvOS{
                let ancillaryViewObject : AncillaryViewObject_tvOS = module as! AncillaryViewObject_tvOS
                
                modulesListDict["\(ancillaryViewObject.moduleID!)"] = ancillaryViewObject
                modulesListArray.append(ancillaryViewObject)
                
            }
            else if module is SFWatchlistAndHistoryViewObject {
                
                let watchlistObject:SFWatchlistAndHistoryViewObject = module as! SFWatchlistAndHistoryViewObject
                modulesListDict["\(watchlistObject.moduleID!)"] = watchlistObject
                modulesListArray.append(watchlistObject)
            }
            else if module is SFSubNavigationViewObject {
                
                let teamObject:SFSubNavigationViewObject = module as! SFSubNavigationViewObject
                modulesListDict["\(teamObject.moduleID!)"] = teamObject
                modulesListArray.append(teamObject)
            }
            else if module is SettingViewObject_tvOS{
                let settingViewObject : SettingViewObject_tvOS = module as! SettingViewObject_tvOS
                modulesListDict["\(settingViewObject.moduleID!)"] = settingViewObject
                modulesListArray.append(settingViewObject)
            }
            else if module is ContactUsViewObject_tvOS{
                let contactUsViewObject : ContactUsViewObject_tvOS = module as! ContactUsViewObject_tvOS
                modulesListDict["\(contactUsViewObject.moduleID!)"] = contactUsViewObject
                modulesListArray.append(contactUsViewObject)
            }
            else if module is SFRawTextViewObject {
                let rawTextViewObject : SFRawTextViewObject = module as! SFRawTextViewObject
                modulesListDict["\(rawTextViewObject.moduleID!)"] = rawTextViewObject
                modulesListArray.append(rawTextViewObject)
            }
            else if module is SubscriptionViewObject_tvOS{
                let subscriptionViewObject : SubscriptionViewObject_tvOS = module as! SubscriptionViewObject_tvOS
                modulesListDict["\(subscriptionViewObject.moduleID!)"] = subscriptionViewObject
                modulesListArray.append(subscriptionViewObject)
            }
            else if module is SFFooterViewObject {
                if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment {
                    createFooterView(footerViewObject: module as! SFFooterViewObject)
                }
            }
            else if module is VideoPlayerModuleViewObject {
                let viewObject : VideoPlayerModuleViewObject = module as! VideoPlayerModuleViewObject
                modulesListDict["\(viewObject.moduleID!)"] = viewObject
                modulesListArray.append(viewObject)
            }
        }
        if modulesListArray.count > 1 {
            modulesListArray = modulesListArray.filter() { !($0 is SFRawTextViewObject) }
        }
    }

    //MARK: Method to fetch page content
    private func fetchPageContent() {
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable && doesPageHaveDataForModules() == true  {
            fetchRequestInProcess = false
            showAlertForAlertType(alertType: .AlertTypeNoInternetFound, alertTitle: nil, alertMessage: nil)
        }
        else {
            
            if viewControllerPage?.modules.isEmpty == false && doesPageHaveDataForModules() == false {
                self.createPageModuleLayoutList()
                tableView?.reloadData()
                tableView?.isHidden = false
            } else {
                fetchRequestInProcess = true
                removeEmptyMessageLbl()
                self.showActivityIndicator()
                
                if viewModel.pageOpenAction == .videoClickAction {
                    callVideoPageDataFetchAPI()
                } else if viewModel.pageOpenAction == .masterNavigationClickAction {
                    callPageDataFetchAPI()
                }

                else {
                    self.hideActivityIndicator()
                }
            }
        }
    }

    private func callVideoPageDataFetchAPI () {
        
        var apiEndPoint:String? = "/content/pages?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&includeContent=true"
        
        if pagePath != nil {
            
            apiEndPoint = "\(apiEndPoint ?? "")&path=\(pagePath ?? "")"
        }
        else if contentId != nil {
            apiEndPoint = "\(apiEndPoint ?? "")&pageId=\(contentId ?? "")"
            
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            DataManger.sharedInstance.fetchContentForVideoPage(shouldUseCacheUrl: self.viewControllerPage?.shouldUseCacheAPI ?? false, apiEndPoint: apiEndPoint!) { (pageAPIObjectResponse, errorMessage, isSuccess) in
                
                self.fetchRequestInProcess = false
                if let pageApiResponse = pageAPIObjectResponse {
                    
                    self.updatePageAfterFetchingResponse(pageAPIObjectResponse: pageApiResponse)

                } else {
                    
                    if errorMessage != nil {
                        
                        self.failureCaseReceivedCheckAndShowAlert(alertTitle: "", alertMessage: errorMessage!)
                    }
                    else {
                        
                        self.failureCaseReceivedCheckAndShowAlert(alertTitle: nil, alertMessage: nil)
                    }
                }
            }
        }
    }
    
    override func showEmptyLabel() {
       super.showEmptyLabel()
       let emptyMsglbl = self.getEmptyMessageLbl()
        emptyMsglbl.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        self.view.addSubview(emptyMsglbl)
    }
    
    private func callPageDataFetchAPI () {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            var apiEndPoint = "\(self.viewControllerPage?.pageAPI ?? "")?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&pageId=\(self.viewControllerPage?.pageId ?? "")&includeContent=true"
            
            if Utility.sharedUtility.checkIfUserIsLoggedIn(){
                
                apiEndPoint = apiEndPoint.appending("&includeWatchHistory=true&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")")
            }
            
            DataManger.sharedInstance.fetchContentForPage(shouldUseCacheUrl: self.viewControllerPage?.shouldUseCacheAPI ?? false, apiEndPoint: apiEndPoint) { (pageAPIObjectResponse) in
                
                self.fetchRequestInProcess = false
                if let pageApiResponse = pageAPIObjectResponse {
                    self.updatePageAfterFetchingResponse(pageAPIObjectResponse: pageApiResponse)
                } else {
                    self.failureCaseReceivedCheckAndShowAlert(alertTitle: nil, alertMessage: nil)
                }
            }
        }
    }
    
    private func updatePageAfterFetchingResponse(pageAPIObjectResponse: PageAPIObject) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            self.pageAPIObject = pageAPIObjectResponse
            if self.pageAPIObject != nil && self.pageAPIObject?.pageModules != nil {
                self.cellModuleDict.removeAll()
                self.createPageModuleLayoutList()
                if Constants.kAPPDELEGATE.appContainerVC?.isMenuViewShowing == false {
                    if self.modulesListArray.count > 1 {
                        let arrayContainingVideoPlayer = self.modulesListArray.filter() {$0 is VideoPlayerModuleViewObject}
                        if arrayContainingVideoPlayer.count > 0 {
                            let videoPlayerViewObject = arrayContainingVideoPlayer[0] as! VideoPlayerModuleViewObject
                            let isZoomSupported = videoPlayerViewObject.isZoomSupported ?? false
                            if self.tableView?.contentOffset.x == 0 {//}&& (isZoomSupported == false) {
                                self.viewModel.showScrollToSeeContentNotification(afterDelay: 0.0)
                            }
                            self.viewModel.showSwipeUpToSeeMenuHeadsUpNotification(afterDelay: 0.0)
                        } else {
                            self.viewModel.showSwipeUpToSeeMenuHeadsUpNotification(afterDelay: 0.0)
                        }
                    } else {
                        self.viewModel.showSwipeUpToSeeMenuHeadsUpNotification(afterDelay: 0.0)
                    }
                }
                self.tableView?.isHidden = false
                self.tableView?.reloadData()
            }
            else {
                self.failureCaseReceivedCheckAndShowAlert(alertTitle: nil, alertMessage: nil)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.viewModel.hideSwipeUpToSeeMenuHeadsUpNotification()
    }
    
    //MARK: Method to create table view
    private func createTableView() {
        
        if tableView == nil {
            var tableStartY: CGFloat = 0
            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports && (pageDisplayName != "Teams" && pageDisplayName != "Settings" && pageDisplayName != "reset_password") && viewModel.pageOpenAction != .subNavigationClickAction {
                let isSubscribed = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool ?? false)
                if isSubscribed == false {
                    var startingY = 0
                    if addBackgroundImage {
                        startingY = 10
                    }
                    topBannerView = UINib(nibName: "TopBannerSubscriptionModule", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? TopBannerSubscriptionModule
                    topBannerView?.frame = CGRect(x: 0, y: startingY, width: Int((topBannerView?.bounds.size.width)!), height: 55)
                    topBannerView?.constructView()
                    self.view.addSubview(topBannerView!)
                    self.view.bringSubview(toFront: topBannerView!)
                    tableStartY = CGFloat(55 + startingY)
                } else {
                    if addBackgroundImage {
                        tableStartY = 10
                    }
                }
            }
            tableView = UITableView(frame: CGRect(x: 0, y: tableStartY, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - tableStartY), style: .plain)
            tableView?.delegate = self
            tableView?.dataSource = self
            tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            tableView?.backgroundView = nil
            tableView?.backgroundColor = UIColor.clear
            tableView?.showsVerticalScrollIndicator = false
            tableView?.register(SFTrayModuleCell.self, forCellReuseIdentifier: "trayModuleCell")
            self.tableView?.mask = nil
            tableView?.clipsToBounds = true
            self.view.addSubview(tableView!)
            self.tableView?.isHidden = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustWrapperView()
    }
    
    @objc private func adjustWrapperView() {
        if #available(tvOS 11.0, *) {
            self.tableView?.contentInsetAdjustmentBehavior = .never
            self.tableView?.contentInset = .zero
            self.tableView?.insetsLayoutMarginsFromSafeArea = false
            for  view in (tableView?.subviews)! {
                if String(describing: type(of: view)) == "UITableViewWrapperView" {
                    if view.bounds != (tableView?.bounds)! {
                        view.changeFrameWidth(width: (tableView?.bounds.width)!)
                        view.changeFrameXAxis(xAxis: (tableView?.bounds.origin.x)!)
                    }
                    break
                }
            }
        }
    }
    
    //MARK: Table View Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if viewControllerPage?.modules.isEmpty == false && doesPageHaveDataForModules() == false {
            return 1
        }
        else if let countOfRows = pageAPIObject?.pageModules?.count {
            return countOfRows
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier:String = "gridCell"
        var cell:UITableViewCell? = cellModuleDict["\(String(indexPath.row))"] as? UITableViewCell
        
        if cell == nil {
            
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell?.backgroundColor = UIColor.clear
            cell?.contentView.backgroundColor = UIColor.clear
            cell?.selectionStyle = .none
            cell?.layoutMargins = UIEdgeInsets.zero
            cell?.changeFrameWidth(width: (self.tableView?.bounds.size.width)!)
            if indexPath.row > modulesListArray.count - 1{
                return cell!
            }
            let module:Any = modulesListArray[indexPath.row] as Any
            var moduleId:String?
            //Move this to view model.
            if module is SFTrayObject {
                let trayObject:SFTrayObject? = module as? SFTrayObject
                moduleId = trayObject?.trayId
            }
            else if module is SFJumbotronObject{
                let jumbotronObject:SFJumbotronObject? = module as? SFJumbotronObject
                moduleId = jumbotronObject?.trayId
            }
            else if module is SFVideoDetailModuleObject{
                let videoDetailModuleObject:SFVideoDetailModuleObject? = module as? SFVideoDetailModuleObject
                moduleId = videoDetailModuleObject?.moduleID
            }
            else if module is SFShowDetailModuleObject{
                let showDetailModuleObject:SFShowDetailModuleObject? = module as? SFShowDetailModuleObject
                moduleId = showDetailModuleObject?.moduleID
            }
            else if module is SFWatchlistAndHistoryViewObject{
                let moduleObject:SFWatchlistAndHistoryViewObject? = module as? SFWatchlistAndHistoryViewObject
                moduleId = moduleObject?.moduleID
            }

            else if module is SFSubNavigationViewObject{
                let moduleObject:SFSubNavigationViewObject? = module as? SFSubNavigationViewObject
                moduleId = moduleObject?.moduleID
            }
            else if module is SFRawTextViewObject{
                let moduleObject:SFRawTextViewObject? = module as? SFRawTextViewObject
                moduleId = moduleObject?.moduleID
            }
            else if module is VideoPlayerModuleViewObject {
                let moduleObject:VideoPlayerModuleViewObject? = module as? VideoPlayerModuleViewObject
                moduleId = moduleObject?.moduleID
            }
            
            let pageAPIModuleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(moduleId ?? "")"] as? SFModuleObject
            
            if module is SFTrayObject && pageAPIModuleObject != nil {

                let trayObject:SFTrayObject = modulesListDict["\(pageAPIModuleObject!.moduleId ?? "")"] as! SFTrayObject
                let collectionGridViewController = collectionGridHandlerViewModel.getCollectionGrid(parentViewFrame: (cell?.frame)!, pageModuleObject: pageAPIModuleObject!, trayObject: trayObject)
                //Remembering the last focused cell.
                if viewModel.pageOpenAction == .videoClickAction {
                    collectionGridViewController.collectionGrid?.remembersLastFocusedIndexPath = true
                }
                self.addChildViewController(collectionGridViewController)
                cell?.addSubview(collectionGridViewController.view)
            }
            else if module is SFJumbotronObject && pageAPIModuleObject != nil {

                let jumbotronObject:SFJumbotronObject? = modulesListDict["\(pageAPIModuleObject!.moduleId ?? "")"] as? SFJumbotronObject
                let carouselViewController = carouselHandlerViewModel.getCarouselView(parentViewFrame: (cell?.frame)!, pageModuleObject: pageAPIModuleObject!, jumbotronObject: jumbotronObject!)
                self.addChildViewController(carouselViewController)
                cell?.addSubview(carouselViewController.view)
            }
            else if module is SFVideoDetailModuleObject && pageAPIModuleObject != nil
            {
                let videoDetailObject:SFVideoDetailModuleObject = modulesListDict["\(pageAPIModuleObject!.moduleId ?? "")"] as!SFVideoDetailModuleObject
                let videoDetailModule = videoDetailHandlerViewModel.getVideoDetail(parentViewFrame: (cell?.frame)!, pageModuleObject: pageAPIModuleObject!, videoDetailObject: videoDetailObject, gridObject: gridObject)
                cell?.addSubview(videoDetailModule.view)
                self.addChildViewController(videoDetailModule)
            }
            else if module is SFShowDetailModuleObject && pageAPIModuleObject != nil
            {
                let showDetailObject:SFShowDetailModuleObject = modulesListDict["\(pageAPIModuleObject!.moduleId ?? "")"] as!SFShowDetailModuleObject
                let showDetailModule = showDetailHandlerViewModel.getShowDetail(parentViewFrame: (cell?.frame)!, pageModuleObject: pageAPIModuleObject!, showDetailObject: showDetailObject)
                cell?.addSubview(showDetailModule.view)
                self.addChildViewController(showDetailModule)
            }
            else if module is LoginViewObject_tvOS
            {
                let loginObject = module as! LoginViewObject_tvOS
                loginObject.moduleTitle = pageDisplayName
                cell?.changeFrameHeight(height: CGFloat(Utility.fetchLoginViewLayoutDetails(loginViewObject: loginObject).height ?? 880))
                let loginViewModule = loginViewHandlerViewModel.getLoginView(parentViewFrame: (cell?.frame)!, loginObject: loginObject)
                cell?.addSubview(loginViewModule.view)
                //Update View frame as per presentation type
                if viewModel.pageOpenAction == nil {
                    loginViewModule.view.changeFrameYAxis(yAxis: 140)
                }
                else if viewModel.pageOpenAction != .subNavigationClickAction {
                        loginViewModule.view.changeFrameYAxis(yAxis: 140)
                    }
                
                self.addChildViewController(loginViewModule)
                cell?.backgroundColor = UIColor.clear
                cell?.contentView.backgroundColor = UIColor.clear
            }
            else if module is SFWatchlistAndHistoryViewObject
            {
                let viewModuleObject:SFWatchlistAndHistoryViewObject = modulesListDict[moduleId!] as!SFWatchlistAndHistoryViewObject
                let viewModule = watchlistHistoryViewHandler.getModuleView(parentViewFrame: (cell?.frame)!, watchListObject: viewModuleObject)
                cell?.addSubview(viewModule.view)
                self.addChildViewController(viewModule)
                self.tableView?.isScrollEnabled = false
            }
                
            else if module is SFSubNavigationViewObject
            {
               let viewModuleObject:SFSubNavigationViewObject = modulesListDict[moduleId!] as!SFSubNavigationViewObject
                let viewModule = teamsViewHandler.getModuleView(parentViewFrame: (cell?.frame)!, teamObject: viewModuleObject, pageName: pageDisplayName ?? "")
                cell?.addSubview(viewModule.view)
                self.addChildViewController(viewModule)
                self.tableView?.isScrollEnabled = false
                
            }
            else if module is AncillaryViewObject_tvOS
            {

                let ancillaryViewModule = ancillaryViewHandlerViewModel.getAncillaryView(parentViewFrame: (cell?.frame)!, ancillaryObject: module as! AncillaryViewObject_tvOS)
                cell?.addSubview(ancillaryViewModule.view)
                self.addChildViewController(ancillaryViewModule)
                cell?.backgroundColor = UIColor.clear
                cell?.contentView.backgroundColor = UIColor.clear
                if let path = self.pagePath {
                    ancillaryViewHandlerViewModel.pageType = path
                    ancillaryViewHandlerViewModel.shouldUseCacheUrl = self.viewControllerPage?.shouldUseCacheAPI
                    ancillaryViewHandlerViewModel.loadAncillaryPageData()
                }
                
            }
            else if module is SettingViewObject_tvOS
            {
                let settingViewModule = settingViewHandler.getSettingView(parentViewFrame: (cell?.frame)!, settingObject: module as! SettingViewObject_tvOS, pageObject: viewControllerPage!)
                self.addChildViewController(settingViewModule)
                cell?.addSubview(settingViewModule.view)
                cell?.backgroundColor = UIColor.clear
                cell?.contentView.backgroundColor = UIColor.clear
            }
            else if module is ContactUsViewObject_tvOS
            {
                let contactUsViewModule = contactUsViewHandler.getContactUsView(parentViewFrame: (cell?.frame)!, contactUsObject: module as! ContactUsViewObject_tvOS)
                cell?.addSubview(contactUsViewModule)
                cell?.backgroundColor = UIColor.clear
                cell?.contentView.backgroundColor = UIColor.clear
            }
                
            else if module is SubscriptionViewObject_tvOS
            {
                let subscriptionViewModule = subscriptionViewHandler.getSubscriptionView(parentViewFrame: (cell?.frame)!, subscriptionObject: module as! SubscriptionViewObject_tvOS)
                cell?.addSubview(subscriptionViewModule.view)
                self.addChildViewController(subscriptionViewModule)
                cell?.backgroundColor = UIColor.clear
                cell?.contentView.backgroundColor = UIColor.clear
            }
            else if module is VideoPlayerModuleViewObject {
                let viewModuleObject:VideoPlayerModuleViewObject = modulesListDict[moduleId!] as!VideoPlayerModuleViewObject
                if let _pageAPIModuleObject = pageAPIModuleObject {
                    let viewModule = videopPlayerHandlerViewModel.getVideoPlayerModule(parentViewFrame: (cell?.frame)!, viewObject: viewModuleObject, pageAPIModuleObject: _pageAPIModuleObject)
                    cell?.addSubview(viewModule.view)
                    self.addChildViewController(viewModule)
                    cell?.tag = 404
                }
            }
            else if module is SFRawTextViewObject
            {
                let rawTextViewModule = rawTextViewHandler.getRawTextView(parentViewFrame: (cell?.frame)!, pageModuleObject: pageAPIModuleObject!, rawTextObject: module as! SFRawTextViewObject)
                cell?.addSubview(rawTextViewModule)
                cell?.backgroundColor = UIColor.clear
                cell?.contentView.backgroundColor = UIColor.clear
            }
            
            //Adding it to cellModuleDict
            cellModuleDict["\(String(indexPath.row))"] = cell!
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 170.0
        if indexPath.row > modulesListArray.count - 1{
            return 0
        }
        
        let module:Any = modulesListArray[indexPath.row] as Any

        if module is SFTrayObject {
            let trayObject:SFTrayObject? = module as? SFTrayObject
            rowHeight = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject!).height ?? 170)

            if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
                let component = trayObject?.trayComponents.filter() {$0 is SFCollectionGridObject}
                if component != nil && (component?.count)! > 0 {
                    let collectionGridObject = component![0] as? SFCollectionGridObject
                    let pageAPIModuleObject:SFModuleObject? = self.pageAPIObject?.pageModules?["\(trayObject?.trayId ?? "")"] as? SFModuleObject
                    if pageAPIModuleObject != nil {
                        rowHeight = Utility.sharedUtility.getCollectionViewHeightForSportsTemplate(rowHeight: rowHeight, gridObject: collectionGridObject!, pageAPIModuleObject: pageAPIModuleObject!)
                    }
                }
            }
            
            //Detecting last row, increasing height for footer.
            if indexPath.row == modulesListArray.count - 1 {
                if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment {
                    rowHeight = rowHeight + 200 // Makes this dynamic.
                } else {
                    rowHeight = rowHeight + 10
                }
            }
        }
        else if module is SFJumbotronObject {
            
            let jumbotronObject:SFJumbotronObject? = module as? SFJumbotronObject
            rowHeight = CGFloat(Utility.fetchCarouselLayoutDetails(carouselViewObject: jumbotronObject!).height ?? 400)
        }
        else if module is SFVideoDetailModuleObject
        {
            let videoViewObject:SFVideoDetailModuleObject? = module as? SFVideoDetailModuleObject
            rowHeight = CGFloat(Utility.fetchVideoDetailLayoutDetails(videoDetailObject: videoViewObject!).height ?? 350)
        }
        else if module is LoginViewObject_tvOS
        {
            let viewObject:LoginViewObject_tvOS? = module as? LoginViewObject_tvOS
            rowHeight = CGFloat(Utility.fetchLoginViewLayoutDetails(loginViewObject: viewObject!).height ?? 880)
        }
        else if module is ContactUsViewObject_tvOS
        {
            let viewObject:ContactUsViewObject_tvOS? = module as? ContactUsViewObject_tvOS
            rowHeight = CGFloat(Utility.fetchContactUsViewLayoutDetails(ContactUsViewObject:viewObject!).height ?? 880)
        }
        else if module is SubscriptionViewObject_tvOS
        {
            let viewObject:SubscriptionViewObject_tvOS? = module as? SubscriptionViewObject_tvOS
            rowHeight = CGFloat(Utility.fetchSubscriptionViewLayoutDetails(SubscriptionViewObject: viewObject!).height ?? 1100)
        }
        else if module is SFWatchlistAndHistoryViewObject
        {
            let viewObject:SFWatchlistAndHistoryViewObject? = module as? SFWatchlistAndHistoryViewObject
            rowHeight = CGFloat(Utility.fetchWatchlistLayoutDetails(watchListObject: viewObject!).height ?? 940)
        }
        else if module is SFSubNavigationViewObject
        {
            let viewObject:SFSubNavigationViewObject? = module as? SFSubNavigationViewObject
            rowHeight = CGFloat(Utility.fetchSubMenuLayoutDetails(teamObject: viewObject!).height ?? 940)
        }
        else if module is SettingViewObject_tvOS
        {
            let viewObject:SettingViewObject_tvOS? = module as? SettingViewObject_tvOS
            rowHeight = CGFloat(Utility.fetchSettingsViewLayoutDetails(settingViewObject: viewObject!).height ?? 940)
        }
        else if module is VideoPlayerModuleViewObject {
            let viewObject:VideoPlayerModuleViewObject? = module as? VideoPlayerModuleViewObject
            rowHeight = CGFloat(Utility.fetchVideoPlayerViewLayoutDetails(viewObject: viewObject!).height ?? 1080)
        }
        else if module is SFShowDetailModuleObject
        {
            let showViewObject:SFShowDetailModuleObject? = module as? SFShowDetailModuleObject
            var moduleHeight = CGFloat(Utility.fetchShowDetailLayoutDetails(showDetailObject: showViewObject!).height ?? 350)
            let arrayOfTrayObjects = showViewObject?.showDetailModuleComponents?.filter() {$0 is SFTrayObject}
            if let _arrayOfTrayObjects = arrayOfTrayObjects {
                if _arrayOfTrayObjects.count > 0{
                    let trayObject = _arrayOfTrayObjects[0]
                    let pageModuleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(showViewObject?.moduleID ?? "")"] as? SFModuleObject
                    let show : SFShow = pageModuleObject!.moduleData![0] as! SFShow
                    if let seasonsArray =  show.seasons {
                        if seasonsArray.count > 0{
                            let collectionViewFrameHeight: CGFloat = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject as! SFTrayObject).height!)
                            moduleHeight = moduleHeight + ((CGFloat)(seasonsArray.count) * (collectionViewFrameHeight))
                        }
                    }
                }
            }
            rowHeight = moduleHeight
        }
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: ModuleViewModel delegates
    
    func popCurrentViewController() {
        if navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func scrollToNextFocusableItem() {
        DispatchQueue.main.async {
            if self.modulesListArray.count > 1 {
                let indexPath = IndexPath(row: 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    func launchAccountPage(accountPage: UIViewController) {
        self.navigationController?.pushViewController(accountPage, animated: true)
    }
    
    func launchVideoPlayer(video: VideoObject) {
        fireNotificationToDisableMenuController()
        let playerControllerVC =  PlayerViewController_tvOS.init(videoObject: video)
        self.navigationController?.pushViewController(playerControllerVC, animated: true)
    }
    
    func launchVideoPlayerForEpisodicContent(video: VideoObject, nextEpisodesArray:Array<String>?) {
        fireNotificationToDisableMenuController()
        let playerControllerVC =  PlayerViewController_tvOS.init(videoObject: video)
        playerControllerVC.relatedFilmIds = nextEpisodesArray
        self.navigationController?.pushViewController(playerControllerVC, animated: true)
    }
    
    func launchVideoDetailPage(videoDetailPage: ModuleContainerViewController_tvOS) {
        fireNotificationToDisableMenuController()
        videoDetailPage.addBackgroundImage = true
        self.navigationController?.pushViewController(videoDetailPage, animated: true)
    }
    
    func launchTeamDetailPage(teamDetailPage: ModuleContainerViewController_tvOS) {
        fireNotificationToDisableMenuController()
        teamDetailPage.addBackgroundImage = true
        self.navigationController?.pushViewController(teamDetailPage, animated: true)
    }
    
    private func fireNotificationToEnableMenuController() {
        let userInfo = [ "value" : true ]
        NotificationCenter.default.post(name: Constants.kToggleMenuBarInteractionNotification, object: nil , userInfo : userInfo )
    }
    
    private func fireNotificationToDisableMenuController() {
        //Fire Notification to disable the menu controller.
        let userInfo = [ "value" : false ]
        NotificationCenter.default.post(name: Constants.kToggleMenuBarInteractionNotification, object: nil , userInfo : userInfo )
    }
    
    func launchTrailerPlayer(trailerURL: String) {
        loadVideoPlayer(videoURLString:trailerURL)
    }
    
    func showPopOverController(controller: SFPopOverController) {
        controller.blurTheParentView(view: self.view)
        self.present(controller, animated: true, completion:{ () in })
    }
    
    func updateBackgroundView(film: SFFilm, isFocused: Bool) {
        backGroundImageView?.film = film
        backGroundImageView?.showHideImageView(shouldShow: isFocused)
    }
    func updateBackgroundViewForShowObject(show: SFShow,isFocused: Bool){
        backGroundImageView?.show = show
        backGroundImageView?.showHideImageView(shouldShow: isFocused)
    }
    
    func showAlertController(alertController: UIAlertController) {
        present(alertController, animated: true) { 
            
        }
    }
    
    func forgotPasswordButtonTapped(forgotCredentialVC: ModuleContainerViewController_tvOS) {
        if navigationController != nil {
            self.navigationController?.pushViewController(forgotCredentialVC, animated: true)
        } else {
            self.present(forgotCredentialVC, animated: true, completion: nil)
        }
    }

    func loadAncillaryPageData(ancillaryVC: ModuleContainerViewController_tvOS) {
        ancillaryVC.modalPresentationStyle = .overCurrentContext
        self.present(ancillaryVC, animated: true)
    }
    
    //MARK: Load VideoPlayer
    func loadVideoPlayer(videoURLString:String) {
        if isDeviceConnectedToInternet() {
            showActivityIndicator()
            let encodedURLString = Utility.urlEncodedString_ch(emailStr: videoURLString)
            guard let url = URL(string: encodedURLString) else {
                return
            }
            let playerItem = AVPlayerItem(url: url)
            let videoPlayer = AVPlayer(playerItem: playerItem)
            videoPlayerController = AVPlayerViewController()
            videoPlayerController?.player = videoPlayer
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayerController?.player?.currentItem)
            self.present(videoPlayerController!, animated: true) {
                self.hideActivityIndicator()
                self.videoPlayerController?.player?.play()
            }
        } else {
            trailerURL = videoURLString
            showAlertForTrailerPlaybackForFimTrailerUrl(videoURLString)
        }
    }
    
    private func showAlertForTrailerPlaybackForFimTrailerUrl(_ trailerURL: String) {
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            self.loadVideoPlayer(videoURLString: trailerURL)
        }
        
        var alertTitleString:String?
        var alertMessage:String?
        alertTitleString = Constants.kInternetConnection
        alertMessage = Constants.kInternetConntectionRefresh
        
        trailerUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction,retryAction])
        self.present(trailerUnavailableAlert!, animated: true, completion: {
        })
    }
    
    @objc func checkTrailerAlertIsShowing() {
        if self.checkIfTrailerAlertIsShowing()! && self.trailerURL != nil {
            trailerUnavailableAlert?.dismiss(animated: true, completion: {
                self.loadVideoPlayer(videoURLString: self.trailerURL!)
            })
        }
    }
    
    private func checkIfTrailerAlertIsShowing() -> Bool? {
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            if topController == trailerUnavailableAlert {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    private func createFooterView(footerViewObject:SFFooterViewObject) {
        
        let footerLayout = Utility.fetchFooterLayoutDetails(footerObject: footerViewObject)
        if footerView == nil {
            footerView = SFFooterView(frame: CGRect.zero)
            footerView?.viewObject = footerViewObject
            footerView?.viewlayout = footerLayout
            footerView?.relativeViewFrame = self.view.frame
            footerView?.initialiseFooterViewFrameFromLayout(footerViewLayout: footerLayout)
            footerView?.createFooterView()
        }
        let margin:CGFloat = isSubContainer ? 140 : 0
        footerView?.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - (200 + margin), width: self.view.bounds.width, height: 200)

        self.view.addSubview(footerView!)
    }
    
    //MARK: Player Delegate
    func playerDidFinishPlaying(notification:Notification) {
        
        videoPlayerController?.dismiss(animated: false, completion: {})
    }
    
    private func doesPageHaveDataForModules() -> Bool {
        if viewControllerPage != nil && viewControllerPage?.modules != nil && (viewControllerPage?.modules.count)! > 0 {
            if ((viewControllerPage?.modules[0] is LoginViewObject_tvOS) == true || (((viewControllerPage?.modules.filter() {$0 is SubscriptionViewObject_tvOS})?.count)! > 0) || (viewControllerPage?.modules[0] is AncillaryViewObject_tvOS) == true) || (viewControllerPage?.modules[0] is SFWatchlistAndHistoryViewObject) ||
                (viewControllerPage?.modules[0] is SFSubNavigationViewObject) || (viewControllerPage?.modules[0] is SettingViewObject_tvOS || (viewControllerPage?.modules[0] is ContactUsViewObject_tvOS)) {
                return false
            }
            return true
        }
        return false
    }

    private func addFooterViewToTheView() {
        //Un-comment when correct responses are received from the server.
        for module:Any in (viewControllerPage?.modules)! {
            if module is SFFooterViewObject {
                createFooterView(footerViewObject: module as! SFFooterViewObject)
            }
        }
    }
    
    func ignoreMenu(presses: Set<NSObject>) -> Bool {
        return (presses.first! as! UIPress).type == .menu
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if self.ignoreMenu(presses: presses) {
            super.pressesBegan(presses, with: event)
        }
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if lastFocusedView != nil {
            let lastFocusedViewLocalCopy = lastFocusedView as? UIView
            lastFocusedView = nil
            return [lastFocusedViewLocalCopy!]
        }
        return super.preferredFocusEnvironments
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        //Workaround to make table scroll to the top when previewendcardfocused.
        if let nextFocusView = context.nextFocusedView as? UIButton {
            if nextFocusView.tag == 9876 && self.isShowing() && self.tableView?.contentOffset.y != 0 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.tableView?.setContentOffset(CGPoint(x:0,y:0), animated: false)
                })
            }
        }
    }
}
