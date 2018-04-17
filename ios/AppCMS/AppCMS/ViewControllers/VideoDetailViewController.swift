//
//  VideoDetailViewController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 22/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import GoogleCast
import Firebase
class VideoDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,CollectionGridViewDelegate, VideoPlaybackDelegate, AVPlayerViewControllerDelegate, GCKUIMiniMediaControlsViewControllerDelegate, SFMorePopUpViewControllerDelegate, SFBannerViewDelegate,SFKisweBaseViewControllerDelegate,MoreButtonDelegate {
    
    enum CompeletionHandlerOptions {
        
        case UpdateWatchlist
        case UpdateVideoPlay
    }
    
    enum PageType
    {
        case videoDetail
        case showDetail
    }

    var isNavControllerCreated:Bool = false
    var viewControllerPage: Page?
    var tableView:UITableView?
    var modulesListDict:Dictionary<String, Any> = [:]
    var pageAPIObject:PageAPIObject?
    var progressIndicator:MBProgressHUD?
    var contentId:String?
    var pagePath:String?
    var modulesListArray:Array<Any> = []
    var filmIdArray:Array<Any>=[]
    var videoPlayerController:AVPlayerViewController?
    var shareActivityViewController:UIActivityViewController?
    var videoDescriptionView:VideoDescriptionView?
    var showDescriptionView: VideoDescriptionView?
    var isViewDismissAnimationStarted:Bool = false
    var alertType:AlertType?
    var networkUnavailableAlert:UIAlertController?
    var cellModuleDict:Dictionary<String, AnyObject> = [:]
    var failureAlertType:PageLoadAfterFailureAlert?
    var watchlistStatusUpdateLabel:UILabel?
    var _miniMediaControlsContainerView: UIView!
    var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    private var isRelatedVideoClicked:Bool = false
    var detailPageType: PageType
    var nextEpisodesArray:Array<String>?
    var isContentFetched:Bool = false
    private var showObject:SFShow?
    private var filmObject:SFFilm?
    private var gridObject:SFGridObject?
    private var isTableHeaderAvailable:Bool = false
    private var tableHeaderView:UIView?
    private var bannerViewObject:SFBannerViewObject?
    private var selectedSeason:Int = 0
    private var showRowId:Int = 0
    var isVideoPlaying: Bool = false
    private var isVideoPlayingInFullScreen:Bool = false
    private var videoDuration:Double?
    
