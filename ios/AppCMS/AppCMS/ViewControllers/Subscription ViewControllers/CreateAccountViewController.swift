//
//  CreateAccountViewController.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 7/5/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import AppsFlyerLib
import AdSupport
import Firebase

class CreateAccountViewController: UIViewController {
    var emailAddress : String?
    var isNewProductPurchase = false
    var progressIndicator:MBProgressHUD?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            FIRAnalytics.logEvent(withName: kFIREventViewItem, parameters: [kFIRParameterItemName: "Create Account Screen"])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getUserIdWithTransactionWithSuccess(success: @escaping ((_ isSuccess:Bool) -> Void)) {
        let userInfo:Dictionary<String,Any>? = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as? Dictionary<String, AnyObject>)
        if userInfo != nil {
            DataManger.sharedInstance.getUserIdWithTransaction(transactionId: userInfo?["transactionId"] as! String, success: { (response:Dictionary?, isSuccess:Bool) in
                let isUserIdKeyExists = response!["id"] != nil
                if isUserIdKeyExists{
                    let userId:String = response!["id"] as! String!
                    Constants.kSTANDARDUSERDEFAULTS.set(userId, forKey: Constants.kUSERID)
                    Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                    let emailKeyExists = response!["email"] != nil
                    if emailKeyExists {
                        self.emailAddress = response!["email"] as! String!
                        if self.emailAddress?.range(of:userInfo?["transactionId"] as! String) == nil{
                            Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsAccountLinked)
                        }
                    }
                }
                success(isSuccess)
            })
        }
    }

    func dismissCreateLogin() -> Void {
        let reachability:Reachability = Reachability.forInternetConnection()

        if reachability.currentReachabilityStatus() == NotReachable {
            let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
                self.dismissCreateLogin()
            }
            self.showAlertForAlertType(alertType: .AlertTypeNoInternetFound,retryAction: retryAction)
        }
        else {
            self.dismissPresentingViewController()
        }
    }

    func showAlertForAlertType(alertType: AlertType, retryAction:UIAlertAction ) {

        let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
        }

        var alertTitleString:String?
        var alertMessage:String?

        if alertType == .AlertTypeNoInternetFound {
            alertTitleString = Constants.kInternetConnection
            alertMessage = Constants.kInternetConntectionRefresh
        }
        let networkUnavailableAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: alertTitleString ?? "", alertMessage: alertMessage ?? "", alertActions: [closeAction,retryAction])

        self.present(networkUnavailableAlert, animated: true, completion: nil)
    }

    func dismissPresentingViewController() -> Void {
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
    }

    func dismissCreateLoginOnSkip() -> Void {
        self.dismissPresentingViewController()
    }
    func showActivityIndicator(loaderText:String?) {

        progressIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        if loaderText != nil {

            progressIndicator?.label.text = loaderText!
        }
    }

    func hideActivityIndicator() {

        progressIndicator?.hide(animated: true)
    }

    func skipStep(sender:UIButton!) {
        print("Button Clicked")
        if ((Constants.kAPPDELEGATE.drawerController != nil && !Utility.sharedUtility.isDummyUserLoggedIn() && Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) == nil) || self.isNewProductPurchase) {
            let reachability:Reachability = Reachability.forInternetConnection()

            if reachability.currentReachabilityStatus() == NotReachable {
                let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
                    self.skipStep(sender:nil)
                }
                self.showAlertForAlertType(alertType: .AlertTypeNoInternetFound,retryAction: retryAction)
            }
            else{
                let userInfo:Dictionary<String,Any>? = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as? Dictionary<String, AnyObject>)
                if userInfo != nil {
                    let data:Data = userInfo!["receiptData"] as! Data
                    var base64encodedReceipt:String? = nil
                    base64encodedReceipt = data.base64EncodedString()
                    self.showActivityIndicator(loaderText: "Loading...")
                    DataManger.sharedInstance.createDummyUserWithTransactionId(transactionId: userInfo?["transactionId"] as! String, base64EncodedReceipt:base64encodedReceipt!, success: { (response:Dictionary?, isSuccess:Bool) in
                        DispatchQueue.main.async {
                            self.hideActivityIndicator()
                        }
                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsAccountLinked)
                        Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kSubscribed)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                        if Constants.kAPPDELEGATE.drawerController == nil  {
                            self.dismissCreateLogin()
                        }
                        else{
                            self.dismissCreateLoginOnSkip()
                        }
                    })
                }
            }
        }
        else if Constants.kAPPDELEGATE.drawerController != nil{
            self.dismissPresentingViewController()
        }
        else if Constants.kAPPDELEGATE.drawerController == nil && Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) != nil{
            Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kSubscribed)
            Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
            Constants.kSTANDARDUSERDEFAULTS.set(Constants.kSubscribedGuest, forKey: Constants.kLoginType)
            self.dismissCreateLogin()
        }
    }

    func nextStepAfterSuccess() -> Void {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kUserLogInSuccess), object: nil)
        if (Constants.kAPPDELEGATE.drawerController == nil ) {
            self.dismissCreateLogin()
        }
        else{
            self.dismissPresentingViewController()
        }
    }
    func showAlert(title:String?,message:String?,alertAction:UIAlertAction) -> Void {

        let networkUnavailableAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle: title ?? "" , alertMessage: message ?? "", alertActions: [alertAction])

        self.present(networkUnavailableAlert, animated: true, completion: nil)
    }

    func showalertOnSucces() -> Void {
        let alertAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrOk, style: .default) { (result : UIAlertAction) in
            self.nextStepAfterSuccess()
        }
        DispatchQueue.main.async {
            self.showAlert(title: Constants.kSuccess, message: Constants.kCreateLoginSuccessMessage, alertAction: alertAction)
        }

    }
    
    func showErrorMessage(title:String, errorMessage:String?) -> Void {
        if errorMessage != nil && (errorMessage?.characters.count)! > 0 {
            let alertAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrOk, style: .default) { (result : UIAlertAction) in
            }
            DispatchQueue.main.async {
                self.showAlert(title:title, message:errorMessage, alertAction: alertAction)
            }
        }
    }

    func saveUserWithLinkAccount() -> Void {
        if (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsAccountLinked) as! Bool == true) {
            self.showActivityIndicator(loaderText: "Loading...")
            let credetials: Dictionary<String,String> = ["email":"email","confirmEmail":"confirmEmail","password":"password"];
            DataManger.sharedInstance.saveUserAccountWithParameter(requestParameter: credetials, success: { (response:Dictionary?, isSuccess:Bool) in
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    if isSuccess == true{
                        Constants.kSTANDARDUSERDEFAULTS.set(Constants.kEmail, forKey: Constants.kLoginType)
                        Constants.kSTANDARDUSERDEFAULTS.set("email", forKey:Constants.kEmailAddress)
                        Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kSubscribed)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                        self.showalertOnSucces()
                    }
                    else{
                        //show error message
                    }
                }
            })
        }
        else{
            let message:String = "\(Constants.kAlreadyLinkedMessage)\(String(describing: self.emailAddress))."
            self.showErrorMessage(title: Constants.kAlreadyLinkedTitle, errorMessage: message)
        }
    }
    
    
    func performUserSignUp() -> Void {
        let reachability:Reachability = Reachability.forInternetConnection()

        if reachability.currentReachabilityStatus() == NotReachable {
            let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
                self.skipStep(sender:nil)
            }
            self.showAlertForAlertType(alertType: .AlertTypeNoInternetFound,retryAction: retryAction)
        }
        else{
            self.showActivityIndicator(loaderText: "Loading...")
            self.getUserIdWithTransactionWithSuccess(success: { (isSuccess:Bool) in
                if isSuccess == true {
                    if self.isNewProductPurchase && Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) != nil{
                        self.saveUserWithLinkAccount()
                    }
                    else{
                        let email:String = "email"
                        let password:String = "password"
                        let escapedEmailString = email.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                        let escapedPasswordString = password.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

                        let credetials:Dictionary<String,Any> = ["email":escapedEmailString!,"iosuser":true,"password":escapedPasswordString!]
                        DataManger.sharedInstance.userSignUp(apiEndPoint: "", requestType: .post, requestParameters: credetials, success: { (response:Dictionary?, isSuccess:Bool) in
                            if isSuccess == true{
                                Constants.kSTANDARDUSERDEFAULTS.set(Constants.kEmail, forKey: Constants.kLoginType)
                                Constants.kSTANDARDUSERDEFAULTS.set("email", forKey:Constants.kEmailAddress)
                                Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kSubscribed)
                                Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                                let userId = response?["id"]
                                Constants.kSTANDARDUSERDEFAULTS.set(userId, forKey: Constants.kUSERID)
                                AppsFlyerTracker.shared().trackEvent(Constants.APPSFLYER_EVENT_REGISTRATION, withValues: [Constants.APPSFLYER_KEY_UUID : Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) ?? "",Constants.APPSFLYER_KEY_DEVICEID : ASIdentifierManager.shared().advertisingIdentifier.uuidString , Constants.APPSFLYER_KEY_REGISTER : "true" , Constants.APPSFLYER_KEY_ENTITLED : "true"])
                              
                               

                                let userInfo:Dictionary<String,Any>? = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as? Dictionary<String, AnyObject>)
                                if userInfo != nil {
                                    let data:Data = userInfo!["receiptData"] as! Data
                                    var base64encodedReceipt:String? = nil
                                    base64encodedReceipt = data.base64EncodedString()
                                    DataManger.sharedInstance.updateSubscriptionInfoWithUserWithSuccess(userId: userId as! String, base64EncodedReceipt: base64encodedReceipt!, success: { (responseValue:Dictionary?, isTrue:Bool) in
                                        DispatchQueue.main.async {
                                            self.hideActivityIndicator()
                                            if isTrue == true{
                                                Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kSubscribed)
                                                Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                                                Constants.kSTANDARDUSERDEFAULTS.setValue(Date(), forKey: Constants.kUserOnlineTime)
                                                self.showalertOnSucces()
                                            }
                                            else{
                                                //show error message
                                            }
                                        }
                                    })
                                }
                            }
                        })
                    }
                }
                else{
                    let retryAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrRetry, style: .default) { (result : UIAlertAction) in
                        self.performUserSignUp()
                    }
                    let closeAction:UIAlertAction = UIAlertAction.init(title: Constants.kStrCancel, style: .default) { (result : UIAlertAction) in
                    }
                    let retryAlert:UIAlertController = Utility.sharedUtility.presentAlertController(alertTitle:Constants.kAccountCreationErrorTitle , alertMessage:Constants.kAccountCreationErrorMessage, alertActions: [closeAction,retryAction])

                    self.present(retryAlert, animated: true, completion: nil)
                }
            })

        }
    }
}
