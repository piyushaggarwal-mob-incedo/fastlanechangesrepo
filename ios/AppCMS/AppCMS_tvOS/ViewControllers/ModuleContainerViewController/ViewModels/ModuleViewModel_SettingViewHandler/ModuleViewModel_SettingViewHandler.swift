//
//  ModuleViewModel_SettingViewHandler.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 16/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ModuleViewModel_SettingViewHandler: ModuleViewModel,SettingViewDelegate {

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
    func getSettingView(parentViewFrame:CGRect, settingObject: SettingViewObject_tvOS, pageObject: Page) -> SettingView_tvOS {
        
        let moduleHeight = CGFloat(Utility.fetchSettingsViewLayoutDetails(settingViewObject: settingObject).height ?? 880)
        let moduleWidth = CGFloat(Utility.fetchSettingsViewLayoutDetails(settingViewObject: settingObject).width ?? 1920)
        let settingView  = SettingView_tvOS.init(frame: CGRect.init(x: 0, y: 0, width: moduleWidth, height: moduleHeight), settingObject: settingObject, pageObject: pageObject)
        settingView.delegate = self
        return settingView
    }
    
    ///Clear all user related data and navigate to home page
    func logoutButtonTapped() {
        Constants.kAPPDELEGATE.clearUserDefaultSettings()
        ///Navigate to home page.
        Constants.kAPPDELEGATE.navigateToHomeScreen()
    }
}
