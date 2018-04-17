//
//  SFWatchlistAndHistoryViewModule.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 10/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

enum PageLoadAfterFailureAlert {
    case RefreshPageContent
    case RefreshQueueContent
    case RefreshHistoryContent
    case RefreshRemoveFromWatchlist
    case RefreshRemoveAllFromWatchlist
    case RefreshAddToWatchlist
    case RefreshRemoveFromHistory
    case RefreshRemoveAllFromHistory
    case RefreshAccountSettings
    case RefreshSubscriptionDetails
}

@objc protocol SFWatchlistAndHistoryViewModuleDelegate:NSObjectProtocol {
    @objc optional func launchVideo(gridObject:SFGridObject?, cellRowValue:Int) -> Void
    @objc optional func openVideoDetails(gridObject:SFGridObject?, cellRowValue:Int) -> Void
    @objc optional func clearButtonClicked(button: SFButton)
}

class SFWatchlistAndHistoryViewModule: UIViewController, SFButtonDelegate, UITableViewDataSource, UITableViewDelegate, SFTableViewCellDelegate {

    /// Video description module object.
    var moduleObject: SFWatchlistAndHistoryViewObject?
    
    /// Relative view frame
    var relativeViewFrame:CGRect?
    
    /// Base tableView.
    var tableView:SFTableView?
    
    /// WatchListHistory Module delegate
    weak var delegate:SFWatchlistAndHistoryViewModuleDelegate?
    
    ///Displays empty message label
    private var emptyMessageLbl : UILabel?
    
    /// Check if a fetch request is in process.
    var fetchRequestInProcess:Bool = false

    /// Network unavailanble alert.
    var networkUnavailableAlert:UIAlertController?
    
    /// Alert type.
    var failureAlertType:PageLoadAfterFailureAlert?
    
    /// Array of items added in history/watchlist.
    var arrayOfItems: Array<SFGridObject>?
    
    /// Progress Indicator instance.
    private var progressIndicator:UIActivityIndicatorView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(frame: CGRect, items: Array<SFGridObject>) {
        super.init(nibName: nil, bundle: nil)
        arrayOfItems = items
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchPageData()
        NotificationCenter.default.addObserver(self, selector:#selector(SFWatchlistAndHistoryViewModule.fetchPageData), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideActivityIndicator()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc private func fetchPageData() {
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() != NotReachable {
            if let networkAlert = networkUnavailableAlert {
                if networkAlert.isShowing() {
                    networkAlert.dismiss(animated: true, completion: nil)
                }
            }
        }
        if fetchRequestInProcess == false {
            if self.moduleObject?.contentPageType == .watchlist {
                fetchQueueContent()
            } else {
                fetchHistoryContent()
            }
        }
    }
    
    private func fetchQueueContent() {
        if Utility.sharedUtility.checkIfUserIsLoggedIn() == false {
            self.tableView?.isHidden = true
            self.updateViewForEmptyArray()
        } else {
            self.showActivityIndicator()
            self.fetchRequestInProcess = true
            let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")&limit=1000000"
            DataManger.sharedInstance.fetchQueueResults(apiEndPoint: apiRequest) { [weak self] (moduleObject, isSuccess)  in
                
                self?.hideActivityIndicator()
                self?.fetchRequestInProcess = false
                
                if isSuccess {
                    self?.hideActivityIndicator()
                    if moduleObject != nil {
                        self?.updateViewForContent()
                        self?.arrayOfItems = (moduleObject?.moduleData)! as? Array<SFGridObject>
                        self?.tableView?.isHidden = false
                        self?.tableView?.reloadData()
                    }
                    else {
                        self?.tableView?.isHidden = true
                        self?.updateViewForEmptyArray()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self?.hideActivityIndicator()

                        self?.failureAlertType = .RefreshQueueContent
                        
                        let reachability:Reachability = Reachability.forInternetConnection()
                        if reachability.currentReachabilityStatus() == NotReachable {
                            self?.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
                        }
                        else {
                            self?.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived)
                        }
                    }
                }
            }
        }
    }
    
