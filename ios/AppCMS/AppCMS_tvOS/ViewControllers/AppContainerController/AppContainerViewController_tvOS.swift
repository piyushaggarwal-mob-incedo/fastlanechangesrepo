//
//  AppContainerViewController_tvOS.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 14/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

/// Class which acts the container class for complete AppCMS tvOS application.
class AppContainerViewController_tvOS: UIViewController , MenuViewControllerDelegate {
    
    /// Acts as the center view, that holds all the controllers.
    private var centerViewControllerContainerView : UIView?
    
    /// Stores the menu show/hide state.
    private var centerViewStartingY = 0.0
    
    /// Stores the menu show/hide state.
    var isMenuViewShowing: Bool = false
    
    /// Saves the state when the user navigates from CenterViewController to MenuViewContoller
    private var didTransitionFromMenu: Bool = false
    
    /// Menu Controller instance.
    private var menuController : MenuBaseViewController_tvOS?
    
    /// Holds the current state of Menu.
    private var menuViewShowState = false
    
    /// Holds the current selected item.
    private var currentSelectedIndex : Int = 0
    
    /// Navigation array items. Array of UIViewControllers.
    private var navigationItemsArray : Array<PageTuple>?
    
    /// Associated View Model.
    private let viewModel = AppContainerViewModel_tvOS()
    
    //blurViewAdded bool value is used to track blur view is already displaying on view or not.
    private var isBlurViewAdded : Bool = false
    
    /// Holder object. Holds the object of the current object/view controller being shown.
    private var baseModuleController: UIViewController?
    
    /// property blurView is used for dispalying blurview
    private var blurView : BlurView_tvOS?
    
    /// Reference of completion handler for subContainer dismiss completion. Mark it as nil after callback.
    private var subContainerDismissCompletionHandler: (() -> Void)? = nil
    
