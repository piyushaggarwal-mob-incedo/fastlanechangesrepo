//
//  AncillaryPageViewController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 14/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import GoogleCast
import Firebase

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

class AncillaryPageViewController: UIViewController, SFButtonDelegate, UITableViewDataSource, UITableViewDelegate, SFTableViewCellDelegate, UserDetailsViewDelegate, GCKUIMiniMediaControlsViewControllerDelegate, SFBannerViewDelegate, SFMorePopUpViewControllerDelegate,SFKisweBaseViewControllerDelegate {

    enum CompeletionHandlerOptions {
        
        case UpdateWatchlist
        case UpdateVideoPlay
    }
    
    var viewControllerPage: Page?
    var tableView:SFTableView?
    var userAccountTableView:UITableView?
    var modulesListDict:Dictionary<String, Any> = [:]
    var pageAPIObject:PageAPIObject?
    var progressIndicator:MBProgressHUD?
    var modulesLayoutListArray:Array<Any> = []
    var alertType:AlertType?
    var networkUnavailableAlert:UIAlertController?
    var contentOffSetDictionary:Dictionary<String, AnyObject> = [:]
    var cellModuleDict:Dictionary<String, AnyObject> = [:]
    var trayObject:SFTrayObject?
    var userAccountObject: UserAccountModuleObject?
    var relativeViewFrame:CGRect?
    var pagePath:String?
    var apiModuleListArray:Array<AnyObject> = []
    var userDetails: SFUserDetails?
    var failureAlertType:PageLoadAfterFailureAlert?
    var isWatchlistUpdated:Bool = false
    var isHistoryUpdated:Bool = false
    var _miniMediaControlsContainerView: UIView!
    var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    var userUIAccountModuleDict:Dictionary<String, AnyObject>?
    var userAccountModuleData:Array<AnyObject>?
    var pageName:String?
    private var isTableHeaderAvailable:Bool = false
    private var tableHeaderView:UIView?
    private var bannerViewObject:SFBannerViewObject?
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

        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "FFFFFF")
        
        if viewControllerPage?.modules != nil {
            
            for module:Any in (viewControllerPage?.modules)! {
                
                if module is SFTrayObject {
                    
                    trayObject = module as? SFTrayObject
                }
                else if module is UserAccountModuleObject{
                    userAccountObject = module as? UserAccountModuleObject
                }
            }
            
            relativeViewFrame = self.view.frame
            relativeViewFrame?.origin.y += Utility.sharedUtility.getPosition(position: 20)
            relativeViewFrame?.size.height -= Utility.sharedUtility.getPosition(position: 20)
            
            NotificationCenter.default.addObserver(self, selector: #selector(updateWatchlistStatus), name: NSNotification.Name(rawValue: "isWatchlistUpdated"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateHistoryStatus), name: NSNotification.Name(rawValue: "isHistoryUpdated"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(displayViewContent), name: NSNotification.Name(rawValue: "dismissDownloaQualityView"), object: nil)
            createViewComponents()
        }
    }
    
