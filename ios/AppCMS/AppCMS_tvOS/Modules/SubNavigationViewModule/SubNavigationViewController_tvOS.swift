//
//  SubNavigationViewController_tvOS.swift
//  AppCMS
//
//  Created by Rajni Pathak on 07/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//


import UIKit

private var cellHeight : CGFloat =  160.0
private let  MenuTitleTag = 102
private let  cellMaxWidth : CGFloat =  180.0


protocol SubNavigationViewControllerDelegate: class {
    func menuSelected(menuSelectedAtIndex: Int)
    func logoutButtonTapped()
}
class SubNavigationViewController_tvOS: BaseViewController ,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    //MARK: - Delegate property
    //Create  delegate property of MenuViewControllerDelegate.
    weak var delegate:SubNavigationViewControllerDelegate?
    private let padding : CGFloat =  80.0
    private var userDetails: SFUserDetails?
    private let reuseIdentifier = "cell"
    //Property menuCollectionView renders collection of menu.
    var  menuCollectionView :   UICollectionView?
    
    //Property menuArray holds collection of menu.
    var  menuArray : Array<SubNavTuple>
    
    //MARK: - Private properties
    //Property collectionViewWidth property holds width of Collection View .
    private  var collectionViewWidth : Float = 0
    
    //Property focusedMenuTitleFont holds font NAME when cell is in focused state.
    private   var focusedMenuTitleFont  : String
    
    //Property focusedMenuTitleFontSize holds font SIZE when cell is in focused state.
    private  var focusedMenuTitleFontSize  : CGFloat

    
    private var menuCreated : Bool = false
    //Property used for storing last focus Item.
    //private var  lastFocusedMenuIndex : IndexPath?
    private var  lastFocusedMenuIndexPath = IndexPath(row: 0, section: 0)
    private var collectionGridObject:SFCollectionGridObject?
    
    private var pageDisplayName: String?
    