    /// Get only property which checks the subContainerDismissCompletionHandler property for nil and responds accordingly.
    public var isSubContainerDisplayedModally: Bool? {
        get {
            if self.subContainerDismissCompletionHandler != nil {
                return true
            } else {
                return false
            }
        }
    }
    private var menuViewHeight: Int {
        get {
            if  TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
                return 1080
            } else  if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment{
                return 140
            }
            else {
                return 1080
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Constants.kToggleMenuBarInteractionNotification, object: nil);
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            centerViewStartingY = 10
        }
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(AppContainerViewController_tvOS.toggleUserInteractionForMenu(_ : )), name: Constants.kToggleMenuBarInteractionNotification, object: nil)
        
        //        let backgroundImage = UIImage(named: "app_background.png")
        //        self.view.backgroundColor =   UIColor(patternImage:backgroundImage!)
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
        createBaseStructureForTheApplication()
    }
    
    
    private func createBaseStructureForTheApplication () {
        
        navigationItemsArray = fetchTheViewControllerArrayForNavigation()
        setupAndAddMenuControllerWithArray(arrayOfnavigationItems: navigationItemsArray!)
        
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            let topBar = UIView(frame: CGRect(x: 0, y: 0, width: (self.view.bounds.size.width), height: 10))
            topBar.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "#000000")
            self.view.addSubview(topBar)
        }
        centerViewControllerContainerView = UIView.init(frame: CGRect(x: 0.0, y: centerViewStartingY, width: (Double(self.view.bounds.size.width)), height: (Double(self.view.bounds.size.height))))
        centerViewControllerContainerView?.backgroundColor = UIColor.clear

        self.view.addSubview(centerViewControllerContainerView!)
        
        //Load initial module.
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            currentSelectedIndex = 1
            updateTheBaseControllerForItemAtIndex(index: currentSelectedIndex)
        } else {
            updateTheBaseControllerForItemAtIndex(index: 0)
        }
    }
    
    private func setupAndAddMenuControllerWithArray (arrayOfnavigationItems: Array<PageTuple>) {
         if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports{
            menuController = MenuSportsViewController_tvOS.init(menuArray: arrayOfnavigationItems as Array<PageTuple>)
        }
        else if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment{
            menuController = MenuViewController_tvOS.init(menuArray: arrayOfnavigationItems as Array<PageTuple>)
        }
        self.addChildViewController(menuController!)
        self.view.addSubview((menuController?.view)!)

        menuController?.view.alpha = 1.0
        menuController?.view.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: menuViewHeight)
        menuController?.fetchPageModuleList()
        menuController?.view.frame = CGRect(x: 0, y: -menuViewHeight, width: Int(self.view.frame.width), height: menuViewHeight)
        menuController?.delegate = self
        menuController?.didMove(toParentViewController: self)
        
    }

    
    private func fetchTheViewControllerArrayForNavigation () -> Array<PageTuple> {
        return viewModel.getAllTheNavigationViewControllers()
    }
    
    private func adjustTheFramesOnMenuFocusAndDefocus (didFocusOnMenu : Bool) {
        toggleMenuState(shouldShow: didFocusOnMenu)
    }
    
    //MARK: UIFocus Methods
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        //TODO: Update this logic.
        if (context.nextFocusedView is SFCollectionGridCell_tvOS) || (context.nextFocusedView is CarouselView) || (context.nextFocusedView is BlurView_tvOS) {
            adjustTheFramesOnMenuFocusAndDefocus(didFocusOnMenu: false)
            
        }
        else{
             if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
                if context.nextFocusedView is MenuSportsCollectionCell_tvOS || (context.nextFocusedView is SFButton && context.nextFocusedView?.tag == 7878) {
                    adjustTheFramesOnMenuFocusAndDefocus(didFocusOnMenu: true)
                }
            }
            else  if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment{
                if context.nextFocusedView is MenuCollectionCell_tvOS {
                    adjustTheFramesOnMenuFocusAndDefocus(didFocusOnMenu: true)
                }
            }
      }
  }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - MenuViewControllerDelegate
    func menuSelected(menuSelectedAtIndex: Int) {
        if currentSelectedIndex != menuSelectedAtIndex {
            updateSubContainerItems()
            updateTheViewAtCenterViewControllerForSelectedIndex(indexSelected: menuSelectedAtIndex)
            NotificationCenter.default.post(name: Constants.kMenuButtonTapped, object: nil , userInfo : nil)
        }
        didTransitionFromMenu = true
        self.setNeedsFocusUpdate()
        currentSelectedIndex = menuSelectedAtIndex
        print("Item selected at Index \(menuSelectedAtIndex)");
        self.adjustTheFramesOnMenuFocusAndDefocus(didFocusOnMenu: false)
        
     
        ///Check if selected/tapped menu is Home or index 0
        if menuSelectedAtIndex == 0{
            ///Refresh data for home page to get latest continue watching tray.
            NotificationCenter.default.post(name: Constants.KRefreshDataOfPage, object: nil , userInfo : nil)
        }
        
    }
    
    @objc private func toggleUserInteractionForMenu(_ notification: NSNotification) -> Void {
        let userInfo = notification.userInfo
        self.menuController?.toggleUserInteraction(userInfo?["value"] as! Bool)
    }
    
    private func updateTheViewAtCenterViewControllerForSelectedIndex(indexSelected: Int) {
        didTransitionFromMenu = true
        self.setNeedsFocusUpdate()
        toggleMenuState(shouldShow: false)
        updateTheBaseControllerForItemAtIndex(index: indexSelected)
    }
    
    private func updateTheBaseControllerForItemAtIndex(index: Int) {

        self.baseModuleController?.view.removeFromSuperview()
        self.baseModuleController?.removeFromParentViewController()
        self.baseModuleController = self.navigationItemsArray?[index].pageObject
        self.addChildViewController(self.baseModuleController!)
        self.centerViewControllerContainerView?.addSubview((self.baseModuleController?.view)!)
    }

    private func toggleMenuState(shouldShow: Bool) {
        if isMenuViewShowing != shouldShow {
            isMenuViewShowing = shouldShow
            let userInfo = [ "value" : shouldShow ]
            NotificationCenter.default.post(name: Constants.kToggleMenuBarNotification, object: nil , userInfo : userInfo)
            Constants.kNOTIFICATIONCENTER.post(name: NSNotification.Name(rawValue: "MenuToggled"), object: nil)
        }
        if shouldShow {
            self.addBlurViewOnCenterView()
            UIView.animate(withDuration: 0.2, animations: {
                self.menuController?.view.alpha = 1.0
                self.menuController?.view.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width), height: self.menuViewHeight)
                self.centerViewControllerContainerView?.frame = CGRect(x: 0, y: CGFloat(self.menuViewHeight), width: self.view.frame.width, height: self.view.frame.height)
                self.blurView?.alpha = 1.0
                
            }, completion: { (completed) in
            })
        } else {
            self.removeBlurViewFromCenterView()
            UIView.animate(withDuration: 0.2, animations: {
                self.menuController?.view.frame = CGRect(x: 0, y: -(self.menuViewHeight), width: Int(self.view.frame.width), height: self.menuViewHeight)
                self.centerViewControllerContainerView?.frame = CGRect(x: 0.0, y: self.centerViewStartingY, width: (Double(self.view.bounds.size.width)), height: (Double(self.view.bounds.size.height)))
            }, completion: { (completed) in
                self.menuController?.view.alpha = 1.0
            })
        }
    }
    
