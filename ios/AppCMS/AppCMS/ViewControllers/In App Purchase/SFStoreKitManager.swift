//
//  SFStoreKitManager.swift
//  AppCMS
//
//  Created by Rajni Pathak on 04/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import StoreKit


 let FAILED_PAYMENT_CODE = "failed_payment"
 let FAILED_PAYMENT_MESSAGE = "Payment failed!"
 let PAYMENT_NOTIFICATION_CODE_KEY = "code"
 let PAYMENT_NOTIFICATION_MESSAGE_KEY = "message"
 let PAYMENT_NOTIFICATION_SUCCESS_KEY = "success"



class SFStoreKitManager: NSObject, SKProductsRequestDelegate,SKPaymentTransactionObserver{
    static let sharedStoreKitManager = SFStoreKitManager()
   
        let SFPurchaseCompletionNotification = "SFPurchaseCompletionNotification"
     let SFPurchaseFailedNotification = "SFPurchaseFailedNotification"
     let SFPurchaseInProcessNotification = "SFPurchaseInProcessNotification"
     let SFPurchaseProductNotAvailableNotification = "SFPurchaseProductNotAvailableNotification"
     let ShowAlertNotification = "ShowAlertNotification"
     let SFPurchaseRestoreNotification = "SFPurchaseRestoreNotification"
     let SFPurchaseRestoreWithZeroTransaction = "SFPurchaseRestoreWithZeroTransaction"

    var validProducts:Array<Any> = []
    var isProductPurchased:Bool = false
    var productIdentifier:String?

    /**
     *  Method to show alert
     *
     *  @param title   title to be shown
     *  @param message message to be shown
     */
    func showAlertWithTitle(title: String,  message messageStr:String) {
    
        let dic = ["title": title,"message":messageStr]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ShowAlertNotification), object: dic)

    }
    
    
    /**
     *  Method to restore all completed transactions for user
     */
    func restorePreviousTransaction(){
        if (canMakePurchases()) {
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
            
        else{
            //[[IncLoadingView sharedInstance] removeLoadingView];
        }
    }
    
    
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error)
    {
       // [[IncLoadingView sharedInstance] removeLoadingView];
    }
    

    
    /**
     *  Method to determine whether user can make purchase
     *
     *  @return BOOL value with determination
     */
    func canMakePurchases() -> Bool{
        return SKPaymentQueue.canMakePayments()
    }
    
    
    
    /**
     *  Method to initiate purchase product
     *
     *  @param product valid SKProduct to be purchased
     */
    func purchaseProduct(product:SKProduct){
        if (canMakePurchases()) {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
        else{
            showAlertWithTitle(title: "Purchases are disabled in your device", message: "")
        }
    }
    
    
    
    
    /**
     *  Method to initiate purchase for valid product
     */
    func initiatePurchase(){
        for transaction:SKPaymentTransaction in SKPaymentQueue.default().transactions
        {
            if transaction.transactionState == SKPaymentTransactionState.purchased
            {
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            else if (transaction.transactionState == SKPaymentTransactionState.failed) {
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
        purchaseProduct(product: validProducts[0] as! SKProduct)
    }

    
    
    /**
     *  Method to fetch product from iTunes for product identifier
     *
     *  @param pId product identifier
     */
    func fetchAvailableProductsForProdcutIdentifier(pId: String){
        if (canMakePurchases())
        {
            let productIdentifiers:NSSet = NSSet(object: pId);
            self.productIdentifier = pId
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>);
            productsRequest.delegate = self;
            productsRequest.start();
        }
        else
        {
            //MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
        
    }
 
    
    
    /**
     Method to manage the transaction and receipt
     
     @param transaction SKPaymentTransaction
     @param receiptData transaction receipt
     */
    func getTransaction(transaction: SKPaymentTransaction, andReceiptData receiptData: NSData){
        
        switch transaction.transactionState
        {
        case .purchased:
            if ((transaction.transactionIdentifier != nil)){// && receiptData) {
                let userInfo:Dictionary<String, Any>  = ["success": true,"transactionId":transaction.transactionIdentifier!,"receiptData":receiptData]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SFPurchaseCompletionNotification), object: userInfo)
            }
            
            break
        case .restored :
            if ((transaction.original!.transactionIdentifier != nil)){// && receiptData) {
                let userInfo:Dictionary<String, Any>  = ["success": true,"transactionId":transaction.transactionIdentifier!,"receiptData":receiptData]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SFPurchaseRestoreNotification), object: userInfo)
            }
            break
        default:
            
            break
        }
        
    }

    //pragma mark StoreKit Delegate
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        var totalNumberOfPurchasedProducts = 0
        for transaction:AnyObject in transactions {
            if transaction.transactionState == SKPaymentTransactionState.purchased {
                totalNumberOfPurchasedProducts += 1;
            }
        }
        
        for transaction:AnyObject in transactions
        {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction
            {
                switch trans.transactionState
                {
                case .purchasing:
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: SFPurchaseInProcessNotification), object: nil)
                    break
                case .purchased:
                    if (transaction.payment.productIdentifier == self.productIdentifier && isTheTransactionCurrentTransaction(transaction: transaction as! SKPaymentTransaction, withTotalPurchasedTransactions:totalNumberOfPurchasedProducts)) {
                        
                        self.isProductPurchased = true
                        let receiptURL = Bundle.main.appStoreReceiptURL
                        let receipt = NSData(contentsOf:receiptURL!)
                        
                        getTransaction(transaction: transaction as! SKPaymentTransaction, andReceiptData:receipt!)
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)

    
                    }
                    
                    break
                case .failed:
                    //[[IncLoadingView sharedInstance] removeLoadingView];
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    NotificationCenter.default.post(name:  NSNotification.Name(rawValue: SFPurchaseFailedNotification), object: nil)
                    self.isProductPurchased = false
                    break
                case .restored :
                     self.isProductPurchased = true
