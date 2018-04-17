//
//  SearchViewController.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 05/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import GoogleCast
import Firebase
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CollectionGridViewDelegate, CollectionGridViewDelegate1, GCKUIMiniMediaControlsViewControllerDelegate, SFMorePopUpViewControllerDelegate {
    
    var searchTextField:UITextField?
    var searchBarButton:UIButton?
    var clearSearchTextButton:UIButton?
    var searchTermLabel:UILabel?
    var noResultLabel:UILabel?
    var searchResultsHeaderView:UIView?
    var searchResultsHeaderViewTopSeparator:UIView?
    var searchResultsHeaderViewBottomSeparator:UIView?
    var searchResultsTableView:UITableView?
    var searchTypeAheadTableView:UITableView?
    var layoutDictSearchTextField:Dictionary<String, LayoutObject> = [:]
    var layoutDictSearchBarButton:Dictionary<String, LayoutObject> = [:]
    var layoutDictSearchResultsHeaderView:Dictionary<String, LayoutObject> = [:]
    var layoutDictSearchResultsHeaderViewTopSeparator:Dictionary<String, LayoutObject> = [:]
    var layoutDictSearchResultsHeaderViewBottomSeparator:Dictionary<String, LayoutObject> = [:]
    var layoutDictClearSearchResults:Dictionary<String, LayoutObject> = [:]
    var layoutDictSearchText:Dictionary<String, LayoutObject> = [:]
    var layoutDictSearchTypeAheadTableView:Dictionary<String, LayoutObject> = [:]
    var layoutDictSearchResultsTableView:Dictionary<String, LayoutObject> = [:]
    var layoutDictNoResultLabel:Dictionary<String, LayoutObject> = [:]
    var relativeViewFrame:CGRect?
    var searchResultsArray:Array<AnyObject> = []
    var typeAheadSearchResultsArray:Array<AnyObject> = []
    let navBarPadding:CGFloat = 0.0
    var alertType:AlertType?
    var networkUnavailableAlert:UIAlertController?
    var searchTerm:String = ""
    var modulesListArray:Array<AnyObject> = []
    var moduleObject:SFModuleObject?
    var contentOffSetDictionary:Dictionary<String, AnyObject> = [:]
    var cellModuleDict:Dictionary<String, AnyObject> = [:]
    var _miniMediaControlsContainerView: UIView!
    var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    var shouldDisplayBackButtonOnNavBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = true
        self.edgesForExtendedLayout = []
        
        self.addMiniCastControllerToViewController(viewController: self)
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        relativeViewFrame = UIScreen.main.bounds
        relativeViewFrame?.size.height = UIScreen.main.bounds.size.height - navBarPadding
        
        createModuleListForSearchResultsTable()
        createSearchTextField()
        createTypeAheadTableView()
        createSearchResultsHeaderView()
        createSearchResultTableView()
        createNoResultLabel()
        updateSubViewFramesAsPerScreenRatio()
        
        self.view.bringSubview(toFront: searchTextField!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.isUserInteractionEnabled = true
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
//            FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [kFIRParameterItemName: "Search Results Screen"])
            FIRAnalytics.setScreenName("Search Results Screen", screenClass: nil)
        }

        self.updateControlBarsVisibility()

        createNavigationBar()
        
        if !(self.searchTextField?.isFirstResponder)! && searchTextField?.isHidden == false {// && Constants.kAPPDELEGATE.shouldDisplayKeyboard == true{
            
            self.searchTextField?.becomeFirstResponder()
            //Constants.kAPPDELEGATE.shouldDisplayKeyboard = false
        }
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    // MARK: - Internal methods
    func updateControlBarsVisibility() {
        if (self.miniMediaControlsViewController != nil){
            var variance:CGFloat = 0
            if (Constants.IPHONE && Utility.sharedUtility.isIphoneX()){
                variance = 20;
            }
            _miniMediaControlsContainerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - (112 + variance) , width: UIScreen.main.bounds.width, height: 0)

            if self.miniMediaControlsViewController.active && CastPopOverView.shared.isConnected() {
                _miniMediaControlsContainerView.changeFrameHeight(height: 64)
                self.view.bringSubview(toFront: _miniMediaControlsContainerView)
            } else {
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
        
        _miniMediaControlsContainerView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - (112), width: UIScreen.main.bounds.width, height: 0))
        
        viewController.view.addSubview(_miniMediaControlsContainerView)
        
        self.miniMediaControlsViewController = GCKCastContext.sharedInstance().createMiniMediaControlsViewController()
        self.miniMediaControlsViewController.delegate = self
        self.miniMediaControlsViewController.view.frame = _miniMediaControlsContainerView.bounds
        _miniMediaControlsContainerView.addSubview(self.miniMediaControlsViewController.view)
        
        self.updateControlBarsVisibility()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.allowIDFACollection = true
        tracker.set(kGAIScreenName, value: "Search Results Screen")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func createNavigationBar() {
        
        self.navigationController?.navigationBar.barTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        self.navigationItem.titleView = Utility.createNavigationTitleView(navBarHeight: (self.navigationController?.navigationBar.frame.size.height)!)
        
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() || shouldDisplayBackButtonOnNavBar == true {
            
            if shouldDisplayBackButtonOnNavBar {
                
                createLeftNavItems()
            }
        }
    }
    
    //MARK: Creation of left nav items for sports template
    private func createLeftNavItems() {
        
        self.navigationItem.leftBarButtonItems = nil
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15
        
        let backButton = UIButton(type: .custom)
        backButton.sizeToFit()
        let backButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "cancelIcon.png"))
        
        backButton.setImage(backButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        backButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (backButtonImageView.image?.size.height)!/2)
        backButton.addTarget(self, action: #selector(backButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        
        let backButtonItem = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItems = [negativeSpacer, backButtonItem]
    }
    
    
    func backButtonClicked(sender:AnyObject) {
        
        NotificationCenter.default.removeObserver(self)
        
        //        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
        
        self.navigationController?.popViewController(animated: true)
        //        }
        //        else {
        
        //            self.dismiss(animated: true, completion: nil)
        //        }
    }
    
    
    //MARK: method to create right bar button items
    func createRightNavBarItems() {
        
        self.navigationItem.rightBarButtonItems = nil
        
        let searchButton = UIButton(type: .custom)
        searchButton.sizeToFit()
        
        let searchButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "searchIcon.png"))
        
        searchButton.setImage(searchButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        searchButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        
        searchButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (searchButtonImageView.image?.size.height)!/2)
        searchButton.addTarget(self, action: #selector(cancelButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        
        let searchButtonItem = UIBarButtonItem(customView: searchButton)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15
        
        self.navigationItem.rightBarButtonItems = [negativeSpacer, searchButtonItem]
    }
    
    //MARK: Button event handler for nav bar cancel icon
    func cancelButtonClicked(sender:AnyObject) {
        
        Constants.kAPPDELEGATE.openTabBarWith(barIndex: 0)
        //self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Method to create Module list for Search result table
    func createModuleListForSearchResultsTable() {
        
        let filePath:String = (Bundle.main.resourcePath?.appending("/SearchPageModule.json"))!
        
        let jsonData:Data = FileManager.default.contents(atPath: filePath)!
        
        let responseJson:Array<Dictionary<String, AnyObject>>? = try! JSONSerialization.jsonObject(with:jsonData) as? Array<Dictionary<String, AnyObject>>
        let moduleParser = ModuleUIParser()
        modulesListArray = moduleParser.parseModuleConfigurationJson(modulesConfigurationArray: responseJson!) as Array<AnyObject>
    }
    
    
    //MARK: Create search textfield
    func createSearchTextField() {
        
        createSearchTextFieldDictLayout()
        
        let layoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchTextField)

        searchTextField = UITextField(frame: Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: relativeViewFrame!))
