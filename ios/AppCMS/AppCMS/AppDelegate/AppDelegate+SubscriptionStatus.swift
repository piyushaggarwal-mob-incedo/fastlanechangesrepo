//
//  AppDelegate+SubscriptionStatus.swift
//  AppCMS
//
//  Created by Gaurav Vig on 29/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    func fetchUserSubscriptionStatusFromServer(shouldUpdateIAPReceipt:Bool) {
        
        let reachability:Reachability = Reachability.forInternetConnection()
        if reachability.currentReachabilityStatus() != NotReachable {
            
            if (Utility.sharedUtility.checkIfUserIsSubscribedGuest() || Utility.sharedUtility.checkIfUserIsLoggedIn()) && AppConfiguration.sharedAppConfiguration.serviceType != nil {
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD && !self.isStatusUpdateAPIInProgress {
                        
                        if shouldUpdateIAPReceipt {
                            
                            self.isStatusUpdateAPIInProgress = true
                        }
                        
                        DataManger.sharedInstance.apiToGetUserEntitledStatus(success: { (isSubscribed) in
                            
                            DispatchQueue.main.async {
                                
                                if isSubscribed != nil {
                                    
                                    Constants.kSTANDARDUSERDEFAULTS.set(isSubscribed!, forKey: Constants.kIsSubscribedKey)
                                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                                    
                                    if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                        
                                        Utility.sharedUtility.setGTMUserProperty(userPropertyValue: isSubscribed! ? Constants.kGTMSubscribedPropertyValue : Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                                    }
                                }
                                else {
                                    
                                    let subscriptionStatus:Bool? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool
                                    
                                    if subscriptionStatus != nil {
                                        
                                        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                            
                                            Utility.sharedUtility.setGTMUserProperty(userPropertyValue: subscriptionStatus! ? Constants.kGTMSubscribedPropertyValue : Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                                        }
                                    }
                                    else {
                                        
                                        Constants.kSTANDARDUSERDEFAULTS.set(false, forKey: Constants.kIsSubscribedKey)
                                        Constants.kSTANDARDUSERDEFAULTS.synchronize()
                                        
                                        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
                                            
                                            Utility.sharedUtility.setGTMUserProperty(userPropertyValue: Constants.kGTMNotSubscribedPropertyValue, userPropertyKeyName: Constants.kGTMSubscriptionStatusProperty)
                                        }
                                    }
                                }
                                
                                if shouldUpdateIAPReceipt {
                                    
                                    self.updateIAPReceiptToServer(isSubscribed: isSubscribed ?? false)
                                }
                                else {
                                    
                                    if shouldUpdateIAPReceipt {
                                        
                                        self.isStatusUpdateAPIInProgress = false
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    
    //MARK: Update IAP Receipt to server
    func updateIAPReceiptToServer(isSubscribed:Bool) {
        let transactionInfo:Dictionary<String, Any>? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as? Dictionary<String, Any>
        
        if !isSubscribed {
          
            if transactionInfo != nil {
                
                let receiptData:NSData? = transactionInfo?["receiptData"] as? NSData
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    self.updateSubscriptionInfoWithReceiptdata(isSubscribed: isSubscribed, receipt: receiptData, emailId: nil, productIdentifier: transactionInfo!["productIdentifier"] as? String, transactionIdentifier: transactionInfo!["transactionId"] as? String, success: { (isSuccess) in
                        
                        self.isStatusUpdateAPIInProgress = false
                    })
                }
            }
            else {
                
                self.fetchSubscriptionDetailsFromServerUsingReceiptUrl(success: { (subscriptionDetails, isSubscriptionDetailsAvailable, receiptData) in
                    
                    if isSubscriptionDetailsAvailable == true {
                        
                        let originalTransactionIdentifier:String? = subscriptionDetails?["paymentUniqueId"] as? String
                        let planIdentifier:String? = subscriptionDetails?["planIdentifier"] as? String
                        
                        if originalTransactionIdentifier != nil && planIdentifier != nil {
                            
                            DispatchQueue.global(qos: .userInitiated).async {
                                
                                self.updateSubscriptionInfoWithReceiptdata(isSubscribed: isSubscribed, receipt: receiptData, emailId: nil, productIdentifier: planIdentifier!, transactionIdentifier: originalTransactionIdentifier!, success: { (isSuccess) in
                                    
                                    self.isStatusUpdateAPIInProgress = false
                                })
                            }
                        }
                        else {
                            
                            self.isStatusUpdateAPIInProgress = false
                        }
                    }
                    else {
                        
                        self.isStatusUpdateAPIInProgress = false
                    }
                })
            }
        }
        else {
            
            self.fetchSubscriptionDetailsFromServerUsingReceiptUrl(success: { (subscriptionDetails, isSubscriptionDetailsAvailable, receiptData) in
                
                self.isStatusUpdateAPIInProgress = false
            })
        }
    }
    
    
    //MARK: Method to fetch subscription details from server using receipt url
    func fetchSubscriptionDetailsFromServerUsingReceiptUrl(success: @escaping ((_ subscriptionDetails:Dictionary<String, Any>?, _ isSubscriptionDetailsAvailable:Bool, _ receiptData:NSData?) -> Void)) {
        
        let appStoreReceiptURL = Bundle.main.appStoreReceiptURL
        
        if let receiptUrl = appStoreReceiptURL {
            
            let receiptData:NSData? = NSData(contentsOf:receiptUrl)
            
            if receiptData != nil {
                
                let receiptString = (receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)))!

                let requestParameter:Dictionary<String, Any> = ["receipt":receiptString]
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    DataManger.sharedInstance.apiToValidateReceiptFromApple(requestParameter: requestParameter, success: { (subscriptionDetails, isSuccess) in
                        
                        DispatchQueue.main.async {
                            
                            if isSuccess == true && subscriptionDetails != nil {
                                
                                success(subscriptionDetails, isSuccess, receiptData)
                            }
                            else {
                                
                                success(nil, isSuccess, receiptData)
                            }
                        }
                    })
                }
            }
        }
        else {
            
            success(nil, false, nil)
        }
    }
    
    
    /**
     Method to update subscription info with user
     @param receipt transaction receipt
     */
    func updateSubscriptionInfoWithReceiptdata(isSubscribed:Bool, receipt: NSData?, emailId:String?, productIdentifier:String?, transactionIdentifier:String?, success: @escaping ((_ isSuccess:Bool) -> Void))
    {
        let requestParameters:Dictionary<String, Any> = Utility.sharedUtility.getRequestParametersForSubscription(receiptData: receipt, emailId: emailId, paymentModelObject: nil, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
        
        print("Entered >>>>>")
        DataManger.sharedInstance.apiToUpdateSubscriptionStatus(requestParameter: requestParameters, requestType: isSubscribed == true ? .put : .post ) { (subscriptionResponse, isSuccess) in
            
            DispatchQueue.main.async {
             
                print("subscription response >>>> \(subscriptionResponse ?? [:])")
                if subscriptionResponse != nil {
                    
                    if isSuccess {
                        
                        Constants.kSTANDARDUSERDEFAULTS.set(true, forKey: Constants.kIsSubscribedKey)
                        Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kTransactionInfo)
                        Constants.kSTANDARDUSERDEFAULTS.synchronize()
                        
                        Constants.kAPPDELEGATE.removePlistFromDocumentDirectory(plistName: Constants.kTransactionDetailPlistName)
                        
                        success(true)
                    }
                    else {
                        
                        success(isSuccess)
                    }
                }
                else {
                    
                    success(false)
                }
            }
        }
    }
}
