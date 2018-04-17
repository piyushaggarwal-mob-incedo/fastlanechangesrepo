
//
//  SubscriptionView_tvOS.swift
//  AppCMS
//
//  Created by Rajni Pathak on 01/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
enum AlertAction {
    case FetchProducts
    case GetUserStatus
}
@objc protocol SubscriptionViewDelegate: NSObjectProtocol {
    @objc optional func loadAncillaryPage(_ Type : String) -> Void
    @objc optional func loadCreateAccountPage(shouldDismiss: Bool) -> Void
    @objc optional func loadHomePage() -> Void

}


class SubscriptionView_tvOS: UIViewController, PlanCollectionGridViewDelegate, SFPlanAdditionalTextCellDelegate, SFButtonDelegate{
    //Stores view Frames
    private var relativeViewFrame:CGRect?
    weak var delegate: SubscriptionViewDelegate?
    private  var progressIndicator:MBProgressHUD?

    private var modulesArray:Array<AnyObject> = []
    private var subscriptionPlans:Array<AnyObject> = []
    private var selectedPlanPaymentModelObject:PaymentModel?
    private var moduleObject:SubscriptionViewObject_tvOS?
    private var pageAPIObject:PageAPIObject?
    private var alertActionType:AlertAction?
    private var isPerformingRestorePurchase:Bool = false
    private var fetchRequestInProcess:Bool = false
    private var modulesListArray:Array<AnyObject> = []
    private var planCollectionGridViewController:PlanCollectionGridView_tvOS?
    //Stores the Annual plan Price to be displayed in Addtional Static View(Terms&PrivacyPolicy)
    private var planPrice:String?
    private let backgroundFocusGuide : UIFocusGuide = UIFocusGuide()
    
