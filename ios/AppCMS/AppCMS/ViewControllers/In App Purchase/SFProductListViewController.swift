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



class SFProductListViewController: UIViewController{
    /*
    var modulesListArray:Array<AnyObject> = []
    var modulesArray:Array<AnyObject> = []
    var completionHandlerCopy : ((Bool) -> Void)? = nil

    var planPrice:String?
    var subscriptionPlans:Array<AnyObject> = []
    var selectedPlanIdentifier:String?
    var priceCurrency:String?


    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        //fetchProductListPageUI()
        createNavigationBar()
        // Do any additional setup after loading the view.
        
        //    [self setFramesOfViews];
        //
        //    self.navigationController.navigationBarHidden = YES;
        //    self.subscriptionPlans = [[NSMutableArray alloc] init];
        //    //Setting up home logo image on navigation bar
        //    UIImage *image = [UIImage imageNamed: @"navigation_homeLogo"];
        //    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
        //    self.navigationItem.titleView = imageView;
        //    self.view.backgroundColor = [UIColor whiteColor];
        //
        //    [NOTIFICATIONCENTER addObserver:self selector:@selector(processPurchaseCompletionCallbackData:) name:SFPurchaseCompletionNotification object:nil];
        //    [NOTIFICATIONCENTER addObserver:self selector:@selector(showProgressHUDForPaymentProcess) name:SFPurchaseInProcessNotification object:nil];
        //    [NOTIFICATIONCENTER addObserver:self selector:@selector(purchaseFailed) name:SFPurchaseFailedNotification object:nil];
        //    [NOTIFICATIONCENTER addObserver:self selector:@selector(ProductNotAvailable) name:SFPurchaseProductNotAvailableNotification object:nil];
        //    [NOTIFICATIONCENTER addObserver:self selector:@selector(showAlert:) name:ShowAlertNotification object:nil];

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //    [super viewDidAppear:YES];
        //    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
    override func viewWillAppear(_ animated: Bool) {
        
        //[self getproductsFromServer];
    }
    
    
    func fetchProductListPageUI() -> Void {
        
        let pageID: String = Utility.sharedUtility.getPageIdFromPagesArray(pageName: " ")!
        
        let filePath:String = AppSandboxManager.getpageFilePath(fileName: pageID)
        
        if FileManager.default.fileExists(atPath: filePath){
            let jsonData:Data = FileManager.default.contents(atPath: filePath)!
            
            let responseStarJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, Any>
            let responseJson:Array<Dictionary<String, AnyObject>> = responseStarJson["moduleList"] as! Array<Dictionary<String, AnyObject>>
            
            modulesListArray = ModuleUIParser.sharedInstance.parseModuleConfigurationJson(modulesConfigurationArray: responseJson) as Array<AnyObject>
            createModules()
        }
    }
    
    
    func createNavigationBar() -> Void {
        self.navigationController?.navigationBar.barTintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "ffffff")
        self.navigationItem.titleView = Utility.createNavigationTitleView(navBarHeight: (self.navigationController?.navigationBar.frame.size.height)!)
        let closeButton: UIButton = UIButton.init(type: .custom)
        closeButton.setImage(#imageLiteral(resourceName: "cancelIcon.png"), for: .normal)
        closeButton.frame = CGRect.init(x: 0, y: 0, width: 22, height: 22)
        closeButton.addTarget(self, action: #selector(closeButtonTapped(sender:)), for: .touchUpInside)
        let closeBarButtonItem: UIBarButtonItem = UIBarButtonItem.init(customView: closeButton)
        self.navigationItem.rightBarButtonItem = closeBarButtonItem
    }
    
    func closeButtonTapped(sender: UIButton) -> Void {
        self.navigationController?.dismiss(animated: false, completion: {
            
            if self.completionHandlerCopy != nil {
                self.completionHandlerCopy!(false)
            }
        })
    }
    
    func createModules() -> Void {
        for module:AnyObject in self.modulesListArray {
            
            if module is SFProductListObject {
                
                var ii: Int = 0
                for component in (module as! SFProductListObject).components
                {
                    
                    ii = ii+1
                }
            }
        }
    }

    
    
    
    
    // #pragma mark - Purchase handle methods
    
    /**
     Method to show the popup
     
     @param message popUp informations
     */
    func showAlertWithMessage(message: Dictionary<String:Any>){
        Constants.kSTANDARDUSERDEFAULTS.setValue(false, forKey: Constants.kStrUserSubscribed)
        Constants.kSTANDARDUSERDEFAULTS.synchronize()
        
        
        let okAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrOk, style: .default) { (result : UIAlertAction) in
            
            //[self checkIfTheUserShouldBeNavigatedToHomeScreenOnTap];
        }
        let tryAgainAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
            