//  override weak var preferredFocusedView: UIView? {
//        if isMenuViewShowing {
//            return self.menuController?.view
//        } else {
//            if didTransitionFromMenu {
//                didTransitionFromMenu = false
//                return self.navigationItemsArray?[0].pageObject.view
//            } else {
//                return nil
//            }
//        }
//    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if isMenuViewShowing {
            if let viewToBeFocused = self.menuController?.view {
                return [viewToBeFocused]
            }
        } else {
            if didTransitionFromMenu {
                didTransitionFromMenu = false
                if let viewToBeFocused = self.navigationItemsArray?[0].pageObject.view {
                    return [viewToBeFocused]
                }
            } else {
                return super.preferredFocusEnvironments
            }
        }
        return super.preferredFocusEnvironments
    }
    
    func ignoreMenu(presses: Set<NSObject>) -> Bool {
        return (presses.first! as! UIPress).type == .menu
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if self.ignoreMenu(presses: presses) {
            super.pressesBegan(presses, with: event)
        }
    }
    
    
    //MARK: - Add BlurView Method
    private func addBlurViewOnCenterView() -> Void {
        if (!isBlurViewAdded)
        {
            if blurView == nil {
                blurView = BlurView_tvOS.init(frame: CGRect(x: 0, y: CGFloat(menuViewHeight), width: self.view.frame.size.width, height: self.view.frame.size.height))
            }
            blurView?.alpha = 0.0
            self.view.addSubview(blurView!)
            isBlurViewAdded  = true
        }
    }

    private func removeBlurViewFromCenterView() -> Void {
        blurView?.removeFromSuperview()
        isBlurViewAdded = false
    }
    
    private func updateSubContainerItems() {
        if let navigationItems = self.navigationItemsArray {
            let filteredArray = navigationItems.filter({$0.pageObject is AppSubContainerController})
            if filteredArray.count > 0 {
                let subContainer: AppSubContainerController = filteredArray[0].pageObject as! AppSubContainerController
                subContainer.loadSpecificPage = .loadAll
                subContainer.updateFocusOnSubMenuSelection()
            }
        }
    }
    
    private func updateSubContainerFocus() {
        if let navigationItems = self.navigationItemsArray {
            let filteredArray = navigationItems.filter({$0.pageObject is AppSubContainerController})
            if filteredArray.count > 0 {
                let subContainer: AppSubContainerController = filteredArray[0].pageObject as! AppSubContainerController
                subContainer.updateFocusOnSubMenu()
            }
        }
    }
    
    func openSubContainerView(contentToLoad: SubContainerLoadsSpecificPage = .loadAll, _ completionHandler: (() -> Void)? = nil,shouldJustDismiss: Bool = false) {
        
        //Opening user profile page i.e. sub container.
        let subContainer: AppSubContainerController = AppSubContainerController()
        subContainer.shouldJustDismiss = shouldJustDismiss
        subContainer.loadSpecificPage = contentToLoad
        if let topVC = self.getTheTopViewController() {
            topVC.present(subContainer, animated: true, completion: nil)
        } else {
            self.present(subContainer, animated: true, completion: nil)
        }
        subContainerDismissCompletionHandler = completionHandler
    }
    
    func dismissSubContainer() {
        updateSubContainerFocus()
        if let topVC = self.getTheTopViewController() {
            topVC.dismiss(animated: false, completion: {
                if let subContainerCallback = self.subContainerDismissCompletionHandler {
                    subContainerCallback()
                }
                self.dismissAllPresentVC(vc: topVC)
                self.subContainerDismissCompletionHandler = nil
            })
        } else {
            self.dismiss(animated: false, completion: {
                if let subContainerCallback = self.subContainerDismissCompletionHandler {
                    subContainerCallback()
                }
                self.subContainerDismissCompletionHandler = nil
            })
        }
    }
    
    
    private func dismissAllPresentVC(vc: UIViewController) {
        var currentVC = vc
        while let parentVC = currentVC.presentingViewController {
            if let presentedVC = parentVC.presentedViewController {
                presentedVC.dismiss(animated: false, completion: nil)
            }
            currentVC = parentVC
        }
    }
    
    private func getTheTopViewController() -> UIViewController? {
        let viewController: UIViewController?
        viewController = self.presentedViewController
        return viewController
    }
}
