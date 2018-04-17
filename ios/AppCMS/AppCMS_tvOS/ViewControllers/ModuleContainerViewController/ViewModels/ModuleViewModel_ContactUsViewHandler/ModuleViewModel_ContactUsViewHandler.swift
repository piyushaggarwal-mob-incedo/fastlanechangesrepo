//
//  ModuleViewModel_ContactUsViewHandler.swift
//  AppCMS
//
//  Created by Rajni Pathak on 23/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ModuleViewModel_ContactUsViewHandler: ModuleViewModel {

    deinit {
        ///release any strong refrence object or observers
    }
    
    
    
    /// Call this method to create Setting View.
    ///
    /// - Parameters:
    /// - parentViewFrame: CGRect object
    /// - settingObject: SettingViewObject_tvOS object
    /// - Return:
    /// - SettingView object
    func getContactUsView(parentViewFrame:CGRect, contactUsObject: ContactUsViewObject_tvOS) -> ContactUsView_tvOS {
        
        let moduleHeight = CGFloat(Utility.fetchContactUsViewLayoutDetails(ContactUsViewObject: contactUsObject).height ?? 880)
        let moduleWidth = CGFloat(Utility.fetchContactUsViewLayoutDetails(ContactUsViewObject: contactUsObject).width ?? 1920)
        let contactUsView  = ContactUsView_tvOS.init(frame: CGRect.init(x: 0, y: 0, width: moduleWidth, height: moduleHeight), contactUsObject: contactUsObject )
        return contactUsView
    }
}