//    func applicationUpdated()  {
//        var zz: Int = 0
//        for page in AppConfiguration.sharedAppConfiguration.pages
//        {
//            let localPage: Page = page
//            if localPage.pageId == self.pageName
//            {
//                if localPage.isPageUpdated == true
//                {
//                    createViewComponents()
//                    localPage.isPageUpdated = false
//                }
//                AppConfiguration.sharedAppConfiguration.pages[zz] = localPage
//            }
//            zz = zz + 1
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateControlBarsVisibility()
       
        var pageTitle = self.pageName ?? "UserManagement"
        pageTitle += " Screen"
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {

            if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
            {
                FIRAnalytics.setScreenName(pageTitle, screenClass: nil)
            }
        }
        
        loadPageData()
        
        if viewControllerPage?.modules != nil {
            
            for module:Any in (viewControllerPage?.modules)! {
                
                if module is SFTrayObject {
                    
                    trayObject = module as? SFTrayObject
                }
            }
        }

        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.allowIDFACollection = true
        tracker.set(kGAIScreenName, value: "\(pageTitle)")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateWatchlistStatus() {
        
        isWatchlistUpdated = true
    }
    
    
    func updateHistoryStatus() {
        
        isHistoryUpdated = true
    }
    
    //MARK: Method to fetch page module layout list
    func createPageModuleLayoutList() {
        
        if viewControllerPage?.modules != nil {
            
            for module:Any in (viewControllerPage?.modules)! {
                
                if module is SFTrayObject {
                    
                    let trayObject:SFTrayObject = module as! SFTrayObject
                    
                    if checkIfModuleComingInServerResponse(moduleId: trayObject.trayId) {
                        
                        modulesListDict["\(trayObject.trayId!)"] = trayObject
                        modulesLayoutListArray.append(trayObject)
                        
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
    
    //MARK: - Create View Components
    func createViewComponents() {
        
        if trayObject != nil {
            
            for component:Any in (trayObject?.trayComponents)! {
                
                if component is SFButtonObject {
                    
                    createButtonView(buttonObject: component as! SFButtonObject)
                }
                else if component is SFTextViewObject {
                    
                    createTextView(textViewObject: component as! SFTextViewObject)
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
        else if userAccountObject != nil
        {
            userUIAccountModuleDict = [:]
            for component:Any in (userAccountObject?.components)!
            {
                if component is SFButtonObject {
                    
                    createButtonView(buttonObject: component as! SFButtonObject)
                }
                else if component is SFSeparatorViewObject {
                    
                    createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
                }
                else if component is SFLabelObject {
                    
                    createLabelView(labelObject: component as! SFLabelObject)
                }
                else if component is UserAccountComponentObject{
                    
                    let userAccountComponentObject = component as! UserAccountComponentObject
                    
                    userUIAccountModuleDict?["\(userAccountComponentObject.key ?? "tempKey")"] = userAccountComponentObject
                }
            }
            
            if (userUIAccountModuleDict?.count)! > 0 {
                
                createTableView()
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
    
    
    //method to create textview
    func createTextView(textViewObject:SFTextViewObject) {
        
        let textViewLayout = Utility.fetchTextViewLayoutDetails(textViewObject: textViewObject)
        let textView:SFTextView = SFTextView(frame: CGRect.zero)
        textView.textViewObject = textViewObject
        textView.textViewLayout = textViewLayout
        textView.relativeViewFrame = relativeViewFrame!
        textView.updateView()
        textView.textContainer.lineFragmentPadding = 0
        
        textView.isEditable = false
        textView.isSelectable = false
        
        self.view.addSubview(textView)
        updateTextView(textView: textView)
        
        textView.font = UIFont(name: (textView.font?.fontName)!, size: (textView.font?.pointSize)! * Utility.getBaseScreenHeightMultiplier())
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
            
            button.isHidden = true
            
            button.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000")
            button.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor ?? AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        }
        
        self.view.addSubview(button)
        updateButtonView(button: button)
        
        button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!, size: (button.titleLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
    }
    
    
    //MARK: method to create user account view
    func createUserAccountView(userAccountViewObject:UserAccountComponentObject) {
        
        let userAccountLayout = Utility.fetchUserAccountViewLayoutDetails(userAccountViewObject: userAccountViewObject)
        
        let userAccountView:UserAccount = UserAccount.init(frame: Utility.initialiseViewLayout(viewLayout: userAccountLayout, relativeViewFrame: relativeViewFrame!), userAccountObject: userAccountObject!, userAccountViewObject: userAccountViewObject, viewTag: 0)
        userAccountView.changeFrameHeight(height: userAccountView.frame.height * Utility.getBaseScreenHeightMultiplier())
        userAccountView.userDetailViewDelegate = self
        userAccountView.userAccountViewLayout = userAccountLayout
        userAccountView.userAccountViewObject = userAccountViewObject
        userAccountView.relativeViewFrame = relativeViewFrame!
        
        self.view.addSubview(userAccountView)
        userAccountView.isHidden = true
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
        tableView?.tag = 200
        self.view.addSubview(tableView!)
        self.tableView?.isHidden = true
    }
    
    
    //MARK: method to create user account module tableView
    func createTableView() {
        
        userAccountTableView = UITableView(frame: CGRect(x: 0, y: 47 * Utility.getBaseScreenHeightMultiplier(), width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 47 * Utility.getBaseScreenHeightMultiplier()), style: .plain)
        userAccountTableView?.delegate = self
        userAccountTableView?.dataSource = self
        userAccountTableView?.separatorStyle = .none
        userAccountTableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        userAccountTableView?.backgroundView = nil
        //MSEIOS-1369
        var pos:CGFloat = 20
        if let pageHeaderObject = AppConfiguration.sharedAppConfiguration.pageHeaderObject{
            if pageHeaderObject.placement != nil && pageHeaderObject.placement?.lowercased() == "Banner".lowercased() {
                if let isSubscribed = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool{
                if !isSubscribed {
                    pos = 10
                }
              }
            }
        }
        userAccountTableView?.changeFrameYAxis(yAxis: (userAccountTableView?.frame.minY)! + Utility.sharedUtility.getPosition(position: pos))
        userAccountTableView?.backgroundColor = UIColor.clear
        userAccountTableView?.showsVerticalScrollIndicator = false
        userAccountTableView?.tag = 201
        userAccountTableView?.register(SFUserAccountTableCell.self, forCellReuseIdentifier: "userAccountCell")
        self.view.addSubview(userAccountTableView!)
        self.userAccountTableView?.isHidden = true
    }

    //MARK: TableView delegates
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView.tag == 200 {
            
            var customTableViewCell:SFTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "tableViewCustomCell") as? SFTableViewCell
            
            if customTableViewCell == nil {
                
                customTableViewCell = SFTableViewCell(style: .default, reuseIdentifier: "tableViewCustomCell")
            }
            
            customTableViewCell?.cellRowValue = indexPath.row
            addCustomTableViewCellToTable(customTableViewCell: customTableViewCell!, gridObject: apiModuleListArray[indexPath.row] as? SFGridObject)
            
            return customTableViewCell!
        }
        else {
            
            var tableViewCell:SFUserAccountTableCell? //= tableView.dequeueReusableCell(withIdentifier: "userAccountCell") as? SFUserAccountTableCell

            if tableViewCell == nil && userAccountModuleData != nil {
                
                let userAccountLayout = Utility.fetchUserAccountViewLayoutDetails(userAccountViewObject: userAccountModuleData?[indexPath.row] as! UserAccountComponentObject)
                let rowHeight:CGFloat = CGFloat(userAccountLayout.height ?? 200) * Utility.getBaseScreenHeightMultiplier()
                let cellFrame:CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: rowHeight)
                
                tableViewCell = SFUserAccountTableCell(userAccountObject: userAccountObject!, userAccountViewObject: userAccountModuleData?[indexPath.row] as! UserAccountComponentObject, userAccountLayout: userAccountLayout, relativeViewFrame: cellFrame)
            }

            if tableViewCell != nil && userAccountModuleData != nil {
                addUserAccountModuleToTable(tableViewCell: tableViewCell!, userAccountViewObject: userAccountModuleData?[indexPath.row] as! UserAccountComponentObject)
            }
            
            if tableViewCell == nil && userAccountModuleData == nil {
                
                tableViewCell = SFUserAccountTableCell(style: .default, reuseIdentifier: "userAccountCell")
            }
            
            return tableViewCell!
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 200 {
            return apiModuleListArray.count
        }
        else if tableView.tag == 201 {
            
            return userAccountModuleData?.count ?? 0
        }
        else {
            
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView.tag == 200 {
            
            return CGFloat(((self.tableView?.tableLayout?.gridHeight) ?? 44 )) * Utility.getBaseScreenHeightMultiplier()
        }
        else if tableView.tag == 201 {
            
            if userAccountModuleData != nil {
                
                let userAccountLayout = Utility.fetchUserAccountViewLayoutDetails(userAccountViewObject: userAccountModuleData?[indexPath.row] as! UserAccountComponentObject)
                let rowHeight:CGFloat =  CGFloat(userAccountLayout.height ?? 200)
                
                return (rowHeight * Utility.getBaseScreenHeightMultiplier())
            }
            else
            {
                return 0
            }
        }
        else {
            
            return 0
        }
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

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            
            if self.isTableHeaderAvailable && self.bannerViewObject != nil {
                
                let bannerViewLayout = Utility.fetchBannerViewLayoutDetails(bannerViewObject: self.bannerViewObject!)
                let bannerViewFrame = Utility.initialiseViewLayout(viewLayout: bannerViewLayout, relativeViewFrame: tableView.frame)
                
                var headerHeight:CGFloat = bannerViewFrame.size.height
                
                if !Utility.sharedUtility.checkIfUserIsSubscribedGuest() && !Utility.sharedUtility.checkIfUserIsLoggedIn() {
                    
                    if let pageHeaderObject = AppConfiguration.sharedAppConfiguration.pageHeaderObject {
                        
                        if pageHeaderObject.buttonText != nil  && (pageHeaderObject.placement != nil && pageHeaderObject.placement?.lowercased() == "Banner".lowercased()) {
                            
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
    
    func removeKisweBaseViewController(viewController:UIViewController) -> Void{
        self.view.isUserInteractionEnabled = true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 200 {
            
            var viewControllerPage:Page?
            
            let gridObject:SFGridObject? = apiModuleListArray[indexPath.row] as? SFGridObject
            
            //check for kiswe event and display kiswe controller
            let eventId = gridObject?.eventId
            if eventId != nil && Constants.kAPPDELEGATE.isKisweEnable{
                
                Utility.presentKiswePlayer(forEventId: eventId!, withFilmId: gridObject?.contentId ?? "",vc: self)
                return
            }
            
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
            else {
                
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
                    
                    videoDetailViewController.contentId = gridObject?.contentId
                    videoDetailViewController.pagePath = gridObject?.gridPermaLink
                    videoDetailViewController.view.changeFrameYAxis(yAxis: 20.0)
                    videoDetailViewController.view.changeFrameHeight(height: videoDetailViewController.view.frame.height - 20.0)
                    
                    if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                        
                        if self.navigationController != nil {
                            
                            self.navigationController?.pushViewController(videoDetailViewController, animated: true)
                        }
                        else {
                            
                            videoDetailViewController.isNavControllerCreated = true
                            let navController = UINavigationController(rootViewController: videoDetailViewController)
                            
                            self.present(navController, animated: true, completion: nil)
                        }
                    }
                    else {
                        
                        self.present(videoDetailViewController, animated: true, completion: nil)
                    }
                
            }
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
        
        let moduleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(trayObject?.trayId ?? "")"] as? SFModuleObject
        
        if moduleObject?.moduleType == "HistoryModule" {
            
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
    
    
    //MARK: method to add user account module to tableview cell
    func addUserAccountModuleToTable(tableViewCell:SFUserAccountTableCell, userAccountViewObject:UserAccountComponentObject) {
        
        tableViewCell.selectionStyle = .none
        tableViewCell.backgroundColor = UIColor.clear
        tableViewCell.contentView.backgroundColor = UIColor.clear
        
        tableViewCell.userAccountView?.userDetails = userDetails
        tableViewCell.userAccountView?.updateView()
        tableViewCell.userAccountView?.updateUserDetailsOnView()
        
        if tableViewCell.userAccountView != nil {
            
            tableViewCell.userAccountView?.userDetailViewDelegate = self
        }
    }
    
    
    //MARK: Load Page Data
    func loadPageData() {
        if AppConfiguration.sharedAppConfiguration.isUserDetailUpdated
        {
            self.fetchPageContent()
        }
        else if pageAPIObject == nil
        {
            self.fetchPageContent()
        }
        else if isWatchlistUpdated {
            
            let moduleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(trayObject?.trayId ?? "")"] as? SFModuleObject
            
            if moduleObject?.moduleType == "QueueModule" {
                
                showActivityIndicator(loaderText: "Loading...")
                self.fetchQueueContent()
            }
            else {
                isWatchlistUpdated = false
            }
        }
        else if isHistoryUpdated {
            
            let moduleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(trayObject?.trayId ?? "")"] as? SFModuleObject

            if moduleObject?.moduleType == "HistoryModule" {
                
                showActivityIndicator(loaderText: "Loading...")
                self.fetchHistoryContent()
            }
            else {
                
               isHistoryUpdated = false
            }
        }
    }
    
    
    //MARK: Method to fetch page content
    func fetchPageContent() {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshPageContent
            
            showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
        }
        else {
            
            showActivityIndicator(loaderText: "Loading...")
            
            var apiEndPoint:String? = "\(self.viewControllerPage?.pageAPI ?? "/content/pages")?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&includeContent=true"
            
            if pagePath != nil {
                
                apiEndPoint = "\(apiEndPoint ?? "")&path=\(pagePath ?? "")"
            }
            else if self.viewControllerPage?.pageId != nil {
                apiEndPoint = "\(apiEndPoint ?? "")&pageId=\(self.viewControllerPage?.pageId ?? "")"
                
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                DataManger.sharedInstance.fetchContentForAncillaryPage(shouldUseCacheUrl: self.viewControllerPage?.shouldUseCacheAPI ?? false, apiEndPoint: apiEndPoint!) { (pageAPIObjectResponse) in
                    
                    if pageAPIObjectResponse != nil {
                        
                        self.pageAPIObject = pageAPIObjectResponse

                        if self.checkIfModuleExistInPageAPIObject(moduleName: "QueueModule") {
                            
                            self.fetchQueueContent()
                        }
                        else if self.checkIfModuleExistInPageAPIObject(moduleName: "HistoryModule") {
                            
                            self.fetchHistoryContent()
                        }
                        else if self.checkIfModuleExistInPageAPIObject(moduleName: "UserManagementModule") && (Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest())
                        {
                            self.fetchUserDetailModuleContent()
                        }
                        else if self.checkIfModuleExistInPageAPIObject(moduleName: "UserManagementModule") {
                            
                            self.addSettingModule(isUserDetailAvailable: false, isSubscripitonInfoAvailable: false)
                            self.displayViewContent()
                        }
                        else {
                            
                            self.displayViewContent()
                        }
                    }
                    else {
                        
                        DispatchQueue.main.async {
                            self.hideActivityIndicator()
                            self.failureAlertType = .RefreshPageContent
                            self.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived)
                        }
                    }
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
        else if userAccountObject != nil{
            let moduleObject = self.pageAPIObject?.pageModules!["\((userAccountObject?.moduleID)!)"] as? SFModuleObject
            if moduleObject != nil {
                
                if moduleName == moduleObject?.moduleType {
                    
                    isModulePresent = true
                }
            }
        }
        return isModulePresent
    }
    
    
    //MARK: Method to fetch History content
    func fetchHistoryContent() {
        
        let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/video/history/user/\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")&offset=0"
        
        DataManger.sharedInstance.fetchQueueResults(apiEndPoint: apiRequest) { (moduleObject, isSuccess) in
            
            if moduleObject != nil && isSuccess {
                
                self.isHistoryUpdated = false
                self.apiModuleListArray = (moduleObject?.moduleData)!
                if let arrayOfGridItems:Array<SFGridObject> = self.apiModuleListArray as? Array<SFGridObject> {
                    var tempItemArray = arrayOfGridItems
                    tempItemArray = tempItemArray.filter() {$0.updatedDate != nil && $0.contentTitle != nil}
                    self.apiModuleListArray = tempItemArray.sorted (by: { $0.updatedDate ?? 0.0 > $1.updatedDate ?? 0.0 })
                }
                self.displayViewContent()
                
                if self.apiModuleListArray.count > 0 {
                    self.tableView?.scrollsToTop = true
                }
            }
            else if isSuccess {
                
                self.displayViewContent()
            }
            else {
                
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.failureAlertType = .RefreshHistoryContent
                    self.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived)
                }
            }
        }
    }
    
    
    //MARK: Method to fetch History content
    func fetchDownLoadedContent() {
        
        let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/video/history/user/\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")&offset=0"
        
        DataManger.sharedInstance.fetchQueueResults(apiEndPoint: apiRequest) { (moduleObject, isSuccess) in
            
            if moduleObject != nil && isSuccess {
                
                self.isHistoryUpdated = false
                self.apiModuleListArray = (moduleObject?.moduleData)!
                self.displayViewContent()
                
                if self.apiModuleListArray.count > 0 {
                    self.tableView?.scrollsToTop = true
                }
            }
            else if isSuccess {
                
                self.displayViewContent()
            }
            else {
                
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.failureAlertType = .RefreshHistoryContent
                    self.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived)
                }
            }
        }
    }

    
    func fetchUserDetailModuleContent() {
        
        let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/identity/user?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        DataManger.sharedInstance.fetchUserPageDetails(apiEndPoint: apiRequest) { (userResult, isSuccess) in
            
            self.userAccountModuleData = []
            if userResult != nil && isSuccess {
                
                self.userDetails = userResult
                
                if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                    
                    self.fetchSubscriptionStatus()
                }
                else {
                    
                    self.addSettingModule(isUserDetailAvailable: true, isSubscripitonInfoAvailable: false)
                    self.displayViewContent()
                }
            }
            else if isSuccess {
                
                self.addSettingModule(isUserDetailAvailable: false, isSubscripitonInfoAvailable: true)
                self.displayViewContent()
            }
            else {
                
                if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                    
                    self.fetchSubscriptionStatus()
                }
                else {
                    self.hideActivityIndicator()
                    self.displayViewContent()
                }
            }
        }
    }
    
    
    func fetchSubscriptionStatus() {
        
        if self.userDetails == nil {
            
            self.userDetails = SFUserDetails()
        }
        
        DataManger.sharedInstance.apiToGetUserSubscriptionStatus(success: { (userSubscriptionStatus, isSuccess) in
            
            DispatchQueue.main.async {
                
                if userSubscriptionStatus != nil {
                    
                    self.addSettingModule(isUserDetailAvailable: true, isSubscripitonInfoAvailable: true)
                    
                    if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) != nil
                    {
                        if (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as! Bool) {
                            
                            let paymentPlatform:String? = userSubscriptionStatus?["platform"] as? String ?? ""
                            let planId:String? = userSubscriptionStatus?["name"] as? String ?? ""
                            let planProductId:String? = userSubscriptionStatus?["planProductId"] as? String
                            
                            self.userDetails?.paymentProcessor = paymentPlatform
                            self.userDetails?.subscriptionPlan = planId
                            self.userDetails?.isSubscribed = true
                            self.userDetails?.paymentMethod =  userSubscriptionStatus?["paymentHandlerDisplayName"] as? String ?? ""
                            
                            if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                
                                Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                                
                                if planProductId != nil {
                                    Utility.sharedUtility.setGTMUserProperty(userPropertyValue: planProductId!, userPropertyKeyName: Constants.kGTMCurrentSubscriptionIDProperty)
                                }
                                
                                if planId != nil {
                                    
                                    if !(planId?.isEmpty)! {
                                        
                                        Utility.sharedUtility.setGTMUserProperty(userPropertyValue: planId!, userPropertyKeyName: Constants.kGTMCurrentSubscriptionNameProperty)
                                    }
                                }
                            }
                        }
                        else {
                            
                            if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                
                                Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                            }
                            
                            self.userDetails?.subscriptionPlan = "Not Subscribed"
                        }
                    }
                    else {
                        
                        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                            
                            Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                        }
                        
                        self.userDetails?.subscriptionPlan = "Not Subscribed"
                    }
                    
                    //self.userDetails = userResult
                    self.displayViewContent()
                }
                else
                {
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                        
                        Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                    }
                    
                    //else for subscription has no response data
                    self.userDetails?.subscriptionPlan = "Not Subscribed"
                    self.addSettingModule(isUserDetailAvailable: true, isSubscripitonInfoAvailable: true)
                    //self.userDetails = userResult
                    self.displayViewContent()
                }
            }
        })
    }
    
    
    func addSettingModule(isUserDetailAvailable:Bool, isSubscripitonInfoAvailable:Bool) {
        
        if self.userAccountModuleData != nil {
            
            if (self.userAccountModuleData?.count)! > 0 {
                
                self.userAccountModuleData?.removeAll()
            }
        }
        
        if self.userUIAccountModuleDict?["userDetail"] != nil && isUserDetailAvailable {
            
            self.userAccountModuleData?.append((self.userUIAccountModuleDict?["userDetail"])!)
        }
        
        if self.userUIAccountModuleDict?["subscriptionInfo"] != nil && isSubscripitonInfoAvailable {
            
            self.userAccountModuleData?.append((self.userUIAccountModuleDict?["subscriptionInfo"])!)
        }
        
        if self.userUIAccountModuleDict?["autoplay"] != nil {
            
            self.userAccountModuleData?.append((self.userUIAccountModuleDict?["autoplay"])!)
        }
        
        if self.userUIAccountModuleDict?["download"] != nil {
            
            self.userAccountModuleData?.append((self.userUIAccountModuleDict?["download"])!)
        }
    }
    
    
    //MARK: Method to fetch QueueContent
    func fetchQueueContent() {
        
        let apiRequest = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")&limit=1000000"
        DataManger.sharedInstance.fetchQueueResults(apiEndPoint: apiRequest) { (moduleObject, isSuccess) in
            
            if moduleObject != nil && isSuccess {
                
                self.isWatchlistUpdated = false
                self.apiModuleListArray = (moduleObject?.moduleData)!
                self.displayViewContent()
                
                if self.apiModuleListArray.count > 0 {
                    self.tableView?.scrollsToTop = true
                }
            }
            else if isSuccess {
                
                self.displayViewContent()
            }
            else {
                
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.failureAlertType = .RefreshQueueContent
                    self.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived)
                }
            }
        }
    }
   
    
    //MARK: Method to display view
    func displayViewContent() {
        
        DispatchQueue.main.async {
            
            self.hideActivityIndicator()
            self.cellModuleDict.removeAll()
            self.updateViewContent()
            
            if self.apiModuleListArray.count > 0 {
                
                self.tableView?.isHidden = false
                self.tableView?.reloadData()
            }
            else if self.userAccountModuleData != nil {
                
                if (self.userAccountModuleData?.count)! > 0 {
                    
                    self.userAccountTableView?.reloadData()
                    self.userAccountTableView?.isHidden = false
                }
            }
            else {
                
                self.createSubscriptionHeader(updateBottomFrame: true)
            }
        }
    }
    
    
    //MARK: - Update View Content
    func updateViewContent() {
        
        if trayObject != nil {
            
            let moduleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(trayObject?.trayId ?? "")"] as? SFModuleObject

            for subView in self.view.subviews {
                
                if subView is SFLabel {
                    
                    let label:SFLabel = subView as! SFLabel
                    
                    if label.labelObject?.key == "title" {
                        label.text = pageAPIObject?.pageTitle
                    }
                    else if label.labelObject?.key == "watchlistLabel" {
                        
                        label.text = "You haven't added anything to your watchlist."
                        
                        if apiModuleListArray.count > 0 {
                            
                            label.isHidden = true
                        }
                        else {
                            label.isHidden = false
                        }
                    }
                    else if label.labelObject?.key == "historyLabel" {
                        
                        label.text = "You haven't watched anything yet."
                        
                        if apiModuleListArray.count > 0 {
                            
                            label.isHidden = true
                        }
                        else {
                            label.isHidden = false
                        }
                    }
                    
                }
                else if subView is SFTextView {
                    
                    if moduleObject?.moduleRawText != nil {
                        
                        let textView:SFTextView =  subView as! SFTextView
                        
                        textView.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: (textView.font?.pointSize)! * Utility.getBaseScreenHeightMultiplier())
                        let textToBeDisplayed:String = (moduleObject?.moduleRawText)!.appending("<style>body{font-family: '\(UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: (textView.font?.pointSize)! * Utility.getBaseScreenHeightMultiplier())!)'; font-size=\((textView.font?.pointSize)! * Utility.getBaseScreenHeightMultiplier())px;}")
                        
                        let attributedText:NSAttributedString = try! NSAttributedString.init(data: textToBeDisplayed.data(using: .unicode)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                        textView.attributedText = attributedText
                        
                        textView.textColor = Utility.hexStringToUIColor(hex: textView.textViewObject?.textColor ?? "ffffff")
                    }
                }
                else if subView is SFButton {
                    
                    if moduleObject?.moduleType == "QueueModule" || moduleObject?.moduleType == "HistoryModule" {
                        
                        let button:SFButton = subView as! SFButton
                        
                        if button.buttonObject?.key == "removeAll" {
                            
                            if apiModuleListArray.count == 0 {
                                
                                button.isHidden = true
                            }
                            else {
                                
                                button.isHidden = false
                                
                            }
                        }
                    }
                }
            }
            
        }
        else if userAccountObject != nil {
            
            for subView in self.view.subviews {
                
                if subView is SFLabel {
                    
                    let label:SFLabel = subView as! SFLabel
                    
                    if label.labelObject?.key == "title" {
                        label.text = pageAPIObject?.pageTitle
                    }
                }
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
        
        let moduleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(trayObject?.trayId ?? "")"] as? SFModuleObject

        if button.buttonObject?.action == "close" {
            
            NotificationCenter.default.removeObserver(self)
            self.dismiss(animated: true, completion: nil)
        }
        else if button.buttonObject?.action == "removeAll" {
            
            let okAction:UIAlertAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (buttonAction) in
                
                if moduleObject?.moduleType == "QueueModule" {
                    
                    self.removeAllVideoFromQueue()
                }
                else if moduleObject?.moduleType == "HistoryModule" {
                    
                    self.removeAllVideoFromHistory()
                }
            })
            
            let cancelAction:UIAlertAction = UIAlertAction(title: Constants.kStrCancel, style: .default, handler: { (buttonAction) in
                
            })

            var alertTitle:String?
            var alertMessage:String?
            
            if moduleObject?.moduleType == "QueueModule" {
                
                alertTitle = Constants.kStrDeleteWatchlistAlertTitle
                alertMessage = Constants.kStrDeleteAllVideosFromWatchlistAlertMessage
            }
            else if moduleObject?.moduleType == "HistoryModule" {
                
                alertTitle = Constants.kStrDeleteHistoryAlertTitle
                alertMessage = Constants.kStrDeleteAllVideosFromHistoryAlertMessage
            }
            
            let alertController:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitle ?? "", alertMessage: alertMessage ?? "", alertActions: [cancelAction, okAction])
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: Remove all videos from queue
    func removeAllVideoFromQueue() {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshRemoveAllFromWatchlist
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, contentId: nil, cellRowValue: nil, errorMessage: nil, errorTitle: nil)
        }
        else {
            
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")"
            self.showActivityIndicator(loaderText: nil)
            
            DataManger.sharedInstance.removeVideosFromQueue(apiEndPoint: apiEndPoint) { (isVideoRemoved) in
                
                self.hideActivityIndicator()
                
                if isVideoRemoved {
                    
                    self.apiModuleListArray.removeAll()
                    self.tableView?.reloadData()
                    if self.apiModuleListArray.count == 0 {
                        
                        self.updateViewForEmptyArray()
                    }
                }
                else {
                    
                    self.failureAlertType = .RefreshRemoveAllFromWatchlist
                    self.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, contentId: nil, cellRowValue: nil, errorMessage: "Unable to remove videos from watchlist.", errorTitle: "Watchlist")
                }
            }
        }
    }
    
    
    //MARK: Remove all videos from history
    func removeAllVideoFromHistory() {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshRemoveAllFromHistory
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, contentId: nil, cellRowValue: nil, errorMessage: nil, errorTitle: nil)
        }
        else {
            
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/video/history/user/\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
            self.showActivityIndicator(loaderText: nil)
            
            DataManger.sharedInstance.removeVideosFromQueue(apiEndPoint: apiEndPoint) { (isVideoRemoved) in
                
                self.hideActivityIndicator()
                
                if isVideoRemoved {
                    
                    self.apiModuleListArray.removeAll()
                    self.tableView?.reloadData()
                    if self.apiModuleListArray.count == 0 {
                        
                        self.updateViewForEmptyArray()
                    }
                }
                else {
                    
                    self.failureAlertType = .RefreshRemoveAllFromHistory
                    self.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, contentId: nil, cellRowValue: nil, errorMessage: "Unable to remove videos from history.", errorTitle: "Delete History")
                }
            }
        }
    }

    
    //MARK: Custom TableView Cell Delegates
    func buttonClicked(button: SFButton, gridObject: SFGridObject?, cellRowValue:Int) {
        
        let moduleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(trayObject?.trayId ?? "")"] as? SFModuleObject

        if button.buttonObject?.action == "delete" {
            
            var alertTitle:String?
            var alertMessage:String?
            
            if gridObject != nil {
                
                let okAction:UIAlertAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (buttonAction) in
                    
                    if moduleObject?.moduleType == "QueueModule" {
                        
                        self.removeVideoFromQueue(contentId: (gridObject?.contentId) ?? "", cellRowValue:cellRowValue)
                    }
                    else if moduleObject?.moduleType == "HistoryModule" {
                        
                        self.removeVideoFromHistory(contentId: (gridObject?.contentId) ?? "", cellRowValue: cellRowValue)
                    }
                })
                
                let cancelAction:UIAlertAction = UIAlertAction(title: Constants.kStrCancel, style: .default, handler: { (buttonAction) in
                    
                })
                
                
                if moduleObject?.moduleType == "QueueModule" {
                    
                    alertTitle = Constants.kStrDeleteWatchlistAlertTitle
                    alertMessage = Constants.kStrDeleteSingleVideoFromWatchlistAlertMessage
                }
                else if moduleObject?.moduleType == "HistoryModule" {
                    
                    alertTitle = Constants.kStrDeleteHistoryAlertTitle
                    alertMessage = Constants.kStrDeleteSingleVideoFromHistoryAlertMessage
                }
                
                
                let alertController:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitle ?? "", alertMessage: alertMessage ?? "", alertActions: [cancelAction, okAction])
                self.present(alertController, animated: true, completion: nil)
            }
        }
        else if button.buttonObject?.action == "watchVideo" {
            
            if gridObject != nil {
                
                if Utility.sharedUtility.checkIfDownloadAlertToBeDisplayedInOfflineMode() {
                    
                    Utility.sharedUtility.displayOfflineAlertToPlayDownloadVideo(viewController: self)
                }
                else {
                    
                    if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                        
                        checkIfUserIsEntitledToVideo(button: button, gridObject: gridObject!)
                    }
                    else {
                        
                        playVideo(gridObject: gridObject)
                    }
                }
            }
        }
    }
    
    
    //MARK: Method to check if user is entitled or not
    func checkIfUserIsEntitledToVideo(button: SFButton?, gridObject:SFGridObject) {
        
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
                                
                                self.playVideo(gridObject: gridObject)
                            }
                            else {
                                
                                self.subscriptionStatusFail(button: button, gridObject: gridObject)
                            }
                        }
                        else {
                            
                            if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                
                                Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                            }
                            
                            self.subscriptionStatusFail(button: button, gridObject: gridObject)
                        }
                    }
                })
            }
        }
        else {
            self.playVideo(gridObject: gridObject)
           // self.displayNonEntitledUserAlert(button: button!, gridObject: gridObject)
        }
    }
    
    
    func subscriptionStatusFail(button: SFButton?, gridObject:SFGridObject) {
        
        let transactionInfo:Dictionary<String, Any>? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as? Dictionary<String, Any>
        
        if transactionInfo != nil {
            
            let receiptData:NSData? = transactionInfo?["receiptData"] as? NSData
            
            if receiptData != nil {
                
                self.updateSubscriptionInfoWithReceiptdata(receipt: receiptData, emailId: nil, productIdentifier: transactionInfo?["productIdentifier"] as? String, transactionIdentifier: transactionInfo?["transactionId"] as? String, success: { (isSuccessfullySubscribed) in
                    
                    if isSuccessfullySubscribed {
                        
                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kUpdateSubscriptionStatusToServer)
                        Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                        Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    }
                    else {
                        
                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                        //self.displayNonEntitledUserAlert(button: button!, gridObject: gridObject)
                    }
                    
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()

                    self.playVideo(gridObject: gridObject)
                })
            }
//            else {
//                
//                self.updateSubscriptionStatusWithReceipt(button: button, gridObject: gridObject, productIdentifier: transactionInfo?["productIdentifier"] as? String, transactionIdentifier: transactionInfo?["transactionId"] as? String)
//            }
        }
        else {
            
            self.playVideo(gridObject: gridObject)
        }