//        searchTextField?.frame.origin.y = 0//Utility.sharedUtility.getPosition(position:(searchTextField?.frame.origin.y)!) + navBarPadding
        searchTextField?.textAlignment = .left
        searchTextField?.placeholder = "SEARCH"
        
        searchTextField?.attributedPlaceholder = NSAttributedString(string: "SEARCH", attributes: [NSForegroundColorAttributeName : Utility.hexStringToUIColor(hex: "162732").withAlphaComponent(0.46)])
        searchTextField?.textColor = Utility.hexStringToUIColor(hex: "292929")
        searchTextField?.borderStyle = .none
        searchTextField?.autocorrectionType = .no
        searchTextField?.backgroundColor = UIColor.white
        searchTextField?.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: (10.0 * Utility.getBaseScreenHeightMultiplier()))
        searchTextField?.keyboardAppearance = .dark
        searchTextField?.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        searchTextField?.returnKeyType = .go
        searchTextField?.addTarget(self, action: #selector(searchBarButtonClicked(sender:)), for: .editingDidEndOnExit)
        searchTextField?.addTarget(self, action: #selector(textDidChanged(sender:)), for: .editingChanged)
        self.view.addSubview(searchTextField!)

        createSearchBarButtonDictLayout()
        let layoutObject1:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchBarButton)
        
        searchBarButton = UIButton(frame: Utility.initialiseViewLayout(viewLayout: layoutObject1, relativeViewFrame: relativeViewFrame!))
        searchBarButton?.frame.origin.y = (searchBarButton?.frame.origin.y)!//Utility.sharedUtility.getPosition(position: (searchBarButton?.frame.origin.y)!)  + navBarPadding
        searchBarButton?.setTitle("GO", for: .normal)
        searchBarButton?.titleLabel?.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Semibold", size: (12.0 * Utility.getBaseScreenHeightMultiplier()))
        searchBarButton?.addTarget(self, action: #selector(searchBarButtonClicked(sender:)), for: .touchUpInside)
//        searchBarButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor ?? "000000")
        searchBarButton?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000")
        searchBarButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.textColor ?? AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        
        self.view.addSubview(searchBarButton!)
    }
    
    
    //MARK: Search Bar button click Event
    func searchBarButtonClicked(sender:AnyObject) {
        
        if typeAheadSearchResultsArray.count > 0 {
            
            if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
            {
                FIRAnalytics.logEvent(withName: Constants.kGTMSubmitSearchEvent, parameters: [Constants.kGTMSearchTermAttribute : self.searchTerm])
            }
            
            searchTextField?.resignFirstResponder()
            
            searchTextField?.isHidden = true
            searchBarButton?.isHidden = true
            hideTypeAheadSearchResultTable()
            noResultLabel?.isHidden = true
            
            searchResultsHeaderView?.isHidden = false
            searchTermLabel?.text = searchTerm.uppercased()
            searchResultsTableView?.isHidden = false
            searchResultsTableView?.reloadData()
        }
    }
    
    func textDidChanged(sender:UITextField) {
     
        searchTerm = sender.text ?? ""
        searchTerm = searchTerm.trimmingCharacters(in: .whitespaces)
        if !searchTerm.isEmpty {
            
            fetchTypeAheadSearchResults()
        }
        else {
            
            hideTypeAheadSearchResultTable()
        }
    }
    
    //MARK: Create search results header view
    func createSearchResultsHeaderView() {
        
        createSearchResultsHeaderViewDictLayout()
        createClearSearchResultsDictLayout()
        createSearchTextDictLayout()
        createSearchResultsHeaderViewTopSeparatorDictLayout()
        createSearchResultsHeaderViewBottomSeparatorDictLayout()
        
        let searchResultsHeaderViewLayoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchResultsHeaderView)
        searchResultsHeaderView = UIView(frame: Utility.initialiseViewLayout(viewLayout: searchResultsHeaderViewLayoutObject, relativeViewFrame: relativeViewFrame!))

//        if (Constants.IPHONE && Utility.sharedUtility.isIphoneX()) {
//            searchResultsHeaderView?.frame.origin.y = 0//Utility.sharedUtility.getPosition(position: 20)  + navBarPadding
//        }
//        else{
            searchResultsHeaderView?.frame.origin.y = (searchResultsHeaderView?.frame.origin.y)! + navBarPadding
//        }
        
        self.view.addSubview(searchResultsHeaderView!)
        
        let clearSearchButtonLayoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictClearSearchResults)
        clearSearchTextButton = UIButton(frame: Utility.initialiseViewLayout(viewLayout: clearSearchButtonLayoutObject, relativeViewFrame: (searchResultsHeaderView?.frame)!))
        clearSearchTextButton?.layer.borderColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff").cgColor
        clearSearchTextButton?.layer.borderWidth = 1.0
        clearSearchTextButton?.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"), for: .normal)
        clearSearchTextButton?.titleLabel?.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Semibold", size: 12.0)
        clearSearchTextButton?.setTitle("CLEAR", for: .normal)
        clearSearchTextButton?.addTarget(self, action: #selector(clearSearchResultsButtonClicked(sender:)), for: .touchUpInside)
        searchResultsHeaderView?.addSubview(clearSearchTextButton!)
        
        let searchTextLayoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchText)
        searchTermLabel = UILabel(frame: Utility.initialiseViewLayout(viewLayout: searchTextLayoutObject, relativeViewFrame: (searchResultsHeaderView?.frame)!))
        searchTermLabel?.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Semibold", size: 12.0)
        searchTermLabel?.textAlignment = .left
        searchTermLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        searchResultsHeaderView?.addSubview(searchTermLabel!)
        
        let searchResultsHeaderViewTopSeparatorLayoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchResultsHeaderViewTopSeparator)
        searchResultsHeaderViewTopSeparator = UIView(frame: Utility.initialiseViewLayout(viewLayout: searchResultsHeaderViewTopSeparatorLayoutObject, relativeViewFrame: (searchResultsHeaderView?.frame)!))
        searchResultsHeaderViewTopSeparator?.backgroundColor = Utility.hexStringToUIColor(hex: "6C7074")
        searchResultsHeaderView?.addSubview(searchResultsHeaderViewTopSeparator!)
        
        let searchResultsHeaderViewBottomSeparatorLayoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchResultsHeaderViewBottomSeparator)
        searchResultsHeaderViewBottomSeparator = UIView(frame: Utility.initialiseViewLayout(viewLayout: searchResultsHeaderViewBottomSeparatorLayoutObject, relativeViewFrame: (searchResultsHeaderView?.frame)!))
        searchResultsHeaderViewBottomSeparator?.backgroundColor = Utility.hexStringToUIColor(hex: "6C7074")
        searchResultsHeaderView?.addSubview(searchResultsHeaderViewBottomSeparator!)
     
        searchResultsHeaderView?.isHidden = true
    }
    
    
    //MARK: Button event handler for clearing search text
    func clearSearchResultsButtonClicked(sender:AnyObject) {
    
        searchTextField?.text = ""
        searchTextField?.isHidden = false
        searchBarButton?.isHidden = false
        
        searchTermLabel?.text = ""
        searchResultsHeaderView?.isHidden = true
        searchResultsTableView?.isHidden = true
        noResultLabel?.isHidden = true
        moduleObject = nil
        searchResultsTableView?.reloadData()
    }
    
    
    //MARK: Create typeahead table view
    func createTypeAheadTableView() {
        
        createSearchTypeAheadTableViewDictLayout()
        
        let layoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchTypeAheadTableView)
        
        searchTypeAheadTableView = UITableView(frame: Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: relativeViewFrame!), style: .plain)
        searchTypeAheadTableView?.frame.origin.y = searchTextField?.frame.maxY ?? (searchTypeAheadTableView?.frame.origin.y)! + navBarPadding
        searchTypeAheadTableView?.backgroundColor = Utility.hexStringToUIColor(hex: "EAEAEA")
        searchTypeAheadTableView?.delegate = self
        searchTypeAheadTableView?.dataSource = self
        searchTypeAheadTableView?.tag = 100
        searchTypeAheadTableView?.separatorStyle = .none
        searchTypeAheadTableView?.register(SFSearchResultTypeAheadCell.self, forCellReuseIdentifier: "typeAheadCell")
        self.view.addSubview(searchTypeAheadTableView!)
        
        searchTypeAheadTableView?.isHidden = true
    }
    
    
    //MARK: Create search results table view
    func createSearchResultTableView() {
        
        createSearchResultsTableViewDictLayout()
        
        let layoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchResultsTableView)
        
        searchResultsTableView = UITableView(frame: Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: relativeViewFrame!), style: .plain)
        if (Constants.IPHONE && Utility.sharedUtility.isIphoneX()) {
           // searchResultsTableView?.frame.origin.y = Utility.sharedUtility.getPosition(position: (searchResultsTableView?.frame.origin.y)!) + 5 + navBarPadding
        }
        else
        {
            searchResultsTableView?.frame.origin.y = (searchResultsTableView?.frame.origin.y)! + navBarPadding
        }

        searchResultsTableView?.backgroundColor = UIColor.clear
        searchResultsTableView?.delegate = self
        searchResultsTableView?.dataSource = self
        searchResultsTableView?.separatorStyle = .none
        searchResultsTableView?.register(SFTrayModuleCell.self, forCellReuseIdentifier: "trayModuleCell")
        searchResultsTableView?.tag = 101
    
        self.view.addSubview(searchResultsTableView!)
        searchResultsTableView?.isHidden = true
    }
    
    
    //MARK: method to create no result label
    func createNoResultLabel() {
        
        createNoResultLabelDictLayout()
        
        let layoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictNoResultLabel)
        
        noResultLabel = UILabel(frame: Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: relativeViewFrame!))
        noResultLabel?.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 14 * Utility.getBaseScreenHeightMultiplier())
