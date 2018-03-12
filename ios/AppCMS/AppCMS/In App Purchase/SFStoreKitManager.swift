//
//  SFStoreKitManager.swift
//  AppCMS
//
//  Created by Rajni Pathak on 04/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation
import StoreKit


class SFStoreKitManager: NSObject, SKProductsRequestDelegate,SKPaymentTransactionObserver {
    
    static let sharedStoreKitManager:SFStoreKitManager = {
        
        let instance = SFStoreKitManager()
        
        SKPaymentQueue.default().add(instance)
        return instance
    }()
    
    var validProducts:Array<Any> = []
    var isProductPurchased:Bool = false
    var productIdentifier:String?
    var serverSubscriptionPlans:Array<AnyObject> = []
    private var productsRequest:SKProductsRequest?
    /**
     *  Method to show alert
     *
     *  @param title   title to be shown
     *  @param message message to be shown
     */
    func showAlertWithTitle(title: String,  message messageStr:String) {
        
        let dic = ["title": title,"message":messageStr]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kShowAlertNotification), object: nil, userInfo: dic)
    }
    
    
    /**
     *  Method to restore all completed transactions for user
     */
    func restorePreviousTransaction() {
        
        if (canMakePurchases()) {
            
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
        else {
            
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue: Constants.kSFPurchaseFailedNotification), object: nil)
        }
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error)
    {
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue: Constants.kSFPurchaseFailedNotification), object: nil)
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
    func fetchAvailableProductsForProdcutIdentifier(pId: String, subscriptionPlans:Array<AnyObject>){
        
        if (canMakePurchases())
        {
            if self.serverSubscriptionPlans.count > 0 {
                
                self.serverSubscriptionPlans.removeAll()
            }
            
            self.serverSubscriptionPlans = subscriptionPlans
            
            let productIdentifiers:NSSet = NSSet(object: pId);
            self.productIdentifier = pId
            productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productsRequest?.delegate = self
            productsRequest?.start()
        }
        else
        {
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue: Constants.kSFPurchaseFailedNotification), object: nil)
        }
    }
    
    
    /**
     Method to manage the transaction and receipt
     
     @param transaction SKPaymentTransaction
     @param receiptData transaction receipt
     */
    func getTransaction(transaction: SKPaymentTransaction, andReceiptData receiptData: NSData?){
        
        switch transaction.transactionState
        {
        case .purchased:
            if transaction.transactionIdentifier != nil && receiptData != nil {
                
                var transactionId:String = transaction.transactionIdentifier!
                
                if transaction.original != nil {
                    
                    if transaction.original?.transactionIdentifier != nil {
                        
                        transactionId = transaction.original!.transactionIdentifier!
                    }
                }
                
                let userInfo:Dictionary<String, Any>  = ["success": true, "transactionId":transactionId,"receiptData":receiptData!, "productIdentifier":transaction.payment.productIdentifier]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kSFPurchaseCompletionNotification), object: nil, userInfo: userInfo)
            }
            
            break
        case .restored :
            
            if transaction.original != nil {
                
                if ((transaction.original!.transactionIdentifier != nil) && receiptData != nil) {
                    
                    let userInfo:Dictionary<String, Any>  = ["success": true, "transactionId":transaction.original!.transactionIdentifier!,"receiptData":receiptData!, "productIdentifier":transaction.payment.productIdentifier]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreNotification), object: nil, userInfo: userInfo)
                }
                else if (transaction.original!.transactionIdentifier != nil) {
                    
                    let userInfo:Dictionary<String, Any>  = ["success": true, "transactionId":transaction.original!.transactionIdentifier!,"productIdentifier":transaction.payment.productIdentifier]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreNotification), object: nil, userInfo: userInfo)
                }
                else {
                    
                    SKPaymentQueue.default().finishTransaction(transaction)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseFailedNotification), object: nil)
                }
            }
            else {
                
                SKPaymentQueue.default().finishTransaction(transaction)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseFailedNotification), object: nil)
            }
            break
        default:
            
            break
        }
        
    }
    
    //MARK: StoreKit Delegate methods
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        var totalNumberOfPurchasedProducts = 0
        for transaction:AnyObject in transactions {
            if transaction.transactionState == SKPaymentTransactionState.purchased {
                totalNumberOfPurchasedProducts = totalNumberOfPurchasedProducts + 1;
            }
        }
        
        for transaction:AnyObject in transactions
        {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction
            {
                switch trans.transactionState
                {
                case .purchasing:
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kSFPurchaseInProcessNotification), object: nil)
                    break
                case .purchased:
                    if (transaction.payment.productIdentifier == self.productIdentifier && isTheTransactionCurrentTransaction(transaction: transaction as! SKPaymentTransaction, withTotalPurchasedTransactions:totalNumberOfPurchasedProducts)) {
                        
                        self.isProductPurchased = true
                       
                        let receiptURL = Bundle.main.appStoreReceiptURL
                        let receipt:NSData? = NSData(contentsOf:receiptURL!)
                        
                        getTransaction(transaction: transaction as! SKPaymentTransaction, andReceiptData:receipt)
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    }
                    else {
                        
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        NotificationCenter.default.post(name:  NSNotification.Name(rawValue: Constants.kSFPurchaseFailedNotification), object: nil)
                    }
                    
                    break
                case .failed:
                    
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    NotificationCenter.default.post(name:  NSNotification.Name(rawValue: Constants.kSFPurchaseFailedNotification), object: nil)
                    self.isProductPurchased = false
                    break
                case .restored :
                    
                        let receiptURL:URL? = Bundle.main.appStoreReceiptURL
                        
                        if receiptURL != nil && !self.isProductPurchased {
                            
                            self.isProductPurchased = true

                            let receiptData:NSData? = NSData(contentsOf: receiptURL!)
                            getTransaction(transaction: transaction as! SKPaymentTransaction, andReceiptData: receiptData)
                            
                            SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kSFRestorePurchaseCompletionNotification), object: nil)
                        }
                        else {
                            
                            SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kSFPurchaseFailedNotification), object: nil)
                        }
                    
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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kSFPurchaseRestoreWithZeroTransaction), object: nil)
        }
    }
    
    
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        let count : Int = response.products.count
        if (count > 0)
        {
            self.validProducts = response.products
            initiatePurchase()
        }
        else
        {
            showAlertWithTitle(title: "No Products Available!", message: "There are no products available for subscription on iTunes.")
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue: Constants.kSFPurchaseFailedNotification), object: nil)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        
        let userInfo:Dictionary<String, String> = ["errorMessage": error.localizedDescription]
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue: Constants.kSFiTunesConnectErrorNotification), object: nil, userInfo: userInfo)
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