//    override var preferredFocusedView : UIView? {
//        return (self.menuCollectionView)!
//    }
    
    func refreshMenu(menuArray: Array<SubNavTuple>) {
        self.menuArray = menuArray
        menuCollectionView?.reloadData()
        //Calculate the collection View Width
        collectionViewWidth =  self.calculateWidthOfCollectionView()
        //Get screen view width
        let screenWidth : Float = Float(self.view.frame.size.width)
        //If collection view width is more than screen size width then set
        //width of collection view as screen width
        if( collectionViewWidth  >  screenWidth) {
            collectionViewWidth = screenWidth
        }
        menuCollectionView?.changeFrameWidth(width: CGFloat(collectionViewWidth))
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let viewToBeFocused = self.menuCollectionView {
            return [viewToBeFocused]
        } else {
            return super.preferredFocusEnvironments
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, teamViewObject: SFSubNavigationViewObject, menuArray: Array<SubNavTuple>, pageDisplayName: String) {
        self.pageDisplayName = pageDisplayName
        self.menuArray = menuArray
        var fontFamily:String?
        if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
            fontFamily = _fontFamily
        }
        if fontFamily == nil {
            fontFamily = "OpenSans"
        }
        self.focusedMenuTitleFont = fontFamily!
        self.focusedMenuTitleFontSize = 22
        super.init(nibName: nil, bundle: nil)
        self.view.frame = frame
        if teamViewObject.layoutObjectDict.isEmpty == false {
            self.createModules(teamViewObject: teamViewObject)
        }
        
    }

    //MARK: -  deinit Method
    //deinit Method is called when
    deinit {
        print("Menu Collection view is going to be deinitialise  ")
        NotificationCenter.default.removeObserver(self, name: Constants.kToggleMenuBarNotification, object: nil)
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(setNeedsFocusUpdate), name: Constants.kToggleMenuBarNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.fetchPageModuleList()
    }

    /// Method to create modules for the page.
    private func createModules(teamViewObject : SFSubNavigationViewObject) {
        for component:AnyObject in (teamViewObject.components) {
            if component is SFCollectionGridObject {
                collectionGridObject = component as? SFCollectionGridObject
                createMenuCollectionView()
            }
            if component is SFLabelObject {
                createLabelView(labelObject: component as! SFLabelObject)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Creation of Grid View
    private func createMenuCollectionView() {
        let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
        createCollectionView(collectionGridLayout: collectionGridLayout)
    }
    
    private func createLabelView(labelObject: SFLabelObject){
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = self.view.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        if labelObject.key == "pageTitle" && pageDisplayName?.isEmpty == false {
            label.text = pageDisplayName
        } else {
            label.text = labelObject.text
        }
        label.createLabelView()
        label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff")
        self.view.addSubview(label)
    }
  
    func createCollectionView(collectionGridLayout:LayoutObject) {
        cellHeight = CGFloat(collectionGridLayout.gridHeight ?? 160)
        // Handling multiple menu creation issue.
        if menuCreated == true {
            return
        }
        //Calculate the collection View Width
        collectionViewWidth =  self.calculateWidthOfCollectionView()
        //Get screen view width
        let screenWidth : Float = Float(self.view.frame.size.width)
        
        //If collection view width is more than screen size width then set
        //width of collection view as screen width
        if( collectionViewWidth  >  screenWidth)
        {
            collectionViewWidth = screenWidth
        }
        let backgroundFocusGuide : UIFocusGuide = UIFocusGuide()
        self.view.addLayoutGuide(backgroundFocusGuide)
        backgroundFocusGuide.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundFocusGuide.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundFocusGuide.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundFocusGuide.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        //Create UICollectionViewFlowLayout layout instance.
        let collectionViewFlowLayout:SFCollectionGridFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!), height: CGFloat(collectionGridLayout.gridHeight!)), isHorizontalScroll: true, gridPadding: collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 0.0)
        
        //Create UICollection View.
        menuCollectionView = UICollectionView(frame: Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: self.view.frame), collectionViewLayout: collectionViewFlowLayout)
        menuCollectionView?.changeFrameWidth(width: CGFloat(collectionViewWidth))
        menuCollectionView?.register(SubNavCollectionCell_tvOS.self, forCellWithReuseIdentifier: reuseIdentifier)
        menuCollectionView?.delegate = self
        menuCollectionView?.dataSource = self
        menuCollectionView?.backgroundColor = UIColor.clear
        if #available(tvOS 11.0, *) {
            self.menuCollectionView?.contentInsetAdjustmentBehavior = .never
        }
        menuCollectionView?.showsVerticalScrollIndicator = false
        menuCollectionView?.showsHorizontalScrollIndicator = false
        menuCollectionView?.isScrollEnabled = true
        menuCollectionView?.center = self.view.center
        backgroundFocusGuide.preferredFocusedView = menuCollectionView
        //Add UICollectionView as sub view.
        if menuCollectionView != nil {
            self.view.addSubview(menuCollectionView!)
            menuCreated = true
        }
        
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menuArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let menuCell:SubNavCollectionCell_tvOS = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SubNavCollectionCell_tvOS
        menuCell.tag = indexPath.row
        menuCell.cellComponents = (collectionGridObject?.trayComponents)!
        
        if menuArray[indexPath.row].pageAction == .subNavActionToggle{
            if menuArray[indexPath.row].pageName == Constants.kAutoplayOn || menuArray[indexPath.row].pageName == Constants.kAutoplayOff{
                if let autoPlay = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) as? Bool {
                    if autoPlay{
                        menuCell.menuTitle = Constants.kAutoplayOn
                    }
                    else{
                        menuCell.menuTitle = Constants.kAutoplayOff
                    }
                } else {
                    menuCell.menuTitle = Constants.kAutoplayOff
                }
                
            } else if menuArray[indexPath.row].pageName == Constants.kClosedCaptionOn || menuArray[indexPath.row].pageName == Constants.kClosedCaptionOff {
                if let ccEnabled = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsCCEnabled) as? Bool {
                    if ccEnabled{
                        menuCell.menuTitle = Constants.kClosedCaptionOn
                    }
                    else{
                        menuCell.menuTitle = Constants.kClosedCaptionOff
                    }
                    
                } else {
                    menuCell.menuTitle = Constants.kClosedCaptionOff
                }
            } else {
                menuCell.menuTitle = menuArray[indexPath.row].pageName
            }
        }
        else{
            menuCell.menuTitle = menuArray[indexPath.row].pageName
        }
        menuCell.menuIcon = menuArray[indexPath.row].pageIcon
        menuCell.updateCellView()
        return menuCell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if let previousCell = context.previouslyFocusedView as? SubNavCollectionCell_tvOS {
            let view = previousCell.viewWithTag(MenuTitleTag) as? SFImageView
            view?.backgroundColor = UIColor.clear
            let tag = previousCell.tag
            let imgString = menuArray[tag].pageIcon
            if imgString.lowercased().range(of:"http") == nil {
                if let textColor = AppConfiguration.sharedAppConfiguration.secondaryButton.textColor {
                    view?.tintColor = Utility.hexStringToUIColor(hex: textColor)
                    view?.layer.borderColor = Utility.hexStringToUIColor(hex: textColor).cgColor
                    
                }
            }
            
        }
        
        if let nextCell = context.nextFocusedView as? SubNavCollectionCell_tvOS {
            let view = nextCell.viewWithTag(MenuTitleTag) as? SFImageView
            view?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.backgroundColor ?? "#000000")
            let tag = nextCell.tag
            let imgString = menuArray[tag].pageIcon
            if imgString.lowercased().range(of:"http") == nil {
                if let textColor = AppConfiguration.sharedAppConfiguration.primaryButton.textColor {
                    view?.tintColor = Utility.hexStringToUIColor(hex: textColor)
                    view?.layer.borderColor = Utility.hexStringToUIColor(hex: textColor).cgColor
                    
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        lastFocusedMenuIndexPath = indexPath
        //Item selected at Index path
        self.menuSelected(menuSelectedAtIndex: indexPath.row)
    }
    
    func menuSelected(menuSelectedAtIndex: Int){
        if menuArray[menuSelectedAtIndex].pageAction == .subNavActionToggle{
            if menuArray[menuSelectedAtIndex].pageName == Constants.kAutoplayOn || menuArray[menuSelectedAtIndex].pageName == Constants.kAutoplayOff{
                
                if let autoPlay = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kAutoPlay) as? Bool {
                    if autoPlay{
                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kAutoPlay)
                    }
                    else{
                        Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kAutoPlay)
                    }
                } else {
                    Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kAutoPlay)
                }
            }
            if menuArray[menuSelectedAtIndex].pageName == Constants.kClosedCaptionOn || menuArray[menuSelectedAtIndex].pageName == Constants.kClosedCaptionOff {
                if let ccEnabled = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsCCEnabled) as? Bool {
                    if ccEnabled{
                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsCCEnabled)

                    }
                    else{
                        Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsCCEnabled)
                    }
                    
                } else {
                    Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsCCEnabled)
                }
            }
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
            menuCollectionView?.reloadItems(at: [IndexPath(row: menuSelectedAtIndex, section: 0)])
        }
        //Item selected at Index path is SIGN IN.
        else if menuArray[menuSelectedAtIndex].pageAction == .subNavActionDisplay{
            let menuSelected = menuArray[menuSelectedAtIndex]
            if menuSelected.pageName.uppercased() == "SIGN IN" {
                Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView()
            } else {
                delegate?.menuSelected(menuSelectedAtIndex: menuSelectedAtIndex)
            }
        }
        else if menuArray[menuSelectedAtIndex].pageAction == .subNavActionSubscribeNow {
            Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView(contentToLoad: .loadPlansPage)
        }
        else if menuArray[menuSelectedAtIndex].pageAction == .subNavActionSignUp{
            Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView(contentToLoad: .loadSignUpPage)
        }
        else if menuArray[menuSelectedAtIndex].pageAction == .subNavActionAccount {
//            checkForLoggedInStateAndShowAccount()
            delegate?.menuSelected(menuSelectedAtIndex: menuSelectedAtIndex)
        }
        else if menuArray[menuSelectedAtIndex].pageAction == .subNavActionAlert{
               fetchSubscriptionDetails()
        }
        else if menuArray[menuSelectedAtIndex].pageAction == .subNavActionSignOut{
                delegate?.logoutButtonTapped()
        }
    }
    
