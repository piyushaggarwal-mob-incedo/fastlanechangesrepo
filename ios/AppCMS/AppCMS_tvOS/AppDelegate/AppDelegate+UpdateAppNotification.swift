//
//  AppDelegate+UpdateAppNotification.swift
//  AppCMS_tvOS
//
//  Created by Anirudh Vyas on 24/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    func dimissSoftAppUpdateAlert(completionHandler : @escaping (() -> Void)) {
        self.shouldDisplayAppUpdateView = false
        dismissPopOver()
    }
    
    func presentAppUpdateView(isForceUpdate:Bool) {
        if shouldDisplayAppUpdateView {
            var messageString: String?
            if isForceUpdate {
                messageString = "Your app's version \(self.appVersion).\(self.appBuild) is out of date and no longer supported. The current version \(AppConfiguration.sharedAppConfiguration.appAppStoreVersionNumber ?? "") is available in the App Store for upgrade."
                
            } else {
                messageString = "There is some optimisation done in application.\nKindly update to newer app version."
            }
            if morePopOver != nil {
                morePopOver!.view.alpha = 0.0
                morePopOver!.view.removeFromSuperview()
            }
            morePopOver = SFPopOverController(title: "New Update Available", message: messageString!, preferredStyle: .alertWithBackground)
            morePopOver?.view.backgroundColor = Utility.hexStringToUIColor(hex: "#24282b").withAlphaComponent(0.3)
            morePopOver?.modalPresentationStyle = .overCurrentContext
            let updateAction = SFPopOverAction(title: "UPDATE", handler: { (action) in
                self.openAppStore()
            })
            if isForceUpdate == false {
                let closeAction = SFPopOverAction(title: "CLOSE", handler: { (action) in
                    self.dimissSoftAppUpdateAlert(completionHandler: {
                        
                    })
                })
                morePopOver!.actions = [updateAction,closeAction]
            } else {
                morePopOver!.actions = [updateAction]
            }
            morePopOver!.view.alpha = 0.0
            Constants.kAPPDELEGATE.appContainerVC?.view.isUserInteractionEnabled = false
            let keyWindow = UIApplication.shared.windows[0]
            keyWindow.addSubview((morePopOver?.view)!)
            UIView.animate(withDuration: 0.2) {
                self.morePopOver!.view.alpha = 1.0
            }
        } else if isForceUpdate {
            dismissPopOver()
            presentAppUpdateView(isForceUpdate: true)
        }
    }
    
    private func dismissPopOver() {
        if let _morePopOver = morePopOver {
            UIView.animate(withDuration: 0.2, animations: {
                _morePopOver.view.alpha = 0.0
            }, completion: { (done) in
                Constants.kAPPDELEGATE.appContainerVC?.view.isUserInteractionEnabled = true
                _morePopOver.view.removeFromSuperview()
            })
        }
    }
    
    private func openAppStore() {
        if AppConfiguration.sharedAppConfiguration.appStoreUrl != nil {
            
            guard let appStoreURL = URL(string: AppConfiguration.sharedAppConfiguration.appStoreUrl!) else { return }
            
            self.shouldDisplayAppUpdateView = false
            self.dimissSoftAppUpdateAlert(completionHandler: {})
            UIApplication.shared.openURL(appStoreURL)
        }
    }
}
