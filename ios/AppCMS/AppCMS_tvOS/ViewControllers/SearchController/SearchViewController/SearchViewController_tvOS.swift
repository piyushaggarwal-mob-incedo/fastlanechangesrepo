//
//  SearchViewController_tvOS.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 07/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

private let PREVIOUS_SEARCH_TERMS = "PREVIOUS_SERACH_TERMS"
private let LEFT_PADDING_TABLE = 70.0 as CGFloat

class SearchViewController_tvOS: BaseViewController, UISearchControllerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, SearchHistoryViewDelegate, CollectionGridViewDelegate {
    ///
    var typeAheadSearchResultsArray:Array<AnyObject> = []
    weak var mainSearchController : UISearchController?
    weak var containerVC : UISearchContainerViewController?
    var noResultLabel : UILabel?
    var modulesListArray:Array<Any> = []
    var moduleObject:SFModuleObject?
    var cellModuleDict:Dictionary<String, AnyObject> = [:]
    var tableView:UITableView?
    var didChangeFocusFromSearchArea : Bool? = false
    var lastSearchedString : String?
    var lastSearchStateTuple : (didChangeFocusFromSearchArea: Bool?, lastSearchedString: String?)
    var previousSearchHistoryView : SearchHistoryView_tvOS?
    var previousSearchArray : Array<String>?
    var networkUnavailableAlert:UIAlertController?
    var navController: UINavigationController?
    private var footerView : SFFooterView?
    private  var acitivityIndicator : UIActivityIndicatorView?
  
    deinit {
        ///
        resetSearchToInitialState()
        ///Remove observers
//        NotificationCenter.default.removeObserver(self, name: Constants.kToggleMenuBarNotification, object: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        
        ///Register notification
//        NotificationCenter.default.addObserver(self, selector: #selector(adjustFooterFrame(_:)), name: Constants.kToggleMenuBarNotification, object: nil)

        ///Create module list array
        createModuleListForSearchResultsTable()
        
        ///Create tableview to display search result.
        self.createTableView()
        
        ///createNoResultLabel
        self.createNoResultLabel()
    }
    

