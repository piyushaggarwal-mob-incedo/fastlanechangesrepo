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
     * @discussion metaDataTitle property holds metadata title.
     */
    var metaDataTitle: String?

    
    /*!
     * @discussion isCheckMarkVisible property holds whether to display Check mark icon
     */
     var isCheckMarkVisible: Bool?
    
    
    /*!
     * @discussion deviceCount property holds count of devices supported by plan.
     */
    var deviceCount:String?
    
    
    /*!
     * @discussion metaDataImageUrl property holds image url to be displayed for plan.
     */
    var metaDataImageUrl:String?
    
    override init () {
        
    }
    
    func createSubscriptionPlanMetaData(metaDataDict:Dictionary<String, AnyObject>?) -> SubscriptionPlanMetaData? {
        
        if metaDataDict == nil {
            
            return nil
        }
        
        metaDataTitle = metaDataDict?["textToDisplay"] as? String
        
        let valueType:String? = metaDataDict?["valueType"] as? String
        
        if valueType != nil {
            
            if valueType == "boolean" {
                
                let checkMarkValue:String? = metaDataDict?["value"] as? String
                
                if checkMarkValue != nil {
                    
                    switch checkMarkValue! {
                        
                    case "true", "True", "yes", "1", "y", "Y":
                        isCheckMarkVisible = true
                        break
    
                    case "false", "False", "no", "0", "n", "N":
                        isCheckMarkVisible = false
                        break
                        
                    default:
                        break
                    }
                }
                else {
                    
                    let checkMarkBoolValue:Bool? = metaDataDict?["value"] as? Bool
                    
                    if checkMarkBoolValue != nil {
                        
                        isCheckMarkVisible = checkMarkBoolValue!
                    }
                }
            }
            else if valueType == "text" {
                
                deviceCount = metaDataDict?["value"] as? String
            }
            else if valueType == "image" {
                
                metaDataImageUrl = metaDataDict?["value"] as? String
            }
        }
        
        return self
    }
}