//                     for (obj:PaymentModel in [IAPNetworkHandler sharedIAPNetworkHandler].productArray){
//                        if (transaction.payment.productIdentifier == obj.planIdentifier) {
//                            let receiptURL = Bundle.main.appStoreReceiptURL
//                            
//                            var receipt:NSData = try NSData(contentsOf: receiptURL, options: NSData.ReadingOptions.alwaysMapped)
//                            
//                            getTransaction(transaction, andReceiptData:receipt)
//                            
//                            break;
//                        }
//                     }
                     
                     SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    //[[IncLoadingView sharedInstance] removeLoadingView];
                    break
                default:
                    //[[IncLoadingView sharedInstance] removeLoadingView];
                    break
                }
            }
        }
    }
    
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue)
    {
        if (queue.transactions.count == 0) {
            NotificationCenter.default.post(name:   NSNotification.Name(rawValue: SFPurchaseRestoreWithZeroTransaction), object: nil)
        }
    }

    
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        let count : Int = response.products.count
        if (count>0)
        {
            self.validProducts = response.products
            initiatePurchase()
        }
        else
        {
            showAlertWithTitle(title: "No Products Available!", message: "There are no products available for subscription on iTunes.")
        }
    }
   
    
    
    
    func isTheTransactionCurrentTransaction(transaction: SKPaymentTransaction, withTotalPurchasedTransactions totalPurchasedTransactions:Int) ->Bool
    {
        if (totalPurchasedTransactions == 1) {
            return true
        }
        else if (transaction.transactionDate != nil) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            dateFormatter.locale = NSLocale(localeIdentifier: "US") as Locale!
            
            
            let now = NSDate()
            let dateAsString:String = dateFormatter.string(from: now as Date)
            let utcDate: NSDate = dateFormatter.date(from: dateAsString)! as NSDate
            
            let secs = utcDate.timeIntervalSince(transaction.transactionDate!)
            if (secs <= 120) {
                return true
            }
        }
        return false
    }

}
