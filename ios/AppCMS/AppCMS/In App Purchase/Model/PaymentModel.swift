//
//  PaymentModel.swift
//  AppCMS
//
//  Created by Rajni Pathak on 04/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class PaymentModel: NSObject {
    
    enum BillingPeriod: Int{
        case YEARLY
        case MONTHLY
        case OTHER
    }

    //This is plan ID, this will be a unique identifier for payment plan.
    var planID: String?
    
    //This attribute will tell type for a plan, ex = SUBSCRIPTION_PLAN
    var planType: String?
    
    //This is description text for plan
    var planDescription: String?
    
    //This will show plan's name
    var planName: String?
    
    // This is Apple iTunes Connect product identifier.
    var planIdentifier: String?
    
    //This Property signifies cycle multiplier for which plan will be valid. ex = 1.
    var billingCyclePeriodMultiplier: NSNumber?
    
    //This property type of billing plan cycle, ex = MONTH
    var billingCyclePeriodType: String?
    
    //This property provides information about total cost of current plan.
    var recurringPaymentsTotal: NSNumber?
    
    //Start time(if subscribed) of subscription to current plan.
    var timeStampStartTime: String?
    
    //End time(if subscribed) of subscription to current plan.
    var timeStampEndTime: String?
    
    //Boolean attribute. This is used to dictate whether a plan is hidden or visible.
    var isPlanVisible: Bool?
    
    //Boolean attribute. This is used to dictate whether plan is subscribable
    var isPlanSubscribableBasedOnDate: Bool?
    
    //String attribute. This is used to hold the currency information.
    var recurringPaymentsTotalCurrency: String?
    
    //subscriptionPlansMetaData attribute holds array of plan meta data.
    var subscriptionPlansMetaData: Array<SubscriptionPlanMetaData>?
    
    //This will tell the billing period for plan
    var billingPeriodType: BillingPeriod?
    
    //This will show discounted price for plan
    var planDiscountedPrice: NSNumber?
    
    //This will show original price for plan
    var planOriginalPrice:NSNumber?
    
    //This will show the site owner for plan
    var siteOwner:String?
    
    //This is used to save country code of plan
    var countryCode:String?
    
    //This is used to display plan selection button text
    var planSelectionButtonText:String?
    override init () {

    }
    
    
    //MARK: Method to create plan details
    func createPlanDetails(planDetailsDict:Dictionary<String, AnyObject>) -> PaymentModel {
        
        self.planID = planDetailsDict["id"] as? String
        self.planName = planDetailsDict["name"] as? String
        self.planIdentifier = planDetailsDict["identifier"] as? String
        self.planDescription = planDetailsDict["description"] as? String
        
        self.billingCyclePeriodMultiplier = planDetailsDict["renewalCyclePeriodMultiplier"] as? NSNumber
        
        let planBillingType:String? = planDetailsDict["renewalCycleType"] as? String
        
        if planBillingType != nil {
            
            if planBillingType?.lowercased() == "month" {
                
                self.billingPeriodType = BillingPeriod.MONTHLY
            }
            else if planBillingType?.lowercased() == "year" {
                
                self.billingPeriodType = BillingPeriod.YEARLY
            }
            else {
                
                self.billingPeriodType = BillingPeriod.OTHER
            }
        }
        
        self.planType = planDetailsDict["objectKey"] as? String
        
        let planDetailsArray:Array<Dictionary<String, AnyObject>>? = planDetailsDict["planDetails"] as? Array<Dictionary<String, AnyObject>>
        
        if planDetailsArray != nil {
            
            for details in planDetailsArray! as Array<Dictionary<String, AnyObject>> {
                
                self.recurringPaymentsTotal = details["recurringPaymentAmount"] as? NSNumber
                self.recurringPaymentsTotalCurrency = details["recurringPaymentCurrencyCode"] as? String
                self.countryCode = details["countryCode"] as? String
                self.isPlanVisible = planDetailsDict["visible"] as? Bool
                self.planDiscountedPrice = details["strikeThroughPrice"] as? NSNumber
                self.planSelectionButtonText = details["callToAction"] as? String
                let planMetaDataListArray:Array<AnyObject>? = details["featureDetails"] as? Array<AnyObject>
                
                if planMetaDataListArray != nil {
                    
                    for featureList in planMetaDataListArray! {
                        
                        let subscriptionPlanMetaData:SubscriptionPlanMetaData? = SubscriptionPlanMetaData.init().createSubscriptionPlanMetaData(metaDataDict: featureList as? Dictionary<String, AnyObject>)
                        
                        if subscriptionPlanMetaData != nil {
                            
                            if subscriptionPlansMetaData == nil {
                                
                                subscriptionPlansMetaData = []
                            }
                            subscriptionPlansMetaData?.append(subscriptionPlanMetaData!)
                        }
                    }
                }
            }
        }
        
        return self
    }
}