    private func fetchHistoryContent() {
        if Utility.sharedUtility.checkIfUserIsLoggedIn() == false {
            self.tableView?.isHidden = true
            self.updateViewForEmptyArray()
        } else {
            self.showActivityIndicator()
            self.fetchRequestInProcess = true
            let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/video/history/user/\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")&offset=0"
            
            DataManger.sharedInstance.fetchQueueResults(apiEndPoint: apiRequest) { [weak self] (moduleObject, isSuccess) in
                self?.hideActivityIndicator()
                self?.fetchRequestInProcess = false
                if isSuccess {
                    if moduleObject != nil {
                        self?.updateViewForContent()
                        self?.arrayOfItems = (moduleObject?.moduleData)! as? Array<SFGridObject>
                        var tempItemArray = self?.arrayOfItems
                        tempItemArray = tempItemArray?.filter() {$0.updatedDate != nil && $0.contentTitle != nil}
                        self?.arrayOfItems = tempItemArray?.sorted (by: { $0.updatedDate ?? 0.0 > $1.updatedDate ?? 0.0 })
                        self?.tableView?.isHidden = false
                        self?.tableView?.reloadData()
                    } else {
                        self?.tableView?.isHidden = true
                        self?.updateViewForEmptyArray()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self?.hideActivityIndicator()
                        self?.failureAlertType = .RefreshHistoryContent
                        let reachability:Reachability = Reachability.forInternetConnection()
                        if reachability.currentReachabilityStatus() == NotReachable {
                            self?.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
                        }
                        else {
                            self?.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived)
                        }
                    }
                }
            }
        }
    }
    
    /// Creates the view.
    func createView() {
        createModulesForPage()
    }
    
    private func createModulesForPage() {
        for component:AnyObject in (self.moduleObject?.components)! {
            
            if component is SFButtonObject {
                
                let buttonObject:SFButtonObject = component as! SFButtonObject
                createButtonView(buttonObject: buttonObject, containerView: self.view, type: component.key!!)
            }
            else if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject, containerView: self.view, type: component.key!!)
            }
            else if component is SFTableViewObject {
                
                createTableView(tableViewObject: component as! SFTableViewObject)
            }
            else if component is SFSeparatorViewObject {
                
                createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
            }
        }
    }
    
    //method to create separator view
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        let separatorView:SFSeparatorView = SFSeparatorView(frame: CGRect.zero)
        separatorView.separtorViewObject = separatorViewObject
        separatorView.relativeViewFrame = relativeViewFrame!
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject))
        self.view.addSubview(separatorView)
        separatorView.isHidden = false
    }
    
    func createButtonView(buttonObject:SFButtonObject, containerView:UIView, type: String) -> Void {
        
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        
        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.buttonLayout = buttonLayout
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.buttonDelegate = self
        button.createButtonView()
        containerView.addSubview(button)
        
        if type == "playButton" {
            button.setImage(UIImage(named: "videoDetailPlayIcon_tvOS")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState.normal)
            if let textColor = AppConfiguration.sharedAppConfiguration.primaryButton.backgroundColor {
                button.imageView?.tintColor = Utility.hexStringToUIColor(hex: textColor)
            }
            button.contentMode = .scaleAspectFit
            button.buttonShowsAnImage = true
        }
        if button.buttonObject?.key == "removeAll" {
            button.isHidden = true
            let removeAllContainerView = UIView.init(frame: CGRect(x: 0.0, y: 0, width: (Double(self.view.bounds.size.width)), height: (Double(button.bounds.size.height + button.frame.origin.y))))
            containerView.addSubview(removeAllContainerView)
            removeAllContainerView.backgroundColor = UIColor.clear
            
            let backgroundFocusGuide : UIFocusGuide = UIFocusGuide()
            removeAllContainerView.addLayoutGuide(backgroundFocusGuide)
            
            backgroundFocusGuide.leftAnchor.constraint(equalTo: removeAllContainerView.leftAnchor).isActive = true
            backgroundFocusGuide.topAnchor.constraint(equalTo: removeAllContainerView.topAnchor).isActive = true
            backgroundFocusGuide.widthAnchor.constraint(equalTo: removeAllContainerView.widthAnchor).isActive = true
            backgroundFocusGuide.heightAnchor.constraint(equalTo: removeAllContainerView.heightAnchor).isActive = true
            backgroundFocusGuide.preferredFocusedView = button
               
        }
        
        containerView.bringSubview(toFront: button)
    }
    
    func createLabelView(labelObject:SFLabelObject, containerView:UIView, type: String) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.text = labelObject.text
        label.createLabelView()
        
        if labelObject.key == "pageTitle" {
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor ?? "#ffffff")
        }
        containerView.addSubview(label)
    }
    
    func fixTableViewInsets() {
        let zContentInsets = UIEdgeInsets.zero
        self.tableView?.contentInset = zContentInsets
        self.tableView?.scrollIndicatorInsets = zContentInsets
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        fixTableViewInsets()
    }
    
    //method to create table view
    func createTableView(tableViewObject:SFTableViewObject) {
        
        let tableViewLayout = Utility.sharedUtility.fetchTableViewLayoutDetails(tableViewObject: tableViewObject)
        tableView = SFTableView(frame: CGRect.zero, style: .plain)
        tableView?.relativeViewFrame = relativeViewFrame!
        tableView?.tableObject = tableViewObject
        tableView?.tableLayout = tableViewLayout
        tableView?.initialiseTableViewFrameFromLayout(tableViewLayout: tableViewLayout)
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.updateTableView()
        tableView?.register(SFTableViewCell_tvOS.self, forCellReuseIdentifier: "tableViewCustomCell")
        tableView?.mask = nil
        tableView?.backgroundView = nil
        tableView?.backgroundColor = UIColor.clear
        tableView?.clipsToBounds = true
        self.view.addSubview(tableView!)
        self.tableView?.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = self.arrayOfItems?.count {
            return count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == ((self.arrayOfItems?.count)! - 1) {
            return CGFloat((self.tableView?.tableLayout?.itemHeight) ?? 44 ) + 200
        }
        return CGFloat((self.tableView?.tableLayout?.itemHeight) ?? 44 )
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //MARK: TableView delegates
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var customTableViewCell:SFTableViewCell_tvOS? = tableView.dequeueReusableCell(withIdentifier: "tableViewCustomCell") as? SFTableViewCell_tvOS
        
        if customTableViewCell == nil {
            
            customTableViewCell = SFTableViewCell_tvOS(style: .default, reuseIdentifier: "tableViewCustomCell")
        }
        
        customTableViewCell?.cellRowValue = indexPath.row
        addCustomTableViewCellToTable(customTableViewCell: customTableViewCell!, gridObject: arrayOfItems?[indexPath.row])
        customTableViewCell?.contentView.backgroundColor = UIColor.clear
        customTableViewCell?.selectionStyle = .none
        
        return customTableViewCell!
    }
    
    //MARK: method to custom table view cell
    func addCustomTableViewCellToTable(customTableViewCell:SFTableViewCell_tvOS, gridObject:SFGridObject?) {
        
        customTableViewCell.backgroundColor = UIColor.clear
        customTableViewCell.selectionStyle = .none
        customTableViewCell.relativeViewFrame = CGRect(x: 0, y: 0, width: (tableView?.frame.size.width)!, height: CGFloat(tableView?.tableLayout?.gridHeight ?? 44))
        customTableViewCell.tableComponents = (tableView?.tableObject?.trayComponents)!
        customTableViewCell.tableViewCellDelegate = self
        customTableViewCell.gridObject = gridObject!
        customTableViewCell.updateGridSubView()
        
        if self.moduleObject?.contentPageType == .history {
            
            if customTableViewCell.gridObject?.watchedTime ?? 0 > 0 {
                
                customTableViewCell.progressView?.isHidden = false
            }
            else {
                
                customTableViewCell.progressView?.isHidden = true
            }
        }
        else {
            
            customTableViewCell.progressView?.isHidden = true
        }
    }
    
    //MARK: Removing single video from watchlist
    func removeVideoFromQueue(contentId:String, cellRowValue:Int) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshRemoveFromWatchlist
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, contentId: nil, cellRowValue: nil, errorMessage: nil, errorTitle: nil)
        }
        else {
            
            var indexOfItemToBeDeleted:Int?
            
            for (index, item) in (self.arrayOfItems?.enumerated())! {
                
                if item.contentId == contentId {
                    
                    indexOfItemToBeDeleted = index
                    break
                }
            }
            
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")&contentIds=\(contentId)"
            showActivityIndicator()
            
            DataManger.sharedInstance.removeVideosFromQueue(apiEndPoint: apiEndPoint) { [weak self] (isVideoRemoved) in
                
                self?.hideActivityIndicator()
                
                if isVideoRemoved {
                    
                    if indexOfItemToBeDeleted != nil {
                        
                        self?.arrayOfItems?.remove(at: indexOfItemToBeDeleted!)
                        self?.tableView?.deleteRows(at: [IndexPath(row: indexOfItemToBeDeleted!, section: 0)], with: .fade)
                    }
                    if self?.arrayOfItems?.count == 0 {

                        self?.updateViewForEmptyArray()
                    }
                }
                else {
                    
                    self?.failureAlertType = .RefreshRemoveFromWatchlist
                    
                    let reachability:Reachability = Reachability.forInternetConnection()
                    
                    if reachability.currentReachabilityStatus() == NotReachable {
                        
                        self?.failureAlertType = .RefreshRemoveFromWatchlist
                        self?.showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, contentId: nil, cellRowValue: nil, errorMessage: nil, errorTitle: nil)
                    }
                    else {
                        self?.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, contentId: contentId, cellRowValue: indexOfItemToBeDeleted, errorMessage: "Unable to remove video from watchlist.", errorTitle: "Watchlist")
                    }
                    
                }
            }
        }
    }
    
    //MARK: Remove all videos from queue
    private func removeAllVideoFromQueue() {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshRemoveAllFromWatchlist
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, contentId: nil, cellRowValue: nil, errorMessage: nil, errorTitle: nil)
        }
        else {
            
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")"
            self.showActivityIndicator()
            
            DataManger.sharedInstance.removeVideosFromQueue(apiEndPoint: apiEndPoint) { [weak self] (isVideoRemoved) in
                
                self?.hideActivityIndicator()
                
                if isVideoRemoved {
                    
                    self?.arrayOfItems?.removeAll()
                    self?.tableView?.reloadData()
                    if let empty = self?.arrayOfItems?.isEmpty {
                        if empty {
                            self?.updateViewForEmptyArray()
                        }
                    }
                }
                else {
                    
                    self?.failureAlertType = .RefreshRemoveAllFromWatchlist
                    self?.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, contentId: nil, cellRowValue: nil, errorMessage: "Unable to remove videos from watchlist.", errorTitle: "Watchlist")
                }
            }
        }
    }
    
    //MARK: Remove all videos from history
    private func removeAllVideoFromHistory() {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshRemoveAllFromHistory
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, contentId: nil, cellRowValue: nil, errorMessage: nil, errorTitle: nil)
        }
        else {
            
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/video/history/user/\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
            self.showActivityIndicator()
            
            DataManger.sharedInstance.removeVideosFromQueue(apiEndPoint: apiEndPoint) { [weak self] (isVideoRemoved) in
                
                self?.hideActivityIndicator()
                
                if isVideoRemoved {
                    
                    self?.arrayOfItems?.removeAll()
                    self?.tableView?.reloadData()
                    if let empty = self?.arrayOfItems?.isEmpty {
                        if empty {
                            self?.updateViewForEmptyArray()
                        }
                    }
                }
                else {
                    
                    self?.failureAlertType = .RefreshRemoveAllFromHistory
                    self?.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, contentId: nil, cellRowValue: nil, errorMessage: "Unable to remove videos from history.", errorTitle: "Delete History")
                }
            }
        }
    }
    
    func buttonClicked(button: SFButton, gridObject: SFGridObject?, cellRowValue: Int) {
        if button.buttonObject?.action == "deleteItem" {
            self.removeVideoFromQueue(contentId: (gridObject?.contentId)!, cellRowValue: cellRowValue)
        } else {
            if self.delegate != nil {
                if self.moduleObject?.contentPageType == .history {
                    if (delegate?.responds(to: #selector(SFWatchlistAndHistoryViewModuleDelegate.launchVideo(gridObject:cellRowValue:))))! {
                        delegate?.launchVideo!(gridObject: gridObject, cellRowValue:cellRowValue)
                    }
                } else {
                    if (delegate?.responds(to: #selector(SFWatchlistAndHistoryViewModuleDelegate.openVideoDetails(gridObject:cellRowValue:))))! {
                        delegate?.openVideoDetails!(gridObject: gridObject, cellRowValue:cellRowValue)
                    }
                }
            }
        }
    }
    
    func playVideo(button: UIButton, gridObject: SFGridObject?, cellRowValue: Int) {
        if self.delegate != nil {
            if self.moduleObject?.contentPageType == .history {
                if (delegate?.responds(to: #selector(SFWatchlistAndHistoryViewModuleDelegate.launchVideo(gridObject:cellRowValue:))))! {
                    delegate?.launchVideo!(gridObject: gridObject, cellRowValue:cellRowValue)
                }
            } else {
                if (delegate?.responds(to: #selector(SFWatchlistAndHistoryViewModuleDelegate.openVideoDetails(gridObject:cellRowValue:))))! {
                    delegate?.openVideoDetails!(gridObject: gridObject, cellRowValue:cellRowValue)
                }
            }
        }
    }
    
    @objc func buttonClicked(button: SFButton) {
        
        let okAction:UIAlertAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (buttonAction) in
            
            if self.moduleObject?.contentPageType == .watchlist {
                
                self.removeAllVideoFromQueue()
            }
            else {
                
                self.removeAllVideoFromHistory()
            }
        })
        
        let cancelAction:UIAlertAction = UIAlertAction(title: Constants.kStrCancel, style: .default, handler: { (buttonAction) in
            
        })
        
        var alertTitle:String?
        var alertMessage:String?
        
        if self.moduleObject?.contentPageType == .watchlist {
            
            alertTitle = "CLEAR WATCHLIST?"
            alertMessage = ""
        }
        else {
            
            alertTitle = "CLEAR HISTORY?"
            alertMessage = ""
        }
        
        let alertController:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitle ?? "", alertMessage: alertMessage ?? "", alertActions: [cancelAction, okAction])
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Display Network Error Alert
    func showAlertForAlertType(alertType: AlertType) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                if self.failureAlertType == .RefreshQueueContent {
                    
                    self.fetchQueueContent()
                }
                else if self.failureAlertType == .RefreshHistoryContent {
                    
                    self.fetchHistoryContent()
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
            alertTitleString = "No Response Received"
            alertMessage = "Unable to fetch data!\nDo you wish to Try Again?"
        }
        
        networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction, retryAction])
        
        self.present(networkUnavailableAlert!, animated: true, completion: nil)
    }
    
    //MARK:Display Error in removing from watchlist
    func showWatchlistAlertForAlertType(alertType: AlertType, contentId:String?, cellRowValue:Int?, errorMessage:String?, errorTitle:String?) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                if self.failureAlertType == .RefreshRemoveAllFromWatchlist {
                    
                    self.removeAllVideoFromQueue()
                }
                else if self.failureAlertType == .RefreshRemoveFromWatchlist {
                    
                    self.removeVideoFromQueue(contentId: contentId!, cellRowValue: cellRowValue!)
                }
                else if self.failureAlertType == .RefreshRemoveAllFromHistory {
                    
                    self.removeAllVideoFromHistory()
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
        
        self.present(networkUnavailableAlert!, animated: true, completion: nil)
    }
    
    /* getEmptyMessageLbl method is used for creating label and displaying message in absense of network and data is not available to display.*/
    func updateViewForEmptyArray() {
        var fontFamily:String?
        if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
            fontFamily = _fontFamily
        }
        if fontFamily == nil {
            fontFamily = "OpenSans"
        }
        if emptyMessageLbl == nil {
            emptyMessageLbl = UILabel.init(frame: CGRect(x: 0, y: 0, width: 900, height: 100))
        }
        emptyMessageLbl?.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        emptyMessageLbl?.font = UIFont(name: "\(fontFamily!)-Semibold", size: 28)
        emptyMessageLbl?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")//UIColor.white
        emptyMessageLbl?.textAlignment = .center
        emptyMessageLbl?.numberOfLines = 0
        if moduleObject?.contentPageType == .watchlist {
            if Utility.sharedUtility.checkIfUserIsLoggedIn() {
                emptyMessageLbl?.text = "You haven't added anything to your watchlist."
            } else {
                emptyMessageLbl?.text = "You need to be signed in to view your watchlist."
            }
        } else {
            if Utility.sharedUtility.checkIfUserIsLoggedIn() {
                emptyMessageLbl?.text = "You haven't watched anything yet."
            } else {
                emptyMessageLbl?.text = "You need to be signed in to view your history."
            }
        }
        self.view.addSubview(emptyMessageLbl!)
        self.updateClearHistoryButton(false)
    }
    
    /*updateViewForContent method is used for removing label from view if label is displaying*/
    func updateViewForContent() {
        emptyMessageLbl?.removeFromSuperview()
        updateClearHistoryButton(true)
    }
    
    private func updateClearHistoryButton(_ isEnabled: Bool) {
        for subView in self.view.subviews {
            if subView is SFButton {
                
                let button:SFButton = subView as! SFButton
                
                if button.buttonObject?.key == "removeAll" {
                    
                    button.isEnabled = isEnabled
                    button.isUserInteractionEnabled = isEnabled
                    button.isHidden = !isEnabled
                }
            }
        }
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
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
    
    //MARK:Display Error in removing from watchlist
    func showAlert(alertType: AlertType, filmObject:SFFilm?, errorMessage:String?, errorTitle:String?) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
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

}
