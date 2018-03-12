//
//  PaymentModel.swift
//  AppCMS
//
//  Created by Rajni Pathak on 04/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class PaymentModel: NSObject{
    
   
    enum billingPeriod: Int{
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
    
    //This will show plans metadata
    var planMetaData: String?
    
    // This is Apple iTunes Connect product identifier.
    var planIdentifier: String?
    
    //This Property signifies cycle multiplier for which plan will be valid. ex = 1.
    var billingCyclePeriodMultiplier: String?
    
    //This property type of billing plan cycle, ex = MONTH
    var billingCyclePeriodType: String?
    
    //This property provides information about total cost of current plan.
    var recurringPaymentsTotal: NSNumber = 0.0
    
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
    
    //subscriptionPlansMetaData attribute holds plans meta data.
    var subscriptionPlansMetaData: SubscriptionPlanMetaData?
    
    var billingPeriodType: billingPeriod?
    override init () {

    }
}