            //[self processThePayment];
            
        }
        
        
        var errorCode: String = message[PAYMENT_NOTIFICATION_CODE_KEY]
            if (errorCode == FAILED_PAYMENT_CODE) {
                DispatchQueue.main.async {
                    var paymentAlert:UIAlertController = Utility.presentAlertController(alertTitle: "Payment Failed!", alertMessage: "The payment process did not complete/failed.\nTap OK to continue.\nTap Try Again to try again!", alertActions: [okAction, tryAgainAction])
                    self.present(paymentAlert!, animated: true, completion: nil)
                }
            } else if (errorCode == "validation") {
                
                DispatchQueue.main.async {
                    var paymentAlert:UIAlertController = Utility.presentAlertController(alertTitle: "Payment Failed!", alertMessage: "You may have another account associated with the entered Apple Id. Kindly log in with that TGC account.\nTap OK to continue.\nTap Try Again to try again!", alertActions: [okAction, tryAgainAction])
                    self.present(paymentAlert!, animated: true, completion: nil)
                }
            }
    }
    
 
   func processThePayment()
    {
    //[self showProgressHUDForPlan:@"Your payment is being processed!"];
        SFStoreKitManager.sharedStoreKitManager.fetchAvailableProductsForProdcutIdentifier(pId: self.selectedPlanIdentifier)
    }

    /**
     Method to update subscription info with user
     
     @param receipt transaction receipt
     */
    func updateSubscriptionInfoWithReceiptdata(receipt: NSData)
    {
   // [[IncLoadingView sharedInstance] showLoadingView:[UIApplication sharedApplication].keyWindow];
    
//    [[IAPNetworkHandler sharedIAPNetworkHandler] setUserWithUserID:[STANDARDUSERDEFAULT objectForKey:USERID] subcribedWithSiteInternalName: nil andReceiptDataBase64String: [receipt base64EncodedStringWithOptions:0]
//    withSuccess:^(NSDictionary *responseDict)
//    {
//    [[IncLoadingView sharedInstance] removeLoadingView];
//    if (responseDict && [responseDict nilOrValueForKey:@"success"] && [[responseDict nilOrValueForKey:@"success"] boolValue] == YES) {
//    [STANDARDUSERDEFAULT setBool:YES forKey:USER_SUBSCRIBED];
//    [STANDARDUSERDEFAULT synchronize];
//    [STANDARDUSERDEFAULT setObject:nil forKey:@"transactionInfo"];
//    [self checkIfTheUserShouldBeNavigatedToHomeScreenOnTap];
//    
//    } else {
//    
//    NSDictionary* errorDict = [responseDict nilOrValueForKey:@"errors"];
//    NSArray* errorMessageArray = errorDict ? [errorDict nilOrValueForKey:@"message"] : nil;
//    NSArray* errorCodeArray = errorDict ? [errorDict nilOrValueForKey:@"code"] : nil;
//    NSString* errorMessage = errorMessageArray ? [errorMessageArray count] > 0 ?[errorMessageArray objectAtIndex:0] : @"" : @"";
//    NSString* errorCode = errorCodeArray ? [errorCodeArray count] > 0 ?[errorCodeArray objectAtIndex:0] : @"" : @"";
//    NSDictionary* userInfo = @{PAYMENT_NOTIFICATION_SUCCESS_KEY: @(NO),PAYMENT_NOTIFICATION_MESSAGE_KEY:errorMessage,PAYMENT_NOTIFICATION_CODE_KEY:errorCode};
//    [self showAlertWithMessage:userInfo];
//    }
//    } andFailure:^(NSError *error) {
//    [[IncLoadingView sharedInstance] removeLoadingView];
//    NSLog(@"setUserWithUserID with receipt API failed----%@",error.description);
//    SFAppDelegate *appDelegate = (SFAppDelegate*)[[UIApplication sharedApplication] delegate];
//    [appDelegate jumpToTabBarController];
//    }];
    }
    
    /**
     Method to present link your account after restore purchase
     */
    func presentLinkAccountScreen()
    {
//    MSELinkAccountVC* signUpVC = [[MSELinkAccountVC alloc]initWithNibName:NibName(@"MSELinkAccountVC") bundle:nil];
//    signUpVC.delegate = self;
//    signUpVC.isNewProductPurchase = YES;
//    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:signUpVC];
//    [navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBarImage"] forBarMetrics:UIBarMetricsDefault];
//    [self presentViewController:navigationController animated:YES completion:nil];
    }
    
    /**
     Method to manage subscriptions for user
     x
     @param userInfo transaction details
     */
    func proceedAfterPaymentWithInfo(userInfo: Dictionary){
    
//    [STANDARDUSERDEFAULT setObject:userInfo forKey:@"transactionInfo"];
//    [STANDARDUSERDEFAULT synchronize];
//    
//    if (!self.isFromSignIn && _shouldTheUserBeNavigatedToHomePage) {
//    [[IncLoadingView sharedInstance] showLoadingView:[UIApplication sharedApplication].keyWindow];
//    [self presentLinkAccountScreen];
//    }
//    else{
//    NSString *loginType = [STANDARDUSERDEFAULT objectForKey:LOGINTYPE];
//    if ((loginType == nil || [loginType isEqualToString:GUEST] || [loginType isEqualToString:SUBSCRIBED_GUEST])) {
//    [self presentLinkAccountScreen];
//    }
//    else{
//    [self updateSubscriptionInfoWithReceiptdata:userInfo[@"receiptData"]];
//    }
    
//    }
    }

    /**
     Method to handle purchase complition callback
     
     @param notification transaction details
     */
    func processPurchaseCompletionCallbackData(notification:Notification)
    {
//    [self hideProgressHUD];
//    if ([notification.name isEqualToString:SFPurchaseCompletionNotification])
//    {
//    NSDictionary* userInfo = notification.object;
//    BOOL success = (BOOL)[userInfo[@"success"] boolValue];
//    if (success) {
//    //Set TRUE for userSubscribedKey
//    //For facebook app event method to send data to facebook after payment.
//    [FBAppEvents logPurchase:[self.planPrice doubleValue] currency:self.priceCurrency];
//    UIAlertAction *okAction = [UIAlertAction
//    actionWithTitle:@"OK"
//    style:UIAlertActionStyleDefault
//    handler:^(UIAlertAction *action)
//    {
//    if (self.isFromSignIn) {
//    [STANDARDUSERDEFAULT setBool:YES forKey:USER_SUBSCRIBED];
//    [STANDARDUSERDEFAULT synchronize];
//    if([STANDARDUSERDEFAULT boolForKey:PERSONALIZATION_PAGE_APPEARED])
//    {
//    [self dismissAndNavigateToValidVC];
//    }
//    else
//    {
//    MSESignUpPersonalizationViewController *msePersonlizationVC = [[MSESignUpPersonalizationViewController alloc]initWithNibName:NibName(@"MSESignUpPersonalizationViewController") bundle:nil];
//    msePersonlizationVC.delegate = self;
//    SFNavigationViewController* navigationController = (SFNavigationViewController *)[MSE navWithViewController:msePersonlizationVC];
//    [self presentViewController:navigationController animated:YES completion:^{
//    }];
//    }
//    }
//    else{
//    [STANDARDUSERDEFAULT setBool:NO forKey:PERSONALIZATION_PAGE_APPEARED];
//    [self proceedAfterPaymentWithInfo:userInfo];
//    }
//    }];
//    dispatch_async(dispatch_get_main_queue(), ^{
//    [self presentAlertControllerWithTitle:@"Payment Success!" andAlertMessage:@"Welcome to The Monumental Sports Network.\nTap OK to start exploring the content." andActions:@[okAction]];
//    });
//    } else {
//    [self showAlertWithMessage:userInfo];
//    }
//    }
    }
   
    
  
    
    
    func purchaseFailed()
    {
//    [self hideProgressHUD];
//    
//    UIAlertAction *okAction = [UIAlertAction
//    actionWithTitle:@"OK"
//    style:UIAlertActionStyleDefault
//    handler:^(UIAlertAction *action)
//    {
//    if (self.isFromSignIn) {
//    if([STANDARDUSERDEFAULT boolForKey:PERSONALIZATION_PAGE_APPEARED])
//    {
//    [self dismissAndNavigateToValidVC];
//    }
//    else
//    {
//    MSESignUpPersonalizationViewController *msePersonlizationVC = [[MSESignUpPersonalizationViewController alloc]initWithNibName:NibName(@"MSESignUpPersonalizationViewController") bundle:nil];
//    msePersonlizationVC.delegate = self;
//    SFNavigationViewController* navigationController = (SFNavigationViewController *)[MSE navWithViewController:msePersonlizationVC];
//    [self presentViewController:navigationController animated:YES completion:^{
//    }];
//    }
//    }
//    }];
//    UIAlertAction *tryAgainAction = [UIAlertAction
//    actionWithTitle:@"Try Again"
//    style:UIAlertActionStyleDefault
//    handler:^(UIAlertAction *action)
//    {
//    [self processThePayment];
//    }];
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//    
//    [self presentAlertControllerWithTitle:@"Payment Failed" andAlertMessage:[NSString stringWithFormat:@"The payment process did not complete/failed.\nTap OK to continue.\nTap Try Again to try again!"] andActions:@[okAction,tryAgainAction]];
//    });
//    
    
    
    }
 
    
    
    func getproductsFromServer()
    {
//    AFNetworkReachabilityStatus status = API.networkReachabilityStatus;
//    
//    if (status == AFNetworkReachabilityStatusNotReachable) {
//    
//    UIAlertController  *alertController = [UIAlertController alertControllerWithTitle:STR_INTERNETCONNETION message:STR_INTERNETCONNETION_REFRESH preferredStyle:UIAlertControllerStyleAlert];
//    
//    [alertController addAction:[UIAlertAction actionWithTitle:STR_CLOSE style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
//    
//    }]];
//    
//    [alertController addAction:[UIAlertAction actionWithTitle:STR_BUTTON_RETRY style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//    [self getproductsFromServer];
//    }]];
//    
//    [self presentViewController:alertController animated:YES completion:nil];
//    }
//    else{
//    if (self.subscriptionPlans.count <= 0) {
//    [self showProgressHUDForPlan:@""];
//    __weak MSEProductListViewController *weakSelf = self;
//    
//    [[IAPNetworkHandler sharedIAPNetworkHandler] getListOfAvailableSubscriptionPlansWithSuccess:^(NSArray *subscriptionPlans,NSString *planPrice) {
//    [self.subscriptionPlans removeAllObjects];
//    //Perform UI related task on main thread.
//    dispatch_async(dispatch_get_main_queue(), ^{
//    [weakSelf hideProgressHUD];
//    
//    [weakSelf.subscriptionPlans addObjectsFromArray:subscriptionPlans];
//    
//    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"billingPeriodType" ascending:YES];
//    [weakSelf.subscriptionPlans sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
//    
//    [weakSelf.tableViewProductList reloadData];
//    weakSelf.annualPlanPriceLbl.text = [NSString stringWithFormat:@"**  Annual plan costs $%.02f and is charged annually. There is no refund for early termination of annual plan.",[planPrice floatValue]];
//    // [self.tableViewProductList selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
//    _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self setSelectedViewAtIndexPath:_selectedIndexPath];                });
//    
//    } andFailure:^(NSError *error) {
//    [self hideProgressHUD];
//    }];
//    }
//    }
    }

    
   */
}