//    private func checkForLoggedInStateAndShowAccount() {
//        if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
//            let accountPage = SFAccountInfoModuleSports_tvOS(nibName: "SFAccountInfoModuleSports_tvOS", bundle: nil)
//            self.present(accountPage, animated: true, completion: nil)
//        } else {
//            let alertController: UIAlertController?
//            let alertTitleString: String = "SIGN IN"
//            let signInAction:UIAlertAction = UIAlertAction(title: Constants.kStrSign, style: .default) { (signInAction) in
//
//                Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView({ [weak self] () in
//                    guard let _ = self else {
//                        return
//                    }
//                })
//            }
//
//            let cancelAction:UIAlertAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in}
//            let msgString: String = "Please sign in to view account."
//            alertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString, alertMessage: msgString, alertActions: [cancelAction, signInAction])
//            self.present(alertController!, animated: true)
//        }
//    }
    
    private func fetchSubscriptionDetails() {
        self.showActivityIndicator()
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) != nil {
            DataManger.sharedInstance.apiToGetUserSubscriptionStatus(success: { [weak self] (userSubscriptionStatus, isSuccess) in
                
                guard let checkedSelf = self else {
                    return
                }
                checkedSelf.hideActivityIndicator()
                
                if checkedSelf.userDetails == nil {
                    checkedSelf.userDetails = SFUserDetails()
                }
                
                if userSubscriptionStatus != nil {
                    
                    if isSuccess {
                        
                        let paymentPlatform:String? = userSubscriptionStatus?["platform"] as? String ?? ""
                        let planId:String? = userSubscriptionStatus?["name"] as? String ?? "-"
                        checkedSelf.userDetails?.paymentProcessor = paymentPlatform
                        checkedSelf.userDetails?.subscriptionPlan = planId
                        checkedSelf.userDetails?.isSubscribed = true
                        checkedSelf.userDetails?.paymentMethod =  userSubscriptionStatus?["paymentHandlerDisplayName"] as? String ?? ""
                        checkedSelf.showManageSubscriptionAlertWith(subscriptionPlatform: (checkedSelf.userDetails?.paymentProcessor)!)
                    }
                    else {
                        checkedSelf.showNotLoggedInAlert()
                    }
                }
                else {
                    checkedSelf.showNotLoggedInAlert()
                }
            })
        } else {
            showNotLoggedInAlert()
        }
    }
    
    private func showNotLoggedInAlert() {
        let alertController: UIAlertController?
        let alertTitleString: String = Constants.kManageSubscription
        let okAction: UIAlertAction = UIAlertAction.init(title: Constants.kStrOk, style: .default) { (UIAlertAction) in /*Do nothing*/}
        let msgString: String = "You are currently not a subscriber, please subscribe."
        alertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString, alertMessage: msgString, alertActions: [okAction])
        self.present(alertController!, animated: true)
    }
    
    func showManageSubscriptionAlertWith(subscriptionPlatform: String) -> Void
    {
        let alertTitleString: String = Constants.kManageSubscription
        let alertController: UIAlertController?
        let okAction: UIAlertAction = UIAlertAction.init(title: Constants.kStrOk, style: .default) { (UIAlertAction) in /*Do nothing*/}
        
        if subscriptionPlatform.lowercased() == "ios" || subscriptionPlatform.lowercased() == "ios_phone" || subscriptionPlatform.lowercased() == "ios_ipad" || subscriptionPlatform.lowercased() == "ios_apple_tv" || subscriptionPlatform.lowercased() == "ios_apple_watch" || subscriptionPlatform.lowercased() == "ios_iphone" {
            alertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString, alertMessage: "In order to Manage your subscriptions you need to go to Settings > Accounts > Manage Subscriptions", alertActions: [okAction])
        }
        else {
            let msgString: String = Utility.getPlatformNameFromPaymentProcessorString(subscriptionPlatform)
            alertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString, alertMessage: "This is \(getCorrectArticleTPrecedeTheWordFor(wordThatFollows: msgString)) \(msgString) subscription. Management is only possible with the device used for purchase.", alertActions: [okAction])
        }
        self.present(alertController!, animated: true)
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
    
    //MARK:- UICollectionViewFlow Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let sizeOfItem =  CGSize(width: cellMaxWidth , height: cellHeight)
        return sizeOfItem
    }
    
    func  indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        return lastFocusedMenuIndexPath as IndexPath
    }
    
    
    func calculateWidthOfCollectionView() -> Float
    {
        var frameWidth : Float = 0
        frameWidth = Float(menuArray.count) * Float(cellMaxWidth)
        return frameWidth
    }
    

    //MARK: - Make User Interaction enable/disable for collectionView
    func toggleUserInteraction(_ value : Bool) -> Void {
        self.view?.isUserInteractionEnabled = value
    }
 
}

