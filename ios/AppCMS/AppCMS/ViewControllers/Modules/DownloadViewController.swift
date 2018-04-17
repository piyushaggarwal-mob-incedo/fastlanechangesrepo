//
//  AncillaryPageViewController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 14/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import GoogleCast
import Firebase
class DownloadViewController: UIViewController, SFButtonDelegate, UITableViewDataSource, UITableViewDelegate, SFTableViewCellDelegate, UserDetailsViewDelegate,AVPlayerViewControllerDelegate,DownloadEntitlementDelegate,downloadManagerDelegate, GCKUIMiniMediaControlsViewControllerDelegate {
    
    var viewControllerPage: Page?
    var tableView:SFTableView?
    var modulesListDict:Dictionary<String, Any> = [:]
    var pageAPIObject:PageAPIObject?
    var progressIndicator:MBProgressHUD?
    var modulesLayoutListArray:Array<Any> = []
    var alertType:AlertType?
    var networkUnavailableAlert:UIAlertController?
    var contentOffSetDictionary:Dictionary<String, AnyObject> = [:]
    var cellModuleDict:Dictionary<String, AnyObject> = [:]
    var trayObject:SFTrayObject?
    var relativeViewFrame:CGRect?
    var pagePath:String?
    var apiModuleListArray:Array<AnyObject> = []
    var moduleObj = SFModuleObject()
    var videoPlayerController:AVPlayerViewController?
    var relatedItemsForAutoPlay = [SFFilm]()
    var _miniMediaControlsContainerView: UIView!
    var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    private var isTableHeaderAvailable:Bool = false
    private var tableHeaderView:UIView?
    private var minBannerYAxis:CGFloat = 0.0

    init (viewControllerPage:Page) {
        self.viewControllerPage = viewControllerPage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addMiniCastControllerToViewController(viewController: self)
        DownloadManager.sharedInstance.downloadDelegate = self
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "FFFFFF")
        
        if viewControllerPage?.modules != nil {
            
            for module:Any in (viewControllerPage?.modules)! {
                
                if module is SFTrayObject {
                    
                    trayObject = module as? SFTrayObject
                }
            }
        }
        
        relativeViewFrame = self.view.frame
        relativeViewFrame?.origin.y += Utility.sharedUtility.getPosition(position: 20)
        relativeViewFrame?.size.height -= Utility.sharedUtility.getPosition(position: 20)
        
