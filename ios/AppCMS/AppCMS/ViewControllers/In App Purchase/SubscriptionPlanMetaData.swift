//
//  SubscriptionPlanMetaData.swift
//  AppCMS
//
//  Created by Rajni Pathak on 05/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class SubscriptionPlanMetaData:NSObject{
    
    /*!
     * @discussion planTitle property holds plan title.
     */
    var planTitle: String?

    
    /*!
     * @discussion planPriceTitle property holds plan price.
     */
     var planPriceTitle: String?
    
    
    /*!
     * @discussion plandescription property holds plans meta dataValues.
     */
    var planMetaData:Array<Any> = []
    

}