//Class to differentiate between different cells on focus.
class SubNavCollectionCell_tvOS : UICollectionViewCell {
    var menuTitleLabel:SFLabel?
    var menuThumbnailImage:SFImageView?
    var cellComponents:Array<Any> = []
    var menuTitle:String?
    var menuIcon:String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //MARK: method to create cell view
    private func createCellView() {
        menuTitleLabel = SFLabel()
        self.addSubview(menuTitleLabel!)
        menuTitleLabel?.isHidden = true
        
        
        menuThumbnailImage = SFImageView()
        self.addSubview(menuThumbnailImage!)
        menuThumbnailImage?.isHidden = true
        menuThumbnailImage?.tag = MenuTitleTag
       
    }
    
    func updateCellView() {
        for cellComponent in cellComponents {
            
            if cellComponent is SFLabelObject {
                
                updateLabelView(labelObject: cellComponent as! SFLabelObject)
            }
            else if cellComponent is SFImageObject {
                
                updateImageView(imageObject: cellComponent as! SFImageObject)
            }
        }
    }
    
    //MARK: Update label view
    private func updateLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        if labelObject.key != nil && labelObject.key == "menuTitle" {
            menuTitleLabel?.isHidden = false
            menuTitleLabel?.relativeViewFrame = self.frame
            menuTitleLabel?.labelObject = labelObject
            menuTitleLabel?.labelLayout = labelLayout
            menuTitleLabel?.text = menuTitle?.uppercased()
            menuTitleLabel?.numberOfLines = 2
            menuTitleLabel?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            menuTitleLabel?.createLabelView()
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                menuTitleLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
    }
    
