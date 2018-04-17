//
//  SubscriptionHandler.swift
//  AppCMS
//
//  Created by Gaurav Vig on 31/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SubscriptionHandler: NSObject {

    
    /**
     Method to update subscription info with user
     @param receipt transaction receipt
     */
    class func updateSubscriptionInfoWithReceiptdata(receipt: NSData?, emailId:String?, productIdentifier:String?, transactionIdentifier:String?, success: @escaping ((_ isSuccess:Bool) -> Void))
    {
//        self.view.isUserInteractionEnabled = false
//        self.showActivityIndicator(loaderText: nil)
        
        let requestParameters:Dictionary<String, Any> = Utility.sharedUtility.getRequestParametersForSubscription(receiptData: receipt, emailId: emailId, paymentModelObject: nil, productIdentifier: productIdentifier, transactionIdentifier: transactionIdentifier)
        DataManger.sharedInstance.apiToUpdateSubscriptionStatus(requestParameter: requestParameters, requestType: .post) { (subscriptionResponse, isSuccess) in
            
//            self.view.isUserInteractionEnabled = true
//            self.hideActivityIndicator()
            
            if subscriptionResponse != nil {
                
                if isSuccess {
                    
                    Constants.kSTANDARDUSERDEFAULTS.setValue(nil, forKey: Constants.kTransactionInfo)
                    Constants.kSTANDARDUSERDEFAULTS.synchronize()
                    
                    success(true)
                    //self.checkIfUserShouldBeNavigatedToHomeScreenOnTap(isSuccessfullyRegistered:true)
                }
                else {
                    
//                    let errorCode:String? = subscriptionResponse?["code"] as? String
//                    
//                    if errorCode != nil {
//                        self.showSubscriptionAlertWithMessage(message: ["code": errorCode!], success: { (isSuccess) in
//                            
//                            success(isSuccess)
//                        })
//                    }
//                    else {
//                        
//                        success(false)
//                    }
                }
            }
            else {
                
//                success(false)
            }
        }
    }
}