    init(frame: CGRect, subscriptionObject: SubscriptionViewObject_tvOS, viewTag: Int, relativeFrame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        self.view.frame = relativeFrame
        self.relativeViewFrame = relativeFrame
        self.moduleObject = subscriptionObject
        self.modulesArray = subscriptionObject.components
        self.view.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector:#selector(SubscriptionView_tvOS.checkNetworkStatus), name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
        if self.pageAPIObject == nil && fetchRequestInProcess == false{
            self.getProductsFromServer()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kNetWorkStatus), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideActivityIndicator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         fetchRequestInProcess = true
        self.getProductsFromServer()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseCompletionNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishRestorePurchase), name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseCompletionNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFPurchaseCompletionNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processPurchaseCompletionCallbackData(notification:)), name: NSNotification.Name(rawValue: Constants.kSFPurchaseCompletionNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFPurchaseFailedNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFiTunesConnectErrorNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed), name: NSNotification.Name(rawValue: Constants.kSFPurchaseFailedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(iTunesConnectErrorNotification), name: NSNotification.Name(rawValue: Constants.kSFiTunesConnectErrorNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseFailedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restorePurchaseFailed), name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseFailedNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFPurchaseInProcessNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProgressPaymentProcess), name: NSNotification.Name(rawValue: Constants.kSFPurchaseInProcessNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kShowAlertNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert(notification:)), name: NSNotification.Name(rawValue: Constants.kShowAlertNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processRestorePurchaseCompetionCallbackData(notification:)), name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreWithZeroTransaction), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processRestoreWithZeroTransactionCallbackData(notification:)), name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreWithZeroTransaction), object: nil)
    }

    @objc private func checkNetworkStatus(){
        let networkStatus = NetworkStatus.sharedInstance
        if networkStatus.isNetworkAvailable() {
            if self.pageAPIObject == nil && fetchRequestInProcess == false{
                self.getProductsFromServer()
            }
        }
    }
    
    private func createView() -> Void {
        self.view.changeFrameWidth(width: (self.relativeViewFrame?.width)!)
        createSubscriptionView(containerView: self.view, itemIndex: 0)
    }
    
    
    //MARK: Creation of View Components
    private func createSubscriptionView(containerView: UIView, itemIndex:Int) {
        createAdditionalTextView(containerView: self.view)
        for component:AnyObject in self.modulesArray {
            if component is SFButtonObject {
                let buttonObject:SFButtonObject = component as! SFButtonObject
                createButtonView(buttonObject: buttonObject, containerView: containerView, itemIndex: itemIndex, type: component.key!!)
            }
            else if component is SFLabelObject {
                createLabelView(labelObject: component as! SFLabelObject, containerView: containerView, type: component.key!!)
            }
            else if component is SFImageObject {
                createImageView(imageObject: component as! SFImageObject, containerView: containerView,  type: component.key!!)
            }
            if component is SFCollectionGridObject {
                let moduleId = self.moduleObject?.moduleID
                guard let pageAPIModuleObject:SFModuleObject = pageAPIObject?.pageModules?["\(moduleId ?? "")"] as? SFModuleObject else {
                    return
                }
                guard let collectionGridObject = component as? SFCollectionGridObject else{
                    return
                }
                createCollectionGridView(pageModuleObject: pageAPIModuleObject, containerView: self.view,  module: self.moduleObject!, gridObject: collectionGridObject)
            }
        }
        addBackgroundFocusGuide()
    }

    //MARK: Method to create Static Page Content for terms of use and Privacy Policy.
    
    private func createAdditionalTextView(containerView:UIView){
        let planAdditionTextView = SFPlanAdditionalTextView_tvOS.instanceFromNib() as! SFPlanAdditionalTextView_tvOS
        planAdditionTextView.frame = CGRect(x: 0, y: 680, width: 1920, height: 280)
        planAdditionTextView.backgroundColor = UIColor.clear
        planAdditionTextView.delegate = self
        planAdditionTextView.updateViewColorTheme(containerView: planAdditionTextView)
        planAdditionTextView.updatePlanPriceText(annualPriceValue: planPrice)
        containerView.addSubview(planAdditionTextView)
    }
    
    //MARK: Method to create Collection Grid to display product plans.

    private func createCollectionGridView(pageModuleObject:SFModuleObject, containerView:UIView, module: AnyObject, gridObject: SFCollectionGridObject) {
        planCollectionGridViewController = PlanCollectionGridView_tvOS(moduleObject: module, moduleAPIObject: pageModuleObject)
        planCollectionGridViewController?.delegate = self
        planCollectionGridViewController?.moduleAPIObject = pageModuleObject
        planCollectionGridViewController?.moduleObject = module
        let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: gridObject)
        planCollectionGridViewController?.view.frame = Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: containerView.bounds)
        planCollectionGridViewController?.preferredContentSize = CGSize(width:(planCollectionGridViewController?.view.bounds.width)!, height: (planCollectionGridViewController?.view.bounds.height)!)
        planCollectionGridViewController?.relativeViewFrame = planCollectionGridViewController?.view.bounds
       
        //planCollectionGridViewController?.view.changeFrameWidth(width: 539)
        if (module as! SubscriptionViewObject_tvOS).moduleType == "AC SelectPlan 02" || (module as! SubscriptionViewObject_tvOS).moduleTitle == "AC SelectPlan 02" {
            planCollectionGridViewController?.isVeriticalCollectionView = true
        }
        else {
            
            planCollectionGridViewController?.isVeriticalCollectionView = false
        }
        planCollectionGridViewController?.createSubViews()
        self.addChildViewController(planCollectionGridViewController!)
        containerView.addSubview((planCollectionGridViewController?.view)!)
        
    }
    
    private func createLabelView(labelObject:SFLabelObject, containerView:UIView, type: String) {
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.text = labelObject.text
        containerView.addSubview(label)
        containerView.bringSubview(toFront: label)
        label.createLabelView()
    }
    
    private func createButtonView(buttonObject:SFButtonObject, containerView:UIView, itemIndex:Int, type: String) -> Void {
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.buttonLayout = buttonLayout
        button.relativeViewFrame = containerView.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.buttonDelegate = self
        button.tag = itemIndex
        if button.buttonObject?.key == "cancelButton"  {
            button.isHidden = true
        }
        button.createButtonView()
        containerView.addSubview(button)
        containerView.bringSubview(toFront: button)
        
        let backgroundFocusGuide : UIFocusGuide = UIFocusGuide()
        self.view.addLayoutGuide(backgroundFocusGuide)
        backgroundFocusGuide.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        backgroundFocusGuide.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        backgroundFocusGuide.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        backgroundFocusGuide.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        backgroundFocusGuide.preferredFocusedView = button
    }
    
    private func createImageView(imageObject:SFImageObject, containerView:UIView, type: String) {
        let imageView:SFImageView = SFImageView()
        imageView.imageViewObject = imageObject
        imageView.relativeViewFrame = containerView.frame
        imageView.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
        imageView.updateView()
        if imageView.imageViewObject?.key == "subscriptionLogoImage"  {
            imageView.image = UIImage(named: "appLogo")
        }
        else{
            imageView.image = UIImage(named: imageObject.imageName!)
        }
        imageView.contentMode = .left
        containerView.addSubview(imageView)
    }
    
    
    /// Returns the subscription logo image view instance.
    ///
    /// - Returns: Optional. May contain logo imageview instance.
    private func getTheLogoImageView() -> SFImageView? {
        for view in self.view.subviews {
            if let imageView = view as? SFImageView {
                if imageView.imageViewObject?.key == "subscriptionLogoImage" {
                    return imageView
                }
            }
        }
        return nil
    }
    
    /// Adds a background focus guide to the view, for smooth transition of focus.
    private func addBackgroundFocusGuide() {
        if let imageView = getTheLogoImageView() {
//            let backgroundFocusGuide : UIFocusGuide = UIFocusGuide()
            self.view.addLayoutGuide(backgroundFocusGuide)
            backgroundFocusGuide.leftAnchor.constraint(equalTo: imageView.leftAnchor).isActive = true
            backgroundFocusGuide.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
            backgroundFocusGuide.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
            backgroundFocusGuide.heightAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
            backgroundFocusGuide.preferredFocusedView = planCollectionGridViewController?.view
        }
    }

    //MARK: Get list of products from server
    private func getProductsFromServer()
    {
        let networkStatus = NetworkStatus.sharedInstance
        if networkStatus.isNetworkAvailable() {
            
            self.showActivityIndicator(loaderText: nil)
            
            var apiEndPoint = "\(AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? "")/content/pages?device=ios_apple_tv&site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")&path=/viewplans&includeContent=true"
            
            if let userId = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) {
                
                apiEndPoint.append("&userId=\(userId)")
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                DataManger.sharedInstance.fetchContentForPlansPage(apiEndPoint: apiEndPoint, requestHeaders: nil, pageAPIResponse: { [weak self] (pageAPIObjectResponse, isSuccess) in
                    guard let checkedSelf = self else {
                        return
                    }
                    DispatchQueue.main.async {
                        checkedSelf.hideActivityIndicator()
                        checkedSelf.fetchRequestInProcess = false
                        if pageAPIObjectResponse != nil && pageAPIObjectResponse?.pageModules != nil && isSuccess == true {
                            checkedSelf.pageAPIObject = pageAPIObjectResponse
                            checkedSelf.modulesListArray.removeAll()
                            checkedSelf.getAnnualPlanPrice()
                            checkedSelf.createView()
                        }
                        else {
                            checkedSelf.alertActionType = AlertAction.FetchProducts
                            checkedSelf.showAlertForAlertType(alertType: .AlertTypeNoResponseReceived, alertMessage: nil, alertTitle: nil)
                        }
                    }
                })
            }
        }
        else{
            fetchRequestInProcess = false
            alertActionType = AlertAction.FetchProducts
            showAlertForAlertType(alertType: .AlertTypeNoInternetFound, alertMessage: nil, alertTitle: nil)
        }
        
    }
    
    private func getAnnualPlanPrice() {
        var moduleId:String?
        if self.moduleObject != nil {
            moduleId = self.moduleObject?.moduleID
        }
        if moduleId != nil {
            guard let moduleAPIObject:SFModuleObject = pageAPIObject?.pageModules?["\(moduleId ?? "")"] as? SFModuleObject else {
                return
            }
            if moduleAPIObject.moduleData != nil {
                self.subscriptionPlans = (moduleAPIObject.moduleData)!
                for _ in (moduleAPIObject.moduleData)!
                {
                    var yearlyPrice:NSNumber?
                    
                    for moduleData in (moduleAPIObject.moduleData)! {
                        
                        if moduleData is PaymentModel {
                            
                            let paymentModel = moduleData as! PaymentModel
                            
                            if paymentModel.billingPeriodType == .YEARLY {
                                
                                if paymentModel.recurringPaymentsTotalCurrency != nil {
                                    
                                    planPrice = Utility.getSymbolForCurrencyCode(countryCode: (paymentModel.recurringPaymentsTotalCurrency)!)
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
    }

    //MARK: - Button Delegate
    func updateCancelButtonFor(hasAnyPlanSelected: Bool) {
        for subView in self.view.subviews {
            if subView is SFButton {
                let button:SFButton = subView as! SFButton
                if button.buttonObject?.key == "cancelButton"  {
                    button.isHidden = !hasAnyPlanSelected
                }
                if(hasAnyPlanSelected){
                    backgroundFocusGuide.preferredFocusedView = nil
                }
                else{
                    
                    backgroundFocusGuide.preferredFocusedView = planCollectionGridViewController?.view
                    self.view.setNeedsFocusUpdate()
                }
            }
            if subView is SFLabel {
                let label:SFLabel = subView as! SFLabel
                if label.labelObject?.key == "confirmPurchase"  {
                    if hasAnyPlanSelected{
                        label.text = "CONFIRM YOUR PLAN"
                    }
                    else{
                        label.text = label.labelObject?.text
                    }
                }
            }
        }
    }

    
    func buttonClicked(button: SFButton) {
        if button.buttonObject?.action == "cancel"
        {
            guard (planCollectionGridViewController != nil) else {
                return
            }
            planCollectionGridViewController?.reloadPlansOnCancelButtonClick()
        }
    }

    //MARK:Button Click methods
    func addtionalTextCellButtonClicked(button: UIButton) {
        switch button.tag {
        case 100:
            if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.loadAncillaryPage(_:))))!
            {
                self.delegate?.loadAncillaryPage!("Terms")
            }
            break
        case 101:
            if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.loadAncillaryPage(_:))))!
            {
                self.delegate?.loadAncillaryPage!("Privacy Policy")
            }
            break
        case 102:
            //restore purchase functionality
            restoreButtonTapped()
            break
        default:
            break
        }
    }
    
    //MARK: Method to intiate purchase process for selected product
    func selectedPlanClicked(paymentModelObject: PaymentModel) {
        self.selectedPlanPaymentModelObject = paymentModelObject
        if self.selectedPlanPaymentModelObject?.planIdentifier != nil {
            processPayment()
        }
    }
    
    private func processPayment() {
        let networkStatus = NetworkStatus.sharedInstance
        if networkStatus.isNetworkAvailable() {
            if self.selectedPlanPaymentModelObject?.planIdentifier != nil {
                self.showActivityIndicator(loaderText: "Processing your payment")
                SFStoreKitManager.sharedStoreKitManager.fetchAvailableProductsForProdcutIdentifier(pId: (self.selectedPlanPaymentModelObject?.planIdentifier)!, subscriptionPlans: self.subscriptionPlans)
            }
        }
        else{
            let okAction:UIAlertAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (okAction) in
                
            })
            let paymentNetworkAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "", alertMessage: "Check your Internet Connection and try again.", alertActions: [okAction])
            self.present(paymentNetworkAlert, animated: true, completion: nil)
        }
    }
    
    //MARK: Method to restore purchase
    func restoreButtonTapped() {
//        presentCreateLoginPage()
//        return
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
        let userInfoDict:Dictionary<String, Any> = notification.userInfo as! Dictionary<String, Any>
        let isSuccessFullyPurchased:Bool = userInfoDict["success"] as! Bool
        if isSuccessFullyPurchased {
            Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
            Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
            Constants.kSTANDARDUSERDEFAULTS.synchronize()
            DispatchQueue.main.async {
                self.proceedAfterPaymentWithInfo(userInfo: userInfoDict)
            }
        }
        else {
            self.showAlertWithMessage(message: userInfoDict)
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
            self.userShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered: false)
        }
        
        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default) { (cancelAction) in
            self.hideActivityIndicator()
        }
        
        let tryAgainAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            self.hideActivityIndicator()
            self.processPayment()
        }
        
        guard let errorCode:String = message[Constants.PAYMENT_NOTIFICATION_CODE_KEY] as? String else{
            return
        }
        
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
            self.userShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered: false)
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
        //showActivityIndicator(loaderText: "Processing your payment")
    }
    
    func finishRestorePurchase() {
        self.hideActivityIndicator()
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
        
        let networkStatus = NetworkStatus.sharedInstance
        if networkStatus.isNetworkAvailable() {
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
                DataManger.sharedInstance.apiToGetUserIdFromTransactionId(requestParameter: requestParameter, success: { [weak self] (userStatusDict, isSuccess) in
                    guard let checkedSelf = self else {
                        return
                    }
                    DispatchQueue.main.async {

                        if userStatusDict != nil && isSuccess {
                            
                            let refreshToken:String? = userStatusDict?["refreshToken"] as? String
                            let authorizationToken: String? = userStatusDict?["authorizationToken"] as? String
                            let id:String? = userStatusDict?["userId"] as? String
                            let email:String? = userStatusDict?["email"] as? String
                            let signInProvider:String? = userStatusDict?["provider"] as? String
                            let isSubscribed:Bool? = userStatusDict?["isSubscribed"] as? Bool

                            if checkedSelf.isPerformingRestorePurchase {
                                
                                if Utility.sharedUtility.checkIfUserIsLoggedIn() || Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                                    
                                    let currentUserId:String? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) as? String
                                    
                                    if currentUserId != nil {
                                    
                                        if currentUserId != id {
                                        
                                            let okAction = UIAlertAction(title: Constants.kStrOk, style: .default, handler: { (okAction) in
                                            })
                                            
                                            let alreadyLinkedUserAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: "", alertMessage: "You may have another account associated with this apple Id. Kindly log in with that \(Bundle.main.infoDictionary?["CFBundleDisplayName"] ?? "") account.", alertActions: [okAction])
                                            
                                            checkedSelf.present(alreadyLinkedUserAlert, animated: true, completion: nil)
                                        }
                                        else {
                                            
                                            checkedSelf.performAfterRestoreAPI(receipt: userInfo["receiptData"] as? NSData, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String, refreshToken: refreshToken, authorizationToken: authorizationToken, userId: id, emailId: email, signInProvider: signInProvider, isSubscribed: isSubscribed)
                                        }
                                    }
                                    else {
                                        
                                        checkedSelf.performAfterRestoreAPI(receipt: userInfo["receiptData"] as? NSData, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String, refreshToken: refreshToken, authorizationToken: authorizationToken, userId: id, emailId: email, signInProvider: signInProvider, isSubscribed: isSubscribed)
                                    }
                                }
                                else {
                                    checkedSelf.performAfterRestoreAPI(receipt: userInfo["receiptData"] as? NSData, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String, refreshToken: refreshToken, authorizationToken: authorizationToken, userId: id, emailId: email, signInProvider: signInProvider, isSubscribed: isSubscribed)
                                }
                            }
                            else {
                                checkedSelf.performActionAfterUserStatusApi(refreshToken: refreshToken, authorizationToken: authorizationToken, userId: id, emailId: email, signInProvider: signInProvider)
                            }
                        }
                        else if !checkedSelf.isPerformingRestorePurchase {
                            
                            if Utility.sharedUtility.checkIfUserIsSubscribedGuest() {
                                
                                checkedSelf.updateSubscriptionInfoWithReceiptdata(receipt: userInfo["receiptData"] as? NSData, emailId:nil, productIdentifier: userInfo["productIdentifier"] as? String, transactionIdentifier: userInfo["transactionId"] as? String)
                            }
                            else {
                                
                                checkedSelf.hideActivityIndicator()
                                checkedSelf.presentCreateLoginPage()
                            }
                        }
                        else if checkedSelf.isPerformingRestorePurchase {
                            
                            checkedSelf.hideActivityIndicator()
                            checkedSelf.presentCreateLoginPage()
                        }
                    }
                })
            }
        }
        else{
            fetchRequestInProcess = false
            alertActionType = AlertAction.GetUserStatus
            showAlertForAlertType(alertType: .AlertTypeNoInternetFound, alertMessage: nil, alertTitle: nil)
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
        DataManger.sharedInstance.apiToUpdateSubscriptionStatusForRestorePurchase(requestParameter: requestParameters, authorizationToken: authorizationToken, requestType: .post) { [weak self](subscriptionResponse, isSuccess) in
            
            guard let checkedSelf = self else {
                return
            }
            
            if subscriptionResponse != nil {
                
                if isSuccess {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kTransactionInfo)
                    Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    success(true)
                }
                else {
                    
                    Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    
                    let errorCode:String? = subscriptionResponse?["code"] as? String
                    
                    if errorCode != nil {
                        checkedSelf.showAlertWithMessage(message: ["code": errorCode!])
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
            userShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered: true)
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
            
            self.userShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered: true)
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
        self.showActivityIndicator(loaderText: nil)
        let requestParameters:Dictionary<String, Any> = Utility.sharedUtility.getRequestParametersForSubscription(receiptData: receipt, emailId: emailId, paymentModelObject: selectedPlanPaymentModelObject, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
        DataManger.sharedInstance.apiToUpdateSubscriptionStatus(requestParameter: requestParameters, requestType: .post) { [weak self](subscriptionResponse, isSuccess) in
            guard let checkedSelf = self else {
                return
            }
            checkedSelf.hideActivityIndicator()
            if subscriptionResponse != nil {
                if isSuccess {
                    Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kTransactionInfo)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    checkedSelf.userShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered:true)
                }
                else {
                    let errorCode:String? = subscriptionResponse?["code"] as? String
                    
                    if errorCode != nil {
                        checkedSelf.showAlertWithMessage(message: ["code": errorCode!])
                    }
                    else {
                        checkedSelf.userShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered:false)
                    }
                }
            }
            else {
                checkedSelf.userShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered:false)
            }
        }
    }

    /**
     Method to present create your account screen
     */
    func presentCreateLoginPage()
    {
        if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.loadCreateAccountPage)))!
        {
            if let vc = self.traverseAndFindClass() as AppSubContainerController? {
                if let shouldDismiss = vc.shouldJustDismiss {
                    self.delegate?.loadCreateAccountPage!(shouldDismiss: shouldDismiss)
                }
                print("")
            } else {
                self.delegate?.loadCreateAccountPage!(shouldDismiss: false)
            }
        }
    }
    
    //MARK - Show/Hide Activity Indicator
    private func showActivityIndicator(loaderText:String?) {
        progressIndicator = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        if loaderText != nil {
            progressIndicator?.mode = .indeterminate
            progressIndicator?.label.text = loaderText!
            progressIndicator?.label.font = UIFont.boldSystemFont(ofSize: 25)
        }
        self.view.isUserInteractionEnabled = false
    }
    
    private func hideActivityIndicator() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
        self.view.isUserInteractionEnabled = true
    }

    
    //MARK: Display Network Error Alert
    private func showAlertForAlertType(alertType: AlertType, alertMessage:String?, alertTitle:String?) {
        
        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
            DispatchQueue.main.async {
                self.hideActivityIndicator()
            }
        }
        let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            DispatchQueue.main.async {
                if self.alertActionType == AlertAction.FetchProducts {
                    self.getProductsFromServer()
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

    func userShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered:Bool) {
        if isSuccessfullyRegistered{
            if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.loadHomePage)))! {
                self.dismiss(animated: false, completion: nil)
                self.delegate?.loadHomePage!()
            }
        }
        else{
            
        }
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

extension UIViewController{
    
    func traverseAndFindClass<T : UIViewController>() -> T? {
        
        var currentVC = self
        while let parentVC = currentVC.parent {
            if let result = parentVC as? T {
                return result
            }
            currentVC = parentVC
        }
        return nil
    }
}