    @objc private func adjustFooterFrame (_ notification: NSNotification) {
        let userInfo = notification.userInfo
        if (userInfo?["value"] as! Bool) {
            UIView.animate(withDuration: 0.2, animations: {
                self.footerView?.changeFrameYAxis(yAxis: 360)
            }, completion: { (completed) in
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.footerView?.changeFrameYAxis(yAxis: 497)
            }, completion: { (completed) in
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*Setting search bar delegate*/
        self.mainSearchController?.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        footerView?.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Search bar delegate
    // called when text changes (including clear)
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        
        let searchText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (searchText?.characters.count)! > 2 {
            if didChangeFocusFromSearchArea! {
                if searchText != nil && !(searchText?.isEmpty)! && lastSearchedString != searchText! {
                    refreshPreviousSearchView()
                }
            }
            self.fetchTypeAheadSearchResults()
        }
        else
        {
            resetSearchToInitialState()
        }
        didChangeFocusFromSearchArea = false
    }
    
    
    //MARK: - resetSearchToInitialState
    func resetSearchToInitialState()
    {
        self.cellModuleDict.removeAll()
        self.moduleObject = nil
        self.typeAheadSearchResultsArray.removeAll()
        self.noResultLabel?.isHidden = true
        //self.tableView?.isHidden = false
        self.tableView?.reloadData()
    }
    
    //MARK: Method to create Module list for Search result table
    private func createModuleListForSearchResultsTable() {
        
        var filePath:String = ""
        if AppConfiguration.sharedAppConfiguration.templateType == Constants.kTemplateTypeSports {
            filePath = (Bundle.main.resourcePath?.appending("/SearchPageModule_Sports_tvOS.json"))!
        } else {
            filePath = (Bundle.main.resourcePath?.appending("/SearchPageModule_Entertainment_tvOS.json"))!
        }
        let jsonData:Data = FileManager.default.contents(atPath: filePath)!
        
        let responseJson:Array<Dictionary<String, AnyObject>>? = try! JSONSerialization.jsonObject(with:jsonData) as? Array<Dictionary<String, AnyObject>>
        let moduleParser = ModuleUIParser()
        modulesListArray = moduleParser.parseModuleConfigurationJson(modulesConfigurationArray: responseJson!) as Array<AnyObject>
        
    }
    
    
    private func createPreviousSearchModule() -> SearchHistoryView_tvOS
    {
        //Create a Search history module
        if previousSearchHistoryView == nil
        {
            previousSearchHistoryView = SearchHistoryView_tvOS.init()
            let viewFrame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 60)
            previousSearchHistoryView?.view.frame = viewFrame//CGRect(x: 0, y: 0, width: self.view.frame.width, height: 140)
            previousSearchHistoryView?.searchTextArray = fetchArrayOfPreviousSearchs()
            previousSearchHistoryView?.setupSubView()
            previousSearchHistoryView?.delegate = self
            if fetchArrayOfPreviousSearchs() == nil {
                previousSearchHistoryView?.view.isHidden = true
            }
        }
        
        return previousSearchHistoryView!
        
    }
    
    private func refresPreviousSearchDataWithArray()
    {
        if previousSearchHistoryView != nil {
            previousSearchHistoryView?.refreshCollectionView()
        }
    }
    
    override func loadPageData() {
        super.loadPageData()
        let searchText = self.mainSearchController?.searchBar.text
        if (searchText?.characters.count)! > 2 {
            if isDeviceConnectedToInternet() == true{
                fetchTypeAheadSearchResults()
            }
        }
        else{
            resetSearchToInitialState()
        }
    }
    
    //MARK: Api to fetch search typeahead results
    func fetchTypeAheadSearchResults() {
        
        if isDeviceConnectedToInternet() == false {
            failureCaseReceivedCheckAndShowAlert(alertTitle: nil, alertMessage: nil)
        }
        else
        {
            //searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if var searchStr = self.mainSearchController?.searchBar.text
            {
                self.addActivityIndicator()
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    let searchEncodedTerm = searchStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                    DataManger.sharedInstance.fetchTypeAheadSearchResults(shouldUseCacheUrl: false, apiEndPoint: "/search/v1?site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&searchTerm=\(searchEncodedTerm!)", searchResults: { [weak self] (typeAheadSearchResults) in
                        
                        DispatchQueue.main.async {
                            
                            searchStr = (self?.mainSearchController?.searchBar.text)!
                            print(typeAheadSearchResults ?? "")
                            if !searchStr.isEmpty && searchStr.characters.count > 2
                            {
                                self?.removeActivityIndicator()
                                if (typeAheadSearchResults != nil &&  (typeAheadSearchResults?.moduleData?.count)! > 0){
                                    self?.moduleObject = typeAheadSearchResults!
                                    self?.cellModuleDict.removeAll()
                                    if (self?.typeAheadSearchResultsArray.count)! > 0 {
                                        self?.typeAheadSearchResultsArray.removeAll()
                                    }
                                    self?.tableView?.isUserInteractionEnabled = true
                                    self?.noResultLabel?.isHidden = true
                                    self?.typeAheadSearchResultsArray = (typeAheadSearchResults?.moduleData)!
                                    self?.tableView?.reloadData()
                                }
                                else
                                {
                                    self?.resetSearchToInitialState()
                                    self?.noResultLabel?.isHidden = false
//                                    self?.noResultLabel?.text = "NO RESULTS FOR \"\(searchStr.trimmingCharacters(in: .whitespacesAndNewlines))\""
                                    self?.noResultLabel?.text = "NO RESULTS FOR \"\(searchStr)\""
                                }
                            }
                            else
                            {
                                self?.removeActivityIndicator()
                                self?.noResultLabel?.isHidden = true
                                self?.resetSearchToInitialState()
                            }
                        }
                    })
                }
            }

        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased(){
            return nil
        }
        else{
            if previousSearchHistoryView == nil
            {
                return createPreviousSearchModule().view
                
            }
            else
            {
                previousSearchHistoryView?.searchTextArray = fetchArrayOfPreviousSearchs()
                previousSearchHistoryView?.refreshCollectionView()
                return previousSearchHistoryView?.view
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased(){
            return 10.0
        }
        return 80.0
    }
    
    //MARK: method to create no result label
    func createNoResultLabel() {
        
        //createNoResultLabelDictLayout()
        //let layoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictNoResultLabel)
        noResultLabel = UILabel.init(frame: CGRect(x: 700, y: 100, width: 500, height: 50)) //UILabel(frame: Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: relativeViewFrame!))
        var fontFamily:String?
        if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
            fontFamily = _fontFamily
        }
        if fontFamily == nil {
            fontFamily = "OpenSans"
        }
        noResultLabel?.font = UIFont(name: fontFamily!, size: 28)
        //noResultLabel?.frame.origin.y = (noResultLabel?.frame.origin.y)! + navBarPadding
        noResultLabel?.textAlignment = .center
        noResultLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        
        self.view.addSubview(noResultLabel!)
        noResultLabel?.isHidden = true
    }
    
    
    //MARK: Method to create table view
    func createTableView() {
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), style: .plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.backgroundView = nil
        tableView?.backgroundColor = UIColor.clear
        tableView?.showsVerticalScrollIndicator = false
        if #available(tvOS 11.0, *) {
            self.tableView?.contentInsetAdjustmentBehavior = .never
            self.tableView?.contentInset = UIEdgeInsetsMake(0, -90, 0, 0)
        }
        tableView?.clipsToBounds = true
        tableView?.register(SFTrayModuleCell.self, forCellReuseIdentifier: "trayModuleCell")
        self.tableView?.mask = nil;
        self.view.addSubview(tableView!)
        //        self.tableView?.isHidden = true
    }
    
    //MARK:- UITableViewDataSource
    
    
     func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.modulesListArray.count > 0 //&& self.moduleObject != nil
        {
            return self.modulesListArray.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight:CGFloat = 530.0
        
        let module:Any = modulesListArray[indexPath.row] as Any
        
        if module is SFTrayObject {
            let trayObject:SFTrayObject? = module as? SFTrayObject
            rowHeight = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject!).height ?? 530)
        }
        