//        noResultLabel?.frame.origin.y = Utility.sharedUtility.getPosition(position: (noResultLabel?.frame.origin.y)!) + navBarPadding
        noResultLabel?.textAlignment = .center
        noResultLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        
        self.view.addSubview(noResultLabel!)
        noResultLabel?.isHidden = true
    }

    
    //MARK: TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 100 {
            
            return typeAheadSearchResultsArray.count
        }
        else if tableView.tag == 101 {
           
            return moduleObject != nil ? 1 : 0
        }
        
        return 0
//        return searchResultsArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 0.0
        
        if tableView.tag == 100 {
            
            rowHeight = 50.0
        }
        else if tableView.tag == 101 {
            
            let trayObject:SFTrayObject? = modulesListArray[0] as? SFTrayObject
            rowHeight = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject!).height ?? 170)
        }
        
        return rowHeight
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 100 {
            
            let typeAheadCell:SFSearchResultTypeAheadCell = tableView.dequeueReusableCell(withIdentifier: "typeAheadCell") as! SFSearchResultTypeAheadCell
            
            addTypeAheadCellToTable(typeAheadCell: typeAheadCell, gridObject: typeAheadSearchResultsArray[indexPath.row] as? SFGridObject)
    
            return typeAheadCell
        }
        else if tableView.tag == 101 {

            var tableViewCell:UITableViewCell? = cellModuleDict["\(String(indexPath.row))"] as? UITableViewCell

            if tableViewCell == nil {
                
                tableViewCell = UITableViewCell(style: .value1, reuseIdentifier: "trayModuleCell")
                tableViewCell?.selectionStyle = .none
                tableViewCell?.backgroundColor = UIColor.clear
                
                addCollectionGridToTable(cell: tableViewCell!, pageModuleObject: moduleObject!)
                cellModuleDict["\(String(indexPath.row))"] = tableViewCell!
            }
           
//            let trayModuleCell:SFTrayModuleCell = tableView.dequeueReusableCell(withIdentifier: "trayModuleCell") as! SFTrayModuleCell
//            
//            addCollectionGridViewToTable(cell: trayModuleCell, pageModuleObject: moduleObject!)
//            
//            trayModuleCell.offSetValue = indexPath.row
//            
//            let horizontalOffset:CGFloat? = self.contentOffSetDictionary["\(indexPath.row)"] as? CGFloat
//            trayModuleCell.collectionGrid?.setContentOffset(CGPoint(x: horizontalOffset ?? 0, y: 0), animated: false)
            
            return tableViewCell!
//            addCollectionGridToTable(cell: tableViewCell, pageModuleObject: moduleObject!)
        }
        else {
            let tableViewCell = UITableViewCell.init(style: .default, reuseIdentifier: "gridCell")

            tableViewCell.selectionStyle = .none
            tableViewCell.backgroundColor = UIColor.clear
            
            return tableViewCell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 100 {
            
            let gridObject = typeAheadSearchResultsArray[indexPath.row] as? SFGridObject
            
            let eventId = gridObject?.eventId
            
            if eventId != nil && Constants.kAPPDELEGATE.isKisweEnable {
                
                Utility.presentKiswePlayer(forEventId: eventId!, withFilmId: gridObject?.contentId ?? "", vc:self)
            }
            else {
                
                navigateToVideoDetailPage(gridObject: gridObject)
            }
        }
    }
    
    
    //MARK: method to create type ahead cell
    func addTypeAheadCellToTable(typeAheadCell:SFSearchResultTypeAheadCell, gridObject:SFGridObject?) {
        
        typeAheadCell.backgroundColor = UIColor.clear
        typeAheadCell.selectionStyle = .none
        typeAheadCell.relativeViewFrame = CGRect(x: 0, y: 0, width: (searchTypeAheadTableView?.frame.size.width)!, height: 50)
        typeAheadCell.tableViewLayoutDict = layoutDictSearchTypeAheadTableView
        typeAheadCell.tableViewRelativeFrame = relativeViewFrame!
        typeAheadCell.gridObject = gridObject!
        typeAheadCell.updateCellView()
    }
    
    
    //MARK: Method to add grids to table view cell
    func addCollectionGridToTable(cell:UITableViewCell, pageModuleObject:SFModuleObject) {
        
        let trayObject:SFTrayObject = modulesListArray[0] as! SFTrayObject
        let collectionGridViewController:CollectionGridViewController = CollectionGridViewController(trayObject: trayObject)
        
        let rowHeight:CGFloat = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject).height ?? 170)
        let cellFrame:CGRect = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: UIScreen.main.bounds.width, height: rowHeight)
        
        collectionGridViewController.view.frame = Utility.initialiseViewLayout(viewLayout: Utility.fetchTrayLayoutDetails(trayObject: trayObject), relativeViewFrame: cellFrame)
        collectionGridViewController.relativeViewFrame = collectionGridViewController.view.frame
        collectionGridViewController.delegate = self
        collectionGridViewController.isFromSearch = true
        collectionGridViewController.moduleAPIObject = pageModuleObject
        collectionGridViewController.createSubViews()
        self.addChildViewController(collectionGridViewController)
        cell.addSubview(collectionGridViewController.view)
    }
    
    
    //MARK: Method to add grids to table view cell
    func addCollectionGridViewToTable(cell:SFTrayModuleCell, pageModuleObject:SFModuleObject) {
        
        let trayObject:SFTrayObject = modulesListArray[0] as! SFTrayObject
        
        let rowHeight:CGFloat = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject).height ?? 170)
        let cellFrame:CGRect = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: UIScreen.main.bounds.width, height: rowHeight)
        
