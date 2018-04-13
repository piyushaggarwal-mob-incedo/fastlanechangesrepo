//
//  SearchBaseViewController.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 14/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SearchBaseViewController: UIViewController {

    
    var searchViewController: SearchViewController_tvOS?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        createSearcContainerControllers()
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(resetSearch(_:)), name: Constants.kMenuButtonTapped, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Constants.kMenuButtonTapped, object: nil);
    }
    
    
    func  resetSearch (_ info : NSNotification) -> Void {
        
        if searchViewController != nil
        {
            let searchText = searchViewController?.mainSearchController?.searchBar.text
            if (!(searchText?.isEmpty)! &&  (searchViewController?.typeAheadSearchResultsArray.count)!>0)
            {
                searchViewController?.saveSearchTextToUserDefaults(searchString: searchText!)
                searchViewController?.refreshPreviousSearchView()
                searchViewController?.tableView?.isUserInteractionEnabled = true
            }
            searchViewController?.mainSearchController?.searchBar.text = nil
            searchViewController?.resetSearchToInitialState()
        }
    }
    

    override func viewDidAppear(_ animated: Bool)  {
        super.viewDidAppear(animated)
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment {
            if let searchVC = searchViewController {
                searchVC.addFooterViewToTheView()
            }
        }
        let userInfo = [ "value" : true ]
        NotificationCenter.default.post(name: Notification.Name("ToggleMenuBarInteraction"), object: nil , userInfo : userInfo )
        GATrackerTVOS.sharedInstance().screenView("Search Results Screen", customParameters: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment {
            if let searchVC = searchViewController {
                searchVC.hideFooterView()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createSearcContainerControllers() {
        
        ///Create SearchViewController
        searchViewController  = SearchViewController_tvOS()
        searchViewController?.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        var fontFamily:String?
        if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
            fontFamily = _fontFamily
        }
        if fontFamily == nil {
            fontFamily = "OpenSans"
        }
        searchViewController?.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: fontFamily!, size: 10)!], for: .selected)
        
        //Create searchController object with searchViewController object.
        let searchController = UISearchController.init(searchResultsController: searchViewController)
        //searchController.obscuresBackgroundDuringPresentation = NO;
        searchController.searchResultsUpdater = searchViewController as? UISearchResultsUpdating
        searchController.searchBar.tintColor = UIColor.white;
        searchController.searchBar.keyboardAppearance = .dark;
        searchController.hidesNavigationBarDuringPresentation = false;
        
        searchViewController?.mainSearchController = searchController;
        
        let Device = UIDevice.current
        let tvOSVersion = NSString(string: Device.systemVersion).doubleValue
        
        if tvOSVersion < 10 {
            /*Create SearchContainerViewController_tvOS controller object with searchController.*/
            let searchContainerVC = SearchContainerViewController_tvOS.init(searchController: searchController)
            
            let navigationController = UINavigationController(rootViewController: searchContainerVC)
            
            searchViewController?.containerVC = searchContainerVC;
            searchViewController?.navController = self.navigationController
            
            self.addChildViewController(navigationController)
            self.view.addSubview(navigationController.view!)
            navigationController.didMove(toParentViewController: self)
        } else {
            /*Create SearchContainerViewController_tvOS controller object with searchController.*/
            let searchContainerVC = SearchContainerViewController_tvOS.init(searchController: searchController)
            
            searchViewController?.containerVC = searchContainerVC;
            searchViewController?.navController = self.navigationController
            
            self.addChildViewController(searchContainerVC)
            self.view.addSubview(searchContainerVC.view!)
            searchContainerVC.didMove(toParentViewController: self)
        }
        
    }
    
}