        return rowHeight
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier:String = "gridCell"
        var cell = cellModuleDict["\(String(indexPath.row))"] as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell?.backgroundColor = UIColor.clear
            cell?.contentView.backgroundColor = UIColor.clear
            cell?.selectionStyle = .none
            
            let module:Any = modulesListArray[indexPath.row] as Any
            
            if module is SFTrayObject && self.moduleObject != nil {
                addCollectionGridToTable(cell: cell!, pageModuleObject: self.moduleObject!)
                cellModuleDict["\(String(indexPath.row))"] = cell!
            }
        }
        return cell!
        
    }
    
    //MARK: - UITableViewDelegate
    
    
    //MARK: Method to add grids to table view cell
    func addCollectionGridToTable(cell:UITableViewCell, pageModuleObject:SFModuleObject) {
       
        let trayObject:SFTrayObject = modulesListArray[0] as! SFTrayObject
        let collectionGridViewController:CollectionGridViewController = CollectionGridViewController(trayObject: trayObject)
        let rowHeight:CGFloat = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject).height ?? 530)
//        let cellFrame:CGRect = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: UIScreen.main.bounds.width - LEFT_PADDING_TABLE, height: rowHeight)
        
        
        let cellFrame:CGRect = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: UIScreen.main.bounds.width, height: rowHeight)

        collectionGridViewController.view.frame = Utility.initialiseViewLayout(viewLayout: Utility.fetchTrayLayoutDetails(trayObject: trayObject), relativeViewFrame: cellFrame)
        collectionGridViewController.relativeViewFrame = collectionGridViewController.view.frame
        collectionGridViewController.delegate = self
        collectionGridViewController.isFromSearch = true
        collectionGridViewController.moduleAPIObject = pageModuleObject
        collectionGridViewController.createSubViews()
        /*Update tray title to search term*/
        updateTrayTitleWithSearchTerm(grid: collectionGridViewController)
        self.addChildViewController(collectionGridViewController)
        cell.addSubview(collectionGridViewController.view)
    }
    
    
    /*Update tray title to search term while typeahead search*/
    private func updateTrayTitleWithSearchTerm(grid : CollectionGridViewController)
    {
        let subViews = grid.view.subviews
        for gridObject in subViews  {
            if (gridObject as? UILabel) != nil {
                if let searcTerm = self.mainSearchController?.searchBar.text
                {
//                    (gridObject as! UILabel).text  = "RESULTS FOR  \"\(searcTerm.trimmingCharacters(in: .whitespacesAndNewlines))\""
                    (gridObject as! UILabel).text  = "RESULTS FOR  \"\(searcTerm)\""
                }
            }
        }
    }


    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    //MARK:Collection Grid Delegates and Carousel Delegate
    func didSelectVideo(gridObject: SFGridObject?) {
        
        var viewControllerPage:Page?
        var filePath:String = ""
        if gridObject?.contentType?.lowercased() == Constants.kShowContentType || gridObject?.contentType?.lowercased() == Constants.kShowsContentType
        {
            filePath = AppSandboxManager.getpageFilePath(fileName: Utility.getPageIdFromPagesArray(pageName: "Show Page") ?? "")
        }
        else
        {
            filePath = AppSandboxManager.getpageFilePath(fileName: Utility.getPageIdFromPagesArray(pageName: "Video Page") ?? "")
        }
        
        //let filePath:String = AppSandboxManager.getpageFilePath(fileName: Utility.getPageIdFromPagesArray(pageName: "Video Page") ?? "")
        if !filePath.isEmpty {
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                
                viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
            }
        }
        
        if viewControllerPage != nil {
            
            //Fire Notification to disable the navigation controller.
            let userInfo = [ "value" : false ]
            NotificationCenter.default.post(name: Constants.kToggleMenuBarInteractionNotification, object: nil , userInfo : userInfo )
            var videoDetailViewController:ModuleContainerViewController_tvOS!
            if gridObject?.contentType?.lowercased() == Constants.kShowContentType || gridObject?.contentType?.lowercased() == Constants.kShowsContentType
            {
                videoDetailViewController = ModuleContainerViewController_tvOS.init(pageObject: viewControllerPage!, pageDisplayName: "show_detail")
            }
            else
            {
                videoDetailViewController = ModuleContainerViewController_tvOS.init(pageObject: viewControllerPage!, pageDisplayName: "video_detail")
            }

            //let videoDetailViewController:ModuleContainerViewController_tvOS = ModuleContainerViewController_tvOS.init(pageObject: viewControllerPage!, pageDisplayName: "video_detail")
            videoDetailViewController.contentId = gridObject?.contentId ?? ""
            videoDetailViewController.pagePath = gridObject?.gridPermaLink ?? ""
            videoDetailViewController.viewModel.pageOpenAction = .videoClickAction
            videoDetailViewController.view.changeFrameYAxis(yAxis: 20.0)
            videoDetailViewController.addBackgroundImage = true
            videoDetailViewController.gridObject = gridObject
            videoDetailViewController.view.changeFrameHeight(height: videoDetailViewController.view.frame.height - 20.0)
            ////containerVC?.navigationController?.pushViewController(videoDetailViewController, animated: true)
            ////self.navigationController?.pushViewController(videoDetailViewController, animated: true)
            self.navController?.pushViewController(videoDetailViewController, animated: true)
        }
    }
    
    func videoSelectedAtIndexPath(gridObject: SFGridObject) {
        playVideoWithGridObjectClick(gridObject)
    }
    
    private func playVideoWithGridObjectClick(_ gridObject: SFGridObject) {
        let userInfo = [ "value" : false ]
        NotificationCenter.default.post(name: Constants.kToggleMenuBarInteractionNotification, object: nil , userInfo : userInfo )
        
        let videoObject: VideoObject = VideoObject.init(gridObject: gridObject)
        
        let playerControllerVC =  PlayerViewController_tvOS.init(videoObject: videoObject)
        self.navController?.pushViewController(playerControllerVC, animated: true)
    }
    
    //MARK: UIFocus Methods
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if (context.nextFocusedView is SFCollectionGridCell_tvOS) || (context.nextFocusedView is UICollectionViewCell)
        {
            lastSearchedString = self.mainSearchController?.searchBar.text
            didChangeFocusFromSearchArea = true
            if let tempStr = lastSearchedString
            {
                if !tempStr.isEmpty
                {
                    saveSearchTextToUserDefaults(searchString: tempStr)
                }
            }
        }
    }
    
    func refreshPreviousSearchView() {
        if previousSearchHistoryView != nil
        {
            previousSearchHistoryView?.searchTextArray = fetchArrayOfPreviousSearchs()
            previousSearchHistoryView?.view.isHidden = false
            previousSearchHistoryView?.refreshCollectionView()
        }
    }
    
    //MARK: - SearchHistory Helper
    /*saveSearchTextToUSerDefaults saves latest search to 0th index in array */
    func saveSearchTextToUserDefaults(searchString : String) -> Void {
        previousSearchArray = fetchArrayOfPreviousSearchs()
        if previousSearchArray == nil {
            previousSearchArray = Array()
        }
        if !(previousSearchArray?.contains((self.mainSearchController?.searchBar.text)!))! {
            if (previousSearchArray?.count)! >= 3 {
                previousSearchArray?.remove(at: (previousSearchArray?.count)!-1)
            }
            previousSearchArray?.insert(searchString, at: 0)
            UserDefaults.standard.setValue(previousSearchArray, forKey: PREVIOUS_SEARCH_TERMS)
            UserDefaults.standard.synchronize()
        }
    }
    
    
    /*fetchArrayOfPreviousSearchs fetch  previous search terms from user defaults*/
    private func fetchArrayOfPreviousSearchs() -> Array<String>? {
        return UserDefaults.standard.object(forKey: PREVIOUS_SEARCH_TERMS) as? Array<String>

    }
    
    //MARK: - PreviousSearch Module Delegate
    func searchTextTapped(searchText: String?) {
        if !(searchText?.isEmpty)!{
            self.mainSearchController?.searchBar.text = searchText
            self.fetchTypeAheadSearchResults()
        }
    }
    
    /*clearPreviousSearchHistory delete all previous search term history and update Userdefaults*/
    func clearPreviousSearchHistory()  {
        UserDefaults.standard.removeObject(forKey: PREVIOUS_SEARCH_TERMS)
        UserDefaults.standard.synchronize()
        previousSearchHistoryView?.view.isHidden = true
        previousSearchArray?.removeAll()
        previousSearchHistoryView?.refreshCollectionView()
        
        if typeAheadSearchResultsArray.isEmpty   {
            tableView?.isUserInteractionEnabled = false
        }
    }

    //MARK: - Footer View
    func addFooterViewToTheView() {

        let margin:CGFloat = 0
        if footerView == nil {
            footerView = SFFooterView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - (200 + margin), width: self.view.bounds.width, height: 200))
            self.view.addSubview(footerView!)
        } else {
            footerView?.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - (200 + margin), width: self.view.bounds.width, height: 200)
        }
        UIApplication.shared.keyWindow!.addSubview(footerView!)
    }
    
    func hideFooterView() {
        footerView?.removeFromSuperview()
    }
    
    //MARK: - Activity Indicator Methods
    private func addActivityIndicator()
    {
        //If acitivityIndicator is not created then create acitivityIndicator object
        if (self.acitivityIndicator == nil)
        {
            self.acitivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            self.acitivityIndicator!.center = self.view.center
        }
        //Remove acitivityIndicator before adding it.
        removeActivityIndicator()
        
        //Add acitivityIndicator and start animating it.
        self.view.addSubview(self.acitivityIndicator!)
        self.acitivityIndicator!.startAnimating();
    }
    
    private func removeActivityIndicator()
    {
        if let tempActivityIndicatorView = self.acitivityIndicator
        {
            tempActivityIndicatorView.removeFromSuperview()
            tempActivityIndicatorView.stopAnimating();
        }
    }
}