    //MARK: Update label view
    private func updateImageView(imageObject:SFImageObject) {
        let imageLayout = Utility.fetchImageLayoutDetails(imageObject: imageObject)
        if imageObject.key != nil && imageObject.key == "menuThumbnailImage" {
            menuThumbnailImage?.relativeViewFrame = self.frame
            menuThumbnailImage?.isHidden = false
            menuThumbnailImage?.initialiseImageViewFrameFromLayout(imageLayout: imageLayout)
            menuThumbnailImage?.imageViewObject = imageObject
            menuThumbnailImage?.updateView()
            menuThumbnailImage?.contentMode = .scaleAspectFit
            menuThumbnailImage?.changeFrameXAxis(xAxis: (self.frame.width - (menuThumbnailImage?.frame.width)!)/2)
            menuThumbnailImage?.layer.borderWidth = 1.0
            menuThumbnailImage?.layer.borderColor = UIColor.white.cgColor
            guard let imgString = menuIcon?.lowercased() else{
                    return
            }
            // alternative: not case sensitive
            if imgString.lowercased().range(of:"http") != nil {
                let imgWidth = (menuThumbnailImage?.frame.width)! * 7/10
                let imgOriginX = ((menuThumbnailImage?.frame.width)! - imgWidth) / 2
                
                let imgHeight = (menuThumbnailImage?.frame.height)! * 7/10
                let imgOriginY = ((menuThumbnailImage?.frame.height)! - imgHeight) / 2
                
                
                var imageView : UIImageView
                imageView = UIImageView(frame:CGRect(x: imgOriginX, y: imgOriginY, width: imgWidth, height: imgHeight))
                imageView.contentMode = .scaleAspectFit
                
                menuThumbnailImage?.addSubview(imageView)
                
                var imageURL = imgString
                imageURL = imageURL.trimmingCharacters(in: .whitespaces)
                if imageURL.isEmpty == false {
                    imageView.af_setImage(
                        withURL: URL(string: imageURL)!,
                        placeholderImage: nil,
                        filter: nil,
                        imageTransition: .crossDissolve(0.2)
                    )
                }
                
                
                
            } else{
                menuThumbnailImage?.image = UIImage(named: imgString)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                if let textColor = AppConfiguration.sharedAppConfiguration.secondaryButton.textColor {
                    menuThumbnailImage?.tintColor = Utility.hexStringToUIColor(hex: textColor)
                    menuThumbnailImage?.layer.borderColor = Utility.hexStringToUIColor(hex: textColor).cgColor
                }
            }
        }
    }
}

