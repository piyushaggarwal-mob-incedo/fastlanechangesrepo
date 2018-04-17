//
//  PageViewController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 21/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import DrawerController
import AVKit
import AVFoundation
import GoogleCast
import Firebase
enum AlertType {
    case AlertTypeNoInternetFound
    case AlertTypeNoResponseReceived
}

class PageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,CollectionGridViewDelegate,CarouselViewControllerDelegate, AVPlayerViewControllerDelegate, CollectionGridViewDelegate1, GCKUIMiniMediaControlsViewControllerDelegate, tutorialEventsDelegate, VerticalCollectionGridDelegate, SFMorePopUpViewControllerDelegate, ListViewControllerDelegate, SFBannerViewDelegate, VideoPlayerDelegate,LiveVideoPlaybackDelegate,SFKisweBaseViewControllerDelegate {
    

    let attributedStringDict = [NSFontAttributeName: UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 14)! , NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")]

    enum CompeletionHandlerOptions {
        
        case UpdateWatchlist
        case UpdateVideoPlay
    }
    
    var navItem:NavigationItem?
    var viewControllerPage: Page?
    var tableView:UITableView?
    var pageAPIObject:PageAPIObject?
    let networkStatus = NetworkStatus.sharedInstance
    var isUserLoggedIn:Bool = false
    var pageId:String?
    var pagePath:String?
    var displayCancelIcon:Bool = false
    var displayBackButton:Bool = false
    var videoViewCell:UITableViewCell?
    private var castFirstTimeController:CastTutorialViewController?
    private var modulesListDict:Dictionary<String, Any> = [:]
    private var progressIndicator:MBProgressHUD?
    private var modulesListArray:Array<Any> = []
    private var videoPlayerController:AVPlayerViewController?
    private var refreshControl:UIRefreshControl?
    private var fetchRequestInProcess:Bool = false
    private var alertType:AlertType?
    private var networkUnavailableAlert:UIAlertController?
    private var cellModuleDict:Dictionary<String, AnyObject> = [:]
    private var _miniMediaControlsContainerView: UIView!
    private var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    private var chromecastButton:UIButton!
    private var isPageUpdatedAfterBackgroundContentRefresh:Bool = false
    private var isTableHeaderAvailable:Bool = false
    private var tableHeaderView:UIView?
    private var bannerViewObject:SFBannerViewObject?
    private var videoPlayerObject: VideoPlayerModuleViewObject?
    private var iOSVideoPlayer: CustomVideoController?
    private var previousDeviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
    private var isPipVisible:Bool = false
    private var isForcePIPClose:Bool = false
    private var swipeRight : UISwipeGestureRecognizer?
    private var swipeLeft : UISwipeGestureRecognizer?
    private let upperBorder = CALayer()
    private var adViewHeightDict:Dictionary<String, Any> = [:]
    init(viewControllerPage:Page) {
        
        self.viewControllerPage = viewControllerPage
        super.init(nibName: nil, bundle: nil)
    }
    
