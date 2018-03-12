//
//  AppDelegate+UpdateAppNotification.swift
//  AppCMS
//
//  Created by Gaurav Vig on 02/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension AppDelegate {

    func presentAppUpdateView(isForceUpdate:Bool) {
        
        if self.shouldDisplayAppUpdateView && !isForceUpdate {
            
            self.createSoftAppUpdateAlert()
        }
        else if isForceUpdate {
            
            self.createForceAppUpdateView()
        }
        else {
            
            if appUpdateView != nil {
                
                self.appUpdateView?.removeFromSuperview()
                self.appUpdateView = nil
            }
        }
    }
    
    private func createSoftAppUpdateAlert() {
        
        if appUpdateView == nil {
            
            appUpdateView = SFAppUpdateView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 90), isForceUpdate: false)
            appUpdateView?.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            
            self.window?.addSubview(appUpdateView!)
            self.window?.bringSubview(toFront: appUpdateView!)
            
            appUpdateView?.alpha = 0
            
            let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(navigateToAppStore))
            appUpdateView?.addGestureRecognizer(tapGesture)
            
            let swipeUpGesture:UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(dismissappUpdateView))
            swipeUpGesture.direction = .up
            appUpdateView?.addGestureRecognizer(swipeUpGesture)
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.appUpdateView?.alpha = 1.0
            })
        }
        else {
            
            self.window?.bringSubview(toFront: appUpdateView!)
            appUpdateView?.alpha = 1.0
        }
    }
    
    
    //MARK: Method to navigate to app store
    func navigateToAppStore() {
        
        if AppConfiguration.sharedAppConfiguration.appStoreUrl != nil {
            
            guard let appStoreURL = URL(string: AppConfiguration.sharedAppConfiguration.appStoreUrl!) else { return }
            
            self.shouldDisplayAppUpdateView = false
            self.dimissSoftAppUpdateAlert()
            UIApplication.shared.openURL(appStoreURL)
        }        
    }
    
    
    //MARK: Method to dismiss the update view alert
    func dismissappUpdateView() {
        
        self.shouldDisplayAppUpdateView = false
        self.dimissSoftAppUpdateAlert()
    }
    
    private func dimissSoftAppUpdateAlert() {
        
        if self.appUpdateView != nil {
            
            UIView.animate(withDuration: Constants.kAppUpdateViewDismissAnimation, animations: {
                
                for subView in (self.appUpdateView?.subviews)! {
                    
                    subView.changeFrameHeight(height: 0)
                }
                
                self.appUpdateView?.changeFrameHeight(height: 0)
            }, completion: { (_) in
                
                self.appUpdateView?.removeFromSuperview()
                self.appUpdateView = nil
            })
        }
    }
    
    
    func dimissSoftAppUpdateAlert(completionHandler : @escaping (() -> Void)) {
        
        if self.appUpdateView != nil {
            
            UIView.animate(withDuration: Constants.kAppUpdateViewDismissAnimation, animations: {
                
                for subView in (self.appUpdateView?.subviews)! {
                    
                    subView.changeFrameHeight(height: 0)
                }
                
                self.appUpdateView?.changeFrameHeight(height: 0)
            }, completion: { (_) in
                
                self.appUpdateView?.removeFromSuperview()
                self.appUpdateView = nil
                
                completionHandler()
            })
        }
        else {
            
            completionHandler()
        }
    }
        
    //MARK: Method to create Force app update view
    private func createForceAppUpdateView() {
        
        if self.appUpdateView == nil {
            
            appUpdateView = SFAppUpdateView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), isForceUpdate: true)
            appUpdateView?.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            
            self.window?.addSubview(appUpdateView!)
            self.window?.bringSubview(toFront: appUpdateView!)
            
            appUpdateView?.alpha = 0
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.appUpdateView?.alpha = 1.0
            })
        }
        else {
            
            self.window?.bringSubview(toFront: appUpdateView!)
            appUpdateView?.alpha = 1.0
        }
    }
    
    
    
    //MARK: Method to update the app update view frame on orientation change
    func updateAppUpdateViewFrameOnOrientationChange(){
        
        if appUpdateView != nil {
            
            appUpdateView?.changeFrameWidth(width: UIScreen.main.bounds.width)
            
            if (appUpdateView?.isForceUpdate)! {
                
                appUpdateView?.changeFrameHeight(height: UIScreen.main.bounds.height)
            }
            
            appUpdateView?.updateAppUpdateSubViewsFrames()
        }
    }
}