        createViewComponents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateControlBarsVisibility()
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            FIRAnalytics.setScreenName("Downloads Screen", screenClass: nil)
        }
        
        if !self.apiModuleListArray.isEmpty
        {
            let reachability:Reachability = Reachability.forInternetConnection()
            if reachability.currentReachabilityStatus() != NotReachable
            {
                loadPageData()
            }
        }
        else
        {
            loadPageData()
        }

        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.allowIDFACollection = true
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
             tracker.set(kGAIScreenName, value: "Downloads Screen")
        }
        else{
             tracker.set(kGAIScreenName, value: "\(pagePath ?? "Downloads Screen")")
        }
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Create View Components
    func createViewComponents() {
        
        if trayObject != nil {
            
            for component:Any in (trayObject?.trayComponents)! {
                
                if component is SFButtonObject {
                    
                    createButtonView(buttonObject: component as! SFButtonObject)
                }
                else if component is SFSeparatorViewObject {
                    
                    createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
                }
                else if component is SFLabelObject {
                    
                    createLabelView(labelObject: component as! SFLabelObject)
                }
                else if component is SFTableViewObject {
                    
                    createTableView(tableViewObject: component as! SFTableViewObject)
                }
            }
            
            if tableView == nil {
                
                self.createSubscriptionHeader(updateBottomFrame: true)
            }
        }
    }
    
    
    //MARK: Method to create subscriptionHeader
    private func createSubscriptionHeader(updateBottomFrame:Bool) {
        
        if AppConfiguration.sharedAppConfiguration.pageHeaderObject != nil {
            
            if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() && !Utility.sharedUtility.checkIfUserIsLoggedIn() {
                
                if let subscribeButton = self.createHeaderViewFrame() {
                    
                    let headerView = UIView(frame: CGRect(x: 0, y: minBannerYAxis, width: self.view.frame.size.width, height: CGFloat(Constants.IPHONE ? 40 : 55)))
                    headerView.backgroundColor = .clear
                    headerView.addSubview(subscribeButton)
                    self.tableHeaderView = headerView
                    self.tableHeaderView?.autoresizingMask = [.flexibleWidth]
                }
            }
            else if let isSubscribed = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool {
                
                if !isSubscribed {
                    
                    if let subscribeButton = self.createHeaderViewFrame() {
                        
                        let headerView = UIView(frame: CGRect(x: 0, y: minBannerYAxis, width: self.view.frame.size.width, height: CGFloat(Constants.IPHONE ? 40 : 55)))
                        headerView.backgroundColor = .clear
                        headerView.addSubview(subscribeButton)
                        self.tableHeaderView = headerView
                        self.tableHeaderView?.autoresizingMask = [.flexibleWidth]
                    }
                }
            }
        }
        
        if self.tableHeaderView != nil && updateBottomFrame {
            
            for subView in self.view.subviews {
                
                if subView is SFLabel || subView is SFButton || subView is SFTextView {
                    
                    if subView.frame.origin.y >= minBannerYAxis {
                        
                        subView.changeFrameHeight(height: subView.frame.size.height - (tableHeaderView?.frame.size.height)!)
                        subView.changeFrameYAxis(yAxis: subView.frame.origin.y + (tableHeaderView?.frame.size.height)!)
                    }
                }
            }
            
            self.view.addSubview(self.tableHeaderView!)
        }
    }
    
    
    //method to create label view
    func createLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.relativeViewFrame = relativeViewFrame!
        label.labelLayout = labelLayout
        
        self.view.addSubview(label)
        label.createLabelView()
        label.font = UIFont(name: label.font.fontName, size: label.font.pointSize * Utility.getBaseScreenHeightMultiplier())
        updateLabelView(label: label)
        
        if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
            
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
        }
        if label.labelObject?.key == "title" {
            label.text = "My Downloads"
        }
        else if label.labelObject?.key == "watchlistLabel" {
            
            label.text = "You haven't downloaded anything yet."
            label.isHidden = true
        }
        else if label.labelObject?.key == "totalVideoDownloadSize" {

            label.text = ""
            label.isHidden = true
        }
    }
    
    
    //method to create separator view
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        let separatorView:SFSeparatorView = SFSeparatorView(frame: CGRect.zero)
        separatorView.separtorViewObject = separatorViewObject
        separatorView.relativeViewFrame = relativeViewFrame!
        self.view.addSubview(separatorView)
        updateSeparatorView(separatorView: separatorView)
        
        self.minBannerYAxis = separatorView.frame.size.height + separatorView.frame.origin.y

        separatorView.isHidden = false
    }
    
    //method to create buttonview
    func createButtonView(buttonObject:SFButtonObject) {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        
        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.relativeViewFrame = relativeViewFrame!
        button.buttonLayout = buttonLayout
        button.buttonDelegate = self
        button.createButtonView()
        
        if button.buttonObject?.key == "closeButton"{
            
            let cancelButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "cancelIcon.png"))
            
            button.setImage(cancelButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        }
        else if button.buttonObject?.key == "removeAll" {
            
            if apiModuleListArray.count == 0 {
                
                button.isHidden = true
            }
            else {
                
                button.isHidden = false
            }
            button.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000")
            button.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor ?? AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        }
        
        self.view.addSubview(button)
        updateButtonView(button: button)
        
        button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!, size: (button.titleLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
    }
    
    
    //method to create table view
    func createTableView(tableViewObject:SFTableViewObject) {
        
        let tableViewLayout = Utility.sharedUtility.fetchTableViewLayoutDetails(tableViewObject: tableViewObject)
        tableView = SFTableView(frame: CGRect.zero, style: .plain)
        tableView?.relativeViewFrame = relativeViewFrame!
        tableView?.tableObject = tableViewObject
        tableView?.tableLayout = tableViewLayout
        tableView?.initialiseTableViewFrameFromLayout(tableViewLayout: tableViewLayout)
        tableView?.changeFrameYAxis(yAxis: (tableView?.frame.minY)! + Utility.sharedUtility.getPosition(position: 20))
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.updateTableView()
        tableView?.register(SFTableViewCell.self, forCellReuseIdentifier: "tableViewCustomCell")
        self.view.addSubview(tableView!)
        self.tableView?.isHidden = true
    }
    
    
    //MARK: TableView delegates
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var customTableViewCell:SFTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "tableViewCustomCell") as? SFTableViewCell
        
        if customTableViewCell == nil {
            
            customTableViewCell = SFTableViewCell(style: .default, reuseIdentifier: "tableViewCustomCell")
        }
        
        customTableViewCell?.cellRowValue = indexPath.row
        
        let downloadobj: DownloadObject = DownloadManager.sharedInstance.globalDownloadArray[indexPath.row]
        let filmobj: SFFilm = DownloadManager.sharedInstance.getFilmObject(for: downloadobj)
        customTableViewCell?.film = filmobj
        addCustomTableViewCellToTable(customTableViewCell: customTableViewCell!, gridObject: apiModuleListArray[indexPath.row] as? SFGridObject)
        
        return customTableViewCell!
    }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if AppConfiguration.sharedAppConfiguration.pageHeaderObject != nil {
            
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
                
                if self.tableView == nil {
                    
                    self.tableHeaderView = nil
                    self.tableHeaderView?.removeFromSuperview()
                    self.updateViewComponents()
                }
                else {

                    if self.tableView != nil {
                        
                        self.tableHeaderView = nil
                        self.tableHeaderView?.removeFromSuperview()
                        self.tableView?.reloadData()
                    }
                }
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
        
        if section == 0 {
            
            if AppConfiguration.sharedAppConfiguration.pageHeaderObject != nil {
                
                var headerHeight:CGFloat = 1.0
                
                if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() && !Utility.sharedUtility.checkIfUserIsLoggedIn() {
                    
                    if let pageHeaderObject = AppConfiguration.sharedAppConfiguration.pageHeaderObject {
                        
                        if pageHeaderObject.buttonText != nil  && (pageHeaderObject.placement != nil && pageHeaderObject.placement?.lowercased() == "Banner".lowercased()) {
                            
                            headerHeight = CGFloat(Constants.IPHONE ? 40 : 55)
                        }
                    }
                }
                else if let isSubscribed = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool {
                    
                    if !isSubscribed {
                        if let pageHeaderObject = AppConfiguration.sharedAppConfiguration.pageHeaderObject {
                            
                            if pageHeaderObject.buttonText != nil  && (pageHeaderObject.placement != nil && pageHeaderObject.placement?.lowercased() == "Banner".lowercased()) {
                                
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
        else {
            
            return 1.0
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return apiModuleListArray.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(((self.tableView?.tableLayout?.gridHeight) ?? 44 )) * Utility.getBaseScreenHeightMultiplier()
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row < apiModuleListArray.count){
            let gridObject:SFGridObject? = apiModuleListArray[indexPath.row] as? SFGridObject
            self.playViedeoForDownload(gridObject: gridObject!, row: indexPath.row)
        }
    }
    
    
    //MARK: method to custom table view cell
    func addCustomTableViewCellToTable(customTableViewCell:SFTableViewCell, gridObject:SFGridObject?) {
        
        customTableViewCell.backgroundColor = UIColor.clear
        customTableViewCell.selectionStyle = .none
        customTableViewCell.relativeViewFrame = CGRect(x: 0, y: 0, width: (tableView?.frame.size.width)!, height: CGFloat(tableView?.tableLayout?.gridHeight ?? 44) * Utility.getBaseScreenHeightMultiplier())
        customTableViewCell.tableComponents = (tableView?.tableObject?.trayComponents)!
        
        customTableViewCell.tableViewCellDelegate = self
        customTableViewCell.gridObject = gridObject!
        customTableViewCell.updateGridSubView()
    }
    
    
    func shouldPlayDownloadedVideo(objDownload: DownloadObject) {
        
        DispatchQueue.main.async {
            
            self.hideActivityIndicator()
            
            if CastPopOverView.shared.isConnected(){
                CastController().playSelectedItemRemotely(contentId: objDownload.fileID, isDownloaded:  true, relatedContentIds: self.relatedItemsForAutoPlay, contentTitle: objDownload.fileName)
            }
            else{
                
                let videoObject: VideoObject = VideoObject()
                videoObject.videoTitle = objDownload.fileName
                videoObject.videoPlayerDuration = Double(objDownload.fileDurationSeconds ?? 0)
                videoObject.videoContentId = objDownload.fileID
                videoObject.gridPermalink = objDownload.filePathUrl
                videoObject.videoWatchedTime = Double(objDownload.fileWatchedPercentage )
                videoObject.contentRating = objDownload.parentalRating ?? "NR"

                let playerViewController: CustomVideoController = CustomVideoController.init(videoObject: videoObject, videoPlayerType: .streamVideoPlayer, videoFitType: .fullScreen)
                playerViewController.isOpenFromDownload = true
                playerViewController.autoPlayObjectArray = self.relatedItemsForAutoPlay
                self.present(playerViewController, animated: true, completion: {
                })

            }
        }
    }
    
    
    func displayNonEntitledUserAlert() {
        
        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
        }
        
        let subscriptionAction = UIAlertAction(title: Constants.kStrSubscription, style: .default) { (subscriptionAction) in
            
            self.displayPlanPageWithCompletionHandler(completionHandler: { (isSuccessfullyLoggedIn) in
                
                if isSuccessfullyLoggedIn {
                    
                    if self.tableView == nil {
                        
                        if self.tableHeaderView != nil {
                            
                            self.tableHeaderView = nil
                            self.tableHeaderView?.removeFromSuperview()
                            self.updateViewComponents()
                        }
                    }
                    else {
                        
                        if self.tableHeaderView != nil {
                            
                            self.tableHeaderView = nil
                            self.tableHeaderView?.removeFromSuperview()
                            self.tableView?.reloadData()
                        }
                    }
                }
            })
        }
        
        var alertActionArray:Array<UIAlertAction>?
        
        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
            
            alertActionArray = [cancelAction, subscriptionAction]
        }
        else {
            
            alertActionArray = [cancelAction, subscriptionAction]
        }
        
        let nonEntitledAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kEntitlementErrorTitle, alertMessage: Constants.kEntitlementErrorMessage, alertActions: alertActionArray!)
        
        self.present(nonEntitledAlert, animated: true, completion: nil)
    }
    
    
    func displayUserOnlineTimeAlert(message:String) {
        
        let cancelAction = UIAlertAction(title: Constants.kStrOk, style: .default) { (cancelAction) in
        }
        var alertActionArray:Array<UIAlertAction>?
        alertActionArray = [cancelAction]
        let nonEntitledAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kEntitlementErrorTitle, alertMessage: message, alertActions: alertActionArray!)
        self.present(nonEntitledAlert, animated: true, completion: nil)
    }
    
    
    func displayPlanPage() -> Void {
        let planViewController:SFProductListViewController = SFProductListViewController.init()
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: planViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
    func shouldPresentAlertView(message: String){
        self.hideActivityIndicator()
        if message == Constants.kUserOnlineTimeAlert{
            self.displayUserOnlineTimeAlert(message: message)
        }
        else{
            self.displayNonEntitledUserAlert()
        }
    }
    
    
    func playViedeoForDownload(gridObject: SFGridObject, row:Int) -> Void {
        
        let downloadobj: DownloadObject = DownloadManager.sharedInstance.globalDownloadArray[row]
        if (gridObject.isDownloadComplete == true) {
            self.showActivityIndicator(loaderText: nil)
            relatedItemsForAutoPlay.removeAll()
            let rowIndex = Int(row)
            for ii in rowIndex ..< DownloadManager.sharedInstance.globalDownloadArray.count
            {
                let objCourseObject = DownloadManager.sharedInstance.globalDownloadArray[ii]
                let state:downloadObjectState = downloadObjectState(rawValue: DownloadManager.sharedInstance.getCurrentDownloadStateForFile(withFileID: objCourseObject.fileID))!
                if state == .eDownloadStateFinished
                {
                    let film:SFFilm = DownloadManager.sharedInstance.getFilmObject(for: objCourseObject)
                    if(DownloadManager.sharedInstance.globalDownloadArray.count-1 != row)
                    {
                        relatedItemsForAutoPlay.append(film)
                    }
                }
            }
            DownloadEntitlementCheck.sharedInstance.isContentEntitledAndSubscribed(objDownload: downloadobj)
            DownloadEntitlementCheck.sharedInstance.delegate = self
        }
        else
        {
            let alertMessage = "\(downloadobj.fileName) has not yet been downloaded. Please try again later."
            let cancelAction = UIAlertAction(title: Constants.kStrClose, style: .default) { (cancelAction) in
            }
            var alertActionArray:Array<UIAlertAction>?
            alertActionArray = [cancelAction]
            let nonEntitledAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "Download", alertMessage: alertMessage, alertActions: alertActionArray!)
            self.present(nonEntitledAlert, animated: true, completion: nil)
        }
    }
    
    
    //MARK: Load Page Data
    func loadPageData() {
        
        self.fetchdownloadData()
    }
    
    
    func getModuleData() -> Void {
        var moduleContentArray:Array <AnyObject> = []
        for downloadObject:DownloadObject in DownloadManager.sharedInstance.globalDownloadArray {
            let gridObject = SFGridObject()
            
            gridObject.contentTitle = downloadObject.fileName
            gridObject.contentId =  downloadObject.fileID
            gridObject.contentType = ""
            gridObject.thumbnailImageURL = downloadObject.fileImageUrl
            gridObject.posterImageURL =  downloadObject.fileImageUrl
            if (downloadObject.fileDurationSeconds != nil){
                gridObject.totalTime = Double((downloadObject.fileDurationSeconds?.intValue)!)
            }
            gridObject.watchedTime = Double(downloadObject.fileWatchedPercentage)
            gridObject.gridPermaLink = downloadObject.fileUrl
            gridObject.contentDescription = downloadObject.fileDescription
            gridObject.parentalRating = downloadObject.parentalRating
            gridObject.isDownloadComplete = false
            if downloadObject.fileDownloadState == .eDownloadStateFinished {
                gridObject.isDownloadComplete = true
            }
            gridObject.totalSize = downloadObject.fileTotalLength
            self.moduleObj.moduleData?.append(gridObject)
            moduleContentArray.append(gridObject)
        }
        self.moduleObj.moduleData  = moduleContentArray
    }
    
    func fetchdownloadData() -> Void {
        
        self.showActivityIndicator(loaderText: "Loading...")
        self.getModuleData()
        self.apiModuleListArray = (self.moduleObj.moduleData)!

        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable
        {
            self.displayViewContent()
            self.tableView?.scrollsToTop = true
        }
        else
        {
            self.fetchDownLoadedContent()
        }
    }
    
    //MARK: Method to fetch History content
    func fetchDownLoadedContent() {
        
        if DownloadManager.sharedInstance.getGlobalDownloadObjectsArray().count > 0 {
            
            let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/video/history/user/\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")&offset=0&fields=records(contentResponse(gist(watchedTime,id,runtime)))"
            
            DataManger.sharedInstance.fetchQueueResults(apiEndPoint: apiRequest) { (moduleObject, isSuccess) in
                
                if moduleObject != nil && isSuccess {
                    
                    if moduleObject?.moduleData != nil {
                        
                        let historyListArray: Array = (moduleObject?.moduleData)!
                        
                        if historyListArray.count > 0 {
                            
                            for moduleObj in historyListArray
                            {
                                if (moduleObj is SFGridObject)
                                {
                                    let gridObj: SFGridObject = moduleObj as! SFGridObject
                                    self.updateDownloadedObjectProgress(gridObject: gridObj)
                                }
                            }
                        }
                    }
                    
                    self.displayViewContent()
                    self.tableView?.scrollsToTop = true
                }
                else {
                    
                    self.displayViewContent()
                }
            }
        }
        else {
            
            self.displayViewContent()
        }
    }

    func updateDownloadedObjectProgress(gridObject: SFGridObject) -> Void {
        for downloadedObject in DownloadManager.sharedInstance.getGlobalDownloadObjectsArray()
        {
            let localDownloadObject: DownloadObject = downloadedObject 
            
            if gridObject.contentId == localDownloadObject.fileID
            {
                if let watchedTime = gridObject.watchedTime, let totalTime = gridObject.totalTime {
                    
                    localDownloadObject.fileWatchedPercentage = Float((watchedTime / totalTime) * 100.00)
                    DownloadManager.sharedInstance.updatePlist(forFile: localDownloadObject)
                }
            }
        }
    }
    
    //MARK: Check if Module Exist in API
    func checkIfModuleExistInPageAPIObject(moduleName:String) -> Bool {
        
        var isModulePresent = false
        
        if trayObject != nil {
            
            let moduleObject:SFModuleObject? = self.pageAPIObject?.pageModules!["\((trayObject?.trayId)!)"] as? SFModuleObject
            
            if moduleObject != nil {
                
                if moduleName == moduleObject?.moduleType {
                    
                    isModulePresent = true
                }
            }
        }
        
        return isModulePresent
    }

    
    //MARK: Method to display view
    func displayViewContent() {
        
        DispatchQueue.main.async {
            
            self.hideActivityIndicator()
            self.cellModuleDict.removeAll()
            self.updateViewForModuleListArray()
            
            if self.apiModuleListArray.count > 0 {
                self.tableView?.isHidden = false
                self.tableView?.reloadData()
            }
            else {
                
                self.createSubscriptionHeader(updateBottomFrame: true)
            }
        }
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
    
    //MARK: - SFButton Delegates
    func buttonClicked(button: SFButton) {
        
        if button.buttonObject?.action == "close" {
            
            self.dismiss(animated: true, completion: nil)
        }
        else if button.buttonObject?.action == "removeAll" {
            
            let okAction:UIAlertAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (buttonAction) in
                
                self.removeAllVideoFromDownload()
            })
            
            let cancelAction:UIAlertAction = UIAlertAction(title: Constants.kStrCancel, style: .default, handler: { (buttonAction) in
                
            })
            
            var alertTitle:String?
            var alertMessage:String?
            
            alertTitle = Constants.kStrDeleteDownloadAlertTitle
            alertMessage = Constants.kStrDeleteAllVideosFromDownloadAlertMessage
            
            let alertController:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitle ?? "", alertMessage: alertMessage ?? "", alertActions: [cancelAction, okAction])
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: Remove all videos from queue
    func removeAllVideoFromDownload() {
        
        self.showActivityIndicator(loaderText: nil)
        DownloadManager.sharedInstance.removeAllDownloadedContent(withSuccessBlock: { () in
            
            self.hideActivityIndicator()
            self.fetchdownloadData()
        }) { () in
            
            self.hideActivityIndicator()
        }
    }
    
    
    //MARK: Custom TableView Cell Delegates
    func buttonClicked(button: SFButton, gridObject: SFGridObject?, cellRowValue:Int) {
        
        if button.buttonObject?.action == "delete" || button.buttonObject?.action == "cancel" {
            
            var alertTitle:String?
            var alertMessage:String?
            
            if gridObject != nil {
                
                let okAction:UIAlertAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (buttonAction) in
                    
                    self.removeVideoFromDownload(contentId: gridObject?.contentId ?? "" , cellRowValue:cellRowValue)
                })
                
                let cancelAction:UIAlertAction = UIAlertAction(title: Constants.kStrCancel, style: .default, handler: { (buttonAction) in
                    
                })
                
                alertTitle = Constants.kStrDeleteDownloadAlertTitle
                alertMessage = Constants.kStrDeleteSingleVideoFromDownloadAlertMessage
                
                let alertController:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitle ?? "", alertMessage: alertMessage ?? "", alertActions: [cancelAction, okAction])
                self.present(alertController, animated: true, completion: nil)
            }
        }
        else if button.buttonObject?.action == "watchVideo" {
            
            self.playViedeoForDownload(gridObject: gridObject!, row: cellRowValue)
        }
    }
    
    
    //MARK: method to play video
    func playVideo(gridObject:SFGridObject?) {
        
        if gridObject != nil {
            
            let videoObject: VideoObject = VideoObject()
            videoObject.videoTitle = gridObject?.contentTitle ?? ""
            videoObject.videoPlayerDuration = gridObject?.totalTime ?? 0
            videoObject.videoContentId = gridObject?.contentId ?? ""
            videoObject.gridPermalink = gridObject?.gridPermaLink ?? ""
            videoObject.videoWatchedTime = gridObject?.watchedTime ?? 0
            
            let playerViewController: CustomVideoController = CustomVideoController.init(videoObject: videoObject, videoPlayerType: .streamVideoPlayer, videoFitType: .fullScreen)
            self.present(playerViewController, animated: true, completion: nil)
        }
        else {
            
            let alertController = UIAlertController(title: "Error", message: "Error is loading film details", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: Removing single video from watchlist
    func removeVideoFromDownload(contentId:String, cellRowValue:Int) {
        
        var indexOfItemToBeDeleted:Int?
        for (index, item) in DownloadManager.sharedInstance.globalDownloadArray.enumerated() {
            
            if item.fileID == contentId {
                
                indexOfItemToBeDeleted = index
                break
            }
        }

        if indexOfItemToBeDeleted != nil {
            
            self.showActivityIndicator(loaderText: nil)

            let downloadObjectToBeDeleted: DownloadObject = DownloadManager.sharedInstance.globalDownloadArray[indexOfItemToBeDeleted!]
            DownloadManager.sharedInstance.removeObject(fromDownloadedArray: downloadObjectToBeDeleted.fileID, withSuccessBlock: {() -> Void in
                
                self.hideActivityIndicator()
                self.fetchdownloadData()
            }, andFailureBlock: {(_ error: Error?) -> Void in
                
                self.hideActivityIndicator()
            })
        }
    }
    
    
    func updateViewForModuleListArray() {
        
        if self.apiModuleListArray.count > 0{
            self.tableView?.isHidden = false
            hideUnHideNoResultArrayLabel(isHidden: true)
        }
        else{
            self.tableView?.isHidden = true
            hideUnHideNoResultArrayLabel(isHidden: false)
        }
    }
    
    
    func hideUnHideNoResultArrayLabel(isHidden:Bool) {
        
        for subView in self.view.subviews {
            
            if subView is SFLabel {
                
                let label:SFLabel = subView as! SFLabel
                
                if label.labelObject?.key == "watchlistLabel" {
                    
                    label.isHidden = isHidden
                }
                else if label.labelObject?.key == "totalVideoDownloadSize" {
                    
                    if DownloadManager.sharedInstance.totalDownloadLength > 0 {
                        
                        self.updateTotalDownloadSizeLabel(label: label)
                        label.isHidden = false
                    }
                    else {
                        
                        label.text = ""
                        label.isHidden = true
                    }
                }
            }
            else if subView is SFButton {
                
                let button:SFButton = subView as! SFButton
                
                if button.buttonObject?.key == "removeAll" {
                    
                    button.isHidden = !isHidden
                }
            }
        }
    }
    
    
    func updateTotalDownloadSizeLabel(label:SFLabel) {
        
        var totalDownloadText:String = label.labelObject?.text ?? "Storage Used"
        
        let downloadSizeString = self.createTotalDownloadLengthString()
        
        totalDownloadText = totalDownloadText.appending(" \(downloadSizeString)")
        
        let totalDownloadAttributedText = NSMutableAttributedString(string: totalDownloadText)
        
        let fontFamily = Utility.sharedUtility.fontFamilyForApplication()
        var fontWeight = "ExtraBold"
        
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
            
            fontWeight = "Black"
        }
        
        totalDownloadAttributedText.addAttributes([NSFontAttributeName: UIFont(name: "\(fontFamily)-\(fontWeight)", size: 12 * Utility.getBaseScreenHeightMultiplier())!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")], range: (totalDownloadText as NSString).range(of: downloadSizeString))
        
        label.attributedText = totalDownloadAttributedText
    }
    
    
    func createTotalDownloadLengthString() -> String {
        
        let totalDownloadedDataSize = Int(DownloadManager.sharedInstance.totalDownloadLength / (1024 * 1024))
        let downloadSizeString = "\(totalDownloadedDataSize) MB"
        
        return downloadSizeString
    }
    
    //MARK: - Handle View Frames
    override func viewDidLayoutSubviews() {
        
        relativeViewFrame?.size = UIScreen.main.bounds.size
        relativeViewFrame?.size.height -= Utility.sharedUtility.getPosition(position: 20)
        
//        if (self.miniMediaControlsViewController != nil){
//            if self.miniMediaControlsViewController.active && CastPopOverView.shared.isConnected(){
//                relativeViewFrame?.size.height -= 64
//            }
//        }
        
        updateControlBarsVisibility()

        updateViewComponents()
        
    }
    
    
    //MARK: - Update View Components
    func updateViewComponents() {
        
        if trayObject != nil {
            
            for subView in self.view.subviews {
                
                if subView is SFLabel {
                    
                    updateLabelView(label: subView as! SFLabel)
                }
                    
                else if subView is SFSeparatorView {
                    
                    updateSeparatorView(separatorView: subView as! SFSeparatorView)
                }
                else if subView is SFButton {
                    
                    updateButtonView(button: subView as! SFButton)
                }
                else if subView is SFTableView {
                    
                    updateTableView(tableView: subView as! SFTableView)
                }
            }
            
            if self.tableView == nil && self.tableHeaderView != nil {
                
                updateSubscriptionHeaderFrame(updateBottomFrame: true)
            }
            else if self.tableHeaderView != nil {
                
                updateSubscriptionHeaderFrame(updateBottomFrame: true)
            }
        }
        
    }
    
    
    //MARK: Updating view components
    private func updateSubscriptionHeaderFrame(updateBottomFrame: Bool) {
        
        if AppConfiguration.sharedAppConfiguration.pageHeaderObject != nil {
            
            if (!Utility.sharedUtility.checkIfUserIsSubscribedGuest() && !Utility.sharedUtility.checkIfUserIsLoggedIn()) || self.tableView?.isHidden == true {

                self.tableHeaderView?.changeFrameYAxis(yAxis: minBannerYAxis)
                self.tableHeaderView?.changeFrameWidth(width: UIScreen.main.bounds.width)
            }
        }
        
        if self.tableHeaderView != nil {
            
            for subView in (tableHeaderView?.subviews)! {
                
                if subView is UIButton {
                    
                    subView.changeFrameWidth(width: UIScreen.main.bounds.size.width)
                }
            }
        }
        if self.tableHeaderView != nil && updateBottomFrame {
            
            for subView in self.view.subviews {
                
                if subView is SFLabel || subView is SFButton || subView is SFTextView {
                    
                    if subView.frame.origin.y >= minBannerYAxis {
                        
                        subView.changeFrameHeight(height: subView.frame.size.height - (tableHeaderView?.frame.size.height)!)
                        subView.changeFrameYAxis(yAxis: subView.frame.origin.y + (tableHeaderView?.frame.size.height)!)
                    }
                }
            }
        }
    }
    
    
    //method to update label view frames
    func updateLabelView(label:SFLabel) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!)
        
        label.relativeViewFrame = relativeViewFrame!
        label.labelLayout = labelLayout
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.changeFrameYAxis(yAxis: label.frame.minY + Utility.sharedUtility.getPosition(position: 20))
    }
    
    
    //method to update separator view frames
    func updateSeparatorView(separatorView:SFSeparatorView) {
        
        separatorView.relativeViewFrame = relativeViewFrame!
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorView.separtorViewObject!))
        separatorView.changeFrameYAxis(yAxis: separatorView.frame.minY + Utility.sharedUtility.getPosition(position: 20))
        
        self.minBannerYAxis = separatorView.frame.size.height + separatorView.frame.origin.y
    }

    
    //method to update button view frames
    func updateButtonView(button:SFButton) {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: button.buttonObject!)
        
        button.relativeViewFrame = relativeViewFrame!
        button.buttonLayout = buttonLayout
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.changeFrameYAxis(yAxis: button.frame.minY + Utility.sharedUtility.getPosition(position: 20))
        button.changeFrameWidth(width: button.frame.width * Utility.getBaseScreenWidthMultiplier())
        button.changeFrameHeight(height: button.frame.height * Utility.getBaseScreenHeightMultiplier())
        
        if buttonLayout.height != nil {
            
            button.changeFrameYAxis(yAxis: button.frame.origin.y - (button.frame.size.height - CGFloat(buttonLayout.height!)))
        }
        
        if buttonLayout.width != nil {
            
            button.changeFrameXAxis(xAxis: button.frame.origin.x - (button.frame.size.width - CGFloat(buttonLayout.width!))/2)
        }
    }
    
    
    //method to update table view frames
    func updateTableView(tableView:SFTableView) {
        
        tableView.relativeViewFrame = relativeViewFrame!
        let tableViewLayout = Utility.sharedUtility.fetchTableViewLayoutDetails(tableViewObject: tableView.tableObject!)
        tableView.initialiseTableViewFrameFromLayout(tableViewLayout: tableViewLayout)
        tableView.changeFrameYAxis(yAxis: (tableView.frame.minY) + Utility.sharedUtility.getPosition(position: 20))
    }
    
    
    deinit {
        
    }
    
    // MARK: - DownloadManager Delegate
    func getIndexNumber(thisObject: DownloadObject) -> Int {
        var indexRow: Int = -1
        for ii in 0 ..< DownloadManager.sharedInstance.globalDownloadArray.count {
            let objDownload = DownloadManager.sharedInstance.globalDownloadArray[ii] as? DownloadObject ?? DownloadObject()
            if (objDownload.fileID == thisObject.fileID) {
                indexRow = ii
                break
            }
        }
        return indexRow
    }
    
    func manageStateOfDownloadProgress(thisObject: DownloadObject) -> Void {
        let indexRow: Int = self.getIndexNumber(thisObject: thisObject)
        if indexRow != -1 {
            let cell: SFTableViewCell? = (tableView?.cellForRow(at: IndexPath(row: indexRow, section: 0)) as? SFTableViewCell)
            if cell != nil
            {
            cell?.roundProgressView?.downloadObject = thisObject
            cell?.roundProgressView?.setTheProgressForItemForDownloadProgress(DownloadManager.sharedInstance.getFilmObject(for: thisObject))
            }
        }
    }
    
    func updateDownloadProgress(for thisObject: DownloadObject, withProgress progress: Float) {
        
        self.manageStateOfDownloadProgress(thisObject: thisObject)
    }
    
    func downloadFinished(for thisObject: DownloadObject) {
        manageStateOfProgressViews(with: thisObject)
        
        let userInfo:Dictionary<String, Any> = ["downloadObject":thisObject]
        NotificationCenter.default.post(name: Notification.Name(Constants.kManageProgressViewState), object: nil, userInfo: userInfo)
        
        let indexRow: Int = self.getIndexNumber(thisObject: thisObject)
        if indexRow != -1 {
            let cell: SFTableViewCell? = (tableView?.cellForRow(at: IndexPath(row: indexRow, section: 0)) as? SFTableViewCell)
            if cell != nil {
                
                cell?.gridObject?.totalSize = thisObject.fileTotalLength
                cell?.gridObject?.isDownloadComplete = true
                cell?.updateCellSubViewsFrame()
                self.updateTotalSizeAfterDownload()
            }
        }
    }
    
    
    func updateTotalSizeAfterDownload() {
        
        for subView in self.view.subviews {
            
            if subView is SFLabel {
                
                let label = subView as! SFLabel
                
                if label.labelObject?.key == "totalVideoDownloadSize" {
                    
                    if DownloadManager.sharedInstance.totalDownloadLength > 0 {
                        
                        self.updateTotalDownloadSizeLabel(label: label)
                        label.isHidden = false
                    }
                    else {
                        
                        label.text = ""
                        label.isHidden = true
                    }
                    
                    break
                }
            }
        }
    }
    
    
    func downloadStateUpdate(for thisObject: DownloadObject) {
        manageStateOfProgressViews(with: thisObject)
        
        let userInfo:Dictionary<String, Any> = ["downloadObject":thisObject]
        NotificationCenter.default.post(name: Notification.Name(Constants.kManageProgressViewState), object: nil, userInfo: userInfo)
    }
    
    func downloadFailed(for thisObject: DownloadObject) {
        manageStateOfProgressViews(with: thisObject)
        
        let userInfo:Dictionary<String, Any> = ["downloadObject":thisObject]
        NotificationCenter.default.post(name: Notification.Name(Constants.kManageProgressViewState), object: nil, userInfo: userInfo)
    }
    
    func manageStateOfProgressViews(with thisObject: DownloadObject) {
        self.manageStateOfDownloadProgress(thisObject: thisObject)
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    // MARK: - Internal methods
    func updateControlBarsVisibility() {
        if (self.miniMediaControlsViewController != nil){
            _miniMediaControlsContainerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - (64), width: UIScreen.main.bounds.width, height: 0)
            if self.miniMediaControlsViewController.active && CastPopOverView.shared.isConnected(){
                relativeViewFrame?.size = UIScreen.main.bounds.size
                relativeViewFrame?.size.height = (relativeViewFrame?.size.height)! - 84
                
                updateViewComponents()
                _miniMediaControlsContainerView.changeFrameHeight(height: 64)
                self.view.bringSubview(toFront: _miniMediaControlsContainerView)
            } else {
                relativeViewFrame?.size = UIScreen.main.bounds.size
                relativeViewFrame?.size.height -= Utility.sharedUtility.getPosition(position: 20)
                
                updateViewComponents()
                _miniMediaControlsContainerView.changeFrameHeight(height: 0)
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
}