    init(viewControllerPage:Page, navItem:NavigationItem?) {
        
        self.viewControllerPage = viewControllerPage
        self.navItem = navItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        
        createTableView()
        
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased(){
            
            self.automaticallyAdjustsScrollViewInsets = true
            self.edgesForExtendedLayout = []
        }
        
        if let subNavItems = navItem?.subNavItems {
            
            if subNavItems.count == 0 {
                
                self.createRefreshControl()
            }
        }
        else {
            
            createRefreshControl()
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserLoginStatusFlag), name: NSNotification.Name(rawValue: "UserLoggedInStatusUpdated"), object: nil)
        // Do any additional setup after loading the view.
        self.addMiniCastControllerToViewController(viewController: self)
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(enteredBackground), name: NSNotification.Name("ApplicationEnteredBackground"), object: nil)
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(enteresForeground), name: NSNotification.Name("ApplicationEnteredForeground"), object: nil)

        if AppConfiguration.sharedAppConfiguration.isPIPAvailable == true{
            Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(dismissPIP), name: NSNotification.Name(rawValue: Constants.kDismissPIP), object: nil)
        }
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(refreshCastButton), name: NSNotification.Name("ApplicationResumeCasting"), object: nil)
    }
    
    func refreshCastButton() {
        let castImage =  UIImage(named: Constants.IMAGE_NAV_BUTTON_CHROMECAST_CONNECTED)
        if chromecastButton != nil {
            chromecastButton.setImage(castImage, for: .normal)
        }
        updateControlBarsVisibility()
    }

    //MARK: Orientation Method
    override func viewDidLayoutSubviews() {
        
        if !Constants.IPHONE {
            self.updateControlBarsVisibility()
            
            if self.chromecastButton != nil {
                
                //CastPopOverView.shared.updateAlertFramesOnOrientation(chromeCastButton: chromecastButton, vc: self)
                self.perform(#selector(rotateCastpopOver), with: nil, afterDelay: 0.01)
            }

            if self.isPipVisible == true {
                 self.iOSVideoPlayer?.view.frame =  CGRect(x: self.view.bounds.size.width - (Constants.IPHONE ? Constants.kPIPWidth_iPhone: Constants.kPIPWidth_iPad) - 15, y: self.view.bounds.size.height - (Constants.IPHONE ? Constants.kPIPHeight_iPhone: Constants.kPIPHeight_iPad) - 64, width: (Constants.IPHONE ? Constants.kPIPWidth_iPhone: Constants.kPIPWidth_iPad), height: (Constants.IPHONE ? Constants.kPIPHeight_iPhone: Constants.kPIPHeight_iPad))
            }
        }
        else
        {
            if self.isPipVisible == true {
                self.iOSVideoPlayer?.view.frame =  CGRect(x: self.view.bounds.size.width - (Constants.IPHONE ? Constants.kPIPWidth_iPhone: Constants.kPIPWidth_iPad) - 15, y: self.view.bounds.size.height - (Constants.IPHONE ? Constants.kPIPHeight_iPhone: Constants.kPIPHeight_iPad) - 64, width: (Constants.IPHONE ? Constants.kPIPWidth_iPhone: Constants.kPIPWidth_iPad), height: (Constants.IPHONE ? Constants.kPIPHeight_iPhone: Constants.kPIPHeight_iPad))
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
    
    
    func rotateCastpopOver()  {
        CastPopOverView.shared.updateAlertFramesOnOrientation(chromeCastButton: chromecastButton, vc: self)
    }

    // MARK: - Internal methods
    func updateControlBarsVisibility() {
        
        if (self.miniMediaControlsViewController != nil){
            var variance:CGFloat = 0
            if (Constants.IPHONE && Utility.sharedUtility.isIphoneX()){
                variance = 20;
            }
            
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                
                _miniMediaControlsContainerView.frame = CGRect(x: 0, y: self.view.frame.size.height - 64.0, width: UIScreen.main.bounds.width, height: 0)
            }
            else {
                
                _miniMediaControlsContainerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - Utility.sharedUtility.getPosition(position: (112 + variance)), width: UIScreen.main.bounds.width, height: 0)
            }
            
            if self.miniMediaControlsViewController.active && CastPopOverView.shared.isConnected() {
                _miniMediaControlsContainerView.changeFrameHeight(height: 64)
                self.view.bringSubview(toFront: _miniMediaControlsContainerView)
                
                if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                    
                    tableView?.changeFrameHeight(height: self.view.bounds.size.height - 64.0)
                }
                else {
                    
                    tableView?.changeFrameHeight(height: UIScreen.main.bounds.size.height - Utility.sharedUtility.getPosition(position: (112 + variance)))
                }
                
            } else {
                _miniMediaControlsContainerView.changeFrameHeight(height: 0)
                tableView?.changeFrameHeight(height: self.view.bounds.size.height)
            }
        }
    }
    
    // MARK: - GCKUIMiniMediaControlsViewControllerDelegate
    func miniMediaControlsViewController(_ miniMediaControlsViewController: GCKUIMiniMediaControlsViewController,
                                         shouldAppear: Bool) {
        
        self.updateControlBarsVisibility()
    }
    
    func addMiniCastControllerToViewController(viewController: UIViewController) {
        
        // Do any additional setup after loading the view.
        _miniMediaControlsContainerView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - Utility.sharedUtility.getPosition(position: 112), width: UIScreen.main.bounds.width, height: 0))
        viewController.view.addSubview(_miniMediaControlsContainerView)
        
        self.miniMediaControlsViewController = GCKCastContext.sharedInstance().createMiniMediaControlsViewController()
        self.miniMediaControlsViewController.delegate = self
        self.miniMediaControlsViewController.view.frame = _miniMediaControlsContainerView.bounds
        _miniMediaControlsContainerView.addSubview(self.miniMediaControlsViewController.view)
        
        self.updateControlBarsVisibility()
    }
    
     
    func updateUserLoginStatusFlag() {
        isUserLoggedIn = true
        self.tableView?.scrollsToTop = true
        self.tableView?.reloadData()
    }
    
    
    func networkConnectionChanged() {
        
        loadPageData()
        if self.presentedViewController != nil && networkUnavailableAlert != nil {
            
            if (self.presentedViewController?.isKind(of: UIAlertController.self))! {
                
                networkUnavailableAlert?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //Called when app files are updated
    func applicationUpdated()  {
        
        updatePageLayoutIfNeeded()
        if self.isPageUpdatedAfterBackgroundContentRefresh {
            
            loadPageData()
        }        
    }
    
    
    private func updatePageLayoutIfNeeded() {
        
        var zz: Int = 0
        for localPage in AppConfiguration.sharedAppConfiguration.pages
        {
            if localPage.pageId == self.viewControllerPage?.pageId ?? self.pageId
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
                    isPageUpdatedAfterBackgroundContentRefresh = true
                    AppConfiguration.sharedAppConfiguration.pages[zz] = localPage
                    break
                }
            }
            zz = zz + 1
        }
    }
    
    
    // Called when app is configured.
    func applicationConfigured()
    {
        Constants.kAPPDELEGATE.dimissSoftAppUpdateAlert {
            
            if Utility.sharedUtility.shouldDisplayForceUpdate() {
                
                Constants.kAPPDELEGATE.presentAppUpdateView(isForceUpdate: true)
            }
            else if Utility.sharedUtility.shouldDisplaySoftUpdate() {
                
                Constants.kAPPDELEGATE.presentAppUpdateView(isForceUpdate: false)
            }
        }
    }
    
    func displayAppUpdateView() {
        
        if Utility.sharedUtility.shouldDisplayForceUpdate() {
            
            Constants.kAPPDELEGATE.presentAppUpdateView(isForceUpdate: true)
        }
        else if Utility.sharedUtility.shouldDisplaySoftUpdate() {
            
            Constants.kAPPDELEGATE.presentAppUpdateView(isForceUpdate: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector:#selector(networkConnectionChanged), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        
        let updateNavItem = fetchNavItemFromPageId(pageId: viewControllerPage?.pageId ?? self.pageId)
        
        if updateNavItem != nil {
            
            self.navItem = updateNavItem
        }
        
        loadPageData()
        
        if Utility.sharedUtility.shouldDisplayForceUpdate() {
            
            Constants.kAPPDELEGATE.presentAppUpdateView(isForceUpdate: true)
        }
        else if Utility.sharedUtility.shouldDisplaySoftUpdate() {
            
            Constants.kAPPDELEGATE.presentAppUpdateView(isForceUpdate: false)
        }
//        self.applicationConfigured()
        //MARK: Will need to change as per the force update options.
        self.updateControlBarsVisibility()
        if iOSVideoPlayer != nil
        {
            iOSVideoPlayer?.playVideo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        if self.iOSVideoPlayer != nil {
            Constants.kAPPDELEGATE.isFullScreenEnabled = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        if iOSVideoPlayer != nil
        {
            iOSVideoPlayer?.pauseVideo()
        }
    }
    
    func showPIPOnViewAppear() {
        if self.isForcePIPClose == true{
            self.isForcePIPClose = false
            self.addVideoPlayer()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLeftMenuButton()
        createNavigationBar()
        
        self.updateControlBarsVisibility()
        if self.iOSVideoPlayer != nil {
            self.iOSVideoPlayer?.setCastPopOverViewDelegate(vc: self.iOSVideoPlayer!)
            Constants.kAPPDELEGATE.isFullScreenEnabled = true
        }
        
        if self.viewControllerPage?.pageName != nil{
            self.trackGAEvent(pageTitle: self.viewControllerPage?.pageName)
        }
        self.showPIPOnViewAppear()
    }
    
    //MARK: Method to fetch update nav item for page from tab bar items
    private func fetchNavItemFromPageId(pageId:String?) -> NavigationItem? {
        
        if pageId != nil {
            
            if let navItemsArray = AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["tabBar"] {
                
                for navItem in navItemsArray {
                    
                    if navItem.pageId == pageId! {
                        
                        return navItem
                    }
                }
            }
        }
        return nil
    }
    
    
    //MARK: Method to track GA Event
    func trackGAEvent(pageTitle: String?) -> Void {
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            FIRAnalytics.setScreenName(pageTitle ?? "Page Screen", screenClass: nil)
        }

        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.allowIDFACollection = true
        tracker.set(kGAIScreenName, value: pageTitle ?? "Page Screen")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func enteredBackground()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kUpdateAppNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kAppConfigureNotification), object: nil)
    }
    
    
    func enteresForeground()
    {
        NotificationCenter.default.addObserver(self, selector:#selector(applicationUpdated), name: NSNotification.Name(rawValue: Constants.kUpdateAppNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(applicationConfigured), name: NSNotification.Name(rawValue: Constants.kAppConfigureNotification), object: nil)
    }
    
    
    func createNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        self.navigationItem.titleView = Utility.createNavigationTitleView(navBarHeight: (self.navigationController?.navigationBar.frame.size.height)!)
        
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
            
            self.createLeftNavItems()
        }
        
        createRightNavBarItems()
    }
    
    func castButtonTapped(sender: AnyObject){
        
        CastPopOverView.shared.chooseDevice(chromeCastButton: sender as! UIButton, vc: self)
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
        
        if self.displayBackButton {

//            let image = UIImage(named: "Back")
            
            let backButton = UIButton(type: .custom)
            backButton.sizeToFit()
            let cancelButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "Back.png"))
            
            backButton.setImage(cancelButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            backButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
            
            backButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (cancelButtonImageView.image?.size.height)!/2)
            backButton.addTarget(self, action: #selector(backButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
            
            let backButtonItem = UIBarButtonItem(customView: backButton)
            
            self.navigationItem.leftBarButtonItems = [negativeSpacer, backButtonItem]
        }
        else {
            
//            let image = UIImage(named: "icon-user")
            
            let userAccountButton = UIButton(type: .custom)
            userAccountButton.sizeToFit()
            let userButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "icon-user.png"))
            
            userAccountButton.setImage(userButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            userAccountButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
            
            userAccountButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (userButtonImageView.image?.size.height)!/2)
            userAccountButton.addTarget(self, action: #selector(userAccountButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
            
            let userAccountButtonItem = UIBarButtonItem(customView: userAccountButton)
            
            self.navigationItem.leftBarButtonItems = [negativeSpacer, userAccountButtonItem]
        }
    }
    
    
    func userAccountButtonClicked(sender:AnyObject) {
        
        var ii = 0
        for navigationItem in AppConfiguration.sharedAppConfiguration.navigationMenu.navigationItemDict["tabBar"] ?? []
        {
            if let navTitle = navigationItem.title {
             
                if navTitle.lowercased() == "Menu".lowercased() || navTitle.lowercased() == "More".lowercased() {
                   
                    break
                }
            }
            
            ii += 1
        }
        
        Constants.kAPPDELEGATE.openTabBarWith(barIndex: ii)
    }
    
    func backButtonClicked(sender:AnyObject) {
        
        NotificationCenter.default.removeObserver(self)
        
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
            
            self.navigationController?.popViewController(animated: true)
        }
        else {
            
            self.dismiss(animated: true, completion: nil)
        }
    }

    //MARK: Creation of right nav items for sports template
    private func createRightNavItemsForPage() {
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15
        
        var righBarItems:Array<UIBarButtonItem> = []
        
        if displayCancelIcon == true {
//            let image = UIImage(named: "cancelIcon")
            
            let cancelButton = UIButton(type: .custom)
            cancelButton.sizeToFit()
            let cancelButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "cancelIcon.png"))
            
            cancelButton.setImage(cancelButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            cancelButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
            cancelButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (cancelButtonImageView.image?.size.height)!/2)

            cancelButton.addTarget(self, action: #selector(cancelButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
            
            let cancelButtonItem = UIBarButtonItem(customView: cancelButton)
            righBarItems = [negativeSpacer, cancelButtonItem]
        }
        else
        {
            var castImage = UIImage(named: Constants.IMAGE_NAV_BUTTON_CHROMECAST_NORMAL)
            if CastPopOverView.shared.isConnected(){
                castImage = UIImage(named: Constants.IMAGE_NAV_BUTTON_CHROMECAST_CONNECTED)
            }
            
            chromecastButton = UIButton(type: .custom)
            chromecastButton.sizeToFit()
            chromecastButton.addTarget(self, action: #selector(castButtonTapped(sender:)), for: .touchDown)
            chromecastButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (castImage?.size.height)!/2)
            chromecastButton.setImage(castImage, for: .normal)
            let listOfAvailableDevices = SecondScreenDeviceProvider.shared.allAvailableDevices()
            if listOfAvailableDevices.count > 0{
                chromecastButton.isHidden = false
            }
            else{
                chromecastButton.isHidden = false
            }
            let chromeButtonItem = UIBarButtonItem(customView: chromecastButton)
            righBarItems = [negativeSpacer, chromeButtonItem]
            firstTimeSetup()
        }
        
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
        
            if let rightNavBarItems = AppConfiguration.sharedAppConfiguration.rightNavItems {
                
                for navObject in rightNavBarItems {
                    
                    let navButton = self.createDyanmicRighNavItems(navObject: navObject)
                    let navButtonItem = UIBarButtonItem(customView: navButton)
                    righBarItems.append(navButtonItem)
                }
            }
        }
        else {
            
            if displayCancelIcon == false {
                
                if let rightNavBarItems = AppConfiguration.sharedAppConfiguration.rightNavItems {
                    
                    for navObject in rightNavBarItems {
                        
                        let navButton = self.createDyanmicRighNavItems(navObject: navObject)
                        let navButtonItem = UIBarButtonItem(customView: navButton)
                        righBarItems.append(navButtonItem)
                    }
                }
            }
        }
        
        self.navigationItem.rightBarButtonItems = righBarItems
    }
    
    
    private func createDyanmicRighNavItems(navObject:SFNavigationObject) -> SFButton {
        
        let navButton = SFButton(type: .custom)
        
//        let navImage = UIImage(named: navObject.iconName ?? "icon-search")
        navButton.sizeToFit()
        let searchButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "icon-search.png"))
        
        navButton.setImage(searchButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        navButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        
        navButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (searchButtonImageView.image?.size.height)!/2)

        if navObject.pagePath == "/search" {
            
            navButton.addTarget(self, action: #selector(searchButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        }
        
        return navButton
    }
    
    
    func searchButtonClicked(sender: AnyObject) {
     
        let searchViewController: SearchViewController = SearchViewController()
        searchViewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        searchViewController.shouldDisplayBackButtonOnNavBar = true
        
        if let topController = Utility.sharedUtility.topViewController() {
            
            topController.navigationController?.pushViewController(searchViewController, animated: true)
        }
    }

    
    func cancelButtonClicked(sender:AnyObject) {
        
        NotificationCenter.default.removeObserver(self)
        
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
            
            self.navigationController?.popViewController(animated: true)
        }
        else {
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    private func createRefreshControl() {
     
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshPageContent(refreshControl:)), for: .valueChanged)

        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to Refresh", attributes: attributedStringDict)
        
        refreshControl?.tintColor = UIColor.white
        refreshControl?.beginRefreshing()
        refreshControl?.endRefreshing()
        
        tableView?.addSubview(refreshControl!)
    }
    
    
    func refreshPageContent(refreshControl:UIRefreshControl) {
        
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing data...", attributes: attributedStringDict)
        fetchPageContent()
    }
    func pipCrossPressed()
    {
        self.isForcePIPClose = true
        self.isPipVisible = false
        if self.iOSVideoPlayer != nil {
            self.addPlayerView(frame: (videoViewCell?.frame)!, containerView: self.videoViewCell!)
            DispatchQueue.main.async {
                self.iOSVideoPlayer?.pauseVideo()
                self.iOSVideoPlayer?.isForcePaused = true
            }
        }
    }
    private func getAttributedTitleForRefreshControl()-> NSAttributedString {
        
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        let lastUpdate:String = "Last updated at \(formatter.string(from: Date.init()))"
        
        return NSAttributedString.init(string: lastUpdate, attributes: attributedStringDict)
    }
    
    private func setupLeftMenuButton() {
        if !AppConfiguration.sharedAppConfiguration.appHasTabBar
        {
            let leftDrawerButton = DrawerBarButtonItem(target: self, action: #selector(leftDrawerButtonPress(_:)))
            self.navigationItem.setLeftBarButton(leftDrawerButton, animated: true)
        }
    }
    
    func leftDrawerButtonPress(_ sender: AnyObject?) {
        let drawerController:DrawerController = Constants.kAPPDELEGATE.drawerController!
        drawerController.toggleDrawerSide(.left, animated: true, completion: nil)
    }

    
    //MARK: Load Page Data
    private func loadPageData() {
       
        if let subNavItems = navItem?.subNavItems {
            
            if subNavItems.count == 0 {
                
                self.loadPageDataFromAPI()
            }
            else {
                
                self.loadPageDataFromTemplate()
            }
        }
        else {
            
            loadPageDataFromAPI()
        }
    }
    
    
    //MARK: Method to load page data from template
    private func loadPageDataFromTemplate() {
        
        self.modulesListArray.removeAll()
        self.modulesListDict.removeAll()
        self.cellModuleDict.removeAll()
        self.adViewHeightDict.removeAll()
        self.createPageModuleLayoutList()
        
        self.tableView?.isHidden = false
        self.tableView?.scrollsToTop = true
        self.tableView?.reloadData()
    }
    
    
    //MARK: Method to load page data from api
    private func loadPageDataFromAPI() {
        
        if (pageAPIObject == nil || isUserLoggedIn || isPageUpdatedAfterBackgroundContentRefresh)  && fetchRequestInProcess == false {
            
            fetchPageContent()
        }
        
        if fetchRequestInProcess == true && (refreshControl?.isRefreshing)! {
            
            let offset = tableView?.contentOffset
            refreshControl?.endRefreshing()
            refreshControl?.beginRefreshing()
            tableView?.contentOffset = offset!
        }
    }
    
    //MARK: Method to fetch page module layout list
    private func createPageModuleLayoutList() {
        
        if viewControllerPage?.modules != nil {
            
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
                else if module is SFListViewObject {
                    
                    let listViewObject:SFListViewObject = module as! SFListViewObject
                    modulesListDict["\(listViewObject.listViewId!)"] = listViewObject
                    modulesListArray.append(listViewObject)
                }
                else if module is SFBannerViewObject {
                    
                    self.bannerViewObject = module as? SFBannerViewObject
                    self.isTableHeaderAvailable = true
                }
                else if module is VideoPlayerModuleViewObject {
                    let livePlayerObject = module as! VideoPlayerModuleViewObject
                    modulesListDict["\(livePlayerObject.moduleID!)"] = livePlayerObject
                    modulesListArray.append(livePlayerObject)
                }
                else if module is SFVerticalArticleViewObject {

                    let verticalArticleViewObject = module as! SFVerticalArticleViewObject

                    if checkIfModuleComingInServerResponse(moduleId: verticalArticleViewObject.moduleId) {

                        modulesListDict["\(verticalArticleViewObject.moduleId!)"] = verticalArticleViewObject
                        modulesListArray.append(verticalArticleViewObject)
                    }
                }
            }
        }
    }
    
    
    private func checkIfModuleComingInServerResponse(moduleId:String?) -> Bool {
        
        let pageAPIModuleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(moduleId ?? "")"] as? SFModuleObject
        
        if pageAPIModuleObject != nil {
            
            return true
        }
        
        return false
    }
    
    
   //MARK: Method to fetch page content
    private func fetchPageContent() {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            fetchRequestInProcess = false
            Constants.kAPPDELEGATE.navigateToDownload(callback: { (isDownload) in
                if isDownload != nil && isDownload == false
                {
                    self.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
                }
            })
        }
        else {
            
            fetchRequestInProcess = true
            
            if !(refreshControl?.isRefreshing)! {
                
                DispatchQueue.main.async {
                    self.showActivityIndicator(loaderText: "Loading...")
                }
            }
            
            DispatchQueue.global(qos: .userInitiated).async
            {
                var apiEndPoint = "\(self.viewControllerPage?.pageAPI ?? "/content/pages")?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&includeContent=true"
                
                if self.viewControllerPage?.pageId != nil {
                    
                    apiEndPoint = apiEndPoint.appending("&pageId=\(self.viewControllerPage?.pageId ?? "")")
                }
                else if self.pageId != nil {
                    
                    apiEndPoint = apiEndPoint.appending("&pageId=\(self.pageId ?? "")")
                }
                else if self.pagePath != nil {
                    
                    apiEndPoint = apiEndPoint.appending("&path=\(self.pagePath ?? "")")
                }
                
                if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                    
                    apiEndPoint = apiEndPoint.appending("&includeWatchHistory=true&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")")
                }
                
                var shouldUseCacheUrl:Bool = self.viewControllerPage?.shouldUseCacheAPI ?? false
                
                if shouldUseCacheUrl && self.isPageUpdatedAfterBackgroundContentRefresh {
                    
                    shouldUseCacheUrl = false
                }
                
                DataManger.sharedInstance.fetchContentForPage(shouldUseCacheUrl: shouldUseCacheUrl, apiEndPoint: apiEndPoint) { (pageAPIObjectResponse) in
                    
                    DispatchQueue.main.async {
                        
                        if self.isPageUpdatedAfterBackgroundContentRefresh {
                            self.isPageUpdatedAfterBackgroundContentRefresh = false
                        }
                        
                        self.isUserLoggedIn = false
                        self.fetchRequestInProcess = false
                        self.progressIndicator?.hide(animated: true)
                        
                        if (self.refreshControl?.isRefreshing)! {
                            
                            self.refreshControl?.attributedTitle = self.getAttributedTitleForRefreshControl()
                            self.refreshControl?.endRefreshing()
                        }
                        
                        if pageAPIObjectResponse != nil && pageAPIObjectResponse?.pageModules != nil {
                            
                            self.pageAPIObject = nil
                            self.pageAPIObject = pageAPIObjectResponse
                            self.isForcePIPClose = false
                            self.updatePageLayoutIfNeeded()
                            self.modulesListArray.removeAll()
                            self.modulesListDict.removeAll()
                            self.cellModuleDict.removeAll()
                            self.adViewHeightDict.removeAll()
                            self.createPageModuleLayoutList()
                            self.tableView?.isHidden = false
                            self.tableView?.scrollsToTop = true
                            self.tableView?.reloadData()
                        }
                        else {
                            
                            self.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived)
                        }
                    }
                }
            }
        }
    }
    
    private func showActivityIndicator(loaderText:String?) {
        
        progressIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        if loaderText != nil {
            
            progressIndicator?.label.text = loaderText!
        }
    }
    
    private func hideActivityIndicator() {
        
        progressIndicator?.hide(animated: true)
    }

    //MARK: Method to create table view
    private func createTableView() {

        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.view.bounds.size.height), style: .plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.backgroundView = nil
        tableView?.backgroundColor = UIColor.clear
        tableView?.showsVerticalScrollIndicator = false
        
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased(){
            
            tableView?.clipsToBounds = false
        }
        
        self.view.addSubview(tableView!)
        self.tableView?.isHidden = false
    }

    
    //MARK: Table View Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let subNavItems = navItem?.subNavItems {
            
            if subNavItems.count > 0 && self.modulesListArray.count > 0{
                
                return subNavItems.count
            }
        }
        
        return pageAPIObject?.pageModules?.count ?? 0
    }
    func addVideoPlayer() -> Void {
        if AppConfiguration.sharedAppConfiguration.isPIPAvailable == true {
            if self.isVideoPlayerVisible() == false {
                if self.iOSVideoPlayer != nil && Constants.kAPPDELEGATE.isBackgroundImageVisible == false {
                    if self.isPipVisible == false{
                        self.isPipVisible = true
                        
                        self.addPlayerView(frame: CGRect(x: self.view.bounds.size.width - (Constants.IPHONE ? Constants.kPIPWidth_iPhone: Constants.kPIPWidth_iPad) - 15, y: self.view.bounds.size.height - (Constants.IPHONE ? Constants.kPIPHeight_iPhone: Constants.kPIPHeight_iPad) - 64, width: (Constants.IPHONE ? Constants.kPIPWidth_iPhone: Constants.kPIPWidth_iPad), height: (Constants.IPHONE ? Constants.kPIPHeight_iPhone: Constants.kPIPHeight_iPad)), containerView: self.view)
                    }
                }
            }
            else
            {
                if self.isPipVisible == true && self.iOSVideoPlayer?.playerFit == .smallScreen {
                    self.isPipVisible = false
                    if self.iOSVideoPlayer != nil {
                        self.addPlayerView(frame: (videoViewCell?.frame)!, containerView: self.videoViewCell!)
                    }
                }
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        DispatchQueue.main.async {
            if self.isForcePIPClose == false{
                self.addVideoPlayer()
            }
            else if (self.isVideoPlayerVisible() == false)
            {
                if self.iOSVideoPlayer != nil{
                    self.iOSVideoPlayer?.pauseVideo()
                }
            }
            else {
                if self.iOSVideoPlayer != nil{
                    self.iOSVideoPlayer?.playMedia()
                }
            }
        }
    }

    func isVideoPlayerVisible() -> Bool {
        
        let indexes = tableView?.indexPathsForVisibleRows
        if indexes != nil{
            for index: IndexPath in indexes! {
                if index.row == 0 {
                    return true
                }
            }
        }
        return false
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier:String = "gridCell"
        var cell:UITableViewCell? = cellModuleDict["\(String(indexPath.row))"] as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
            cell?.contentView.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
            cell?.selectionStyle = .none
            
            if indexPath.row > modulesListArray.count - 1{
                return cell!
            }
            let module:Any = modulesListArray[indexPath.row] as Any
            var moduleId:String?
            
            if module is SFTrayObject {
                
                let trayObject:SFTrayObject? = module as? SFTrayObject
                moduleId = trayObject?.trayId
            }
            else if module is SFJumbotronObject {
                
                let jumbotronObject:SFJumbotronObject? = module as? SFJumbotronObject
                moduleId = jumbotronObject?.trayId
            }
            else if module is SFListViewObject {
                
                let listViewObject:SFListViewObject? = module as? SFListViewObject
                moduleId = listViewObject?.listViewId
            }
            else if module is VideoPlayerModuleViewObject
            {
                let videoObjectModule: VideoPlayerModuleViewObject? = module as? VideoPlayerModuleViewObject
                moduleId = videoObjectModule?.moduleID
            }
            else if module is SFVerticalArticleViewObject {
            
                moduleId = (module as! SFVerticalArticleViewObject).moduleId
            }
            
            let pageAPIModuleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(moduleId ?? "")"] as? SFModuleObject
            
            if module is SFTrayObject && pageAPIModuleObject != nil {
                
                if (module as! SFTrayObject).trayViewName == "AC Grid 01" {
                 
                    addVerticalCollectionGridToTableCell(cell: cell!, pageModuleObject: pageAPIModuleObject!)
                }
                else {
                    
                    addCollectionGridToTable(cell: cell!, pageModuleObject: pageAPIModuleObject!, cellIndex: indexPath.row)
                }
                
                cellModuleDict["\(String(indexPath.row))"] = cell!
            }
            else if module is SFJumbotronObject && pageAPIModuleObject != nil {
                
                addCarouselToTable(cell: cell!, pageModuleObject: pageAPIModuleObject!)
                
                cellModuleDict["\(String(indexPath.row))"] = cell!
            }
            else if module is SFListViewObject {
                
                addListViewCellToTableCell(cell: cell!, viewModuleObject: module as! SFListViewObject)
                cellModuleDict["\(String(indexPath.row))"] = cell!
            }
            else if module is VideoPlayerModuleViewObject && pageAPIModuleObject != nil
            {
                addVideoPlayer(cell: cell!, pageModuleObject: pageAPIModuleObject!)
                cellModuleDict["\(String(indexPath.row))"] = cell!
            }
            else if module is SFVerticalArticleViewObject && pageAPIModuleObject != nil {
                
                
            }
        }
        
        return cell!
    }

    
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
                            
                            headerHeight += CGFloat(Constants.IPHONE ? 40 : 55)
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 170.0
        if indexPath.row > modulesListArray.count - 1{
            return 0
        }
        
        let module:Any = modulesListArray[indexPath.row] as Any
        
        if module is SFTrayObject {
            
            let trayObject:SFTrayObject? = module as? SFTrayObject
            
            if trayObject?.trayViewName == "AC Grid 01" {
                
                let pageAPIModuleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(trayObject?.trayId ?? "")"] as? SFModuleObject

                rowHeight = CGFloat(Utility.sharedUtility.calculateCellHeightFromCellComponents(trayObject: trayObject!, noOfData: Float(pageAPIModuleObject?.moduleData?.count ?? 0))) * Utility.getBaseScreenHeightMultiplier()
            }
            else if trayObject?.trayViewName == "AC BannerAd 01" {
                
                if self.adViewHeightDict.isEmpty && self.adViewHeightDict["\(String(indexPath.row))"] == nil {
                    
                    rowHeight = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject!).height ?? 170)
                }
                else {
                    
                    rowHeight = self.adViewHeightDict["\(String(indexPath.row))"] as? CGFloat ?? CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject!).height ?? 170)
                }
            }
            else {
                
                rowHeight = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject!).height ?? 170)
            }
        }
        else if module is SFJumbotronObject {
            
            let jumbotronObject:SFJumbotronObject? = module as? SFJumbotronObject
            rowHeight = CGFloat(Utility.fetchCarouselLayoutDetails(carouselViewObject: jumbotronObject!).height ?? 400)
            rowHeight = rowHeight * Utility.getBaseScreenHeightMultiplier()
        }
        else if module is SFListViewObject {
            
            if let subItems = navItem?.subNavItems {
                
                let listViewObject:SFListViewObject = module as! SFListViewObject
                rowHeight = CGFloat(Utility.sharedUtility.calculateCellHeightFromCellComponents(listViewObject: listViewObject, noOfData: Float(subItems.count))) * Utility.getBaseScreenHeightMultiplier()
            }
        }
        else if module is VideoPlayerModuleViewObject {
            
            rowHeight = self.view.frame.width * 9/16
        }
        else if module is SFVerticalArticleViewObject {
            
            let verticalArticleViewObject = module as! SFVerticalArticleViewObject
            let moduleLayoutCalculator = ModuleLayoutCalculator()
            
            if let pageAPIModuleObject:SFModuleObject = pageAPIObject?.pageModules?["\(verticalArticleViewObject.moduleId ?? "")"] as? SFModuleObject {
                
                var relativeViewFrameDict:Dictionary<String, CGRect> = [Constants.kSTRING_IPHONE_ORIENTATION_TYPE : CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)]
                
                if Constants.IPHONE {
                    
                    relativeViewFrameDict["\(Constants.kSTRING_IPHONE_ORIENTATION_TYPE)"] = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                }
                else {
                    
                    if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height {
                        
                        relativeViewFrameDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        relativeViewFrameDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
                    }
                    else {
                        
                        relativeViewFrameDict["\(Constants.kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE)"] = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        relativeViewFrameDict["\(Constants.kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE)"] = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
                    }
                }
                let _ = moduleLayoutCalculator.fetchLayoutDetailsForModule(pageAPIModuleObject: pageAPIModuleObject, moduleUIObject: verticalArticleViewObject, relativeViewFrameDict: relativeViewFrameDict)
            }
        }
        return rowHeight
    }
    
    
    //MARK: Method to add carousel to table view cell
    private func addCarouselToTable(cell:UITableViewCell, pageModuleObject:SFModuleObject) {
        
        let jumbotronObject:SFJumbotronObject? = modulesListDict["\(pageModuleObject.moduleId ?? "")"] as? SFJumbotronObject

        var rowHeight:CGFloat = CGFloat(Utility.fetchCarouselLayoutDetails(carouselViewObject: jumbotronObject!).height ?? 400)
        rowHeight = rowHeight * Utility.getBaseScreenHeightMultiplier()

        let cellFrame:CGRect = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: UIScreen.main.bounds.width, height: rowHeight)
        
        let carouselViewController:CarousalViewController = CarousalViewController()
        carouselViewController.view.frame = cellFrame
        
        carouselViewController.relativeViewFrame = cellFrame
        carouselViewController.isCarouselHidden = false
        carouselViewController.delegate = self
        carouselViewController.carouselObject = jumbotronObject
        carouselViewController.pageModuleObject = pageModuleObject
        carouselViewController.createSubViews()
        self.addChildViewController(carouselViewController)
        cell.addSubview(carouselViewController.view)
    }
    
    
    //MARK: Method to add grids to table view cell
    private func addCollectionGridToTable(cell:UITableViewCell, pageModuleObject:SFModuleObject, cellIndex:Int) {
        
        let trayObject:SFTrayObject = modulesListDict["\(pageModuleObject.moduleId ?? "")"] as! SFTrayObject
        let collectionGridViewController:CollectionGridViewController = CollectionGridViewController(trayObject: trayObject)
        
        let rowHeight:CGFloat = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject).height ?? 170)
        let cellFrame:CGRect = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: UIScreen.main.bounds.width, height: rowHeight)

        collectionGridViewController.view.frame = cellFrame//Utility.initialiseViewLayout(viewLayout: Utility.fetchTrayLayoutDetails(trayObject: trayObject), relativeViewFrame: cellFrame)
        collectionGridViewController.relativeViewFrame = collectionGridViewController.view.frame
        collectionGridViewController.delegate = self
        collectionGridViewController.moduleAPIObject = pageModuleObject
        collectionGridViewController.cellIndex = cellIndex
        collectionGridViewController.createSubViews()
        self.addChildViewController(collectionGridViewController)
        cell.addSubview(collectionGridViewController.view)
    }

    
    //MARK: Method to add vertical collection grid to table view cell
    private func addVerticalCollectionGridToTableCell(cell:UITableViewCell, pageModuleObject:SFModuleObject) {
        
        let trayObject:SFTrayObject = modulesListDict["\(pageModuleObject.moduleId ?? "")"] as! SFTrayObject
        let collectionGridViewController:VerticalCollectionGridController = VerticalCollectionGridController(trayObject: trayObject)
        
        let rowHeight:CGFloat = CGFloat(Utility.sharedUtility.calculateCellHeightFromCellComponents(trayObject: trayObject, noOfData: Float(pageModuleObject.moduleData?.count ?? 0)))
        let cellFrame:CGRect = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: UIScreen.main.bounds.width, height: rowHeight)
        let collectionGridFrame = Utility.initialiseViewLayout(viewLayout: Utility.fetchTrayLayoutDetails(trayObject: trayObject), relativeViewFrame: cellFrame)
        
        collectionGridViewController.view.frame = CGRect(x: collectionGridFrame.origin.x, y: collectionGridFrame.origin.y, width: collectionGridFrame.size.width, height: rowHeight)
        collectionGridViewController.relativeViewFrame = collectionGridViewController.view.frame
        collectionGridViewController.delegate = self
        collectionGridViewController.moduleAPIObject = pageModuleObject
        collectionGridViewController.createSubViews()
        self.addChildViewController(collectionGridViewController)
        cell.addSubview(collectionGridViewController.view)
    }
    
    
    //MARK: Method to add list view object to table view cell
    private func addListViewCellToTableCell(cell:UITableViewCell, viewModuleObject:SFListViewObject) {
        
        if let subItems = navItem?.subNavItems {
            
            let rowHeight:CGFloat = CGFloat(Utility.sharedUtility.calculateCellHeightFromCellComponents(listViewObject: viewModuleObject, noOfData: Float(subItems.count))) * Utility.getBaseScreenHeightMultiplier()
            let cellFrame:CGRect = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: UIScreen.main.bounds.width, height: rowHeight)
            
            let listViewController:ListViewController = ListViewController(moduleObject: viewModuleObject, subNavItemsArray: subItems)
            listViewController.view.frame = CGRect(x: cellFrame.origin.x, y: cellFrame.origin.y, width: cellFrame.size.width, height: rowHeight)
            listViewController.relativeViewFrame = listViewController.view.frame
            listViewController.delegate = self
            listViewController.createSubViews()
            self.addChildViewController(listViewController)
            cell.addSubview(listViewController.view)
        }
    }
    
    //MARK: Method to add video player to tableview cell
    private func addVideoPlayer(cell:UITableViewCell, pageModuleObject:SFModuleObject)
    {
        let gridObject: SFGridObject = (pageModuleObject.moduleData?[0] as? SFGridObject)!
        
        let videoControllerObject: VideoObject = VideoObject()
        videoControllerObject.videoTitle = gridObject.contentTitle ?? ""
        videoControllerObject.videoPlayerDuration = gridObject.totalTime ?? 0
        videoControllerObject.videoContentId = gridObject.contentId ?? ""
        videoControllerObject.gridPermalink = gridObject.gridPermaLink ?? ""
        videoControllerObject.videoWatchedTime = gridObject.watchedTime ?? 0
        videoControllerObject.contentRating = gridObject.parentalRating ?? ""

        if (gridObject.eventId != nil && Constants.kAPPDELEGATE.isKisweEnable == true) {
            
            let cellFrame:CGRect = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: UIScreen.main.bounds.width, height: self.view.frame.width * 9/16)
            let videoDescriptionView : LiveKiswePlayerDescriptionViewController = LiveKiswePlayerDescriptionViewController.init(frame: cellFrame, gridObject: gridObject)
            videoDescriptionView.liveVideoPlaybackDelegate = self
            self.addChildViewController(videoDescriptionView)
            cell.addSubview(videoDescriptionView.view)
        }
        else{
            
            let isLiveVideo = gridObject.isLiveStream ?? false
            if iOSVideoPlayer != nil{
                if self.swipeRight != nil{
                    iOSVideoPlayer?.view.removeGestureRecognizer(self.swipeRight!)
                }
                if self.swipeLeft != nil{
                    iOSVideoPlayer?.view.removeGestureRecognizer(self.swipeLeft!)
                }
                iOSVideoPlayer?.view.removeFromSuperview()
                iOSVideoPlayer?.removeFromParentViewController()
            }
            if Constants.IPHONE {
                Constants.kAPPDELEGATE.isFullScreenEnabled = true
            }
            iOSVideoPlayer = CustomVideoController.init(videoObject: videoControllerObject, videoPlayerType: isLiveVideo ? .liveVideoPlayer : .streamVideoPlayer, videoFitType: .smallScreen)
            iOSVideoPlayer?.videoPlayerDelegate = self
            iOSVideoPlayer?.isVideoPlayedFromGrids = true
            let cellFrame:CGRect = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.frame.width, height: cell.frame.height)
            iOSVideoPlayer?.view.frame = cellFrame
            videoViewCell = cell

            self.swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeLeftGesture))
            self.swipeRight?.direction = UISwipeGestureRecognizerDirection.left
            iOSVideoPlayer?.view.addGestureRecognizer(self.swipeRight!)

            self.swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeRightGesture))
            self.swipeLeft?.direction = UISwipeGestureRecognizerDirection.right
            iOSVideoPlayer?.view.addGestureRecognizer(self.swipeLeft!)

            self.addChildViewController(iOSVideoPlayer!)
            cell.addSubview((iOSVideoPlayer?.view)!)
        }
    }
    
    //MARK: Method to add vertical article grid view
    private func addVertialArticleGridViewToTableViewCell(cell:UITableViewCell, pageModuleObject:SFModuleObject) {
        
        let verticalArticleViewObject:SFVerticalArticleViewObject = modulesListDict["\(pageModuleObject.moduleId ?? "")"] as! SFVerticalArticleViewObject
        let collectionGridViewController:SFVerticalArticleGridViewController = SFVerticalArticleGridViewController(verticalArticleViewObject: verticalArticleViewObject)
        
//        let rowHeight:CGFloat = CGFloat(Utility.sharedUtility.calculateCellHeightFromCellComponents(trayObject: trayObject, noOfData: Float(pageModuleObject.moduleData?.count ?? 0)))
        let verticalArticleViewLayout = Utility.fetchVerticalArticleViewLayoutDetails(verticalArticleViewObject: verticalArticleViewObject)
        let cellFrame:CGRect = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: UIScreen.main.bounds.width, height: CGFloat(verticalArticleViewLayout.height ?? 500.0))//rowHeight)
        let collectionGridFrame = Utility.initialiseViewLayout(viewLayout: Utility.fetchVerticalArticleViewLayoutDetails(verticalArticleViewObject: verticalArticleViewObject), relativeViewFrame: cellFrame)
        
        collectionGridViewController.view.frame = CGRect(x: collectionGridFrame.origin.x, y: collectionGridFrame.origin.y, width: collectionGridFrame.size.width, height: collectionGridFrame.size.height)//rowHeight)
        collectionGridViewController.relativeViewFrame = collectionGridViewController.view.frame
