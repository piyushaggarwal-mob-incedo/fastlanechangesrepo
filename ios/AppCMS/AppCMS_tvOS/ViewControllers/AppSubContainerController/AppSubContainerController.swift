//
//  AppSubContainerController.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 03/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

let LOADDUMMYDATA : Bool = false

enum SubContainerLoadsSpecificPage {
    case loadAll
    case loadLoginPage
    case loadPlansPage
    case loadSignUpPage
}

class AppSubContainerController: UIViewController, MenuViewControllerDelegate {

    /// Menu Controller instance.
    private var subMenuController: SubMenuViewController_tvOS?
    private var subNavigationArray: Array<PageTuple>?
    private var selectedSubMenuOptionIndex = 0
    private var currentViewController: UIViewController?
    var shouldJustDismiss: Bool?
    
    /// Set this to load certain data.
    private var _loadSpecificPage:SubContainerLoadsSpecificPage = .loadAll
    var loadSpecificPage:SubContainerLoadsSpecificPage {
        set(newValue) {
            if _loadSpecificPage != newValue {
                _loadSpecificPage = newValue
                updateSubMenuPageArray()
            }
            subMenuController?.updateSelectedMenuOption(selectedSubMenuOptionIndex)
        } get {
            return _loadSpecificPage
        }
    }
    
    /// Holds the instance of the last focused item.
    private var lastFocusedView: Any?
    
    private(set) lazy var centralContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private(set) lazy var viewModel: AppSubContainer_ViewModel = {
        let viewModel = AppSubContainer_ViewModel()
        return viewModel
    }()
    
    private func setupCentralContainerView() {
        var startingY = 0
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
            startingY = 10
            let topBar = UIView(frame: CGRect(x: 0, y: 0, width: (self.view.bounds.size.width), height: 10))
            topBar.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "#000000")
            self.view.addSubview(topBar)
        }
        centralContainerView.frame = CGRect(x: startingY, y: 140, width: 1920, height: (940 - startingY))
        centralContainerView.backgroundColor = UIColor.clear
        self.view.addSubview(centralContainerView)
    }
    
    private func setupAndAddMenuControllerWithArray (arrayOfnavigationItems: Array<PageTuple>) {
        
        subMenuController = SubMenuViewController_tvOS.init(menuArray: arrayOfnavigationItems as Array<PageTuple>)
        self.addChildViewController(subMenuController!)
        self.view.addSubview((subMenuController?.view)!)
        subMenuController?.view.backgroundColor = UIColor.clear
        subMenuController?.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 140)
        subMenuController?.preferredContentSize = CGSize(width: self.view.frame.width, height: 140)
        subMenuController?.delegate = self
        subMenuController?.didMove(toParentViewController: self)
        subMenuController?.view.alpha = 0.52
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(updateFocus), name: Constants.kToggleMenuBarNotification, object: nil)
        Constants.kNOTIFICATIONCENTER.addObserver(self, selector: #selector(fetchSubNavItems), name: Constants.kUpdateNavigationMenuItems, object: nil)
        fetchSubNavItems()
        setupCentralContainerView()
        setupAndAddMenuControllerWithArray(arrayOfnavigationItems: subNavigationArray!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if subNavigationArray != nil && (subNavigationArray?.count)! > 0{
            updateViewControllerAtCenter(viewController: (subNavigationArray?[selectedSubMenuOptionIndex].pageObject)!)
        }
        UIView.animate(withDuration: 0.2) { 
            self.view.alpha = 1.0
        }
        if lastFocusedView != nil {
            DispatchQueue.main.async {
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        lastFocusedView = UIScreen.main.focusedView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.alpha = 0.0
    }
    
    deinit {
        Constants.kNOTIFICATIONCENTER.removeObserver(self, name: Constants.kUpdateNavigationMenuItems, object: nil)
    }
    
    private func refreshSubMenuController(arrayOfnavigationItems: Array<PageTuple>) {
        subMenuController?.refreshMenuWithArray(menuArray: arrayOfnavigationItems)
    }
    
    @objc private func fetchSubNavItems() {
        if let pageName = (subNavigationArray?[selectedSubMenuOptionIndex].pageName) {
            if pageName != "Settings" {
                selectedSubMenuOptionIndex = 0
            }
        } else {
            selectedSubMenuOptionIndex = 0
        }
        if LOADDUMMYDATA {
            subNavigationArray = viewModel.getDummyArrayForGuestUser()
        } else {
            subNavigationArray = viewModel.getAllTheNavigationViewControllers()
        }
        refreshSubMenuController(arrayOfnavigationItems: subNavigationArray!)
    }
    
    func updateFocusOnSubMenuSelection() {
        selectedSubMenuOptionIndex = 0
        subMenuController?.updateSelectedMenuOption(selectedSubMenuOptionIndex)
    }
    
    func updateFocusOnSubMenu() {
        subMenuController?.updateSelectedMenuOption(selectedSubMenuOptionIndex)
        if subNavigationArray != nil && (subNavigationArray?.count)! > 0{
            updateViewControllerAtCenter(viewController: (subNavigationArray?[selectedSubMenuOptionIndex].pageObject)!)
        }
    }
    
    private func updateSubMenuPageArray() {
        viewModel.loadSpecificPage = _loadSpecificPage
        fetchSubNavItems()
    }
    
    @objc private func updateFocus() {
        subMenuController?.updateCollectionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - MenuViewControllerDelegate
    func menuSelected(menuSelectedAtIndex: Int) {
        selectedSubMenuOptionIndex = menuSelectedAtIndex
        updateViewControllerAtCenter(viewController: (subNavigationArray?[menuSelectedAtIndex].pageObject)!)
    }
    
    private func updateViewControllerAtCenter (viewController: UIViewController) {
        if currentViewController != nil {
            currentViewController?.removeFromParentViewController()
            currentViewController?.view.removeFromSuperview()
        }
        currentViewController = viewController
        currentViewController?.preferredContentSize = CGSize(width: 1920, height: 940)
        currentViewController?.view.frame = CGRect(x: 0, y: 0, width: 1920, height: 940)
        self.addChildViewController(currentViewController!)
        centralContainerView.addSubview((currentViewController?.view)!)
        currentViewController?.didMove(toParentViewController: self)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView is SubMenuCollectionCell_tvOS && context.previouslyFocusedView is SubMenuCollectionCell_tvOS == false {
            subMenuController?.view.alpha = 1.0
            subMenuController?.menuCollectionView?.reloadData()
        }
        if context.previouslyFocusedView is SubMenuCollectionCell_tvOS && context.nextFocusedView is SubMenuCollectionCell_tvOS == false{
            subMenuController?.view.alpha = 0.52
        }
    }
    
//    override weak var preferredFocusedView: UIView? {
//        if lastFocusedView != nil {
//            let lastFocusedViewLocalCopy = lastFocusedView as? UIView
//            lastFocusedView = nil
//            return lastFocusedViewLocalCopy
//        }
//        return nil
//    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if lastFocusedView != nil {
            let lastFocusedViewLocalCopy = lastFocusedView as? UIView
            lastFocusedView = nil
            return [lastFocusedViewLocalCopy!]
        }
        return super.preferredFocusEnvironments
    }
}