    init (viewControllerPage:Page, pageType: PageType) {
        
        self.viewControllerPage = viewControllerPage
        self.detailPageType = pageType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserLoginStatusFlag), name: NSNotification.Name(rawValue: "UserLoggedInStatusUpdated"), object: nil)
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        self.addMiniCastControllerToViewController(viewController: self)
        
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased(){
            
            self.automaticallyAdjustsScrollViewInsets = true
            self.edgesForExtendedLayout = []
        }
        createTableView()
        // Do any additional setup after loading the view.
        
    }

    func updateUserLoginStatusFlag() {
        self.tableView?.scrollsToTop = true
        self.tableView?.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateControlBarsVisibility()
        loadPageData()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
            createNavigationBar()
        }
    }
    
    //MARK: Creation of navigation bar
    func createNavigationBar() {
        
        if isNavControllerCreated {
            
            self.navigationController?.navigationBar.barTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        }
         self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.titleView = Utility.createNavigationTitleView(navBarHeight: (self.navigationController?.navigationBar.frame.size.height)!)
        createLeftNavItems()
        createRightNavBarItems()
    }
    
    private func createRightNavBarItems() {
        
        self.navigationItem.rightBarButtonItems = nil
        self.createRightNavItemsForPage()
    }
    
    
    //MARK: Creation of left nav items for sports template
    private func createLeftNavItems() {
        
        self.navigationItem.leftBarButtonItems = nil
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15
        
        let backButton = UIButton(type: .custom)
        backButton.sizeToFit()
        let backButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "Back.png"))
        
        backButton.setImage(backButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        
        backButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (backButtonImageView.image?.size.height)!/2)
        backButton.addTarget(self, action: #selector(backButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        
        let backButtonItem = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItems = [negativeSpacer, backButtonItem]
    }
    
    
    func shareButtonClicked(sender:AnyObject) {
        
        shareButtonTapped(button: nil, filmObject: filmObject, showObject: showObject,shareButton: sender as? UIButton)
    }
    
    func backButtonClicked(sender:AnyObject) {
        
        NotificationCenter.default.removeObserver(self)
        
        if self.videoDescriptionView?.iOSVideoPlayer != nil {
         
            self.videoDescriptionView?.iOSVideoPlayer?.view.removeFromSuperview()
            self.videoDescriptionView?.iOSVideoPlayer?.removeFromParentViewController()
        }
        

        Constants.kAPPDELEGATE.isFullScreenEnabled = false
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
            
            if isNavControllerCreated {
                
                self.dismiss(animated: true, completion: {
                
                    Constants.kAPPDELEGATE.isFullScreenEnabled = false
                })
            }
            else {
                
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    //MARK: Creation of right nav items for sports template
    private func createRightNavItemsForPage() {
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15
        
        var righBarItems:Array<UIBarButtonItem> = [negativeSpacer]
        
        let searchButton = UIButton(type: .custom)
        searchButton.sizeToFit()
        let searchButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "icon-search.png"))
        
        searchButton.setImage(searchButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        searchButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        
        searchButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (searchButtonImageView.image?.size.height)!/2)
        searchButton.addTarget(self, action: #selector(searchButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        
        let searchButtonItem = UIBarButtonItem(customView: searchButton)
        righBarItems.append(searchButtonItem)
        
        let shareButton = UIButton(type: .custom)
        shareButton.sizeToFit()
        let shareButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "shareIcon.png"))
        
        shareButton.setImage(shareButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        shareButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        
        shareButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (shareButtonImageView.image?.size.height)!/2)
        shareButton.addTarget(self, action: #selector(shareButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        
        let shareButtonItem = UIBarButtonItem(customView: shareButton)
        righBarItems.append(shareButtonItem)

        self.navigationItem.rightBarButtonItems = righBarItems
    }
    
    func searchButtonClicked(sender: AnyObject) {
        
        let searchViewController: SearchViewController = SearchViewController()
        searchViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        searchViewController.shouldDisplayBackButtonOnNavBar = true

        if let topController = Utility.sharedUtility.topViewController() {
            
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                
                topController.navigationController?.pushViewController(searchViewController, animated: true)
            }
            else {
                
                topController.present(searchViewController, animated: true, completion: {
                    
                })
            }
        }
    }
    
    
    // MARK: - Internal methods
    func updateControlBarsVisibility() {
        
        if (self.miniMediaControlsViewController != nil) {
            
            var variance:CGFloat = 0
            if (Constants.IPHONE && Utility.sharedUtility.isIphoneX()){
                variance = 20;
            }
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                
                _miniMediaControlsContainerView.frame = CGRect(x: 0, y: self.view.frame.size.height - 64.0, width: UIScreen.main.bounds.width, height: 0)
            }
            else {
                
                _miniMediaControlsContainerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - (64), width: UIScreen.main.bounds.width, height: 0)
            }
            
            if self.miniMediaControlsViewController.active && CastPopOverView.shared.isConnected() {
                
                _miniMediaControlsContainerView.changeFrameHeight(height: 64)
                self.view.bringSubview(toFront: _miniMediaControlsContainerView)
                
                if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                    
                    tableView?.changeFrameHeight(height: self.view.bounds.size.height - 64.0)
                }
                else {
                    
                    tableView?.changeFrameHeight(height: UIScreen.main.bounds.size.height - 84.0)
                }
            } else {
                
                _miniMediaControlsContainerView.changeFrameHeight(height: 0)
                
                if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                    
                    tableView?.changeFrameHeight(height: self.view.bounds.size.height)
                    
                }
                else {
                    tableView?.changeFrameHeight(height: UIScreen.main.bounds.size.height - 20)
                }
            }
        }
        
    }
    
    // MARK: - GCKUIMiniMediaControlsViewControllerDelegate
    func miniMediaControlsViewController(_ miniMediaControlsViewController: GCKUIMiniMediaControlsViewController,
                                         shouldAppear: Bool) {
        self.updateControlBarsVisibility()
        
    }
    
    func addMiniCastControllerToViewController(viewController: UIViewController){
        // Do any additional setup after loading the view.
        
        _miniMediaControlsContainerView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - (64), width: UIScreen.main.bounds.width, height: 0))
        
        viewController.view.addSubview(_miniMediaControlsContainerView)
        
        self.miniMediaControlsViewController = GCKCastContext.sharedInstance().createMiniMediaControlsViewController()
        self.miniMediaControlsViewController.delegate = self
        self.miniMediaControlsViewController.view.frame = _miniMediaControlsContainerView.bounds
        _miniMediaControlsContainerView.addSubview(self.miniMediaControlsViewController.view)
        
        self.updateControlBarsVisibility()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Method to fetch page module layout list
    func createPageModuleLayoutList() {
        
        if viewControllerPage?.modules != nil {
            
            for module:Any in (viewControllerPage?.modules)! {
                
                if module is SFTrayObject {
                    
                    let trayObject:SFTrayObject = module as! SFTrayObject
                    
                    if checkIfModuleComingInServerResponse(moduleId: trayObject.trayId) {
                        
                        modulesListDict["\(trayObject.trayId!)"] = trayObject
                        modulesListArray.append(trayObject)
                    }
                }
                else if module is SFVideoDetailModuleObject
                {
                    let videoDetailObject:SFVideoDetailModuleObject = module as! SFVideoDetailModuleObject
                    
                    if checkIfModuleComingInServerResponse(moduleId: videoDetailObject.moduleID) {
                        
                        modulesListDict["\(videoDetailObject.moduleID!)"] = videoDetailObject
                        modulesListArray.append(videoDetailObject)
                    }
                }
                else if module is SFShowDetailModuleObject
                {
                    let showDetailObject:SFShowDetailModuleObject = module as! SFShowDetailModuleObject
                    if checkIfModuleComingInServerResponse(moduleId: showDetailObject.moduleID) {
                        
                        modulesListDict["\(showDetailObject.moduleID!)"] = showDetailObject
                        modulesListArray.append(showDetailObject)
                    }
                }
                else if module is SFArticleDetailObject
                {
                    let videoDetailObject:SFArticleDetailObject = module as! SFArticleDetailObject
                    
                    if checkIfModuleComingInServerResponse(moduleId: videoDetailObject.moduleID) {
                        
                        modulesListDict["\(videoDetailObject.moduleID!)"] = videoDetailObject
                        modulesListArray.append(videoDetailObject)
                    }
                   
                }
                else if module is SFBannerViewObject {
                    
                    self.bannerViewObject = module as? SFBannerViewObject
                    self.isTableHeaderAvailable = true
                }
            }
        }
    }
    
    
    func checkIfModuleComingInServerResponse(moduleId:String?) -> Bool {
        
        let pageAPIModuleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(moduleId ?? "")"] as? SFModuleObject
        
        if pageAPIModuleObject != nil {
            
            return true
        }
        
        return false
    }

    //MARK: Load Page Data
    func loadPageData() {
        
        if pageAPIObject == nil {
            self.fetchPageContent()
        }
    }
    
    //MARK: Method to fetch page content
    func fetchPageContent() {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            showAlertForAlertType(alertType: .AlertTypeNoInternetFound, isAlertForVideoDetailAPI: true, contentId: nil, alertTitle: nil, alertMessage: nil)
        }
        else {
            
            showActivityIndicator(loaderText: "Loading...")
            
            var apiEndPoint:String? = "/content/pages?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&includeContent=true"
            
            if pagePath != nil {
                
                apiEndPoint = "\(apiEndPoint ?? "")&path=\(pagePath ?? "")"
            }
            else if contentId != nil {
                apiEndPoint = "\(apiEndPoint ?? "")&pageId=\(contentId ?? "")"
                
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                DataManger.sharedInstance.fetchContentForVideoPage(shouldUseCacheUrl: self.viewControllerPage?.shouldUseCacheAPI ?? false, apiEndPoint: apiEndPoint!) { (pageAPIObjectResponse, errorMessage, isSuccess) in
                    
                    DispatchQueue.main.async {
                        
                        self.hideActivityIndicator()
                        
                        if pageAPIObjectResponse != nil && pageAPIObjectResponse?.pageModules != nil  && isSuccess == true{
                            
                            if self.isRelatedVideoClicked {
                                
                                self.modulesListDict.removeAll()
                                self.pageAPIObject = nil
                                self.modulesListArray.removeAll()
                                self.isRelatedVideoClicked = false
                            }
                            
                            self.isContentFetched = true
                            self.pageAPIObject = pageAPIObjectResponse
                            self.cellModuleDict.removeAll()
                            self.createPageModuleLayoutList()
                            self.tableView?.isHidden = false

                            if !self.isVideoPlayingInFullScreen {
                            
                                self.tableView?.reloadData()
                                
                                if self.tableView?.indexPathsForVisibleRows != nil {
                                    
                                    self.tableView?.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
                                }
                                else {
                                    
                                    self.tableView?.scrollsToTop = true
                                }
                                
                                self.tableView?.setContentOffset(CGPoint.zero, animated: false)
                            }
                        }
                        else {
                            
                            if errorMessage != nil {
                                
                                self.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived, isAlertForVideoDetailAPI: true, contentId: nil, alertTitle: "", alertMessage: errorMessage!)
                            }
                            else {
                             
                                self.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived, isAlertForVideoDetailAPI: true, contentId: nil, alertTitle: nil, alertMessage: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: Method to create table view
    func createTableView() {

        //frame adjustment to fix status bar issue
        tableView = UITableView(frame: CGRect(x: 0, y: Utility.sharedUtility.getPosition(position: 20), width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - Utility.sharedUtility.getPosition(position: 20)), style: .plain)
       
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
            
            tableView?.changeFrameYAxis(yAxis: 0)
            tableView?.changeFrameHeight(height: UIScreen.main.bounds.size.height)
        }

        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
        tableView?.backgroundView = nil
        tableView?.backgroundColor = UIColor.clear
        tableView?.showsVerticalScrollIndicator = false
    
        self.view.addSubview(tableView!)
        self.tableView?.isHidden = true
    }
    
    
    //MARK: Table View Delegates
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if self.isTableHeaderAvailable && self.bannerViewObject != nil {
            
            let headerView = UIView.init()
            headerView.backgroundColor = .clear
            headerView.autoresizingMask = [.flexibleWidth]
            var minYAxis:CGFloat = 0
            
            if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() && !Utility.sharedUtility.checkIfUserIsLoggedIn() {
                
                if let subscribeButton = self.createHeaderViewFrame() {
                    
                    headerView.addSubview(subscribeButton)
                    minYAxis += subscribeButton.frame.size.height + subscribeButton.frame.origin.y
                }
            }
            else if let isSubscribed = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool {
                
                if !isSubscribed {
                    
                    if let subscribeButton = self.createHeaderViewFrame() {
                        
                        headerView.addSubview(subscribeButton)
                        minYAxis += subscribeButton.frame.size.height + subscribeButton.frame.origin.y
                    }
                }
            }
            
            let bannerView = self.createBannerView(minYAxis: minYAxis)
            headerView.addSubview(bannerView)
            
            self.tableHeaderView = headerView
            return headerView
        }
        else if AppConfiguration.sharedAppConfiguration.pageHeaderObject != nil {
            
            let headerView = UIView.init()
            headerView.backgroundColor = .clear
            
            if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() && !Utility.sharedUtility.checkIfUserIsLoggedIn() {
                
                if let subscribeButton = self.createHeaderViewFrame() {
                    
                    headerView.addSubview(subscribeButton)
                }
            }
            else if let isSubscribed = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool {
                
                if !isSubscribed {
                    
                    if let subscribeButton = self.createHeaderViewFrame() {
                        
                        headerView.addSubview(subscribeButton)
                    }
                }
            }
            
            self.tableHeaderView = headerView
            return headerView
        }
        else {
            
            let tempView = UIView.init()
            tempView.backgroundColor = UIColor.clear
            
            self.tableHeaderView = nil
            return tempView
        }
    }
    
    
    //MARK: Method to create banner view
    private func createBannerView(minYAxis:CGFloat) -> SFBannerView {
        
        let bannerViewLayout = Utility.fetchBannerViewLayoutDetails(bannerViewObject: self.bannerViewObject!)
        let bannerViewFrame = Utility.initialiseViewLayout(viewLayout: bannerViewLayout, relativeViewFrame: (tableView?.frame)!)
        
        let bannerView = SFBannerView.init(frame: bannerViewFrame)
        bannerView.changeFrameYAxis(yAxis: minYAxis)
        bannerView.bannerViewObject = self.bannerViewObject
        bannerView.bannerViewDelegate = self
        bannerView.backgroundColor = Utility.hexStringToUIColor(hex: self.bannerViewObject?.bannerViewBackgroundColor ?? AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        bannerView.createSubView()
        
        return bannerView
    }
    
    
    //MARK: Method to create subscription header view
    private func createHeaderViewFrame() -> UIButton? {
        
        if let pageHeaderObject = AppConfiguration.sharedAppConfiguration.pageHeaderObject {
            
            if pageHeaderObject.placement != nil && pageHeaderObject.placement?.lowercased() == "Banner".lowercased() {
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: CGFloat(Constants.IPHONE ? 40 : 55))
                button.titleLabel?.font = UIFont(name: "Lato", size: Constants.IPHONE ? 13 * Utility.getBaseScreenHeightMultiplier() : 14)
                button.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000")
                button.contentVerticalAlignment = .center
                button.contentHorizontalAlignment = .center
                button.titleLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
                var buttonText = pageHeaderObject.buttonPrefixText
                
                if buttonText != nil {
                    
                    buttonText?.append(" ")
                }
                
                if pageHeaderObject.buttonText != nil {
                    
                    if buttonText != nil {
                        
                        buttonText?.append(pageHeaderObject.buttonText!)
                    }
                    else {
                        
                        buttonText = pageHeaderObject.buttonText
                    }
                }
                
                if buttonText != nil {
                    
                    let attributedButtonText = NSMutableAttributedString(string: buttonText!)
                    
                    if pageHeaderObject.buttonText != nil {
                        
                        attributedButtonText.addAttributes([NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue, NSUnderlineColorAttributeName : Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "fffff")], range: (buttonText! as NSString).range(of: pageHeaderObject.buttonText!))
                    }
                    
                    button.setAttributedTitle(attributedButtonText, for: .normal)
                    button.addTarget(self, action: #selector(pageHeaderButtonClicked), for: .touchUpInside)
                }
                
                return button
            }
            else {
                
                return nil
            }
        }
        else {
            
            return nil
        }
    }
    
    
    func pageHeaderButtonClicked() {
        
        self.displayPlanPageWithCompletionHandler { (isSuccessfullyLoggedIn) in
            
            if isSuccessfullyLoggedIn {
                self.tableView?.reloadData()
            }
        }
    }
    
    private func displayPlanPageWithCompletionHandler(completionHandler: @escaping ((_ isSuccessfullyLoggedIn: Bool) -> Void)) -> Void {
        
        let planViewController:SFProductListViewController = SFProductListViewController.init()
        planViewController.completionHandlerCopy = completionHandler
        let navigationController = UINavigationController.init(rootViewController: planViewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if self.isTableHeaderAvailable && self.bannerViewObject != nil {
            
            let bannerViewLayout = Utility.fetchBannerViewLayoutDetails(bannerViewObject: self.bannerViewObject!)
            let bannerViewFrame = Utility.initialiseViewLayout(viewLayout: bannerViewLayout, relativeViewFrame: tableView.frame)
            
            var headerHeight:CGFloat = bannerViewFrame.size.height
            
            if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() && !Utility.sharedUtility.checkIfUserIsLoggedIn() {
                
                if let pageHeaderObject = AppConfiguration.sharedAppConfiguration.pageHeaderObject {
                    
                    if pageHeaderObject.buttonText != nil && (pageHeaderObject.placement != nil && pageHeaderObject.placement?.lowercased() == "Banner".lowercased()) {
                        
                        headerHeight += CGFloat(Constants.IPHONE ? 40 : 55)
                    }
                }
            }
            else if let isSubscribed = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool {
                
                if !isSubscribed {
                    if let pageHeaderObject = AppConfiguration.sharedAppConfiguration.pageHeaderObject {
                        
                        if pageHeaderObject.buttonText != nil && (pageHeaderObject.placement != nil && pageHeaderObject.placement?.lowercased() == "Banner".lowercased()) {
                            
                            headerHeight = CGFloat(Constants.IPHONE ? 40 : 55)
                        }
                    }
                }
            }
            
            return headerHeight
        }
        else if AppConfiguration.sharedAppConfiguration.pageHeaderObject != nil {
            
            var headerHeight:CGFloat = 1.0
            
            if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() && !Utility.sharedUtility.checkIfUserIsLoggedIn() {
                
                if let pageHeaderObject = AppConfiguration.sharedAppConfiguration.pageHeaderObject {
                    
                    if pageHeaderObject.buttonText != nil && (pageHeaderObject.placement != nil && pageHeaderObject.placement?.lowercased() == "Banner".lowercased()) {
                        
                        headerHeight = CGFloat(Constants.IPHONE ? 40 : 55)
                    }
                }
            }
            else if let isSubscribed = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool {
                
                if !isSubscribed {
                    if let pageHeaderObject = AppConfiguration.sharedAppConfiguration.pageHeaderObject {
                        
                        if pageHeaderObject.buttonText != nil && (pageHeaderObject.placement != nil && pageHeaderObject.placement?.lowercased() == "Banner".lowercased()) {
                            
                            headerHeight = CGFloat(Constants.IPHONE ? 40 : 55)
                        }
                    }
                }
            }
            
            return headerHeight
        }
        else {
            
            return 1.0
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pageAPIObject?.pageModules?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier:String = "gridCell"
        var cell:UITableViewCell? = cellModuleDict["\(String(indexPath.row))"] as? UITableViewCell

        if cell == nil {
            
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
            cell?.contentView.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
            cell?.selectionStyle = .none
            
            cell?.selectionStyle = .none
            
            if indexPath.row > modulesListArray.count - 1 {
                
                return cell!
            }
            
            let module:AnyObject = modulesListArray[indexPath.row] as AnyObject
            var moduleId:String?
            
            if module is SFTrayObject {
                let trayObject:SFTrayObject? = module as? SFTrayObject
                moduleId = trayObject?.trayId
            }
            else if module is SFVideoDetailModuleObject{
                let videoDetailModuleObject:SFVideoDetailModuleObject? = module as? SFVideoDetailModuleObject
                moduleId = videoDetailModuleObject?.moduleID
            }
            else if module is SFShowDetailModuleObject{
                let showDetailModuleObject:SFShowDetailModuleObject? = module as? SFShowDetailModuleObject
                moduleId = showDetailModuleObject?.moduleID
            }
            else if module is SFArticleDetailObject{
                let articleDetailModuleObject:SFArticleDetailObject? = module as? SFArticleDetailObject
                moduleId = articleDetailModuleObject?.moduleID
            }
            
            let pageAPIModuleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(moduleId ?? "")"] as? SFModuleObject
            
            if module is SFTrayObject {
                addCollectionGridToTable(cell: cell!, pageModuleObject: pageAPIModuleObject!)
                cellModuleDict["\(String(indexPath.row))"] = cell!
            }
            else if module is SFVideoDetailModuleObject
            {
                let film:SFFilm = pageAPIModuleObject!.moduleData![0] as! SFFilm
                var pageTitle = "Video Screen - "
                pageTitle += film.title ?? ""
                
                if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                    
                    FIRAnalytics.setScreenName(pageTitle, screenClass: nil)
                }
                
                self.trackGAEvent(screenName: pageTitle)
//                if self.videoDescriptionView == nil
//                {
                    addVideoDetailToTable(cell: cell!, pageModuleObject: pageAPIModuleObject!)
//                }
//                else
//                {
//
//                }
                cellModuleDict["\(String(indexPath.row))"] = cell!
            }
            else if module is SFShowDetailModuleObject
            {
                let show:SFShow = pageAPIModuleObject!.moduleData![0] as! SFShow
                var pageTitle = "Show Screen - "
                pageTitle += show.showTitle ?? ""
                
                if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                    
                    FIRAnalytics.setScreenName(pageTitle, screenClass: nil)
                }
                
                self.trackGAEvent(screenName: pageTitle)
                addVideoDetailToTable(cell: cell!, pageModuleObject: pageAPIModuleObject!)
                cellModuleDict["\(String(indexPath.row))"] = cell!
                
                showRowId = indexPath.row
            }
            else if module is SFArticleDetailObject{
                let articleDetailObject:SFArticleDetailObject? = module as? SFArticleDetailObject
                moduleId = articleDetailObject?.moduleID
                addArticleToTable(cell: cell!, pageModuleObject: pageAPIModuleObject!)
                cellModuleDict["\(String(indexPath.row))"] = cell!
            }
        }
        
        return cell!
    }
    //MARK :- Add Article To Table
    private func addArticleToTable(cell:UITableViewCell, pageModuleObject:SFModuleObject) {
        let articleDetailObject : SFArticleDetailObject = (modulesListDict["\(pageModuleObject.moduleId ?? "")"] as?SFArticleDetailObject)!
        var moduleHeight : CGFloat = CGFloat(Utility.fetchArticleDetailLayoutDetails(articleDetailObject: articleDetailObject).height!)
        let moduleWidth: CGFloat = self.view.frame.width
        moduleHeight = moduleHeight * Utility.getBaseScreenHeightMultiplier()
        var articleDetailViewController:ArticleDetailViewController!
        articleDetailViewController = ArticleDetailViewController.init(frame: CGRect.init(x: cell.frame.origin.x, y: cell.frame.origin.y, width: moduleWidth, height: moduleHeight))
        articleDetailViewController.articleDeatilObject = articleDetailObject
        articleDetailViewController.contentId = contentId
        self.gridObject = pageModuleObject.moduleData![0] as? SFGridObject
        self.tableView?.isScrollEnabled=false
        articleDetailViewController.createModules()
        self.addChildViewController(articleDetailViewController)
        cell.addSubview(articleDetailViewController.view)
    }
    
    private func trackGAEvent(screenName:String) {
        
        var screenNameToBeDisplayed: String = screenName
        
        if screenNameToBeDisplayed.isEmpty {
            switch self.detailPageType {
            case .videoDetail:
                screenNameToBeDisplayed = "video_detail_view"
                break
            case .showDetail:
                screenNameToBeDisplayed = "show_detail_view"
                break
            }
        }

        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.allowIDFACollection = true
        tracker.set(kGAIScreenName, value: screenNameToBeDisplayed)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 170.0
        
        if indexPath.row > modulesListArray.count - 1 {
            
            return 0
        }
        
        let module:AnyObject = modulesListArray[indexPath.row] as AnyObject

        if module is SFTrayObject {
            let trayObject:SFTrayObject? = module as? SFTrayObject
            rowHeight = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject!).height ?? 170)
        }
        else if module is SFVideoDetailModuleObject
        {
            let videoViewObject:SFVideoDetailModuleObject? = module as? SFVideoDetailModuleObject
            
            rowHeight = CGFloat(Utility.fetchVideoDetailLayoutDetails(videoDetailObject: videoViewObject!).height ?? 350)

            //Currently hardcoded to achieve dynamic row nature if trailer not available for iPhone
            if Constants.IPHONE {
                
                let pageAPIModuleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(videoViewObject?.moduleID ?? "")"] as? SFModuleObject
                
                if pageAPIModuleObject != nil {
                    
                    let film:SFFilm = pageAPIModuleObject!.moduleData![0] as! SFFilm
                    
                    if film.trailerId == nil {
                        
                        rowHeight = rowHeight - 60
                    }
                }
            }
            rowHeight = rowHeight * Utility.getBaseScreenHeightMultiplier()
        }
        else if module is SFArticleDetailObject
        {
            let articleViewObject:SFArticleDetailObject? = module as? SFArticleDetailObject
            
            rowHeight = CGFloat(Utility.fetchArticleDetailLayoutDetails(articleDetailObject: articleViewObject!).height ?? 660)
            
            rowHeight = rowHeight * Utility.getBaseScreenHeightMultiplier()
        }
        else if module is SFShowDetailModuleObject
        {
            let showViewObject:SFShowDetailModuleObject? = module as? SFShowDetailModuleObject
            
            let pageAPIModuleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(showViewObject?.moduleID ?? "")"] as? SFModuleObject

            var showObject:SFShow?
            
            if pageAPIModuleObject != nil && showViewObject != nil {
                
               showObject = pageAPIModuleObject!.moduleData![0] as? SFShow
                
                rowHeight = CGFloat(self.calculateCellHeightFromCellComponents(showViewObject: showViewObject!, noOfData: Float(showObject?.seasons?[selectedSeason].episodes?.count ?? 0))) //+ 10.0
            }
            
            //Currently hardcoded to achieve dynamic row nature if trailer not available for iPhone
            if Constants.IPHONE {

                if showObject != nil {

                    if showObject?.trailerId == nil {

                        rowHeight -= 60 * Utility.getBaseScreenHeightMultiplier()
                    }
                }
            }
            rowHeight = rowHeight * Utility.getBaseScreenHeightMultiplier() //+ 10.0
        }
        return rowHeight
    }

    
    //MARK: Method to dynamically calculate cell height from cell components
    private func calculateCellHeightFromCellComponents(showViewObject:SFShowDetailModuleObject, noOfData:Float) -> Float {
        
        var rowHeight:Float = 0.0
        
        if showViewObject.showDetailModuleComponents != nil {
            
            for module in (showViewObject.showDetailModuleComponents)! {
                
                if module is SFLabelObject {
                    
                    let labelObject = module as! SFLabelObject
                    
                    let maxYAxis = Float(Utility.fetchLabelLayoutDetails(labelObject: labelObject).height ?? 0) + Float(Utility.fetchLabelLayoutDetails(labelObject: labelObject).yAxis ?? 0)
                    
                    if maxYAxis > rowHeight {
                        
                        rowHeight = maxYAxis
                    }
                }
                else if module is SFImageObject {
                    
                    let imageObject = module as! SFImageObject
                    
                    let maxYAxis = Float(Utility.fetchImageLayoutDetails(imageObject: imageObject).height ?? 0) + Float(Utility.fetchImageLayoutDetails(imageObject: imageObject).yAxis ?? 0)
                    
                    if maxYAxis > rowHeight {
                        
                        rowHeight = maxYAxis
                    }
                }
                else if module is SFCastViewObject {
                    
                    let castViewObject = module as! SFCastViewObject
                    
                    let maxYAxis = Float(Utility.fetchCastViewLayoutDetails(castViewObject: castViewObject).height ?? 0) + Float(Utility.fetchCastViewLayoutDetails(castViewObject: castViewObject).yAxis ?? 0)
                    
                    if maxYAxis > rowHeight {
                        
                        rowHeight = maxYAxis
                    }
                }
                else if module is SFButtonObject {
                    
                    let buttonObject = module as! SFButtonObject
                    
                    let maxYAxis = Float(Utility.fetchButtonLayoutDetails(buttonObject: buttonObject).height ?? 0) + Float(Utility.fetchButtonLayoutDetails(buttonObject: buttonObject).yAxis ?? 0)
                    
                    if maxYAxis > rowHeight {
                        
                        rowHeight = maxYAxis
                    }
                }
                else if module is SFStarRatingObject {
                    
                    let starRatingObject = module as! SFStarRatingObject
                    
                    let maxYAxis = Float(Utility.fetchStarRatingLayoutDetails(starRatingObject: starRatingObject).height ?? 0) + Float(Utility.fetchStarRatingLayoutDetails(starRatingObject: starRatingObject).yAxis ?? 0)
                    
                    if maxYAxis > rowHeight {
                        
                        rowHeight = maxYAxis
                    }
                }
                else if module is SFTrayObject {
                    
                    let trayObject = module as! SFTrayObject
                    
                    let maxYAxis = Float(Utility.sharedUtility.calculateCellHeightFromCellComponents(trayObject: trayObject, noOfData: noOfData)) + Float(Utility.fetchTrayLayoutDetails(trayObject: trayObject).yAxis ?? 0)
                    
                    if maxYAxis > rowHeight {
                        
                        rowHeight = maxYAxis
                    }
                }
                else if module is SFSeparatorViewObject {
                    
                    let separatorViewObject = module as! SFSeparatorViewObject
                    
                    let maxYAxis = Float(Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject).height ?? 0) + Float(Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject).yAxis ?? 0)
                    
                    if maxYAxis > rowHeight {
                        
                        rowHeight = maxYAxis
                    }
                }
                else if module is SFCollectionGridObject {
                    
                    let collectionGridObject = module as! SFCollectionGridObject
                    let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject)
                    
                    let collectionViewWidth = ceil(Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)).width)
                    
                    let collectionViewGridWidth:Float = (collectionGridLayout.gridWidth ?? 0) * Float(Utility.getBaseScreenWidthMultiplier()) + (collectionGridLayout.trayPadding ?? 0)
                    
                    let noOfGridToBeDisplayedInRow:Int = Int(round(Float(collectionViewWidth) / collectionViewGridWidth))
                    
                    var collectionGridHeight:Float = 0.0
                    
                    if noOfGridToBeDisplayedInRow > 0 {
                        
                        collectionGridHeight = ((((collectionGridLayout.gridHeight ?? 0) + ((collectionGridLayout.trayPadding ?? 0))) * Float(Utility.getBaseScreenHeightMultiplier())) * noOfData) / Float(noOfGridToBeDisplayedInRow)
                    }
                    
                    let maxYAxis = (collectionGridLayout.yAxis ?? 0) + collectionGridHeight
                    
                    if maxYAxis > rowHeight {
                        
                        rowHeight = maxYAxis
                    }
                    
                    rowHeight += 10.0
                }
            }
        }
        return rowHeight
    }
    
    //MARK: Method to add grids to table view cell
    func addCollectionGridToTable(cell:UITableViewCell, pageModuleObject:SFModuleObject) {
        
        let trayObject:SFTrayObject = modulesListDict["\(pageModuleObject.moduleId ?? "")"] as! SFTrayObject
        
        for gridObject in pageModuleObject.moduleData! {
            var tempGridObject : SFGridObject = SFGridObject()
            tempGridObject=gridObject as! SFGridObject
            filmIdArray.append(tempGridObject)
        }
        
        let collectionGridViewController:CollectionGridViewController = CollectionGridViewController(trayObject: trayObject)
        
        let rowHeight:CGFloat = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject).height ?? 170)
        let cellFrame:CGRect = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: UIScreen.main.bounds.width, height: rowHeight)
        
        collectionGridViewController.view.frame = Utility.initialiseViewLayout(viewLayout: Utility.fetchTrayLayoutDetails(trayObject: trayObject), relativeViewFrame: cellFrame)
        collectionGridViewController.relativeViewFrame = collectionGridViewController.view.frame
        collectionGridViewController.delegate = self
        collectionGridViewController.moduleAPIObject = pageModuleObject
        collectionGridViewController.createSubViews()
        self.addChildViewController(collectionGridViewController)
        cell.addSubview(collectionGridViewController.view)
    }
    
    
    //MARK: Method to add videoDetail to table view cell
    func addVideoDetailToTable(cell:UITableViewCell, pageModuleObject:SFModuleObject) {
        switch self.detailPageType {
        case .videoDetail:
            let videoDetailObject:SFVideoDetailModuleObject = modulesListDict["\(pageModuleObject.moduleId ?? "")"] as!SFVideoDetailModuleObject
            
            var moduleHeight: CGFloat = CGFloat(Utility.fetchVideoDetailLayoutDetails(videoDetailObject: videoDetailObject).height!)
            let moduleWidth: CGFloat = self.view.frame.width
            moduleHeight = moduleHeight * Utility.getBaseScreenHeightMultiplier()
            
            if self.videoDescriptionView != nil {
                
                self.videoDescriptionView?.removeFromSuperview()
            }
//            if self.videoDescriptionView == nil
//            {
            let videoDescriptionView: VideoDescriptionView = VideoDescriptionView.init(frame: CGRect.init(x: 0, y: 0, width: moduleWidth, height: moduleHeight), videoDescriptionModule: videoDetailObject, film: pageModuleObject.moduleData![0] as! SFFilm, containerViewController: self, videoDuration: videoDuration)
                videoDescriptionView.videoPlaybackDelegate = self
                cell.addSubview(videoDescriptionView)
                self.videoDescriptionView = videoDescriptionView
//            }
//            else
//            {
//                cell.addSubview(self.videoDescriptionView!)
//            }
            self.filmObject = pageModuleObject.moduleData![0] as? SFFilm
            self.videoDescriptionView?.videoPlaybackDelegate = self
            if videoDetailObject.isInlineVideoPlayer
            {
                if Constants.IPHONE {
                    Constants.kAPPDELEGATE.isFullScreenEnabled = true
                }
                
                self.isVideoPlaying = true
            }
            if isVideoPlaying && Constants.IPHONE
            {
                if self.videoDescriptionView?.iOSVideoPlayer != nil {
                    
                    if self.view.frame.size.width > self.view.frame.size.height {
                        
                        self.videoPlayerFullScreenTapped(videoPlayer: self.videoDescriptionView?.iOSVideoPlayer, isFullScreenButtonTapped: false)
                    }
//                    else if Constants.IPHONE {
//
//                        self.videoPlayerExitFullScreenTapped(videoPlayer: videoDescriptionView?.iOSVideoPlayer)
//                    }
                }
            }
            break
            
        case .showDetail:
            let showDetailObject:SFShowDetailModuleObject = modulesListDict["\(pageModuleObject.moduleId ?? "")"] as! SFShowDetailModuleObject

            var moduleHeight: CGFloat = CGFloat(self.calculateCellHeightFromCellComponents(showViewObject: showDetailObject, noOfData: Float((pageModuleObject.moduleData![0] as! SFShow).seasons?[selectedSeason].episodes?.count ?? 0))) //+ 10.0
            
            let moduleWidth: CGFloat = self.view.frame.width
            moduleHeight = moduleHeight * Utility.getBaseScreenHeightMultiplier() //+ 10.0
            
            let showDescriptionView: VideoDescriptionView = VideoDescriptionView.init(frame: CGRect.init(x: 0, y: 0, width: moduleWidth, height: moduleHeight), showDescriptionModule: showDetailObject, show: pageModuleObject.moduleData![0] as! SFShow, containerViewController: self, selectedSeason: selectedSeason)
            showDescriptionView.videoPlaybackDelegate = self
            cell.addSubview(showDescriptionView)
            self.showObject = pageModuleObject.moduleData![0] as? SFShow
            self.showDescriptionView = showDescriptionView
            break
        }
    }
    
    //MARK:Collection Grid Delegates
    func didSelectVideo(gridObject: SFGridObject?) {

        var viewControllerPage:Page?
        
        var filePath:String = ""
        
        if gridObject?.contentType?.lowercased() == Constants.kVideoContentType || gridObject?.contentType?.lowercased() == Constants.kVideosContentType
        {
            filePath = AppSandboxManager.getpageFilePath(fileName: Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Video Page") ?? "")
        }
        else if gridObject?.contentType?.lowercased() == Constants.kShowContentType || gridObject?.contentType?.lowercased() == Constants.kShowsContentType
        {
            filePath = AppSandboxManager.getpageFilePath(fileName: Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Show Page") ?? "")
        }
        
        if !filePath.isEmpty {
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                
                let pageParser = PageUIParser()
                viewControllerPage = pageParser.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
            }
        }
        
        if viewControllerPage != nil {
            
            self.isRelatedVideoClicked = true
            self.viewControllerPage = viewControllerPage
            self.contentId = gridObject?.contentId ?? ""
            self.pagePath = gridObject?.gridPermaLink ?? ""
            self.fetchPageContent()
        }

    }
    
    
    func didDisplayMorePopUp(button: SFButton, gridObject: SFGridObject?) {
        
        if gridObject != nil {
            
            if let contentId = gridObject?.contentId , let contentType = gridObject?.contentType {
                
                var moreOptionArray = [["option":"watchlist"]]
                
                if let isDownloadEnabled = AppConfiguration.sharedAppConfiguration.isDownloadEnabled {
                    
                    if isDownloadEnabled {
                        
                        moreOptionArray.append(["option":"download"])
                    }
                }
                
                self.displayMorePopUpView(moreOptionArray: moreOptionArray, contentId: contentId , contentType:contentType, isOptionForBannerView: false)
            }
        }
    }
    
    
    //MARK: Method to display more pop up option array
    private func displayMorePopUpView(moreOptionArray:Array<Dictionary<String, Any>>, contentId:String?, contentType:String?, isOptionForBannerView: Bool) {
        self.view.isUserInteractionEnabled = false
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        Utility.presentMorePopUpView(moreOptionArray: moreOptionArray, contentId: contentId, contentType: contentType, isModel: true, delegate: self, isOptionForBannerView: isOptionForBannerView)
    }
    
    
    //MARK: More popover controller delegate
    func removePopOverViewController(viewController: UIViewController) {
        self.view.isUserInteractionEnabled = true
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }

    func removeKisweBaseViewController(viewController:UIViewController) -> Void{
        self.view.isUserInteractionEnabled = true
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
    }

    //MARK: - VideoPlaybackDelegate Method
    func buttonTapped(button: SFButton, filmObject:SFFilm?, showObject:SFShow?) {
        
        if button.buttonObject?.action == "watchVideo"
        {
            if filmObject != nil {
                
                if Utility.sharedUtility.checkIfDownloadAlertToBeDisplayedInOfflineMode() {
                    
                    Utility.sharedUtility.displayOfflineAlertToPlayDownloadVideo(viewController: self)
                }
                else {
                    
                     let eventId = filmObject?.eventId
                     if eventId != nil && Constants.kAPPDELEGATE.isKisweEnable{
                        
                        Utility.presentKiswePlayer(forEventId: eventId!, withFilmId: filmObject?.id ?? "",vc: self)
                    }
                    else {
                        
                        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                            
                            if filmObject?.isFreeVideo != nil {
                                
                                if filmObject?.isFreeVideo == true {
                                    
                                    loadVideoController(filmObject: filmObject, showObject: showObject)
                                }
                                else {
                                    
                                    checkIfUserIsEntitledToVideo(button: button, filmObject: filmObject, showObject: showObject)
                                }
                            }
                            else {
                                
                                checkIfUserIsEntitledToVideo(button: button, filmObject: filmObject, showObject: showObject)
                            }
                        }
                        else{
                            
                            loadVideoController(filmObject: filmObject, showObject: showObject)
                        }
                    }
                }
            }
        }
        else if button.buttonObject?.action == "share" {
            
            shareButtonTapped(button:button, filmObject:filmObject, showObject: showObject, shareButton: nil)
        }
        else if button.buttonObject?.action == "close" {
            
            Constants.kAPPDELEGATE.isFullScreenEnabled = false
            
            if self.videoDescriptionView?.iOSVideoPlayer != nil {
                
                self.videoDescriptionView?.iOSVideoPlayer?.view.removeFromSuperview()
                self.videoDescriptionView?.iOSVideoPlayer?.removeFromParentViewController()
            }
            
            if Constants.IPHONE {
                
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
            
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                
                self.navigationController?.popViewController(animated: true)
            }
            else {
                
                self.dismiss(animated: true, completion: {
                
                    Constants.kAPPDELEGATE.isFullScreenEnabled = false
                })
            }
        }
        else if button.buttonObject?.action == "watchTrailer" {
            
            if filmObject != nil {
                
                self.playTrailer(trailerId: filmObject?.trailerId)
                //loadVideoPlayer(videoURLString:(filmObject?.trailerURL)!)
            }
            else if showObject != nil {
                
                self.playTrailer(trailerId: showObject?.trailerId)
                //loadVideoPlayer(videoURLString: (showObject?.trailerURL)!)
            }
        }
        else if button.buttonObject?.action == "addToWatchlist" {
            
            if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                
                updateVideoWatchlistStatus(button: button, filmObject: filmObject, showObject: showObject)
            }
            else {
                
                userPromptForSignIn(button: button, filmObject: filmObject, showObject: showObject)
            }
        }
        else if button.buttonObject?.action == "morePopUp" {
            
            if filmObject != nil {
                
                if let contentId = filmObject?.id , let contentType = filmObject?.type {

                    var moreOptionArray = [["option":"watchlist"]]
                    
                    if let isDownloadEnabled = AppConfiguration.sharedAppConfiguration.isDownloadEnabled {
                        
                        if isDownloadEnabled {
                            
                            moreOptionArray.append(["option":"download"])
                        }
                    }
                    
                    self.displayMorePopUpView(moreOptionArray: moreOptionArray, contentId: contentId, contentType: contentType, isOptionForBannerView: false)
                }
            }
            else if showObject != nil {
                
                if let contentId = showObject?.showId , let contentType = showObject?.type {
                    
                    var moreOptionArray = [["option":"watchlist"]]
                    
                    if let isDownloadEnabled = AppConfiguration.sharedAppConfiguration.isDownloadEnabled {
                        
                        if isDownloadEnabled {
                            
                            moreOptionArray.append(["option":"download"])
                        }
                    }
                    
                    self.displayMorePopUpView(moreOptionArray: moreOptionArray, contentId: contentId, contentType: contentType, isOptionForBannerView: false)
                }
            }
        }
    }
    
    
    private func playTrailer(trailerId:String?) {
        
        if trailerId != nil {
            
            self.fetchVideoURLToBePlayed(contentId: trailerId!)
        }
        else {
            
            let alertController = UIAlertController(title: "Error", message: "Url not available", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: Constants.kStrOk, style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func playSelectedEpisode(filmObject: SFFilm?, nextEpisodesArray: Array<String>?) {
        
        if filmObject != nil {
            
            self.nextEpisodesArray = nextEpisodesArray
            
            if Utility.sharedUtility.checkIfDownloadAlertToBeDisplayedInOfflineMode() {
                
                Utility.sharedUtility.displayOfflineAlertToPlayDownloadVideo(viewController: self)
            }
            else {
                
                 let eventId = filmObject?.eventId
                 if eventId != nil && Constants.kAPPDELEGATE.isKisweEnable{
                    
                    Utility.presentKiswePlayer(forEventId: eventId!, withFilmId: filmObject?.id ?? "", vc: self)
                }
                else {
                    
                    if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                        
                        checkIfUserIsEntitledToVideo(button: nil, filmObject: filmObject, showObject: nil)
                    }
                    else{
                        
                        loadVideoController(filmObject: filmObject, showObject: nil)
                    }
                }
            }
        }
    }
    
    //MARK: Method to check if user is entitled or not
    func checkIfUserIsEntitledToVideo(button: SFButton?, filmObject:SFFilm?, showObject:SFShow?) {
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            self.showActivityIndicator(loaderText: nil)
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                DataManger.sharedInstance.apiToGetUserEntitledStatus(success: { (isSubscribed) in
                    
                    DispatchQueue.main.async {
                        
                        self.hideActivityIndicator()
                        
                        if isSubscribed != nil {
                            
                            if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                
                                Utility.sharedUtility.setGTMUserProperty(userPropertyValue: isSubscribed! ? Constants.kGTMSubscribedPropertyValue : Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                            }
                            
                            if isSubscribed! {
                                
                                self.loadVideoController(filmObject: filmObject, showObject: showObject)
                            }
                            else {
                                
                                self.subscriptionStatusFail(button: button, filmObject: filmObject, showObject: showObject)
                            }
                        }
                        else {
                         
                            if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                
                                Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                            }
                            
                            self.subscriptionStatusFail(button: button, filmObject: filmObject, showObject: showObject)
                        }
                    }
                })
            }
        }
        else {
            loadVideoController(filmObject: filmObject, showObject: showObject)
            //self.displayNonEntitledUserAlert(button: button, filmObject: filmObject)
        }
    }
    
    
    func subscriptionStatusFail(button:SFButton?, filmObject:SFFilm?, showObject:SFShow?) {
        
        let transactionInfo:Dictionary<String, Any>? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as? Dictionary<String, Any>
        
        if transactionInfo != nil {
            
            let receiptData:NSData? = transactionInfo?["receiptData"] as? NSData
            
            if receiptData != nil {

                self.updateSubscriptionInfoWithReceiptdata(receipt: receiptData, emailId: nil, productIdentifier: transactionInfo?["productIdentifier"] as? String, transactionIdentifier: transactionInfo?["transactionId"] as? String, success: { (isSuccessfullySubscribed) in

                    if isSuccessfullySubscribed {

                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kUpdateSubscriptionStatusToServer)
                        Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                    }
                    else {
                        
                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                    }
                    
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()

                    self.loadVideoController(filmObject: filmObject, showObject: showObject)
                    //                    else {
                    //
                    //                        self.displayNonEntitledUserAlert(button: button, filmObject: filmObject)
                    //                    }
                })
            }
//            else {
//                
//                self.updateSubscriptionStatusWithReceipt(button: button, filmObject: filmObject, productIdentifier: transactionInfo?["productIdentifier"] as? String, transactionIdentifier:transactionInfo?["transactionId"] as? String)
//            }
        }
        else {
            
            self.loadVideoController(filmObject: filmObject, showObject: showObject)
        }