//        else {
//            
//            self.updateSubscriptionStatusWithReceipt(button: button, gridObject: gridObject, productIdentifier: nil, transactionIdentifier: nil)
//            //self.displayNonEntitledUserAlert(button: button!, gridObject: gridObject)
//        }
    }
    
    
    func updateSubscriptionStatusWithReceipt(button: SFButton?, gridObject:SFGridObject,  productIdentifier: String?, transactionIdentifier:String?) {
        
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
                    self.playVideo(gridObject: gridObject)
//                    else {
//                        
//                        self.displayNonEntitledUserAlert(button: button!, gridObject: gridObject)
//                    }
                })
            }
            else {
                self.playVideo(gridObject: gridObject)
                //self.displayNonEntitledUserAlert(button: button!, gridObject: gridObject)
            }
        }
        else {
            self.playVideo(gridObject: gridObject)
            //self.displayNonEntitledUserAlert(button: button!, gridObject: gridObject)
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
    
    
    func displayNonEntitledUserAlert(button: SFButton?, gridObject:SFGridObject) {
        
        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
            
            
        }
        
        let signInAction = UIAlertAction(title: Constants.kStrSign, style: .default) { (signInAction) in
            
            self.displayLoginScreen(button: button, gridObject: gridObject, loginCompeletionHandlerType: .UpdateVideoPlay)
        }
        
        let subscriptionAction = UIAlertAction(title: Constants.kStrSubscription, style: .default) { (subscriptionAction) in
            
            self.displayPlanPage(button: button, gridObject: gridObject, loginCompeletionHandlerType: .UpdateVideoPlay)
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
    
    
    func displayPlanPage(button:SFButton?, gridObject:SFGridObject, loginCompeletionHandlerType:CompeletionHandlerOptions) -> Void {
        
        displayPlanPageWithCompletionHandler(button: button, gridObject: gridObject) { (isSuccessfullyLoggedIn) in
            
            if isSuccessfullyLoggedIn {
                
                if loginCompeletionHandlerType == CompeletionHandlerOptions.UpdateVideoPlay {
                    
                    self.playVideo(gridObject: gridObject)
                }
            }
        }
    }
    
    
    func displayPlanPageWithCompletionHandler(button:SFButton?, gridObject:SFGridObject, completionHandler: @escaping ((_ isSuccessfullyLoggedIn: Bool) -> Void)) -> Void {
        
        let planViewController:SFProductListViewController = SFProductListViewController.init()
        planViewController.completionHandlerCopy = completionHandler
        let navigationController = UINavigationController.init(rootViewController: planViewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
    func displayLoginScreen(button:SFButton?, gridObject:SFGridObject, loginCompeletionHandlerType:CompeletionHandlerOptions) -> Void {
        
        displayLoginViewWithCompletionHandler(button: button, gridObject: gridObject) { (isSuccessfullyLoggedIn) in
            
            if isSuccessfullyLoggedIn {
                
                if loginCompeletionHandlerType == CompeletionHandlerOptions.UpdateVideoPlay {
                    
                    self.checkIfUserIsEntitledToVideo(button: button, gridObject: gridObject)
                }
            }
        }
    }
    
    
    func displayLoginViewWithCompletionHandler(button:SFButton?, gridObject:SFGridObject, completionHandler: @escaping ((_ isSuccessfullyLoggedIn: Bool) -> Void)) -> Void {
        
        let loginViewController: LoginViewController = LoginViewController.init()
        loginViewController.loginPageSelection = 0
        loginViewController.pageScreenName = "Sign In Screen"
        loginViewController.loginType = loginPageType.authentication
        loginViewController.completionHandlerCopy = completionHandler
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: loginViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
    //MARK: method to play video
    func playVideo(gridObject:SFGridObject?) {
        
        if gridObject != nil {
            
             let eventId = gridObject?.eventId
             if eventId != nil && Constants.kAPPDELEGATE.isKisweEnable{
                
                Utility.presentKiswePlayer(forEventId: eventId!, withFilmId: gridObject?.contentId ?? "",vc: self)
            }
            else {
                
                if CastPopOverView.shared.isConnected() {
                    
                    if  Utility.sharedUtility.checkIfMoviePlayable() == true || gridObject?.isFreeVideo == true {
                        
                        CastController().playSelectedItemRemotely(contentId: gridObject?.contentId ?? "", isDownloaded:  false, relatedContentIds: nil, contentTitle: gridObject?.contentTitle ?? "")
                    }
                    else {
                        
                        Utility.sharedUtility.showAlertForUnsubscribeUser()
                    }
                }
                else {
                    
                    let videoObject: VideoObject = VideoObject()
                    videoObject.videoTitle = gridObject?.contentTitle ?? ""
                    videoObject.videoPlayerDuration = gridObject?.totalTime ?? 0
                    videoObject.videoContentId = gridObject?.contentId ?? ""
                    videoObject.gridPermalink = gridObject?.gridPermaLink ?? ""
                    videoObject.videoWatchedTime = gridObject?.watchedTime ?? 0
                    
                    let playerViewController: CustomVideoController = CustomVideoController.init(videoObject: videoObject, videoPlayerType: .streamVideoPlayer, videoFitType: .fullScreen)
                    self.present(playerViewController, animated: true, completion: nil)
                }
            }
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
    func removeVideoFromQueue(contentId:String, cellRowValue:Int) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshRemoveFromWatchlist
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, contentId: nil, cellRowValue: nil, errorMessage: nil, errorTitle: nil)
        }
        else {
            
            var indexOfItemToBeDeleted:Int?
            
            for (index, item) in self.apiModuleListArray.enumerated() {
                
                if item is SFGridObject {
                    
                    let itemToBeDeleted:SFGridObject = item as! SFGridObject
                    
                    if itemToBeDeleted.contentId == contentId {
                        
                        indexOfItemToBeDeleted = index
                        break
                    }
                }
            }
            
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/user/queues?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&userId=\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")&contentIds=\(contentId)"
            showActivityIndicator(loaderText: nil)
            
            DataManger.sharedInstance.removeVideosFromQueue(apiEndPoint: apiEndPoint) { (isVideoRemoved) in
                
                self.hideActivityIndicator()
                
                if isVideoRemoved {
                    
                    if indexOfItemToBeDeleted != nil {
                        
                        self.apiModuleListArray.remove(at: indexOfItemToBeDeleted!)
                        self.tableView?.deleteRows(at: [IndexPath(row: indexOfItemToBeDeleted!, section: 0)], with: .fade)
                        self.tableView?.reloadData()
                    }
                    if self.apiModuleListArray.count == 0 {
                        
                        self.updateViewForEmptyArray()
                    }
                }
                else {
                    
                    self.failureAlertType = .RefreshRemoveFromWatchlist
                    self.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, contentId: contentId, cellRowValue: indexOfItemToBeDeleted, errorMessage: "Unable to remove video from watchlist.", errorTitle: "Watchlist")
                }
            }
        }
    }
    
    
    //MARK: Removing single video from history
    func removeVideoFromHistory(contentId:String, cellRowValue:Int) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshRemoveFromWatchlist
            showWatchlistAlertForAlertType(alertType: .AlertTypeNoInternetFound, contentId: nil, cellRowValue: nil, errorMessage: nil, errorTitle: nil)
        }
        else {
            
            var indexOfItemToBeDeleted:Int?
            
            for (index, item) in self.apiModuleListArray.enumerated() {
                
                if item is SFGridObject {
                    
                    let itemToBeDeleted:SFGridObject = item as! SFGridObject
                    
                    if itemToBeDeleted.contentId == contentId {
                        
                        indexOfItemToBeDeleted = index
                        break
                    }
                }
            }
            
            let apiEndPoint:String = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/video/history/user/\(Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "")?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&videoIds=\(contentId)"
            showActivityIndicator(loaderText: nil)
            
            DataManger.sharedInstance.removeVideosFromQueue(apiEndPoint: apiEndPoint) { (isVideoRemoved) in
                
                self.hideActivityIndicator()
                
                if isVideoRemoved {
                    
                    if indexOfItemToBeDeleted != nil {
                        
                        self.apiModuleListArray.remove(at: indexOfItemToBeDeleted!)
                        self.tableView?.deleteRows(at: [IndexPath(row: indexOfItemToBeDeleted!, section: 0)], with: .fade)
                        self.tableView?.reloadData()
                    }
                    
                    if self.apiModuleListArray.count == 0 {
                        
                        self.updateViewForEmptyArray()
                    }
                }
                else {
                    
                    self.failureAlertType = .RefreshRemoveFromHistory
                    self.showWatchlistAlertForAlertType(alertType: .AlertTypeNoResponseReceived, contentId: contentId, cellRowValue: indexOfItemToBeDeleted, errorMessage: "Unable to remove video from history.", errorTitle: "Delete History")
                }
            }
        }
    }
    
    
    //MARK: Update view if array is empty
    func updateViewForEmptyArray() {
        
        self.tableView?.isHidden = true        
        hideUnHideNoResultArrayLabel(isHidden: false)
        self.createSubscriptionHeader(updateBottomFrame: true)
    }
    
    
    func hideUnHideNoResultArrayLabel(isHidden:Bool) {
        
        for subView in self.view.subviews {
            
            if subView is SFLabel {
                
                let label:SFLabel = subView as! SFLabel
                
                if label.labelObject?.key == "historyLabel" {
                    
                   label.isHidden = isHidden
                }
                else if label.labelObject?.key == "watchlistLabel" {
                    
                    label.isHidden = isHidden
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
    
    
    //MARK: - Handle View Frames
    override func viewDidLayoutSubviews() {
        
        relativeViewFrame?.size = UIScreen.main.bounds.size
        relativeViewFrame?.size.height -= Utility.sharedUtility.getPosition(position: 20)
        
//        if (self.miniMediaControlsViewController != nil){
//            if self.miniMediaControlsViewController.active && CastPopOverView.shared.isConnected(){
//                relativeViewFrame?.size.height -= 64
//             }
//        }

        // MSEIOS-1424 - Fixes bottom padding in the scroll view while Google cast in on
        if (self.miniMediaControlsViewController != nil){
            if self.miniMediaControlsViewController.active && CastPopOverView.shared.isConnected(){
                for subView in self.view.subviews {
                    if subView is SFTextView {
                        let subviewTextView = subView as! SFTextView
                        let mediaControllerHeight = CGFloat(self.miniMediaControlsViewController.view.frame.height)
                        subviewTextView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: mediaControllerHeight, right: 0.0)
                    }
                }
            }
            
        }
        updateControlBarsVisibility()

//        updateViewComponents()
    }
    
    
    //MARK: - Update View Components
    func updateViewComponents() {
        
        if trayObject != nil {
            
            for subView in self.view.subviews {
                
                if subView is SFLabel {
                    
                    updateLabelView(label: subView as! SFLabel)
                }
                else if subView is SFTextView {
                    
                    updateTextView(textView: subView as! SFTextView)
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
        else if userAccountObject != nil
        {
            for subView in self.view.subviews {
                
                if subView is SFLabel {
                    
                    updateLabelView(label: subView as! SFLabel)
                }
                else if subView is SFTextView {
                    
                    updateTextView(textView: subView as! SFTextView)
                }
                else if subView is SFSeparatorView {
                    
                    updateSeparatorView(separatorView: subView as! SFSeparatorView)
                }
                else if subView is SFButton {
                    
                    updateButtonView(button: subView as! SFButton)
                }
                else if subView is UITableView {
                    
                    userAccountTableView?.changeFrameWidth(width: UIScreen.main.bounds.width)
                    userAccountTableView?.changeFrameHeight(height: (relativeViewFrame?.size.height)! - (userAccountTableView?.frame.origin.y)!)
                }
            }
            
            if self.userAccountTableView == nil && self.tableHeaderView != nil {
                
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
                        
                        if subView is SFButton {
                            let button:SFButton = subView as! SFButton
                            if button.buttonObject?.key != "removeAll" {
                                
                                subView.changeFrameHeight(height: subView.frame.size.height - (tableHeaderView?.frame.size.height)!)
                                subView.changeFrameYAxis(yAxis: subView.frame.origin.y + (tableHeaderView?.frame.size.height)!)
                            }
                        }
                        else {
                            subView.changeFrameHeight(height: subView.frame.size.height - (tableHeaderView?.frame.size.height)!)
                            subView.changeFrameYAxis(yAxis: subView.frame.origin.y + (tableHeaderView?.frame.size.height)!)
                        }
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
        
        if label.labelObject?.key != "watchlistLabel" {
            
            label.changeFrameHeight(height: label.frame.height * Utility.getBaseScreenHeightMultiplier())
            
            if labelLayout.height != nil {
                
                label.changeFrameYAxis(yAxis: label.frame.origin.y - (label.frame.size.height - CGFloat(labelLayout.height!)))
            }
        }
    }
    
    //method to update separator view frames
    func updateSeparatorView(separatorView:SFSeparatorView) {
        
        separatorView.relativeViewFrame = relativeViewFrame!
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorView.separtorViewObject!))
        separatorView.changeFrameYAxis(yAxis: separatorView.frame.minY + Utility.sharedUtility.getPosition(position: 20))
        
        self.minBannerYAxis = separatorView.frame.size.height + separatorView.frame.origin.y
    }
    
    
    //method to update textview frames
    func updateTextView(textView:SFTextView) {
        
        let textViewLayout = Utility.fetchTextViewLayoutDetails(textViewObject: textView.textViewObject!)
        
        textView.relativeViewFrame = relativeViewFrame!
        textView.initialiseTextViewFrameFromLayout(textViewLayout: textViewLayout)
        textView.changeFrameYAxis(yAxis: textView.frame.minY + Utility.sharedUtility.getPosition(position: 20))
        textView.changeFrameHeight(height: UIScreen.main.bounds.size.height - textView.frame.minY)
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

    
    //MARK: method to update user account view frames
    func updateUserAccountView(userAccountView:UserAccount) {
        
        userAccountView.relativeViewFrame = relativeViewFrame!
        
        let userAccountLayout = Utility.fetchUserAccountViewLayoutDetails(userAccountViewObject: userAccountView.userAccountViewObject!)
        userAccountView.userAccountViewLayout = userAccountLayout
        userAccountView.initialiseUserAccountViewFrameFromLayout(userAccountViewLayout: userAccountLayout)
        userAccountView.changeFrameYAxis(yAxis: (userAccountView.frame.minY) + Utility.sharedUtility.getPosition(position: 20))
        userAccountView.changeFrameHeight(height: userAccountView.frame.height * Utility.getBaseScreenHeightMultiplier())
        userAccountView.updateView()
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
                
                if self.failureAlertType == .RefreshPageContent {
                    
                    self.fetchPageContent()
                }
                else if self.failureAlertType == .RefreshQueueContent {
                    
                    self.showActivityIndicator(loaderText:"Loading...")
                    self.fetchQueueContent()
                }
                else if self.failureAlertType == .RefreshHistoryContent {
                    
                    self.showActivityIndicator(loaderText:"Loading...")
                    self.fetchHistoryContent()
                }
                else if self.failureAlertType == .RefreshAccountSettings {
                    
                    self.showActivityIndicator(loaderText: "Loading...")
                    self.fetchUserDetailModuleContent()
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
                else if self.failureAlertType == .RefreshRemoveFromHistory {
                    
                    self.removeVideoFromHistory(contentId: contentId!, cellRowValue: cellRowValue!)
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

    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "dismissDownloaQualityView"), object: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func buttonTapped(sender: SFButton) -> Void
    {
        if sender.buttonObject?.action == "changeDownloadQuality"
        {
            let downloadQualityViewController = DownloadQualityViewController()
            downloadQualityViewController.film = nil
            let navEditorViewController: UINavigationController = UINavigationController(rootViewController: downloadQualityViewController)
            navEditorViewController.modalPresentationStyle = .overFullScreen
            UIApplication.shared.keyWindow?.rootViewController?.present(navEditorViewController, animated: true, completion: nil)
            navEditorViewController.present()
        }
        else if sender.buttonObject?.action == "manageSubscription"
        {
            if self.userDetails?.isSubscribed != nil
            {
                if (self.userDetails?.isSubscribed)!
                {
                    if self.userDetails?.paymentProcessor?.lowercased() == "ios" || self.userDetails?.paymentProcessor?.lowercased() == "ios_phone" || self.userDetails?.paymentProcessor?.lowercased() == "ios_ipad" || self.userDetails?.paymentProcessor?.lowercased() == "ios_apple_tv" || self.userDetails?.paymentProcessor?.lowercased() == "ios_apple_watch" || self.userDetails?.paymentProcessor?.lowercased() == "ios_iphone"
                    {
                        UIApplication.shared.openURL(NSURL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")! as URL)
                    }
                    else
                    {
                        // Show Alert
                        showManageSubscriptionAlertWith(subscriptionPlatform: self.userDetails?.paymentProcessor ?? "")
                    }
                }
                else
                {
                    displayPlanPage()
                }
            }
            else
            {
                displayPlanPage()
            }
        }
        else
        {
            if Utility.sharedUtility.checkIfUserIsSubscribedGuest() && AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
                
                let okAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (okAction) in
                    
                })
                
                let userAccountErrorAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: pageAPIObject?.pageTitle ?? "", alertMessage: "Please create your login to access this feature.", alertActions: [okAction])
                self.present(userAccountErrorAlert, animated: true, completion: nil)
            }
            else {
                
                let settingsDetailViewController: SettingsDetailViewController = SettingsDetailViewController()
                settingsDetailViewController.action = sender.buttonObject?.action
                settingsDetailViewController.navigationTitle = sender.buttonObject?.key
                
                let navController: UINavigationController = UINavigationController.init(rootViewController: settingsDetailViewController)
                self.present(navController, animated: false, completion: {
                    
                })
            }
        }
    }
    
    
    func displayPlanPage() -> Void {
        
        displayPlanPageWithCompletionHandler() { (isSuccessfullyLoggedIn) in
            
            if isSuccessfullyLoggedIn {
                
                if self.tableView == nil && self.userAccountTableView == nil {
                    
                    if self.tableHeaderView != nil {
                        
                        self.tableHeaderView = nil
                        self.tableHeaderView?.removeFromSuperview()
                        self.updateViewComponents()
                    }
                }
                else {
                 
                    if self.checkIfModuleExistInPageAPIObject(moduleName: "QueueModule") {
                        
                        if self.tableHeaderView != nil {
                            
                            self.tableView?.reloadData()
                        }
                    }
                    else if self.checkIfModuleExistInPageAPIObject(moduleName: "HistoryModule") {
                        
                        if self.tableHeaderView != nil {
                            
                            self.tableView?.reloadData()
                        }
                    }
                    else if self.checkIfModuleExistInPageAPIObject(moduleName: "UserManagementModule") {
                        
                        self.fetchSubscritionDetails()
                    }
                }
            }
        }
    }
    
    
    func displayPlanPageWithCompletionHandler(completionHandler: @escaping ((_ isSuccessfullyLoggedIn: Bool) -> Void)) -> Void {
        
        let planViewController:SFProductListViewController = SFProductListViewController.init()
        planViewController.shouldUserBeNavigatedToHomePage = false
        planViewController.completionHandlerCopy = completionHandler
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: planViewController)
        self.present(navigationController, animated: true, completion: {
            
        })
    }
    
    
    func fetchSubscritionDetails() {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            failureAlertType = .RefreshSubscriptionDetails
            self.showAlertForAlertType(alertType: .AlertTypeNoInternetFound)
        }
        else {
            showActivityIndicator(loaderText: "Loading...")
            
            DispatchQueue.global(qos: .userInitiated).async {
             
                DataManger.sharedInstance.apiToGetUserSubscriptionStatus(success: { (userSubscriptionStatus, isSuccess) in
                    
                    DispatchQueue.main.async {
                        
                        self.hideActivityIndicator()
                        if userSubscriptionStatus != nil {
                            
                            if isSuccess {
                                
                                if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) != nil
                                {
                                    if (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as! Bool) {
                                        
                                        let paymentPlatform:String? = userSubscriptionStatus?["platform"] as? String ?? ""
                                        let planId:String? = userSubscriptionStatus?["name"] as? String ?? ""
                                        let planProductId:String? = userSubscriptionStatus?["planProductId"] as? String
                                        
                                        self.userDetails?.paymentProcessor = paymentPlatform
                                        self.userDetails?.subscriptionPlan = planId
                                        self.userDetails?.isSubscribed = true
                                        self.userDetails?.paymentMethod =  userSubscriptionStatus?["paymentHandlerDisplayName"] as? String ?? ""
                                        
                                        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                            
                                            Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                                            
                                            if planProductId != nil {
                                                Utility.sharedUtility.setGTMUserProperty(userPropertyValue: planProductId!, userPropertyKeyName: Constants.kGTMCurrentSubscriptionIDProperty)
                                            }
                                            
                                            if planId != nil {
                                                
                                                if !(planId?.isEmpty)! {
                                                    
                                                    Utility.sharedUtility.setGTMUserProperty(userPropertyValue: planId!, userPropertyKeyName: Constants.kGTMCurrentSubscriptionNameProperty)
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        
                                        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                            
                                            Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                                        }
                                        
                                        self.userDetails?.subscriptionPlan = "Not Subscribed"
                                    }
                                }
                                else {
                                    
                                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                        
                                        Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                                    }
                                    
                                    self.userDetails?.subscriptionPlan = "Not Subscribed"
                                }
                                
                                self.userAccountTableView?.reloadData()
                            }
                        }
                        else
                        {
                            
                            let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default, handler: { (cancelAction) in
                                
                                //else for subscription has no response data
                                if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                    
                                    Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                                }
                                
                                self.userDetails?.subscriptionPlan = "Not Subscribed"
                                self.userAccountTableView?.reloadData()
                            })
                            
                            let retryAction = UIAlertAction(title: Constants.kStrRetry, style: .default, handler: { (re) in
                                
                                self.fetchSubscritionDetails()
                            })
                            
                            let errorAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kStrRetry, alertMessage: "Unable to fetch updated subscription details. Please try again later.", alertActions: [cancelAction, retryAction])
                            
                            self.present(errorAlert, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    
    func showManageSubscriptionAlertWith(subscriptionPlatform: String) -> Void
    {
        let okAction: UIAlertAction = UIAlertAction.init(title: Constants.kStrOk, style: .default) { (UIAlertAction) in
            
        }
        
        var msgString: String = "different platform/device"
        let alertTitleString: String = Constants.kManageSubscription
        if (subscriptionPlatform.lowercased() == "web_browser")
        {
            msgString = "Web"
        }
        else if (subscriptionPlatform.lowercased() == "android_phone") || (subscriptionPlatform.lowercased() == "android_tablet") || (subscriptionPlatform.lowercased() == "android_wear") || (subscriptionPlatform.lowercased() == "android_tv")
        {
            msgString = "Google Play"
        }
        else if (subscriptionPlatform.lowercased() == "amazon_fire") || (subscriptionPlatform.lowercased() == "amazon_tv") || (subscriptionPlatform.lowercased() == "amazon_stick")
        {
            msgString = "Amazon"
        }
        else if (subscriptionPlatform.lowercased() == "roku_box") || (subscriptionPlatform.lowercased() == "roku_stick")
        {
            msgString = "Roku"
        }
        else if (subscriptionPlatform.lowercased() == "windows_phone") || (subscriptionPlatform.lowercased() == "windows_tablet") || (subscriptionPlatform.lowercased() == "windows_xbox")
        {
            msgString = "Window Device"
        }
        else if (subscriptionPlatform.lowercased() == "sony_playstation4") || (subscriptionPlatform.lowercased() == "sony_playstation_vita") || (subscriptionPlatform.lowercased() == "sony_playstation_tv")
        {
            msgString = "PS4"
        }
        else if (subscriptionPlatform.lowercased() == "smart_tv_lg")
        {
            msgString = "Google Play"
        }
        else if (subscriptionPlatform.lowercased() == "smart_tv_samsung")
        {
            msgString = "Google Play"
        }
        else if (subscriptionPlatform.lowercased() == "smart_tv_sony")
        {
            msgString = "Google Play"
        }
        else if (subscriptionPlatform.lowercased() == "smart_tv_panasonic")
        {
            msgString = "Google Play"
        }
        else if (subscriptionPlatform.lowercased() == "smart_tv_opera_tv")
        {
            msgString = "Google Play"
        }
        
        let alertController: UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString, alertMessage: "This is \(getCorrectArticleTPrecedeTheWordFor(wordThatFollows: msgString)) \(msgString) subscription. Management is possible with the device used for purchase.", alertActions: [okAction])
        self.present(alertController, animated: true) { 
            
        }
    }
    
    func getCorrectArticleTPrecedeTheWordFor(wordThatFollows: String) -> String
    {
        var stringToReturn: String = "a"
        if wordThatFollows.characters.count > 0
        {
            let index = wordThatFollows.index(wordThatFollows.startIndex, offsetBy: 1)
            var firstLetter: String = wordThatFollows.substring(to: index)
            firstLetter = firstLetter.lowercased()
            let vowels: Array = ["a", "e", "i", "o", "u"]
            if vowels.contains(firstLetter)
            {
             stringToReturn = "an"
            }
        }
        return stringToReturn
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
        Utility.presentMorePopUpView(moreOptionArray: moreOptionArray, contentId: contentId, contentType: nil, isModel: self.isModal, delegate: self, isOptionForBannerView: isOptionForBannerView);
    }
    
    
    //MARK: More popover controller delegate
    func removePopOverViewController(viewController: UIViewController) {
        self.view.isUserInteractionEnabled = true
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
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
                relativeViewFrame?.size.height -= 84
                
                updateViewComponents()
                _miniMediaControlsContainerView.changeFrameHeight(height: 64)
                self.view.bringSubview(toFront: _miniMediaControlsContainerView)
            } else {
                relativeViewFrame?.size = UIScreen.main.bounds.size
                relativeViewFrame?.size.height -= 20
                
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
