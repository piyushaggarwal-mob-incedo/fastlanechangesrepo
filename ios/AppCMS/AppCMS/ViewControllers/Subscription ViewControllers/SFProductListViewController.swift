//
//  SFProductListViewController.swift
//  AppCMS
//
//  Created by Rajni Pathak on 05/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import AppsFlyerLib
import AdSupport
import Firebase
enum AlertAction {
    case FetchProducts
    case GetUserStatus
}

class SFProductListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PlanCollectionGridViewDelegate, SFPlanAdditionalTextCellDelegate {
    
    var modulesListArray:Array<AnyObject> = []
    var completionHandlerCopy : ((Bool) -> Void)? = nil

    var planPrice:String?
    var subscriptionPlans:Array<AnyObject> = []
    var selectedPlanPaymentModelObject:PaymentModel?
    var priceCurrency:String?
    var fetchRequestInProcess:Bool = false
    var viewControllerPage:Page?
    var progressIndicator:MBProgressHUD?
    var pageAPIObject:PageAPIObject?
    var subscriptionTable:UITableView?
    var cellModuleDict:Dictionary<String, AnyObject> = [:]
    var modulesListDict:Dictionary<String, Any> = [:]
    var shouldUserBeNavigatedToHomePage:Bool?
    var alertActionType:AlertAction?
    var isPerformingRestorePurchase:Bool = false
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        
        fetchProductListPageUI()
        createNavigationBar()
        createTableView()

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseCompletionNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishRestorePurchase), name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseCompletionNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFPurchaseFailedNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFiTunesConnectErrorNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed), name: NSNotification.Name(rawValue: Constants.kSFPurchaseFailedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(iTunesConnectErrorNotification), name: NSNotification.Name(rawValue: Constants.kSFiTunesConnectErrorNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseFailedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restorePurchaseFailed), name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseFailedNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFPurchaseCompletionNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processPurchaseCompletionCallbackData(notification:)), name: NSNotification.Name(rawValue: Constants.kSFPurchaseCompletionNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFPurchaseInProcessNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProgressPaymentProcess), name: NSNotification.Name(rawValue: Constants.kSFPurchaseInProcessNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kShowAlertNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert(notification:)), name: NSNotification.Name(rawValue: Constants.kShowAlertNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processRestorePurchaseCompetionCallbackData(notification:)), name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreWithZeroTransaction), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processRestoreWithZeroTransactionCallbackData(notification:)), name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreWithZeroTransaction), object: nil)
        
        fetchRequestInProcess = true
        self.getproductsFromServer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)

        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            FIRAnalytics.logEvent(withName: Constants.kGTMViewPlansPageEvent, parameters: nil)
        }
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "View Plans Screen")
        tracker.allowIDFACollection = true
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            FIRAnalytics.setScreenName("View Plans Screen", screenClass: nil)
        }

        if self.pageAPIObject == nil && fetchRequestInProcess == false{
            
            self.getproductsFromServer()
        }
    }
    
    
    //MARK Method to create navigation bar
   private func createNavigationBar() {
        
        self.navigationController?.navigationBar.barTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        self.navigationItem.titleView = Utility.createNavigationTitleView(navBarHeight: (self.navigationController?.navigationBar.frame.size.height)!)
        
        createRightNavBarItems()
    }
    
    
    //MARK: Method to create right navigation bar items
    private func createRightNavBarItems() {
        
        self.navigationItem.rightBarButtonItems = nil
        
        let image = UIImage(named: "cancelIcon")
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.sizeToFit()
        
        let cancelButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "cancelIcon.png"))
        
        cancelButton.setImage(cancelButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        cancelButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        
        cancelButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (cancelButtonImageView.image?.size.height)!/2)

        cancelButton.changeFrameYAxis(yAxis: (self.navigationController?.navigationBar.frame.size.height)!/2 - (image?.size.height)!/2)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked(sender:)), for: UIControlEvents.touchUpInside)
        
        let cancelButtonItem = UIBarButtonItem(customView: cancelButton)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -15
        
        self.navigationItem.rightBarButtonItems = [negativeSpacer, cancelButtonItem]
    }
    
    
    func cancelButtonClicked(sender:AnyObject) {
        
        self.dismiss(animated: true, completion: {
            
            if self.completionHandlerCopy != nil {
                
                self.completionHandlerCopy!(false)
            }
        })
    }

    
    //MARK: Method to fetch page layout details
    private func fetchProductListPageUI() -> Void {
        
        guard let pageID:String = Utility.sharedUtility.getPageIdFromPagesArray(pageName: "View Plans") else { return }
        
        let filePath:String = AppSandboxManager.getpageFilePath(fileName: pageID)
        
        if !filePath.isEmpty {
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                
                viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
            }
        }
    }
    
    
    //MARK: Get list of products from server
    private func getproductsFromServer()
    {
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            fetchRequestInProcess = false
            alertActionType = AlertAction.FetchProducts
            showAlertForAlertType(alertType: .AlertTypeNoInternetFound, alertMessage: nil, alertTitle: nil)
        }
        else {
            
            self.showActivityIndicator(loaderText: nil)
            
            var apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")\(viewControllerPage?.pageAPI ?? "/content/pages")?device=ios_phone&site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&path=/viewplans&includeContent=true"

            if let userId = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) {
                
                apiEndPoint.append("&userId=\(userId)")
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                DataManger.sharedInstance.fetchContentForPlansPage(apiEndPoint: apiEndPoint, requestHeaders: nil, pageAPIResponse: { (pageAPIObjectResponse, isSuccess) in
                    
                    DispatchQueue.main.async {
                        
                        self.hideActivityIndicator()
                        self.fetchRequestInProcess = false
                        
                        if pageAPIObjectResponse != nil && pageAPIObjectResponse?.pageModules != nil && isSuccess == true {
                            
                            self.pageAPIObject = pageAPIObjectResponse
                            self.getAnnualPlanPrice()
                            self.modulesListArray.removeAll()
                            self.cellModuleDict.removeAll()
                            self.createPageModuleLayoutList()
                            self.subscriptionTable?.isHidden = false
                            self.subscriptionTable?.reloadData()
                            self.subscriptionTable?.scrollsToTop = true
                        }
                        else {
                            
                            self.alertActionType = AlertAction.FetchProducts
                            self.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived, alertMessage: nil, alertTitle: nil)
                        }
                    }
                })
            }
        }
    }
    
    
    //MARK: Method to fetch annual price with maximum value
    func getAnnualPlanPrice() {
        
        var moduleId:String?
        
        if viewControllerPage?.modules != nil {
            for module:Any in (viewControllerPage?.modules)! {
                
                if module is SFProductListObject {
                    
                    let productListObject:SFProductListObject = module as! SFProductListObject
                    moduleId = productListObject.moduleId
                    break
                }
            }
        }
        
        if moduleId != nil {
            
            let moduleAPIObject:SFModuleObject? = pageAPIObject?.pageModules?["\(moduleId ?? "")"] as? SFModuleObject
            
            if moduleAPIObject?.moduleData != nil {
                
                self.subscriptionPlans = (moduleAPIObject?.moduleData)!
                
                var yearlyPrice:NSNumber?
                
                for moduleData in (moduleAPIObject?.moduleData)! {
                    
                    if moduleData is PaymentModel {
                        
                        let paymentModel = moduleData as! PaymentModel
                        
                        if paymentModel.billingPeriodType == .YEARLY {
                            
                            if paymentModel.recurringPaymentsTotalCurrency != nil {
                                
                                planPrice = Utility.sharedUtility.getSymbolForCurrencyCode(countryCode: (paymentModel.recurringPaymentsTotalCurrency)!)
                            }
                            
                            if yearlyPrice != nil {
                                
                                if (yearlyPrice?.floatValue)! < (paymentModel.recurringPaymentsTotal?.floatValue)! {
                                    
                                    yearlyPrice = paymentModel.recurringPaymentsTotal
                                }
                            }
                            else {
                                
                                yearlyPrice = paymentModel.recurringPaymentsTotal
                            }
                        }
                    }
                }
                
                if yearlyPrice != nil {
                    
                    let numberFormatter:NumberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    numberFormatter.maximumFractionDigits = 10
                    
                    let planOriginalPrice:String? = numberFormatter.string(from: (yearlyPrice)!)
                    
                    if planPrice == nil {
                        
                        if planOriginalPrice != nil {
                            planPrice = planOriginalPrice!
                        }
                    }
                    else {
                        
                        if planOriginalPrice != nil {
                            
                            planPrice = planPrice?.appending("\(planOriginalPrice!)")
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: Method to fetch page module layout list
    private func createPageModuleLayoutList() {
        
        if viewControllerPage?.modules != nil {
            
            for module:Any in (viewControllerPage?.modules)! {
                
                if module is SFProductListObject {
                    
                    let productListObject:SFProductListObject = module as! SFProductListObject
                    
                    if checkIfModuleComingInServerResponse(moduleId: productListObject.moduleId) {
                        
                        modulesListDict["\(productListObject.moduleId!)"] = productListObject
                        modulesListArray.append(productListObject)
                    }
                }
                else if module is SFProductFeatureListObject {
                    
                    let productFeatureListObject:SFProductFeatureListObject = module as! SFProductFeatureListObject
                    
                    if checkIfModuleComingInServerResponse(moduleId: productFeatureListObject.moduleId) {
                        
                        modulesListDict["\(productFeatureListObject.moduleId!)"] = productFeatureListObject
                        modulesListArray.append(productFeatureListObject)
                    }
                }
            }
        }
    }
    
    
    //MARK: Method to check if module in server response is same as coming in layout json
    private func checkIfModuleComingInServerResponse(moduleId:String?) -> Bool {
        
        let pageAPIModuleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(moduleId ?? "")"] as? SFModuleObject
        
        if pageAPIModuleObject != nil {
            
            return true
        }
        
        return false
    }
    
    
    //MARK: View creation methods
    //MARK: Method to create table view
    private func createTableView() {
        
        subscriptionTable = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), style: .plain)
        subscriptionTable?.delegate = self
        subscriptionTable?.dataSource = self
        subscriptionTable?.separatorStyle = .none
        subscriptionTable?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subscriptionTable?.backgroundView = nil
        subscriptionTable?.backgroundColor = UIColor.clear
        subscriptionTable?.showsVerticalScrollIndicator = false
        subscriptionTable?.register(SFPlanAdditionalTextCell.self, forCellReuseIdentifier: "PlanAdditionTextCell")
        
        if Constants.IPHONE {
            
            subscriptionTable?.register(UINib(nibName: "SFPlanAdditionalTextCell_iPhone", bundle: nil), forCellReuseIdentifier: "PlanAdditionTextCell")
        }
        else {
            
            subscriptionTable?.register(UINib(nibName: "SFPlanAdditionalTextCell_iPad", bundle: nil), forCellReuseIdentifier: "PlanAdditionTextCell")
        }
        
        self.view.addSubview(subscriptionTable!)
        self.subscriptionTable?.isHidden = true
    }

    
    //MARK: TableView Delegates Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var noOfRows:Int = 0
        
        if pageAPIObject?.pageModules != nil {
            
            if (pageAPIObject?.pageModules?.count)! > 0 {
                
                noOfRows = (pageAPIObject?.pageModules?.count)! + 1
            }
        }
        
        return noOfRows
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        
        let cellIdentifier:String = "gridCell"
        
        let cellObject:AnyObject? = cellModuleDict["\(String(indexPath.row))"]
        
        if cellObject == nil {
            
            if indexPath.row < (pageAPIObject?.pageModules?.count)! {
                
                let tableViewCell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
                tableViewCell.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
                tableViewCell.contentView.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
                tableViewCell.selectionStyle = .none
                
                if indexPath.row > modulesListArray.count - 1{
                    return tableViewCell
                }
                
                let module:AnyObject = modulesListArray[indexPath.row] as AnyObject
                var moduleId:String?
                
                if module is SFProductListObject {
                    
                    let moduleObject = module as! SFProductListObject
                    moduleId = moduleObject.moduleId
                }
                else if module is SFProductFeatureListObject {
                    
                    let moduleObject = module as! SFProductFeatureListObject
                    moduleId = moduleObject.moduleId
                }
                
                let pageAPIModuleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(moduleId ?? "")"] as? SFModuleObject
                addCollectionGridToTable(cell: tableViewCell, pageModuleObject: pageAPIModuleObject!, module: module)
                cellModuleDict["\(String(indexPath.row))"] = tableViewCell
                
                return tableViewCell
            }
            else {
                
                let planAdditionTextCell:SFPlanAdditionalTextCell = tableView.dequeueReusableCell(withIdentifier: "PlanAdditionTextCell", for: indexPath) as! SFPlanAdditionalTextCell
                
                planAdditionTextCell.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
                planAdditionTextCell.contentView.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "000000")
                planAdditionTextCell.selectionStyle = .none
                planAdditionTextCell.delegate = self
                planAdditionTextCell.updateViewColorTheme(containerView: planAdditionTextCell.contentView)
                planAdditionTextCell.updatePlanPriceText(annualPriceValue: planPrice)
                
                cellModuleDict["\(String(indexPath.row))"] = planAdditionTextCell

                return planAdditionTextCell
            }
        }
        else {
            
            if cellObject is UITableViewCell {
                
                let tableViewCell = cellObject as! UITableViewCell
                
                return tableViewCell
            }
            else if cellObject is SFPlanAdditionalTextCell {
                
                let planAdditionTextCell = cellObject as! SFPlanAdditionalTextCell
                
                return planAdditionTextCell
            }
        }
        
        let tempCell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        
        return tempCell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 10.0

        if indexPath.row < (pageAPIObject?.pageModules?.count)! {
            
            if indexPath.row > modulesListArray.count - 1 {
                return 0.0
            }
            
            let module:AnyObject = modulesListArray[indexPath.row] as AnyObject
            var moduleId:String?
            
            if module is SFProductListObject {
                
                let productListObject = module as! SFProductListObject
                moduleId = productListObject.moduleId
            }
            else if module is SFProductFeatureListObject {
                
                let productFeatureListObject = module as! SFProductFeatureListObject
                moduleId = productFeatureListObject.moduleId
            }
            
            let pageAPIModuleObject:SFModuleObject? = pageAPIObject?.pageModules?["\(moduleId ?? "")"] as? SFModuleObject

            rowHeight = CGFloat(calculateHeightForCollectionGridCell(moduleObject: module, pageModuleObject: pageAPIModuleObject!))
        }
        else {
            
            if Constants.IPHONE {
                
                rowHeight = 186.0
            }
            else {
                
                rowHeight = 232.0
            }
        }

        return rowHeight
    }
    
    
    //MARK: Method to add grids to table view cell
    func addCollectionGridToTable(cell:UITableViewCell, pageModuleObject:SFModuleObject, module:AnyObject) {
        
        let planCollectionGridViewController:PlanCollectionGridViewController = PlanCollectionGridViewController(moduleObject: module, moduleAPIObject: pageModuleObject)
        
        let collectionGridHeight:CGFloat = CGFloat(calculateHeightForCollectionGridCell(moduleObject: module, pageModuleObject: pageModuleObject))
        let cellFrame:CGRect = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: UIScreen.main.bounds.width, height: collectionGridHeight)
        planCollectionGridViewController.view.frame = cellFrame

        if !Constants.IPHONE {
            
            planCollectionGridViewController.isCollectionGridScrollEnabled = true
        }
        
        if module is SFProductListObject {
            
            if (module as! SFProductListObject).type == "AC SelectPlan 01" || (module as! SFProductListObject).viewName == "AC SelectPlan 01" {
             
                planCollectionGridViewController.isVeriticalCollectionView = true
            }
            else {
                
                planCollectionGridViewController.isVeriticalCollectionView = false
            }
        }
        
        planCollectionGridViewController.relativeViewFrame = planCollectionGridViewController.view.frame
        planCollectionGridViewController.delegate = self
        planCollectionGridViewController.moduleAPIObject = pageModuleObject
        planCollectionGridViewController.moduleObject = module
        planCollectionGridViewController.createSubViews()
    
        self.addChildViewController(planCollectionGridViewController)
        cell.addSubview(planCollectionGridViewController.view)
    }
    
    
    //MARL: method to calculate collection grid height
    func calculateHeightForCollectionGridCell(moduleObject:AnyObject, pageModuleObject:SFModuleObject) -> Float {
        
        var rowHeight:Float = 0.0
        
        if moduleObject is SFProductListObject {
            
            let productListObject:SFProductListObject = moduleObject as! SFProductListObject
            
            for module in productListObject.components {
                
                if module is SFLabelObject {
                    
                    let labelObject = module as! SFLabelObject
                    let labelHeight = Float(Utility.fetchLabelLayoutDetails(labelObject: labelObject).height!)
                    
                    rowHeight += labelHeight
                }
                else if module is SFCollectionGridObject {
                    
                    let collectionGridObject = module as! SFCollectionGridObject
                    let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject)
                    
                    var collectionGridHeight:Float = 10.0
                    
                    if Constants.IPHONE {
                        
                        let gridHeight = ((collectionGridLayout.gridHeight ?? 319) + (collectionGridLayout.trayPadding ?? 0)) * Float(Utility.getBaseScreenHeightMultiplier())
                        collectionGridHeight = collectionGridHeight + (gridHeight * Float(pageModuleObject.moduleData?.count ?? 0)) //+ (collectionGridLayout.trayPadding ?? 0)
                        
                        if collectionGridLayout.yAxis != nil {
                        
                            collectionGridHeight = (collectionGridLayout.yAxis! * Float(Utility.getBaseScreenHeightMultiplier())) + collectionGridHeight
                        }
                    }
                    else {
                        
                        if (moduleObject as! SFProductListObject).type == "AC SelectPlan 01" || (moduleObject as! SFProductListObject).viewName == "AC SelectPlan 01" {
                            
                            collectionGridHeight = collectionGridHeight + ((collectionGridLayout.gridHeight ?? 319) * Float(Utility.getBaseScreenHeightMultiplier())) + 35
                        }
                        else {
                            
                            collectionGridHeight = ((collectionGridLayout.height ?? 234.0) + 40.0) * Float(Utility.getBaseScreenHeightMultiplier())
                        }
                    }
                    
                    rowHeight += collectionGridHeight
                }
            }
        }
        else if moduleObject is SFProductFeatureListObject {
            
            let productFeatureListObject:SFProductFeatureListObject = moduleObject as! SFProductFeatureListObject
            
            for module in productFeatureListObject.components {
                
                if module is SFCollectionGridObject {
                    
                    let collectionGridObject = module as! SFCollectionGridObject
                    let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject)
                    
                    var collectionGridHeight:Float = 10.0
                    
                    if Constants.IPHONE {
                        
                        collectionGridHeight = collectionGridHeight + ((collectionGridLayout.gridHeight ?? 319) + (collectionGridLayout.trayPadding ?? 0)) * Float(productFeatureListObject.featureListArray.count) + (collectionGridLayout.trayPadding ?? 0)
                    }
                    else {
                        let totalGridHeight = ((collectionGridLayout.gridHeight ?? 319) + (collectionGridLayout.trayPadding ?? 0)) * ceil(Float(productFeatureListObject.featureListArray.count)/2)
                        
                        collectionGridHeight = collectionGridHeight + totalGridHeight + (collectionGridLayout.trayPadding ?? 0)
                    }
                    
                    rowHeight = rowHeight + collectionGridHeight
                }
            }
        }
        
        return rowHeight
    }
    
 
    func processPayment() {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            let okAction:UIAlertAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (okAction) in
                
            })
            
            let paymentNetworkAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "", alertMessage: "Check your Internet Connection and try again.", alertActions: [okAction])
            self.present(paymentNetworkAlert, animated: true, completion: nil)
        }
        else {
            
            if self.selectedPlanPaymentModelObject?.planIdentifier != nil {
                
                if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                {
                    FIRAnalytics.logEvent(withName: Constants.kGTMSelectSubscriptionPlanEvent, parameters: [Constants.kGTMProductIDAttribute:self.selectedPlanPaymentModelObject?.planIdentifier ?? "", Constants.kGTMProductNameAttribute:self.selectedPlanPaymentModelObject?.planName ?? "", Constants.kGTMProductCurrencyAttribute:self.selectedPlanPaymentModelObject?.recurringPaymentsTotalCurrency ?? "USD", Constants.kGTMProductValueAttribute: "\(self.selectedPlanPaymentModelObject?.planDiscountedPrice != nil ? (self.selectedPlanPaymentModelObject?.planDiscountedPrice?.floatValue)! : self.selectedPlanPaymentModelObject?.recurringPaymentsTotal != nil ? (self.selectedPlanPaymentModelObject?.recurringPaymentsTotal?.floatValue)! : 0.0)"])
                }
                
                self.showActivityIndicator(loaderText: "Processing your payment")
                SFStoreKitManager.sharedStoreKitManager.fetchAvailableProductsForProdcutIdentifier(pId: (self.selectedPlanPaymentModelObject?.planIdentifier)!, subscriptionPlans: self.subscriptionPlans)
            }
        }
    }


    //MARK: Table view cell delegate methods
    func buttonClicked(button: UIButton) {
        
        switch button.tag {
        case 100:
            
            loadAncillaryController(pageName: "Terms of Service", pagePath: "/tos")
            break
        case 101:
            
            loadAncillaryController(pageName: "Privacy Policy", pagePath: "/privacy-policy")
            break
            
        case 102:
            
            //restore purchase functionality
            restoreButtonTapped()
            break
        default:
            break
        }
    }
    
    
    func selectedPlanClicked(paymentModelObject: PaymentModel) {
        
        self.selectedPlanPaymentModelObject = paymentModelObject
        if self.selectedPlanPaymentModelObject?.planIdentifier != nil {
            
            processPayment()
        }
    }
    
    
    //MARK: Load ancillary page
    func loadAncillaryController(pageName:String, pagePath:String) {
        
        var viewControllerPage:Page?
        let filePath:String = AppSandboxManager.getpageFilePath(fileName: Utility.sharedUtility.getPageIdFromPagesArray(pageName: pageName) ?? "")
        if !filePath.isEmpty {
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                
                viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
            }
        }
        
        if viewControllerPage != nil {
            
            let ancillaryPageViewController:AncillaryPageViewController = AncillaryPageViewController(viewControllerPage: viewControllerPage!)
            ancillaryPageViewController.view.changeFrameYAxis(yAxis: 20.0)
            ancillaryPageViewController.view.changeFrameHeight(height: ancillaryPageViewController.view.frame.height - 20.0)
            ancillaryPageViewController.pagePath = pagePath
            ancillaryPageViewController.pageName = pageName
            self.present(ancillaryPageViewController, animated: true, completion: {
                
            })
        }
    }
    
    
    //MARK: Method to restore purchase
    func restoreButtonTapped() {
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
//            FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [kFIRParameterItemName: "Restore Purchase"])
            FIRAnalytics.setScreenName("Restore Purchase", screenClass: nil)
        }
        
        self.showActivityIndicator(loaderText: "Restoring your purchase")
        SFStoreKitManager.sharedStoreKitManager.isProductPurchased = false
        SFStoreKitManager.sharedStoreKitManager.restorePreviousTransaction()
    }
    
    
    //MARK: Notification Methods
    /**
     Method to handle purchase compeletion callback
     
     @param notification transaction details
     */
    func processPurchaseCompletionCallbackData(notification:Notification)
    {
        let userInfoDict:Dictionary<String, Any>? = notification.userInfo as? Dictionary<String, Any>
        
        if userInfoDict != nil {
            
            let isSuccessFullyPurchased:Bool? = userInfoDict?["success"] as? Bool
            
            if isSuccessFullyPurchased != nil && isSuccessFullyPurchased! {
                
                if Utility.sharedUtility.checkIfGoogleTagMangerAvailable()
                {
                    FIRAnalytics.logEvent(withName: Constants.kGTMFinishSubscriptionEvent, parameters: [Constants.kGTMProductIDAttribute:self.selectedPlanPaymentModelObject?.planIdentifier ?? "", Constants.kGTMProductNameAttribute:self.selectedPlanPaymentModelObject?.planName ?? "", Constants.kGTMProductCurrencyAttribute:self.selectedPlanPaymentModelObject?.recurringPaymentsTotalCurrency ?? "USD", Constants.kGTMProductValueAttribute: "\(self.selectedPlanPaymentModelObject?.planDiscountedPrice != nil ? (self.selectedPlanPaymentModelObject?.planDiscountedPrice?.floatValue)! : self.selectedPlanPaymentModelObject?.recurringPaymentsTotal != nil ? (self.selectedPlanPaymentModelObject?.recurringPaymentsTotal?.floatValue)! : 0.0)", Constants.kGTMProductTransactionIDAttribute:userInfoDict?["transactionId"] as? String ?? ""])
                }
                
                Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                Constants.kSTANDARDUSERDEFAULTS.synchronize()
                
                if AppsFlyerTracker.shared() != nil {
                    
                    AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_SUBSCRIPTION, withValues: [Constants.APPSFLYER_KEY_DEVICEID : ASIdentifierManager.shared().advertisingIdentifier.uuidString , AFEventParamRevenue : self.selectedPlanPaymentModelObject?.recurringPaymentsTotal?.stringValue ?? "" ,AFEventParamCurrency:self.selectedPlanPaymentModelObject?.recurringPaymentsTotalCurrency ?? "USD",Constants.APPSFLYER_KEY_PLAN_NAME :self.selectedPlanPaymentModelObject?.planName ?? "" , Constants.APPSFLYER_KEY_ENTITLED : "true"])
                }
                
                DispatchQueue.main.async {
                    
                    self.proceedAfterPaymentWithInfo(userInfo: userInfoDict!)
                }
            }
            else {
                
                self.showAlertWithMessage(message: userInfoDict!)
            }
        }
        else {
            
            self.hideActivityIndicator()
        }
    }
    
    
    /**
     Method to handle purchase failure
     */
    func purchaseFailed()
    {
        self.hideActivityIndicator()
    }
    
    
    /**
     Method to handle itunesconnect error handler
     */
    func iTunesConnectErrorNotification(notification:Notification) {
        
        self.hideActivityIndicator()
        let okAction = UIAlertAction(title: Constants.kStrOk, style: .default) { (okAction) in
        }
        
        let userInfo:Dictionary<String, Any>? = notification.userInfo as? Dictionary<String, Any>
        
        var errorMessage = Constants.kiTunesConnectErrorMessage
        
        if userInfo != nil {
            
            if let notificationErrorMessage = userInfo!["errorMessage"] as? String {
                
                errorMessage = notificationErrorMessage
            }
        }
        
        let iTunesConnectErrorAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "", alertMessage: errorMessage, alertActions: [okAction])
        self.present(iTunesConnectErrorAlert, animated: true, completion: nil)
    }
    
    
    /**
     Method to handle restore purchase failure
     */
    func restorePurchaseFailed() {
        
        self.hideActivityIndicator()
        
        let okAction = UIAlertAction(title: Constants.kStrOk, style: .default) { (okAction) in
            
        }
        
        let failedRestorePurchaseAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kRestorePurchaseFailureTitle, alertMessage: Constants.kRestorePurchaseFailureMessage, alertActions: [okAction])
        self.present(failedRestorePurchaseAlert, animated: true, completion: nil)
    }
    
    
    //MARK: Purchase handle methods
    /**
     Method to show the popup
     
     @param message popUp informations
     */
    private func showAlertWithMessage(message: Dictionary<String, Any>)
    {
        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kStrUserSubscribed)
        Constants.kSTANDARDUSERDEFAULTS.synchronize()
        
        let okAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrOk, style: .default) { (result : UIAlertAction) in
            
            self.hideActivityIndicator()
            self.checkIfUserShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered: false)
        }
        
        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
            
            self.hideActivityIndicator()
        }
        
        let tryAgainAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            self.hideActivityIndicator()
            self.processPayment()
        }
        
        let errorCode:String = message[Constants.PAYMENT_NOTIFICATION_CODE_KEY] as! String
        
        if (errorCode.lowercased() == Constants.kPaymentFailedCode.lowercased() || errorCode.lowercased() == Constants.kSubscriptionServiceFailedErrorCode.lowercased()) {
            DispatchQueue.main.async {
                let paymentAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "Payment Failed!", alertMessage: "The payment process did not complete/failed.\nTap OK to continue.\nTap Try Again to try again!", alertActions: [okAction, tryAgainAction])
                self.present(paymentAlert, animated: true, completion: nil)
            }
        } else if (errorCode.lowercased() == Constants.kDuplicateUserErrorCode.lowercased()) {
            
            DispatchQueue.main.async {
                let paymentAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "Payment Failed!", alertMessage: "You may have another account associated with the entered Apple Id. Kindly log in with that \(Bundle.main.infoDictionary?["CFBundleDisplayName"] ?? "") account.\nTap OK to continue.\nTap Try Again to try again!", alertActions: [okAction, tryAgainAction])
                self.present(paymentAlert, animated: true, completion: nil)
            }
        }
        else if errorCode.lowercased() == Constants.kUserNotFoundInSubscripionFailedErrorCode.lowercased() {
            
            DispatchQueue.main.async {
                
                self.hideActivityIndicator()
                self.presentCreateLoginPage()
            }
        }
        else if errorCode.lowercased() == Constants.kIllegalArugmentExceptionFailedErrorCode.lowercased(){
            
            self.hideActivityIndicator()
            self.checkIfUserShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered: false)
        }
        else {
            
            DispatchQueue.main.async {
                let paymentAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "Payment Failed!", alertMessage: "The payment process got failed.\nTap Retry to try again!", alertActions: [cancelAction, tryAgainAction])
                self.present(paymentAlert, animated: true, completion: nil)
            }
        }
    }

    
    /**
     Method to handle display payment failure alert
     
     @param notification transaction details
     */
    func showAlert(notification:NSNotification) {
        
        let userInfoDict:Dictionary<String, Any> = notification.userInfo as! Dictionary<String, Any>
        
        let okAction:UIAlertAction = UIAlertAction(title: Constants.kStrOk, style: .default) { (okAction) in
            
            self.hideActivityIndicator()
        }
        
        let paymentErrorAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: userInfoDict["title"] as? String ?? "", alertMessage: userInfoDict["message"] as? String ?? "", alertActions: [okAction])
        self.present(paymentErrorAlert, animated: true, completion: nil)
    }
    
    
    func showProgressPaymentProcess() {
        
    }
    

    func finishRestorePurchase() {
        
    }
    
    
    /**
     Method to handle restore purchase compeletion callback
     
     @param notification transaction details
     */
    func processRestorePurchaseCompetionCallbackData(notification:NSNotification) {
        
        let userInfoDict:Dictionary<String, Any> = notification.userInfo as! Dictionary<String, Any>
        
        DispatchQueue.main.async {
            
            Constants.kSTANDARDUSERDEFAULTS.setValue(userInfoDict, forKey: Constants.kTransactionInfo)
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
            
            self.isPerformingRestorePurchase = true
            self.getUserStatusFromTransactionId()
        }
    }
    
    
    /**
     Method to handle restore purchase with no transaction compeletion callback
     
     @param notification
     */
    func processRestoreWithZeroTransactionCallbackData(notification:NSNotification) {
        
        self.hideActivityIndicator()
        
        let okAction:UIAlertAction = UIAlertAction(title: Constants.kStrOk, style: .default) { (okAction) in
            
        }
        
        let restorePurchaseErrorAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.RESTORE_NO_PRODUCT_TITLE, alertMessage: Constants.RESTORE_NO_PRODUCT_MESSAGE, alertActions: [okAction])
        self.present(restorePurchaseErrorAlert, animated: true, completion: nil)
    }
    
    
    /**
     Method to manage subscriptions for user
     x
     @param userInfo transaction details
     */
    func proceedAfterPaymentWithInfo(userInfo: Dictionary<String, Any>){
        
        Constants.kSTANDARDUSERDEFAULTS.setValue(userInfo, forKey: Constants.kTransactionInfo)
        Constants.kSTANDARDUSERDEFAULTS.synchronize()
        
        if !(Utility.sharedUtility.checkIfUserIsLoggedIn()) && !(Utility.sharedUtility.checkIfUserIsSubscribedGuest()){
         
            self.isPerformingRestorePurchase = false
            self.getUserStatusFromTransactionId()
            //self.presentCreateLoginPage()
        }
        else if (Utility.sharedUtility.checkIfUserIsSubscribedGuest()) {
            
            self.isPerformingRestorePurchase = false
            self.getUserStatusFromTransactionId()
        }
        else {
            
            self.hideActivityIndicator()
            self.updateSubscriptionInfoWithReceiptdata(receipt: userInfo["receiptData"] as? NSData, emailId:nil, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String)
        }
    }

    
    /**
     Method to get user status from transaction id
     */
    func getUserStatusFromTransactionId() {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        
        if reachability.currentReachabilityStatus() == NotReachable {
            
            fetchRequestInProcess = false
            alertActionType = AlertAction.GetUserStatus
            showAlertForAlertType(alertType: .AlertTypeNoInternetFound, alertMessage: nil, alertTitle: nil)
        }
        else {
            
            let userInfo:Dictionary<String, Any> = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as! Dictionary<String, Any>
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                let receiptData:NSData? = userInfo["receiptData"] as? NSData
                
                var receiptString:String?
                if receiptData != nil {
                    
                    receiptString = (receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)))!
                }
                else {
                    
                    let receiptURL = Bundle.main.appStoreReceiptURL
                    
                    if receiptURL != nil {
                        
                        let receipt:NSData? = NSData(contentsOf:receiptURL!)
                        
                        if receipt != nil {
                            
                            receiptString = (receipt?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)))!
                        }
                    }
                }
                
                let requestParameter = ["paymentUniqueId":"\(userInfo["transactionId"] ?? "")", "site":"\(AppConfiguration.sharedAppConfiguration.sitename ?? "")", "receipt" : receiptString ?? ""]
                DataManger.sharedInstance.apiToGetUserIdFromTransactionId(requestParameter: requestParameter, success: { (userStatusDict, isSuccess) in
                    
                    DispatchQueue.main.async {
                        
                        if userStatusDict != nil && isSuccess {
                            
                            let refreshToken:String? = userStatusDict?["refreshToken"] as? String
                            let authorizationToken: String? = userStatusDict?["authorizationToken"] as? String
                            let id:String? = userStatusDict?["userId"] as? String
                            let email:String? = userStatusDict?["email"] as? String
                            let signInProvider:String? = userStatusDict?["provider"] as? String
                            let isSubscribed:Bool? = userStatusDict?["isSubscribed"] as? Bool
                            
                            if self.isPerformingRestorePurchase {
                                
                                if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                                    
                                    let currentUserId:String? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as? String
                                    
                                    if currentUserId != nil {
                                        
                                        if currentUserId != id {
                                            
                                            self.hideActivityIndicator()

                                            let okAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (okAction) in
                                                
                                            })
                                            
                                            let alreadyLinkedUserAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "", alertMessage: "You may have another account associated with this apple Id. Kindly log in with that \(Bundle.main.infoDictionary?["CFBundleDisplayName"] ?? "") account.", alertActions: [okAction])
                                            
                                            self.present(alreadyLinkedUserAlert, animated: true, completion: nil)
                                        }
                                        else {
                                         
                                            self.performAfterRestoreAPI(receipt: userInfo["receiptData"] as? NSData, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String, refreshToken: refreshToken, authorizationToken: authorizationToken, userId: id, emailId: email, signInProvider: signInProvider, isSubscribed: isSubscribed)
                                        }
                                    }
                                    else {
                                        
                                        self.performAfterRestoreAPI(receipt: userInfo["receiptData"] as? NSData, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String, refreshToken: refreshToken, authorizationToken: authorizationToken, userId: id, emailId: email, signInProvider: signInProvider, isSubscribed: isSubscribed)
                                    }
                                }
                                else {
                                    
                                    self.performAfterRestoreAPI(receipt: userInfo["receiptData"] as? NSData, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String, refreshToken: refreshToken, authorizationToken: authorizationToken, userId: id, emailId: email, signInProvider: signInProvider, isSubscribed: isSubscribed)
                                }
                            }
                            else {
                                
                                self.performAfterRestoreAPI(receipt: userInfo["receiptData"] as? NSData, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String, refreshToken: refreshToken, authorizationToken: authorizationToken, userId: id, emailId: email, signInProvider: signInProvider, isSubscribed: isSubscribed)
                            }
                        }
                        else if !self.isPerformingRestorePurchase {
                            
                            if Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                                
                                self.updateSubscriptionInfoWithReceiptdata(receipt: userInfo["receiptData"] as? NSData, emailId:nil, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String)
                            }
                            else {
                                
                                self.hideActivityIndicator()
                                self.presentCreateLoginPage()
                            }
                        }
                        else if self.isPerformingRestorePurchase {
                            
                            if Utility.sharedUtility.checkIfUserIsSubscribedGuest() || Utility.sharedUtility.checkIfUserIsLoggedIn() {
                                
                                self.updateSubscriptionInfoWithReceiptdata(receipt: userInfo["receiptData"] as? NSData, emailId:nil, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String)
                            }
                            else {
                                
                                self.hideActivityIndicator()
                                self.presentCreateLoginPage()
                            }
                        }
                    }
                })
            }
        }
    }
    
    
    func performAfterRestoreAPI(receipt: NSData?, productIdentifier:String?, transactionIdentifier:String?, refreshToken:String?, authorizationToken:String?, userId:String?, emailId:String?, signInProvider:String?, isSubscribed:Bool?) {
        
        if let subscriptionStatus = isSubscribed {
            
            if !subscriptionStatus {
                
                self.updateSubscriptionInfoWithReceiptdataAfterRestorePurchaseAPI(authorizationToken: authorizationToken, receipt: receipt, emailId: emailId, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier, success: { (isSuccess) in
                    
                    self.hideActivityIndicator()
                    
                    if isSuccess == true {
                        
                        self.performActionAfterUserStatusApi(refreshToken: refreshToken, authorizationToken: authorizationToken, userId: userId, emailId: emailId, signInProvider: signInProvider)
                    }
                })
            }
            else {
                
                self.hideActivityIndicator()
                self.performActionAfterUserStatusApi(refreshToken: refreshToken, authorizationToken: authorizationToken, userId: userId, emailId: emailId, signInProvider: signInProvider)
            }
        }
        else {
            
            self.hideActivityIndicator()
            self.performActionAfterUserStatusApi(refreshToken: refreshToken, authorizationToken: authorizationToken, userId: userId, emailId: emailId, signInProvider: signInProvider)
        }
    }
    
    /**
     Method to update subscription info with user
     @param receipt transaction receipt
     */
    func updateSubscriptionInfoWithReceiptdataAfterRestorePurchaseAPI(authorizationToken:String?, receipt: NSData?, emailId:String?, productIdentifier:String?, transactionIdentifier:String?, success: @escaping ((_ isSuccess:Bool) -> Void))
    {
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator(loaderText: nil)
        
        let requestParameters:Dictionary<String, Any> = Utility.sharedUtility.getRequestParametersForSubscription(receiptData: receipt, emailId: emailId, paymentModelObject: nil, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
        DataManger.sharedInstance.apiToUpdateSubscriptionStatusForRestorePurchase(requestParameter: requestParameters, authorizationToken: authorizationToken, requestType: .post) { (subscriptionResponse, isSuccess) in
            
            self.view.isUserInteractionEnabled = true
            self.hideActivityIndicator()
            
            if subscriptionResponse != nil {
                
                if isSuccess {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kTransactionInfo)
                    Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    Constants.kAPPDELEGATE.removePlistFromDocumentDirectory(plistName: Constants.kTransactionDetailPlistName)
                    success(true)
                }
                else {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    
                    let errorCode:String? = subscriptionResponse?["code"] as? String
                    
                    if errorCode != nil {
                        self.showAlertWithMessage(message: ["code": errorCode!])
                        success(false)
                    }
                    else {
                        
                        success(true)
                    }
                }
            }
            else {
                
                success(true)
            }
        }
    }
    
    func performActionAfterUserStatusApi(refreshToken:String?, authorizationToken:String?, userId:String?, emailId:String?, signInProvider:String?) {
        
        if authorizationToken != nil && refreshToken != nil
        {
            Constants.kSTANDARDUSERDEFAULTS.setValue(refreshToken, forKey: Constants.kRefreshToken)
            Constants.kSTANDARDUSERDEFAULTS.setValue(authorizationToken!, forKey: Constants.kAuthorizationToken)
            Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kAuthorizationTokenTimeStamp)
            Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
        }
        
        if userId != nil {
            
            Constants.kSTANDARDUSERDEFAULTS.setValue(userId, forKey: Constants.kUSERID)
        }
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            FIRAnalytics.setUserID(userId)
        }
        
        Constants.kSTANDARDUSERDEFAULTS.synchronize()

        self.checkUserNavigationToScreen(emailId: emailId, signInProvider: signInProvider)
    }
    
    
    func checkUserNavigationToScreen(emailId:String?, signInProvider:String?) {
        
        if emailId != nil || signInProvider != nil || Utility.sharedUtility.checkIfUserIsLoggedIn() {
            
            if signInProvider != nil {
                
                if signInProvider!.lowercased() == "facebook" {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Facebook.rawValue, forKey: Constants.kLoginType)
                }
                else if signInProvider!.lowercased() == "google" || signInProvider!.lowercased() == "gmail" || signInProvider!.lowercased() == "googleplus" {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Gmail.rawValue, forKey: Constants.kLoginType)
                }
                else if signInProvider!.lowercased() == "ios" && !Utility.sharedUtility.checkIfUserIsLoggedIn() {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.SubscribedGuest.rawValue, forKey: Constants.kLoginType)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    self.displayAlertForSubscribedGuestUser()
                    
                    return
                }
                else {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Email.rawValue, forKey: Constants.kLoginType)
                }
            }
            else {
                
                Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.Email.rawValue, forKey: Constants.kLoginType)
            }
            
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
            Constants.kAPPDELEGATE.fetchDownloadItemsAndUpdateThePaths()
            checkIfUserShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered: true)
        }
        else {
            
            Constants.kSTANDARDUSERDEFAULTS.setValue(UserLoginType.SubscribedGuest.rawValue, forKey: Constants.kLoginType)
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
            self.displayAlertForSubscribedGuestUser()
        }
    }
    
    
    func displayAlertForSubscribedGuestUser() {
        
        let createAccountAction = UIAlertAction(title: Constants.kCreateAccountTitle, style: .default) { (createAccountAction) in
            
            self.presentCreateLoginPage()
        }
        
        let skipCreateAccountAction = UIAlertAction(title: Constants.kSkipCreateAccountTitle, style: .default) { (skipCreateAccountAction) in
            
            self.checkIfUserShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered: true)
        }
        
        let accountCreationAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: Constants.kRestoreSuccessTitle, alertMessage: Constants.kRestoreSuccessMessageForNonLinkedAccount, alertActions: [createAccountAction, skipCreateAccountAction])
        
        self.present(accountCreationAlert, animated: true, completion: nil)
    }
    
    
    /**
     Method to update subscription info with user
     @param receipt transaction receipt
     */
    func updateSubscriptionInfoWithReceiptdata(receipt: NSData?, emailId:String?, productIdentifier:String?, transactionIdentifier:String?)
    {
        self.view.isUserInteractionEnabled = false
        self.showActivityIndicator(loaderText: nil)
    
        let requestParameters:Dictionary<String, Any> = Utility.sharedUtility.getRequestParametersForSubscription(receiptData: receipt, emailId: emailId, paymentModelObject: selectedPlanPaymentModelObject, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
        DataManger.sharedInstance.apiToUpdateSubscriptionStatus(requestParameter: requestParameters, requestType: .post) { (subscriptionResponse, isSuccess) in
            
            self.view.isUserInteractionEnabled = true
            self.hideActivityIndicator()
            
            if subscriptionResponse != nil {
                
                if isSuccess {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kTransactionInfo)
                    Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    Constants.kAPPDELEGATE.removePlistFromDocumentDirectory(plistName: Constants.kTransactionDetailPlistName)
                    self.checkIfUserShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered:true)
                }
                else {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    
                    let errorCode:String? = subscriptionResponse?["code"] as? String
                    
                    if errorCode != nil {
                        self.showAlertWithMessage(message: ["code": errorCode!])
                    }
                    else {
                        self.checkIfUserShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered:false)
                    }
                }
            }
            else {
                self.checkIfUserShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered:false)
            }
        }
    }
    
    
    func checkIfUserShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered:Bool) {
        
        NotificationCenter.default.removeObserver(self)

        if shouldUserBeNavigatedToHomePage != nil {
            
            if shouldUserBeNavigatedToHomePage! {
                
                DispatchQueue.main.async {
                    
                    //load home page
                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                        
                        Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMLoggedInPropertyValue, userPropertyKeyName: Constants.kGTMLoggedInProperty)
                    }
                    
                    Constants.kAPPDELEGATE.navigateToHomeScreen()
                }
            }
            else {
                
                DispatchQueue.main.async {
                    
                    //Dismiss view controller
                    self.dismiss(animated: true, completion: {
                        
                        if self.completionHandlerCopy != nil {
                            
                            self.completionHandlerCopy!(isSuccessfullyRegistered)
                        }
                    })
                }
            }
        }
        else {
            
            DispatchQueue.main.async {
                
                //Dismiss view controller
                self.dismiss(animated: true, completion: {
                    
                    if self.completionHandlerCopy != nil {
                        
                        self.completionHandlerCopy!(isSuccessfullyRegistered)
                    }
                })
            }
        }
    }
    
    
    /**
     Method to present create your account screen
     */
    func presentCreateLoginPage()
    {
        NotificationCenter.default.removeObserver(self)
        let loginViewController: LoginViewController = LoginViewController.init()
        loginViewController.loginPageSelection = 0
        loginViewController.pageScreenName = "Sign Up Screen"
        loginViewController.loginType = .createLogin
        loginViewController.paymentModelObject = self.selectedPlanPaymentModelObject
        loginViewController.shouldUserBeNavigatedToHomePage = self.shouldUserBeNavigatedToHomePage ?? false
        loginViewController.completionHandlerCopy = completionHandlerCopy
        loginViewController.navigationController?.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }

    
    //MARK - Show/Hide Activity Indicator
    private func showActivityIndicator(loaderText:String?) {
        
        progressIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        if loaderText != nil {
            
            progressIndicator?.mode = .indeterminate
            progressIndicator?.label.text = loaderText!
        }
    }
    
    
    private func hideActivityIndicator() {
        
        progressIndicator?.hide(animated: true)
    }
    
    
    //MARK: Display Network Error Alert
    private func showAlertForAlertType(alertType: AlertType, alertMessage:String?, alertTitle:String?) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
            }
        }
        
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            DispatchQueue.main.async {
                
                if self.alertActionType == AlertAction.FetchProducts {
                    
                    self.getproductsFromServer()
                }
                else if self.alertActionType == AlertAction.GetUserStatus {
                    
                    self.getUserStatusFromTransactionId()
                }
            }
        }
        
        var alertTitleString:String? = alertTitle
        var alertMessageString:String? = alertMessage
        
        if alertType == .AlertTypeNoInternetFound {
            
            if alertTitleString == nil {
                
                alertTitleString = Constants.kInternetConnection
            }
            
            if alertMessageString == nil {
                
                alertMessageString = Constants.kInternetConntectionRefresh
            }
        }
        else {
            
            if alertTitleString == nil {
                
                alertTitleString = Constants.kNoResponseErrorTitle
            }
            
            if alertMessageString == nil {
                
                alertMessageString = Constants.kSubscriptionNoResponseErrorMessage
            }
        }
        
        let networkUnavailableAlert = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction, retryAction])
        self.present(networkUnavailableAlert, animated: true, completion: nil)
    }
    
    
    //Method to deinitialise variables
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Memory Warning method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