//        collectionGridViewController.delegate = self
        collectionGridViewController.moduleAPIObject = pageModuleObject
        collectionGridViewController.createSubViews()
        self.addChildViewController(collectionGridViewController)
        cell.addSubview(collectionGridViewController.view)
    }
    
    
    //MARK: Swipe Gesture Event handler
    func respondToSwipeLeftGesture(gesture: UIGestureRecognizer){
        if self.isPipVisible == true && self.iOSVideoPlayer?.playerFit == .smallScreen {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.iOSVideoPlayer?.view.changeFrameXAxis(xAxis: 0)
            }, completion: { (complete : Bool) in
                self.pipCrossPressed()
            })
        }
    }

    func respondToSwipeRightGesture(gesture: UIGestureRecognizer){
        if self.isPipVisible == true && self.iOSVideoPlayer?.playerFit == .smallScreen{
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.iOSVideoPlayer?.view.changeFrameXAxis(xAxis: UIScreen.main.bounds.size.width)
            }, completion: { (complete : Bool) in
                self.pipCrossPressed()
            })
        }
    }

    //MARK: Kiswe View Controller Delegate
    func removeKisweBaseViewController(viewController:UIViewController) -> Void{
        self.view.isUserInteractionEnabled = true
    }
    
    //MARK:Collection Grid Delegates and Carousel Delegate
    func updateAdViewTrayHeight(adViewHeight: CGFloat, cellIndex:Int) {
        
        self.adViewHeightDict["\(String(cellIndex))"] = adViewHeight
        self.tableView?.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
    func didSelectVideo(gridObject: SFGridObject?) {
        
        let eventId = gridObject?.eventId
        if eventId != nil && Constants.kAPPDELEGATE.isKisweEnable {
            
            Utility.presentKiswePlayer(forEventId: eventId!, withFilmId: gridObject?.contentId ?? "", vc:self)
        }
        else {
            
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
            else if gridObject?.contentType?.lowercased() == Constants.kArticleContentType
            {
               filePath = AppSandboxManager.getpageFilePath(fileName: Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Article Page") ?? "")
            }
            else{
                filePath = AppSandboxManager.getpageFilePath(fileName: Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Video Page") ?? "")
            }
        
            if !filePath.isEmpty {
                let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
                
                if jsonData != nil {
                    let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                    
                    viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
                }
            }
            
            if viewControllerPage != nil {
                    var videoDetailViewController:VideoDetailViewController!
                    
                    if gridObject?.contentType?.lowercased() == Constants.kVideoContentType || gridObject?.contentType?.lowercased() == Constants.kVideosContentType
                    {
                        videoDetailViewController = VideoDetailViewController(viewControllerPage: viewControllerPage!, pageType: .videoDetail)
                    }
                    else if gridObject?.contentType?.lowercased() == Constants.kShowContentType || gridObject?.contentType?.lowercased() == Constants.kShowsContentType
                    {
                        videoDetailViewController = VideoDetailViewController(viewControllerPage: viewControllerPage!, pageType: .showDetail)
                    }
                    else {
                        videoDetailViewController = VideoDetailViewController(viewControllerPage: viewControllerPage!, pageType: .videoDetail)
                    }
                    
                    videoDetailViewController.contentId = gridObject?.contentId ?? ""
                    videoDetailViewController.pagePath = gridObject?.gridPermaLink ?? ""
                    videoDetailViewController.view.changeFrameYAxis(yAxis: 20.0)
                    videoDetailViewController.view.changeFrameHeight(height: videoDetailViewController.view.frame.height - 20.0)
                    
                    if let topController = Utility.sharedUtility.topViewController() {
                        
                        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                            
                            topController.navigationController?.pushViewController(videoDetailViewController, animated: true)
                        }
                        else {
                            
                            topController.present(videoDetailViewController, animated: true, completion: {
                                
                            })
                        }
                    }
            }
        }
    }
    
    func didCarouselButtonClicked(contentId: String?, buttonAction: String, gridObject:SFGridObject) {
     
        if buttonAction == "watchVideo" {
            
            if Utility.sharedUtility.checkIfDownloadAlertToBeDisplayedInOfflineMode() {
                
                Utility.sharedUtility.displayOfflineAlertToPlayDownloadVideo(viewController: self)
            }
            else {
            
                if let contentType = gridObject.contentType {
                    
                    if contentType.lowercased() == Constants.kShowContentType || contentType.lowercased() == Constants.kShowsContentType
                    {
                        let filePath = AppSandboxManager.getpageFilePath(fileName: Utility.sharedUtility.getPageIdFromPagesArray(pageName: "Show Page") ?? "")
                        
                        if !filePath.isEmpty {
                            
                            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
                            
                            if jsonData != nil {
                                
                                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                                
                                viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
                            }
                        }
                        
                        if viewControllerPage != nil {
                            
                            let videoDetailViewController = VideoDetailViewController(viewControllerPage: viewControllerPage!, pageType: .showDetail)
                            videoDetailViewController.contentId = gridObject.contentId ?? ""
                            videoDetailViewController.pagePath = gridObject.gridPermaLink ?? ""
                            videoDetailViewController.view.changeFrameYAxis(yAxis: 20.0)
                            videoDetailViewController.view.changeFrameHeight(height: videoDetailViewController.view.frame.height - 20.0)
                            
                            if let topController = Utility.sharedUtility.topViewController() {
                                
                                if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                                    
                                    topController.navigationController?.pushViewController(videoDetailViewController, animated: true)
                                }
                                else {
                                    
                                    topController.present(videoDetailViewController, animated: true, completion: {
                                        
                                    })
                                }
                            }
                        }
                    }
                    else {
                        
                        self.playVideoAfterCarouselButtonClick(button: nil, contentId: contentId, gridObject: gridObject)
                    }
                }
                else {
                    
                    self.playVideoAfterCarouselButtonClick(button: nil, contentId: contentId, gridObject: gridObject)
                }
            }
        }
    }
    
    
    //MARK: Play Video
    private func playVideoAfterCarouselButtonClick(button:SFButton?, contentId:String?, gridObject:SFGridObject) {
        
        var isFreeVideo:Bool = false
        
        if gridObject.isFreeVideo == true {
            
            isFreeVideo = true
        }
        
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && isFreeVideo == false {
            
            checkIfUserIsEntitledToVideo(button: nil, contentId: contentId, gridObject: gridObject)
        }
        else {
            
            playVideo(contentId: contentId, gridObject:gridObject)
        }
    }
    
    
    func didPlayVideo(contentId: String?, button: SFButton, gridObject: SFGridObject?) {
        
        if contentId != nil && gridObject != nil {
            
            if Utility.sharedUtility.checkIfDownloadAlertToBeDisplayedInOfflineMode() {
                
                Utility.sharedUtility.displayOfflineAlertToPlayDownloadVideo(viewController: self)
            }
            else {
                
                 let eventId = gridObject?.eventId
                if eventId != nil && Constants.kAPPDELEGATE.isKisweEnable{
                    
                    Utility.presentKiswePlayer(forEventId: eventId!, withFilmId: gridObject?.contentId ?? "", vc: self)
                }
                else{
                    if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                        
                        checkIfUserIsEntitledToVideo(button: nil, contentId: contentId!, gridObject: gridObject!)
                    }
                    else {
                        
                        playVideo(contentId: contentId!, gridObject:gridObject!)
                    }
                }
            }
        }
    }
    
    
    func didDisplayMorePopUp(button: SFButton, gridObject: SFGridObject?) {
    
        if gridObject != nil {
            
            if let contentId = gridObject?.contentId , let contentType = gridObject?.contentType {
                
                var moreOptionArray:Array<Dictionary<String, Any>> = []
                
                if contentType.lowercased() == Constants.kArticlesContentType || contentType.lowercased() == Constants.kArticleContentType {
                    
                }
                else if contentType.lowercased() == Constants.kVideoContentType || contentType.lowercased() == Constants.kVideosContentType {
                    
                    moreOptionArray.append(["option":"watchlist"])
                    
                    if let isDownloadEnabled = AppConfiguration.sharedAppConfiguration.isDownloadEnabled {
                        
                        if isDownloadEnabled {
                            
                            moreOptionArray.append(["option":"download"])
                        }
                    }
                }
                
                self.presentMorePopUpView(moreOptionArray: moreOptionArray, contentId: contentId, contentType: contentType, isOptionForBannerView: false)
            }
        }
    }
    
    
    //MARK: Method to display more pop up option array
    private func presentMorePopUpView(moreOptionArray:Array<Dictionary<String, Any>>, contentId:String?, contentType:String?, isOptionForBannerView:Bool) {
        self.view.isUserInteractionEnabled = false
        Utility.presentMorePopUpView(moreOptionArray: moreOptionArray, contentId: contentId, contentType: contentType, isModel: self.isModal, delegate: self, isOptionForBannerView: isOptionForBannerView)
    }
    
    
    //MARK: More popover controller delegate
    func removePopOverViewController(viewController: UIViewController) {
        self.view.isUserInteractionEnabled = true
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    //MARK: Method to check if user is entitled or not
    private func checkIfUserIsEntitledToVideo(button: SFButton?, contentId: String?, gridObject:SFGridObject) {
        
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
                                
                                self.playVideo(contentId: contentId, gridObject: gridObject)
                            }
                            else {
                                
                                self.subscriptionStatusFail(button: button, contentId: contentId, gridObject: gridObject)
                            }
                        }
                        else {
                            
                            if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                
                                Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                            }
                            
                            self.subscriptionStatusFail(button: button, contentId: contentId, gridObject: gridObject)
                        }
                    }
                })
            }
        }
        else {
            self.playVideo(contentId: contentId, gridObject: gridObject)
        }
    }
    

    private func subscriptionStatusFail(button: SFButton?, contentId: String?, gridObject:SFGridObject) {
        
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
                    self.playVideo(contentId: contentId, gridObject: gridObject)
                })
            }
        }
        else {
            
            self.playVideo(contentId: contentId, gridObject: gridObject)
        }
    }
    
    
    private func updateSubscriptionStatusWithReceipt(button: SFButton?, contentId: String, gridObject:SFGridObject,  productIdentifier: String?, transactionIdentifier:String?) {
        
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
                        self.playVideo(contentId: contentId, gridObject: gridObject)
                })
            }
            else {
                self.playVideo(contentId: contentId, gridObject: gridObject)
            }
        }
        else {
            self.playVideo(contentId: contentId, gridObject: gridObject)
        }
    }
    
    /**
     Method to update subscription info with user
     @param receipt transaction receipt
     */
    private func updateSubscriptionInfoWithReceiptdata(receipt: NSData?, emailId:String?, productIdentifier:String?, transactionIdentifier:String?, success: @escaping ((_ isSuccess:Bool) -> Void))
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
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    Constants.kAPPDELEGATE.removePlistFromDocumentDirectory(plistName: Constants.kTransactionDetailPlistName)

                    success(true)
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
    
    
    private func displayNonEntitledUserAlert(button: SFButton?, contentId: String, gridObject:SFGridObject) {
        
        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
            
        }
        
        let signInAction = UIAlertAction(title: Constants.kStrSign, style: .default) { (signInAction) in
            
            self.displayLoginScreen(button: button, contentId: contentId, gridObject: gridObject, loginCompeletionHandlerType: .UpdateVideoPlay)
        }
        
        let subscriptionAction = UIAlertAction(title: Constants.kStrSubscription, style: .default) { (subscriptionAction) in
            
            self.displayPlanPage(button: button, contentId: contentId, gridObject: gridObject, loginCompeletionHandlerType: .UpdateVideoPlay)
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
    
    
    private func displayPlanPage(button:SFButton?, contentId: String, gridObject:SFGridObject, loginCompeletionHandlerType:CompeletionHandlerOptions) -> Void {
        
        displayPlanPageWithCompletionHandler(button: button, contentId: contentId, gridObject: gridObject) { (isSuccessfullyLoggedIn) in
            
            if isSuccessfullyLoggedIn {
                
                if loginCompeletionHandlerType == CompeletionHandlerOptions.UpdateVideoPlay {
                    
                    self.playVideo(contentId: contentId, gridObject: gridObject)
                }
            }
        }
    }
    
    
    private func displayPlanPageWithCompletionHandler(button:SFButton?, contentId: String, gridObject:SFGridObject, completionHandler: @escaping ((_ isSuccessfullyLoggedIn: Bool) -> Void)) -> Void {
        
        let planViewController:SFProductListViewController = SFProductListViewController.init()
        planViewController.completionHandlerCopy = completionHandler
        let navigationController = UINavigationController.init(rootViewController: planViewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
    private func displayLoginScreen(button:SFButton?, contentId: String, gridObject:SFGridObject, loginCompeletionHandlerType:CompeletionHandlerOptions) -> Void {
        
        displayLoginViewWithCompletionHandler(button: button, contentId: contentId, gridObject: gridObject) { (isSuccessfullyLoggedIn) in
            
            if isSuccessfullyLoggedIn {
                
                if loginCompeletionHandlerType == CompeletionHandlerOptions.UpdateVideoPlay {
                    
                    self.checkIfUserIsEntitledToVideo(button: button, contentId: contentId, gridObject: gridObject)
                }
            }
        }
    }
    
    
    private func displayLoginViewWithCompletionHandler(button:SFButton?, contentId: String, gridObject:SFGridObject, completionHandler: @escaping ((_ isSuccessfullyLoggedIn: Bool) -> Void)) -> Void {
        
        let loginViewController: LoginViewController = LoginViewController.init()
        loginViewController.loginPageSelection = 0
        loginViewController.pageScreenName = "Sign In Screen"
        loginViewController.loginType = loginPageType.authentication
        loginViewController.completionHandlerCopy = completionHandler
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: loginViewController)
        self.present(navigationController, animated: true, completion: nil)
    }

    private func playVideo(contentId:String?, gridObject:SFGridObject) {
        
        if contentId != nil {

            let eventId = gridObject.eventId
            if eventId != nil && Constants.kAPPDELEGATE.isKisweEnable{
                
                Utility.presentKiswePlayer(forEventId: eventId!, withFilmId: gridObject.contentId ?? "", vc: self)
            }
            else {
                
                if CastPopOverView.shared.isConnected() {
                    
                    if  Utility.sharedUtility.checkIfMoviePlayable() == true || gridObject.isFreeVideo == true {
                        CastController().playSelectedItemRemotely(contentId: gridObject.contentId ?? "", isDownloaded:  false, relatedContentIds: nil, contentTitle: gridObject.contentTitle ?? "")
                    }
                    else {
                        
                        Utility.sharedUtility.showAlertForUnsubscribeUser()
                    }
                }
                else {
                    
                    let videoObject: VideoObject = VideoObject()
                    videoObject.videoTitle = gridObject.contentTitle ?? ""
                    videoObject.videoPlayerDuration = gridObject.totalTime ?? 0
                    videoObject.videoContentId = gridObject.contentId ?? ""
                    videoObject.gridPermalink = gridObject.gridPermaLink ?? ""
                    videoObject.videoWatchedTime = gridObject.watchedTime ?? 0
                    videoObject.contentRating = gridObject.parentalRating ?? ""
                    
                    let playerViewController: CustomVideoController = CustomVideoController.init(videoObject: videoObject, videoPlayerType: .streamVideoPlayer, videoFitType: .fullScreen)
                    self.present(playerViewController, animated: true, completion: nil)
                }
            }
        }
        else {
            
            let alertController = UIAlertController(title: "Error", message: "Error is loading details", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: Constants.kStrOk, style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: Memory warning methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Display Network Error Alert 
    private func showAlertForAlertType(alertType: AlertType) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                if (self.refreshControl?.isRefreshing)! {
                    
                    self.refreshControl?.endRefreshing()
                }
            }
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                if (self.refreshControl?.isRefreshing)! {
                    
                    self.refreshControl?.endRefreshing()
                }
                self.fetchPageContent()
            }
        }
        
        var alertTitleString:String?
        var alertMessage:String?
        
        if alertType == .AlertTypeNoInternetFound {
            alertTitleString = Constants.kInternetConnection
            alertMessage = Constants.kInternetConntectionRefresh
        }
        else {
            alertTitleString = "No Response Received"
            alertMessage = "Unable to fetch data!\nDo you wish to Try Again?"
        }
        
        networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction, retryAction])
        
        self.present(networkUnavailableAlert!, animated: true, completion: nil)
    }
    
    
    //MARK: ListView Controller delegates
    func didListViewSelected(navigationItem: NavigationItem?) {
        
        if navigationItem?.pageId != nil && navigationItem?.pageUrl != nil {
            if let title = navigationItem?.title{
                self.trackGAEvent(pageTitle:title)
            }

            self.loadPageViewController(pageName: (navigationItem?.pageId)!, pagePath: (navigationItem?.pageUrl)!)
        }
    }
    
    
    //MARK: - Method to load ancillary view controller
    private func loadPageViewController(pageName:String, pagePath:String) {
        
        var viewControllerPage:Page?
        let filePath:String = AppSandboxManager.getpageFilePath(fileName: pageName)
        if !filePath.isEmpty {
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)

            }
        }
        
        if viewControllerPage != nil {
            
            let pageViewController:PageViewController = PageViewController(viewControllerPage: viewControllerPage!)
            pageViewController.view.changeFrameYAxis(yAxis: 20.0)
            pageViewController.view.changeFrameHeight(height: pageViewController.view.frame.height - 20.0)
            pageViewController.pagePath = pagePath
            pageViewController.pageId = pageName

            if let topController = Utility.sharedUtility.topViewController() {
                
                if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                    
                    pageViewController.displayBackButton = true
                    topController.navigationController?.pushViewController(pageViewController, animated: true)
                }
                else {
                    
                    pageViewController.displayCancelIcon = true

                    let navController:UINavigationController = UINavigationController(rootViewController: pageViewController)

                    topController.present(navController, animated: true, completion: {
                        
                    })
                }
            }
        }
    }
    
    
    //MARK: Banner View delegates
    func displayMorePopUpView(button: UIButton, gridOptionsArray: Array<SFLinkObject>) {
        
        var moreOptionArray:Array<Dictionary<String, Any>> = []
        
        for linkObject in gridOptionsArray {
            
            moreOptionArray.append(["option":linkObject.title ?? "", "navLink":linkObject.displayedPath ?? ""])
        }

        self.presentMorePopUpView(moreOptionArray: moreOptionArray, contentId: nil, contentType: nil, isOptionForBannerView: true)
    }
    
    
    private func firstTimeSetup()
    {
        let firstTimeKey = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kFirstTimeUserKey) as? String
        if (firstTimeKey == nil || firstTimeKey != "1") {
            castFirstTimeController = CastTutorialViewController.init(nibName: "CastTutorialViewController", bundle: nil)
            castFirstTimeController?.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            if AppConfiguration.sharedAppConfiguration.appHasTabBar
            {
                Constants.kAPPDELEGATE.tabBar?.view.addSubview((castFirstTimeController?.view)!)
            }
            else
            {
                Constants.kAPPDELEGATE.drawerController?.centerViewController?.view.addSubview((castFirstTimeController?.view)!)
            }
            castFirstTimeController?.delegate = self
        }
    }
    
    
    func chromeCastButtonClicked()
    {
        self.castButtonTapped(sender: self.chromecastButton)
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //Video Player Delegate Methods
    func videoPlayerStartedPlaying() {
        if (self.iOSVideoPlayer?.playerControls != nil){
            if self.isPipVisible == false {
                if (self.iOSVideoPlayer?.view.subviews.contains((self.iOSVideoPlayer?.playerControls)!)) == false && CastPopOverView.shared.isConnected() == false && self.iOSVideoPlayer?.adView == nil && self.iOSVideoPlayer?.avPlayer.currentItem != nil || (self.iOSVideoPlayer?.adView != nil && self.iOSVideoPlayer?.adView.isHidden == true){
                    self.iOSVideoPlayer?.view.addSubview((self.iOSVideoPlayer?.playerControls!)!)
                }
            }
        }
    }
    
    func videoPLayerFinishedVideo() {
        
    }

    func dismissPIP()  {
        DispatchQueue.main.async {
            if self.iOSVideoPlayer != nil {
                if self.view.subviews.contains((self.iOSVideoPlayer?.view)!){
                    self.iOSVideoPlayer?.view.removeFromSuperview()
                }
            }
        }
    }

    func addPlayerView(frame:CGRect, containerView: AnyObject)  {
        DispatchQueue.main.async {
            if (containerView.subviews.contains((self.iOSVideoPlayer?.view)!) == false){
                
                if containerView is UITableViewCell{
                    
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                        
                        self.iOSVideoPlayer?.view.changeFrameYAxis(yAxis: (self.iOSVideoPlayer?.view.frame.origin.y)! + (self.iOSVideoPlayer?.view.frame.size.height)!)
                        self.iOSVideoPlayer?.view.alpha = 0

                    }, completion: { (isFinished) in
                        
                        self.iOSVideoPlayer?.view.alpha = 1
                        self.loadPlayerViewOnTableAfterPIPCloseAnimation(cellFrame: frame, containerView: containerView as! UITableViewCell)
                    })
                }
                else if containerView is UIView {
                    
                    self.iOSVideoPlayer?.view.removeFromSuperview()

                    let pipHeight = frame.size.height
                    self.iOSVideoPlayer?.view.frame = CGRect(x: frame.origin.x, y: frame.origin.y + pipHeight, width: frame.size.width, height: frame.size.height)
                    
                    (containerView as! UIView).addSubview((self.iOSVideoPlayer?.view)!)
                    if (self.iOSVideoPlayer?.playerControls != nil){
                        self.iOSVideoPlayer?.playerControls?.removeFromSuperview()
                    }
                    self.iOSVideoPlayer?.view.layer.borderColor = UIColor.white.cgColor
                    self.addBorderOnPIP(with: frame)
                    self.iOSVideoPlayer?.view.alpha = 0
                    
                    UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
                        
                        self.iOSVideoPlayer?.view.changeFrameYAxis(yAxis: (self.iOSVideoPlayer?.view.frame.origin.y)! - pipHeight)
                        self.iOSVideoPlayer?.view.alpha = 1

                    }, completion: { (isFinished) in
                        

                    })
                }
                self.iOSVideoPlayer?.playMedia()
            }
        }
    }
    

    //MARK: Load Player on table cell after PIP animation
    private func loadPlayerViewOnTableAfterPIPCloseAnimation(cellFrame: CGRect, containerView:UITableViewCell) {
        
        self.iOSVideoPlayer?.view.removeFromSuperview()
        
        self.iOSVideoPlayer?.view.frame = cellFrame
        self.iOSVideoPlayer?.view.layer.borderColor = UIColor.clear.cgColor
        containerView.addSubview((self.iOSVideoPlayer?.view)!)
        self.iOSVideoPlayer?.view.changeFrameYAxis(yAxis: 0)
        self.upperBorder.removeFromSuperlayer()
        if (self.iOSVideoPlayer?.playerControls != nil){
            if (self.iOSVideoPlayer?.view.subviews.contains((self.iOSVideoPlayer?.playerControls)!)) == false && CastPopOverView.shared.isConnected() == false && self.iOSVideoPlayer?.adView == nil && self.iOSVideoPlayer?.avPlayer.currentItem != nil || (self.iOSVideoPlayer?.adView != nil && self.iOSVideoPlayer?.adView.isHidden == true){
                self.iOSVideoPlayer?.view.addSubview((self.iOSVideoPlayer?.playerControls!)!)
            }
        }
    }
    
    
    func didCreatedPlayerView() -> Void{
        if self.isPipVisible == true{
            if (self.iOSVideoPlayer?.playerControls != nil){
                self.iOSVideoPlayer?.playerControls?.removeFromSuperview()
            }
        }
    }
    func fullScreenVideoPlayer()
    {
        fullScreenVideoPlayer(fullScreenTapped: true)
    }
    
    func fullScreenVideoPlayer(fullScreenTapped: Bool)
    {
        if iOSVideoPlayer != nil {
            
            if self.isVideoPlayerVisible() == false && self.isForcePIPClose == true{
                self.iOSVideoPlayer?.forceFullScreen = false
                self.iOSVideoPlayer?.playerFit = .smallScreen
                return
            }
            
            UIApplication.shared.isStatusBarHidden = true
            self.navigationController?.navigationBar.isHidden = true
            if Constants.kAPPDELEGATE.window?.rootViewController is UITabBarController {
                let controller = Constants.kAPPDELEGATE.window?.rootViewController as! UITabBarController
                controller.tabBar.isHidden = true
            }
            iOSVideoPlayer?.view.removeFromSuperview()
            self.upperBorder.removeFromSuperlayer()
            //            previousDeviceOrientation = UIDevice.current.orientation
            self.view.addSubview((iOSVideoPlayer?.view)!)
            //            Constants.kAPPDELEGATE.isFullScreenEnabled = true
            iOSVideoPlayer?.view.layer.borderColor = UIColor.clear.cgColor
            if fullScreenTapped {
                
                if Constants.IPHONE
                {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                }
                else {
                    
                    Constants.kAPPDELEGATE.isFullScreenEnabled = true
                }
            }
            self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.iOSVideoPlayer?.view.frame = self.view.bounds
            if (self.iOSVideoPlayer?.playerControls != nil && self.iOSVideoPlayer?.adView == nil || (self.iOSVideoPlayer?.adView != nil && self.iOSVideoPlayer?.adView.isHidden == true)){
                if (self.iOSVideoPlayer?.view.subviews.contains((self.iOSVideoPlayer?.playerControls)!)) == false{
                    self.iOSVideoPlayer?.view.addSubview((self.iOSVideoPlayer?.playerControls!)!)
                }
            }
            self.iOSVideoPlayer?.playMedia()
            
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            }
        }
    }
    
    func updateVideoPlayerForOrientation() {
        if iOSVideoPlayer != nil {
            
            if self.isVideoPlayerVisible() == false && self.isForcePIPClose == true{
                self.iOSVideoPlayer?.forceFullScreen = false
                self.iOSVideoPlayer?.playerFit = .smallScreen
                return
            }
            
            UIApplication.shared.isStatusBarHidden = true
            self.navigationController?.navigationBar.isHidden = true
            if Constants.kAPPDELEGATE.window?.rootViewController is UITabBarController {
                let controller = Constants.kAPPDELEGATE.window?.rootViewController as! UITabBarController
                controller.tabBar.isHidden = true
            }
            iOSVideoPlayer?.view.removeFromSuperview()
            self.upperBorder.removeFromSuperlayer()
//            previousDeviceOrientation = UIDevice.current.orientation
            self.view.addSubview((iOSVideoPlayer?.view)!)
            iOSVideoPlayer?.view.layer.borderColor = UIColor.clear.cgColor
            
            self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.iOSVideoPlayer?.view.frame = self.view.bounds
            if (self.iOSVideoPlayer?.playerControls != nil && self.iOSVideoPlayer?.adView == nil || (self.iOSVideoPlayer?.adView != nil && self.iOSVideoPlayer?.adView.isHidden == true)){
                if (self.iOSVideoPlayer?.view.subviews.contains((self.iOSVideoPlayer?.playerControls)!)) == false{
                    self.iOSVideoPlayer?.view.addSubview((self.iOSVideoPlayer?.playerControls!)!)
                }
            }
            
            self.iOSVideoPlayer?.playMedia()
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            }
        }
    }

    func didDisconnectCastDevice() -> Void{

        if self.isForcePIPClose == false{
            if self.iOSVideoPlayer != nil {
                if self.isVideoPlayerVisible() == true{
                    self.isPipVisible = false
                    self.addPlayerView(frame: (videoViewCell?.frame)!, containerView: self.videoViewCell!)
                }
                else{
                    self.isPipVisible = true
                    self.addPlayerView(frame: CGRect(x: self.view.bounds.size.width - (Constants.IPHONE ? Constants.kPIPWidth_iPhone: Constants.kPIPWidth_iPad) - 15, y: self.view.bounds.size.height - (Constants.IPHONE ? Constants.kPIPHeight_iPhone: Constants.kPIPHeight_iPad) - 64, width: (Constants.IPHONE ? Constants.kPIPWidth_iPhone: Constants.kPIPWidth_iPad), height: (Constants.IPHONE ? Constants.kPIPHeight_iPhone: Constants.kPIPHeight_iPad)), containerView: self.view)
                }
            }
        }
        else
        {
            self.pipCrossPressed()
        }
    }

    func exitFullScreenVideoPlayer() {

        if iOSVideoPlayer != nil {
//            Constants.kAPPDELEGATE.isFullScreenEnabled = false
            UIApplication.shared.isStatusBarHidden = false
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.isTranslucent = false
            if Constants.IPHONE{
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
//            self.iOSVideoPlayer?.view.transform = CGAffineTransform.init(rotationAngle: 0)
            if self.isPipVisible == false{
                iOSVideoPlayer?.view.removeFromSuperview()
                videoViewCell?.addSubview((iOSVideoPlayer?.view)!)
                self.upperBorder.removeFromSuperlayer()
                self.iOSVideoPlayer?.view.frame = (videoViewCell?.frame)!
                if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() && !Utility.sharedUtility.checkIfUserIsLoggedIn() {

                    self.iOSVideoPlayer?.view.frame.origin.y = (videoViewCell?.frame.origin.y)! - CGFloat(Constants.IPHONE ? 40 : 55)
                }
                else if let isSubscribed = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool {

                    if !isSubscribed {
                        self.iOSVideoPlayer?.view.frame.origin.y = (videoViewCell?.frame.origin.y)! - CGFloat(Constants.IPHONE ? 40 : 55)
                    }
                }
                // MSEIOS-1422
                if self.bannerViewObject != nil {
                    let bannerViewLayout = Utility.fetchBannerViewLayoutDetails(bannerViewObject: self.bannerViewObject!)
                    self.iOSVideoPlayer?.view.frame.origin.y = (self.iOSVideoPlayer?.view.frame.origin.y)! - CGFloat(bannerViewLayout.height!)
                }
            }
            else
            {
                self.iOSVideoPlayer?.view.frame =  CGRect(x: self.view.bounds.size.width - (Constants.IPHONE ? Constants.kPIPWidth_iPhone: Constants.kPIPWidth_iPad) - 15, y: self.view.bounds.size.height - (Constants.IPHONE ? Constants.kPIPHeight_iPhone: Constants.kPIPHeight_iPad) - 64, width: (Constants.IPHONE ? Constants.kPIPWidth_iPhone: Constants.kPIPWidth_iPad), height: (Constants.IPHONE ? Constants.kPIPHeight_iPhone: Constants.kPIPHeight_iPad))
                self.addBorderOnPIP(with: (self.iOSVideoPlayer?.view.frame)!)
                if (self.iOSVideoPlayer?.playerControls != nil){
                    self.iOSVideoPlayer?.playerControls?.removeFromSuperview()
                }
            }
            if Constants.kAPPDELEGATE.window?.rootViewController is UITabBarController {
                let controller = Constants.kAPPDELEGATE.window?.rootViewController as! UITabBarController
                controller.tabBar.isHidden = false
            }
            self.iOSVideoPlayer?.playMedia()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if iOSVideoPlayer != nil{
            if Constants.IPHONE
            {
                if size.width > size.height {
                    self.iOSVideoPlayer?.videoPlayerFullScreen()
                    
                }
                else
                {
                    self.iOSVideoPlayer?.videoPlayerExitFullScreen()
                }
            }
            else
            {
                if self.iOSVideoPlayer?.playerFit == .fullScreen
                {
                    let when = DispatchTime.now() + 0.1
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    }
                }
            }
        }
    }

    func addBorderOnPIP(with frame:CGRect) {
        var borderWidth: CGFloat = 3.0
        if(!Constants.IPHONE){
            borderWidth = 4.0
        }
        upperBorder.frame = CGRect(x: -borderWidth , y: -borderWidth, width: frame.size.width + borderWidth , height: frame.size.height + borderWidth)
        upperBorder.borderWidth = borderWidth
        upperBorder.borderColor = UIColor.white.cgColor
        self.iOSVideoPlayer?.view.layer.addSublayer(upperBorder)
        self.iOSVideoPlayer?.view.layer.masksToBounds = false
    }

    func buttonTapped(button: SFButton, gridObject:SFGridObject?) -> Void{
        let eventId = gridObject?.eventId
        if eventId != nil && Constants.kAPPDELEGATE.isKisweEnable {
            Utility.presentKiswePlayer(forEventId: eventId!, withFilmId: gridObject?.contentId ?? "",vc: self)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application
     , you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension UIViewController {
    
    var isModal: Bool {
        if let index = navigationController?.viewControllers.index(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController  {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
}