//        collectionGridViewController.view.frame = Utility.initialiseViewLayout(viewLayout: Utility.fetchTrayLayoutDetails(trayObject: trayObject), relativeViewFrame: cellFrame)
        cell.relativeViewFrame = Utility.initialiseViewLayout(viewLayout: Utility.fetchTrayLayoutDetails(trayObject: trayObject), relativeViewFrame: cellFrame)
        cell.delegate = self
        cell.isFromSearch = true
        cell.trayObject = trayObject
        cell.moduleAPIObject = pageModuleObject
        cell.updateCellView()
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
//        cell.createSubViews()
//        cell.addSubview(collectionGridViewController.view)
    }
    
    
    //MARK:Collection Grid Delegates
    func didSelectVideo(gridObject: SFGridObject?) {
        
        let eventId = gridObject?.eventId
        
        if eventId != nil && Constants.kAPPDELEGATE.isKisweEnable {
            
            Utility.presentKiswePlayer(forEventId: eventId!, withFilmId: gridObject?.contentId ?? "", vc:self)
        }
        else {
            
            navigateToVideoDetailPage(gridObject: gridObject)
        }

    }
    
    func didDisplayMorePopUp(button: SFButton, gridObject: SFGridObject?) {
        
        if gridObject != nil {
            
            if let contentId = gridObject?.contentId, let contentType = gridObject?.contentType {
                
                var moreOptionArray = [["option":"watchlist"]]
                
                if let isDownloadEnabled = AppConfiguration.sharedAppConfiguration.isDownloadEnabled {
                    
                    if isDownloadEnabled {
                        
                        moreOptionArray.append(["option":"download"])
                    }
                }
                
                self.presentMorePopUpView(moreOptionArray: moreOptionArray, contentId: contentId, contentType: contentType, isOptionForBannerView: false)
            }
        }
    }
    
    
    //MARK: Method to display more pop up option array
    private func presentMorePopUpView(moreOptionArray:Array<Dictionary<String, Any>>, contentId:String?, contentType:String?, isOptionForBannerView: Bool) {
        self.view.isUserInteractionEnabled = false
        Utility.presentMorePopUpView(moreOptionArray: moreOptionArray, contentId: contentId, contentType: contentType, isModel: self.isModal, delegate: self, isOptionForBannerView: isOptionForBannerView);
    }
    
    
    //MARK: More popover controller delegate
    func removePopOverViewController(viewController: UIViewController) {
        self.view.isUserInteractionEnabled = true
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    
    func collectionViewDidScroll(scrollView:UIScrollView, offsetValue:Int) {
        
        if !(scrollView is UICollectionView) {
            
            return
        }
        
        let horizontalOffset:CGFloat = scrollView.contentOffset.x
        self.contentOffSetDictionary["\(offsetValue)"] = horizontalOffset as AnyObject
    }
    
    
    //MARK: method to navigate to video detail page
    func navigateToVideoDetailPage(gridObject: SFGridObject?) {
        
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
        else
        {
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
                else
                {
                    videoDetailViewController = VideoDetailViewController(viewControllerPage: viewControllerPage!, pageType: .videoDetail)
                }
                videoDetailViewController.contentId = gridObject?.contentId ?? ""
                videoDetailViewController.pagePath = gridObject?.gridPermaLink ?? ""
                videoDetailViewController.view.changeFrameYAxis(yAxis: 20.0)
                videoDetailViewController.view.changeFrameHeight(height: videoDetailViewController.view.frame.height - 20.0)
                
                if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                    
                    self.navigationController?.pushViewController(videoDetailViewController, animated: true)
                }
                else {
                    self.tabBarController?.present(videoDetailViewController, animated: true, completion: {
                        
                    })
                }
            
        }
    }
    
    //MARK: Api to fetch search typeahead results
    func fetchTypeAheadSearchResults() {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            showAlertForAlertType(alertType: .AlertTypeNoInternetFound, isTypeAheadSearch: true)
        }
        else {
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                {
                    FIRAnalytics.logEvent(withName: Constants.kGTMSearchEvent, parameters: [Constants.kGTMSearchTermAttribute : self.searchTerm])
                }
                
                let searchEncodedTerm = self.searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let searchEncodedTerm1 = searchEncodedTerm?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

                
                DataManger.sharedInstance.fetchTypeAheadSearchResults(shouldUseCacheUrl: false, apiEndPoint: "/search/v1?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&searchTerm=\(searchEncodedTerm1!)", searchResults: { (typeAheadSearchResults) in
                    
                    DispatchQueue.main.async {
                        
                        if typeAheadSearchResults != nil {
                            
                            self.moduleObject = typeAheadSearchResults!
                            
                            if (typeAheadSearchResults?.moduleData?.count)! > 0 && !self.searchTerm.isEmpty{
                                
                                //MARK: Anirudh to check if this is required or not?
                                self.cellModuleDict.removeAll()
                                
                                if self.typeAheadSearchResultsArray.count > 0 {
                                    
                                    self.typeAheadSearchResultsArray.removeAll()
                                }
                                
                                self.noResultLabel?.isHidden = true
                                self.typeAheadSearchResultsArray = (typeAheadSearchResults?.moduleData)!
                                self.searchTypeAheadTableView?.isHidden = false
                                self.searchTypeAheadTableView?.reloadData()
                            }
                            else {
                                
                                self.hideTypeAheadSearchResultTable()
                            }
                        }
                        else {
                            
                            self.hideTypeAheadSearchResultTable()
                        }
                    }
                })
            }
        }
    }
    
    
    //MARK: method to hide type ahead search result table
    func hideTypeAheadSearchResultTable() {
        
        if typeAheadSearchResultsArray.count > 0 {
            
            typeAheadSearchResultsArray.removeAll()
        }
        
        if searchTerm.isEmpty {
            
            noResultLabel?.isHidden = true
        }
        else {
  
            noResultLabel?.text = "No Results"
//            noResultLabel?.text = "No Result for \"\(searchTerm)\""
            noResultLabel?.isHidden = false
        }
        
        searchTypeAheadTableView?.isHidden = true
        searchTypeAheadTableView?.reloadData()
    }
    
    
    //MARK - method to created alert controller
    func showAlertForAlertType(alertType: AlertType, isTypeAheadSearch:Bool) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            

            if isTypeAheadSearch {
                
                self.fetchTypeAheadSearchResults()
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
    
    
    //MARK: ScrollView Delegates
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if (searchTextField?.isFirstResponder)! {
            
            searchTextField?.resignFirstResponder()
        }
    }
    
    
    //MARK: Touches event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (searchTextField?.isFirstResponder)! {
            
            self.searchTextField?.resignFirstResponder()
        }
    }
    
    
    //MARK: Orientation Method
    override func viewDidLayoutSubviews() {
        if !Constants.IPHONE {
            
            relativeViewFrame?.size = UIScreen.main.bounds.size
            relativeViewFrame?.size.height -= navBarPadding
            var layoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchTextField)
            searchTextField?.frame = Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: relativeViewFrame!)
            searchTextField?.frame.origin.y = (searchTextField?.frame.origin.y)! + navBarPadding
            
            layoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchBarButton)
            searchBarButton?.frame = Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: relativeViewFrame!)
            searchBarButton?.frame.origin.y = (searchBarButton?.frame.origin.y)! + navBarPadding
            
            layoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchTypeAheadTableView)
            searchTypeAheadTableView?.frame = Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: relativeViewFrame!)
            searchTypeAheadTableView?.frame.origin.y = searchTextField?.frame.maxY ?? (searchTypeAheadTableView?.frame.origin.y)! + navBarPadding
            
            layoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchResultsHeaderView)
            searchResultsHeaderView?.frame = Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: relativeViewFrame!)
            searchResultsHeaderView?.frame.origin.y = (searchResultsHeaderView?.frame.origin.y)! + navBarPadding
            layoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictClearSearchResults)
            clearSearchTextButton?.frame = Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: (searchResultsHeaderView?.frame)!)
            
            layoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchText)
            searchTermLabel?.frame = Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: (searchResultsHeaderView?.frame)!)
            
            layoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchResultsHeaderViewBottomSeparator)
            searchResultsHeaderViewBottomSeparator?.frame = Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: (searchResultsHeaderView?.frame)!)
            
            layoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchResultsHeaderViewTopSeparator)
            searchResultsHeaderViewTopSeparator?.frame = Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: (searchResultsHeaderView?.frame)!)

            layoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSearchResultsTableView)
            searchResultsTableView?.frame = Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: relativeViewFrame!)
            searchResultsTableView?.frame.origin.y = (searchResultsTableView?.frame.origin.y)! + navBarPadding
            
            layoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictNoResultLabel)
            noResultLabel?.frame = Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: relativeViewFrame!)
            noResultLabel?.frame.origin.y = (noResultLabel?.frame.origin.y)! + navBarPadding
            
            updateSubViewFramesAsPerScreenRatio()
            
             self.updateControlBarsVisibility()
        }
    }
    
    func updateSubViewFramesAsPerScreenRatio() {
        
        searchTextField?.changeFrameHeight(height: (searchTextField?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
        searchBarButton?.changeFrameHeight(height: (searchBarButton?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
        searchTypeAheadTableView?.changeFrameHeight(height: (searchTypeAheadTableView?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
        searchResultsHeaderView?.changeFrameHeight(height: (searchResultsHeaderView?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
        clearSearchTextButton?.changeFrameHeight(height: (clearSearchTextButton?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
        searchTermLabel?.changeFrameHeight(height: (searchTermLabel?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
        searchResultsTableView?.changeFrameHeight(height: (searchResultsTableView?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
        noResultLabel?.changeFrameHeight(height: (noResultLabel?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
        searchResultsHeaderViewBottomSeparator?.changeFrameYAxis(yAxis: (searchResultsHeaderViewBottomSeparator?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
        searchTermLabel?.changeFrameYAxis(yAxis: (searchTermLabel?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
        clearSearchTextButton?.changeFrameYAxis(yAxis: (clearSearchTextButton?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
        
        searchTypeAheadTableView?.frame.origin.y = searchTextField?.frame.maxY ?? (searchTypeAheadTableView?.frame.origin.y)! + navBarPadding
    }
    
    
    //MARK: methods to create layout dict
    func createSearchTextFieldDictLayout() {
        
        let height:Float = 34
        let layoutObject1 = LayoutObject()
        
        let leftMarginPercentiPhone:Float = 2.67
        let rightMarginPercentiPhone:Float = 22.4
        let topMarginPercentiPhone:Float = 1.5
        
        layoutObject1.leftMargin = leftMarginPercentiPhone
        layoutObject1.rightMargin = rightMarginPercentiPhone
        layoutObject1.topMargin = topMarginPercentiPhone
        layoutObject1.height = height
        
        layoutDictSearchTextField["iPhone"] = layoutObject1
        
        let leftMarginPercentiPadPortrait:Float = 26.43
        let rightMarginPercentiPadPortrait:Float = 36.98
        let topMarginPercentiPadPortrait:Float = 18.45
        
        let layoutObject2 = LayoutObject()
        layoutObject2.leftMargin = leftMarginPercentiPadPortrait
        layoutObject2.rightMargin = rightMarginPercentiPadPortrait
        layoutObject2.topMargin = topMarginPercentiPadPortrait
        layoutObject2.height = height
        
        layoutDictSearchTextField["iPadPortrait"] = layoutObject2
        
        let layoutObject3 = LayoutObject()
        
        let leftMarginPercentiPadLandscape:Float = 26.43
        let rightMarginPercentiPadLandscape:Float = 36.98
        let topMarginPercentiPadLandscape:Float = 24.60
        
        layoutObject3.leftMargin = leftMarginPercentiPadLandscape
        layoutObject3.rightMargin = rightMarginPercentiPadLandscape
        layoutObject3.topMargin = topMarginPercentiPadLandscape
        layoutObject3.height = height
        
        layoutDictSearchTextField["iPadLandscape"] = layoutObject3
    }
    
    func createSearchBarButtonDictLayout() {
        
        let height:Float = 34
        let layoutObject1 = LayoutObject()
        let layoutObject2 = LayoutObject()
        let layoutObject3 = LayoutObject()
        
        let leftMarginPercentiPhone:Float = 77.6
        let rightMarginPercentiPhone:Float = 2.67
        let topMarginPercentiPhone:Float = 1.5
        
        layoutObject1.leftMargin = leftMarginPercentiPhone
        layoutObject1.rightMargin = rightMarginPercentiPhone
        layoutObject1.topMargin = topMarginPercentiPhone
        layoutObject1.height = height
        
        layoutDictSearchBarButton["iPhone"] = layoutObject1
        
        let leftMarginPercentiPadPortrait:Float = 63.02
        let rightMarginPercentiPadPortrait:Float = 26.43
        let topMarginPercentiPadPortrait:Float = 18.45
        
        layoutObject2.leftMargin = leftMarginPercentiPadPortrait
        layoutObject2.rightMargin = rightMarginPercentiPadPortrait
        layoutObject2.topMargin = topMarginPercentiPadPortrait
        layoutObject2.height = height
        
        layoutDictSearchBarButton["iPadPortrait"] = layoutObject2
        
        let leftMarginPercentiPadLandscape:Float = 63.02
        let rightMarginPercentiPadLandscape:Float = 26.43
        let topMarginPercentiPadLandscape:Float = 24.60
        
        layoutObject3.leftMargin = leftMarginPercentiPadLandscape
        layoutObject3.rightMargin = rightMarginPercentiPadLandscape
        layoutObject3.topMargin = topMarginPercentiPadLandscape
        layoutObject3.height = height
        
        layoutDictSearchBarButton["iPadLandscape"] = layoutObject3
    }
    
    func createSearchResultsHeaderViewDictLayout() {
        
        let height:Float = 56
        let layoutObject1 = LayoutObject()
        let layoutObject2 = LayoutObject()
        let layoutObject3 = LayoutObject()
        
        let leftMarginPercentiPhone:Float = 0
        let rightMarginPercentiPhone:Float = 0
        let topMarginPercentiPhone:Float = 0
        
        layoutObject1.leftMargin = leftMarginPercentiPhone
        layoutObject1.rightMargin = rightMarginPercentiPhone
        layoutObject1.topMargin = topMarginPercentiPhone
        layoutObject1.height = height
        
        layoutDictSearchResultsHeaderView["iPhone"] = layoutObject1
        
        let leftMarginPercentiPadPortrait:Float = 0
        let rightMarginPercentiPadPortrait:Float = 0
        let topMarginPercentiPadPortrait:Float = 0
        
        layoutObject2.leftMargin = leftMarginPercentiPadPortrait
        layoutObject2.rightMargin = rightMarginPercentiPadPortrait
        layoutObject2.topMargin = topMarginPercentiPadPortrait
        layoutObject2.height = height
        
        layoutDictSearchResultsHeaderView["iPadPortrait"] = layoutObject2
        
        let leftMarginPercentiPadLandscape:Float = 0
        let rightMarginPercentiPadLandscape:Float = 0
        let topMarginPercentiPadLandscape:Float = 0
        
        layoutObject3.leftMargin = leftMarginPercentiPadLandscape
        layoutObject3.rightMargin = rightMarginPercentiPadLandscape
        layoutObject3.topMargin = topMarginPercentiPadLandscape
        layoutObject3.height = height
        
        layoutDictSearchResultsHeaderView["iPadLandscape"] = layoutObject3
    }
    
    func createClearSearchResultsDictLayout() {
        
        let height:Float = 34
        let layoutObject1 = LayoutObject()
        let layoutObject2 = LayoutObject()
        let layoutObject3 = LayoutObject()
        
        let leftMarginPercentiPhone:Float = 2.67
        let rightMarginPercentiPhone:Float = 73.33
        let topMarginPercentiPhone:Float = 19.64
        
        layoutObject1.leftMargin = leftMarginPercentiPhone
        layoutObject1.rightMargin = rightMarginPercentiPhone
        layoutObject1.topMargin = topMarginPercentiPhone
        layoutObject1.height = height
        
        layoutDictClearSearchResults["iPhone"] = layoutObject1
        
        let leftMarginPercentiPadPortrait:Float = 1.30
        let rightMarginPercentiPadPortrait:Float = 86.98
        let topMarginPercentiPadPortrait:Float = 19.64
        
        layoutObject2.leftMargin = leftMarginPercentiPadPortrait
        layoutObject2.rightMargin = rightMarginPercentiPadPortrait
        layoutObject2.topMargin = topMarginPercentiPadPortrait
        layoutObject2.height = height
        
        layoutDictClearSearchResults["iPadPortrait"] = layoutObject2
        
        let leftMarginPercentiPadLandscape:Float = 0.98
        let rightMarginPercentiPadLandscape:Float = 90.23
        let topMarginPercentiPadLandscape:Float = 19.64
        
        layoutObject3.leftMargin = leftMarginPercentiPadLandscape
        layoutObject3.rightMargin = rightMarginPercentiPadLandscape
        layoutObject3.topMargin = topMarginPercentiPadLandscape
        layoutObject3.height = height
        
        layoutDictClearSearchResults["iPadLandscape"] = layoutObject3
    }
    
    func createSearchTextDictLayout() {
        
        let height:Float = 17
        let layoutObject1 = LayoutObject()
        let layoutObject2 = LayoutObject()
        let layoutObject3 = LayoutObject()
        
        let leftMarginPercentiPhone:Float = 29.33
        let rightMarginPercentiPhone:Float = 2.67
        let topMarginPercentiPhone:Float = 33.93
        
        layoutObject1.leftMargin = leftMarginPercentiPhone
        layoutObject1.rightMargin = rightMarginPercentiPhone
        layoutObject1.topMargin = topMarginPercentiPhone
        layoutObject1.height = height
        
        layoutDictSearchText["iPhone"] = layoutObject1
        
        let leftMarginPercentiPadPortrait:Float = 14.32
        let rightMarginPercentiPadPortrait:Float = 0.98
        let topMarginPercentiPadPortrait:Float = 33.93
        
        layoutObject2.leftMargin = leftMarginPercentiPadPortrait
        layoutObject2.rightMargin = rightMarginPercentiPadPortrait
        layoutObject2.topMargin = topMarginPercentiPadPortrait
        layoutObject2.height = height
        
        layoutDictSearchText["iPadPortrait"] = layoutObject2
        
        let leftMarginPercentiPadLandscape:Float = 10.74
        let rightMarginPercentiPadLandscape:Float = 0.98
        let topMarginPercentiPadLandscape:Float = 33.93
        
        layoutObject3.leftMargin = leftMarginPercentiPadLandscape
        layoutObject3.rightMargin = rightMarginPercentiPadLandscape
        layoutObject3.topMargin = topMarginPercentiPadLandscape
        layoutObject3.height = height
        
        layoutDictSearchText["iPadLandscape"] = layoutObject3
    }
    
    
    func createSearchResultsHeaderViewTopSeparatorDictLayout() {
        
        let height:Float = 1
        let layoutObject1 = LayoutObject()
        let layoutObject2 = LayoutObject()
        let layoutObject3 = LayoutObject()
        
        let leftMarginPercentiPhone:Float = 0
        let rightMarginPercentiPhone:Float = 0
        let topMarginPercentiPhone:Float = 0
        
        layoutObject1.leftMargin = leftMarginPercentiPhone
        layoutObject1.rightMargin = rightMarginPercentiPhone
        layoutObject1.topMargin = topMarginPercentiPhone
        layoutObject1.height = height
        
        layoutDictSearchResultsHeaderViewTopSeparator["iPhone"] = layoutObject1
        
        let leftMarginPercentiPadPortrait:Float = 0
        let rightMarginPercentiPadPortrait:Float = 0
        let topMarginPercentiPadPortrait:Float = 0
        
        layoutObject2.leftMargin = leftMarginPercentiPadPortrait
        layoutObject2.rightMargin = rightMarginPercentiPadPortrait
        layoutObject2.topMargin = topMarginPercentiPadPortrait
        layoutObject2.height = height
        
        layoutDictSearchResultsHeaderViewTopSeparator["iPadPortrait"] = layoutObject2
        
        let leftMarginPercentiPadLandscape:Float = 0
        let rightMarginPercentiPadLandscape:Float = 0
        let topMarginPercentiPadLandscape:Float = 0
        
        layoutObject3.leftMargin = leftMarginPercentiPadLandscape
        layoutObject3.rightMargin = rightMarginPercentiPadLandscape
        layoutObject3.topMargin = topMarginPercentiPadLandscape
        layoutObject3.height = height
        
        layoutDictSearchResultsHeaderViewTopSeparator["iPadLandscape"] = layoutObject3
    }

    
    func createSearchResultsHeaderViewBottomSeparatorDictLayout() {
        
        let height:Float = 1
        let layoutObject1 = LayoutObject()
        let layoutObject2 = LayoutObject()
        let layoutObject3 = LayoutObject()
        
        let leftMarginPercentiPhone:Float = 0
        let rightMarginPercentiPhone:Float = 0
        let bottomMarginPercentiPhone:Float = 0
        
        layoutObject1.leftMargin = leftMarginPercentiPhone
        layoutObject1.rightMargin = rightMarginPercentiPhone
        layoutObject1.bottomMargin = bottomMarginPercentiPhone
        layoutObject1.height = height
        
        layoutDictSearchResultsHeaderViewBottomSeparator["iPhone"] = layoutObject1
        
        let leftMarginPercentiPadPortrait:Float = 0
        let rightMarginPercentiPadPortrait:Float = 0
        let bottomMarginPercentiPadPortrait:Float = 0
        
        layoutObject2.leftMargin = leftMarginPercentiPadPortrait
        layoutObject2.rightMargin = rightMarginPercentiPadPortrait
        layoutObject2.bottomMargin = bottomMarginPercentiPadPortrait
        layoutObject2.height = height
        
        layoutDictSearchResultsHeaderViewBottomSeparator["iPadPortrait"] = layoutObject2
        
        let leftMarginPercentiPadLandscape:Float = 0
        let rightMarginPercentiPadLandscape:Float = 0
        let bottomMarginPercentiPadLandscape:Float = 0
        
        layoutObject3.leftMargin = leftMarginPercentiPadLandscape
        layoutObject3.rightMargin = rightMarginPercentiPadLandscape
        layoutObject3.bottomMargin = bottomMarginPercentiPadLandscape
        layoutObject3.height = height
        
        layoutDictSearchResultsHeaderViewBottomSeparator["iPadLandscape"] = layoutObject3
    }

    
    func createSearchTypeAheadTableViewDictLayout() {
        
        let height:Float = 238
        let layoutObject1 = LayoutObject()
        let layoutObject2 = LayoutObject()
        let layoutObject3 = LayoutObject()
        
        let leftMarginPercentiPhone:Float = 2.67
        let rightMarginPercentiPhone:Float = 2.67
        let topMarginPercentiPhone:Float = 6.59
        
        layoutObject1.leftMargin = leftMarginPercentiPhone
        layoutObject1.rightMargin = rightMarginPercentiPhone
        layoutObject1.topMargin = topMarginPercentiPhone
        layoutObject1.height = height
        
        layoutDictSearchTypeAheadTableView["iPhone"] = layoutObject1
        
        let leftMarginPercentiPadPortrait:Float = 26.43
        let rightMarginPercentiPadPortrait:Float = 26.43
        let topMarginPercentiPadPortrait:Float = 22.0
        
        layoutObject2.leftMargin = leftMarginPercentiPadPortrait
        layoutObject2.rightMargin = rightMarginPercentiPadPortrait
        layoutObject2.topMargin = topMarginPercentiPadPortrait
        layoutObject2.height = height
        
        layoutDictSearchTypeAheadTableView["iPadPortrait"] = layoutObject2
        
        let leftMarginPercentiPadLandscape:Float = 26.43
        let rightMarginPercentiPadLandscape:Float = 26.43
        let topMarginPercentiPadLandscape:Float = 29.43
        
        layoutObject3.leftMargin = leftMarginPercentiPadLandscape
        layoutObject3.rightMargin = rightMarginPercentiPadLandscape
        layoutObject3.topMargin = topMarginPercentiPadLandscape
        layoutObject3.height = height
        
        layoutDictSearchTypeAheadTableView["iPadLandscape"] = layoutObject3
    }
    
    func createSearchResultsTableViewDictLayout() {
        
        let layoutObject1 = LayoutObject()
        let layoutObject2 = LayoutObject()
        let layoutObject3 = LayoutObject()
        
        let leftMarginPercentiPhone:Float = 0
        let rightMarginPercentiPhone:Float = 0
        let topMarginPercentiPhone:Float = 9.5
        let bottomMarginPercentiPhone:Float = 0
        
        layoutObject1.leftMargin = leftMarginPercentiPhone
        layoutObject1.rightMargin = rightMarginPercentiPhone
        layoutObject1.topMargin = topMarginPercentiPhone
        layoutObject1.bottomMargin = bottomMarginPercentiPhone
        
        layoutDictSearchResultsTableView["iPhone"] = layoutObject1
        
        let leftMarginPercentiPadPortrait:Float = 0
        let rightMarginPercentiPadPortrait:Float = 0
        let topMarginPercentiPadPortrait:Float = 6.47
        let bottomMarginPercentiPadPortrait:Float = 0
        
        layoutObject2.leftMargin = leftMarginPercentiPadPortrait
        layoutObject2.rightMargin = rightMarginPercentiPadPortrait
        layoutObject2.topMargin = topMarginPercentiPadPortrait
        layoutObject2.bottomMargin = bottomMarginPercentiPadPortrait
        
        layoutDictSearchResultsTableView["iPadPortrait"] = layoutObject2
        
        let leftMarginPercentiPadLandscape:Float = 0
        let rightMarginPercentiPadLandscape:Float = 0
        let topMarginPercentiPadLandscape:Float = 8.29
        let bottomMarginPercentiPadLandscape:Float = 0
        
        layoutObject3.leftMargin = leftMarginPercentiPadLandscape
        layoutObject3.rightMargin = rightMarginPercentiPadLandscape
        layoutObject3.topMargin = topMarginPercentiPadLandscape
        layoutObject3.bottomMargin = bottomMarginPercentiPadLandscape
        
        layoutDictSearchResultsTableView["iPadLandscape"] = layoutObject3
    }
    
    func createNoResultLabelDictLayout() {
        
        let layoutObject1 = LayoutObject()
        let layoutObject2 = LayoutObject()
        let layoutObject3 = LayoutObject()
        
        let height:Float = 42
        
        let leftMarginPercentiPhone:Float = 0
        let rightMarginPercentiPhone:Float = 0
        let topMarginPercentiPhone:Float = 27.59
        
        layoutObject1.leftMargin = leftMarginPercentiPhone
        layoutObject1.rightMargin = rightMarginPercentiPhone
        layoutObject1.topMargin = topMarginPercentiPhone
        layoutObject1.height = height
        
        layoutDictNoResultLabel["iPhone"] = layoutObject1
        
        let leftMarginPercentiPadPortrait:Float = 0
        let rightMarginPercentiPadPortrait:Float = 0
        let topMarginPercentiPadPortrait:Float = 33.4
        
        layoutObject2.leftMargin = leftMarginPercentiPadPortrait
        layoutObject2.rightMargin = rightMarginPercentiPadPortrait
        layoutObject2.topMargin = topMarginPercentiPadPortrait
        layoutObject2.height = height
        
        layoutDictNoResultLabel["iPadPortrait"] = layoutObject2
        
        let leftMarginPercentiPadLandscape:Float = 0
        let rightMarginPercentiPadLandscape:Float = 0
        let topMarginPercentiPadLandscape:Float = 44.53
        
        layoutObject3.leftMargin = leftMarginPercentiPadLandscape
        layoutObject3.rightMargin = rightMarginPercentiPadLandscape
        layoutObject3.topMargin = topMarginPercentiPadLandscape
        layoutObject3.height = height
        
        layoutDictNoResultLabel["iPadLandscape"] = layoutObject3
    }

}
