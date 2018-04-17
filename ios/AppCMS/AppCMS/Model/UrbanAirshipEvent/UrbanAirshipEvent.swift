//
//  UrbanAirshipEvent.swift
//  AppCMS
//
//  Created by Gaurav Vig on 09/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import UIKit
import AirshipKit

class UrbanAirshipEvent: NSObject {
    
    static let sharedInstance = UrbanAirshipEvent()
    
    //MARK: Method to trigger association of Named user on urban airship
    func triggerUserAssociationToUrbanAirship() {
        
        DataManger.sharedInstance.sendUrbanAirshipEvents(requestEndPoint: Constants.kUrbanAirshipUserAssociationEndPoint, requestType: .post, requestParameters: createRequestParametersToAssociateOrDisassociateNamedUser())
        
    }
    
    //MARK: Method to trigger disassociation of Named user on urban airship
    func triggerUserDisAssociationToUrbanAirship() {
        
        DataManger.sharedInstance.sendUrbanAirshipEvents(requestEndPoint: Constants.kUrbanAirshipUserDisAssociationEndPoint, requestType: .post, requestParameters: createRequestParametersToAssociateOrDisassociateNamedUser())
    }
    
    
    //MARK: Method to trigger logged in state of Named user on urban airship
    func triggerUserLoggedInStateTagToUrbanAirship(isUserLoggedIn:Bool) {
        
        DataManger.sharedInstance.sendUrbanAirshipEvents(requestEndPoint: Constants.kUrbanAirshipNamedUserTagEndPoint, requestType: .post, requestParameters: createRequestParameterToTagUserForLoggedInState(isUserLoggedIn: isUserLoggedIn))
    }
    
    //MARK: Method to trigger Subscription state of Named user on urban airship
    func triggerUserSubscriptionStateTagToUrbanAirship(isUserSubscribed:Bool, subscriptionEndDate: String?, planName: String?) {
        
        DataManger.sharedInstance.sendUrbanAirshipEvents(requestEndPoint: Constants.kUrbanAirshipNamedUserTagEndPoint, requestType: .post, requestParameters: createRequestParameterToTagUserForSubscribedState(isUserSubscribed: isUserSubscribed, subscriptionEndDate: subscriptionEndDate, planName: planName))
    }

    //MARK: Method to associate or disassociate iOS channel with Named user
    private func createRequestParametersToAssociateOrDisassociateNamedUser() -> Dictionary<String, Any> {
        
        var requestParameter:Dictionary<String,Any> = [Constants.kDeviceTypeKeyName:"ios"]
        
        let channelId:String? = UAirship.push().channelID
        
        if channelId != nil {
            
            requestParameter[Constants.kChannelIdKeyName] = channelId!
        }
        
        if let userId = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) {
            
            requestParameter[Constants.kNameUserIdKeyName] = userId
        }
        
        return requestParameter
    }
    
    
    //MARK: Method to create request parameter to add tag for name user
    private func createRequestParameterToTagUserForLoggedInState(isUserLoggedIn:Bool) -> Dictionary<String, Any> {
        
        var requestParameter:Dictionary<String,Any> = [:]
     
        if let userId = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) {
            
            let namedUserIdDict = [Constants.kNameUserIdKeyName : [userId]]
            requestParameter[Constants.kAudienceKeyName] = namedUserIdDict
        }
        
        requestParameter[Constants.kAddTagKeyName] = [Constants.kUserLoggedInStatusKeyName : [isUserLoggedIn ? Constants.kUserLoggedInStatusValue : Constants.kUserLoggedOutStatusValue]]
        
//        requestParameter[Constants.kRemoveTagKeyName] = [Constants.kUserLoggedInStatusKeyName : [isUserLoggedIn ? Constants.kUserLoggedOutStatusValue : Constants.kUserLoggedInStatusValue], Constants.kUserSubscriptionStatusKeyName : [isUserSubscribed ? Constants.kUserUnSubscribedValue : Constants.kUserSubscribedValue]]

        return requestParameter
    }
    
    private func createRequestParameterToTagUserForSubscribedState(isUserSubscribed:Bool, subscriptionEndDate: String?, planName: String?) -> Dictionary<String, Any> {
        var requestParameter:Dictionary<String,Any> = [:]
        
        if let userId = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) {
            
            let namedUserIdDict = [Constants.kNameUserIdKeyName : [userId]]
            requestParameter[Constants.kAudienceKeyName] = namedUserIdDict
        }
      
        var addKeyDict:Dictionary<String,Any> = [:]
        
        addKeyDict[Constants.kUserSubscriptionStatusKeyName] = [isUserSubscribed ? Constants.kUserSubscribedValue : Constants.kUserUnSubscribedValue]
        if let subscription_EndDate = subscriptionEndDate {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date = dateFormatter.date(from: subscription_EndDate)
            
            if date != nil {
                
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: date!)
                addKeyDict[Constants.kUserSubscriptionEndDateKeyName] = [dateString]
            }
            else {
                
                addKeyDict[Constants.kUserSubscriptionEndDateKeyName] = [subscription_EndDate]
            }
        }
        if let plan_Name = planName {
            addKeyDict[Constants.kUserSubscriptionPlanKeyName] = [plan_Name]
        }

        requestParameter[Constants.kAddTagKeyName] = addKeyDict

//        requestParameter[Constants.kRemoveTagKeyName] = [Constants.kUserLoggedInStatusKeyName : [isUserLoggedIn ? Constants.kUserLoggedOutStatusValue : Constants.kUserLoggedInStatusValue], Constants.kUserSubscriptionStatusKeyName : [isUserSubscribed ? Constants.kUserUnSubscribedValue : Constants.kUserSubscribedValue]]
        
        return requestParameter
    }
}