//        else {
//            
//            self.updateSubscriptionStatusWithReceipt(button: button, filmObject: filmObject, productIdentifier: nil, transactionIdentifier: nil)
//            //self.displayNonEntitledUserAlert(button: button, filmObject: filmObject)
//        }
    }
    
    
    func updateSubscriptionStatusWithReceipt(button:SFButton?, filmObject:SFFilm?, showObject:SFShow?, productIdentifier: String?, transactionIdentifier:String?) {
        
        let receiptURL = Bundle.main.appStoreReceiptURL
        
        if receiptURL != nil {
            
            let receipt:NSData? = NSData(contentsOf:receiptURL!)
            
            if receipt != nil {
                
                self.updateSubscriptionInfoWithReceiptdata(receipt: receipt, emailId: nil, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier, success: { (isSuccessfullySubscribed) in
                    
                    if isSuccessfullySubscribed {
                        
                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kUpdateSubscriptionStatusToServer)
                        Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                        Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    }
                        self.loadVideoController(filmObject: filmObject, showObject: showObject)
//                    else {
//                        
//                        self.displayNonEntitledUserAlert(button: button, filmObject: filmObject)
//                    }
                })
            }
            else {
                loadVideoController(filmObject: filmObject, showObject: showObject)
                //self.displayNonEntitledUserAlert(button: button, filmObject: filmObject)
            }
        }
        else {
            loadVideoController(filmObject: filmObject, showObject: showObject)
            //self.displayNonEntitledUserAlert(button: button, filmObject: filmObject)
        }
    }
    
    
    /**
     Method to update subscription info with user
     @param receipt transaction receipt
     */
    func updateSubscriptionInfoWithReceiptdata(receipt: NSData?, emailId:String?, productIdentifier:String?, transactionIdentifier:String?, success: @escaping ((_ isSuccess:Bool) -> Void))
    {
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator(loaderText: nil)
        
        let requestParameters:Dictionary<String, Any> = Utility.sharedUtility.getRequestParametersForSubscription(receiptData: receipt, emailId: emailId, paymentModelObject: nil, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
        DataManger.sharedInstance.apiToUpdateSubscriptionStatus(requestParameter: requestParameters, requestType: .post) { (subscriptionResponse, isSuccess) in
            
            self.view.isUserInteractionEnabled = true
            self.hideActivityIndicator()
            
            if subscriptionResponse != nil {
                
                if isSuccess {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                    Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kTransactionInfo)
                    Constants.kAPPDELEGATE.removePlistFromDocumentDirectory(plistName: Constants.kTransactionDetailPlistName)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    
                    success(true)
                    //self.checkIfUserShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered:true)
                }
                else {
                    
                    let errorCode:String? = subscriptionResponse?["code"] as? String
                    
                    if errorCode != nil {
                        self.showSubscriptionAlertWithMessage(message: ["code": errorCode!], success: { (isSuccess) in
                            
                            success(isSuccess)
                        })
                    }
                    else {
                        
                        success(false)
                    }
                }
            }
            else {
                
                success(false)
            }
        }
    }
    
    
    /**
     Method to show the popup
     
     @param message popUp informations
     */
    private func showSubscriptionAlertWithMessage(message: Dictionary<String, Any>, success: @escaping ((_ isSuccess:Bool) -> Void))
    {
        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kStrUserSubscribed)
        Constants.kSTANDARDUSERDEFAULTS.synchronize()
        
        let okAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrOk, style: .default) { (result : UIAlertAction) in
            
            success(false)
        }
        
        let errorCode:String = message[Constants.PAYMENT_NOTIFICATION_CODE_KEY] as! String
        
        if (errorCode.lowercased() == Constants.kPaymentFailedCode.lowercased() || errorCode.lowercased() == Constants.kSubscriptionServiceFailedErrorCode.lowercased()) {
            let paymentAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "Error!", alertMessage: "The payment process did not complete/failed.", alertActions: [okAction])
            self.present(paymentAlert, animated: true, completion: nil)
        } else if (errorCode.lowercased() == Constants.kDuplicateUserErrorCode.lowercased()) {
            
            let paymentAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "Error!", alertMessage: "You may have another account associated with the entered Apple Id. Kindly log in with that \(Bundle.main.infoDictionary?["CFBundleDisplayName"] ?? "") account.", alertActions: [okAction])
            self.present(paymentAlert, animated: true, completion: nil)
        }
        else if errorCode.lowercased() == Constants.kUserNotFoundInSubscripionFailedErrorCode.lowercased() {
            
            success(false)
        }
        else if errorCode.lowercased() == Constants.kIllegalArugmentExceptionFailedErrorCode.lowercased(){
            
            success(false)
        }
        else {
            let paymentAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "Error!", alertMessage: "The payment process got failed.", alertActions: [okAction])
            self.present(paymentAlert, animated: true, completion: nil)
        }
    }
    
    
    func displayNonEntitledUserAlert(button: SFButton?, filmObject:SFFilm?, showObject:SFShow?) {
        
        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
            
            
        }
        
        let signInAction = UIAlertAction(title: Constants.kStrSign, style: .default) { (signInAction) in
            
            self.displayLoginScreen(button: button, filmObject: filmObject, showObject: showObject, loginCompeletionHandlerType: .UpdateVideoPlay)
        }
        
        let subscriptionAction = UIAlertAction(title: Constants.kStrSubscription, style: .default) { (subscriptionAction) in
            
            self.displayPlanPage(button: button, filmObject: filmObject, showObject: showObject, loginCompeletionHandlerType: .UpdateVideoPlay)
        }
        
        var alertActionArray:Array<UIAlertAction>?
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            alertActionArray = [cancelAction, subscriptionAction]
        }
        else {
            
            alertActionArray = [cancelAction, signInAction, subscriptionAction]
        }
        
        let nonEntitledAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kEntitlementErrorTitle, alertMessage: Constants.kEntitlementErrorMessage, alertActions: alertActionArray!)
        
        self.present(nonEntitledAlert, animated: true, completion: nil)
    }
    
    
    func displayPlanPage(button:SFButton?, filmObject:SFFilm?, showObject:SFShow?, loginCompeletionHandlerType:CompeletionHandlerOptions) -> Void {
        
        displayPlanPageWithCompletionHandler(button: button, filmObject: filmObject, showObject: showObject) { (isSuccessfullyLoggedIn) in
            
            if isSuccessfullyLoggedIn {
                
                if loginCompeletionHandlerType == CompeletionHandlerOptions.UpdateVideoPlay {
                    
                    self.loadVideoController(filmObject: filmObject, showObject: showObject)
                }
            }
        }
    }
    
    
    func displayPlanPageWithCompletionHandler(button:SFButton?, filmObject:SFFilm?, showObject:SFShow?, completionHandler: @escaping ((_ isSuccessfullyLoggedIn: Bool) -> Void)) -> Void {
        
        let planViewController:SFProductListViewController = SFProductListViewController.init()
        planViewController.completionHandlerCopy = completionHandler
        let navigationController = UINavigationController.init(rootViewController: planViewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    //MARK: Method to load video controller
    func loadVideoController(filmObject:SFFilm?, showObject: SFShow?) {
        if CastPopOverView.shared.isConnected(){
            
            var isFreeVideo = false
            
            if filmObject?.isFreeVideo != nil {
                
                if filmObject?.isFreeVideo == true {
                    
                    isFreeVideo = (filmObject?.isFreeVideo)!
                }
            }
            
            if  Utility.sharedUtility.checkIfMoviePlayable() == true || isFreeVideo {
                
                CastController().playSelectedItemRemotely(contentId: filmObject?.id ?? "", isDownloaded:  false, relatedContentIds: self.nextEpisodesArray, contentTitle: filmObject?.title ?? "")
            }
            else{
                Utility.sharedUtility.showAlertForUnsubscribeUser()
            }
        }
        else{
            let videoObject: VideoObject = VideoObject()
            videoObject.videoTitle = filmObject?.title ?? ""
            videoObject.videoPlayerDuration = Double(filmObject?.durationSeconds ?? 0)
            videoObject.videoContentId = filmObject?.id ?? ""
            videoObject.gridPermalink = filmObject?.permaLink ?? ""
            videoObject.primaryCategory = filmObject?.primaryCategory ?? ""
            videoObject.videoWatchedTime = Double(filmObject?.filmWatchedDuration ?? 0)
            videoObject.contentRating = filmObject?.parentalRating ?? ""
            videoObject.videoFileBitRate = filmObject?.fileBitRate ?? ""
            let playerViewController: CustomVideoController = CustomVideoController.init(videoObject: videoObject, videoPlayerType: .streamVideoPlayer, videoFitType: .fullScreen)

            if self.nextEpisodesArray != nil {
                
                playerViewController.isPlayingEpisode = true
                playerViewController.autoPlayObjectArray = self.nextEpisodesArray!
            }
            
            self.present(playerViewController, animated: true, completion: nil)
        }
    }

    
    //MARK: method to view more description
    func moreButtonTapped(filmObject: SFFilm?, showObject:SFShow?) {
        let videoDetailDescriptionViewController:VideoDetailDescriptionViewController = VideoDetailDescriptionViewController.init(film: filmObject, show: showObject)
        videoDetailDescriptionViewController.moreButtonDelegate=self
        videoDetailDescriptionViewController.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000").withAlphaComponent(0.90)
        videoDetailDescriptionViewController.modalPresentationStyle = .overCurrentContext
        self.present(videoDetailDescriptionViewController, animated: true, completion: nil)
        
    }
    func videoDescRemoved() {
      self.tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    //MARK: Method to fetch Video URL to play
    func fetchVideoURLToBePlayed(contentId:String) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            showAlertForAlertType(alertType: .AlertTypeNoInternetFound, isAlertForVideoDetailAPI: false, contentId: contentId, alertTitle: nil, alertMessage: nil)
        }
        else {
            
            self.showActivityIndicator(loaderText: nil)
            DataManger.sharedInstance.fetchURLDetailsForVideo(apiEndPoint: "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/videos/\(contentId)?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&fields=streamingInfo") { (videoURLWithStatusDict) in
                
                DispatchQueue.main.async {
                    
                    let filmURLs:Dictionary<String, AnyObject>? = videoURLWithStatusDict?["urls"] as? Dictionary<String, AnyObject>
                    
                    self.progressIndicator?.hide(animated: true)
                    self.playVideo(videoUrls: filmURLs)
                }
            }
        }
    }
    
    @objc func starRatingTapped(filmObject: SFFilm?, showObject:SFShow?) {
        
        let starViewController:StarRatingViewController = StarRatingViewController.init(film: filmObject, show: showObject)
        starViewController.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000").withAlphaComponent(0.90)
        starViewController.modalPresentationStyle = .overCurrentContext
        self.present(starViewController, animated: true, completion: nil)
    }
    
    
    func playVideo(videoUrls:Dictionary<String, AnyObject>?) {
        
        let videoUrls:Dictionary<String, AnyObject>? = videoUrls?["videoUrl"] as? Dictionary<String, AnyObject>
        
        let rendentionUrls:Array<AnyObject>? = videoUrls?["renditionUrl"] as? Array<AnyObject>
        let hlsUrl:String? = videoUrls?["hlsUrl"] as? String
        var videoUrlToBePlayed:String?
        
        var shouldPlayHlsUrlFirst = false
        if let dicRoot:NSDictionary = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "SiteConfig", ofType: "plist")!) {
            
            if let shouldPlayHlsFirst:Bool = dicRoot["shouldPlayHlsUrlFirst"] as? Bool {
                
                shouldPlayHlsUrlFirst = shouldPlayHlsFirst
            }
        }
        
        if shouldPlayHlsUrlFirst {
            
            if hlsUrl != nil
            {
                videoUrlToBePlayed = hlsUrl
            }
            else if rendentionUrls != nil {
                
                if (rendentionUrls?.count)! > 0 {
                    
                    let renditionUrlDict:Dictionary<String, AnyObject>? = rendentionUrls?.last as? Dictionary<String, AnyObject>
                    
                    videoUrlToBePlayed = renditionUrlDict?["renditionUrl"] as? String
                }
            }
        }
        else {
            
            if rendentionUrls != nil {
                
                if (rendentionUrls?.count)! > 0 {
                    
                    let renditionUrlDict:Dictionary<String, AnyObject>? = rendentionUrls?.last as? Dictionary<String, AnyObject>
                    
                    videoUrlToBePlayed = renditionUrlDict?["renditionUrl"] as? String
                }
            }
            else if hlsUrl != nil
            {
                videoUrlToBePlayed = hlsUrl
            }
        }
        
        if videoUrlToBePlayed != nil {
            
            loadVideoPlayer(videoURLString: videoUrlToBePlayed!)
        }
        else {
            
            let alertController = UIAlertController(title: "Error", message: "Url not available", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: Constants.kStrOk, style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: Load VideoPlayer
    func loadVideoPlayer(videoURLString:String) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default, handler: { (cancelAction) in
                
            })
            
            let retryAction = UIAlertAction(title: Constants.kStrRetry, style: .default, handler: { (retryAction) in
                
                self.loadVideoPlayer(videoURLString: videoURLString)
            })
            
            let networkAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kInternetConnection, alertMessage: Constants.kInternetConntectionRefresh, alertActions: [cancelAction, retryAction])
            self.present(networkAlert, animated: true, completion: nil)
        }
        else {
            
            let videoURLStringLocal = Utility.urlEncodedString_ch(emailStr: videoURLString)
            
            let playerItem = AVPlayerItem(url: URL(string: videoURLStringLocal)!)
            let videoPlayer = AVPlayer(playerItem: playerItem)
            videoPlayerController = AVPlayerViewController()
            videoPlayerController?.player = videoPlayer
            
            if #available(iOS 9.0, *) {
                videoPlayerController?.allowsPictureInPicturePlayback = false
            } else {
                // Fallback on earlier versions
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayerController?.player?.currentItem)
            self.present(videoPlayerController!, animated: true) {
                
                self.videoPlayerController?.player?.play()
            }
        }
    }
    
    //MARK: Player Delegate
    func playerDidFinishPlaying(notification:Notification) {
        
        videoPlayerController?.dismiss(animated: false, completion: {
            
            self.navigationController?.popViewController(animated: false)
        })
    }
    
    
    //MARK: Share Button Tapped
    func shareButtonTapped(button:SFButton?, filmObject:SFFilm?, showObject:SFShow?, shareButton:UIButton?) -> Void {
        
        var permaLink:String?
        
        if filmObject != nil {
            
            permaLink = filmObject?.permaLink
        }
        else if showObject != nil {
            
            permaLink = showObject?.permaLink
        }
        else if self.gridObject != nil {
            permaLink = gridObject?.gridPermaLink
        }
        
        if permaLink == nil {
            
            let okAction:UIAlertAction = UIAlertAction.init(title: "Ok", style: .default, handler: { (okAction) in
                
            })
            
            let alerController:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "No Content Available!", alertMessage: "Sorry! There is no shareable content available.", alertActions: [okAction])
            
            self.present(alerController, animated: true, completion: nil)
            
            return
        }
        
        let shareUrlString = "\(AppConfiguration.sharedAppConfiguration.domainName ?? "")\(permaLink ?? "")"
        
        var updatedShareUrlString:String?
        if shareUrlString.hasPrefix("https://")
        {
            updatedShareUrlString = shareUrlString
        }
        else {
            
            updatedShareUrlString = "https://\(shareUrlString)"
        }
        
        let encodedShareUrl = updatedShareUrlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        shareActivityViewController = UIActivityViewController(activityItems: [encodedShareUrl ?? ""], applicationActivities: nil)
        shareActivityViewController?.excludedActivityTypes = [.postToWeibo,.print,.assignToContact,.saveToCameraRoll,.addToReadingList,.postToFlickr,.postToTencentWeibo]
        
        shareActivityViewController?.popoverPresentationController?.sourceView = button ?? shareButton
        //Added this to handle correct position as per relative frame of button
        shareActivityViewController?.popoverPresentationController?.sourceRect.origin.y = (button?.frame.origin.y ?? shareButton?.frame.origin.y ?? 0) + 20
        shareActivityViewController?.popoverPresentationController?.sourceRect.origin.x = ((button?.frame.size.width) ?? (shareButton?.frame.size.width) ?? 0)/2
        self.present(shareActivityViewController!, animated: true, completion: nil)
    }
    
    
    //MARK: Prompt user for Sign in
    func userPromptForSignIn(button:SFButton?, filmObject:SFFilm?, showObject:SFShow?) {
        
        let signInAction:UIAlertAction = UIAlertAction(title: Constants.kStrSign, style: .default) { (signInAction) in
            
            self.displayLoginScreen(button: button, filmObject: filmObject, showObject:showObject, loginCompeletionHandlerType: .UpdateWatchlist)
        }
        
        let cancelAction:UIAlertAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
            
            
        }
        
        let userAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kStrAddToWatchlistAlertTitle, alertMessage: Constants.kStrAddToWatchlistAlertMessage, alertActions: [cancelAction, signInAction])
        
        self.present(userAlert, animated: true, completion: nil)
    }
    
    
    func displayLoginScreen(button:SFButton?, filmObject:SFFilm?, showObject:SFShow?, loginCompeletionHandlerType:CompeletionHandlerOptions) -> Void {
     
        displayLoginViewWithCompletionHandler(button: button, filmObject: filmObject, showObject:showObject) { (isSuccessfullyLoggedIn) in
            
            if isSuccessfullyLoggedIn {
                
                if loginCompeletionHandlerType == CompeletionHandlerOptions.UpdateWatchlist {
                    
                    self.updateVideoWatchlistStatus(button: button, filmObject: filmObject, showObject: showObject)
                }
                else if loginCompeletionHandlerType == CompeletionHandlerOptions.UpdateVideoPlay {
                    
                    self.checkIfUserIsEntitledToVideo(button: button, filmObject: filmObject, showObject:showObject)
                }
            }
        }
    }
    
    
    func displayLoginViewWithCompletionHandler(button:SFButton?, filmObject:SFFilm?, showObject:SFShow?, completionHandler: @escaping ((_ isSuccessfullyLoggedIn: Bool) -> Void)) -> Void {
        
        let loginViewController: LoginViewController = LoginViewController.init()
        loginViewController.loginPageSelection = 0
        loginViewController.pageScreenName = "Sign In Screen"
        loginViewController.loginType = loginPageType.authentication
        loginViewController.completionHandlerCopy = completionHandler
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: loginViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
    //MARK: Method to add/remove video from Watchlist
    func updateVideoWatchlistStatus(button:SFButton?, filmObject:SFFilm?, showObject:SFShow?) {
        
        if (button?.isSelected)! {
            
            button?.isSelected = false
            //Remove video from watchlist
            removeVideoFromQueue(filmObject: filmObject, showObject: showObject, button: button)
        }
        else {
            
            button?.isSelected = true
            //Add video to watchlist
            addVideoToQueue(filmObject: filmObject, showObject: showObject, button: button)
        }
    }
    
    
    //MARK: Method to remove video from watchlist
    func removeVideoFromQueue(filmObject:SFFilm?, showObject:SFShow?, button:SFButton?) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshRemoveFromWatchlist
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, filmObject: filmObject, showObject: showObject, errorMessage: nil, errorTitle: nil,  button: button)
        }
        else {

            var contentId:String?
            
            if showObject != nil {
                
                contentId = showObject?.showId
            }
            else if filmObject != nil {
                
                contentId = filmObject?.id
            }
            
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")&contentIds=\(contentId ?? "")"
            showActivityIndicator(loaderText: nil)
            if self.videoDescriptionView != nil && self.videoDescriptionView?.iOSVideoPlayer != nil
            {
                self.videoDescriptionView?.iOSVideoPlayer?.pauseVideo()
            }
            DataManger.sharedInstance.removeVideosFromQueue(apiEndPoint: apiEndPoint) { (isVideoRemoved) in
                
                self.hideActivityIndicator()
                
                if isVideoRemoved == true {
                    
                    button?.isSelected = false
                    self.showWatchlistStatusUpdateView(viewText: "Removed from Watchlist")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:"isWatchlistUpdated"), object: nil)
                }
                else {
                    
                    button?.isSelected = true
                    self.failureAlertType = .RefreshRemoveFromWatchlist
                    
                    var errorMessage:String = "Unable to remove video from watchlist."
                    
                    if showObject != nil {
                        
                        errorMessage = "Unable to remove show from watchlist."
                    }
                    if self.videoDescriptionView != nil && self.videoDescriptionView?.iOSVideoPlayer != nil
                    {
                        self.videoDescriptionView?.iOSVideoPlayer?.playVideo()
                    }
                    self.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, filmObject: filmObject, showObject: showObject, errorMessage: errorMessage, errorTitle: "Watchlist", button: button)
                }
            }
        }
    }
    
    
    //MARK: Method to add video to watchlist
    func addVideoToQueue(filmObject:SFFilm?, showObject: SFShow?, button:SFButton?) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshRemoveFromWatchlist
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, filmObject: filmObject, showObject: showObject, errorMessage: nil, errorTitle: nil,  button: button)
        }
        else {
            
            var contentId:String?
            
            if showObject != nil {
                
                contentId = showObject?.showId
            }
            else if filmObject != nil {
                
                contentId = filmObject?.id
            }
            
            var contentType:String?
            
            if showObject != nil {
                
                contentType = showObject?.type
            }
            else if filmObject != nil {
                
                contentType = filmObject?.type
            }
            
            let watchlistPayload:Dictionary<String, Any> = ["userId": Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "", "contentId":contentId ?? "", "position":1, "contentType":contentType ?? "video"]
            
            let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
            if self.videoDescriptionView != nil && self.videoDescriptionView?.iOSVideoPlayer != nil
            {
                self.videoDescriptionView?.iOSVideoPlayer?.pauseVideo()
            }
            showActivityIndicator(loaderText: nil)
            DataManger.sharedInstance.addVideoToQueue(apiEndPoint: apiRequest, requestParameters: watchlistPayload, success: { (isVideoAdded) in
                
                self.hideActivityIndicator()
                if isVideoAdded != nil {
                    
                    if isVideoAdded! == true {
                        
                        button?.isSelected = true
                        self.showWatchlistStatusUpdateView(viewText: "Added to Watchlist")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"isWatchlistUpdated"), object: nil)
                    }
                    else {
                        
                        button?.isSelected = false

                        self.failureAlertType = .RefreshAddToWatchlist
                        
                        var errorMessage:String = "Unable to add video to watchlist."
                        
                        if showObject != nil {
                            
                            errorMessage = "Unable to add show to watchlist."
                        }
                        
                        self.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, filmObject: filmObject, showObject: showObject, errorMessage: errorMessage, errorTitle: "Watchlist", button: button)
                    }
                }
                else {
                    
                    button?.isSelected = false

                    self.failureAlertType = .RefreshAddToWatchlist
                    
                    var errorMessage:String = "Unable to add video to watchlist."
                    
                    if showObject != nil {
                        
                        errorMessage = "Unable to add show to watchlist."
                    }
                    if self.videoDescriptionView != nil && self.videoDescriptionView?.iOSVideoPlayer != nil
                    {
                        self.videoDescriptionView?.iOSVideoPlayer?.playVideo()
                    }
                    self.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, filmObject: filmObject, showObject: showObject, errorMessage: errorMessage, errorTitle: "Watchlist",  button: button)
                }
            })
        }
    }
    
    
    //MARK:Display Error in removing from watchlist
    func showWatchlistAlertForAlertType(alertType: AlertType, filmObject:SFFilm?,showObject: SFShow?, errorMessage:String?, errorTitle:String?, button:SFButton?) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
            if button?.isSelected != nil {
                
                button?.isSelected = !(button?.isSelected)!
            }
            else {
                
                button?.isSelected = false
            }
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                if button?.isSelected != nil {
                    
                    button?.isSelected = !(button?.isSelected)!
                }
                else {
                    
                    button?.isSelected = false
                }
                
                self.updateVideoWatchlistStatus(button: button!, filmObject: filmObject, showObject: showObject)
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
        
        self.present(networkUnavailableAlert!, animated: true, completion: nil)
    }

    
    //MARK - Show/Hide Activity Indicator
    func showActivityIndicator(loaderText:String?) {
        
        progressIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        if loaderText != nil {
            
            progressIndicator?.label.text = loaderText!
        }
    }
    
    
    func hideActivityIndicator() {
        
        progressIndicator?.hide(animated: true)
    }
    
    //MARK: Orientation Method
    override func viewDidLayoutSubviews() {
        
        if !Constants.IPHONE {
            
            UIView.performWithoutAnimation {
                
                self.tableView?.contentOffset = CGPoint(x: 0, y: 0)
                self.tableView?.scrollsToTop = true
                
                tableView?.changeFrameWidth(width: UIScreen.main.bounds.width)
                tableView?.changeFrameHeight(height: UIScreen.main.bounds.size.height)

                if TEMPLATETYPE.lowercased() != Constants.kTemplateTypeSports.lowercased() {
                    
                    tableView?.frame.size.height -= Utility.sharedUtility.getPosition(position: 20)
                }
                
                if videoDescriptionView != nil {
                    
                    var moduleHeight: CGFloat = CGFloat(Utility.fetchVideoDetailLayoutDetails(videoDetailObject: self.videoDescriptionView!.videoDescriptionModule).height!)
                    let moduleWidth: CGFloat = self.view.frame.width
                    moduleHeight = moduleHeight * Utility.getBaseScreenHeightMultiplier()
                    
                    self.videoDescriptionView?.changeFrameHeight(height: moduleHeight)
                    self.videoDescriptionView?.changeFrameWidth(width: moduleWidth)
                    
                    self.videoDescriptionView?.updateView()
                }
                
                if showDescriptionView != nil {
                    
                    var moduleHeight: CGFloat = CGFloat(Utility.fetchShowDetailLayoutDetails(showDetailObject: self.showDescriptionView!.showDescriptionModule).height!)

                    let pageAPIModuleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(self.showDescriptionView!.showDescriptionModule?.moduleID ?? "")"] as? SFModuleObject
                    
                    var showObject:SFShow?
                    
                    if pageAPIModuleObject != nil && self.showDescriptionView!.showDescriptionModule != nil {
                        
                        showObject = pageAPIModuleObject!.moduleData![0] as? SFShow
                        
                        moduleHeight = CGFloat(self.calculateCellHeightFromCellComponents(showViewObject: self.showDescriptionView!.showDescriptionModule!, noOfData: Float(showObject?.seasons?[selectedSeason].episodes?.count ?? 0)))
                    }
                    
                    let moduleWidth: CGFloat = self.view.frame.width
                    moduleHeight = moduleHeight * Utility.getBaseScreenHeightMultiplier()
                    
                    self.showDescriptionView?.changeFrameHeight(height: moduleHeight)
                    self.showDescriptionView?.changeFrameWidth(width: moduleWidth)
                    self.showDescriptionView?.updateView()
                }
                
                if watchlistStatusUpdateLabel != nil {
                    
                    self.watchlistStatusUpdateLabel?.frame = UIScreen.main.bounds
                }
                self.updateControlBarsVisibility()
            }
        }
        else
        {
            if videoDescriptionView != nil {
                
                var moduleHeight: CGFloat = CGFloat(Utility.fetchVideoDetailLayoutDetails(videoDetailObject: self.videoDescriptionView!.videoDescriptionModule).height!)
                let moduleWidth: CGFloat = self.view.frame.width
                moduleHeight = moduleHeight * Utility.getBaseScreenHeightMultiplier()
                
                self.videoDescriptionView?.changeFrameHeight(height: moduleHeight)
                self.videoDescriptionView?.changeFrameWidth(width: moduleWidth)
                
                self.videoDescriptionView?.updateView()
            }
        }

        if self.tableHeaderView != nil {
            
            for subView in (tableHeaderView?.subviews)! {
                
                if subView is UIButton {
                    
                    subView.changeFrameWidth(width: (tableView?.frame.size.width)!)
                }
                else if subView is SFBannerView {
                    
                    let bannerView = subView as! SFBannerView
                    
                    bannerView.changeFrameWidth(width: (tableView?.frame.size.width)!)
                    bannerView.updateSubViewFrames()
                }
            }
        }
    }
    
    //MARK: Scroll View Delegates
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if TEMPLATETYPE.lowercased() != Constants.kTemplateTypeSports.lowercased() {

            let tableOffsetYAxis:Double = Double((tableView?.contentOffset.y)!)

            if tableOffsetYAxis < 0.0 {

                let screenHeight:Double = Double(UIScreen.main.bounds.height)

                if (tableOffsetYAxis * -1) >= (screenHeight / 5) && isViewDismissAnimationStarted == false {

                    isViewDismissAnimationStarted = true

                    let screenBounds = UIScreen.main.bounds
                    let bottomLeftCorner = CGPoint(x: 0, y: screenBounds.height)
                    let finalFrame = CGRect(origin: bottomLeftCorner, size: screenBounds.size)

                    if self.videoDescriptionView?.iOSVideoPlayer != nil {
                        
                        self.videoDescriptionView?.iOSVideoPlayer?.view.removeFromSuperview()
                        self.videoDescriptionView?.iOSVideoPlayer?.removeFromParentViewController()
                    }
                    
                    Constants.kAPPDELEGATE.isFullScreenEnabled = false

                    if Constants.IPHONE {
                        
                        let value = UIInterfaceOrientation.portrait.rawValue
                        UIDevice.current.setValue(value, forKey: "orientation")
                    }
                    UIView.animate(withDuration: 0.4, animations: {

                        self.tableView?.frame = finalFrame

                    }, completion: { (_) in

                        let transition: CATransition = CATransition()
                        transition.duration = 0
                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                        transition.type = kCATransitionFade
                        transition.subtype = kCATransitionFromTop

                        if self.view.window != nil {

                            self.view.window!.layer.add(transition, forKey: nil)
                            self.dismiss(animated: false, completion: {
                            
                                Constants.kAPPDELEGATE.isFullScreenEnabled = false

                            })
                        }
                    })
                }
            }
        }
    }
    
    
    func showWatchlistStatusUpdateView(viewText:String) {
        
        watchlistStatusUpdateLabel = UILabel(frame: UIScreen.main.bounds)
        watchlistStatusUpdateLabel?.text = viewText
        watchlistStatusUpdateLabel?.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 17.0)
        watchlistStatusUpdateLabel?.textAlignment = .center
        watchlistStatusUpdateLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "fffff")
        watchlistStatusUpdateLabel?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000").withAlphaComponent(0.9)
        self.view.addSubview(self.watchlistStatusUpdateLabel!)
        self.watchlistStatusUpdateLabel?.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            
            self.watchlistStatusUpdateLabel?.alpha = 1.0
            
        }) { (finished) in
            
            UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
                
                self.watchlistStatusUpdateLabel?.alpha = 0.0
                
            }, completion: { (finished) in
                
                self.watchlistStatusUpdateLabel?.removeFromSuperview()
                self.watchlistStatusUpdateLabel = nil
                if self.videoDescriptionView != nil && self.videoDescriptionView?.iOSVideoPlayer != nil
                {
                    self.videoDescriptionView?.iOSVideoPlayer?.playVideo()
                }
            })
        }
    }
    
    
    //MARK: Display Network Error Alert
    func showAlertForAlertType(alertType: AlertType, isAlertForVideoDetailAPI:Bool, contentId:String?, alertTitle:String?, alertMessage:String?) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
            
                if isAlertForVideoDetailAPI && !self.isRelatedVideoClicked {
                    
                    if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                if isAlertForVideoDetailAPI {
                    
                    self.fetchPageContent()
                }
                else {
                    
                    self.fetchVideoURLToBePlayed(contentId: contentId!)
                }
            }
        }
        
        var alertTitleString:String = alertTitle ?? "No Response Received"
        var alertMessage:String = alertMessage ?? "Unable to fetch data!\nDo you wish to Try Again?"
        
        if alertType == .AlertTypeNoInternetFound {
            alertTitleString = Constants.kInternetConnection
            alertMessage = Constants.kInternetConntectionRefresh
        }
        
        networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString, alertMessage: alertMessage, alertActions: [closeAction, retryAction])
        
        self.present(networkUnavailableAlert!, animated: true, completion: nil)
    }
    
    
    //MARK: Banner View delegates
    func displayMorePopUpView(button: UIButton, gridOptionsArray: Array<SFLinkObject>) {
        
        var moreOptionArray:Array<Dictionary<String, Any>> = []
        
        for linkObject in gridOptionsArray {
            
            moreOptionArray.append(["option":linkObject.title ?? "", "navLink":linkObject.displayedPath ?? ""])
        }
        
        self.presentMorePopUpView(moreOptionArray: moreOptionArray, contentId: nil, isOptionForBannerView: true)
    }
    
    //MARK: Method to display more pop up option array
    private func presentMorePopUpView(moreOptionArray:Array<Dictionary<String, Any>>, contentId:String?, isOptionForBannerView: Bool) {
        self.view.isUserInteractionEnabled = false
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        Utility.presentMorePopUpView(moreOptionArray: moreOptionArray, contentId: contentId, contentType: nil, isModel: self.isModal, delegate: self, isOptionForBannerView: isOptionForBannerView);
    }
    
    
    //MARK: - Video Description View Delegate
    func didSeasonSelectorButtonClicked(dropDownButton: SFDropDownButton?) {
        
        if showObject != nil {
            
            if showObject?.seasons != nil {
                
                let seasonSelectorModule:SeasonDropdownViewController = SeasonDropdownViewController.init(seasonArray: (showObject?.seasons)!, selectedSeasonNumber: selectedSeason)

                seasonSelectorModule.completionHandler = { [weak self] (isSelectedUpdated, selectedSeason) in
                    
                    if isSelectedUpdated {
                        
                        if let checkedSelf = self {
                            
                            checkedSelf.selectedSeason = selectedSeason
                            checkedSelf.cellModuleDict.removeValue(forKey: "\(String(checkedSelf.showRowId))")
                            
                            checkedSelf.tableView?.reloadRows(at: [IndexPath.init(row: checkedSelf.showRowId, section: 0)], with: UITableViewRowAnimation.fade)
//                            checkedSelf.tableView?.reloadData()
                            
                            if TEMPLATETYPE.lowercased() != Constants.kTemplateTypeSports.lowercased() {
                                checkedSelf.tableView?.scrollsToTop = true
                                checkedSelf.tableView?.contentOffset = CGPoint(x: 0, y: 0)
                            }
                        }
                    }
                }
                
                seasonSelectorModule.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000").withAlphaComponent(0.90)
                seasonSelectorModule.modalPresentationStyle = .overCurrentContext
                self.present(seasonSelectorModule, animated: true, completion: nil)
            }
        }
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    
    
    func videoPlayerFullScreenTapped(videoPlayer:CustomVideoController?, isFullScreenButtonTapped: Bool) -> Void
    {
        if videoPlayer != nil {
            UIApplication.shared.isStatusBarHidden = true
            self.navigationController?.navigationBar.isHidden = true
            videoPlayer?.view.removeFromSuperview()
            videoPlayer?.setPlayerFit(videoPlayerFit: .fullScreen)
            self.view.addSubview((videoPlayer?.view)!)

            if isFullScreenButtonTapped {
                
                if Constants.IPHONE {
                    
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                }
                else {
                    
                    Constants.kAPPDELEGATE.isFullScreenEnabled = true
                }
            }

            self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            videoPlayer?.view.frame = self.view.bounds
            videoPlayer?.playMedia()
        }
    }
    
    
    func videoPlayerExitFullScreenTapped(videoPlayer:CustomVideoController?) -> Void
    {
        if videoPlayer != nil {
            
            Constants.kAPPDELEGATE.isFullScreenEnabled = false
            UIApplication.shared.isStatusBarHidden = false
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.isTranslucent = false
            
            videoPlayer?.setPlayerFit(videoPlayerFit: .smallScreen)
            
            if videoPlayer?.avPlayer.currentItem != nil {
                
                if videoPlayer?.avPlayer.currentItem?.currentTime() != nil {
                    
                    videoDuration = CMTimeGetSeconds((videoPlayer?.avPlayer.currentItem?.currentTime())!)
                }
            }
            
            videoPlayer?.view.removeFromSuperview()
            videoPlayer?.removeFromParentViewController()
            if Constants.IPHONE{
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
            
            if self.isVideoPlayingInFullScreen {

                if tableView != nil {

                    self.isVideoPlayingInFullScreen = false
                    self.tableView?.reloadData()
                    if self.tableView?.indexPathsForVisibleRows != nil {

                        self.tableView?.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
                    }
                    else {

                        self.tableView?.scrollsToTop = true
                    }

                    self.tableView?.setContentOffset(CGPoint.zero, animated: false)
                }
            }
            
            self.videoDescriptionView?.reAttachSmallVideoPlayer()

//            else
//            {
//
//            }
        }
    }
    
    func videoPlayerFinishedPlayingMedia(videoPlayer: CustomVideoController?)
    {
//        isVideoPlaying = false
        var viewControllerPage:Page?
        
        if videoPlayer?.playerFit == PlayerFit.fullScreen {

            //Constants.kAPPDELEGATE.isFullScreenEnabled = true
            isVideoPlayingInFullScreen = true
        }
//        else {
//            isVideoPlaying = false
//        }

        var filePath:String = ""
        filePath = AppSandboxManager.getpageFilePath(fileName: Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Video Page") ?? "")
        
        if !filePath.isEmpty {
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                
                let pageParser = PageUIParser()
                viewControllerPage = pageParser.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
            }
        }
        //Constants.kAPPDELEGATE.isFullScreenEnabled = false

        if viewControllerPage != nil {
            
            self.isRelatedVideoClicked = true
            self.viewControllerPage = viewControllerPage
            self.contentId = videoPlayer?.getVideoDetail().videoContentId ?? ""
            self.pagePath = videoPlayer?.getVideoDetail().gridPermalink ?? ""
//            videoPlayer?.removeFromParentViewController()
//            videoPlayer?.view.removeFromSuperview()
            self.fetchPageContent()
        }
    }
    
    func videoPlayerAdded(videoPlayer: CustomVideoController?) {
        isVideoPlaying = true
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if isVideoPlaying && Constants.IPHONE {
            
            if videoDescriptionView != nil {
                
                if videoDescriptionView?.iOSVideoPlayer != nil {
                    
                    if size.width > size.height {
                        
                        self.videoPlayerFullScreenTapped(videoPlayer: videoDescriptionView?.iOSVideoPlayer, isFullScreenButtonTapped: false)
                    }
                    else {
                        
                        self.videoPlayerExitFullScreenTapped(videoPlayer: videoDescriptionView?.iOSVideoPlayer)
                    }
                }
            }
        }
    }
}
